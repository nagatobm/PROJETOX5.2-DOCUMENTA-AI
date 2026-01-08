local inGame  = {};
local NPCs    = {};
local Configs = {};

--ScriptLoader_AddOnReadScript("NpcOfPresent_Read");
--ScriptLoader_AddOnShutScript("NpcOfPresent_Shut");
--ScriptLoader_AddOnTimerThread("NpcOfPresent_Timer");
--ScriptLoader_AddOnNpcTalk("NpcOfPresent_NpcTalk");
--ScriptLoader_AddOnCharacterEntry("NpcOfPresent_Entry");
--ScriptLoader_AddOnCharacterEntry("NpcOfPresent_Close");

BridgeFunctionAttach("OnReadScript","NpcOfPresent_Read");
BridgeFunctionAttach("OnShutScript","NpcOfPresent_Shut");
BridgeFunctionAttach("OnTimerThread","NpcOfPresent_Timer");
BridgeFunctionAttach("OnNpcTalk","NpcOfPresent_NpcTalk");
BridgeFunctionAttach("OnCharacterEntry","NpcOfPresent_Entry");
BridgeFunctionAttach("OnCharacterClose","NpcOfPresent_Close");

NpcOfPresent_Read = function()

    Configs.Time            = 3600; -- Tempo pra pegar a recompensa.
    Configs.RewardName      = "cash";
    Configs.RewardValue     = 5;

    NPCs[1] = MonsterCreate(249, 0, 130, 133, 3);
    
    for aIndex = GetMinUserIndex(), GetMaxUserIndex() do
        if GetObjectType(aIndex) == 1 and GetObjectConnected(aIndex) == 3 then
            inGame[aIndex] = Configs.Time;
        end;
    end;

end;

NpcOfPresent_Shut = function()
    while #NPCs > 0 do
        MonsterDelete(NPCs[1]);
        NPCs[1] = nil;
    end
end;

NpcOfPresent_Timer = function()

    for aIndex in pairs(inGame) do

        if GetObjectConnected(aIndex) == 3 then
            if inGame[aIndex] == 0 then
                NoticeSend(aIndex, 1, "[System]: Recompensa liberada.");
                inGame[aIndex] = -1;
            elseif inGame[aIndex] > 0 then
                inGame[aIndex] = inGame[aIndex] - 1;
            end;
        end;

    end;

end;

NpcOfPresent_NpcTalk = function(aIndex, bIndex)

    if inTableNpc(aIndex) ~= 0 then

        if inGame[bIndex] == -1 then
		    inGame[bIndex] = Configs.Time;
		    SQLQuery(string.format("UPDATE MEMB_INFO SET cash = cash + %d WHERE memb___id = '%s'", Configs.RewardValue, GetObjectAccount(bIndex)));
            SQLClose();
            ChatTargetSend(aIndex, bIndex, string.format("Parabéns!! Você recebeu %d %s.", Configs.RewardValue, Configs.RewardName));
        else
            ChatTargetSend(aIndex, bIndex, string.format("Ainda faltam %d segundos para desbloquear a recomepensa.", inGame[bIndex]));
        end;

        return 1;

    end

    return 0;

end;

NpcOfPresent_Entry = function(aIndex)
    inGame[aIndex] = Configs.Time;
end;

NpcOfPresent_Close = function(aIndex)
    inGame[aIndex] = nil;
end;

inTableNpc = function(aIndex)
    local Row = 0;
    for xIndex in pairs(NPCs) do
        if NPCs[xIndex] == aIndex then
            Row = xIndex;
            break;
        end;
    end;
    return Row;
end;