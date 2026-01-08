-- Developed by Jonathan.
-- Skype: jonathan_coutinhoc
-- Wpp: (21) 98759-7007

BridgeFunctionAttach("OnReadScript","FaF_ReadScript");
BridgeFunctionAttach("OnShutScript","FaF_ShutScript");
BridgeFunctionAttach("OnTimerThread","FaF_TimerThread");
BridgeFunctionAttach("OnCommandManager","FaF_CommandManager");
BridgeFunctionAttach("OnCharacterClose","FaF_CharacterClose");
BridgeFunctionAttach("OnNpcTalk","FaF_NpcTalk");
BridgeFunctionAttach("OnCheckUserTarget","FaF_UserTarget");

local System    = {};
local Configs   = {};

function FaF_ReadScript()

    Configs.Timer                           = {"12:10:00", "21:10:00"};
    Configs.TimerAlert                      = 1;
    Configs.TimerMax                        = 1;
    Configs.MinPlayers                      = 5;
    Configs.MaxPlayers                      = 10;

    Configs.nmCommandEntry                  = "/race";
    Configs.cdCommandEntry                  = 105;

    Configs.Map                             = 2;
    Configs.MonsterIndex                    = 249; 
    Configs.mCordXY                         = {225, 214}; -- por fim clicam aqui
    Configs.mDir                            = 9;

    Configs.CordXY                          = {};
    Configs.CordXY[1], Configs.CordXY[2]    = 204,58; -- Coordenada inicial do evento. nascem aqui qnd digitam o comando
    Configs.CordXY[3], Configs.CordXY[4]    = 222,75; -- Coordenada da corrida. dps vao pRa ca pra corrEr
    
    Configs.RewardName_1                    = "gold";
    Configs.RewardValue_1                   = 2;

    Configs.RewardName_2                    = "gold";
    Configs.RewardValue_2                   = 1;

    Configs.RewardName_3                    = "gold";
    Configs.RewardValue_3                   = 0;

end

function FaF_ShutScript()

	if (System.Stage ~= nil) then
	
		if (System.MonsterIndex ~= 0) then MonsterDelete(System.MonsterIndex) end;
		
	end

end

function FaF_TimerThread()

    if (System.Stage == nil) then

        for x = 1, #Configs.Timer, 1 do

            if (Configs.Timer[x] == os.date("%X")) then

                System.Count        = 0;
                System.Reward       = 0;
                System.MonsterIndex = 0;
                System.Stage        = 1;
                System.UserCount    = 1;
                System.Users        = {};
                System.TimerAlert   = Configs.TimerAlert;
                
                LogPrint("[FAST_AND_FURIOS]: Está na hora! Evento ligado.");

            end

        end

    elseif (System.Stage == 1) then

        if (System.Count % 60 == 0) then

            if (System.TimerAlert == 0) then

                if (#System.Users >= Configs.MinPlayers) then

                    NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                    NoticeSendToAll(0, "Evento iniciado. Tempo de entrada esgotado.");

                    System.Start();

                    LogPrint("[FAST_AND_FURIOS]: Evento iniciado. Tempo de entrada esgotado.");

                else

                    NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                    NoticeSendToAll(0, "Evento cancelado. Mínimo de participantes não atingido.");

                    System.End();

                    LogPrint("[FAST_AND_FURIOS]: Evento cancelado. Mínimo de participantes não atingido.");

                end

            else

                NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                NoticeSendToAll(0, "Participe já! Basta digitar '"..Configs.nmCommandEntry.."'.");
                NoticeSendToAll(0, "O evento fechará em "..System.TimerAlert.." minuto(s).");

                System.Count        = System.Count + 1;
                System.TimerAlert   = System.TimerAlert - 1;

            end

        else

            System.Count = System.Count + 1;

        end

    elseif (System.Stage == 2) then

        if (System.Count % 60 == 0) then

            if (System.TimerAlert == 0) then

                NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                NoticeSendToAll(0, "Evento encerrado. Tempo máximo excedido.");

                System.End();

                LogPrint("[FAST_AND_FURIOS]: Evento encerrado. Tempo máximo excedido.");

            else

                for x = 1, #System.Users, 1 do

                    NoticeSend(System.Users[x]["aIndex"], 1, "[Fast&Furios]: O evento encerrará em "..System.TimerAlert.." minuto(s), CORRA!!");

                end

                System.TimerAlert = System.TimerAlert - 1;
                System.Count      = System.Count + 1;

            end

        else

            System.Count = System.Count + 1;

        end

    end

end

function FaF_CommandManager(aIndex, code, arg)

    if (code == Configs.cdCommandEntry) then

        if (System.Stage == nil) then

            NoticeSend(aIndex, 1, "[Fast&Furios]: Evento indisponível no momento.");

        elseif (System.Stage == 1) then

            if (System.GetUser(aIndex) ~= 0) then

                NoticeSend(aIndex, 1, "[Fast&Furios]: Você já está participando deste evento.");

            else

                for x = 0, 11, 1 do

                    if (InventoryGetItemIndex(aIndex, 0) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 1) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 2) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 3) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 4) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 5) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 6) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 7) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 8) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 9) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 10) ~= -1) or
                    (InventoryGetItemIndex(aIndex, 11) ~= -1) then

                        NoticeSend(aIndex, 1, "[Fast&Furios]: Você não pode possuir itens equipados.");
                        NoticeSend(aIndex, 1, "[Fast&Furios]: Por favor, retire-os e tente novamente.");
                        break;

                    else

                        NoticeSend(aIndex, 1, "[Fast&Furios]: Você entrou no evento!");

                        System.Users[System.UserCount]              = {};
                        System.Users[System.UserCount]["aIndex"]    = aIndex;
                        System.UserCount                            = System.UserCount + 1;

                        MoveUserEx(aIndex, Configs.Map, Configs.CordXY[1], Configs.CordXY[2]);
                        PermissionRemove(aIndex, 4);
                        PermissionRemove(aIndex, 12);

                        if (#System.Users == Configs.MaxPlayers) then

                            NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                            NoticeSendToAll(0, "Evento iniciado. Máximo de participantes atingido.");

                            System.Start();

                            LogPrint("[FAST_AND_FURIOS]: Evento iniciado. Máximo de participantes atingido.");

                        end

                        break;

                    end

                end

            end

        elseif (System.Stage > 1) then

            NoticeSend(aIndex, 1, "[Fast&Furios]: O período de entrada já foi encerrado.");

        end

        return 1;

    end

    return 0;

end

function FaF_CharacterClose(aIndex)

    if (System.Stage ~= nil) then

        local a = System.GetUser(aIndex);

        if (a ~= 0) then

            NoticeSendToAll(1, "[Fast&Furios]: "..GetObjectName(aIndex).." desconectou-se e foi removido.");

            System.DelUser(aIndex);

        end

    end
end

function FaF_NpcTalk(aIndex, bIndex)

    if (System.Stage ~= nil) then

        if (System.MonsterIndex == aIndex) then

            if (System.GetUser(bIndex) ~= 0) then

                    if (System.Reward == 0) then

                        NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                        NoticeSendToAll(0, GetObjectName(bIndex).." chegou em 1º lugar.");
                        NoticeSendToAll(0, "É o FLASH??!?! Não, é "..GetObjectName(bIndex).."!!!");
                        NoticeSend(bIndex, 1, "[Fast&Furios]: Parabéns!! Você chegou em 1º lugar.");

                        System.RewardS14(bIndex, Configs.RewardValue_3, Configs.RewardName_3);
                        System.Reward = 1;

                        System.DelUser(bIndex);

                    elseif (System.Reward == 1) then

                        NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                        NoticeSendToAll(0, GetObjectName(bIndex).." chegou em 2º lugar.");
                        NoticeSendToAll(0, GetObjectName(bIndex).." passou voando!!!");
                        NoticeSend(bIndex, 1, "[Fast&Furios]: Parabéns!! Você chegou em 2º lugar.");

                        System.RewardS14(bIndex, Configs.RewardValue_3, Configs.RewardName_3);
                        System.Reward = 2;

                        System.DelUser(bIndex);

                    elseif (System.Reward == 2) then

                        NoticeSendToAll(0, ". : [ FAST AND FURIOS ] : .");
                        NoticeSendToAll(0, GetObjectName(bIndex).." chegou em 3º lugar.");
                        NoticeSendToAll(0, "O evento foi encerrado.");
    
        if (System.GetUser(aIndex) ~= 0) or (System.GetUser(bIndex) ~= 0) then

            return 0;

        end

    end

    return 1;

end

function System.GetUser(aIndex)

    for x = 1, #System.Users, 1 do

        if (System.Users[x]["aIndex"] == aIndex) then

            return x;

        end

    end

    return 0;

end

function System.DelUser(aIndex)

    for x = #System.Users, 1, -1 do

        if (System.Users[x]["aIndex"] == aIndex) then

            NoticeSend(aIndex, 1, "[Fast&Furios]: Você foi removido do evento.");

            PermissionInsert(aIndex, 4);
            PermissionInsert(aIndex, 12);
            MoveUserEx(aIndex, 0, 125, 125);
            table.remove(System.Users, x);

            if (System.Stage == 1) then System.UserCount = System.UserCount - 1 end;

        end

    end

end

function System.Start()

    System.Stage        = 2;
    System.Count        = 0;
    System.TimerAlert   = Configs.TimerMax;

    System.MonsterIndex = MonsterCreate(Configs.MonsterIndex, Configs.Map, Configs.mCordXY[1], Configs.mCordXY[2], Configs.mDir);

    for x = 1, #System.Users, 1 do

        MoveUserEx(System.Users[x]["aIndex"], Configs.Map, Configs.CordXY[3], Configs.CordXY[4]);

    end

end

function System.RewardS14(aIndex, aValue, aName)

    NoticeSend(aIndex, 1, "[Fast&Furios]: Você recebeu "..aValue.." "..aName..".");

    SQLQuery("UPDATE memb_info SET gold = gold +"..aValue.." WHERE memb___id = '"..GetObjectAccount(aIndex).."'");
    SQLClose();

    LogPrint("[FAST_AND_FURIOS]: "..GetObjectName(aIndex).." recebeu "..aValue.." "..aName..".");

end

function System.End()

    while (#System.Users > 0) do

        System.DelUser(System.Users[#System.Users]["aIndex"]);

    end

    if (System.Stage > 1) then MonsterDelete(System.MonsterIndex) end;

    System.Count        = nil;
    System.Reward       = nil;
    System.MonsterIndex = nil;
    System.Stage        = nil;
    System.UserCount    = nil;
    System.Users        = nil;
    System.TimerAlert   = nil;

end