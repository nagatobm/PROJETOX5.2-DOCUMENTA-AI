--[[ 
    Script_EventRakilion.lua
    Desenvolvido por: 
                        Jonathan C. (Style)
    Organização:
                        Padrão SystemMain + Ferramentas.lua
    Atualização:
                        Mensagens Dinâmicas por Estágio
]]--

local SystemMain        = {};
local SystemConfigs     = {};

BridgeFunctionAttach("OnReadScript", "evRakilion_ReadScript");
BridgeFunctionAttach("OnTimerThread", "evRakilion_TimerThread");
BridgeFunctionAttach("OnMonsterDie", "evRakilion_MonsterDie");
BridgeFunctionAttach("OnUserDie", "evRakilion_UserDie");
BridgeFunctionAttach("OnCommandManager", "evRakilion_CommandManager");

function evRakilion_ReadScript()

    -- Horários de Início
    SystemConfigs.Timer                         = {};
    SystemConfigs.Timer[1]                      = "03:25:00";
    SystemConfigs.Timer[2]                      = "10:00:00";
    SystemConfigs.Timer[3]                      = "18:00:00";
    SystemConfigs.Timer[4]                      = "22:00:00";

    -- Configurações de Tempo (Minutos)
    SystemConfigs.TimeOpen                      = 5;                -- Tempo para entrar (Comando Aberto);
    SystemConfigs.TimeEggs                      = 5;                -- Tempo para destruir os Ovos;
    SystemConfigs.TimeBattle                    = 15;               -- Tempo para matar o Selupan;

    -- Configuração de Entrada
    SystemConfigs.CommandID                     = 121;              -- ID do Comando (/raklion);
    SystemConfigs.CommandName                   = "/raklion";       -- Nome visual;
    
    SystemConfigs.MoveMap                       = 57;               -- Mapa Raklion;
    SystemConfigs.MoveX                         = 175;              -- Coordenada X (Entrada da Hatchery);
    SystemConfigs.MoveY                         = 25;               -- Coordenada Y;
    SystemConfigs.MinLevel                      = 350;              -- Level mínimo;

    -- Configuração dos Ovos (Fase 2)
    SystemConfigs.EggClass                      = 460;              -- ID do Ovo (Spider Egg);
    SystemConfigs.Eggs                          = {
        [1] = { X = 168, Y = 20 },
        [2] = { X = 180, Y = 20 },
        [3] = { X = 175, Y = 15 },
        [4] = { X = 175, Y = 30 }
    };

    -- Configuração do Boss (Selupan - Fase 3)
    SystemConfigs.BossClass                     = 459;              -- ID do Selupan;
    SystemConfigs.BossX                         = 175;
    SystemConfigs.BossY                         = 25;

    -- Premiação Boss (Utility_Master)
    SystemConfigs.RewardCoin                    = "CASH";
    SystemConfigs.RewardAmount                  = 100;
    
    -- Premiação PVP (Rei do Gelo)
    SystemConfigs.RewardPKCoin                  = "GOLD";
    SystemConfigs.RewardPKAmount                = 50000;

    -- Agendamento (Schedule da Ferramentas.lua)
    if (Schedule and Schedule.SetExactTime) then
        for i = 1, #SystemConfigs.Timer do
            Schedule.SetExactTime(SystemConfigs.Timer[i], SystemMain.StartEvent);
        end
    end

    Utils.Log("[EventRakilion]: Ligado. Comando ID: "..SystemConfigs.CommandID, 4);

end

function SystemMain.StartEvent()

    if (SystemMain.Stage == nil) then
        
        SystemMain.Stage            = 1; -- ESTÁGIO 1: ABERTO
        SystemMain.Count            = 0;
        SystemMain.TimeLeft         = SystemConfigs.TimeOpen;
        
        SystemMain.BossIndex        = -1;
        SystemMain.EggList          = {};
        SystemMain.EggCount         = 0;
        
        SystemMain.RankingPK        = {};
        SystemMain.TopKillerName    = "";
        SystemMain.TopKillerKills   = 0;

        Utils.Log("[EVENTO_RAKILION]: Iniciado (Entrada Aberta).", 4);
        
        NoticeGlobalSend(0, ". : [ EVENTO RAKILION ] : .");
        NoticeGlobalSend(0, "A incubadora de Raklion está ABERTA!");
        NoticeGlobalSend(0, "Digite "..SystemConfigs.CommandName.." para entrar.");
        NoticeGlobalSend(1, "A entrada fecha em "..SystemConfigs.TimeOpen.." minuto(s).");

    end

end

function evRakilion_TimerThread()

    -- [ESTÁGIO 1]: Entrada Aberta (Comando Funciona)
    if (SystemMain.Stage == 1) then

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then

            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then

                SystemMain.Stage            = 2; -- VAI PARA OVOS
                SystemMain.Count            = 0;
                SystemMain.TimeLeft         = SystemConfigs.TimeEggs;

                -- SPAWN OVOS
                SystemMain.EggCount = 0;
                
                for i = 1, #SystemConfigs.Eggs do
                    
                    local e = SystemConfigs.Eggs[i];
                    local idx = MonsterCreate(SystemConfigs.EggClass, SystemConfigs.MoveMap, e.X, e.Y, 1);
                    
                    table.insert(SystemMain.EggList, idx);
                    SystemMain.EggCount = SystemMain.EggCount + 1;

                    Utils.Log(string.format("[RAKLION_SPAWN]: Ovo (Index:%d) nasceu em X:%d Y:%d", idx, e.X, e.Y), 3);

                end

                NoticeGlobalSend(0, ". : [ RAKILION - FASE 2 ] : .");
                NoticeGlobalSend(0, "Entrada FECHADA! Os Ovos de Aranha apareceram!");
                NoticeGlobalSend(0, "Destruam os "..SystemMain.EggCount.." ovos para atrair o Selupan!");
                
                Utils.Log("[EVENTO_RAKILION]: Fase Ovos Iniciada.", 4);

            else

                NoticeGlobalSend(0, "[Raklion]: Entrada fecha em "..SystemMain.TimeLeft.." minuto(s). Digite "..SystemConfigs.CommandName);

            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    -- [ESTÁGIO 2]: Destruir Ovos (Entrada Fechada)
    elseif (SystemMain.Stage == 2) then

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then

            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then

                NoticeGlobalSend(0, "[Raklion]: Falha! Os ovos chocaram aranhas menores e o Selupan fugiu.");
                SystemMain.Finish();

            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    -- [ESTÁGIO 3]: Boss Selupan (Entrada Fechada)
    elseif (SystemMain.Stage == 3) then

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then

            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then

                NoticeGlobalSend(0, "[Raklion]: O Selupan se escondeu novamente no gelo. Evento encerrado.");
                
                if (SystemMain.BossIndex ~= -1) then 
                    MonsterDelete(SystemMain.BossIndex); 
                end
                
                SystemMain.Finish();

            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    end

end

function evRakilion_CommandManager(aIndex, code, arg)

    if (code == SystemConfigs.CommandID) then

        -- Verifica Estágio 1 (Único momento que pode entrar)
        if (SystemMain.Stage == 1) then
            
            local Player = Utils.GetPlayer(aIndex);
            
            if (Player:getLevel() < SystemConfigs.MinLevel) then
                NoticeSend(aIndex, 1, "[Raklion]: Level mínimo necessário: "..SystemConfigs.MinLevel);
                return 1;
            end

            MoveUserEx(aIndex, SystemConfigs.MoveMap, SystemConfigs.MoveX, SystemConfigs.MoveY);
            
            NoticeSend(aIndex, 1, "[Raklion]: Bem-vindo a Incubadora!");
            
            return 1;

        -- Mensagens Detalhadas para Estágios Fechados
        elseif (SystemMain.Stage == 2) then

            NoticeSend(aIndex, 1, "[Raklion]: Entrada Fechada! A batalha contra os Ovos já começou.");
            return 1;

        elseif (SystemMain.Stage == 3) then

            NoticeSend(aIndex, 1, "[Raklion]: Entrada Fechada! O Selupan já está vivo.");
            return 1;

        else

            NoticeSend(aIndex, 1, "[Raklion]: O evento está fechado no momento. Próximo às: Verifique o site.");
            return 1;

        end

    end

    return 0;

end

function evRakilion_MonsterDie(aIndex, bIndex)

    -- Fase 2: Ovos
    if (SystemMain.Stage == 2) then
        
        for k, v in pairs(SystemMain.EggList) do
            
            if (v == bIndex) then
                
                SystemMain.EggList[k] = -1;
                SystemMain.EggCount   = SystemMain.EggCount - 1;
                
                if (SystemMain.EggCount <= 0) then
                    
                    -- TODOS DESTRUIDOS -> SPAWN BOSS SELUPAN
                    SystemMain.Stage     = 3;
                    SystemMain.Count     = 0;
                    SystemMain.TimeLeft  = SystemConfigs.TimeBattle;
                    
                    SystemMain.BossIndex = MonsterCreate(SystemConfigs.BossClass, SystemConfigs.MoveMap, SystemConfigs.BossX, SystemConfigs.BossY, 1);
                    
                    Utils.Log(string.format("[RAKLION_SPAWN]: SELUPAN (Index:%d) nasceu em X:%d Y:%d", SystemMain.BossIndex, SystemConfigs.BossX, SystemConfigs.BossY), 2);

                    NoticeGlobalSend(0, ". : [ RAKILION - FASE FINAL ] : .");
                    NoticeGlobalSend(0, "TODOS OS OVOS FORAM DESTRUIDOS!");
                    NoticeGlobalSend(0, "O SELUPAN APARECEU FURIOSO!");

                else
                    
                    local PName = Utils.GetPlayer(aIndex):getName();
                    NoticeGlobalSend(0, "[Raklion]: Um ovo foi destruído por "..PName.."! Restam: "..SystemMain.EggCount);

                end
                
                return;

            end

        end

    -- Fase 3: Selupan
    elseif (SystemMain.Stage == 3) then
        
        if (bIndex == SystemMain.BossIndex) then
            
            local Player = Utils.GetPlayer(aIndex);

            NoticeGlobalSend(0, ". : [ EVENTO RAKILION FINALIZADO ] : .");
            NoticeGlobalSend(0, "O Selupan foi derrotado por "..string.upper(Player:getName()).."!");

            -- Prêmio Boss
            if (Utility_Master) then
                Utility_Master.AddCoin(Player, SystemConfigs.RewardCoin, SystemConfigs.RewardAmount, 1);
            end

            -- Prêmio Top Killer
            if (SystemMain.TopKillerName ~= "") then
                NoticeGlobalSend(0, "Rei do Gelo (Top Killer): "..SystemMain.TopKillerName.." com "..SystemMain.TopKillerKills.." Kills!");
                Utils.Log("[RAKLION_RESULT]: Top Killer: "..SystemMain.TopKillerName, 4);
            end

            SystemMain.Finish();

        end

    end

end

function evRakilion_UserDie(aIndex, bIndex)

    if (SystemMain.Stage ~= nil and SystemMain.Stage > 0) then

        -- Verifica Mapa
        if (GetObjectMap(aIndex) == SystemConfigs.MoveMap and GetObjectMap(bIndex) == SystemConfigs.MoveMap) then
            
            local KillerName = GetObjectName(bIndex);
            
            if (not SystemMain.RankingPK[KillerName]) then
                SystemMain.RankingPK[KillerName] = 0;
            end
            
            SystemMain.RankingPK[KillerName] = SystemMain.RankingPK[KillerName] + 1;
            
            if (SystemMain.RankingPK[KillerName] > SystemMain.TopKillerKills) then
                
                SystemMain.TopKillerKills = SystemMain.RankingPK[KillerName];
                SystemMain.TopKillerName  = KillerName;
                
                NoticeSend(bIndex, 1, "[Raklion]: Você lidera o massacre! ("..SystemMain.TopKillerKills.." kills)");
            
            else
                
                NoticeSend(bIndex, 1, "[Raklion]: Kill +1! Total: "..SystemMain.RankingPK[KillerName]);
            
            end

        end

    end

end

function SystemMain.Finish()

    -- Limpa Ovos restantes
    if (SystemMain.EggList) then
        for _, idx in pairs(SystemMain.EggList) do
            if (idx ~= -1) then MonsterDelete(idx); end
        end
    end
    
    if (SystemMain.BossIndex and SystemMain.BossIndex ~= -1) then 
        MonsterDelete(SystemMain.BossIndex); 
    end

    SystemMain.Stage            = nil;
    SystemMain.Count            = nil;
    SystemMain.BossIndex        = nil;
    SystemMain.EggList          = nil;
    SystemMain.RankingPK        = nil;

    Utils.Log("[EVENTO_RAKILION]: Evento Resetado.", 4);

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