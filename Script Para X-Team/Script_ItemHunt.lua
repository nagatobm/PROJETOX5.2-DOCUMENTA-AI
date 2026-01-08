--[[ 
    Desenvolvido por: 
                        Jonathan C.
]]--

BridgeFunctionAttach("OnReadScript","evItemHunt_ReadScript");
BridgeFunctionAttach("OnTimerThread","evItemHunt_TimerThread");
BridgeFunctionAttach("OnNpcTalk","evItemHunt_NpcTalk");

local System  = {};
local Configs = {Items = {}, NoActived = 0};

function evItemHunt_ReadScript()

    Configs.Timer           = {"14:10:00", "21:50:00", "22:45:00"};     -- Horários em que o evento ocorrerá;
    Configs.TimerMax        = 3;                            -- Tempo, em minutos, para duração do evento;
    Configs.TimerAlert      = 30;                           -- Tempo, em segundos, para o alerta do item procurado;
	
    Configs.Map      		= 0;                           	--
    Configs.NpcMapName  	= "Lorência";                   --
	Configs.MonsterIndex	= 251;
	Configs.CordXY			= {125,125};
	Configs.Direction		= 9;
	
    Configs.Items[1]                  = {};                   -- Não alterar;
    Configs.Items[1]["Index"]         = 1;                    -- Index do item;
    Configs.Items[1]["Level"]         = 11;                   -- Level do item;
    Configs.Items[1]["Option1"]       = 0;                    -- Option 1 do item;
    Configs.Items[1]["Option2"]       = 0;                    -- Option 2 do item;
    Configs.Items[1]["Option3"]       = 0;                    -- Option 3 do item;
    Configs.Items[1]["NewOption"]     = 0;                    -- NewOption do item;
    Configs.Items[1]["SetOption"]     = 0;                    -- SetOption do item;
    Configs.Items[1]["RewardType"]    = 1;                    -- Tipo da coluna para o pagamento ao encontrar o item;
    Configs.Items[1]["RewardValue"]   = 5;                    -- Valor da premiação;
    Configs.Items[1]["RewardName"]    = "Gold";               -- Nome da moeda;
    Configs.Items[1]["Message"]       = "Small Axe não excelente +11";          -- Descrição que será anunciada para o encontro do item;

    Configs.Items[2]                  = {};
    Configs.Items[2]["Index"]         = 0;
    Configs.Items[2]["Level"]         = 11;
    Configs.Items[2]["Option1"]       = 0;
    Configs.Items[2]["Option2"]       = 0;
    Configs.Items[2]["Option3"]       = 0;
    Configs.Items[2]["NewOption"]     = 0;
    Configs.Items[2]["SetOption"]     = 0;
    Configs.Items[2]["RewardType"]    = 1;
    Configs.Items[2]["RewardValue"]   = 1;
    Configs.Items[2]["RewardName"]    = "gold";
    Configs.Items[2]["Message"]       = "Kris não excelente +11";

    Configs.Items[3]                  = {};
    Configs.Items[3]["Index"]         = 32;
    Configs.Items[3]["Level"]         = 13;
    Configs.Items[3]["Option1"]       = 0;
    Configs.Items[3]["Option2"]       = 0;
    Configs.Items[3]["Option3"]       = 0;
    Configs.Items[3]["NewOption"]     = 0;
    Configs.Items[3]["SetOption"]     = 0;
    Configs.Items[3]["RewardType"]    = 1;
    Configs.Items[3]["RewardValue"]   = 1;
    Configs.Items[3]["RewardName"]    = "gold";
    Configs.Items[3]["Message"]       = "Mace of King não excelente SEM ADD  +13";

    Configs.Items[4]                  = {};
    Configs.Items[4]["Index"]         = 3584;
    Configs.Items[4]["Level"]         = 9;
    Configs.Items[4]["Option1"]       = 0;
    Configs.Items[4]["Option2"]       = 0;
    Configs.Items[4]["Option3"]       = 0;
    Configs.Items[4]["NewOption"]     = 0;
    Configs.Items[4]["SetOption"]     = 0;
    Configs.Items[4]["RewardType"]    = 1;
    Configs.Items[4]["RewardValue"]   = 1;
    Configs.Items[4]["RewardName"]    = "gold";
    Configs.Items[4]["Message"]       = "Helm do set bronze não excelente SEM ADD +9";
	
	Configs.Items[5]                  = {};
    Configs.Items[5]["Index"]         = 4629;
    Configs.Items[5]["Level"]         = 9;
    Configs.Items[5]["Option1"]       = 0;
    Configs.Items[5]["Option2"]       = 0;
    Configs.Items[5]["Option3"]       = 0;
    Configs.Items[5]["NewOption"]     = 0;
    Configs.Items[5]["SetOption"]     = 0;
    Configs.Items[5]["RewardType"]    = 1;
    Configs.Items[5]["RewardValue"]   = 1;
    Configs.Items[5]["RewardName"]    = "gold";
    Configs.Items[5]["Message"]       = "GD pants não excelente SEM ADD +9";
	
	Configs.Items[6]                  = {};
    Configs.Items[6]["Index"]         = 5143;
    Configs.Items[6]["Level"]         = 6;
    Configs.Items[6]["Option1"]       = 0;
    Configs.Items[6]["Option2"]       = 0;
    Configs.Items[6]["Option3"]       = 0;
    Configs.Items[6]["NewOption"]     = 0;
    Configs.Items[6]["SetOption"]     = 0;
    Configs.Items[6]["RewardType"]    = 1;
    Configs.Items[6]["RewardValue"]   = 1;
    Configs.Items[6]["RewardName"]    = "gold";
    Configs.Items[6]["Message"]       = "Armor Hurricane nao EX SEM ADD +6";
	
end

function evItemHunt_TimerThread()

    if (System.Stage == nil) then

        for i = 1, #Configs.Timer, 1 do

            if (Configs.Timer[i] == os.date("%X")) then

                System.RewardActive = 0;
                System.Count        = 0;
                System.Stage        = 1;
                System.Users        = {};
                System.TimerMax     = Configs.TimerMax;
                System.Random       = math.random(1, #Configs.Items);
                System.NpcIndex     = MonsterCreate(Configs.MonsterIndex, Configs.Map, Configs.CordXY[1], Configs.CordXY[2], Configs.Direction);

                while (System.NoActived == System.Random) do

                    System.Random       = math.random(1, GetGameServerCurUser());
                    System.Random       = math.random(1, #Configs.Items);
                    System.Random       = math.random(1, 24578);
                    System.Random       = math.random(24579, 58947);
                    System.Random       = math.random(1, #Configs.Items);

                end

                LogPrint("[ITEM_HUNT]: Está na hora! Evento ligado.");

                break;

            end

        end

    elseif (System.Stage == 1) then

        if (System.Count%Configs.TimerAlert == 0) and (System.TimerMax > 0) then

            NoticeSendToAll(0, ". : [ ITEM HUNT ] : .");
            NoticeSendToAll(0, "Item procurado: "..Configs.Items[System.Random]["Message"]..".");
            NoticeSendToAll(0, "Entregue ao NPC em "..Configs.NpcMapName..". ("..Configs.CordXY[1]..","..Configs.CordXY[2]..").");

        end

        if (System.Count%60 == 0) then

            if (System.TimerMax == 0) then

                System.EventEnd();

                NoticeSendToAll(0, ". : [ ITEM HUNT ] : .");
                NoticeSendToAll(0, "Evento encerrado, não houve ganhador.");

                LogPrint("[ITEM_HUNT]: Evento encerrado, não houve ganhador.");

            else

                System.TimerMax = System.TimerMax - 1;
                System.Count    = System.Count + 1;

                NoticeSendToAll(1, "[ItemHunt]: Encerrará em "..(System.TimerMax+1).." minuto(s). Encontre o item, rápido!!");

            end

        else

            System.Count = System.Count + 1;

        end

    elseif(System.Stage == 2) then

        if (System.Count == 3) then

            ChatTargetSend(System.NpcIndex, -1, "Até a próxima, galera. Fui!!");
            System.EventEnd();

            LogPrint("[ITEM_HUNT]: Evento encerrado, "..GetObjectName(System.RewardActive).." ganhou o evento.");

        else

            System.Count = System.Count + 1;

                            ChatTargetSend(aIndex, bIndex, "O item não está com o luck da maneira que pedi!");

                        elseif (Configs.Items[System.Random]["Option3"] ~= Table.Option3) then

                            ChatTargetSend(aIndex, bIndex, "O item não está com o adicional de que preciso!");

                        elseif (Configs.Items[System.Random]["NewOption"] ~= Table.NewOption) then

                            ChatTargetSend(aIndex, bIndex, "O item não está com o adicional exe de que preciso!");

                        elseif (Configs.Items[System.Random]["SetOption"] ~= Table.SetOption) then

                            ChatTargetSend(aIndex, bIndex, "O item não está com o ancient de que preciso!");

                        else

                            System.Count        = 0;
                            System.Stage        = 2;
                            System.RewardActive = bIndex;

                            System.Reward(bIndex);
                            InventoryDelItemIndex(bIndex,x);

                            NoticeSendToAll(0, ". : [ ITEM HUNT ] : .");
                            NoticeSendToAll(0, GetObjectName(bIndex).." encontrou o item. Evento encerrado!");
                            NoticeSend(bIndex, 1, "[ItemHunt]: Você recebeu "..Configs.Items[System.Random]["RewardValue"].." "..Configs.Items[System.Random]["RewardName"]..".");

                            ChatTargetSend(aIndex, -1, "Você encontrou!! Muito obrigado, meu amigo!");

                            break;

                        end

                    end

                end

            else

                ChatTargetSend(aIndex, bIndex, "Você ainda não possui o item.");

            end

            return 1;

        end

    end

    return 0;

end

function System.EventEnd()

    MonsterDelete(System.NpcIndex);

    System.NoActived    = System.Random;
    System.RewardActive = nil;
    System.Count        = nil;
    System.Stage        = nil;
    System.Users        = nil;
    System.TimerMax     = nil;
    System.Random       = nil;
    System.NpcIndex     = nil;

end

function System.Reward(aIndex)

    SQLQuery("UPDATE memb_info SET gold = gold +"..Configs.Items[System.Random]["RewardValue"].." WHERE memb___id = '"..GetObjectAccount(aIndex).."'");
    SQLClose();

end