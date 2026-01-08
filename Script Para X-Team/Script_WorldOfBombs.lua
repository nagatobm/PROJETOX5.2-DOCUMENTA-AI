BridgeFunctionAttach("OnReadScript","evWOB_ReadScript");
BridgeFunctionAttach("OnTimerThread","evWOB_TimerThread");
BridgeFunctionAttach("OnCommandManager","evWOB_CommandManager");
BridgeFunctionAttach("OnNpcTalk","evWOB_NpcTalk");
BridgeFunctionAttach("OnCharacterEntry","evWOB_CharacterEntry");
BridgeFunctionAttach("OnCharacterClose","evWOB_CharacterClose");
BridgeFunctionAttach("OnUserDie","evWOB_UserDie");
BridgeFunctionAttach("OnCheckUserTarget","evWOB_CheckUserTarget");
BridgeFunctionAttach("OnUserRespawn","evWOB_UserRespawn");

local evWOB_SystemTable = nil;
local evWOB_FuncsTable  =  {};
local evWOB_ConfigTable =  {};
local evWOB_TimerTable  =  {};

function evWOB_ReadScript()

	evWOB_TimerTable  = {"22:10:00"};
	
	evWOB_ConfigTable = {
	
		MaxUsers      = 40, -- max participantes
		MinUsers      = 2, -- min participantes
		Map           = 2, -- mapa
		MapName       = "Arena", -- nome do mapa
	
		cdCommandInfo = 102, -- codigo do comando de info
        nmCommandInfo = "/WOB", -- nome do comando
        	
		Entry_Timer   = 1,  -- tempo em minutos para entrar no evento;
		adEntry_Timer = 30, -- tempo em segundos para aparecer a mensagem notificando a entrada aberta;
	
		Score_Timer   = 30, -- tempo em segundos para aparecer o score do 1, 2 e 3 de cada equipe;
	
		Limit_Timer   = 5, -- tempo limite para primeira fase de batalha;
	
		vCordXY       = {205,132}, -- coordenadas iniciais do periodo de entrada;
	
		vName_E1      = "Terrorist", -- nome da equipe 1
		vName_E2      = "Counter Terrorist", -- nome da equipe 2
	
		vRespawn_CX1  = {200}, -- coordenada x dos points de respawn do lado a;
		vRespawn_CY1  = {114}, -- coordenada y;
		
		vRespawn_CX2  = {200}, -- coordenada x dos points de respawn do lado b;
		vRespawn_CY2  = {150}, -- coordenada y;
	
		DamageBomb    = {100,100}, -- dano causado pelas bombas ao nexus;
		NexusLife     = 200, -- vida maxima do nexus;
	
		ScoreDamage   = 10, -- points por explodir a bomba;
		ScoreDefend   = 10, -- points por defender uma explosao;
		nKill_Score   = 3, -- points por kill normal;
		eKill_Score   = 5, -- points por kill com a vitima tendo bomba;
	
		bNPC_Index    = 241, -- numero do npc que representara o nexus;
		bNPC_Dir      = 3, -- direcao
		bNPC_CordXY   = {206,116}, -- coordenadas x e y;
		
		nNPC_Index    = 256, -- numero do npc que dara as bombas;
		nNPC_Dir      = 1, -- direcao
		nNPC_CordXY   = {204,149}, -- coordenadas x e y;
	
		
		-- b?nus pros primeiros do ranking de ponto.
		vReward_Bonus1 = 7, -- valor
		nReward_Bonus1 = "gold", -- nome
	
		-- b?nus pros segundos do ranking de ponto.
		vReward_Bonus2 = 5, 
		nReward_Bonus2 = "gold",
	
		-- b?nus pros terceiros do ranking de ponto.
		vReward_Bonus3 = 3,
		nReward_Bonus3 = "gold",
	
		-- b?nus pra equipe vencedora.
		vReward_BonusW = 5,
		nReward_BonusW = "gold",
	
		-- b?nus pra equipe perdedora.
		vReward_BonusL = 2,
		nReward_BonusL = "gold"

	}
	
	LogPrint("[WORLD_OF_BOMBS]: CONFIGURAc?ES ARMAZENADAS.");
	
end

function evWOB_TimerThread()

    if (evWOB_SystemTable == nil) then
        
        local date = os.date("*t");

        for xx = 1, #evWOB_TimerTable do

            if (evWOB_TimerTable[xx] == os.date("%X")) then
                
                evWOB_FuncsTable.Manipulation(1);
                evWOB_FuncsTable.State(2);

                LogPrint("[WORLD_OF_BOMBS]: A HORA CHEGOU! EVENTO INICIADO.");

                break;

            end

        end

    elseif (evWOB_SystemTable.Stage == 2) then

        if (evWOB_SystemTable.Count == evWOB_ConfigTable.Entry_Timer*60) then

            if (evWOB_SystemTable.vCount >= evWOB_ConfigTable.MinUsers) then

                evWOB_FuncsTable.State(3);

                LogPrint("[WORLD_OF_BOMBS]: ENTRADA ENCERRADA, PRIMEIRO PER?ODO DE BATALHA INICIADO.");
                LogPrint("[WORLD_OF_BOMBS]: PARTICIPANTES T1: "..table.concat(evWOB_SystemTable.sName_T1, ",")..".");
                LogPrint("[WORLD_OF_BOMBS]: PARTICIPANTES T2: "..table.concat(evWOB_SystemTable.sName_T2, ",")..".");

            else

                evWOB_FuncsTable.NoticeUsers(0, ". : [ WORLD OF BOMBS- SERVER 1 ] : .");
                evWOB_FuncsTable.NoticeUsers(0, "EVENTO CANCELADO, M?NIMO DE PARTICIPANTES N?O ATINGIDO.");
                evWOB_FuncsTable.Manipulation(2);

                LogPrint("[WORLD_OF_BOMBS]: O M?NIMO DE PARTICIPANTES NAO FOI ATINGIDO, EVENTO ENCERRADO.");

            end

        elseif (evWOB_SystemTable.Count%evWOB_ConfigTable.adEntry_Timer == 0) then
             
            
            NoticeGlobalSend(0, ". : [ WORLD OF BOMBS- SERVER 1 ] : .");
            NoticeLangGlobalSend(0, "TYPE "..string.upper(evWOB_ConfigTable.nmCommandInfo).." TO PARTICIPATE.", "DIGITE "..string.upper(evWOB_ConfigTable.nmCommandInfo).." PARA PARTICIPAR.", "ESCRIBE "..string.upper(evWOB_ConfigTable.nmCommandInfo).." PARA PARTICIPAR.");
            NoticeGlobalSend(3, ". : [ WORLD OF BOMBS- SERVER 1 ] : .");
            NoticeLangGlobalSend(3, "TYPE "..string.upper(evWOB_ConfigTable.nmCommandInfo).." TO PARTICIPATE.", "DIGITE "..string.upper(evWOB_ConfigTable.nmCommandInfo).." PARA PARTICIPAR.", "ESCRIBE "..string.upper(evWOB_ConfigTable.nmCommandInfo).." PARA PARTICIPAR.");


            evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

        else

            evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

        
        end       

    elseif (evWOB_SystemTable.Stage == 3) then

        for xx = 1, #evWOB_SystemTable.sName_T1, 1 do

            if (GetObjectLevel(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx])) <= 6) then

                local aIndex = GetObjectIndexByName(evWOB_SystemTable.iFuse);

                if (GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]) == aIndex) then

                    evWOB_FuncsTable.iFuse();

                end

                MoveUserEx(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]), 0, 125, 125);
                EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]));
                PermissionInsert(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]), 12);            
                --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]), -1);//

                table.remove(evWOB_SystemTable.sName_T1,  xx);
                table.remove(evWOB_SystemTable.iBomb_T1,  xx);
                table.remove(evWOB_SystemTable.iScore_T1, xx);

            end

        end

        for yy = 1, #evWOB_SystemTable.sName_T2, 1 do

            if (GetObjectLevel(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy])) <= 6) then

                MoveUserEx(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]), 0, 125, 125);
                EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]));
                PermissionInsert(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]), 12);            
                --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]), -1);
                
                table.remove(evWOB_SystemTable.sName_T2,  yy);
                table.remove(evWOB_SystemTable.iBomb_T2,  yy);
                table.remove(evWOB_SystemTable.iScore_T2, yy);

            end

        end

        if (evWOB_SystemTable.Count%evWOB_ConfigTable.Score_Timer == 0) and (evWOB_SystemTable.Count > 0) then

            local T1, T2 = evWOB_FuncsTable.Ranking();

            evWOB_FuncsTable.NoticeUsers(0, ". : [ SCORE RANKING ] : .");
            evWOB_FuncsTable.NoticeUsers(0, "["..evWOB_ConfigTable.vName_E1.."]: 1 - "..T1.Name[1].."("..T1.Score[1].."), 2 - "..T1.Name[2].."("..T1.Score[2].."), 3 - "..T1.Name[3].."("..T1.Score[3]..").");
            evWOB_FuncsTable.NoticeUsers(0, "["..evWOB_ConfigTable.vName_E2.."]: 1 - "..T2.Name[1].."("..T2.Score[1].."), 2 - "..T2.Name[2].."("..T2.Score[2].."), 3 - "..T2.Name[3].."("..T2.Score[3]..").");
            evWOB_FuncsTable.NoticeUsers(1, "Time:" ..(evWOB_ConfigTable.Limit_Timer*60) -(evWOB_SystemTable.Count).." second(s).");

        end

        if (evWOB_SystemTable.iFuse ~= "") then

            local aIndex = GetObjectIndexByName(evWOB_SystemTable.iFuse);

            if (GetObjectMapX(aIndex) == evWOB_SystemTable.iCordXY[1]) and (GetObjectMapY(aIndex) == evWOB_SystemTable.iCordXY[2]) or (evWOB_SystemTable.iBomb_T1[evWOB_FuncsTable.GetUser(GetObjectIndexByName(aIndex))] == 1) then

                if (evWOB_SystemTable.iTemp < 10) then

                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "BOMB: "..(evWOB_SystemTable.iTemp*10).."%.");
                    evWOB_SystemTable.iTemp = evWOB_SystemTable.iTemp + 1;

                    EffectAdd(aIndex, 1, 83, 2, 0, 0, 0, 0);

                else
				
                    EffectAdd(aIndex, 1, 83, 2, 0, 0, 0, 0);

                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Bomba acionada, o nexus foi danificado.");
                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Pump triggered, the nexus has been damaged.");

                    local x, y = evWOB_FuncsTable.GetUser(aIndex);
                    local z = 354;
					z = math.random(evWOB_ConfigTable.DamageBomb[1], evWOB_ConfigTable.DamageBomb[2]);
					
                    evWOB_SystemTable.vNexus = evWOB_SystemTable.vNexus - z;
                    evWOB_SystemTable.iScore_T1[x] = evWOB_SystemTable.iScore_T1[x] + evWOB_ConfigTable.ScoreDamage;
                    evWOB_SystemTable.iBomb_T1[x]  = 0;
					
					--SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 405);

                    NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.ScoreDamage.." points. TOTAL: "..evWOB_SystemTable.iScore_T1[x]..".");
                    
                    if (evWOB_SystemTable.vNexus > 0) then

                        evWOB_FuncsTable.NoticeUsers(0, "O NEXUS FOI DANIFICADO.");
                        evWOB_FuncsTable.NoticeUsers(0, "NEXUS HAS BEEN DAMAGED.");
                        evWOB_FuncsTable.NoticeUsers(0, z.." by "..string.upper(evWOB_SystemTable.sName_T1[x])..".");
                        evWOB_FuncsTable.NoticeUsers(0,  "NEXUS HP: "..evWOB_SystemTable.vNexus..".");
						
                        evWOB_FuncsTable.iFuse();						

                    elseif (evWOB_SystemTable.vNexus <= 0) then

                        evWOB_FuncsTable.NoticeUsers(0, "O NEXUS FOI DESTRUIDO POR "..string.upper(evWOB_SystemTable.sName_T1[x])..".");
                        evWOB_FuncsTable.NoticeUsers(0, "NEXUS WAS DESTROID BY "..string.upper(evWOB_SystemTable.sName_T1[x])..".");
                        
                        evWOB_FuncsTable.State(4); 
                        LogPrint("[WORLD_OF_BOMBS]: PRIMEIRO PERIODO DE BATALHA ENCERRADO, SEGUNDO INICIADO.");

                    end

                end

            elseif (evWOB_SystemTable.iTemp > 1) then
                
                local x = evWOB_FuncsTable.GetUser(GetObjectIndexByName(evWOB_SystemTable.iFuse));
                
                evWOB_SystemTable.iBomb_T1[x]  = 0;
				--SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 405);
				
                evWOB_FuncsTable.iFuse(); 
                
                ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Explosao cancelada.");
                ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "EXPLOSION CANCELED");
				evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(evWOB_SystemTable.sName_T1[x]).." PERDEU A BOMBA.");
                                evWOB_FuncsTable.NoticeUsers(0, "THE PLAYER "..string.upper(evWOB_SystemTable.sName_T1[x]).." LOST THE BOMB.");
                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 1, "[SYSTEM]: Voce deixou a bomba para tras, pegue outra!");
                          NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 1, "[SYSTEM]: You have lost the bomb, pick another!");
            
            elseif (evWOB_SystemTable.iTemp == 0) or (evWOB_SystemTable.iTemp == 1) then

                evWOB_SystemTable.iCordXY[1] = GetObjectMapX(GetObjectIndexByName(evWOB_SystemTable.iFuse));
                evWOB_SystemTable.iCordXY[2] = GetObjectMapY(GetObjectIndexByName(evWOB_SystemTable.iFuse));

            end

        else

            if (evWOB_SystemTable.Count%30 == 0) then

                ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "LIFE: "..evWOB_SystemTable.vNexus);

            end

        end

        if (evWOB_SystemTable.Count <= 10) then

            if (evWOB_SystemTable.Count ~= 10) then

                evWOB_FuncsTable.NoticeUsers(1, "START IN "..(10-evWOB_SystemTable.Count).." second(s)."); 

                evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

            else

                evWOB_FuncsTable.NoticeUsers(0, ". : [ WORLD OF BOMBS ] : ."); 
                evWOB_FuncsTable.NoticeUsers(0, "STAGE 1.");

                evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

            end

        elseif(evWOB_SystemTable.Count == evWOB_ConfigTable.Limit_Timer*60) then

            evWOB_FuncsTable.State(4); 
            LogPrint("[WORLD_OF_BOMBS]: PRIMEIRO PERIODO DE BATALHA ENCERRADO, SEGUNDO INICIADO.");

        else

            evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

        end


    elseif (evWOB_SystemTable.Stage == 4) then 
        for xx = 1, #evWOB_SystemTable.sName_T1, 1 do

            if (GetObjectLevel(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx])) <= 6) then

                MoveUserEx(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]), 0, 125, 125);
                EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]));
                PermissionInsert(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]), 12);            
                --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[xx]), -1);

                table.remove(evWOB_SystemTable.sName_T1,  xx);
                table.remove(evWOB_SystemTable.iBomb_T1,  xx);
                table.remove(evWOB_SystemTable.iScore_T1, xx);

            end

        end

        for yy = 1, #evWOB_SystemTable.sName_T2, 1 do

            if (GetObjectLevel(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy])) <= 6) then

                local aIndex = GetObjectIndexByName(evWOB_SystemTable.iFuse);

                if (GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]) == aIndex) then

                    evWOB_FuncsTable.iFuse();

                end

                MoveUserEx(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]), 0, 125, 125);
                EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]));
                PermissionInsert(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]), 12);            
                --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[yy]), -1);
                
                table.remove(evWOB_SystemTable.sName_T2,  yy);
                table.remove(evWOB_SystemTable.iBomb_T2,  yy);
                table.remove(evWOB_SystemTable.iScore_T2, yy);

            end

        end

        if (evWOB_SystemTable.Count%evWOB_ConfigTable.Score_Timer == 0) and (evWOB_SystemTable.Count > 0) then

            local T1, T2 = evWOB_FuncsTable.Ranking();

            evWOB_FuncsTable.NoticeUsers(0, ". : [ SCORE RANKING ] : .");
            evWOB_FuncsTable.NoticeUsers(0, "["..evWOB_ConfigTable.vName_E1.."]: 1 - "..T1.Name[1].."("..T1.Score[1].."), 2 - "..T1.Name[2].."("..T1.Score[2].."), 3 - "..T1.Name[3].."("..T1.Score[3]..").");
            evWOB_FuncsTable.NoticeUsers(0, "["..evWOB_ConfigTable.vName_E2.."]: 1 - "..T2.Name[1].."("..T2.Score[1].."), 2 - "..T2.Name[2].."("..T2.Score[2].."), 3 - "..T2.Name[3].."("..T2.Score[3]..").");
            evWOB_FuncsTable.NoticeUsers(1, "Time:" ..(evWOB_SystemTable.vTemp - evWOB_SystemTable.Count).." second(s).");

        end

        if (evWOB_SystemTable.iFuse ~= "") then
    
            local aIndex = GetObjectIndexByName(evWOB_SystemTable.iFuse);
    
            if (GetObjectMapX(aIndex) == evWOB_SystemTable.iCordXY[1]) and (GetObjectMapY(aIndex) == evWOB_SystemTable.iCordXY[2]) or (evWOB_SystemTable.iBomb_T2[evWOB_FuncsTable.GetUser(GetObjectIndexByName(aIndex))] == 1) then
                
                if (evWOB_SystemTable.iTemp < 10) then
                    
                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "BOMB: "..(evWOB_SystemTable.iTemp*10).."%.");
                    evWOB_SystemTable.iTemp = evWOB_SystemTable.iTemp + 1;

                    EffectAdd(aIndex, 1, 83, 2, 0, 0, 0, 0);
                    
                else
				
                    EffectAdd(aIndex, 1, 83, 2, 0, 0, 0, 0);
					
                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Bomba acionada, o nexus foi danificado.");
                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "BOMB ACTIVATED, Nexus has been damaged");

                    local x = evWOB_FuncsTable.GetUser(aIndex);
					local z = 354;
					z = math.random(evWOB_ConfigTable.DamageBomb[1], evWOB_ConfigTable.DamageBomb[2]);
                    
                    evWOB_SystemTable.vNexus       = evWOB_SystemTable.vNexus - z;
                    evWOB_SystemTable.iScore_T2[x] = evWOB_SystemTable.iScore_T2[x] + evWOB_ConfigTable.ScoreDamage;
                    evWOB_SystemTable.iBomb_T2[x]  = 0;

					--SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 404);

                    NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.ScoreDamage.." points. TOTAL: "..evWOB_SystemTable.iScore_T2[x]..".");

                    if (evWOB_SystemTable.vNexus > 0) then

                        evWOB_FuncsTable.NoticeUsers(0, "O NEXUS FOI DANIFICADO.");
                        evWOB_FuncsTable.NoticeUsers(0, "NEXUS HAS BEEN DAMAGED.");
                        evWOB_FuncsTable.NoticeUsers(0, z.." by "..string.upper(evWOB_SystemTable.sName_T2[x])..".");
                        evWOB_FuncsTable.NoticeUsers(0,  "NEXUS HP: "..evWOB_SystemTable.vNexus..".");
                        
                        evWOB_FuncsTable.iFuse(); 

                    elseif (evWOB_SystemTable.vNexus <= 0) then

                        evWOB_FuncsTable.NoticeUsers(0, "O NEXUS FOI DESTRUIDO POR "..string.upper(evWOB_SystemTable.sName_T2[x])..".");
                        evWOB_FuncsTable.NoticeUsers(0, "NEXUS WAS DESTROID BY "..string.upper(evWOB_SystemTable.sName_T2[x])..".");

                        evWOB_FuncsTable.Reward(2);
                        evWOB_FuncsTable.State(5); 

                    end

                end
                
            elseif (evWOB_SystemTable.iTemp > 1) then

                local x = evWOB_FuncsTable.GetUser(GetObjectIndexByName(evWOB_SystemTable.iFuse));
                
                evWOB_SystemTable.iBomb_T2[x]  = 0;
                
                evWOB_FuncsTable.iFuse();  
				--SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 404);

                ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Explosao cancelada.");
                ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Explosion canceled.");
				evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(evWOB_SystemTable.sName_T2[x]).." PERDEU A BOMBA.");
                                evWOB_FuncsTable.NoticeUsers(0, "The Player "..string.upper(evWOB_SystemTable.sName_T2[x]).." Lost the bomb.");
                               
                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 1, "[SYSTEM]: Voce deixou a bomba para tras, pegue outra!");
NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 1, "[SYSTEM]: You lost the bomb!, pick another!!");

            elseif (evWOB_SystemTable.iTemp == 0) or (evWOB_SystemTable.iTemp == 1) then

                evWOB_SystemTable.iCordXY[1] = GetObjectMapX(GetObjectIndexByName(evWOB_SystemTable.iFuse));
                evWOB_SystemTable.iCordXY[2] = GetObjectMapY(GetObjectIndexByName(evWOB_SystemTable.iFuse));
                
            end

        else   
            
            if (evWOB_SystemTable.Count%30 == 0) then

                ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "LIFE: "..evWOB_SystemTable.vNexus);

            end
            
        end

        if (evWOB_SystemTable ~= nil) then

            if (evWOB_SystemTable.Count <= 10) then

                if (evWOB_SystemTable.Count ~= 10) then

                    evWOB_FuncsTable.NoticeUsers(1, "START IN "..(10-evWOB_SystemTable.Count).." second(s)."); 

                    evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

                else

                    evWOB_FuncsTable.NoticeUsers(0, ". : [ WORLD OF BOMBS ] : ."); 
                    evWOB_FuncsTable.NoticeUsers(0, "STAGE 2");

                    evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

                end

            elseif(evWOB_SystemTable.Count == evWOB_SystemTable.vTemp) then

                evWOB_FuncsTable.Reward(1);
                evWOB_FuncsTable.State(5); 

            else

                evWOB_SystemTable.Count = evWOB_SystemTable.Count + 1;

            end

        end 

    end 

end


function evWOB_CommandManager (aIndex, code, arg)

	if (evWOB_SystemTable ~= nil) then
	
		if (code == evWOB_ConfigTable.cdCommandInfo) then
				
            if (evWOB_SystemTable.Stage == 2) then
                
                if (evWOB_FuncsTable.GetUser(aIndex) ~= 0) then

                    NoticeSend(aIndex, 1, "[SYSTEM]: Voce ja esta participando.");
                    NoticeSend(aIndex, 1, "[SYSTEM]: YOU ARE IN THE EVENT.");

                else

                    if (evWOB_SystemTable.vCount < evWOB_ConfigTable.MaxUsers) then

                        evWOB_SystemTable.vCount = evWOB_SystemTable.vCount + 1;

                        table.insert(evWOB_SystemTable.vName, GetObjectName(aIndex));
                        evWOB_FuncsTable.MoveUser(aIndex, 0);                       
                        NoticeSend(aIndex, 1, "[SYSTEM]: Voce entrou, nao saia do jogo ou perdera perder a vaga."); 
                        NoticeSend(aIndex, 1, "[SYSTEM]: you are in the event, dont quit!"); 

                    else

                        NoticeSend(aIndex, 1, "[SYSTEM]: O limite de participantes ja foi atingido.");

                    end

                end
				
			else 
			
				NoticeSend(aIndex, 1,"[SYSTEM]: Comando indispon?vel no momento.");

            end
			
			return 1;
			
		end
		
	end

    return 0;

end

function evWOB_NpcTalk(aIndex, bIndex)

    if (evWOB_SystemTable ~= nil) then

        if (evWOB_SystemTable.Stage == 3) then

            if (evWOB_SystemTable.mIndex[1] == aIndex) then

                local x, y = evWOB_FuncsTable.GetUser(bIndex);

                if (y == 1) then

                    if (evWOB_SystemTable.iBomb_T1[x] == 1) then

                        
                        ChatTargetSend(aIndex, bIndex, "You have the bomb");

                    else

                        EffectAdd(bIndex, 1, 75, 600, 0, 0, 0, 0);
                        ChatTargetSend(aIndex, bIndex, "ALLAHU AKBAR!");
						evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(GetObjectName(bIndex)).." PEGOU UMA BOMBA.");
                                                evWOB_FuncsTable.NoticeUsers(0, "The player "..string.upper(GetObjectName(bIndex)).." Got a Bomb.");
                        evWOB_SystemTable.iBomb_T1[x] = 1;

                    end

                else

                    ChatTargetSend(aIndex, bIndex, "no bomb");

                end

                return 1;
            
            elseif (evWOB_SystemTable.mIndex[2] == aIndex) then

                local x, y = evWOB_FuncsTable.GetUser(bIndex);

                if (y == 1) then

                    if (evWOB_SystemTable.iBomb_T1[x] == 1) and (evWOB_SystemTable.iClick == 0) then

                        evWOB_SystemTable.iFuse      = evWOB_SystemTable.sName_T1[x];
                        evWOB_SystemTable.iCordXY[1] = GetObjectMapX(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]));
                        evWOB_SystemTable.iCordXY[2] = GetObjectMapY(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]));
                        evWOB_SystemTable.iClick = 1;
                        --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]),55);

                        EffectAdd(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 1, 83, 2, 0, 0, 0, 0);
                        
                        evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(evWOB_SystemTable.sName_T1[x]).." ESTA ATIVANDO A BOMBA.");
                        evWOB_FuncsTable.NoticeUsers(0, "The Player "..string.upper(evWOB_SystemTable.sName_T1[x]).." is activating the bomb.");

                    elseif (evWOB_SystemTable.iBomb_T1[x] == 0) then
                        
                        ChatTargetSend(aIndex, bIndex, "no bomb");

                    elseif (evWOB_SystemTable.iBomb_T1[x] == 1) and (evWOB_SystemTable.iClick == 1) then

                        ChatTargetSend(aIndex, bIndex, "BOMB IS PLANTING");
                        

                    end

                else

                    ChatTargetSend(aIndex, bIndex, "HELP!!");

                end

                return 1;

            end

        elseif (evWOB_SystemTable.Stage == 4) then

            if (evWOB_SystemTable.mIndex[1] == aIndex) then

                local x, y = evWOB_FuncsTable.GetUser(bIndex);

                if (evWOB_SystemTable.iBomb_T2[x] == 1) then

                    ChatTargetSend(aIndex, bIndex, "You have the bomb!");
                    

                else

                    EffectAdd(bIndex, 1, 75, 600, 0, 0, 0, 0);
                    ChatTargetSend(aIndex, bIndex, "ALLAHU AKBAR!");
					evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(GetObjectName(bIndex)).." PEGOU UMA BOMBA.");
                                        evWOB_FuncsTable.NoticeUsers(0, "The Player "..string.upper(GetObjectName(bIndex)).." got a bomb.");
                    evWOB_SystemTable.iBomb_T2[x] = 1;

                end

                return 1;

            elseif (evWOB_SystemTable.mIndex[2] == aIndex) then

                local x, y = evWOB_FuncsTable.GetUser(bIndex);

                if (y == 2) then

                    if (evWOB_SystemTable.iBomb_T2[x] == 1) and (evWOB_SystemTable.iClick == 0) then

                        evWOB_SystemTable.iFuse      = evWOB_SystemTable.sName_T2[x];
                        evWOB_SystemTable.iCordXY[1] = GetObjectMapX(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]));
                        evWOB_SystemTable.iCordXY[2] = GetObjectMapY(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]));
                        evWOB_SystemTable.iClick = 1;
                        --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]),55);

                        EffectAdd(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 1, 83, 10, 0, 0, 0, 0);
    
                        evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(evWOB_SystemTable.sName_T2[x]).." ESTA ATIVANDO A BOMBA.");
                        evWOB_FuncsTable.NoticeUsers(0, "THE PLAYER "..string.upper(evWOB_SystemTable.sName_T2[x]).." is activating the BOMB.");

                    elseif (evWOB_SystemTable.iBomb_T2[x] == 0) then
                        
                        ChatTargetSend(aIndex, bIndex, "no bomb");

                    elseif (evWOB_SystemTable.iBomb_T2[x] == 1) and (evWOB_SystemTable.iClick == 1) then

                        ChatTargetSend(aIndex, bIndex, "Bomb is beeing planted");
                        
                    end

                else

                    ChatTargetSend(aIndex, bIndex, "HELP!!");

                end

                return 1;

            end

        end

    end

    return 0;

end

function evWOB_CharacterEntry(aIndex)

    if (evWOB_SystemTable ~= nil) then 

        if (evWOB_SystemTable.Stage >= 3) then

            local x, y = evWOB_FuncsTable.GetUser(aIndex);

            if (x ~= 0) then

                evWOB_FuncsTable.MoveUser(aIndex, y);
                EffectAdd(aIndex, 1, 65, 5, 0, 0, 0, 0);
                
                if (y == 1) then

                   --SkinChangeSend(aIndex, 405);
                    
                else
                    
                   --SkinChangeSend(aIndex, 404);

                end

            end

        end

    end

end

function evWOB_CharacterClose(aIndex)

    if (evWOB_SystemTable ~= nil) then

        if (evWOB_SystemTable.Stage == 2) then

            local x = evWOB_FuncsTable.GetUser(aIndex);

            if (x ~= 0) then

                evWOB_FuncsTable.NoticeUsers(0, ". : [ WORLD OF BOMBS ] : .");
                evWOB_FuncsTable.NoticeUsers(0, " "..string.upper(evWOB_SystemTable.vName[x]).." left (-1 corno)");
                

                evWOB_SystemTable.vCount = evWOB_SystemTable.vCount - 1;
                MoveUserEx(GetObjectIndexByName(evWOB_SystemTable.vName[x]), 0, 125, 125);
               

                table.remove(evWOB_SystemTable.vName, x);

            end

        elseif (evWOB_SystemTable.Stage > 2) then

            local x, y = evWOB_FuncsTable.GetUser(aIndex);

            if (x ~= 0) then

                if (y == 1) then

                    if (evWOB_SystemTable.iBomb_T1[x] == 1) then

                        evWOB_SystemTable.iBomb_T1[x] = 0;

                    end

                    if (evWOB_SystemTable.sName_T1[x] == evWOB_SystemTable.iFuse) then

                        --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]), 405);
						evWOB_FuncsTable.iFuse();

                    end

                else

                    if (evWOB_SystemTable.iBomb_T2[x] == 1) then

                        evWOB_SystemTable.iBomb_T2[x] = 0;

                    end

                    if (evWOB_SystemTable.sName_T2[x] == evWOB_SystemTable.iFuse) then

                        --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]), 404);
						evWOB_FuncsTable.iFuse();

                    end

                end
               
            end

        end

    end

end

function evWOB_UserDie(aIndex,bIndex)

    if (evWOB_SystemTable ~= nil) then

        if (evWOB_SystemTable.Stage > 2) then

            local x1, y1 = evWOB_FuncsTable.GetUser(bIndex);
            local x2, y2 = evWOB_FuncsTable.GetUser(aIndex);

            if (x1 ~= 0) and (x2 ~= 0) then
                
                evWOB_FuncsTable.Score(x1, y1, x2, y2);

                if (GetObjectName(aIndex) == evWOB_SystemTable.iFuse) then

                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Explosao cancelada.");
                    ChatTargetSend(evWOB_SystemTable.mIndex[2], -1, "Explosion canceled.");
                    NoticeSend(aIndex, 1, "[SYSTEM]: Voce perdeu a bomba, pegue outra!");
                    NoticeSend(aIndex, 1, "[SYSTEM]: You have lost the bomb, pick another");
					evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A)"..string.upper(GetObjectName(aIndex)).." PERDEU A BOMBA.");
                                        evWOB_FuncsTable.NoticeUsers(0, "The Player "..string.upper(GetObjectName(aIndex)).." lost the bomb");
                                           
                    evWOB_FuncsTable.iFuse();
                    
                    if (y2 == 1) then

                        --SkinChangeSend(aIndex, 405);
                        
                    else
                        
                        --SkinChangeSend(aIndex, 404);

                    end

                end


            end

        end

    end

end

function evWOB_CheckUserTarget(aIndex,bIndex)

    if (evWOB_SystemTable ~= nil) then

        if (evWOB_SystemTable.Stage == 2) then
            
            local x = evWOB_FuncsTable.GetUser(aIndex);

            if (x ~= 0) then

                return 0;

            end

        elseif (evWOB_SystemTable.Stage > 2) then

            local x1, y1 = evWOB_FuncsTable.GetUser(aIndex);
            local x2, y2 = evWOB_FuncsTable.GetUser(bIndex);

			if (x1 ~= 0) and (x2 ~= 0) then
			
				if (y1 == y2) then

					return 0;

				else

					return 1;

				end
				
			end

        end

    end

    return 1;

end

function evWOB_UserRespawn(aIndex, KillerType)

    if (evWOB_SystemTable ~= nil) then

        local x, y = evWOB_FuncsTable.GetUser(aIndex);

        if (x ~= 0) then

            if (y == 1) then

                if (evWOB_SystemTable.iBomb_T1[x] == 1) then

                    NoticeSend(aIndex, 1, "[SYSTEM]: Voce morreu e foi movido para base.");
                   NoticeSend(aIndex, 1, "[SYSTEM]: You died!.");

                end

                --SkinChangeSend(aIndex, 405);

            else

                if (evWOB_SystemTable.iBomb_T2[x] == 1) then

                    NoticeSend(aIndex, 1, "[SYSTEM]: Voce morreu, perdeu a bomba e foi movido para base.");
                    NoticeSend(aIndex, 1, "[SYSTEM]: Youd died.");
					evWOB_FuncsTable.NoticeUsers(0, "O JOGADOR(A) "..string.upper(GetObjectName(aIndex)).." PERDEU A BOMBA.");
                    evWOB_FuncsTable.NoticeUsers(0, "The Player "..string.upper(GetObjectName(aIndex)).." Lost the bomb.");
                    EffectClear(GetObjectIndexByName(aIndex));

                else

                    NoticeSend(aIndex, 1, "[SYSTEM]: Voce morreu e foi movido para base.");
                    NoticeSend(aIndex, 1, "[SYSTEM]: You died!.");

                end

                --SkinChangeSend(aIndex, 404);

            end

            evWOB_FuncsTable.MoveUser(aIndex, y);
            
            EffectAdd(aIndex, 1, 65, 5, 0, 0, 0, 0);

        end

    end

end

function evWOB_FuncsTable.State(iType)

    if (iType == 2) then
    
        evWOB_SystemTable.Stage = 2;
        evWOB_SystemTable.Count = 0;
        
    elseif (iType == 3) then

        evWOB_FuncsTable.NoticeUsers(0, ". : [ WORLD OF BOMBS ] : .");        
        evWOB_FuncsTable.NoticeUsers(0, "STAGE 1"); 
        evWOB_FuncsTable.NoticeUsers(0, "TIME: "..(evWOB_ConfigTable.Limit_Timer*60).." SECONDS."); 

        evWOB_SystemTable.mIndex[1] = MonsterCreate(evWOB_ConfigTable.bNPC_Index, evWOB_ConfigTable.Map, evWOB_ConfigTable.bNPC_CordXY[1], evWOB_ConfigTable.bNPC_CordXY[2], evWOB_ConfigTable.bNPC_Dir);
        evWOB_SystemTable.mIndex[2] = MonsterCreate(evWOB_ConfigTable.nNPC_Index, evWOB_ConfigTable.Map, evWOB_ConfigTable.nNPC_CordXY[1], evWOB_ConfigTable.nNPC_CordXY[2], evWOB_ConfigTable.nNPC_Dir);

        local aleatory = math.random(1,2);

        while (#evWOB_SystemTable.vName > 0) do

            if (aleatory == 1) then

                table.insert(evWOB_SystemTable.sName_T1, evWOB_SystemTable.vName[1]);
                table.insert(evWOB_SystemTable.iBomb_T1, 0);
                table.insert(evWOB_SystemTable.iScore_T1, 0);
                --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[#evWOB_SystemTable.sName_T1]), 405);
                table.remove(evWOB_SystemTable.vName, 1);
                aleatory = 2;

            elseif (aleatory == 2) then

                table.insert(evWOB_SystemTable.sName_T2, evWOB_SystemTable.vName[1]);
                table.insert(evWOB_SystemTable.iBomb_T2, 0);
                table.insert(evWOB_SystemTable.iScore_T2, 0);
                --SkinChangeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[#evWOB_SystemTable.sName_T2]), 404);
                table.remove(evWOB_SystemTable.vName, 1);
                aleatory = 1;

            end

        end

        evWOB_SystemTable.Count  = 0;
        evWOB_SystemTable.Stage  = 3;
        evWOB_SystemTable.vNexus = evWOB_ConfigTable.NexusLife;

        evWOB_FuncsTable.MoveAll();

    elseif (iType == 4) then

        for x = 1, #evWOB_SystemTable.sName_T1 do

            EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x]));
            evWOB_SystemTable.iBomb_T1[x] = 0;

        end

        evWOB_FuncsTable.NoticeUsers(0, ". : [ WORLD OF BOMBS ] : .");        
        evWOB_FuncsTable.NoticeUsers(0, "STAGE 2.");  
        evWOB_FuncsTable.NoticeUsers(0, "TIME: "..evWOB_SystemTable.Count.." SECONDS.");  
        
        evWOB_SystemTable.vTemp  = evWOB_SystemTable.Count;
        evWOB_SystemTable.Count  = 0;
        evWOB_SystemTable.Stage  = 4;
        evWOB_SystemTable.vNexus = evWOB_ConfigTable.NexusLife;
        
        evWOB_FuncsTable.iFuse();
        evWOB_FuncsTable.MoveAll();

    elseif (iType == 5) then

        for x = 1, #evWOB_SystemTable.sName_T2 do

            EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x]));

        end

        MonsterDelete(evWOB_SystemTable.mIndex[1]);
        MonsterDelete(evWOB_SystemTable.mIndex[2]);

        evWOB_FuncsTable.iFuse();
        evWOB_FuncsTable.Manipulation(2);

    end

end

function evWOB_FuncsTable.Manipulation(iType)

    if (iType == 1) then

        evWOB_SystemTable = {
            Stage         =  0,
            Count         =  0,
            vTemp         =  0,
            vNexus        =  0,
            vCount        =  0,

            table.remove(evWOB_SystemTable.sName_T1,  1);
            table.remove(evWOB_SystemTable.iBomb_T1,  1);


end

function evWOB_FuncsTable.GetUser(aIndex)

    local vIndex = 0;

    if (evWOB_SystemTable.Stage == 2) then

        for x = 1, #evWOB_SystemTable.vName do

            if (GetObjectIndexByName(evWOB_SystemTable.vName[x]) == aIndex) then

                vIndex = x;

                break;

            end

        end

        return vIndex;

    else

        local t = 0;

        for t1 = 1, #evWOB_SystemTable.sName_T1  do

            if (GetObjectIndexByName(evWOB_SystemTable.sName_T1[t1]) == aIndex) then

                vIndex = t1;
                t      = 1;

                break;

            end

        end

        for t2 = 1, #evWOB_SystemTable.sName_T2 do

            if (GetObjectIndexByName(evWOB_SystemTable.sName_T2[t2]) == aIndex) then

                vIndex = t2;
                t      =  2;

                break;

            end

        end

        return vIndex, t;

    end

end

function evWOB_FuncsTable.MoveAll()

    if (evWOB_SystemTable.Stage == 3) then

        for t1 = 1, #evWOB_SystemTable.sName_T1 do

            local aIndex   = GetObjectIndexByName(evWOB_SystemTable.sName_T1[t1]);
            local aleatory = math.random(1, 99999);

            aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX1);

            MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX1[aleatory], evWOB_ConfigTable.vRespawn_CY1[aleatory]);
            EffectAdd(aIndex, 1, 65, 10, 0, 0, 0, 0);

        end

        for t2 = 1, #evWOB_SystemTable.sName_T2 do

            local aIndex = GetObjectIndexByName(evWOB_SystemTable.sName_T2[t2]);
            local aleatory = math.random(1, 99999);

            aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX2);

            MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX2[aleatory], evWOB_ConfigTable.vRespawn_CY2[aleatory]);
            EffectAdd(aIndex, 1, 65, 10, 0, 0, 0, 0);

        end

    elseif (evWOB_SystemTable.Stage == 4) then

        for t1 = 1, #evWOB_SystemTable.sName_T1 do

            local aIndex   = GetObjectIndexByName(evWOB_SystemTable.sName_T1[t1]);
            local aleatory = math.random(1, 99999);

            aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX2);

            MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX2[aleatory], evWOB_ConfigTable.vRespawn_CY2[aleatory]);
            EffectAdd(aIndex, 1, 65, 10, 0, 0, 0, 0);

        end

        for t2 = 1, #evWOB_SystemTable.sName_T2 do

            local aIndex = GetObjectIndexByName(evWOB_SystemTable.sName_T2[t2]);
            local aleatory = math.random(1, 99999);

            aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX1);

            MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX1[aleatory], evWOB_ConfigTable.vRespawn_CY1[aleatory]);
            EffectAdd(aIndex, 1, 65, 10, 0, 0, 0, 0);

        end

    end

end

function evWOB_FuncsTable.MoveUser(aIndex, aTeam)

    if (evWOB_SystemTable.Stage == 2) then

        MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vCordXY[1], evWOB_ConfigTable.vCordXY[2]);
        PermissionRemove(aIndex, 12);

    elseif (evWOB_SystemTable.Stage > 2) then

        if (aTeam == 1) then

            if (evWOB_SystemTable.Stage == 3) then

                local aleatory = math.random(1, 99999);

                aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX1);

                MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX1[aleatory], evWOB_ConfigTable.vRespawn_CY1[aleatory]);

            elseif (evWOB_SystemTable.Stage == 4) then

                local aleatory = math.random(1, 99999);

                aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX2);

                MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX2[aleatory], evWOB_ConfigTable.vRespawn_CY2[aleatory]);

            end
            
            PermissionRemove(aIndex, 12);

        elseif (aTeam == 2) then

            if (evWOB_SystemTable.Stage == 3) then

                local aleatory = math.random(1, 99999);

                aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX2);

                MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX2[aleatory], evWOB_ConfigTable.vRespawn_CY2[aleatory]);

            elseif (evWOB_SystemTable.Stage == 4) then

                local aleatory = math.random(1, 99999);

                aleatory = math.random(1, #evWOB_ConfigTable.vRespawn_CX1);

                MoveUserEx(aIndex, evWOB_ConfigTable.Map, evWOB_ConfigTable.vRespawn_CX1[aleatory], evWOB_ConfigTable.vRespawn_CY1[aleatory]);
                
            end

            PermissionRemove(aIndex, 12);

        end

    end

end

function evWOB_FuncsTable.NoticeUsers(aType, aString)

    if (evWOB_SystemTable.Stage == 2) then
    
        if (aType == 0) then

            for x = 1, #evWOB_SystemTable.vName do

                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.vName[x]), 0, aString);

            end

        elseif (aType == 1) then

            for x = 1, #evWOB_SystemTable.vName do
            
                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.vName[x]), 1, "[SYSTEM]: "..aString);

            end

        end

    else

        if (aType == 0) then

            for x1 = 1, #evWOB_SystemTable.sName_T1 do

                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]), 0, aString);

            end

            for x2 = 1, #evWOB_SystemTable.sName_T2 do

                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x2]), 0, aString);

            end


        else

            for x1 = 1, #evWOB_SystemTable.sName_T1 do

                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]), 1, "[SYSTEM]: "..aString);

            end

            for x2 = 1, #evWOB_SystemTable.sName_T2 do

                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x2]), 1, "[SYSTEM]: "..aString);

            end


        end

    end

end

function evWOB_FuncsTable.Score(x1, y1, x2, y2)

    local x1 = x1;
    local y1 = y1;
    local x2 = x2; 
    local y2 = y2;

    if (evWOB_SystemTable.Stage == 3) then

        if (y1 == 1) then

            evWOB_SystemTable.iScore_T1[x1] = evWOB_SystemTable.iScore_T1[x1] + evWOB_ConfigTable.nKill_Score;
            
            NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.nKill_Score.." points. TOTAL: "..evWOB_SystemTable.iScore_T1[x1]..".");

        else

            if (evWOB_SystemTable.iBomb_T1[x2] == 1) then

                if (evWOB_SystemTable.sName_T1[x2] == evWOB_SystemTable.iFuse) then

                    evWOB_SystemTable.iScore_T2[x1] = evWOB_SystemTable.iScore_T2[x1] + evWOB_ConfigTable.ScoreDefend;
                    evWOB_SystemTable.iBomb_T1[x2]  = 0;

                    EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x2]));

                    NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.ScoreDefend.." points. TOTAL: "..evWOB_SystemTable.iScore_T2[x1]..".");
                    
                    evWOB_FuncsTable.NoticeUsers(1, evWOB_SystemTable.sName_T2[x1].." impediu "..evWOB_SystemTable.sName_T1[x2].." de armar a bomba matando-o(a).");
                    evWOB_FuncsTable.NoticeUsers(1, evWOB_SystemTable.sName_T2[x1].." prevent "..evWOB_SystemTable.sName_T1[x2].." to set up the bomb.");

                else

                    evWOB_SystemTable.iScore_T2[x1] = evWOB_SystemTable.iScore_T2[x1] + evWOB_ConfigTable.eKill_Score;
                    evWOB_SystemTable.iBomb_T1[x2]  = 0;

                    EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x2]));

                    NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.eKill_Score.." points. TOTAL: "..evWOB_SystemTable.iScore_T2[x1]..".");

                end

            else

                evWOB_SystemTable.iScore_T2[x1] = evWOB_SystemTable.iScore_T2[x1] + evWOB_ConfigTable.nKill_Score;

                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.nKill_Score.." points. TOTAL: "..evWOB_SystemTable.iScore_T2[x1]..".");

            end

        end

    elseif (evWOB_SystemTable.Stage == 4) then

        if (y1 == 1) then

            if (evWOB_SystemTable.iBomb_T2[x2] == 1) then

                if (evWOB_SystemTable.sName_T2[x2] == evWOB_SystemTable.iFuse) then

                    evWOB_SystemTable.iScore_T1[x1] = evWOB_SystemTable.iScore_T1[x1] + evWOB_ConfigTable.ScoreDefend;
                    evWOB_SystemTable.iBomb_T2[x2]  = 0;

                    EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x2]));

                    NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.ScoreDefend.." points. TOTAL: "..evWOB_SystemTable.iScore_T1[x1]..".");

                    evWOB_FuncsTable.NoticeUsers(1, evWOB_SystemTable.sName_T1[x1].." impediu "..evWOB_SystemTable.sName_T2[x2].." de armar a bomba matando-o(a).");
                    evWOB_FuncsTable.NoticeUsers(1, evWOB_SystemTable.sName_T1[x1].." prevent "..evWOB_SystemTable.sName_T2[x2].." to set up the bomb.");

                else

                    evWOB_SystemTable.iScore_T1[x1] = evWOB_SystemTable.iScore_T1[x1] + evWOB_ConfigTable.eKill_Score;
                    evWOB_SystemTable.iBomb_T2[x2]  = 0;

                    EffectClear(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x2]));

                    NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.eKill_Score.." points. TOTAL: "..evWOB_SystemTable.iScore_T1[x1]..".");

                end

            else

                evWOB_SystemTable.iScore_T1[x1] = evWOB_SystemTable.iScore_T1[x1] + evWOB_ConfigTable.nKill_Score;
                NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.nKill_Score.." points. TOTAL: "..evWOB_SystemTable.iScore_T1[x1]..".");

            end

        else

            evWOB_SystemTable.iScore_T2[x1] = evWOB_SystemTable.iScore_T2[x1] + evWOB_ConfigTable.nKill_Score;
            NoticeSend(GetObjectIndexByName(evWOB_SystemTable.sName_T2[x1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.nKill_Score.." points. TOTAL: "..evWOB_SystemTable.iScore_T2[x1]..".");

        end

    end

end

function evWOB_FuncsTable.iFuse()

    local x, y = evWOB_FuncsTable.GetUser(GetObjectIndexByName(evWOB_SystemTable.iFuse))
    
    EffectClear(GetObjectIndexByName(evWOB_SystemTable.iFuse));

    evWOB_SystemTable.iFuse  = "";
    evWOB_SystemTable.iClick =  0;
    evWOB_SystemTable.iTemp  =  0;

    evWOB_SystemTable.iCordXY[1]  =  0;
    evWOB_SystemTable.iCordXY[2]  =  0;  

end

function evWOB_FuncsTable.Ranking()

    local T1  = {
        Name  = {"","",""},
        Score = {0,0,0}
    }

    local T2  = {
        Name  = {"","",""},
        Score = {0,0,0}
    }

    for n=1,#evWOB_SystemTable.iScore_T1,1 do

        if (evWOB_SystemTable.iScore_T1[n] >= T1.Score[1]) then

			T1.Score[3] = T1.Score[2];
            T1.Score[2] = T1.Score[1];
            T1.Score[1] = evWOB_SystemTable.iScore_T1[n];

            T1.Name[3]  = T1.Name[2];
            T1.Name[2]  = T1.Name[1];
            T1.Name[1]  = evWOB_SystemTable.sName_T1[n];
            
		elseif evWOB_SystemTable.iScore_T1[n] >= T1.Score[2] then

            T1.Score[3] = T1.Score[2];
            T1.Score[2] = evWOB_SystemTable.iScore_T1[n];

            T1.Name[3]  = T1.Name[2];
            T1.Name[2]  = evWOB_SystemTable.sName_T1[n];

		elseif evWOB_SystemTable.iScore_T1[n] >= T1.Score[3] then

            T1.Score[3] = evWOB_SystemTable.iScore_T1[n];
            T1.Name[3]  = evWOB_SystemTable.sName_T1[n];

        end

    end  

    for z=1,#evWOB_SystemTable.iScore_T2,1 do

        if (evWOB_SystemTable.iScore_T2[z] >= T2.Score[1]) then

            T2.Score[3] = T2.Score[2];
            T2.Score[2] = T2.Score[1];
            T2.Score[1] = evWOB_SystemTable.iScore_T2[z];

            T2.Name[3]  = T2.Name[2];
            T2.Name[2]  = T2.Name[1];
            T2.Name[1]  = evWOB_SystemTable.sName_T2[z];
            
        elseif evWOB_SystemTable.iScore_T2[z] >= T2.Score[2] then

            T2.Score[3] = T2.Score[2];
            T2.Score[2] = evWOB_SystemTable.iScore_T2[z];

            T2.Name[3]  = T2.Name[2];
            T2.Name[2]  = evWOB_SystemTable.sName_T2[z];

        elseif evWOB_SystemTable.iScore_T2[z] >= T2.Score[3] then

            T2.Score[3] = evWOB_SystemTable.iScore_T2[z];
            T2.Name[3]  = evWOB_SystemTable.sName_T2[z];

        end

    end

    return T1, T2;

end

function evWOB_FuncsTable.Reward(vType)
    if (vType == 1) then

        NoticeSendToAll(0, ". : [ WORLD OF BOMBS ] : .");
        NoticeSendToAll(0, "EVENTO CLOSED, WINNER TEAM: "..evWOB_ConfigTable.vName_E1..".");
        LogPrint("[WORLD_OF_BOMBS]: EVENTO ENCERRADO, VITORIA DA EQUIPE "..evWOB_ConfigTable.vName_E1..".");

    else

        NoticeSendToAll(0, ". : [ WORLD OF BOMBS ] : .");
        NoticeSendToAll(0, "EVENT CLOSED, WINNER TEAM: "..evWOB_ConfigTable.vName_E2..".");
        LogPrint("[WORLD_OF_BOMBS]: EVENTO ENCERRADO, VITORIA DA EQUIPE "..evWOB_ConfigTable.vName_E2..".");

    end

    local T1, T2 = evWOB_FuncsTable.Ranking();

    if (T1.Name[1] ~= "") then

        evWOB_FuncsTable.RewardS4(GetObjectIndexByName(T1.Name[1]), evWOB_ConfigTable.vReward_Bonus1);
        NoticeSend(GetObjectIndexByName(T1.Name[1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_Bonus1.." "..evWOB_ConfigTable.nReward_Bonus1.." 1 rank.");
    
    end

    if (T2.Name[1] ~= "") then

        evWOB_FuncsTable.RewardS4(GetObjectIndexByName(T2.Name[1]), evWOB_ConfigTable.vReward_Bonus1);
        NoticeSend(GetObjectIndexByName(T2.Name[1]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_Bonus1.." "..evWOB_ConfigTable.nReward_Bonus1.." 1 rank");
    
    end

    if (T1.Name[2] ~= "") then

        evWOB_FuncsTable.RewardS4(GetObjectIndexByName(T1.Name[2]), evWOB_ConfigTable.vReward_Bonus2);
        NoticeSend(GetObjectIndexByName(T1.Name[2]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_Bonus2.." "..evWOB_ConfigTable.nReward_Bonus2.." 2 rank");
    
    end
    
    if (T2.Name[2] ~= "") then

        evWOB_FuncsTable.RewardS4(GetObjectIndexByName(T2.Name[2]), evWOB_ConfigTable.vReward_Bonus2);
        NoticeSend(GetObjectIndexByName(T2.Name[2]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_Bonus2.." "..evWOB_ConfigTable.nReward_Bonus2.." 2 rank");
    
    end

    if (T1.Name[3] ~= "") then

        evWOB_FuncsTable.RewardS4(GetObjectIndexByName(T1.Name[3]), evWOB_ConfigTable.vReward_Bonus3);
        NoticeSend(GetObjectIndexByName(T1.Name[3]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_Bonus3.." "..evWOB_ConfigTable.nReward_Bonus3.." 3 rank");
    
    end

    if (T2.Name[3] ~= "") then

        evWOB_FuncsTable.RewardS4(GetObjectIndexByName(T2.Name[3]), evWOB_ConfigTable.vReward_Bonus3);
        NoticeSend(GetObjectIndexByName(T2.Name[3]), 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_Bonus3.." "..evWOB_ConfigTable.nReward_Bonus3.." 3 rank");
    
    end

    for x1 = 1, #evWOB_SystemTable.sName_T1 do

        local aIndex = GetObjectIndexByName(evWOB_SystemTable.sName_T1[x1]);

        if (vType == 1) then

            evWOB_FuncsTable.RewardS4(aIndex, evWOB_ConfigTable.vReward_BonusW);
            NoticeSend(aIndex, 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_BonusW.." "..evWOB_ConfigTable.nReward_BonusW.." TO WIN");

        else

            evWOB_FuncsTable.RewardS4(aIndex, evWOB_ConfigTable.vReward_BonusL);
            NoticeSend(aIndex, 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_BonusL.." "..evWOB_ConfigTable.nReward_BonusL.." TO LOOSE");

        end

    end

    for x2 = 1, #evWOB_SystemTable.sName_T2 do

        local aIndex = GetObjectIndexByName(evWOB_SystemTable.sName_T2[x2]);

        if (vType == 2) then

            evWOB_FuncsTable.RewardS4(aIndex, evWOB_ConfigTable.vReward_BonusW);
            NoticeSend(aIndex, 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_BonusW.." "..evWOB_ConfigTable.nReward_BonusW.." TO WIN");

        else

            evWOB_FuncsTable.RewardS4(aIndex, evWOB_ConfigTable.vReward_BonusL);
            NoticeSend(aIndex, 1, "[SYSTEM]: BONUS "..evWOB_ConfigTable.vReward_BonusL.." "..evWOB_ConfigTable.nReward_BonusL.." TO LOOSE");

        end

    end

end


function evWOB_FuncsTable.RewardS4(aIndex, aValue) 

    SQLQuery("UPDATE MEMB_INFO SET gold = gold +"..aValue.." WHERE memb___id = '"..GetObjectAccount(aIndex).."'");
    SQLClose();

end