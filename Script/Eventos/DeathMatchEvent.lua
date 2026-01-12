--[[ 
    Death Match Event
    Created by: GitHub Copilot
    Modified: 08/15/2024
]]

-- Attach event functions
BridgeFunctionAttach("OnReadScript", "DeathMatch_ReadScript")
BridgeFunctionAttach("OnShutScript", "DeathMatch_ShutScript")
BridgeFunctionAttach("OnTimerThread", "DeathMatch_TimerThread")
BridgeFunctionAttach("OnCommandManager", "DeathMatch_CommandManager")
BridgeFunctionAttach("OnCommandDone", "DeathMatch_CommandDone")
BridgeFunctionAttach("OnCharacterEntry", "DeathMatch_CharacterEntry")
BridgeFunctionAttach("OnCharacterClose", "DeathMatch_CharacterClose")
BridgeFunctionAttach("OnUserDie", "DeathMatch_UserDie")
BridgeFunctionAttach("OnUserRespawn", "DeathMatch_UserRespawn")
BridgeFunctionAttach("OnCheckUserTarget", "DeathMatch_CheckUserTarget")
BridgeFunctionAttach("OnCheckUserKiller", "DeathMatch_CheckUserKiller")
BridgeFunctionAttach("OnUserMove", "DeathMatch_UserMove") -- Adiciona verificação de movimento

local SYSTEM_MAIN = {}
local SYSTEM_CONFIG = {}

function DeathMatch_ReadScript()
    -- Configurations of the event
    SYSTEM_CONFIG.Timer = { "11:13:00", "20:00:00" } -- Event start times
    SYSTEM_CONFIG.TimerAlert = 2 -- Alert time in minutes
    SYSTEM_CONFIG.MaxUsers = 30
    SYSTEM_CONFIG.MinUsers = 2
    SYSTEM_CONFIG.Map = 6 -- Arena map
    SYSTEM_CONFIG.CordXY = { 64, 47 } -- Center coordinates for arena
    SYSTEM_CONFIG.nmCommandEntry = "/JoinDM" -- Command to join event
    SYSTEM_CONFIG.cdCommandEntry = 130 -- Command ID
    SYSTEM_CONFIG.EventDuration = 180 -- 3 minutes in seconds antes era 600
    SYSTEM_CONFIG.RespawnEnabled = true -- Allow respawns in this event
    SYSTEM_CONFIG.RespawnDelay = 5 -- Seconds before respawn
    SYSTEM_CONFIG.PointsPerKill = 10 -- Points awarded per kill
    
    -- Teleport configurations
    SYSTEM_CONFIG.StartMap = 0 -- Map to teleport players from before the event starts
    SYSTEM_CONFIG.StartMapXY = { 130, 130 } -- Coordinates for teleport before event
    SYSTEM_CONFIG.EndMap = 0 -- Map to teleport players to after the event ends
    SYSTEM_CONFIG.EndMapXY = { 140, 140 } -- Coordinates for teleport after event
    
    -- Rewards configuration
    SYSTEM_CONFIG.Rewards = {
        {Position = 1, ItemIndex = 14, ItemLevel = 12, ItemDurability = 0}, -- 1st place
        {Position = 2, ItemIndex = 14, ItemLevel = 0, ItemDurability = 0}, -- 2nd place
        {Position = 3, ItemIndex = 14, ItemLevel = 0, ItemDurability = 0}, -- 3rd place
    }

    -- Inicializa a tabela de ex-participantes
    SYSTEM_MAIN.FormerParticipants = {}

	-- Marca que a configuração foi carregada (usado no TimerThread para evitar nil)
	SYSTEM_MAIN.ConfigLoaded = true
    
    LogColor(3, "[DEATHMATCH]: Configuration loaded successfully!")
end

function DeathMatch_ShutScript()
    if SYSTEM_MAIN.Stage then
        DeathMatch_Finalize(2) -- Finalize with cancel reason
    end
    LogColor(3, "[DEATHMATCH]: Script shut down successfully.")
end

function DeathMatch_TimerThread()
    -- Alguns cores chamam OnTimerThread antes de OnReadScript; garante config.
    if not SYSTEM_MAIN.ConfigLoaded then
        local ok = pcall(DeathMatch_ReadScript)
        if not ok then
            -- Se falhar, não derruba o timer.
            return
        end
    end
    if type(SYSTEM_CONFIG.Timer) ~= 'table' then
        return
    end

    if not SYSTEM_MAIN.Stage then
        for _, timer in ipairs(SYSTEM_CONFIG.Timer) do
            if os.date("%X") == timer then
                DeathMatch_StartRegistration()  -- Renamed function
                break
            end
        end
    elseif SYSTEM_MAIN.Stage == 1 then
        DeathMatch_ManageRegistration()  -- Renamed function
    elseif SYSTEM_MAIN.Stage == 2 then
        DeathMatch_ManageBattlePhase()  -- Renamed function
    end

    -- Verifica se é hora de limpar a lista de ex-participantes
    if SYSTEM_MAIN.CleanupTime then
        DeathMatch_CheckFormerParticipantsCleanup()  -- Renamed function
    end
    
    -- Check for players that need to respawn after delay
    if SYSTEM_MAIN.Stage == 2 then
        DeathMatch_CheckPlayersOutsideArena()  -- Renamed function
        DeathMatch_CheckDelayedRespawns()  -- Renamed function
    end
end

function DeathMatch_StartRegistration()
    SYSTEM_MAIN.Stage = 1
    SYSTEM_MAIN.UserCount = 0
    SYSTEM_MAIN.Count = 0
    SYSTEM_MAIN.Users = {}
    SYSTEM_MAIN.TimerAlert = SYSTEM_CONFIG.TimerAlert
    SYSTEM_MAIN.EventFinalized = false
    
    LogColor(3, "[DEATHMATCH]: Registration period started.")
    NoticeSendToAll(0, ".:: [ DEATH MATCH ]::. ")
    NoticeSendToAll(0, "Registration is now open! Type " .. SYSTEM_CONFIG.nmCommandEntry .. " to join!")
end

function DeathMatch_ManageRegistration()
    SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1
    if SYSTEM_MAIN.Count % 60 == 0 then  -- Every minute
        if SYSTEM_MAIN.TimerAlert == 0 then
            if #SYSTEM_MAIN.Users >= SYSTEM_CONFIG.MinUsers then
                DeathMatch_StartEvent()
            else
                DeathMatch_CancelEvent()
            end
        else
            DeathMatch_AlertEventStart()
            SYSTEM_MAIN.TimerAlert = SYSTEM_MAIN.TimerAlert - 1
        end
    end
end

function DeathMatch_StartEvent()
    SYSTEM_MAIN.Stage = 2
    SYSTEM_MAIN.Count = 0
    SYSTEM_MAIN.EventEndTime = os.time() + SYSTEM_CONFIG.EventDuration

    NoticeSendToAll(0, ".:: [ DEATH MATCH ]::. ")
    NoticeSendToAll(0, "The battle has begun! Most kills wins!")
    LogColor(3, "[DEATHMATCH]: The event started with " .. #SYSTEM_MAIN.Users .. " participants.")

    for _, user in ipairs(SYSTEM_MAIN.Users) do
        -- Save user's original map and position for potential restoration later
        user.OriginalMap = GetObjectMap(user.Index)
        user.OriginalX = GetObjectMapX(user.Index)
        user.OriginalY = GetObjectMapY(user.Index)
        
        -- Initialize score for each player
        user.Score = 0
        
        -- First teleport players to the starting position
        local startX = SYSTEM_CONFIG.StartMapXY[1] + math.random(-3, 3)
        local startY = SYSTEM_CONFIG.StartMapXY[2] + math.random(-3, 3)
        MoveUserEx(user.Index, SYSTEM_CONFIG.StartMap, startX, startY)
        
        -- Wait a second for gathering all players
        NoticeSend(user.Index, 0, "[DeathMatch]: Preparing for battle...")
    end
    
    -- Set a timer to teleport everyone to the arena after a brief pause
    SYSTEM_MAIN.ArenaStartTime = os.time() + 3
    SYSTEM_MAIN.TeleportToArena = true
end

function DeathMatch_CancelEvent()
    NoticeSendToAll(0, ".:: [ DEATH MATCH ]::. ")
    NoticeSendToAll(0, "The event was canceled. Not enough participants.")
    
    for i = #SYSTEM_MAIN.Users, 1, -1 do
        local userIndex = SYSTEM_MAIN.Users[i].Index
        NoticeSend(userIndex, 1, "[DeathMatch]: Event canceled due to insufficient participants.")
        SYSTEM_MAIN.DelUser(userIndex)
    end

    resetEventVariables()
    LogColor(3, "[DEATHMATCH]: Event canceled due to lack of participants.")
end

function DeathMatch_AlertEventStart()
    NoticeSendToAll(0, ".:: [ DEATH MATCH ]::. ")
    NoticeSendToAll(0, "Event starts in " .. SYSTEM_MAIN.TimerAlert .. " minute(s). " .. 
                     "Current participants: " .. #SYSTEM_MAIN.Users .. "/" .. SYSTEM_CONFIG.MaxUsers)
end

function DeathMatch_ManageBattlePhase()
    local currentTime = os.time()
    
    -- Handle delayed teleport to arena at event start
    if SYSTEM_MAIN.TeleportToArena and currentTime >= SYSTEM_MAIN.ArenaStartTime then
        SYSTEM_MAIN.TeleportToArena = false
        
        for _, user in ipairs(SYSTEM_MAIN.Users) do
            -- Now teleport to the actual arena and enable combat
            DeathMatch_TeleportUserToArena(user.Index)
            
            -- Set PvP permissions
            --PermissionInsert(user.Index, 12)
            PermissionRemove(user.Index, 13) -- Allow attacks
            
            -- Ensure damage calculation works properly
            UserCalcAttribute(user.Index)
            
            -- Notify user
            NoticeSend(user.Index, 1, "[DeathMatch]: Event started! Your score: 0")
        end
    end
    
    if currentTime >= SYSTEM_MAIN.EventEndTime then
        DeathMatch_Finalize(1) -- Finalize normally due to time limit
    else
        local remainingTime = SYSTEM_MAIN.EventEndTime - currentTime
        
        -- Every minute, show time remaining and top players
        if remainingTime % 60 == 0 then
            NoticeSendToAll(0, "[DeathMatch]: " .. math.floor(remainingTime / 60) .. " minutes remaining!")
            
            -- Send current rankings to all participants
            DeathMatch_SendCurrentRankings()
        end
    end
end

function DeathMatch_SendCurrentRankings()
    -- Sort users by score
    local sortedUsers = {}
    for _, user in ipairs(SYSTEM_MAIN.Users) do
        table.insert(sortedUsers, {Index = user.Index, Score = user.Score})
    end
    
    table.sort(sortedUsers, function(a, b) return a.Score > b.Score end)
    
    -- Show top 3 to all participants
    SYSTEM_MAIN.Message(1, "[DeathMatch]: Current Rankings")
    
    for i = 1, math.min(3, #sortedUsers) do
        local user = sortedUsers[i]
        SYSTEM_MAIN.Message(1, i .. ". " .. GetObjectName(user.Index) .. ": " .. user.Score .. " pts")
    end
end

function DeathMatch_CommandManager(aIndex, code, arg)
    if code == SYSTEM_CONFIG.cdCommandEntry then
        if SYSTEM_MAIN.Stage and SYSTEM_MAIN.Stage == 1 then
            if SYSTEM_MAIN.GetUser(aIndex) ~= 0 then
                NoticeSend(aIndex, 1, "[DeathMatch]: You're already registered for this event!")
            else
                SYSTEM_MAIN.AddUser(aIndex)
            end
        else
            NoticeSend(aIndex, 1, "[DeathMatch]: Registration is currently closed.")
        end
        return 1
    end
    return 0
end

function DeathMatch_CommandDone(aIndex, code)
    if code == SYSTEM_CONFIG.cdCommandEntry then
        LogColor(3, "[DEATHMATCH]: Command executed by " .. GetObjectName(aIndex))
    end
end

function DeathMatch_CharacterEntry(aIndex)
    if SYSTEM_MAIN.Stage and SYSTEM_MAIN.Stage > 1 then
        local userIndex = SYSTEM_MAIN.GetUser(aIndex)
        if userIndex ~= 0 then
            DeathMatch_TeleportUserToArena(aIndex)
            LogColor(3, "[DEATHMATCH]: Player " .. GetObjectName(aIndex) .. " re-entered the event arena.")
        end
    elseif SYSTEM_MAIN.FormerParticipants and SYSTEM_MAIN.FormerParticipants[aIndex] then
        -- Se for um ex-participante reconectando, garantir que tenha permissões normais
        --PermissionInsert(aIndex, 12) -- Garante movimento
        PermissionRemove(aIndex, 13) -- Permite ataques
        UserCalcAttribute(aIndex)
        UserInfoSend(aIndex)
        LogColor(3, "[DEATHMATCH]: Ex-participante " .. GetObjectName(aIndex) .. " reconectou. Permissões restauradas.")
    end
end

function DeathMatch_CharacterClose(aIndex)
    if SYSTEM_MAIN.Stage and SYSTEM_MAIN.GetUser(aIndex) ~= 0 then
        SYSTEM_MAIN.DelUser(aIndex)
        SYSTEM_MAIN.Message(1, "[DeathMatch]: " .. GetObjectName(aIndex) .. " disconnected from the event.")
    end
end

function DeathMatch_UserDie(aIndex, aTargetIndex)
    if SYSTEM_MAIN.Stage == 2 then
        local victimIndex = SYSTEM_MAIN.GetUser(aIndex)
        local killerIndex = SYSTEM_MAIN.GetUser(aTargetIndex)
        
        if victimIndex ~= 0 and killerIndex ~= 0 then
            -- Update killer's score
            SYSTEM_MAIN.Users[killerIndex].Score = SYSTEM_MAIN.Users[killerIndex].Score + SYSTEM_CONFIG.PointsPerKill
            
            -- Notify players about the kill
            local killerName = GetObjectName(aTargetIndex)
            local victimName = GetObjectName(aIndex)
            local killerScore = SYSTEM_MAIN.Users[killerIndex].Score
            
            SYSTEM_MAIN.Message(1, "[DeathMatch]: " .. killerName .. " killed " .. victimName .. "! Score: " .. killerScore)
            
            -- If respawn is disabled, remove player from event
            if not SYSTEM_CONFIG.RespawnEnabled then
                SYSTEM_MAIN.DelUser(aIndex)
                NoticeSend(aIndex, 1, "[DeathMatch]: You've been eliminated from the event!")
            else
                NoticeSend(aIndex, 1, "[DeathMatch]: You died! Respawning in " .. SYSTEM_CONFIG.RespawnDelay .. " seconds.")
            end
        end
    end
end

function DeathMatch_UserRespawn(aIndex)
    if SYSTEM_MAIN.Stage == 2 and SYSTEM_CONFIG.RespawnEnabled then
        local userIndex = SYSTEM_MAIN.GetUser(aIndex)
        if userIndex ~= 0 then
            -- Add a small delay before respawn
            LogColor(3, "[DEATHMATCH]: Player " .. GetObjectName(aIndex) .. " respawning...")
            
            -- We schedule the teleport after a delay
            -- Since we can't actually delay the respawn itself, we'll teleport after respawn
            SYSTEM_MAIN.Users[userIndex].RespawnTime = os.time() + SYSTEM_CONFIG.RespawnDelay
        end
    end
    
    -- In the next timer tick, players with respawn time set will be teleported back to arena
    -- after the delay has passed
end

function DeathMatch_CheckUserTarget(aIndex, bIndex)
    -- If both players are event participants, allow PvP
    local aIsParticipant = SYSTEM_MAIN.GetUser(aIndex) ~= 0
    local bIsParticipant = SYSTEM_MAIN.GetUser(bIndex) ~= 0
    
    -- If the event is running and both players are participants, allow PvP between them
    if SYSTEM_MAIN.Stage == 2 and aIsParticipant and bIsParticipant then
        return 1 -- Allow PvP between participants
    end
    
    -- If one player is participant and the other isn't, disable PvP between them
    if aIsParticipant ~= bIsParticipant then
        return 0 -- Prevent PvP between participants and non-participants
    end
    
    -- For non-participants, return 1 to allow normal PvP rules
    return 1
end

function DeathMatch_CheckUserKiller(aIndex, bIndex)
    -- If we're in battle phase and both players are participants, 
    -- don't apply PK status for kills in the event
    if SYSTEM_MAIN.Stage == 2 then
        local aIsParticipant = SYSTEM_MAIN.GetUser(aIndex) ~= 0
        local bIsParticipant = SYSTEM_MAIN.GetUser(bIndex) ~= 0
        
        if aIsParticipant and bIsParticipant then
            return 0 -- Don't apply PK status
        end
    end
    
    -- For any other case, apply regular PK rules
    return 1
end

function DeathMatch_UserMove(aIndex, mapIndex)
    -- Verifica se o usuário é um participante do evento
    local userIndex = SYSTEM_MAIN.GetUser(aIndex)
    
    -- Se o jogador for participante e o evento estiver em andamento
    if SYSTEM_MAIN.Stage == 2 and userIndex ~= 0 then
        -- Verifica se está tentando sair do mapa do evento
        if mapIndex ~= SYSTEM_CONFIG.Map then
            -- Inicia contagem regressiva para retorno ao evento
            SYSTEM_MAIN.Users[userIndex].LeaveTime = os.time()
            SYSTEM_MAIN.Users[userIndex].OutsideMap = true
            
            -- Avisa ao jogador sobre o tempo para retornar
            NoticeSend(aIndex, 1, "[DeathMatch]: Você tem 30 segundos para voltar ao evento ou será desclassificado!")
            LogColor(3, "[DEATHMATCH]: Jogador " .. GetObjectName(aIndex) .. " saiu do mapa do evento, tempo para retorno iniciado.")
        elseif SYSTEM_MAIN.Users[userIndex].OutsideMap then
            -- Jogador voltou ao mapa do evento, cancela a contagem
            SYSTEM_MAIN.Users[userIndex].OutsideMap = false
            SYSTEM_MAIN.Users[userIndex].LeaveTime = nil
            NoticeSend(aIndex, 1, "[DeathMatch]: Bem-vindo de volta ao evento!")
            LogColor(3, "[DEATHMATCH]: Jogador " .. GetObjectName(aIndex) .. " retornou ao mapa do evento.")
        end
    elseif SYSTEM_MAIN.FormerParticipants and SYSTEM_MAIN.FormerParticipants[aIndex] then
        -- Verificando ex-participantes e garantindo que possam mover-se livremente
        LogColor(3, "[DEATHMATCH_DEBUG]: Ex-participante " .. GetObjectName(aIndex) .. " está movendo para mapa " .. mapIndex)
        
        -- Garante novamente que as permissões estão corretas
       -- PermissionInsert(aIndex, 12) -- Garante movimento
        PermissionRemove(aIndex, 13) -- Permite ataques
        UserCalcAttribute(aIndex)
        UserInfoSend(aIndex)
    end
    
    -- Permite sempre a mudança de mapa
    return 1
end

function DeathMatch_Finalize(reason)
    if SYSTEM_MAIN.EventFinalized then
        return  -- Se o evento já estiver finalizado, não faça nada
    end
    
    SYSTEM_MAIN.EventFinalized = true  -- Marca o evento como finalizado

    if reason == 1 then  -- Normal end (time limit)
        NoticeSendToAll(0, ".:: [ DEATH MATCH ]::. ")
        NoticeSendToAll(0, "The event has ended!")
        
        -- Sort users by score
        local sortedUsers = {}
        for _, user in ipairs(SYSTEM_MAIN.Users) do
            table.insert(sortedUsers, {Index = user.Index, Score = user.Score})
        end
        
        table.sort(sortedUsers, function(a, b) return a.Score > b.Score end)
        
        -- Announce top 3 players
        NoticeSendToAll(0, "Final Rankings:")
        
        for i = 1, math.min(3, #sortedUsers) do
            local user = sortedUsers[i]
            local playerName = GetObjectName(user.Index)
            NoticeSendToAll(0, i .. ". " .. playerName .. ": " .. user.Score .. " points")
            
            -- Give rewards to top players
            giveReward(user.Index, i)
        end
        
        LogColor(3, "[DEATHMATCH]: Event ended successfully.")
    elseif reason == 2 then -- Canceled
        NoticeSendToAll(0, ".:: [ DEATH MATCH ]::. ")
        NoticeSendToAll(0, "The event was canceled!")
        LogColor(3, "[DEATHMATCH]: Event canceled.")
    end

    -- Cria uma cópia da lista de usuários para evitar problemas ao iterar e remover
    local usersCopy = {}
    for i, user in ipairs(SYSTEM_MAIN.Users) do
        usersCopy[i] = {
            Index = user.Index,
            OriginalMap = user.OriginalMap or SYSTEM_CONFIG.EndMap,
            OriginalX = user.OriginalX or SYSTEM_CONFIG.EndMapXY[1],
            OriginalY = user.OriginalY or SYSTEM_CONFIG.EndMapXY[2]
        }
    end

    -- Restaura permissões e teleporta todos os jogadores para fora
    for _, user in ipairs(usersCopy) do
        local playerIndex = user.Index
        
        -- Restaura permissões normais
        --PermissionInsert(playerIndex, 12) -- Garante que o movimento está permitido
        PermissionRemove(playerIndex, 13) -- Garante que os ataques estão permitidos

        -- Recalcula atributos para garantir que todas as estatísticas sejam atualizadas
        UserCalcAttribute(playerIndex)
        UserInfoSend(playerIndex)
        
        -- Adiciona o jogador à lista de ex-participantes
        SYSTEM_MAIN.FormerParticipants[playerIndex] = true
        
        -- Determinar as coordenadas para teleporte
        local destMap = SYSTEM_CONFIG.EndMap
        local destX = SYSTEM_CONFIG.EndMapXY[1] + math.random(-5, 5)
        local destY = SYSTEM_CONFIG.EndMapXY[2] + math.random(-5, 5)
        
        -- Opcionalmente, usar as coordenadas originais se disponíveis
        if reason == 2 and user.OriginalMap and user.OriginalX and user.OriginalY then
            destMap = user.OriginalMap
            destX = user.OriginalX
            destY = user.OriginalY
        end
        
        -- Teleporta o jogador
        MoveUserEx(playerIndex, destMap, destX, destY)
        
        -- Notifica o usuário
        NoticeSend(playerIndex, 1, "[DeathMatch]: Você foi teleportado para fora do evento.")
        
        -- Debugando - registrar que as permissões foram restauradas
        LogColor(3, "[DEATHMATCH_DEBUG]: Permissões restauradas e jogador teleportado: " .. GetObjectName(playerIndex))
        
        -- Remove o jogador do evento (isso vai esvaziar a lista gradualmente)
        SYSTEM_MAIN.DelUser(playerIndex)
    end
    
    -- Definir tempo para limpar a lista de ex-participantes
    SYSTEM_MAIN.CleanupTime = os.time() + 300 -- 5 minutos depois
    
    -- Reset de variáveis
    resetEventVariables()
    
    -- Verifica se todos os jogadores foram removidos
    if #SYSTEM_MAIN.Users > 0 then
        LogColor(3, "[DEATHMATCH_ERROR]: Ainda restam " .. #SYSTEM_MAIN.Users .. " jogadores na lista do evento após finalização!")
    else
        LogColor(3, "[DEATHMATCH]: Todos os jogadores foram removidos com sucesso do evento.")
    end
end

function giveReward(userIndex, position)
    for _, reward in ipairs(SYSTEM_CONFIG.Rewards) do
        if reward.Position == position then
            ItemGiveEx(userIndex, reward.ItemIndex, reward.ItemLevel, reward.ItemDurability, 0, 0, 0, 0)
            NoticeSend(userIndex, 0, "[DeathMatch]: You've received a reward for position #" .. position .. "!")
            LogColor(3, "[DEATHMATCH]: Reward given to " .. GetObjectName(userIndex) .. " for position #" .. position)
            break
        end
    end
end

function resetEventVariables()
    SYSTEM_MAIN.Stage = nil
    SYSTEM_MAIN.Users = {}
    SYSTEM_MAIN.UserCount = 0
    SYSTEM_MAIN.Count = 0
    SYSTEM_MAIN.EventEndTime = nil
    SYSTEM_MAIN.EventFinalized = false
    SYSTEM_MAIN.TeleportToArena = false
    SYSTEM_MAIN.ArenaStartTime = nil
    
    -- NÃO resetamos FormerParticipants aqui
    -- Ao invés disso, agendamos uma limpeza após um tempo seguro
    SYSTEM_MAIN.CleanupTime = os.time() + 60 -- 1 minuto depois
end

function DeathMatch_CheckFormerParticipantsCleanup()
    if SYSTEM_MAIN.CleanupTime and os.time() >= SYSTEM_MAIN.CleanupTime then
        SYSTEM_MAIN.FormerParticipants = {}
        SYSTEM_MAIN.CleanupTime = nil
        LogColor(3, "[DEATHMATCH]: Lista de ex-participantes limpa com sucesso.")
    end
end

function DeathMatch_TeleportUserToArena(userIndex)
    local user = SYSTEM_MAIN.GetUserByIndex(userIndex)
    if user ~= 0 then
        -- Permitir temporariamente a mudança de mapa para o teleporte
        SYSTEM_MAIN.Users[user].AllowMapChange = true
        
        -- Teleport user to the Death Match arena with random position around center
        local x = SYSTEM_CONFIG.CordXY[1] + math.random(-15, 15)
        local y = SYSTEM_CONFIG.CordXY[2] + math.random(-15, 15)
        MoveUserEx(userIndex, SYSTEM_CONFIG.Map, x, y)
        
        -- Restaurar a restrição após o teleporte
        SYSTEM_MAIN.Users[user].AllowMapChange = false
        
        -- Force recalculation of user attributes after teleport to ensure damage works
        UserCalcAttribute(userIndex)
        UserInfoSend(userIndex)
    end
end

function SYSTEM_MAIN.AddUser(aIndex)
    if #SYSTEM_MAIN.Users >= SYSTEM_CONFIG.MaxUsers then
        NoticeSend(aIndex, 1, "[DeathMatch]: O evento está cheio. Tente novamente mais tarde!")
        return
    end

    SYSTEM_MAIN.Users[#SYSTEM_MAIN.Users + 1] = { 
        Index = aIndex, 
        Score = 0,
        OutsideMap = false,  -- Novo: para rastrear se está fora do mapa
        LeaveTime = nil      -- Novo: para rastrear quando saiu do mapa
    }
    NoticeSend(aIndex, 1, "[DeathMatch]: Você se registrou com sucesso no evento!")
    LogColor(3, "[DEATHMATCH]: Jogador " .. GetObjectName(aIndex) .. " registrado no evento.")
end

function SYSTEM_MAIN.DelUser(aIndex)
    local userIndex = SYSTEM_MAIN.GetUser(aIndex)
    if userIndex == 0 then return end

    table.remove(SYSTEM_MAIN.Users, userIndex)
    NoticeSend(aIndex, 1, "[DeathMatch]: You have been removed from the event.")
    LogColor(3, "[DEATHMATCH]: Player " .. GetObjectName(aIndex) .. " removed from the event.")
end

function SYSTEM_MAIN.GetUser(aIndex)
    for i, v in ipairs(SYSTEM_MAIN.Users) do
        if v.Index == aIndex then
            return i
        end
    end
    return 0
end

function SYSTEM_MAIN.GetUserByIndex(aIndex)
    for i, v in ipairs(SYSTEM_MAIN.Users) do
        if v.Index == aIndex then
            return i
        end
    end
    return 0
end

-- Function to send messages to all users
function SYSTEM_MAIN.Message(type, message)
    for _, user in ipairs(SYSTEM_MAIN.Users) do
        NoticeSend(user.Index, type, message)
    end
end

function DeathMatch_CheckPlayersOutsideArena()
    if SYSTEM_MAIN.Stage == 2 then
        local currentTime = os.time()
        
        for i = #SYSTEM_MAIN.Users, 1, -1 do
            local user = SYSTEM_MAIN.Users[i]
            -- Se o jogador está fora do mapa e passou o tempo limite
            if user.OutsideMap and user.LeaveTime and (currentTime - user.LeaveTime) > 30 then
                -- Avisa que o jogador foi desclassificado
                NoticeSend(user.Index, 1, "[DeathMatch]: Você foi desclassificado por ficar muito tempo fora do evento!")
                SYSTEM_MAIN.Message(1, "[DeathMatch]: " .. GetObjectName(user.Index) .. " foi desclassificado por sair do evento!")
                LogColor(3, "[DEATHMATCH]: Jogador " .. GetObjectName(user.Index) .. " desclassificado por tempo fora do evento.")
                
                -- Remove o jogador do evento
                SYSTEM_MAIN.DelUser(user.Index)
                
                -- Restaura permissões
               -- PermissionInsert(user.Index, 12) -- Garante que o movimento está permitido
                PermissionRemove(user.Index, 13) -- Garante que os ataques estão permitidos
                UserCalcAttribute(user.Index)
                UserInfoSend(user.Index)
            elseif user.OutsideMap and user.LeaveTime then
                -- Envia aviso do tempo restante a cada 10 segundos
                local timeLeft = 30 - (currentTime - user.LeaveTime)
                if timeLeft > 0 and timeLeft % 10 == 0 then
                    NoticeSend(user.Index, 1, "[DeathMatch]: Você tem " .. timeLeft .. " segundos para voltar ao evento!")
                end
            end
        end
    end
end

function DeathMatch_CheckDelayedRespawns()
    if SYSTEM_MAIN.Stage == 2 and SYSTEM_CONFIG.RespawnEnabled then
        local currentTime = os.time()
        
        for _, user in ipairs(SYSTEM_MAIN.Users) do
            if user.RespawnTime and currentTime >= user.RespawnTime then
                DeathMatch_TeleportUserToArena(user.Index)
                user.RespawnTime = nil
                
                -- Ensure movement is allowed after respawn
              --  PermissionInsert(user.Index, 12) -- Allow movement
                PermissionRemove(user.Index, 13) -- Allow attacks
                
                -- Recalculate attributes to ensure all stats are updated
                UserCalcAttribute(user.Index)
                UserInfoSend(user.Index)
                
                NoticeSend(user.Index, 1, "[DeathMatch]: You've been respawned! Get back in the fight!")
            end
        end
    end
end
