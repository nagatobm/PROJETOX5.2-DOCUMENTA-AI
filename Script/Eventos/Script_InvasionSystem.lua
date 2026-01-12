--[[ 
    Script_InvasionSystem.lua
    Desenvolvido por: 
                        Jonathan C. (Style)
    Correções:
                        - Autorização GM nos comandos
                        - Logs de Coordenadas no Console (Spawn)
                        - Anúncio de Quem Matou + Restantes (Imediato)
    Padrão:
                        LuaClass (User.new), LuaBridge, Funcoes.txt
]]--

local SystemMain        = {};
local SystemConfigs     = {};

-- Tabelas de Controle
local ActiveInvasions   = {}; 
local InvasionMonsters  = {}; 
local InvasionRanking   = {}; 

-- [LUABRIDGE] Registro de Eventos
BridgeFunctionAttach("OnReadScript", "evInvasion_ReadScript");
BridgeFunctionAttach("OnTimerThread", "evInvasion_TimerThread");
BridgeFunctionAttach("OnMonsterDie", "evInvasion_MonsterDie");
BridgeFunctionAttach("OnCommandManager", "evInvasion_CommandManager");

function evInvasion_ReadScript()

    -- [COMANDOS GM]
    SystemConfigs.CmdStartID                    = 124; -- /invstart
    SystemConfigs.CmdEndID                      = 125; -- /invend
    SystemConfigs.GMLevel                       = 32;   -- Nível minimo de GM (1, 8, 32 dependendo do server)

    -- [CONFIGURAÇÃO DAS INVASÕES]
    SystemConfigs.Invasions                     = {};

    -- INVASÃO 1: GOLDEN
    SystemConfigs.Invasions[1] = {
        Name            = "Golden Invasion",
        Duration        = 10,
        AnnounceGlobal  = true, -- Avisar quantos faltam?
        AnnounceKill    = true, -- Avisar quem matou?
        Schedules       = { "08:00:00", "12:00:00", "20:00:00" },
        Monsters = {
            { Class = 295,  Map = 0, Count = 5000, Points = 10 }, 
            { Class = 53,  Map = 2, Count = 5,  Points = 20 }, 
        },
        Drops = {
            { Class = 78, Section = 14, Index = 13, Level = 0, Chance = 8000 }, 
        }
    };

    -- INVASÃO 2: RED DRAGON
    SystemConfigs.Invasions[2] = {
        Name            = "Red Dragon Invasion",
        Duration        = 10,
        AnnounceGlobal  = true,
        AnnounceKill    = true,
        Schedules       = { "19:30:00", "23:30:00" },
        Monsters = {
            { Class = 44, Map = 0, Count = 100, Points = 1 }, 
        },
        Drops = {} 
    };

    -- [AGENDAMENTO]
    if (Schedule and Schedule.SetExactTime) then
        for id, inv in pairs(SystemConfigs.Invasions) do
            for _, time in ipairs(inv.Schedules) do
                Schedule.SetExactTime(time, SystemMain.StartInvasion, id);
            end
        end
    end

    Utils.Log("[InvasionSystem]: Carregado com Sucesso.", 4);

end

-- =======================================================================
-- LÓGICA DE CONTROLE
-- =======================================================================

function SystemMain.StartInvasion(InvID)

    local Config = SystemConfigs.Invasions[InvID];
    
    if (not Config or ActiveInvasions[InvID]) then return; end

    -- Inicializa Dados
    ActiveInvasions[InvID] = {
        Running         = true,
        StartTime       = os.time(),
        EndTime         = os.time() + (Config.Duration * 60),
        Ranking         = {}
    };

    -- Cria Monstros
    local TotalSpawned = 0;
    for _, mob in ipairs(Config.Monsters) do
        local count = SystemMain.CreateMonsterGroup(InvID, mob.Class, mob.Map, mob.Count, mob.Points, mob.X, mob.Y);
        TotalSpawned = TotalSpawned + count;
    end

    if (Config.AnnounceGlobal) then
        NoticeGlobalSend(0, ". : [ INVASÃO INICIADA ] : .");
        NoticeGlobalSend(0, Config.Name .. " comecou! Monstros: " .. TotalSpawned);
    end

    Utils.Log("[Invasion]: " .. Config.Name .. " iniciada. Mobs: " .. TotalSpawned, 4);

end

function SystemMain.StopInvasion(InvID)

    local Active = ActiveInvasions[InvID];
    if (not Active) then return; end

    local Config = SystemConfigs.Invasions[InvID];

    if (Config.AnnounceGlobal) then
        NoticeGlobalSend(0, ". : [ INVASÃO FINALIZADA ] : .");
        NoticeGlobalSend(0, Config.Name .. " acabou.");
    end

    SystemMain.ShowRanking(InvID);
    SystemMain.ClearMonsters(InvID);

    ActiveInvasions[InvID] = nil;

end

function SystemMain.ClearMonsters(InvID)
    for mIndex, data in pairs(InvasionMonsters) do
        if (data.InvID == InvID) then
            if (gObjDel) then gObjDel(mIndex); end
            InvasionMonsters[mIndex] = nil;
        end
    end
end

-- =======================================================================
-- AUXILIARES (REF: INVASION.LUA)
-- =======================================================================
function SystemMain.GetByMonster(InvID, MonsterIndex)
    local data = InvasionMonsters[MonsterIndex];
    if (data and data.InvID == InvID) then
        return MonsterIndex;
    end
    return -1;
end

function SystemMain.GetCountMonsterByInvasion(InvID)
    local count = 0;
    for idx, data in pairs(InvasionMonsters) do
        if (data.InvID == InvID) then
            -- Conta apenas se estiver registrado na tabela
            count = count + 1;
        end
    end
    return count;
end

-- =======================================================================
-- CRIAÇÃO DE MONSTROS (COM LOGS DE SPAWN)
-- =======================================================================
function SystemMain.CreateMonsterGroup(InvID, Class, Map, Count, Points, OriginX, OriginY)
    local spawnedCount = 0;
    for i = 1, Count do
        local index = AddMonster(Map);
        if (index ~= -1) then
            SetPositionMonster(index, Map);
            SetMonster(index, Class);
            
            -- Coordenadas Aleatórias
            local rX = math.random(10, 230);
            local rY = math.random(10, 230);
            
            if rX < 10 then rX = 10; end if rX > 240 then rX = 240; end
            if rY < 10 then rY = 10; end if rY > 240 then rY = 240; end

            -- Aplica Posição (Essencial para aparecer)
            SetMapMonster(index, Map, rX, rY);

            -- [LOG DE SPAWN] - VER NO CONSOLE DO GS PARA SABER ONDE NASCEU
            Utils.Log(string.format("[DEBUG SPAWN] MobID:%d Map:%d X:%d Y:%d (Index:%d)", Class, Map, rX, rY, index), 3);

            InvasionMonsters[index] = { InvID = InvID, Class = Class, Points = Points };
            spawnedCount = spawnedCount + 1;
        else
            break; 
        end
    end
    return spawnedCount;
end

-- =======================================================================
-- EVENTOS
-- =======================================================================

function evInvasion_TimerThread()
    local Now = os.time();
    for id, data in pairs(ActiveInvasions) do
        if (Now >= data.EndTime) then
            SystemMain.StopInvasion(id);
        end
    end
end

function evInvasion_MonsterDie(Player, Monster)
    
    -- Se não tiver invasão rodando, sai.
    if (next(ActiveInvasions) == nil) then return; end

    -- LuaClass Instantiation
    local playerObj  = User.new(Player);
    local monsterObj = User.new(Monster);

    -- Loop por todas as invasões
    for key, invasionInfo in pairs(ActiveInvasions) do
        
        local Config = SystemConfigs.Invasions[key];

        if (invasionInfo ~= nil and invasionInfo.Running == true) then
            
            -- Verifica se o monstro pertence a essa invasão
            if (SystemMain.GetByMonster(key, Monster) == Monster) then
                
                local MData = InvasionMonsters[Monster];

                -- [1] AVISO DE MORTE (QUEM MATOU O QUE)
                if (Config.AnnounceKill == true) then
                    local pName = playerObj:getName();
                    local mName = monsterObj:getName(); -- Pega nome do mob via classe
                    
                    -- Se o nome do mob vier vazio, usa o ID da classe
                    if (mName == nil or mName == "") then mName = "Monster ("..MData.Class..")"; end

                    NoticeGlobalSend(0, string.format("[Invasão] %s matou %s", pName, mName));
                end

                -- Ranking
                local pName = playerObj:getName();
                if (not invasionInfo.Ranking[pName]) then invasionInfo.Ranking[pName] = { Kills = 0, Points = 0 }; end
                invasionInfo.Ranking[pName].Points = invasionInfo.Ranking[pName].Points + (MData.Points or 1);

                -- Drop System
                if (Config.Drops) then
                    for _, drop in ipairs(Config.Drops) do
                        if (drop.Class == MData.Class) then
                            if (math.random(1, 10000) <= drop.Chance) then
                                local ItemID = Utils.GetItem(drop.Section, drop.Index);
                                ItemSerialCreate(Player, playerObj:getMapNumber(), playerObj:getX(), playerObj:getY(), ItemID, drop.Level, 0, 0, 0, 0, 0);
                                NoticeSend(Player, 1, "Drop Especial!");
                                break; 
                            end
                        end
                    end
                end

                -- Remove da tabela ANTES de contar
                InvasionMonsters[Monster] = nil;

                -- [2] AVISO DE CONTAGEM (RESTAM X)
                if (Config.AnnounceGlobal == true) then
                    
                    -- Conta quantos restam na tabela
                    local MonsterCount = SystemMain.GetCountMonsterByInvasion(key);
                    
                    if (MonsterCount > 0) then
                        NoticeGlobalSend(0, string.format("Restam %d monstros!", MonsterCount));
                    else
                        -- Acabou
                        invasionInfo.Running = false;
                        invasionInfo.EndTime = 0; 
                        SystemMain.StopInvasion(key);
                    end
                end

            end
        end
    end
end

function SystemMain.ShowRanking(InvID)
    local Active = ActiveInvasions[InvID];
    if (not Active or not Active.Ranking) then return; end
    local Sorted = {};
    for name, data in pairs(Active.Ranking) do
        table.insert(Sorted, { Name = name, Points = data.Points });
    end
    table.sort(Sorted, function(a, b) return a.Points > b.Points end);
    if (#Sorted > 0) then
        NoticeGlobalSend(0, "--- RANKING ---");
        for i = 1, math.min(3, #Sorted) do
            local p = Sorted[i];
            NoticeGlobalSend(0, "#" .. i .. " " .. p.Name .. " - " .. p.Points .. " Pts");
        end
    end
end

function evInvasion_CommandManager(aIndex, code, arg)
    
    -- Validação de GM
    local player = User.new(aIndex);
    local Authority = player:getAuthority(); -- Geralmente retorna 1, 8 ou 32

    -- Verifica se é comando de Invasão
    if (code == SystemConfigs.CmdStartID or code == SystemConfigs.CmdEndID) then
        
        -- Checa Permissão
        if (Authority < SystemConfigs.GMLevel) then
            NoticeSend(aIndex, 1, "Comando apenas para Game Masters.");
            return 1; -- Retorna 1 para bloquear o comando
        end

        -- /invstart
        if (code == SystemConfigs.CmdStartID) then
            local InvID = CommandGetArgNumber(arg, 0);
            local Mins  = CommandGetArgNumber(arg, 1);
            if (InvID > 0 and SystemConfigs.Invasions[InvID]) then
                if (Mins > 0) then SystemConfigs.Invasions[InvID].Duration = Mins; end
                SystemMain.StartInvasion(InvID);
                NoticeSend(aIndex, 1, "Invasão iniciada.");
            end
            return 1;
        end

        -- /invend
        if (code == SystemConfigs.CmdEndID) then
            local InvID = CommandGetArgNumber(arg, 0);
            if (InvID > 0 and ActiveInvasions[InvID]) then
                SystemMain.StopInvasion(InvID);
                NoticeSend(aIndex, 1, "Invasão parada.");
            end
            return 1;
        end
    end

    return 0;
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