--[[ 
    Desenvolvido por: 
                        Jonathan C.
]]--

local SystemMain       = {};
local SystemConfigs    = {};

BridgeFunctionAttach("OnReadScript","evZombieAttack_ReadScript");
BridgeFunctionAttach("OnTimerThread","evZombieAttack_TimerThread");
BridgeFunctionAttach("OnCommandManager","evZombieAttack_CommandManager");
BridgeFunctionAttach("OnCheckUserTarget","evZombieAttack_CheckTarget");
BridgeFunctionAttach("OnUserDie","evZombieAttack_UserDie");
BridgeFunctionAttach("OnUserRespawn","evZombieAttack_UserRespawn");
BridgeFunctionAttach("OnCharacterClose","evZombieAttack_CharacterClose");
BridgeFunctionAttach("OnCheckUserKiller","evZombieAttack_CheckKiller");

function evZombieAttack_ReadScript()
    
    SystemConfigs.Map           = 6;            -- Mapa onde o evento ocorrera;
    SystemConfigs.MaxUsers      = 25;            -- Maximo de participantes;
    SystemConfigs.MinUsers      = 5;            -- Minimo de participantes;
    SystemConfigs.SkinZombie    = 55;            -- Skin atribuida a quem virar zombie;
    SystemConfigs.CordXY        = {97,161};    -- Coordenada principal do evento;

    SystemConfigs.Timer         = {};           -- Nao mexa nesta linha, as demais podem ser criadas seguindo a sequencia;
    SystemConfigs.Timer[1]      = "16:10:00";   -- Primeiro horario que o evento ira ocorrer;
    SystemConfigs.Timer[2]      = "22:20:00";   -- Segundo horario que o evento ira ocorrer;
   
    SystemConfigs.TimerAlert    = 2;            -- Tempo, em minutos, para entrar no evento.
    SystemConfigs.TimerMax      = 3;            -- Tempo, em minutos, para os zombies infectarem todos.
    SystemConfigs.TimerInfect   = 20;           -- Tempo, em segundos, para a doenca matar alguns participantes.
    
    SystemConfigs.TimerVision   = 10;           -- Tempo, em segundos, para acionar os efeitos.
    SystemConfigs.LimitVision   = 10;           -- Número de vezes que a visao dos humanos sera afetada.
    
    SystemConfigs.rValueZombie = 1;            -- Valor por transformar alguem em zombie;
    SystemConfigs.rNameZombie  = "Gold";            -- Nome da moeda creditada;

    SystemConfigs.rValuePlayer = 1;           -- Valor total dividido entre os participantes humanos que restarem; 
    SystemConfigs.rNamePlayer  = "Gold";            -- Nome da moeda creditada;

    SystemConfigs.rValueZombiesF = 1;         -- Valor creditado a cada zombie caso vencam;
    SystemConfigs.rNameZombiesF  = "Gold";      -- Nome da moeda creditada;

    SystemConfigs.nmCommandEntry = "/zombie";   -- Nome do comando no CommandManager.txt;
    SystemConfigs.cdCommandEntry = 103;         -- Codigo do comando no CommandManager.txt;


    SystemConfigs.RespawnCordX, SystemConfigs.RespawnCordY = {}, {}; -- Coordenadas de onde poderao renascer os que morrerem durante o evento; Pode criar mais seguindo a sequencia;
    SystemConfigs.RespawnCordX[1], SystemConfigs.RespawnCordY[1] = 93,157;
    SystemConfigs.RespawnCordX[2], SystemConfigs.RespawnCordY[2] = 93,167;
    SystemConfigs.RespawnCordX[3], SystemConfigs.RespawnCordY[3] = 101,167;
    --SystemConfigs.RespawnCordX[4], SystemConfigs.RespawnCordY[4] = 170,080;
end

function evZombieAttack_TimerThread()

    if (SystemMain.Stage == nil) then

        for z = 1, #SystemConfigs.Timer, 1 do 

            if (SystemConfigs.Timer[z] == os.date("%X")) then

                SystemMain.Count        = 0;
                SystemMain.Stage        = 1;
                SystemMain.UserCount    = 1;
                SystemMain.Users        = {};
                SystemMain.TimerAlert   = SystemConfigs.TimerAlert;

                LogPrint("[ZOMBIE_ATTACK]: Na hora! Estagio 1 iniciado.");

            end

        end


    elseif (SystemMain.Stage == 1) then

        if (SystemMain.Count%60 == 0) then

            if (SystemMain.TimerAlert == 0) then

                if (SystemMain.UserCount - 1 >= SystemConfigs.MinUsers) then

                    NoticeSendToAll(0, ". : [ ZOMBIE ATTACK ] : .");
                    NoticeLangSendToAll(0, "Event has started, time is over.", "Evento iniciado, tempo esgotado.", "Evento iniciado, tiempo agotado.");
                    SystemMain.Message(1, "[ZombieAttack]: Participants were infected. Trust no one!!");
                    SystemMain.Message(1, "[ZombieAttack]: Participantes foram infectados. Nao confie em ninguem!!");
                    SystemMain.Message(1, "[ZombieAttack]: Participantes furean infectados. No confie en nadie!!");

                    SystemMain.Stage       = 2;
                    SystemMain.Count       = 0;
                    SystemMain.UserCount   = 0;
                    SystemMain.LimitVision = SystemConfigs.LimitVision;
                    SystemMain.TimerAlert  = SystemConfigs.TimerMax; 

                    LogPrint("[ZOMBIE_ATTACK]: Tempo esgotado! Estagio 2 iniciado.");
                
                else

                    while (#SystemMain.Users > 0) do

                        MoveUserEx(SystemMain.Users[1]["Index"], 0, 125, 125);
                        PermissionInsert(SystemMain.Users[1]["Index"], 12);
                        NoticeSend(SystemMain.Users[1]["Index"], 1, "[ZombieAttack]: Minimo de participantes nao atingido, evento cancelado.");
                        NoticeSend(SystemMain.Users[1]["Index"], 1, "[ZombieAttack]: EVENT HAS BEEN CANCELED.");
                       

                        SystemMain.DelUser(1);

                    end

                    NoticeGlobalSend(0, ". : [ ZOMBIE ATTACK ] : .");
                    NoticeLangGlobalSend(0, "Event canceled, minimum of participants not reached.", "Evento cancelado, minimo de participantes nao atingido.", "El evento fue cancelado, minimo de participantes no alcanzado.");


                    SystemMain.Count       = nil;
                    SystemMain.Stage       = nil;
                    SystemMain.UserCount   = nil;
                    SystemMain.TimerAlert  = nil; 
                    SystemMain.Users       = nil;

                    LogPrint("[ZOMBIE_ATTACK]: Tempo esgotado! Minimo de participantes nao atingido, evento cancelado.");

                end

            else
                
                NoticeGlobalSend(0, ". : [ ZOMBIE ATTACK - Server 1 ] : .");
                NoticeLangGlobalSend(0, "Event will start in "..SystemMain.TimerAlert.. " minute(s).", "O evento iniciara em "..SystemMain.TimerAlert.. " minuto(s).", "El evento va empezar en "..SystemMain.TimerAlert.. " minuto(s).");
                NoticeGlobalSend(3, ". : [ ZOMBIE ATTACK - Server 1 ] : .");
                NoticeLangGlobalSend(3, "Event will start in "..SystemMain.TimerAlert.. " minute(s).", "O evento iniciara em "..SystemMain.TimerAlert.. " minuto(s).", "El evento va empezar en "..SystemMain.TimerAlert.. " minuto(s).");
                NoticeLangGlobalSend(0, "Type "..SystemConfigs.nmCommandEntry.." to participate.", "Digite "..SystemConfigs.nmCommandEntry.." para participar.", "Escriba "..SystemConfigs.nmCommandEntry.." para participar.");
                
                
                SystemMain.Count       = SystemMain.Count + 1;
                SystemMain.TimerAlert  = SystemMain.TimerAlert - 1;

            end

        else

            SystemMain.Count = SystemMain.Count + 1;

        end

    elseif (SystemMain.Stage == 2) then

        for xxx = 1, #SystemMain.Users, 1 do 

            if (GetObjectLevel(SystemMain.Users[xxx]["Index"]) <= 6) then

                NoticeSend(SystemMain.Users[xxx]["Index"], 1, "[ZombieAttack]: TOOOOOOMA TROUXA!!!");
                SystemMain.DelUser(xxx);

            end

        end

        if (SystemMain.Count%60 == 0) then

            SystemMain.Message(1, "O evento terminara em "..SystemMain.TimerAlert.. " minuto(s). Sobreviva!");
                
            SystemMain.Count       = SystemMain.Count + 1;
            SystemMain.TimerAlert  = SystemMain.TimerAlert - 1;

        else

            SystemMain.Count = SystemMain.Count + 1;

        end

        if (SystemMain.Stage ~= nil) then

            if (SystemMain.Count%SystemConfigs.TimerInfect == 0) and (#SystemMain.Users > SystemMain.UserCount * 2) then

                local random = math.random(1,500);
                random = math.random(1,#SystemMain.Users);
                local random = math.random(500,1000);
                random = math.random(1,#SystemMain.Users);
                random = math.random(1,#SystemMain.Users);

                SystemMain.Message(0, GetObjectName(SystemMain.Users[random]["Index"]).." transformou-se! Cuidado!!!!");
                SystemMain.Transform(random);

            end

            if (SystemMain.Count%SystemConfigs.TimerVision == 0) and (SystemMain.LimitVision > 0) then

                for x = 1, #SystemMain.Users, 1 do

                    if (SystemMain.Users[x]["Infected"] == 1) then

                        EffectAdd(SystemMain.Users[x]["Index"],0,1,15,10000,0,0,0);
				        EffectAdd(SystemMain.Users[x]["Index"],0,8,15,1000,0,0,0);
                        EffectAdd(SystemMain.Users[x]["Index"],0,143,15,10000,0,0,0);
                        
                    else

                        EffectAdd(SystemMain.Users[x]["Index"],0,144,15,0,0,0,0);

                    end

                end

                SystemMain.LimitVision = SystemMain.LimitVision - 1;

            end

        end

        if (SystemMain.TimerAlert+1 == 0) then 
                
            NoticeSendToAll(0, ". : [ ZOMBIE ATTACK ] : .");
            NoticeLangSendToAll(0, "Victory of humans, the race prevails!", "Vitoria dos humanos, a raca prevalece!", "Victoria de los humanos, la raza prevalece.");
            SystemMain.Finish(1);

            LogPrint("[ZOMBIE_ATTACK]: Vitoria dos humanos, evento finalizado.");

        elseif (SystemMain.UserCount == #SystemMain.Users) then

            NoticeSendToAll(0, ". : [ ZOMBIE ATTACK ] : .");
            NoticeLangSendToAll(0, "Victory of the zombies, there were no survivors!", "Vitoria dos zombies, nao houve sobreviventes!", "Victoria dos zombies, no hubo sobreviventes!");
            SystemMain.Finish(2);

            LogPrint("[ZOMBIE_ATTACK]: Vitoria dos zombies, evento finalizado.");
        end

    end

end

function evZombieAttack_CommandManager(aIndex, code, arg)

    if (SystemConfigs.cdCommandEntry == code) then
	
		if (GetObjectLevel(aIndex) > 6) then 

			if (SystemMain.Stage ~= nil) then

				if (SystemMain.Stage == 1) then

					if (SystemMain.GetUser(aIndex) ~= 0) then

						NoticeSend(aIndex, 1, "[ZombieAttack]: Bem Vindo ao Evento Zumbi...");
						NoticeSend(aIndex, 1, "[ZombieAttack]: Welcome to Zombie Invasion Event...");

					else

						SystemMain.Users[SystemMain.UserCount]              = {};
						SystemMain.Users[SystemMain.UserCount]["Index"]     = aIndex;
                        SystemMain.Users[SystemMain.UserCount]["Infected"]  = 0;
                        SystemMain.Users[SystemMain.UserCount]["Aplly"]     = 0;
						SystemMain.UserCount                                = SystemMain.UserCount + 1;

						PermissionRemove(aIndex, 12);
						MoveUserEx(aIndex, SystemConfigs.Map, SystemConfigs.CordXY[1], SystemConfigs.CordXY[2]);
						NoticeSend(aIndex, 1, "[ZombieAttack]: Bem Vindo ao Evento Zumbi...");
						NoticeSend(aIndex, 1, "[ZombieAttack]: Welcome to Zombie Invasion Event...");

						if (SystemMain.UserCount - 1 == SystemConfigs.MaxUsers) then

							NoticeSendToAll(0, ". : [ ZOMBIE ATTACK ] : .");
							NoticeSendToAll(0, "Evento iniciado, maximo de participantes atingido.");
							SystemMain.Message(1, "[ZombieAttack]: Participantes infectados. Nao confie em ninguem!!");

                            SystemMain.Stage      = 2;
							SystemMain.Count      = 0;
							SystemMain.UserCount  = 0;
							SystemMain.TimerAlert = SystemConfigs.TimerMax; 
							SystemMain.LimitVision = SystemConfigs.LimitVision;

							LogPrint("[ZOMBIE_ATTACK]: Maximo de participantes atingido, estagio 2 iniciado.");

						end

					end
					
				end

            else

                NoticeSend(aIndex, 1, "[ZombieAttack]: Periodo de entrada encerrado, tente na proxima!");

            end

        else

            NoticeSend(aIndex, 1, "[ZombieAttack]: Você não possui level suficiente.");

        end

        return 1;

    end

    return 0;

end

function evZombieAttack_CheckTarget(aIndex, bIndex)

    if (SystemMain.Stage ~= nil) then 

        if (SystemMain.Stage == 1) then

            if (SystemMain.GetUser(bIndex) ~= 0) then

                return 0;

            end

        elseif (SystemMain.Stage == 2) then

            local a = SystemMain.GetUser(aIndex);
            local b = SystemMain.GetUser(bIndex);

            if (SystemMain.UserCount == 0) and (a ~= 0) and (b ~= 0) then

                return 0;
            
            elseif (a ~= 0) and (b ~= 0) then

                if (SystemMain.Users[a]["Infected"] == 1) and (SystemMain.Users[b]["Infected"] == 1) then -- atacante zombie, atacado zombie

                    return 0;

                elseif (SystemMain.Users[a]["Infected"] == 0) and (SystemMain.Users[b]["Infected"] == 1) then -- atacante player, atacado zombie
                    
                    return 1;

                elseif (SystemMain.Users[a]["Infected"] == 1) and (SystemMain.Users[b]["Infected"] == 0) then -- atacante zombie, atacado player
                    
                    return 1;

                elseif (SystemMain.Users[a]["Infected"] == 0) and (SystemMain.Users[b]["Infected"] == 0) then -- atacante player, atacado player

                    return 0;

                end

            end

        end

    end

    return 1;

end

function evZombieAttack_UserDie(aIndex,bIndex)

    if (SystemMain.Stage ~= nil) then

        local a = SystemMain.GetUser(aIndex);
        local b = SystemMain.GetUser(bIndex);

            end

        end

    end

end

function evZombieAttack_CharacterClose(aIndex)

    if (SystemMain.Stage ~= nil) then

        local z = SystemMain.GetUser(aIndex);

        if (z ~= 0) then

            SystemMain.Message(1, "[ZombieAttack]: "..GetObjectName(SystemMain.Users[z]["Index"]).." desconectou-se e foi removido.");
            
            SystemMain.DelUser(z);

            if (SystemMain.Stage == 1) then SystemMain.UserCount = SystemMain.UserCount - 1 end;

        end

    end
    
end

function evZombieAttack_CheckKiller(aIndex, bIndex)

    if (SystemMain.Stage ~= nil) then

        if (SystemMain.GetUser(aIndex) ~= 0) and (SystemMain.GetUser(bIndex) ~= 0) then

            return 0;

        end

    end

    return 1;

end

function SystemMain.GetUser(aIndex)

    for n = 1, #SystemMain.Users, 1 do

        if (SystemMain.Users[n]["Index"] == aIndex) then

            return n;

        end

    end

    return 0;

end

function SystemMain.Message(iType, sMessage)

    for x = 1, #SystemMain.Users, 1 do

        if (SystemMain.iType == 0) then

            NoticeSend(SystemMain.Users[x]["Index"], 0, sMessage);
            
        else 
            
            NoticeSend(SystemMain.Users[x]["Index"], 1, sMessage);

        end

    end

end

function SystemMain.Transform(i)

    SystemMain.Users[i]["Infected"] = 1;
    SystemMain.UserCount            = SystemMain.UserCount + 1;

    SkinChangeSend(SystemMain.Users[i]["Index"], SystemConfigs.SkinZombie);

end

function SystemMain.Reward(aIndex, iValue)

    NoticeSend(aIndex, 1, "[ZombieAttack]: REWARD "..iValue.." GOLD's.");
    LogPrint("[ZOMBIE_ATTACK]: PLAYER: "..GetObjectName(aIndex)..", REWARD "..iValue.." GOLD's.");

    SQLQuery("UPDATE MEMB_INFO SET gold = gold +"..iValue.." WHERE memb___id = '"..GetObjectAccount(aIndex).."'");
    SQLClose();
    
end

function SystemMain.Finish(xx)

    if (xx == 1) then

        while (#SystemMain.Users > 0) do

            if (SystemMain.Users[1]["Infected"] == 0) then

                SystemMain.Reward(SystemMain.Users[1]["Index"], math.abs(math.ceil(SystemConfigs.rValuePlayer/#SystemMain.Users-SystemMain.UserCount)));

            end

            SystemMain.DelUser(1);

        end 

    else

        while (#SystemMain.Users > 0) do

            SystemMain.Reward(SystemMain.Users[1]["Index"], SystemConfigs.rValueZombiesF);

            SystemMain.DelUser(1);

        end 

    end         

   SystemMain.Stage         = nil;
   SystemMain.Count         = nil;
   SystemMain.UserCount     = nil;
   SystemMain.Get           = nil;
   SystemMain.TimerAlert    = nil;
   SystemMain.Users         = nil;
   SystemMain.LimitVision   = nil;

end

function SystemMain.DelUser(ID)

    MoveUserEx(SystemMain.Users[ID]["Index"], 0, 125, 125);
    PermissionInsert(SystemMain.Users[ID]["Index"], 12);
    SkinChangeSend(SystemMain.Users[ID]["Index"], -1);
    EffectDel(SystemMain.Users[ID]["Index"],1);
    EffectDel(SystemMain.Users[ID]["Index"],8);
    EffectDel(SystemMain.Users[ID]["Index"],143);
    EffectDel(SystemMain.Users[ID]["Index"],144);
    table.remove(SystemMain.Users, ID);

end