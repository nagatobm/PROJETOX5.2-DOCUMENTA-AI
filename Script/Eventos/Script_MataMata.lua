--[[ 
    Script_EventMataMata.lua
    Desenvolvido por: 
                        Jonathan C. (Style)
    Organização:
                        Padrão SystemMain + Ferramentas.lua
    Lógica:
                        Torneio 1vs1 (Fases -> Semi -> Final)
]]--

local SystemMain        = {};
local SystemConfigs     = {};

BridgeFunctionAttach("OnReadScript", "evMataMata_ReadScript");
BridgeFunctionAttach("OnTimerThread", "evMataMata_TimerThread");
BridgeFunctionAttach("OnCommandManager", "evMataMata_CommandManager");
BridgeFunctionAttach("OnUserDie", "evMataMata_UserDie");
BridgeFunctionAttach("OnCharacterClose", "evMataMata_CharacterClose");

function evMataMata_ReadScript()

    SystemConfigs.Timer                         = {};
    SystemConfigs.Timer[1]                      = "04:45:20";
    SystemConfigs.Timer[2]                      = "19:00:00";
    SystemConfigs.Timer[3]                      = "22:30:00";

    -- [TEMPOS]
    SystemConfigs.TimeOpen                      = 5;                -- Tempo de Inscrição (Minutos);
    SystemConfigs.TimeFight                     = 3;                -- Tempo Máximo de Luta (Minutos);
    SystemConfigs.TimePrep                      = 10;               -- Tempo de Preparação na Arena (Segundos);

    -- [ENTRADA]
    SystemConfigs.CommandID                     = 122;
    SystemConfigs.CommandName                   = "/matamata";
    SystemConfigs.MinLevel                      = 200;
    SystemConfigs.MinPlayers                    = 2;                -- Mínimo para iniciar o torneio;

    -- [MAPA]
    SystemConfigs.Map                           = 6;                -- Arena;
    
    -- LOBBY (Onde ficam esperando a vez)
    SystemConfigs.LobbyX                        = 76;
    SystemConfigs.LobbyY                        = 76;

    -- ARENA DE LUTA (Onde ocorre o X1)
    SystemConfigs.RingX1                        = 63;               -- Posição Jogador 1;
    SystemConfigs.RingY1                        = 63;
    SystemConfigs.RingX2                        = 63;               -- Posição Jogador 2;
    SystemConfigs.RingY2                        = 70;

    -- SAÍDA (Eliminados)
    SystemConfigs.TownMap                       = 0;
    SystemConfigs.TownX                         = 125;
    SystemConfigs.TownY                         = 125;

    -- [PREMIAÇÃO TOP 3]
    SystemConfigs.RewardCoin                    = "GOLD";
    SystemConfigs.Rewards                       = {
        [1] = 10000, -- 1º Lugar
        [2] = 5000,  -- 2º Lugar
        [3] = 2000   -- 3º Lugar (Perdedor da Semi ou Finalista 2)
    };

    -- Agendamento
    if (Schedule and Schedule.SetExactTime) then
        for i = 1, #SystemConfigs.Timer do
            Schedule.SetExactTime(SystemConfigs.Timer[i], SystemMain.StartEvent);
        end
    end

    Utils.Log("[EventMataMata]: Ligado (Modo Torneio).", 4);

end

function SystemMain.StartEvent()

    if (SystemMain.Stage == nil) then
        
        SystemMain.Stage            = 1;    -- 1: Inscrição
        SystemMain.Count            = 0;
        SystemMain.TimeLeft         = SystemConfigs.TimeOpen;
        
        SystemMain.Users            = {};   -- Lista {Index, Name, Fase}
        SystemMain.Fight            = nil;  -- Dados da Luta Atual {P1, P2, State, Timer}
        SystemMain.CurrentFase      = 1;    -- Fase Atual do Torneio
        SystemMain.Podium           = {};   -- Armazena vencedores {1=Nome, 2=Nome, 3=Nome}

        Utils.Log("[MATAMATA]: Iniciado (Inscrição).", 4);
        
        NoticeGlobalSend(0, ". : [ EVENTO MATA-MATA ] : .");
        NoticeGlobalSend(0, "Inscrições Abertas! Digite "..SystemConfigs.CommandName);
        NoticeGlobalSend(1, "A entrada fecha em "..SystemConfigs.TimeOpen.." minuto(s).");

    end

end

function evMataMata_TimerThread()

    -- [ESTÁGIO 1]: INSCRIÇÃO
    if (SystemMain.Stage == 1) then

        -- Contagem Regressiva (30s)
        local TotalSec = SystemConfigs.TimeOpen * 60;
        local RemSec   = TotalSec - SystemMain.Count;

        if (RemSec == 30) then
            NoticeGlobalSend(0, "[MataMata]: O Torneio inicia em 30 segundos!");
        elseif (RemSec <= 5 and RemSec > 0) then
            NoticeGlobalSend(0, "[MataMata]: Início em "..RemSec.."s...");
        end

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then
            
            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then
                
                if (#SystemMain.Users >= SystemConfigs.MinPlayers) then
                    
                    SystemMain.Stage = 2; -- Inicia Torneio
                    SystemMain.Count = 0;
                    
                    NoticeGlobalSend(0, ". : [ MATA-MATA INICIADO ] : .");
                    NoticeGlobalSend(0, "Inscrições Encerradas! Total: "..#SystemMain.Users.." lutadores.");
                    NoticeGlobalSend(0, "Aguardem no Lobby. O sistema chamará as duplas.");
                    
                    Utils.Log("[MATAMATA]: Torneio Iniciado. Players: "..#SystemMain.Users, 4);

                else
                    NoticeGlobalSend(0, "[MataMata]: Cancelado. Falta de jogadores.");
                    SystemMain.Finish();
                end

            else
                NoticeGlobalSend(0, "[MataMata]: Inscrições fecham em "..SystemMain.TimeLeft.." min.");
            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    -- [ESTÁGIO 2]: GERENCIAMENTO DO TORNEIO (LOOP)
    elseif (SystemMain.Stage == 2) then

        -- Se não tem luta rolando, tenta criar uma
        if (SystemMain.Fight == nil) then
            
            -- Verifica se tem ganhador (Apenas 1 na fase atual e nenhum nas anteriores)
            if (#SystemMain.Users == 1) then
                SystemMain.DeclareWinner();
                return;
            end

            -- Busca jogadores na Fase Atual
            local P1, P2 = SystemMain.GetFightersForPhase(SystemMain.CurrentFase);

            if (P1 and P2) then
                
                -- Inicia Luta
                SystemMain.StartFight(P1, P2);

            else
                
                -- Se não achou par, verifica se sobrou alguém sozinho (Bye) ou se todos já passaram
                local CountInFase = SystemMain.CountPlayersInPhase(SystemMain.CurrentFase);
                
                if (CountInFase == 1) then
                    
                    -- Passa o que sobrou de fase automaticamente (Chapéu)
                    local Lucky = SystemMain.GetPlayerInPhase(SystemMain.CurrentFase);
                    if (Lucky) then
                        Lucky.Fase = Lucky.Fase + 1;
                        NoticeSend(Lucky.Index, 1, "[MataMata]: Você passou para a Fase "..(SystemMain.CurrentFase + 1).." por W.O (Sorteio).");
                        NoticeGlobalSend(0, "[MataMata]: "..Lucky.Name.." avançou de fase automaticamente.");
                    end

                elseif (CountInFase == 0) then
                    
                    -- Ninguém mais nesta fase, avança a fase global
                    SystemMain.CurrentFase = SystemMain.CurrentFase + 1;
                    NoticeGlobalSend(0, ". : [ FASE "..SystemMain.CurrentFase.." ] : .");
                    NoticeGlobalSend(0, "Preparando próximas lutas...");
                    
                end

            end

        else
            -- [GERENCIA A LUTA ATUAL]
            SystemMain.ProcessFight();
        end

    end

end

function evMataMata_CommandManager(aIndex, code, arg)

    if (code == SystemConfigs.CommandID) then

        if (SystemMain.Stage == 1) then
            
            if (SystemMain.IsRegistered(aIndex)) then
                NoticeSend(aIndex, 1, "[MataMata]: Você já está inscrito.");
                return 1;
            end

            local Player = Utils.GetPlayer(aIndex);
            
            if (Player:getLevel() < SystemConfigs.MinLevel) then
                NoticeSend(aIndex, 1, "[MataMata]: Level mínimo: "..SystemConfigs.MinLevel);
                return 1;
            end

            -- Adiciona
            table.insert(SystemMain.Users, { Index = aIndex, Name = Player:getName(), Fase = 1 });
            
            MoveUserEx(aIndex, SystemConfigs.Map, SystemConfigs.LobbyX, SystemConfigs.LobbyY);
            NoticeSend(aIndex, 1, "[MataMata]: Inscrito! Aguarde no Lobby.");
            
            return 1;

        else
            NoticeSend(aIndex, 1, "[MataMata]: Inscrições fechadas.");
            return 1;
        end

    end

    return 0;

end

function evMataMata_UserDie(aIndex, bIndex)

    if (SystemMain.Stage == 2 and SystemMain.Fight ~= nil) then
        
        -- Verifica se quem morreu está na luta
        if (SystemMain.Fight.State == 2) then -- Só conta morte se a luta já VALEU (State 2)
            
            if (aIndex == SystemMain.Fight.P1.Index) then
                SystemMain.EndFight(SystemMain.Fight.P2, SystemMain.Fight.P1); -- P2 Venceu
            elseif (aIndex == SystemMain.Fight.P2.Index) then
                SystemMain.EndFight(SystemMain.Fight.P1, SystemMain.Fight.P2); -- P1 Venceu
            end

        end

    end

end

function evMataMata_CharacterClose(aIndex)

    if (SystemMain.Stage ~= nil) then
        
        -- Remove da lista geral
        for k, v in pairs(SystemMain.Users) do
            if (v.Index == aIndex) then
                table.remove(SystemMain.Users, k);
                
                -- Se estava lutando, dá vitória pro outro
                if (SystemMain.Fight ~= nil) then
                    if (SystemMain.Fight.P1.Index == aIndex) then
                        SystemMain.EndFight(SystemMain.Fight.P2, SystemMain.Fight.P1);
                    elseif (SystemMain.Fight.P2.Index == aIndex) then
                        SystemMain.EndFight(SystemMain.Fight.P1, SystemMain.Fight.P2);
                    end
                end
                
                NoticeGlobalSend(0, "[MataMata]: "..v.Name.." desconectou e foi eliminado.");
                return;
            end
        end

    end

end

-- [SISTEMA DE TORNEIO]

function SystemMain.StartFight(P1, P2)

    SystemMain.Fight = {
        P1 = P1,
        P2 = P2,
        State = 1, -- 1 = Preparação, 2 = Valendo
        Timer = SystemConfigs.TimePrep
    };

    -- Move para Arena
    MoveUserEx(P1.Index, SystemConfigs.Map, SystemConfigs.RingX1, SystemConfigs.RingY1);
    MoveUserEx(P2.Index, SystemConfigs.Map, SystemConfigs.RingX2, SystemConfigs.RingY2);

    -- Trava ou Avida
    NoticeGlobalSend(0, ". : [ DUELO INICIADO ] : .");
    NoticeGlobalSend(0, P1.Name .. " VS " .. P2.Name);
    NoticeSend(P1.Index, 0, "Prepare-se! A luta começa em "..SystemConfigs.TimePrep.."s!");
    NoticeSend(P2.Index, 0, "Prepare-se! A luta começa em "..SystemConfigs.TimePrep.."s!");

end

function SystemMain.ProcessFight()

    if (SystemMain.Fight.State == 1) then
        
        -- Contagem de Preparação
        SystemMain.Fight.Timer = SystemMain.Fight.Timer - 1;
        
        if (SystemMain.Fight.Timer <= 0) then
            SystemMain.Fight.State = 2;
            SystemMain.Fight.Timer = SystemConfigs.TimeFight * 60; -- Converte min para seg
            
            NoticeSend(SystemMain.Fight.P1.Index, 0, "LUTEM!!!");
            NoticeSend(SystemMain.Fight.P2.Index, 0, "LUTEM!!!");
            NoticeGlobalSend(0, "[MataMata]: VALENDO!");
        end

    elseif (SystemMain.Fight.State == 2) then

        -- Tempo de Luta (Anti-Camp)
        SystemMain.Fight.Timer = SystemMain.Fight.Timer - 1;

        if (SystemMain.Fight.Timer <= 0) then
            NoticeGlobalSend(0, "[MataMata]: Tempo Esgotado! Ambos eliminados.");
            
            -- Remove ambos
            SystemMain.Eliminate(SystemMain.Fight.P1);
            SystemMain.Eliminate(SystemMain.Fight.P2);
            
            SystemMain.Fight = nil; -- Reseta Luta
        end

    end

end

function SystemMain.EndFight(Winner, Loser)

    NoticeGlobalSend(0, "[MataMata]: O vencedor é "..Winner.Name.."!");
    
    -- Vencedor: Sobe de Fase e Volta pro Lobby
    Winner.Fase = Winner.Fase + 1;
    MoveUserEx(Winner.Index, SystemConfigs.Map, SystemConfigs.LobbyX, SystemConfigs.LobbyY);
    -- UserRestoreHP(Winner.Index, 100000); -- Opcional: Curar

    -- Perdedor: Eliminado e Salva no Ranking se for Top 3
    local Survivors = #SystemMain.Users; -- Contagem antes de remover
    
    -- Lógica de Pódio
    if (Survivors == 3) then -- Se tinham 3 e um morreu, ele é o 3º
        SystemMain.Podium[3] = Loser.Name;
        SystemMain.GiveReward(Loser.Index, 3);
        NoticeGlobalSend(0, "[MataMata]: "..Loser.Name.." conquistou o 3º Lugar!");
    
    elseif (Survivors == 2) then -- Se tinham 2 e um morreu, ele é o 2º
        SystemMain.Podium[2] = Loser.Name;
        SystemMain.GiveReward(Loser.Index, 2);
        NoticeGlobalSend(0, "[MataMata]: "..Loser.Name.." conquistou o 2º Lugar!");
    end

    SystemMain.Eliminate(Loser);
    SystemMain.Fight = nil; -- Libera para próxima luta

end

function SystemMain.Eliminate(Player)
    
    -- Remove da tabela
    for k, v in pairs(SystemMain.Users) do
        if (v.Index == Player.Index) then
            table.remove(SystemMain.Users, k);
            break;
        end
    end

    MoveUserEx(Player.Index, SystemConfigs.TownMap, SystemConfigs.TownX, SystemConfigs.TownY);

end

function SystemMain.DeclareWinner()

    local Champion = SystemMain.Users[1]; -- O último que sobrou
    
    if (Champion) then
        
        NoticeGlobalSend(0, ". : [ TORNEIO FINALIZADO ] : .");
        NoticeGlobalSend(0, "CAMPEÃO: "..string.upper(Champion.Name).."!");
        
        -- Premia 1º Lugar
        SystemMain.GiveReward(Champion.Index, 1);
        
        MoveUserEx(Champion.Index, SystemConfigs.TownMap, SystemConfigs.TownX, SystemConfigs.TownY);

    end

    SystemMain.Finish();

end

-- [FUNÇÕES AUXILIARES]

function SystemMain.GetFightersForPhase(Fase)
    
    local Candidates = {};
    for k, v in pairs(SystemMain.Users) do
        if (v.Fase == Fase) then
            table.insert(Candidates, v);
        end
    end

    if (#Candidates >= 2) then
        -- Embaralha
        local R1 = math.random(1, #Candidates);
        local P1 = Candidates[R1];
        table.remove(Candidates, R1);
        
        local R2 = math.random(1, #Candidates);
        local P2 = Candidates[R2];
        
        return P1, P2;
    end

    return nil, nil;

end

function SystemMain.CountPlayersInPhase(Fase)
    local c = 0;
    for k, v in pairs(SystemMain.Users) do
        if (v.Fase == Fase) then c = c + 1; end
    end
    return c;
end

function SystemMain.GetPlayerInPhase(Fase)
    for k, v in pairs(SystemMain.Users) do
        if (v.Fase == Fase) then return v; end
    end
    return nil;
end

function SystemMain.GiveReward(aIndex, Rank)
    local Amount = SystemConfigs.Rewards[Rank];
    local Player = Utils.GetPlayer(aIndex);
    
    if (Player and Utility_Master) then
        Utility_Master.AddCoin(Player, SystemConfigs.RewardCoin, Amount, 1);
        Utils.Log("[MATAMATA]: Premio Rank "..Rank.." para "..Player:getName(), 4);
    end
end

function SystemMain.IsRegistered(aIndex)
    for k, v in pairs(SystemMain.Users) do
        if (v.Index == aIndex) then return true; end
    end
    return false;
end

function SystemMain.Finish()
    -- Limpa tudo
    for k, v in pairs(SystemMain.Users) do
        MoveUserEx(v.Index, SystemConfigs.TownMap, SystemConfigs.TownX, SystemConfigs.TownY);
    end
    
    SystemMain.Stage = nil;
    SystemMain.Users = nil;
    SystemMain.Fight = nil;
    
    Utils.Log("[MATAMATA]: Evento Resetado.", 4);
end

function NoticeGlobalSend(type, msg)
    if (SendMessageGlobal) then
        SendMessageGlobal(msg, type);
    elseif (Utils and Utils.Broadcast) then
        Utils.Broadcast(msg, type);
    elseif (NoticeSendToAll) then
        NoticeSendToAll(type, msg);
    end
end