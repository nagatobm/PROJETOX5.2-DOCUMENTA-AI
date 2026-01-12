--[[ 
    Script_RepairCommand.lua
    Desenvolvido por: Denival
    Ajuste: Estrito à Documentação (Inventory Class)
    Slots: 0 a 12 (Equipamentos)
    ID Comando: 126
]]--

local SystemMain        = {};
local SystemConfigs     = {};

-- [LUABRIDGE] Registro de Eventos
BridgeFunctionAttach("OnReadScript", "evRepair_ReadScript");
BridgeFunctionAttach("OnCommandManager", "evRepair_CommandManager");

function evRepair_ReadScript()

    -- [CONFIGURAÇÃO]
    SystemConfigs.CommandID     = 126;   -- /reparar
    SystemConfigs.OnlyGM        = false; -- true = Só GM, false = Todos

    Utils.Log("[RepairSystem]: Script Carregado (Docs Mode).", 4);

end

function evRepair_CommandManager(aIndex, code, arg)

    if (code == SystemConfigs.CommandID) then
        
        local player = User.new(aIndex);

        -- [VERIFICAÇÃO DE GM]
        -- Se OnlyGM for true, verifica a autoridade
        if (SystemConfigs.OnlyGM == true) then
            if (player:getAuthority() < 1) then
                NoticeSend(aIndex, 1, "Apenas Game Masters.");
                return 1;
            end
        end

        -- Executa Reparo
        SystemMain.RepairItems(aIndex);
        
        return 1; 
    end

    return 0;

end

function SystemMain.RepairItems(aIndex)

    -- Instancia a classe Inventory (Conforme Documentação)
    local inv = Inventory.new(aIndex);
    local repairCount = 0;

    -- Loop APENAS nos Slots 0 a 12 (Equipamentos)
    for slot = 0, 12 do
        
        -- Verifica se tem item no slot (isItem retorna 1 se tiver)
        if (inv:isItem(slot) == 1) then
            
            -- Pela documentação, usamos setDurability.
            -- Como não existe função "getMaxDurability" na documentação,
            -- usamos 255 para garantir o reparo completo.
            inv:setDurability(slot, 255);
            
            -- Aplica as alterações no item (Conforme Documentação)
            inv:convertItem(slot);
            
            repairCount = repairCount + 1;
        end

    end

    if (repairCount > 0) then
        -- Atualiza o Cliente Visualmente (Função Global usada na sua referência)
        if (ItemListSend) then 
            ItemListSend(aIndex); 
        end
        
        NoticeSend(aIndex, 1, "Equipamentos reparados.");
    else
        NoticeSend(aIndex, 1, "Nenhum equipamento para reparar.");
    end

end