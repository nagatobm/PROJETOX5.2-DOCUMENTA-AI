--[[ 
    Created by: Jonathan Coutinho;  
]]
 
BridgeFunctionAttach("OnReadScript","BattleRoyale_ReadScript");
BridgeFunctionAttach("OnTimerThread","BattleRoyale_TimerThread");
BridgeFunctionAttach("OnCommandManager","BattleRoyale_CommandManager");
BridgeFunctionAttach("OnUserDie","BattleRoyale_UserDie");
BridgeFunctionAttach("OnCheckUserTarget","BattleRoyale_CheckTarget");
BridgeFunctionAttach("OnCharacterClose","BattleRoyale_CharacterClose");

local SYSTEM_MAIN     = {};
local SYSTEM_CONFIG   = {};

function BattleRoyale_ReadScript()

    SYSTEM_CONFIG.Timer             = {};               -- Horário em que o evento acontecerá.
    SYSTEM_CONFIG.Timer[1]          = "20:30:00";       -- Primeiro horário;    
    SYSTEM_CONFIG.Timer[2]          = "21:35:00";       -- Segundo horário;
    SYSTEM_CONFIG.TimerAlert        = 1;                -- Tempo, em minutos, para duração do período de entrada;
    SYSTEM_CONFIG.TimerDrop         = 10;               -- Tempo, em segundos, para o drop dos itens;
    SYSTEM_CONFIG.TimerPick         = 3;                -- Tempo, em segundos, para que os participantes possam pegar os itens após droparem.

    SYSTEM_CONFIG.MaxUsers          = 20;                -- Número máximo de participantes;
    SYSTEM_CONFIG.MinUsers          = 5;                 -- Número mínimo de participantes;
    SYSTEM_CONFIG.Map               = 06;                -- Mapa onde o evento ocorrerá;
    SYSTEM_CONFIG.CordXY            = {155, 147};        -- Coordenada inicial do evento;
    SYSTEM_CONFIG.DropNumber        = 3;                -- Número de vezes que a EventItemBag será dropada em locais aleatórios definidos no final;
    SYSTEM_CONFIG.DropSpecialValue  = 20;               -- SpecialValue da EventItemBag que dropará os itens do evento;

    SYSTEM_CONFIG.Level             = 400;              -- Level em que os players ficarão, dentro do evento;
    SYSTEM_CONFIG.LevelUpPoint      = 15000;            -- Pontos disponibilizados para distribuição;
    SYSTEM_CONFIG.Strength          = 50;               -- Força inicial dos players;
    SYSTEM_CONFIG.Dexterity         = 50;               -- Agilidade inicial dos players;
    SYSTEM_CONFIG.Vitality          = 50;               -- Vitalidade inicial dos players;
    SYSTEM_CONFIG.Energy            = 50;               -- Energia inicial dos players;
    SYSTEM_CONFIG.Leadership        = 50;               -- Comando inicial dos players;

    SYSTEM_CONFIG.nmCommandEntry    = "/battle";  -- Nome do comando utilizado para entrar;
    SYSTEM_CONFIG.cdCommandEntry    = 104;              -- Código do comando utilizado para entrar;

    SYSTEM_CONFIG.RewardName0       = "Gold"            -- Nome da moeda creditada a todos os participantes, com exceção dos 3 primeiros.
    SYSTEM_CONFIG.RewardNumber0     = 1;                -- Quantidade que será debitada.

    SYSTEM_CONFIG.RewardName1       = "Gold"            -- Nome da moeda creditada ao participante em 1º lugar;
    SYSTEM_CONFIG.RewardNumber1     = 1;                -- Quantidade que será debitada.

    SYSTEM_CONFIG.RewardName2       = "Gold"            -- Nome da moeda creditada ao participante em 2º lugar;
    SYSTEM_CONFIG.RewardNumber2     = 1  ;              -- Quantidade que será debitada.

    SYSTEM_CONFIG.RewardName3       = "Gold"            -- Nome da moeda creditada ao participante em 3º lugar;
    SYSTEM_CONFIG.RewardNumber3     = 1;                -- Quantidade que será debitada.


    SYSTEM_CONFIG.DropCordX, SYSTEM_CONFIG.DropCordY = {}, {}; -- Coordenadas x e y de onde irão dropar os itens do evento, manter o padrão. Será aleatório.
    SYSTEM_CONFIG.DropCordX[1], SYSTEM_CONFIG.DropCordY[1] = 155,144; 
    SYSTEM_CONFIG.DropCordX[2], SYSTEM_CONFIG.DropCordY[2] = 155,150; 
    SYSTEM_CONFIG.DropCordX[3], SYSTEM_CONFIG.DropCordY[3] = 155,147; 
    SYSTEM_CONFIG.DropCordX[4], SYSTEM_CONFIG.DropCordY[4] = 158,147; 

    LogColor(3, "[BATTLE_ROYALE]: Configurações armazenadas com sucesso!");

end

function BattleRoyale_TimerThread()

    if (SYSTEM_MAIN.Stage == nil) then

        for i = 1, #SYSTEM_CONFIG.Timer, 1 do

            if (os.date("%X") == SYSTEM_CONFIG.Timer[i]) then

                SYSTEM_MAIN.Stage       = 1;
                SYSTEM_MAIN.UserCount   = 1;
                SYSTEM_MAIN.Count       = 0;
                SYSTEM_MAIN.Users       = {};
                SYSTEM_MAIN.TimerAlert  = SYSTEM_CONFIG.TimerAlert;
                LogColor(3, "[BATTLE_ROYALE]: Período de inscrição aberto.");

                break;

            end

        end

    elseif (SYSTEM_MAIN.Stage == 1) then

        if (SYSTEM_MAIN.Count%60 == 0) then

            if (SYSTEM_MAIN.TimerAlert == 0) then

                if (#SYSTEM_MAIN.Users >= SYSTEM_CONFIG.MinUsers) then

                    SYSTEM_MAIN.Stage       = 2;
                    SYSTEM_MAIN.Count       = 0;
                    SYSTEM_MAIN.ActiveDrop  = 0;
                    SYSTEM_MAIN.CountDrop   = 0;
                    SYSTEM_MAIN.UserCount   = nil;
                    SYSTEM_MAIN.TimerAlert  = nil;

                    NoticeSendToAll(0, ". : [ BATTLE ROYALE ] : .");
                    NoticeSendToAll(0, "Tempo esgotado, evento iniciado.");
                    LogColor(3, "[BATTLE_ROYALE]: Tempo esgotado, evento iniciado.");

                else

                    while (#SYSTEM_MAIN.Users > 0) do

                        NoticeSend(SYSTEM_MAIN.Users[1]["Index"], 1, "[BattleRoyale]: Você foi removido do evento por falta de participantes.");
                        SYSTEM_MAIN.DelUser(SYSTEM_MAIN.Users[1]["Index"]);
                
                    end

                    SYSTEM_MAIN.Stage       = nil;
                    SYSTEM_MAIN.UserCount   = nil;
                    SYSTEM_MAIN.Count       = nil;
                    SYSTEM_MAIN.Users       = nil;
                    SYSTEM_MAIN.TimerAlert  = nil;

                    NoticeSendToAll(0, ". : [ BATTLE ROYALE ] : .");
                    NoticeSendToAll(0, "Evento cancelado, mínimo de participantes não atingido.");
                    LogColor(3, "[BATTLE_ROYALE]: Evento cancelado, mínimo de participantes não atingido.");

                end

            else

                NoticeSendToAll(0, ". : [ BATTLE ROYALE ] : .");
                NoticeSendToAll(0, "O evento iniciará em "..SYSTEM_MAIN.TimerAlert.. " minuto(s).");
                NoticeSendToAll(0, "Digite "..SYSTEM_CONFIG.nmCommandEntry.." para participar.");

                SYSTEM_MAIN.Message(1, "[BattleRoyale]: Você já pode distribuir seus pontos! Caso ainda não tenha feito.");

                SYSTEM_MAIN.TimerAlert  = SYSTEM_MAIN.TimerAlert - 1;
                SYSTEM_MAIN.Count       = SYSTEM_MAIN.Count + 1;

            end

        else

            SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

        end

    elseif (SYSTEM_MAIN.Stage == 2) then

        if (SYSTEM_MAIN.Count == 0) then

            if (60-SYSTEM_MAIN.CountDrop <= 10) then
            
                if (SYSTEM_MAIN.CountDrop == 60) then

                    SYSTEM_MAIN.Message(0, ". : [ BATTLE ROYALE ] : .");
                    SYSTEM_MAIN.Message(0, "Fase de batalha iniciada. Boa sorte a todos!");
                    SYSTEM_MAIN.Message(1, "[BattleRoyale]: A onda de drop virá em "..SYSTEM_CONFIG.TimerDrop.."s, fique atento!");
                    SYSTEM_MAIN.CountDrop   = 0;
                    SYSTEM_MAIN.Count       = 1;

                    LogColor(3, "[BATTLE_ROYALE]: Fase de batalha iniciada.");

                else

                    SYSTEM_MAIN.Message(1, "[BattleRoyale]: Começará em "..60-SYSTEM_MAIN.CountDrop.."s. Prepare-se!");
                    SYSTEM_MAIN.CountDrop = SYSTEM_MAIN.CountDrop + 1;

                end

            elseif (SYSTEM_MAIN.CountDrop%10 == 0) then

                SYSTEM_MAIN.Message(0, " Distribua seus pontos! Não esqueça! Começará em "..60-SYSTEM_MAIN.CountDrop.."s.");

                SYSTEM_MAIN.CountDrop = SYSTEM_MAIN.CountDrop + 1;

            else

                SYSTEM_MAIN.CountDrop = SYSTEM_MAIN.CountDrop + 1;

            end

        else

            if (SYSTEM_MAIN.Users ~= nil) then

                if (SYSTEM_MAIN.Count%SYSTEM_CONFIG.TimerDrop == 0) then
                
                    SYSTEM_MAIN.Drop();
                    SYSTEM_MAIN.Message(0, ". : [ BATTLE ROYALE ] : .");
                    SYSTEM_MAIN.Message(0, "Itens dropados!! Aguarde "..SYSTEM_CONFIG.TimerPick.."s para pegar os itens.");
                    SYSTEM_MAIN.Message(1, "[BattleRoyale]:"..SYSTEM_CONFIG.TimerDrop.."s até a próxima onda de drop.");

                    SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

                
                elseif (SYSTEM_MAIN.Count%45 == 0) then

                    SYSTEM_MAIN.Message(0, ". : [ BATTLE ROYALE ] : .");
                    SYSTEM_MAIN.Message(0, "Restam "..#SYSTEM_MAIN.Users.." participantes. ");
                
                    SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;
                
                else
                
                    SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1; 
                
                end

                if (SYSTEM_MAIN.ActiveDrop == 1) then

                    if (SYSTEM_MAIN.CountDrop == SYSTEM_CONFIG.TimerPick) then

                        for x = 1, #SYSTEM_MAIN.Users, 1 do

                            PermissionInsert(SYSTEM_MAIN.Users[x]["Index"], 6);
                        
                        end

                        SYSTEM_MAIN.Message(0, ". : [ BATTLE ROYALE ] : .");
                        SYSTEM_MAIN.Message(0, "Os itens foram liberados, pegue-os!");

                        SYSTEM_MAIN.ActiveDrop = 0;
                        SYSTEM_MAIN.CountDrop  = 0;

                    else

                        SYSTEM_MAIN.CountDrop = SYSTEM_MAIN.CountDrop + 1;
                    
                    end

                end

            end

        end

    end

end

function BattleRoyale_CommandManager(aIndex, code,arg)

    if (code == SYSTEM_CONFIG.cdCommandEntry) then

        if (SYSTEM_MAIN.Stage ~= nil) then

            if (SYSTEM_MAIN.Stage == 1) then

                if (SYSTEM_MAIN.GetUser(aIndex) ~= 0) then

                    NoticeSend(aIndex, 1, "[BattleRoyale]: Você já está participando deste evento!");
                    
                else

                    for x = 0, 300, 1 do

                        if (InventoryGetItemIndex(aIndex, x) ~= -1) then

                            NoticeSend(aIndex, 1, "[BattleRoyale]: Você precisa esvaziar o inventário e a loja para entrar!");
                            
                            break;

                        elseif (x == 300) then

                            SYSTEM_MAIN.AddUser(aIndex);

                            NoticeSend(aIndex, 1, "[BattleRoyale]: Você entrou no evento, não saia ou perderá a vaga!");
                            NoticeSend(aIndex, 0, "Você entrou no evento, não saia ou perderá a vaga!");
        
                            if (#SYSTEM_MAIN.Users == SYSTEM_CONFIG.MaxUsers) then
        
                                SYSTEM_MAIN.Stage       = 2;
                                SYSTEM_MAIN.Count       = 0;
                                SYSTEM_MAIN.ActiveDrop  = 0;
                                SYSTEM_MAIN.CountDrop   = 0;
                                SYSTEM_MAIN.UserCount   = nil;
                                SYSTEM_MAIN.TimerAlert  = nil;
            
                                NoticeSendToAll(0, ". : [ BATTLE ROYALE ] : .");
                                NoticeSendToAll(0, "Máximo de participantes atingido, evento iniciado.");
        
                                LogColor(3, "[BATTLE_ROYALE]: Máximo de participantes atingido, evento iniciado.");
                                
        
                            end

                        end

                    end

                end

            else

                NoticeSend(aIndex, 1, "[BattleRoyale]: O período de entrada encontra-se encerrado, tente na próxima!");

            end

        else

            NoticeSend(aIndex, 1, "[BattleRoyale]: Evento indisponível no momento.");

        end

        return 1;

    end
	
	return 0;

end

function BattleRoyale_CheckTarget(aIndex, bIndex)

    if (SYSTEM_MAIN.Stage ~= nil) then
	
		if (SYSTEM_MAIN.Stage == 1) then
		
			if (SYSTEM_MAIN.GetUser(aIndex) ~= 0) and (SYSTEM_MAIN.GetUser(bIndex) ~= 0) then
		
				return 0;
				
			end
			
		else

			if (SYSTEM_MAIN.GetUser(aIndex) ~= 0) and (SYSTEM_MAIN.GetUser(bIndex) ~= 0) and (SYSTEM_MAIN.Count == 0) then

				return 0;

			end

		end

    end

    return 1;

end


            elseif (#SYSTEM_MAIN.Users == 2) then                
                
                NoticeSend(SYSTEM_MAIN.Users[b]["Index"], 1, "[BattleRoyale]: 1º lugar - bônus de "..SYSTEM_CONFIG.RewardNumber1.." "..SYSTEM_CONFIG.RewardName1..".");
                NoticeSend(SYSTEM_MAIN.Users[a]["Index"], 1, "[BattleRoyale]: 2º lugar - bônus de "..SYSTEM_CONFIG.RewardNumber2.." "..SYSTEM_CONFIG.RewardName2..".");
                NoticeSendToAll(0, ". : [ BATTLE ROYALE ] : .");
                NoticeSendToAll(0, "1º lugar - "..GetObjectName(SYSTEM_MAIN.Users[b]["Index"])..". Fez "..SYSTEM_MAIN.Users[b]["Kill"].." vítima(s).");
                NoticeSendToAll(1, "2º lugar - "..GetObjectName(SYSTEM_MAIN.Users[a]["Index"])..". Fez "..SYSTEM_MAIN.Users[a]["Kill"].." vítima(s).");
                
                LogColor(3, "[BATTLE_ROYALE]: Evento encerrado, ganhador: "..GetObjectName(SYSTEM_MAIN.Users[b]["Index"])..".");

                SYSTEM_MAIN.RewardS14(SYSTEM_MAIN.Users[b]["Index"], SYSTEM_CONFIG.RewardNumber1);
                SYSTEM_MAIN.RewardS14(SYSTEM_MAIN.Users[a]["Index"], SYSTEM_CONFIG.RewardNumber2);

				b = SYSTEM_MAIN.GetUser(bIndex);
                SYSTEM_MAIN.DelUser(SYSTEM_MAIN.Users[b]["Index"]);
				a = SYSTEM_MAIN.GetUser(aIndex);
				SYSTEM_MAIN.DelUser(SYSTEM_MAIN.Users[a]["Index"]);
                
                SYSTEM_MAIN.Stage       = nil;
                SYSTEM_MAIN.Count       = nil;
                SYSTEM_MAIN.Users       = nil;
                SYSTEM_MAIN.ActiveDrop  = nil;
                SYSTEM_MAIN.CountDrop   = nil;             

            else

                SYSTEM_MAIN.RewardS14(aIndex, SYSTEM_CONFIG.RewardNumber0); 
                SYSTEM_MAIN.DelUser(aIndex);
                
                NoticeSend(aIndex, 1, "[BattleRoyale]: "..#SYSTEM_MAIN.Users.."º lugar - bônus de "..SYSTEM_CONFIG.RewardNumber0.." "..SYSTEM_CONFIG.RewardName0..".");

            end
            
            NoticeSend(aIndex, 1, "[BattleRoyale]: Você morreu!! Consequentemente, foi removido(a) do evento. Tente na próxima!");
            

			if (SYSTEM_MAIN.Users ~= nil) then SYSTEM_MAIN.Message(1, "[BattleRoyale]: "..GetObjectName(bIndex).. " matou "..GetObjectName(aIndex)..". Restam "..#SYSTEM_MAIN.Users.." pessoas.") end;

        end

    end

end

function BattleRoyale_CharacterClose(aIndex)

    if (SYSTEM_MAIN.Stage ~= nil) then

        if (SYSTEM_MAIN.GetUser(aIndex) ~= 0) then

            SYSTEM_MAIN.DelUser(aIndex);

            SYSTEM_MAIN.Message(1, "[BattleRoyale]: O jogador(a) "..GetObjectName(aIndex).. " desconectou-se e foi removido do evento.");

        end

    end

end

function SYSTEM_MAIN.AddUser(aIndex)

    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]                    = {};
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Index"]           = aIndex;
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Level"]           = GetObjectLevel(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["LevelUpPoint"]    = GetObjectLevelUpPoint(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Strength"]        = GetObjectStrength(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Dexterity"]       = GetObjectDexterity(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Vitality"]        = GetObjectVitality(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Energy"]          = GetObjectEnergy(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Leadership"]      = GetObjectLeadership(aIndex);
    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Kill"]            = 0;
    SYSTEM_MAIN.UserCount                                       = SYSTEM_MAIN.UserCount + 1;

    SetObjectLevel(aIndex, SYSTEM_CONFIG.Level);
    SetObjectLevelUpPoint(aIndex, SYSTEM_CONFIG.LevelUpPoint);
    SetObjectStrength(aIndex, SYSTEM_CONFIG.Strength);
    SetObjectDexterity(aIndex, SYSTEM_CONFIG.Dexterity);
    SetObjectVitality(aIndex, SYSTEM_CONFIG.Vitality);
    SetObjectEnergy(aIndex, SYSTEM_CONFIG.Energy);
    SetObjectLeadership(aIndex, SYSTEM_CONFIG.Leadership);
    UserInfoSend(aIndex);
	UserCalcAttribute(aIndex);
    PermissionRemove(aIndex, 12);
    MoveUserEx(aIndex, SYSTEM_CONFIG.Map, SYSTEM_CONFIG.CordXY[1], SYSTEM_CONFIG.CordXY[2]);

end

function SYSTEM_MAIN.DelUser(aIndex)

    local y = SYSTEM_MAIN.GetUser(aIndex);

    for x = 0, 300, 1 do

        if (InventoryGetItemIndex(aIndex, x) ~= -1) then

            InventoryDelItemIndex(aIndex,x);

        end

    end

    SetObjectLevel(aIndex, SYSTEM_MAIN.Users[y]["Level"]);
    SetObjectLevelUpPoint(aIndex, SYSTEM_MAIN.Users[y]["LevelUpPoint"]);
    SetObjectStrength(aIndex, SYSTEM_MAIN.Users[y]["Strength"]);
    SetObjectDexterity(aIndex, SYSTEM_MAIN.Users[y]["Dexterity"]);
    SetObjectVitality(aIndex, SYSTEM_MAIN.Users[y]["Vitality"]);
    SetObjectEnergy(aIndex, SYSTEM_MAIN.Users[y]["Energy"]);
    SetObjectLeadership(aIndex, SYSTEM_MAIN.Users[y]["Leadership"]);
    UserInfoSend(aIndex);
	UserCalcAttribute(aIndex);
    PermissionInsert(aIndex, 12);
    PermissionInsert(aIndex, 6);
    MoveUserEx(aIndex, 0, 125, 125);

    table.remove(SYSTEM_MAIN.Users, y);

    if (SYSTEM_MAIN.Stage == 1) then SYSTEM_MAIN.UserCount = SYSTEM_MAIN.UserCount - 1 end;

end

function SYSTEM_MAIN.GetUser(aIndex)

	local Index = 0;

    for x, v in pairs(SYSTEM_MAIN.Users) do

        if (SYSTEM_MAIN.Users[x]["Index"] == aIndex) then

            Index = x;
			break;

        end

    end

    return Index;
    
end

function SYSTEM_MAIN.Message(iType, sMessage)

    for i = 1, #SYSTEM_MAIN.Users, 1 do

        if (iType == 1) then

            NoticeSend(SYSTEM_MAIN.Users[i]["Index"], 1, sMessage);
            
        else
            
            NoticeSend(SYSTEM_MAIN.Users[i]["Index"], 0, sMessage);

        end

    end

end

function SYSTEM_MAIN.Drop()

    for x = 1, #SYSTEM_MAIN.Users, 1 do

        PermissionRemove(SYSTEM_MAIN.Users[x]["Index"], 6);

    end

    for i = 1, SYSTEM_CONFIG.DropNumber, 1 do

        local x = math.random(458, 948);
        x       = math.random(5849, 8889);
        x       = math.random(1, #SYSTEM_CONFIG.DropCordX);

        ItemDrop(SYSTEM_MAIN.Users[1]["Index"],SYSTEM_CONFIG.Map,SYSTEM_CONFIG.DropCordX[x],SYSTEM_CONFIG.DropCordY[x],SYSTEM_CONFIG.DropSpecialValue);

    end

    SYSTEM_MAIN.ActiveDrop = 1;

end

function SYSTEM_MAIN.RewardS14(aIndex, aValue) 

    SQLQuery(string.format("UPDATE memb_info SET gold = gold +"..aValue.." WHERE memb___id = '"..GetObjectAccount(aIndex).."'"));
    SQLClose();

end