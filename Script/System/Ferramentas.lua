--[[ 
    Ferramentas.lua
    BIBLIOTECA UNIVERSAL DE UTENSÍLIOS
    Organização:
                        Padrão SystemMain (Visual)
]]--

-- 1. CONFIGURAÇÕES GERAIS

-- [[ Configurations Generals ]] --

DBConfig                        = {};
DBConfig.DSN                    = "MuOnlineBase";
DBConfig.User                   = "sa";
DBConfig.Pass                   = [[iDs]4i3jq&w]:BY%by?$]];

Color                           = { BLACK = 1, RED = 2, GREEN = 3, BLUE = 4 };

unpack                          = unpack and unpack or table.unpack;

-- SQL Configurations Reset
TABLE_RESET                     = "Character";
COLUMN_RESET                    = {};
COLUMN_RESET[0]                 = "Resets";
COLUMN_RESET[1]                 = "ResetsDay";
COLUMN_RESET[2]                 = "ResetsWeek";
COLUMN_RESET[3]                 = "ResetsMonth";
WHERE_RESET                     = "Name";
MAX_RESET                       = -1; -- -1 sem limites

-- SQL Configurations MReset
TABLE_MRESET                    = "Character";
COLUMN_MRESET                   = {};
COLUMN_MRESET[0]                = "MResets";
COLUMN_MRESET[1]                = "MResetsDay";
COLUMN_MRESET[2]                = "MResetsWeek";
COLUMN_MRESET[3]                = "MResetsMonth";
WHERE_MRESET                    = "Name";

-- SQL Configurations PK
TABLE_PK                        = "Character";
COLUMN_PK                       = {};
COLUMN_PK[0]                    = "PKTotal";
COLUMN_PK[1]                    = "PKDay";
COLUMN_PK[2]                    = "PKWeek";
COLUMN_PK[3]                    = "PKMonth";
WHERE_PK                        = "Name";

-- SQL Configurations Hero
TABLE_HERO                      = "Character";
COLUMN_HERO                     = {};
COLUMN_HERO[0]                  = "HeroTotal";
COLUMN_HERO[1]                  = "HeroDay";
COLUMN_HERO[2]                  = "HeroWeek";
COLUMN_HERO[3]                  = "HeroMonth";
WHERE_HERO                      = "Name";

-- SQL Configurations Vip
TABLE_VIP                       = "MEMB_INFO";
COLUMN_VIP                      = "AccountLevel";
WHERE_VIP                       = "memb___id";

-- SQL Configurations Mult Vaults
TABLE_MULT_WAREHOUSE            = "warehouse";
COLUMN_MULT_WAREHOUSE           = "VaultCounts";
WHERE_MULT_WAREHOUSE            = "AccountID";

-- SQL Configurations Mult Vaults - Save Last Number Vault (Recommended warehouse)
TABLE_LAST_VAULT_ID_WAREHOUSE   = "warehouse";
COLUMN_LAST_VAULT_ID_WAREHOUSE  = "LastVaultID";
WHERE_LAST_VAULT_ID_WAREHOUSE   = "AccountID";

-- SQL Configurations Reward Player
TABLE_REWARD_PLAYER             = "MEMB_INFO";
COLUMN_REWARD_PLAYER            = "RewardPlayer";
WHERE_REWARD_PLAYER             = "memb___id";

-- Configurações Set Defense
SET_DEFENSE_SWITCH              = 1;
SET_DEFENSE_CONFIG              = {
    {Helm = 50, Armor = 50, Pants = 50, Gloves = 50, Boots = 50, Defense = 1.20, SucessBlock = 1.05}
};

-- 2. STRING EXTENSION
function string:split(sSeparator, nMax, bRegexp)

    assert(sSeparator ~= '');
    assert(nMax == nil or nMax >= 1);

    local aRecord = {};

    if (self:len() > 0) then

        local bPlain = not bRegexp;
        nMax = nMax or -1;

        local nField, nStart = 1, 1;
        local nFirst, nLast = self:find(sSeparator, nStart, bPlain);

        while nFirst and nMax ~= 0 do

            aRecord[nField] = self:sub(nStart, nFirst - 1);
            nField = nField + 1;
            nStart = nLast + 1;
            nFirst, nLast = self:find(sSeparator, nStart, bPlain);
            nMax = nMax - 1;

        end

        aRecord[nField] = self:sub(nStart);

    end

    return aRecord;

end

-- 3. BANCO DE DADOS
DataBase        = {};
DataBaseAsync   = {};

function DataBase.Connect()

    if (not SQL or not SQL.new) then return nil; end

    local db = SQL.new();
    
    if (db:connect(0, DBConfig.DSN, DBConfig.User, DBConfig.Pass) == 0) then return nil; end

    return db;

end

function DataBase.GetNumberByString(table, column, whereCol, whereVal)

    local val = 0;
    local db  = DataBase.Connect();

    if (db) then

        local query = string.format("SELECT %s FROM %s WHERE %s = '%s'", column, table, whereCol, whereVal);
        
        if (db:exec(query) == 1 and db:fetch() == 1) then val = db:getInt(column); end
        
        db:clear();

    end

    return val;

end

function DataBase.GetString(table, column, whereCol, whereVal)

    local val = "";
    local db  = DataBase.Connect();

    if (db) then

        local query = string.format("SELECT %s FROM %s WHERE %s = '%s'", column, table, whereCol, whereVal);
        
        if (db:exec(query) == 1 and db:fetch() == 1) then val = db:getStr(column); end
        
        db:clear();

    end

    return val;

end

function DataBase.SetAddValue(table, column, amount, whereCol, whereVal)

    local db = DataBase.Connect();

    if (db) then

        local query = string.format("UPDATE %s SET %s = %s + %d WHERE %s = '%s'", table, column, column, amount, whereCol, whereVal);
        
        db:exec(query);
        db:clear();

    end

end

function DataBaseAsync.SetAddValue(table, column, amount, whereCol, whereVal)

    if (CreateAsyncQuery) then

        local query = string.format("UPDATE %s SET %s = %s + %d WHERE %s = '%s'", table, column, column, amount, whereCol, whereVal);
        
        CreateAsyncQuery("SetAddValueAsync", query, -1, 0);

    else

        DataBase.SetAddValue(table, column, amount, whereCol, whereVal);

    end

end

-- 4. UTILITY MASTER (MOEDAS)
Utility_Master                  = { Map = {} };
Utility_Master.Map              = {
    ["GOLD"]  = { Table = "MEMB_INFO", Column = "gold",   Where = "memb___id", Name = "Gold",   IdType = 0 },
    ["CASH"]  = { Table = "MEMB_INFO", Column = "cash",   Where = "memb___id", Name = "Cash",   IdType = 0 },
    ["POINT"] = { Table = "MEMB_INFO", Column = "leilao", Where = "memb___id", Name = "Pontos", IdType = 0 },
};

function Utility_Master.AddCoin(playerObj, coinKey, amount, useAsync)

    local cfg = Utility_Master.Map[coinKey];

    if (not cfg) then return; end

    local target = (cfg.IdType == 1) and playerObj:getName() or playerObj:getAccountID();

    if (useAsync == 1) then

        DataBaseAsync.SetAddValue(cfg.Table, cfg.Column, amount, cfg.Where, target);

    else

        DataBase.SetAddValue(cfg.Table, cfg.Column, amount, cfg.Where, target);

    end

    NoticeSend(playerObj:getIndex(), 1, string.format("[%s]: +%d adicionados!", cfg.Name, amount));

end

-- 5. COMMANDS HELPERS (MODELO ANTIGO / JONATHAN C.)
function CommandGetArgString(arg, pos)

    -- arg: string completa dos argumentos
    -- pos: índice do argumento (0, 1, 2...)

    if (arg == nil or arg == "") then return ""; end

    local argsTable = string.split(arg, " ");
    local index     = pos + 1; -- Lua table começa em 1, scripts antigos mandam 0

    if (argsTable[index]) then
        return argsTable[index];
    end

    return "";

end

function CommandGetArgNumber(arg, pos)

    local strVal = CommandGetArgString(arg, pos);

    if (strVal == "") then return 0; end

    return tonumber(strVal) or 0;

end

-- 6. TIMER & SCHEDULE
Timer                           = {};
local TimerHandles              = {};
local TimerID                   = 0;

function Timer.Interval(timer, call, ...)

    TimerID = TimerID + 1;
    TimerHandles[TimerID] = { 
        timerRun = timer, 
        callback = call, 
        args = {...}, 
        running = 0, 
        count = 0, 
        update = function(t) 
            t.running = t.running + 1;
            if (t.running < t.timerRun) then return false; end
            t.running = 0;
            t.callback(unpack(t.args));
            return false;
        end 
    };

    return TimerID;

end

function Timer.Update() 

    for i, handle in pairs(TimerHandles) do 

        if (handle.update(handle)) then TimerHandles[i] = nil; end 

    end 

end

function TimerSystem() Timer.Update(); end

Schedule                        = {};
local ScheduleHandles           = {};
local ScheduleCount             = 1;

-- Agenda por Dia/Hora/Minuto (Modo Antigo)
function Schedule.SetDayAndHourAndMinute(Day, Hour, Minute, call, ...)

    ScheduleHandles[ScheduleCount] = {
        type = 1,
        day = Day, 
        hour = Hour, 
        minute = Minute, 
        callback = call, 
        args = {...}, 
        state = 1
    };
    ScheduleCount = ScheduleCount + 1;

end

-- Agenda por String Exata "HH:MM:SS" (Novo Modo / Jonathan C.)
function Schedule.SetExactTime(TimeStr, call, ...)

    ScheduleHandles[ScheduleCount] = {
        type = 2,
        timeStr = TimeStr,
        callback = call,
        args = {...},
        lastCall = ""
    };
    ScheduleCount = ScheduleCount + 1;

end

function Schedule.Running()

    local d, h, m   = tonumber(os.date("%d")), tonumber(os.date("%H")), tonumber(os.date("%M"));
    local nowStr    = os.date("%H:%M:%S"); 

    for i, t in pairs(ScheduleHandles) do

        -- Modo 1: Minuto Cheio
        if (t.type == 1) then

            if (t.day == d or t.day == -1) and (t.hour == h) and (t.minute == m) then 

                if (t.state == 1) then t.callback(unpack(t.args)); t.state = 2; end 

            else 

                if (t.state == 2) then t.state = 1; end 

            end

        -- Modo 2: String Exata ("HH:MM:SS")
        elseif (t.type == 2) then

            if (t.timeStr == nowStr) then

                if (t.lastCall ~= nowStr) then

                    t.callback(unpack(t.args));
                    t.lastCall = nowStr;

                end

            end

        end

    end

end

Timer.Interval(1, Schedule.Running);

-- 7. UTILS & USER
User                            = {};
User.__index                    = User;

function User.new(aIndex) 
    local self = setmetatable({}, User); 
    self.aIndex = aIndex; 
    return self; 
end

function User:getIndex() return self.aIndex; end
function User:getName() return GetObjectName(self.aIndex); end
function User:getAccountID() return GetObjectAccount(self.aIndex); end
function User:getLevel() return GetObjectLevel(self.aIndex); end
function User:getMapNumber() return GetObjectMap(self.aIndex); end
function User:getX() return GetObjectX(self.aIndex); end
function User:getY() return GetObjectY(self.aIndex); end
function User:getConnected() return GetObjectConnected(self.aIndex); end

function User:getAuthority()

    if (GetObjectAuthority) then return GetObjectAuthority(self.aIndex); end
    if (GameMasterCheck and GameMasterCheck(self.aIndex, 1) == 1) then return 32; end
    return 1;

end

Utils                           = {};

function Utils.GetPlayer(aIndex) return User.new(aIndex); end
function Utils.Log(message, color) LogAddC(color or 3, "[Utils] " .. tostring(message)); end
function Utils.GetVip(aIndex) return DataBase.GetNumberByString(TABLE_VIP, COLUMN_VIP, WHERE_VIP, User.new(aIndex):getAccountID()); end

-- [[ IDENTIFICAÇÃO DE ITEM ]]
function Utils.GetItem(Section, Index)

    return (Section * 512) + Index;

end

if (User) then function User:getVip() return Utils.GetVip(self.aIndex); end; end

-- 8. INICIALIZAÇÃO
if (ConnectQueryAsync) then ConnectQueryAsync(DBConfig.DSN, DBConfig.User, DBConfig.Pass); end
if (BridgeFunctionAttach) then BridgeFunctionAttach("OnTimerThread", "TimerSystem"); end

LogAddC(4, "[Ferramentas] Biblioteca Completa Carregada.");