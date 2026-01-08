for dir in io.popen([[dir "../Data/Script/PointsOfSurvival/" /b]]):lines() do
    if string.find(dir,'.lua') then
        require('PointsOfSurvival\\'..string.gsub(dir, ".lua", ""))
    end
end

local Main = { Configs = {} };

BridgeFunctionAttach("OnReadScript", "PointsForSurvival_Read");
PointsForSurvival_Read = function()

    Main.Configs["Schedule"] = {    -- wDay = Dia da semana [1~7], Hour = Horário do dia, AlertTime = tempo de anúncio/entrada;
        [1] = { wDay = nil, Hour = "16:33:00", AlertTime = 1 },
        [2] = { wDay = nil, Hour = "10:00:00", AlertTime = 1 },   
        [3] = { wDay = nil, Hour = "10:00:00", AlertTime = 1 }   
    };

    Main.Configs["MapNumber"]      = 1;         -- Número do mapa;
    Main.Configs["RespawnCoords"]  = {          -- Coordenadas onde os players irão nascer.
        [0] = {170,119},
        [1] = {175,117},
        [2] = {180,117},
	    [3] = {184,122},
	    [4] = {183,128},
        [5] = {176,127},
        [6] = {170,125},
        [7] = {170,113}
    }

    Main.Configs["PointsAwarded"]   = 1;        -- Pontos ganhos ao matar;
    Main.Configs["EndTime"]         = 2;        -- Duração do evento;
    Main.Configs["MinPlayers"]      = 2;        -- Mínimo de participantes;
    Main.Configs["MaxPlayers"]      = 15;       -- Máximo de participantes;
    Main.Configs["RankingShow"]		= 30;		-- Tempo para mostrar o ranking na tela;

    Main.Configs["CommandName"]     = "/pvp";   -- Nome do comando;
    Main.Configs["CommandCode"]     = 117;      -- Código do comando;

    Main.Configs["RewardName"]      = "Gold's"; -- Nome da moeda;
    Main.Configs["Reward1"]         = 5;        -- Valor para o 1º do ranking;
    Main.Configs["Reward2"]         = 4;        -- Valor para o 2º do ranking;
    Main.Configs["Reward3"]         = 3;        -- Valor para o 3º do ranking;
    Main.Configs["SpecialValue1"]   = 0;        -- Special Value da EventItemBag para o 1º do ranking; Itens inseridos no inventário.
    Main.Configs["SpecialValue2"]   = 0;        -- Special Value da EventItemBag para o 2º do ranking;
    Main.Configs["SpecialValue3"]   = 0;        -- Special Value da EventItemBag para o 3º do ranking;
    
end;

BridgeFunctionAttach("OnTimerThread", "PointsForSurvival_TimerThread");

PointsForSurvival_TimerThread = function()

    if Main.Stage == nil then

        local Hour = os.date("%X");
        local wDay = os.date("*t")["wday"];

        for index in pairs(Main.Configs["Schedule"]) do

            local Selected = Main.Configs["Schedule"][index];

            if (Selected["wDay"] == nil or Selected["wDay"] == wDay) and (Selected["Hour"] == Hour) then

                Main.Stage      = 1;
                Main.Counter    = 0;
                Main.UserCount  = 0;
                Main.Players    = {};
                Main.AlertTime  = Selected.AlertTime;
                
                LogPrint("[PointsOfSurvival]: Evento iniciado. Período de entrada liberado.");
                break;
            end;

        end;

    elseif Main.Stage == 1 then

        if (Main.Counter%60 == 0) then

            if Main.AlertTime == 0 then

                if (Main.UserCount >= Main.Configs["MinPlayers"]) then

                    Main.Stage      = 2;
                    Main.Counter    = 0;
                    Main.EndTime    = Main.Configs["EndTime"];
                    Main.UserCount  = nil;
                    Main.AlertTime  = nil;

                    NoticeSendToAll(0,". : [ Points for Survival ] : .");
                    NoticeSendToAll(0, "Evento iniciado. Entrada encerrada.");
                    
                    for aIndex in pairs (Main.Players) do Main.Move(aIndex); NoticeSend(aIndex, 0, "Mate todos, AGORA!!!") end;

                    LogPrint("[PointsOfSurvival]: Evento iniciado. Tempo de entrada esgotado.");

                else

                    for aIndex in pairs (Main.Players) do PermissionInsert(aIndex, 12); MoveUserEx(aIndex,0,125,125) end;

                    Main.Stage      = nil;
                    Main.Counter    = nil;
                    Main.Players    = nil;
                    Main.UserCount  = nil;
                    Main.AlertTime  = nil;
                    
                    LogPrint("[PointsOfSurvival]: Evento encerrado. Mínimo de participantes não atingido.");

                end;

            else

                NoticeSendToAll(0, ". : [ Points for Survival ] : .");
                NoticeSendToAll(0, string.format("O evento iniciará em %d minuto(s).", Main.AlertTime));
                NoticeSendToAll(0, string.format("Digite %s para participar.", Main.Configs["CommandName"]));

                Main.AlertTime  = Main.AlertTime - 1;
                Main.Counter    = Main.Counter + 1;

            end;

        else

            Main.Counter = Main.Counter + 1;

        end;

    elseif(Main.Stage == 2) then

        if Main.Counter%60 == 0 then

            if Main.EndTime == 0 then

                NoticeSendToAll(0, ". : [ Points for Survival ] : .");

                Main.Reward();

                Main.Stage      = nil;
                Main.Counter    = nil;
                Main.Players    = nil;
                Main.EndTime    = nil;

            else

                NoticeSendToAll(0, ". : [ Points for Survival ] : .");
                NoticeSendToAll(0, string.format("O evento encerrará em %d minuto(s).", Main.EndTime));
                
                for aIndex in pairs (Main.Players) do 
                    NoticeSend(aIndex, 0, string.format("[ALERTA]: O evento encerrará em %d minuto(s), obtenha o máximo de pontos que conseguir.", Main.EndTime)); 
                end;
                
                Main.Counter = Main.Counter + 1;
                Main.EndTime = Main.EndTime - 1;

            end;

        else

            Main.Counter = Main.Counter + 1;

        end;

        if Main.Stage ~= nil then

            for aIndex in pairs(Main.Players) do

                if EffectCheck(aIndex, 1) == 1 or EffectCheck(aIndex, 2) == 1 then -- ELFA
                    if GetObjectClass(aIndex) ~= 2 then EffectDel(aIndex, 1); EffectDel(aIndex, 2); UserInfoSend(aIndex); end;
                end;
                if EffectCheck(aIndex, 4) then -- SM
                    if GetObjectClass(aIndex) ~= 0 then EffectDel(aIndex, 4); UserInfoSend(aIndex); end;
                end;
                if EffectCheck(aIndex, 5) then -- DL
                    if GetObjectClass(aIndex) ~= 4 then EffectDel(aIndex, 5); UserInfoSend(aIndex); end;
                end;
                if EffectCheck(aIndex, 8) then -- BK 
                    if GetObjectClass(aIndex) ~= 1 then EffectClear(aIndex); UserInfoSend(aIndex); end;
                end;

            end;

            if Main.Counter > 5 and Main.Counter%Main.Configs["RankingShow"] == 0 then

                Main.NoticeAll(0, ". : [ Points for Survival ] : .");
                Main.NoticeAll(0, ". : [ RANKING ] : .");

                local Ranking   = Main.Ranking();

                if #Ranking >= 1 then
                    local Name   = GetObjectName(Ranking[1][1]);
                    local Points = Ranking[1][2];
                    Main.NoticeAll(0, string.format("[1º - %s]: Com %d pontos.", Name, Points));
                end;    
                if #Ranking >= 2 then
                    local Name   = GetObjectName(Ranking[2][1]);
                    local Points = Ranking[2][2];
                    Main.NoticeAll(0, string.format("[2º - %s]: Com %d pontos.", Name, Points));
                end;    
                if #Ranking >= 3 then
                    local Name   = GetObjectName(Ranking[3][1]);
                    local Points = Ranking[3][2];
                    Main.NoticeAll(0, string.format("[3º - %s]: Com %d pontos.", Name, Points));
                end;

                for index in pairs(Ranking) do 
                    NoticeSend(Ranking[index][1], 1, string.format("[RANKING]: Você está em %dº com %d ponto(s).", index, Ranking[index][2])); 
                end;

            end;

        end;

    end;

end;

BridgeFunctionAttach("OnCommandManager","PointsForSurvival_CommandManager");

PointsForSurvival_CommandManager = function(aIndex, code, arg)

    if Main.Configs["CommandCode"] == code and Main.Stage == nil then

        NoticeSend(aIndex, 1, "[EVENT]: Evento indisponível no momento.");

    elseif Main.Configs["CommandCode"] == code then

        if Main.Players[aIndex] ~= nil then

            NoticeSend(aIndex, 1, "[EVENT]: Você já está participando deste evento.");

        else

            if Main.UserCount <= Main.Configs["MaxPlayers"] then

                if Main.Stage == 1 then

                    NoticeSend(aIndex, 1, "[EVENT]: Você entrou no evento. Não saia, do contrário perderá a vaga.");

                    Main.Players[aIndex]            = {};
                    Main.Players[aIndex]["Points"]  = 1;
                    Main.UserCount                  = Main.UserCount + 1;
                    Main.Move(aIndex);
                    PermissionRemove(aIndex, 12);

                elseif Main.Stage == 2 then

                    NoticeSend(aIndex, 1, "[EVENT]: A entrada para o evento está encerrada.");

                end;

            else

                NoticeSend(aIndex, 1, "[EVENT]: O evento está lotado!");

            end;

        end;

        return 1;

    end;

    return 0;

end;

BridgeFunctionAttach("OnCheckUserTarget", "PointsForSurvival_UserTarget");

PointsForSurvival_UserTarget = function(aIndex, bIndex)

    if Main.Stage ~= nil then
        if Main.Players[aIndex] ~= nil and Main.Players[bIndex] ~= nil and Main.Stage == 1 then 
            return 0; 
        elseif Main.Players[aIndex] ~= nil and Main.Players[bIndex] ~= nil and Main.Stage == 2 then 
            return 1;
        end;
    end;

    return 1;

end;

BridgeFunctionAttach("OnUserDie", "PointsForSurvival_UserDie");

PointsForSurvival_UserDie = function(aIndex, bIndex)

    if Main.Stage ~= nil then

        if Main.Players[aIndex] ~= nil and Main.Players[bIndex] ~= nil then

            local Victim  = GetObjectName(aIndex);
            local Killer  = GetObjectName(bIndex);
            local KPoints = Main.Players[bIndex]["Points"];
            local Points  = Main.Configs["PointsAwarded"];
            Main.Players[bIndex]["Points"] = KPoints + Points;

            NoticeSend(aIndex, 1, string.format("[DEAD]: Você morreu para %s, renascendo...", Killer));
            NoticeSend(bIndex, 1, string.format("[KILL]: Você matou %s e recebeu %d ponto(s). TOTAL: %d.", Victim, Points, KPoints));

        end;

    end;

end;

BridgeFunctionAttach("OnUserRespawn", "PointsForSurvival_Respawn");

PointsForSurvival_Respawn = function(aIndex)

    if Main.Stage ~= nil then if Main.Players[aIndex] ~= nil then Main.Move(aIndex); end; end;

end;

BridgeFunctionAttach("OnCharacterClose", "PointsForSurvival_Close");

PointsForSurvival_Close = function(aIndex)

    if Main.Stage ~= nil and Main.Stage > 0 then 
        if Main.Players[aIndex] ~= nil then 
            Main.Players[aIndex] = nil;
            NoticeSendToAll(1, string.format("[EVENT]: %s desconectou-se e foi removido."), GetObjectName(aIndex));
            MoveUserEx(aIndex, 0, 125, 125);
            PermissionInsert(aIndex, 12);
            if Main.Stage == 1 then Main.UserCount = Main.UserCount - 1; end;
        end; 
    end;

end;

Main.Ranking = function()

    local Ranking = {};

    for aIndex in pairs(Main.Players) do table.insert(Ranking, {aIndex, Main.Players[aIndex]["Points"]}) end;
    table.sort(Ranking,function(aIndex, bIndex) return aIndex[2] > bIndex[2] end);

    return Ranking;

end;

Main.Move = function(aIndex)

    local Random        = RandomGetNumber(#Main.Configs["RespawnCoords"]);
    local CordX, CordY  = Main.Configs["RespawnCoords"][Random][1],Main.Configs["RespawnCoords"][Random][2];

    MoveUserEx(aIndex, Main.Configs["MapNumber"], CordX, CordY);

end;

Main.Reward = function()

    local Ranking    = Main.Ranking();
    local RewardName = Main.Configs["RewardName"];           
    local Reward1    = Main.Configs["Reward1"];           
    local Reward2    = Main.Configs["Reward2"];           
    local Reward3    = Main.Configs["Reward3"];

    NoticeSendToAll(0, ". : [ VENCEDORES ] : .");

    if #Ranking >= 1 then
        local aIndex = Ranking[1][1];
        local Name   = GetObjectName(Ranking[1][1]);
        local Points = Ranking[1][2];

        ItemGive(aIndex, Main.Configs["SpecialValue1"]); 
        Main.SQLQuery(string.format("UPDATE MEMB_INFO SET gold = gold + %d WHERE memb___id = '%s'", Reward1, GetObjectAccount(aIndex))); 
        NoticeSendToAll(0, string.format("[1º - %s]: Com %d pontos.", Name, Points));
        NoticeSendToAll(1, string.format("[1º - %s]: Com %d pontos, ganhou %d %s.", Name, Points, Reward1, RewardName));

    end;    
    if #Ranking >= 2 then

        local aIndex = Ranking[2][1];
        local Name   = GetObjectName(Ranking[2][1]);
        local Points = Ranking[2][2];

        ItemGive(aIndex, Main.Configs["SpecialValue2"]); 
        Main.SQLQuery(string.format("UPDATE MEMB_INFO SET gold = gold + %d WHERE memb___id = '%s'", Reward2, GetObjectAccount(aIndex))); 
        NoticeSendToAll(0, string.format("[2º - %s]: Com %d pontos.", Name, Points));
        NoticeSendToAll(1, string.format("[2º - %s]: Com %d pontos, ganhou %d %s.", Name, Points, Reward2, RewardName));

    end;    
    if #Ranking >= 3 then

        local aIndex = Ranking[3][1];
        local Name   = GetObjectName(Ranking[3][1]);
        local Points = Ranking[3][2];

        ItemGive(aIndex, Main.Configs["SpecialValue3"]); 
        Main.SQLQuery(string.format("UPDATE MEMB_INFO SET gold = gold + %d WHERE memb___id = '%s'", Reward3, GetObjectAccount(aIndex))); 
        NoticeSendToAll(0, string.format("[3º - %s]: Com %d pontos.", Name, Points));
        NoticeSendToAll(1, string.format("[3º - %s]: Com %d pontos, ganhou %d %s.", Name, Points, Reward3, RewardName));

    end;

    for x in pairs(Ranking) do NoticeSend(Ranking[x][1], 1, string.format("Você terminou em %dº, com %d ponto(s).", x, Ranking[x][2])); end;
    for aIndex in pairs(Main.Players) do MoveUserEx(aIndex, 0, 125, 125); PermissionInsert(aIndex, 12); EffectClear(aIndex); end;

end;

Main.NoticeAll = function(x, aString) for aIndex in pairs(Main.Players) do NoticeSend(aIndex, x, aString); end; end;

Main.SQLQuery = function(aQuery) SQLQuery(aQuery); SQLClose(); end;