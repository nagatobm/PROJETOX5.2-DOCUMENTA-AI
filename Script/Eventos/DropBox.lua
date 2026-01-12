--[[ 
    Script_EventKalima.lua
    Desenvolvido por: 
                        Jonathan C. (Style)
    Organização:
                        Padrão SystemMain + Logs de Spawn
]]--

local SystemMain        = {};
local SystemConfigs     = {};

BridgeFunctionAttach("OnReadScript", "evKalima_ReadScript");
BridgeFunctionAttach("OnTimerThread", "evKalima_TimerThread");
BridgeFunctionAttach("OnMonsterDie", "evKalima_MonsterDie");
BridgeFunctionAttach("OnUserDie", "evKalima_UserDie");
BridgeFunctionAttach("OnCommandManager", "evKalima_CommandManager");

function evKalima_ReadScript()

    SystemConfigs.Timer                         = {};
    SystemConfigs.Timer[1]                      = "00:30:00";
    SystemConfigs.Timer[2]                      = "06:30:00";
    SystemConfigs.Timer[3]                      = "12:30:00";
    SystemConfigs.Timer[4]                      = "18:30:00";
    SystemConfigs.Timer[5]                      = "21:30:00";

    -- Configurações de Tempo (Minutos)
    SystemConfigs.TimeOpen                      = 5;                -- Tempo com o portal ABERTO.
    SystemConfigs.TimeGuardians                 = 10;               -- Tempo para matar os Guardiões.
    SystemConfigs.TimeBattle                    = 10;               -- Tempo para matar o Kundun.

    -- Configuração de Entrada
    SystemConfigs.CommandID                     = 120;              -- ID do Comando (/kalima).
    SystemConfigs.CommandName                   = "/kalima";
    SystemConfigs.MoveMap                       = 29;               -- Mapa (Kalima 7).
    SystemConfigs.MoveX                         = 16;
    SystemConfigs.MoveY                         = 12;
    SystemConfigs.MinLevel                      = 300;

    -- Fase dos Guardiões (Monstros que devem morrer antes do Boss)
    SystemConfigs.Guardians                     = {
        [1] = { Class = 275, X = 26, Y = 60 },  
        [2] = { Class = 275, X = 40, Y = 60 },  
        [3] = { Class = 275, X = 35, Y = 70 }
    };
    
    -- Configuração do Boss Final (Kundun)
    SystemConfigs.BossClass                     = 275;
    SystemConfigs.BossX                         = 26;
    SystemConfigs.BossY                         = 76;

    -- Premiação
    SystemConfigs.RewardCoin                    = "CASH";
    SystemConfigs.RewardAmount                  = 50;
    SystemConfigs.RewardPKCoin                  = "GOLD";
    SystemConfigs.RewardPKAmount                = 10000;

    -- Agendamento
    if (Schedule and Schedule.SetExactTime) then
        for i = 1, #SystemConfigs.Timer do
            Schedule.SetExactTime(SystemConfigs.Timer[i], SystemMain.StartEvent);
        end
    end

    Utils.Log("[EventKalima]: Ligado. Comando ID: "..SystemConfigs.CommandID, 4);

end

function SystemMain.StartEvent()

    if (SystemMain.Stage == nil) then
        
        SystemMain.Stage            = 1; -- ABERTO
        SystemMain.Count            = 0;
        SystemMain.TimeLeft         = SystemConfigs.TimeOpen;
        
        SystemMain.BossIndex        = -1;
        SystemMain.GuardianList     = {};
        SystemMain.GuardianCount    = 0;
        
        SystemMain.RankingPK        = {};
        SystemMain.TopKillerName    = "";
        SystemMain.TopKillerKills   = 0;

        Utils.Log("[EVENTO_KALIMA]: Iniciado (Entrada Aberta).", 4);
        
        NoticeGlobalSend(0, ". : [ EVENTO KALIMA ] : .");
        NoticeGlobalSend(0, "O portal para Kalima 7 está ABERTO!");
        NoticeGlobalSend(0, "Objetivo: Derrote os Guardiões para invocar o Kundun.");

    end

end

function evKalima_TimerThread()

    -- [ESTÁGIO 1]: Entrada Aberta
    if (SystemMain.Stage == 1) then

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then

            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then

                SystemMain.Stage            = 2; -- VAI PARA GUARDIÕES
                SystemMain.Count            = 0;
                SystemMain.TimeLeft         = SystemConfigs.TimeGuardians;

                -- SPAWN GUARDIÕES
                SystemMain.GuardianCount = 0;
                
                for i = 1, #SystemConfigs.Guardians do
                    
                    local g = SystemConfigs.Guardians[i];
                    local idx = MonsterCreate(g.Class, SystemConfigs.MoveMap, g.X, g.Y, 1);
                    
                    table.insert(SystemMain.GuardianList, idx);
                    SystemMain.GuardianCount = SystemMain.GuardianCount + 1;

                    -- LOG DE SPAWN (GUARDIÃO)
                    Utils.Log(string.format("[KALIMA_SPAWN]: Guardiao (Index:%d Class:%d) nasceu em Map:%d X:%d Y:%d", idx, g.Class, SystemConfigs.MoveMap, g.X, g.Y), 3);

                end

                NoticeGlobalSend(0, ". : [ EVENTO KALIMA - FASE 1 ] : .");
                NoticeGlobalSend(0, "Entrada FECHADA! Os Guardiões do Selo apareceram!");
                NoticeGlobalSend(0, "Eliminem os "..SystemMain.GuardianCount.." Guardiões para o Kundun nascer!");
                
                Utils.Log("[EVENTO_KALIMA]: Fase Guardiões Iniciada.", 4);

            else

                NoticeGlobalSend(0, "[Kalima]: Entrada fecha em "..SystemMain.TimeLeft.." minuto(s). Digite "..SystemConfigs.CommandName);

            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    -- [ESTÁGIO 2]: Guardiões
    elseif (SystemMain.Stage == 2) then

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then

            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then

                NoticeGlobalSend(0, "[Kalima]: Falha! Os Guardiões não foram mortos a tempo.");
                SystemMain.Finish();

            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    -- [ESTÁGIO 3]: Boss Final
    elseif (SystemMain.Stage == 3) then

        if (SystemMain.Count % 60 == 0) and (SystemMain.Count > 0) then

            SystemMain.TimeLeft = SystemMain.TimeLeft - 1;

            if (SystemMain.TimeLeft <= 0) then

                NoticeGlobalSend(0, "[Kalima]: O tempo acabou! Kundun escapou com vida.");
                if (SystemMain.BossIndex ~= -1) then MonsterDelete(SystemMain.BossIndex); end
                SystemMain.Finish();

            end

        end

        SystemMain.Count = SystemMain.Count + 1;

    end

end

function evKalima_CommandManager(aIndex, code, arg)

    if (code == SystemConfigs.CommandID) then

        if (SystemMain.Stage == 1) then
            
            local Player = Utils.GetPlayer(aIndex);
            
            if (Player:getLevel() < SystemConfigs.MinLevel) then
                NoticeSend(aIndex, 1, "[Kalima]: Level mínimo necessário: "..SystemConfigs.MinLevel);
                return 1;
            end

            MoveUserEx(aIndex, SystemConfigs.MoveMap, SystemConfigs.MoveX, SystemConfigs.MoveY);
            NoticeSend(aIndex, 1, "[Kalima]: Bem-vindo a Arena da Morte!");
            return 1;

        else

            NoticeSend(aIndex, 1, "[Kalima]: O portal está fechado. A batalha já começou.");
            return 1;

        end

    end

    return 0;

end

function evKalima_MonsterDie(aIndex, bIndex)

    -- Fase 2: Matando Guardiões
    if (SystemMain.Stage == 2) then
        
        for k, v in pairs(SystemMain.GuardianList) do
            
            if (v == bIndex) then
                
                SystemMain.GuardianList[k] = -1;
                SystemMain.GuardianCount   = SystemMain.GuardianCount - 1;
                
                local PlayerName = Utils.GetPlayer(aIndex):getName();
                
                if (SystemMain.GuardianCount <= 0) then
                    
                    -- TODOS MORTOS -> INVOCA BOSS
                    SystemMain.Stage     = 3;
                    SystemMain.Count     = 0;
                    SystemMain.TimeLeft  = SystemConfigs.TimeBattle;
                    
                    -- SPAWN BOSS
                    SystemMain.BossIndex = MonsterCreate(SystemConfigs.BossClass, SystemConfigs.MoveMap, SystemConfigs.BossX, SystemConfigs.BossY, 1);
                    
                    -- LOG DE SPAWN (BOSS)
                    Utils.Log(string.format("[KALIMA_SPAWN]: BOSS KUNDUN (Index:%d) nasceu em Map:%d X:%d Y:%d", SystemMain.BossIndex, SystemConfigs.MoveMap, SystemConfigs.BossX, SystemConfigs.BossY), 2);

                    NoticeGlobalSend(0, ". : [ EVENTO KALIMA - FASE FINAL ] : .");
                    NoticeGlobalSend(0, "O SELO FOI QUEBRADO POR "..string.upper(PlayerName).."!");
                    NoticeGlobalSend(0, "O LORDE KUNDUN RENASCEU! MATEM-NO!");

                else
                    
                    NoticeGlobalSend(0, "[Kalima]: Um Guardião caiu pelas mãos de "..PlayerName.."! Restam: "..SystemMain.GuardianCount);

                end
                
                return;

            end

        end

    -- Fase 3: Matando Boss
    elseif (SystemMain.Stage == 3) then
        
        if (bIndex == SystemMain.BossIndex) then
            
            local Player = Utils.GetPlayer(aIndex);

            NoticeGlobalSend(0, ". : [ EVENTO KALIMA FINALIZADO ] : .");
            NoticeGlobalSend(0, "O Lorde Kundun foi derrotado por "..string.upper(Player:getName()).."!");

            if (Utility_Master) then
                Utility_Master.AddCoin(Player, SystemConfigs.RewardCoin, SystemConfigs.RewardAmount, 1);
            end

            if (SystemMain.TopKillerName ~= "") then
                NoticeGlobalSend(0, "Rei do PVP (Top Killer): "..SystemMain.TopKillerName.." com "..SystemMain.TopKillerKills.." Kills!");
                Utils.Log("[KALIMA_RESULT]: Top Killer: "..SystemMain.TopKillerName, 4);
            end

            SystemMain.Finish();

        end

    end

end

function evKalima_UserDie(aIndex, bIndex)

    if (SystemMain.Stage ~= nil and SystemMain.Stage > 0) then

        if (GetObjectMap(aIndex) == SystemConfigs.MoveMap and GetObjectMap(bIndex) == SystemConfigs.MoveMap) then
            
            local KillerName = GetObjectName(bIndex);
            
            if (not SystemMain.RankingPK[KillerName]) then
                SystemMain.RankingPK[KillerName] = 0;
            end
            
            SystemMain.RankingPK[KillerName] = SystemMain.RankingPK[KillerName] + 1;
            
            if (SystemMain.RankingPK[KillerName] > SystemMain.TopKillerKills) then
                SystemMain.TopKillerKills = SystemMain.RankingPK[KillerName];
                SystemMain.TopKillerName  = KillerName;
                NoticeSend(bIndex, 1, "[Kalima]: Você é o novo Rei do PVP!");
            end

        end

    end

end

function SystemMain.Finish()

    if (SystemMain.GuardianList) then
        for _, idx in pairs(SystemMain.GuardianList) do
            if (idx ~= -1) then MonsterDelete(idx); end
        end
    end
    
    if (SystemMain.BossIndex and SystemMain.BossIndex ~= -1) then 
        MonsterDelete(SystemMain.BossIndex); 
    end

    SystemMain.Stage            = nil;
    SystemMain.Count            = nil;
    SystemMain.BossIndex        = nil;
    SystemMain.GuardianList     = nil;
    SystemMain.RankingPK        = nil;

    Utils.Log("[EVENTO_KALIMA]: Evento Resetado.", 4);

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