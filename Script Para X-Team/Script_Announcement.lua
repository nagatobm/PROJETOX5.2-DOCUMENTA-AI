--[[ 
    Desenvolvido por: 
                        Jonathan C.
]]--



BridgeFunctionAttach("OnReadScript","ScriptAnnouncement_ReadScript");
BridgeFunctionAttach("OnTimerThread","ScriptAnnouncement_TimerThread");
BridgeFunctionAttach("OnCharacterEntry","ScriptAnnouncement_CharacterEntry");

local SYSTEM_NAME    = {};
local SYSTEM_CONFIGS = {

    Query               = {},
    Message             = {},
    Count               = 1,
    TimerReload         = 0,
    NumberAnnouncement  = 0

};

function ScriptAnnouncement_ReadScript()

    SYSTEM_CONFIGS.TimerReload          = 60;   -- Tempo em minutos para atualização dos rankings;
    SYSTEM_CONFIGS.NumberAnnouncement   = 19;   -- Número de anúncios;

    SYSTEM_CONFIGS.Query[1] = string.format("SELECT top 1 name FROM character order by ResetMon desc");
    SYSTEM_CONFIGS.Query[2] = string.format("SELECT top 1 name FROM character order by MasterResetCount desc");
    SYSTEM_CONFIGS.Query[3] = string.format("SELECT top 1 name FROM character order by quiz desc");
    SYSTEM_CONFIGS.Query[4] = string.format("select top 1 name from RankingBloodCastle order by Score desc");
    SYSTEM_CONFIGS.Query[5] = string.format("select top 1 name from RankingIllusionTemple order by Score desc");
    SYSTEM_CONFIGS.Query[6] = string.format("select top 1 name from character order by horaon desc");
    SYSTEM_CONFIGS.Query[7] = string.format("select top 1 name from character order by RazorTop desc");
    SYSTEM_CONFIGS.Query[8] = string.format("select top 1 name from character order by BattleRoyale desc");
    SYSTEM_CONFIGS.Query[9] = string.format("select top 1 name from RankingCustomArena0 order by score desc");
    SYSTEM_CONFIGS.Query[10] = string.format("select top 1 name from RankingCustomArena1 order by score desc");
    SYSTEM_CONFIGS.Query[11] = string.format("select top 1 name from RankingCustomArena2 order by score desc");
    SYSTEM_CONFIGS.Query[12] = string.format("select top 1 name from RankingCustomArena3 order by score desc");
    SYSTEM_CONFIGS.Query[13] = string.format("select top 1 name from RankingCustomArena4 order by score desc");
    SYSTEM_CONFIGS.Query[14] = string.format("select top 1 name from RankingCustomArena5 order by score desc");
    SYSTEM_CONFIGS.Query[15] = string.format("select top 1 name from RankingCustomArena6 order by score desc");
    SYSTEM_CONFIGS.Query[16] = string.format("select top 1 name from RankingCustomArena7 order by score desc");
    SYSTEM_CONFIGS.Query[17] = string.format("select top 1 name from RankingCustomArena8 order by score desc");
    SYSTEM_CONFIGS.Query[18] = string.format("select top 1 name from RankingCustomArena9 order by score desc");
    SYSTEM_CONFIGS.Query[19] = string.format("select top 1 name from RankingCustomArena10 order by score desc");

    SYSTEM_CONFIGS.ReloadRaking();

    SYSTEM_CONFIGS.Message[1] = "TOP 1 - RESET SEMANAL: "..SYSTEM_NAME[1].." online!";
    SYSTEM_CONFIGS.Message[2] = "TOP 1 - MASTER RESET: "..SYSTEM_NAME[2].." online!";
    SYSTEM_CONFIGS.Message[3] = "TOP 1 - Quiz: "..SYSTEM_NAME[3].." online!";
    SYSTEM_CONFIGS.Message[4] = "TOP 1 - Blood Castle: "..SYSTEM_NAME[4].." online!!";
    SYSTEM_CONFIGS.Message[5] = "TOP 1 - Ilusion Temple: "..SYSTEM_NAME[5].." online!";
    SYSTEM_CONFIGS.Message[6] = "TOP 1 - Online Hours: "..SYSTEM_NAME[6].." online!";
    SYSTEM_CONFIGS.Message[7] = "TOP 1 - RazorTOPKiller: "..SYSTEM_NAME[7].." online!";
    SYSTEM_CONFIGS.Message[8] = "TOP 1 - Battle Royale: "..SYSTEM_NAME[8].." online!";
    SYSTEM_CONFIGS.Message[9] = "TOP 1 - PVP ALL: "..SYSTEM_NAME[9].." online!";
    SYSTEM_CONFIGS.Message[10] = "TOP 1 - BK: "..SYSTEM_NAME[10].." online!";
    SYSTEM_CONFIGS.Message[11] = "TOP 1 - SM: "..SYSTEM_NAME[11].. "online!";
    SYSTEM_CONFIGS.Message[12] = "TOP 1 - MG: "..SYSTEM_NAME[12].." online!";
    SYSTEM_CONFIGS.Message[13] = "TOP 1 - ELF: "..SYSTEM_NAME[13].." online!";
    SYSTEM_CONFIGS.Message[14] = "TOP 1 - DL: "..SYSTEM_NAME[14].." online!";
    SYSTEM_CONFIGS.Message[15] = "TOP 1 - SUM: "..SYSTEM_NAME[15].." online!";
    SYSTEM_CONFIGS.Message[16] = "TOP 1 - RF: "..SYSTEM_NAME[16].." online!";
    SYSTEM_CONFIGS.Message[17] = "TOP 1 - GL: "..SYSTEM_NAME[17].." online!";
    SYSTEM_CONFIGS.Message[18] = "TOP 1 - RW: "..SYSTEM_NAME[18].." online!";
    SYSTEM_CONFIGS.Message[19] = "RAZOR KING: "..SYSTEM_NAME[19].." online!";

    LogPrint("[SCRIPT_ANNOUNCEMENT]: Configurações armazenadas.");

end

function ScriptAnnouncement_TimerThread()

    if (SYSTEM_CONFIGS.Count%(SYSTEM_CONFIGS.TimerReload*60) == 0) then

        SYSTEM_CONFIGS.ReloadRaking();

        SYSTEM_CONFIGS.Count = 1;

    else

        SYSTEM_CONFIGS.Count = SYSTEM_CONFIGS.Count + 1;

    end

end

function ScriptAnnouncement_CharacterEntry(aIndex)

    SYSTEM_CONFIGS.GetUser(aIndex);

end

function SYSTEM_CONFIGS.ReloadRaking()

    for pos = 1, SYSTEM_CONFIGS.NumberAnnouncement, 1 do

        SQLQuery(SYSTEM_CONFIGS.Query[pos]);

        SQLFetch()
            
        SQLClose()

        SYSTEM_NAME[pos] = SQLGetString("name");

        LogPrint("[SCRIPT_ANNOUNCEMENT]: "..SYSTEM_NAME[pos].." adicionado.");

    end

end


function SYSTEM_CONFIGS.GetUser(aIndex)

    for x = 1, SYSTEM_CONFIGS.NumberAnnouncement, 1 do

        if (SYSTEM_NAME[x] == GetObjectName(aIndex)) then    

            LogPrint("[SCRIPT_ANNOUNCEMENT]: "..SYSTEM_NAME[x].." conectou-se.");

            NoticeSendToAll(1, string.format(SYSTEM_CONFIGS.Message[x]));

            break;

        end

    end

    return 0;

end