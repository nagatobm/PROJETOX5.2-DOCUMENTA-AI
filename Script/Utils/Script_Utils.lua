--[[
    Script: Utils Auxiliar para Verificação de Game Master
    Descrição: Valida permissões baseadas em conta, nome do personagem e nível.
]]--

GAME_MASTER_LEVEL = {}

-- Configuração de permissões (Baseado no seu modelo)
-- Note: Em Lua, chaves repetidas em uma tabela ('admin02') sobrescrevem a anterior. 
-- Para múltiplas contas/chars, use chaves únicas ou uma estrutura de lista se necessário.
GAME_MASTER_LEVEL['louis'] = { characterName = 'LuisADM', level = 32 }
GAME_MASTER_LEVEL['admin01'] = { characterName = 'BetaTeste', level = 32 }

--[[
    Função: CheckGameMasterLevel
    Parâmetros: account (string), name (string), level (int)
    Retorno: 1 se for GM válido, 0 caso contrário
]]--
function CheckGameMasterLevel(account, name, level)
    local gamemaster = GAME_MASTER_LEVEL[account]

    if gamemaster ~= nil then
        if name == gamemaster.characterName then
            if gamemaster.level >= level then
                return 1
            end
        end
    end

    return 0
end

--[[
    Função de compatibilidade para o Invasion Manager
    Utiliza as funções nativas do servidor para obter os dados do player
]]--
function GameMasterCheck(aIndex, requiredLevel)
    -- Obtém os dados nativos do objeto via documentação
    local account = GetAccountObject(aIndex)
    local name = GetNameObject(aIndex)
    
    -- Chama a função de verificação configurada acima
    return CheckGameMasterLevel(account, name, requiredLevel)
end

LogAddC(3, "[Utils] Sistema de permissão GameMaster carregado.")