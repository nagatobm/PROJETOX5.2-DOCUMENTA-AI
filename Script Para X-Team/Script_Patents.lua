--[[
    Desenvolvido por:
                        Jonathan C.
]]--

BridgeFunctionAttach("OnReadScript","Patents_ReadScript");
BridgeFunctionAttach("OnShutScript","Patents_ShutScript");
BridgeFunctionAttach("OnCommandManager","Patents_CommandManager");
BridgeFunctionAttach("OnNpcTalk","Patents_NpcTalk");
BridgeFunctionAttach("OnCharacterEntry","Patents_Entry");
BridgeFunctionAttach("OnCharacterClose","Patents_Close");

local System  = {Users   = {}};
local Configs = {Patents = {}};

function Patents_ReadScript()

    Configs.Patents[1]                      = {};
    Configs.Patents[1]["PatentsName"]       = "Soldado";
    Configs.Patents[1]["ResetRequire"]      = 100;              -- Número de resets necessário.
    Configs.Patents[1]["MResetRequire"]     = 0;                -- Número de master resets necessário.
    Configs.Patents[1]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 0, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 0, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
    };

	Configs.Patents[2]                      = {};
    Configs.Patents[2]["PatentsName"]       = "Cabo";
    Configs.Patents[2]["ResetRequire"]      = 300;
    Configs.Patents[2]["MResetRequire"]     = 0;
    Configs.Patents[2]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 1, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 1, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
    };

	Configs.Patents[3]                      = {};
    Configs.Patents[3]["PatentsName"]       = "3 Sargento";
    Configs.Patents[3]["ResetRequire"]      = 400;
    Configs.Patents[3]["MResetRequire"]     = 0;
    Configs.Patents[3]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 2, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 2, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
    };

	Configs.Patents[4]                      = {};
    Configs.Patents[4]["PatentsName"]       = "2 Sargento";
    Configs.Patents[4]["ResetRequire"]      = 450;
    Configs.Patents[4]["MResetRequire"]     = 0;
    Configs.Patents[4]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 3, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 3, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
    };

    Configs.Patents[5]                      = {};
    Configs.Patents[5]["PatentsName"]       = "1 Sargento";
    Configs.Patents[5]["ResetRequire"]      = 500;
    Configs.Patents[5]["MResetRequire"]     = 0;
    Configs.Patents[5]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 4, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 4, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
    };

	Configs.Patents[6]                      = {};
    Configs.Patents[6]["PatentsName"]       = "Subtenente";
    Configs.Patents[6]["ResetRequire"]      = 550;
    Configs.Patents[6]["MResetRequire"]     = 1;
    Configs.Patents[6]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
    };

	Configs.Patents[7]                      = {};
    Configs.Patents[7]["PatentsName"]       = "Aspirante";
    Configs.Patents[7]["ResetRequire"]      = 600;
    Configs.Patents[7]["MResetRequire"]     = 0;
    Configs.Patents[7]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
    };

    Configs.Patents[8]                      = {};
    Configs.Patents[8]["PatentsName"]       = "2 Tenente";
    Configs.Patents[8]["ResetRequire"]      = 600;
    Configs.Patents[8]["MResetRequire"]     = 1;
    Configs.Patents[8]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 6, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 6, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [4] = {["ItemIndex"] = 7179, ["ItemLevel"] = 12, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
    };

	Configs.Patents[9]                      = {};
    Configs.Patents[9]["PatentsName"]       = "1 Tenente";
    Configs.Patents[9]["ResetRequire"]      = 650;
    Configs.Patents[9]["MResetRequire"]     = 0;
    Configs.Patents[9]["Reward"]            = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 8, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 8, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [4] = {["ItemIndex"] = 7179, ["ItemLevel"] = 12, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
    };

	Configs.Patents[10]                     = {};
    Configs.Patents[10]["PatentsName"]      = "Capitao";
    Configs.Patents[10]["ResetRequire"]     = 650;
    Configs.Patents[10]["MResetRequire"]    = 2;
    Configs.Patents[10]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 11, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};   
    };

    Configs.Patents[11]                     = {};
    Configs.Patents[11]["PatentsName"]      = "Major";
    Configs.Patents[11]["ResetRequire"]     = 700;
    Configs.Patents[11]["MResetRequire"]    = 0;
    Configs.Patents[11]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 14, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 14, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 10, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [4] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
    };

    Configs.Patents[12]                     = {};
    Configs.Patents[12]["PatentsName"]      = "Tenente-Coronel";
    Configs.Patents[12]["ResetRequire"]     = 700;
    Configs.Patents[12]["MResetRequire"]    = 2;
    Configs.Patents[12]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 2};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 2};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 13, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [4] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
    };

	Configs.Patents[13]                     = {};
    Configs.Patents[13]["PatentsName"]      = "Coronel";
    Configs.Patents[13]["ResetRequire"]     = 750;
    Configs.Patents[13]["MResetRequire"]    = 2;
    Configs.Patents[13]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 2};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 2};
        [3] = {["ItemIndex"] = 6174, ["ItemLevel"] = 2, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [4] = {["ItemIndex"] = 6175, ["ItemLevel"] = 2, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [5] = {["ItemIndex"] = 7179, ["ItemLevel"] = 12, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [6] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
    };
	Configs.Patents[14]                     = {};
    Configs.Patents[14]["PatentsName"]      = "General de Brigada";
    Configs.Patents[14]["ResetRequire"]     = 800;
    Configs.Patents[14]["MResetRequire"]    = 3;
    Configs.Patents[14]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 2};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 2};
        [3] = {["ItemIndex"] = 6174, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [4] = {["ItemIndex"] = 6175, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [5] = {["ItemIndex"] = 7179, ["ItemLevel"] = 11, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [6] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 7};
    };

    Configs.Patents[15]                     = {};
    Configs.Patents[15]["PatentsName"]      = "General de Divisao";
    Configs.Patents[15]["ResetRequire"]     = 850;
    Configs.Patents[15]["MResetRequire"]    = 3;
    Configs.Patents[15]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 3};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 3};
        [3] = {["ItemIndex"] = 6174, ["ItemLevel"] = 1, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [4] = {["ItemIndex"] = 6175, ["ItemLevel"] = 1, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [5] = {["ItemIndex"] = 7179, ["ItemLevel"] = 10, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [6] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 6};
    };

	Configs.Patents[16]                     = {};
    Configs.Patents[16]["PatentsName"]      = "General de Exercito";
    Configs.Patents[16]["ResetRequire"]     = 900;
    Configs.Patents[16]["MResetRequire"]    = 3;
    Configs.Patents[16]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 3};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 3};
        [3] = {["ItemIndex"] = 6174, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [4] = {["ItemIndex"] = 6175, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 1};
        [5] = {["ItemIndex"] = 7179, ["ItemLevel"] = 7, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [6] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 5};
    };

	Configs.Patents[17]                     = {};
    Configs.Patents[17]["PatentsName"]      = "Marechal";
    Configs.Patents[17]["ResetRequire"]     = 1000;
    Configs.Patents[17]["MResetRequire"]    = 5;
    Configs.Patents[17]["Reward"]           = {
        [1] = {["ItemIndex"] = 6174, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 5};
        [2] = {["ItemIndex"] = 6175, ["ItemLevel"] = 9, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 5};
        [3] = {["ItemIndex"] = 7179, ["ItemLevel"] = 13, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 8};
        [4] = {["ItemIndex"] = 7179, ["ItemLevel"] = 5, ["ItemDurability"] = 0, ["Option1"] = 0, ["Option2"] = 0, ["Option3"] = 0, ["NewOption"] = 0, ["Amount"] = 4};
    };

    System.NpcIndex                 = {
        [1] = MonsterCreate(249, 0, 126, 125, 9),
        [2] = MonsterCreate(249, 0, 127, 125, 9)
    };

	Configs.cdCommandInfo		= 100;
	Configs.nmCommandInfo		= "/patents"

end

function Patents_ShutScript()

	if (System.NpcIndex ~= nil) then

		while (#System.NpcIndex > 0) do

			MonsterDelete(System.NpcIndex[1]);
			table.remove(System.NpcIndex, 1);

		end

	end

end

function Patents_NpcTalk(aIndex, bIndex)

    local aName     = GetObjectName(bIndex);
    local a         = System.GetNpc(aIndex);
	local res, res0 = 0, 0;

    for k, v in pairs(Configs.Patents) do

        if (Configs.Patents[k]["PatentsName"] == System.Users[aName]["Patents"]) then

            res = k;

            break;

        end

    end

    for x = 12, 76, 1 do

        if (InventoryGetItemIndex(bIndex, x) ~= -1) then

            res0 = 1;
            break;

        end

    end

    if (a ~= 0) then

        if (System.Users[aName]["Patents"] ~= "") then

            if (System.Users[aName]["Patents"] ~= Configs.Patents[#Configs.Patents]["PatentsName"]) then

                if (System.Users[aName]["MReset"] >= Configs.Patents[res+1]["MResetRequire"]) then

                    if (GetObjectReset(bIndex) >= Configs.Patents[res+1]["ResetRequire"]) then

                        if (res0 == 0) then

                            SQLQuery("UPDATE Patents SET Patents='"..Configs.Patents[res+1]["PatentsName"].."',MReset="..GetObjectMasterReset(bIndex).." WHERE Name='"..aName.."'");
                            SQLClose();

                            System.Users[aName]["Patents"] = Configs.Patents[res+1]["PatentsName"];
                            System.Users[aName]["MReset"]  = 0;

                            for x = 1, #Configs.Patents[res+1]["Reward"], 1 do

                                for y = 1, Configs.Patents[res+1]["Reward"][x]["Amount"], 1 do

                                    ItemGiveEx(bIndex, Configs.Patents[res+1]["Reward"][x]["ItemIndex"], Configs.Patents[res+1]["Reward"][x]["ItemLevel"], Configs.Patents[res+1]["Reward"][x]["ItemDurability"], Configs.Patents[res+1]["Reward"][x]["Option1"], Configs.Patents[res+1]["Reward"][x]["Option2"], Configs.Patents[res+1]["Reward"][x]["Option3"], Configs.Patents[res+1]["Reward"][x]["NewOption"]);

                                end

                            end

                            NoticeSendToAll(0, GetObjectName(bIndex).." foi promovido para "..System.Users[aName]["Patents"]..".");
                            ChatTargetSend(aIndex, bIndex, "Voce foi promovido para "..System.Users[aName]["Patents"].."., meus parabens!!!");

                        else

                            ChatTargetSend(aIndex, bIndex, "Voce precisa esvaziar seu inventario para ser promovido");

                        end

                    else

                        if (math.random(0,1) == 0) then

                            ChatTargetSend(aIndex, bIndex, "Voce precisa ter "..Configs.Patents[res+1]["ResetRequire"].." Reset(s) para ser promovido");

                        else

                            ChatTargetSend(aIndex, bIndex, "Digite "..Configs.nmCommandInfo.." para obter informacoes");

                        end

                    end

                else

                    if (math.random(0,1) == 0) then

                        ChatTargetSend(aIndex, bIndex, "Voce precisa dar "..Configs.Patents[res+1]["MResetRequire"]-System.Users[aName]["MReset"].." Master Reset(s) para ser promovido");

                    else

                        ChatTargetSend(aIndex, bIndex, "Digite "..Configs.nmCommandInfo.." para obter informacoes");

                    end

                end

            else

                NoticeSend(bIndex, 1, ". : [ SISTEMA DE PATENTES ] : .");
                NoticeSend(bIndex, 1, "Patente: "..System.Users[aName]["Patents"]..".");
                ChatTargetSend(aIndex, bIndex, "Voce já está na patente maxima!");

            end

            if (Configs.Patents[res]["ActionSend"] ~= 0) then

                -- enviar actionsend para o npc.

            end

        else

			if (GetObjectReset(bIndex) >= Configs.Patents[1]["ResetRequire"]) then

				SQLQuery("UPDATE Patents SET Patents='"..Configs.Patents[1]["PatentsName"].."',MReset="..GetObjectMasterReset(bIndex).." WHERE Name='"..aName.."'");
                SQLClose();

                System.Users[aName]["Patents"] = Configs.Patents[1]["PatentsName"];
                
                for x = 1, #Configs.Patents[1]["Reward"], 1 do

                    for y = 1, Configs.Patents[1]["Reward"][x]["Amount"], 1 do

                        ItemGiveEx(bIndex, Configs.Patents[1]["Reward"][x]["ItemIndex"], Configs.Patents[1]["Reward"][x]["ItemLevel"], Configs.Patents[1]["Reward"][x]["ItemDurability"], Configs.Patents[1]["Reward"][x]["Option1"], Configs.Patents[1]["Reward"][x]["Option2"], Configs.Patents[1]["Reward"][x]["Option3"], Configs.Patents[1]["Reward"][x]["NewOption"]);

                    end

                end

				ChatTargetSend(aIndex, bIndex, "Parabens!! Você foi promovido para "..Configs.Patents[1]["PatentsName"]..".");

				NoticeSend(bIndex, 1, ". : [ SISTEMA DE PATENTES ] : .");

	end

	return 0;

end

function Patents_Entry(aIndex)

    local aName = GetObjectName(aIndex);
    local res   = 0;

    System.PlayerScam(aIndex);

	SQLQuery("SELECT Name,Patents,MReset FROM Patents WHERE Name='"..aName.."'");
    SQLFetch();
    SQLClose();

    System.Users[aName]             = {};
    System.Users[aName]["Patents"]  = SQLGetString("Patents");
    System.Users[aName]["MReset"]   = tonumber(GetObjectMasterReset(aIndex)-SQLGetNumber("MReset"));

    for k, v in pairs(Configs.Patents) do

        if (Configs.Patents[k]["PatentsName"] == System.Users[aName]["Patents"]) then

            res = k;

            break;

        end

    end

end

function Patents_Close(aIndex)

    System.Users[GetObjectName(aIndex)] = nil;

end

function System.GetNpc(aIndex)

    for x = 1, #System.NpcIndex, 1 do

        if (System.NpcIndex[x] == aIndex) then

            return x;

        end

    end

    return 0;

end

function System.PlayerScam(aIndex)

    local aName = GetObjectName(aIndex);

    SQLQuery("SELECT Name FROM Patents WHERE Name='"..aName.."'");
    local result = SQLFetch();
    SQLClose();

    if (result == 0.0) then

        SQLQuery("INSERT INTO Patents (Name,Patents,MReset) VALUES ('"..aName.."','',"..GetObjectMasterReset(aIndex)..")");
        SQLClose();

    end

end

function System.PlayerScam(aIndex)

    local aName = GetObjectName(aIndex);

    SQLQuery("SELECT Name FROM Patents WHERE Name='"..aName.."'");
    local result = SQLFetch();
    SQLClose();

    if (result == 0.0) then

        SQLQuery("INSERT INTO Patents (Name,Patents,MReset) VALUES ('"..aName.."','',"..GetObjectMasterReset(aIndex)..")");
        SQLClose();

    end

end