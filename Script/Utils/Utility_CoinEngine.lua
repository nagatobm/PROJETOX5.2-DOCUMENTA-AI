--[[
    Script_Tester.lua
    Teste de Comandos (Modelo Clássico por ID)
    Requer: Ferramentas.lua
]]

BridgeFunctionAttach("OnReadScript", "Teste_ReadScript")
BridgeFunctionAttach("OnCommandManager", "Teste_CommandManager")

-- ==============================================================================
-- 1. CONFIGURAÇÃO (IDs do CommandManager.txt)
-- ==============================================================================

local Config = {
    Saldo   = 114,
    Dar     = 115,
    Remover = 116
}

function Teste_ReadScript()
    if Utils then 
        Utils.Log("[Tester] IDs Carregados: 114, 115, 116", 4) 
    end
end

-- ==============================================================================
-- 2. DISPATCHER (Lógica dos Comandos)
-- ==============================================================================

function Teste_CommandManager(aIndex, code, arg)
    
    -- [COMANDO 1] SALDO (ID 114)
    if code == Config.Saldo then
        local player = Utils.GetPlayer(aIndex)
        
        -- Busca saldo no banco
        local gold = DataBase.GetNumberByString("MEMB_INFO", "gold", "memb___id", player:getAccountID())
        local cash = DataBase.GetNumberByString("MEMB_INFO", "cash", "memb___id", player:getAccountID())
        
        NoticeSend(aIndex, 1, string.format("Ola %s, seu saldo atual:", player:getName()))
        NoticeSend(aIndex, 0, string.format("Gold: %d | Cash: %d", gold, cash))
        return 1
    
    -- [COMANDO 2] DAR (ID 115)
    elseif code == Config.Dar then
        local args = string.split(arg, " ")
        local tipo = string.upper(args[1] or "")
        local qtd  = tonumber(args[2] or 0)
        
        -- Validação
        if qtd > 0 and Utility_Master.Map[tipo] then
            -- Adiciona moeda
            Utility_Master.AddCoin(Utils.GetPlayer(aIndex), tipo, qtd, 1)
            Utils.Log("Admin adicionou " .. qtd .. " " .. tipo, 3)
        else
            NoticeSend(aIndex, 1, "Uso: /dar <GOLD/CASH> <QTD>")
        end
        return 1

    -- [COMANDO 3] REMOVER (ID 116)
    elseif code == Config.Remover then
        local args = string.split(arg, " ")
        local tipo = string.upper(args[1] or "")
        local qtd  = tonumber(args[2] or 0)
        local player = Utils.GetPlayer(aIndex)

        if qtd > 0 and Utility_Master.Map[tipo] then
            local info = Utility_Master.Map[tipo]
            local target = (info.IdType == 1) and player:getName() or player:getAccountID()
            
            -- Remove direto no banco
            DataBase.SetAddValue(info.Table, info.Column, -qtd, info.Where, target)
            NoticeSend(aIndex, 1, string.format("Removido %d %s com sucesso.", qtd, tipo))
        else
            NoticeSend(aIndex, 1, "Uso: /remover <GOLD/CASH> <QTD>")
        end
        return 1
    end

    return 0
end