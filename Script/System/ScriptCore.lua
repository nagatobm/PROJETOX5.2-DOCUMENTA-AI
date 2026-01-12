--[[
    ScriptCore.lua
    MOTOR DE EVENTOS (BRIDGE SYSTEM)
    Responsável por conectar o GameServer ao Lua de forma segura.
]]

BridgeFunctionTable = {}

function BridgeFunctionAttach(BridgeName, FunctionName)
    if not BridgeFunctionTable[BridgeName] then 
        BridgeFunctionTable[BridgeName] = {} 
    end
    
    -- Evita duplicatas
    for _, func in ipairs(BridgeFunctionTable[BridgeName]) do
        if func.Function == FunctionName then 
            return 
        end
    end
    
    table.insert(BridgeFunctionTable[BridgeName], { Function = FunctionName })
end

-- ==============================================================================
-- DISPATCHERS (Executores de Eventos)
-- ==============================================================================

function BridgeFunction_OnReadScript()
    if BridgeFunctionTable["OnReadScript"] then 
        for _, f in ipairs(BridgeFunctionTable["OnReadScript"]) do 
            if _G[f.Function] then 
                _G[f.Function]() 
            end 
        end 
    end
end

function BridgeFunction_OnShutScript()
    if BridgeFunctionTable["OnShutScript"] then 
        for _, f in ipairs(BridgeFunctionTable["OnShutScript"]) do 
            if _G[f.Function] then 
                _G[f.Function]() 
            end 
        end 
    end
end

function BridgeFunction_OnTimerThread()
    if BridgeFunctionTable["OnTimerThread"] then 
        for _, f in ipairs(BridgeFunctionTable["OnTimerThread"]) do 
            if _G[f.Function] then 
                _G[f.Function]() 
            end 
        end 
    end
end

function BridgeFunction_OnCommandManager(aIndex, code, arg)
    if BridgeFunctionTable["OnCommandManager"] then
        for _, f in ipairs(BridgeFunctionTable["OnCommandManager"]) do
            if _G[f.Function] then
                -- Se retornar != 0, o comando foi tratado e para o loop
                if _G[f.Function](aIndex, code, arg) ~= 0 then 
                    return 1 
                end
            end
        end
    end
    return 0
end

function BridgeFunction_OnNpcTalk(aIndex, bIndex)
    if BridgeFunctionTable["OnNpcTalk"] then
        for _, f in ipairs(BridgeFunctionTable["OnNpcTalk"]) do
            if _G[f.Function] then
                if _G[f.Function](aIndex, bIndex) ~= 0 then 
                    return 1 
                end
            end
        end
    end
    return 0
end

-- Outros Eventos (Formatados)
function BridgeFunction_OnCharacterEntry(aIndex)
    if BridgeFunctionTable["OnCharacterEntry"] then 
        for _, f in ipairs(BridgeFunctionTable["OnCharacterEntry"]) do 
            if _G[f.Function] then _G[f.Function](aIndex) end 
        end 
    end
end

function BridgeFunction_OnCharacterClose(aIndex)
    if BridgeFunctionTable["OnCharacterClose"] then 
        for _, f in ipairs(BridgeFunctionTable["OnCharacterClose"]) do 
            if _G[f.Function] then _G[f.Function](aIndex) end 
        end 
    end
end

function BridgeFunction_OnUserDie(aIndex, bIndex)
    if BridgeFunctionTable["OnUserDie"] then 
        for _, f in ipairs(BridgeFunctionTable["OnUserDie"]) do 
            if _G[f.Function] then _G[f.Function](aIndex, bIndex) end 
        end 
    end
end

function BridgeFunction_OnMonsterDie(aIndex, bIndex)
    if BridgeFunctionTable["OnMonsterDie"] then 
        for _, f in ipairs(BridgeFunctionTable["OnMonsterDie"]) do 
            if _G[f.Function] then _G[f.Function](aIndex, bIndex) end 
        end 
    end
end

function BridgeFunction_OnUserMove(...)
    if BridgeFunctionTable["OnUserMove"] then 
        for _, f in ipairs(BridgeFunctionTable["OnUserMove"]) do 
            if _G[f.Function] then _G[f.Function](...) end 
        end 
    end
end

LogAddC(4, "[ScriptCore] Sistema Bridge Carregado.")