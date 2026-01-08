-------------------------------
---  [CREATED BY JONATHAN]  ---
-------------------------------

BridgeFunctionAttach("OnReadScript","H_ReadScript")
BridgeFunctionAttach("OnTimerThread","H_TimerThread")
BridgeFunctionAttach("OnNpcTalk","H_NpcTalk")
BridgeFunctionAttach("OnShutScript","H_ShutScript")

H_System = {Stage = {0}, Alarm = {0}}
H_Count    = 0
H_Countt   = 0
H_Map      = 0
H_CordX    = 0
H_CordY    = 0
H_npcIndex = 0
H_Click    = 0

function H_ReadScript()    
    --[[ CONFIGURAÇÕES DA PREMIAÇÃO ]]--
    H_RewardName    = "gold"        -- Nome da moeda;
    H_TypeReward    = 1;            -- tipo da coluna
    H_ValueReward   = 1;            -- valor da premiação;

    --[[ CONFIGURAÇÕES DO HORÁRIO ]]--

    H_Timer = {"10:22:00", "20:26:00", "22:30:00"}
                                        
    H_Alarm = 1;                        -- Tempo em minutos do anúncio para o inicio do evento;
                                        -- OBS: MANTENHA ACIMA DE 3 MINUTOS;

    --[[ CONFIGURAÇOES DO LOCAL ]]--

    H_Local = {
        Maps = {0, 2},                  -- Número e nome dos mapas onde o evento poderá acontecer; 
        Name = {"Lorencia", "Devias, "}   -- Para cada mapa deve haver 1 nome.   
    }

end

function H_TimerThread()

    if (H_System.Stage[1] == 0) then

        for x = 1, #H_Timer, 1 do

            if (os.date("%X") == H_Timer[x])  then

                NoticeSendToAll(0, "[Guard] Olá, amigos!!! Que tal um Pique-Esconde, ein?!");

                H_System.Stage[1] = 1;
                H_System.Alarm[1] = H_Alarm;

            end

        end

    elseif (H_System.Stage[1] == 1) then

        if (H_Count%60 == 0) then

            if (H_System.Alarm[1] == 0) then

                NoticeSendToAll(0, "[Guard] Aqui está ótimo!! Venham me procurar, hehehe!");
                
                H_Count             = 0;
                H_System.Stage[1]   = 2;
                
                H_MonsterCreate();

            else

                NoticeSendToAll(0, string.format("[Guard] Espere %d minuto(s), estou me escondendo!",H_System.Alarm[1]));

                H_System.Alarm[1] = H_System.Alarm[1] - 1;
                H_Count           = H_Count + 1;

            end

        else

            H_Count = H_Count + 1;

        end
        
    elseif (H_System.Stage[1] == 2) then

        if(H_Count == 180) then

            H_Tips(1);

        elseif(H_Count == 240) then

            H_Tips(2);

        elseif(H_Count == 300) then

            H_Tips(3);

        elseif(H_Count == 360) then

            H_Tips(4);

        elseif (H_Count == 420) then -- essa dica diz a coordenada de onde ele tá, em 20s vai anunciar. é em segundos? sim, se quiser mudar só alterar 

            H_Tips(5);

        elseif (H_Count == 500) then

            H_Tips(6);
            
            H_Count = - 1;
            
            H_EventEnd();      
        end

        H_Count = H_Count + 1;

    end

end

function H_MonsterCreate()

    H_CordX = math.random(5844,515467);
    H_CordY = math.random(1245,554879);

    H_CordX = math.random(14231,9875641);
    H_CordY = math.random(14571,9847845);

    while (MapCheckAttr(H_Map,H_CordX,H_CordY,2) == 0.0) or (MapCheckAttr(H_Map,H_CordX,H_CordY,1) == 1.0) do

		H_CordX = math.random(1,255);
		H_CordX = math.random(1,255);
        H_CordY = math.random(1,255);
        H_CordY = math.random(1,255);
        	
    end
    
    H_Map       = math.random(1, #H_Local.Maps);
    H_npcIndex  = MonsterCreate(249,H_Local.Maps[H_Map],H_CordX,H_CordY,9);
    H_Click     = 1;

    NoticeSendToAll(0,"[Guard] Estou em "..H_Local.Name[H_Map]..", duvido me achar!");

end

function H_NpcTalk(aIndex, bIndex)

    if (H_npcIndex == aIndex) and (H_System.Stage[1] == 2) then

        if (H_Click == 1) and (GetObjectMap(aIndex) == H_Local.Maps[H_Map]) and (GetObjectMapX(aIndex) == H_CordX) and (GetObjectMapY(aIndex) == H_CordY) then 

            NoticeSendToAll(0,"[Guard] Parabéns, ".. GetObjectName(bIndex) ..". Achei que nunca iam me achar, haha!");
            NoticeSend(bIndex, 1, string.format("[Guard] Estou lhe dando %d %s, espero que ajude.", H_ValueReward, H_RewardName));
            H_RewardS4(bIndex);

            H_EventEnd();
            
        end

        return 1;

    end 

    return 0;
end

function H_RewardS4(aIndex)

    SQLQuery("SELECT type FROM Z_Credits WHERE memb___id = '"..GetObjectAccount(aIndex).."' AND type = "..H_TypeReward);
    CheckRew = SQLFetch();
    SQLClose();

    if (CheckRew == 0.0) then 

        SQLQuery("INSERT INTO Z_Credits (memb___id,value,type) VALUES ('"..GetObjectAccount(aIndex).."',"..H_ValueReward..","..H_TypeReward..")");
        SQLClose();

    else

        SQLQuery("UPDATE Z_Credits SET value = value +"..H_ValueReward.." WHERE memb___id = '"..GetObjectAccount(aIndex).."' and type = "..H_TypeReward);
        SQLClose();

    end

end

function H_Tips(aType)

    local lenX = string.len(tostring(H_CordX));
    local lenY = string.len(tostring(H_CordY));

    if (aType == 1) then

        NoticeSendToAll(0, "[Guard] Difícil, não é? Hahaha! Vou dar uma dica!");

        if (lenX == 1) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas X: ["..string.sub(tostring(H_CordX),0,1).."]");

        elseif (lenX == 2) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas X: ["..string.sub(tostring(H_CordX),0,1).."X]");

        elseif (lenX == 3) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas X: ["..string.sub(tostring(H_CordX),0,1).."XX]");

        end

    elseif (aType == 2) then

        NoticeSendToAll(0, "[Guard] Vocês nunca vão me achar, hahaha!");

    elseif (aType == 3) then

        NoticeSendToAll(0, "[Guard] Vocês estão muito moles!! Talvez com essa dica...");

        if (lenX == 1) then

            NoticeSendToAll(0, "[Guard] Não, ainda não... Procurem mais um pouco, haha!");

        elseif (lenX == 2) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas X: ["..string.sub(tostring(H_CordX),0,2).."]");

        elseif (lenX == 3) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas X: ["..string.sub(tostring(H_CordX),0,2).."X]");

        end

    elseif (aType == 4) then

        NoticeSendToAll(0, "[Guard] Vocês demoram muito. Preciso voltar ao trabalho! Que tal mais uma dica?");

        if (lenY == 1) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas Y: ["..string.sub(tostring(H_CordY),0,1).."]");

        elseif (lenY == 2) then

            NoticeSendToAll(0, "[Guard] Mapa: "..H_Local.Name[H_Map].." Coordenadas Y: ["..string.sub(tostring(H_CordY),0,1).."X]");


    H_Map   = 0;
    H_CordX = 0;
    H_CordY = 0;
    H_Click = 0;
    H_npcIndex = 0;
    H_System.Alarm[1] = 0;
    H_System.Stage[1] = 0;

end