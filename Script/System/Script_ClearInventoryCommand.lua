--[[ 
    Script_ClearInventoryCommand.lua
    Desenvolvido por: Denival
    Funcionalidade: Limpar Inventário (Slots 12 a 237)
    Baseado em: LuaClass (Inventory) + Globais (Invasion.lua)
    ID Comando: 127
]]--

local SystemMain        = {};
local SystemConfigs     = {};

-- [LUABRIDGE] Registro de Eventos
BridgeFunctionAttach("OnReadScript", "evClear_ReadScript");
BridgeFunctionAttach("OnCommandManager", "evClear_CommandManager");

function evClear_ReadScript()

    -- [CONFIGURAÇÃO]
    SystemConfigs.CommandID     = 127;   -- ID do comando (/limparinv)
    SystemConfigs.OnlyGM        = false; -- true = Só GM, false = Todos

    Utils.Log("[ClearSystem]: Script Carregado. ID: " .. SystemConfigs.CommandID, 4);

end

function evClear_CommandManager(aIndex, code, arg)

    if (code == SystemConfigs.CommandID) then
        
        local player = User.new(aIndex);

        -- [VERIFICAÇÃO DE GM]
        if (SystemConfigs.OnlyGM == true) then
            if (player:getAuthority() < 1) then
                NoticeSend(aIndex, 1, "Apenas Game Masters.");
                return 1;
            end
        end

        -- Executa a Limpeza
        SystemMain.ClearInventory(aIndex);
        
        return 1; 
    end

    return 0;

end

function SystemMain.ClearInventory(aIndex)

    -- Instancia a classe Inventory (Documentação)
    local inv = Inventory.new(aIndex);
    local itemsDeleted = 0;

    -- Loop pelos slots do Inventário (12 = Primeiro slot da bolsa)
    -- Vai até 237 para garantir que limpe inventários extendidos também.
    -- OBS: Não mexe nos slots 0 a 11 (Equipamentos)
    for slot = 12, 237 do
        
        -- Verifica se tem item no slot (isItem == 1)
        if (inv:isItem(slot) == 1) then
            
            -- Usa as funções globais de deletar (Baseado no Invasion.lua)
            if (InventoryDeleteItem) then
                InventoryDeleteItem(aIndex, slot);
                
                -- Envia pacote para atualizar o cliente visualmente
                if (SendInventoryDeleteItem) then
                    SendInventoryDeleteItem(aIndex, slot);
                end
                
                itemsDeleted = itemsDeleted + 1;
            end
        end

    end

    if (itemsDeleted > 0) then
        NoticeSend(aIndex, 1, "Inventario limpo! " .. itemsDeleted .. " itens removidos.");
    else
        NoticeSend(aIndex, 1, "Seu inventario ja esta vazio.");
    end

end