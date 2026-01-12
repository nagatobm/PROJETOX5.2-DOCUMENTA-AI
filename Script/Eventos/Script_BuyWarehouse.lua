--[[ 
    Script_BuyWarehouse.lua
    Desenvolvido por: 
                        Jonathan C. (Style)
    Adaptado de:
                        Warehouse.lua (Reference)
    Funcionalidade:
                        Compra de Baús Extras com Limite VIP
]]--

local SystemMain        = {};
local SystemConfigs     = {};

BridgeFunctionAttach("OnReadScript", "evBuyVault_ReadScript");
BridgeFunctionAttach("OnCommandManager", "evBuyVault_CommandManager");

function evBuyVault_ReadScript()

    -- [CONFIGURAÇÃO DE COMANDO]
    SystemConfigs.CommandID                     = 123;              -- ID no CommandManager.txt
    SystemConfigs.CommandName                   = "/comprarbau";

    -- [MOEDA]
    SystemConfigs.CoinKey                       = "GOLD";           -- GOLD, CASH, POINT (Definido na Ferramentas.lua)

    -- [CONFIGURAÇÃO POR VIP] (Baseado na lógica do Warehouse.lua)
    -- [0] = Free, [1] = Vip1, [2] = Vip2, [3] = Vip3
    
    -- Limite Máximo de Baús Extras
    SystemConfigs.MaxVaults                     = { [0] = 2, [1] = 5, [2] = 10, [3] = 20 };
    
    -- Preço do Baú
    SystemConfigs.Price                         = { [0] = 1000, [1] = 800, [2] = 600, [3] = 500 };

    Utils.Log("[BuyWarehouse]: Sistema Carregado. ID: "..SystemConfigs.CommandID, 4);

end

function evBuyVault_CommandManager(aIndex, code, arg)

    if (code == SystemConfigs.CommandID) then
        
        -- DEBUG: Confirma que o comando chegou
        Utils.Log("[DEBUG] Comando /comprarbau recebido de Index: "..aIndex, 3);

        local Player = Utils.GetPlayer(aIndex);

        if (Player) then
            SystemMain.ProcessPurchase(Player);
        end

        return 1;
    end

    return 0;

end

function SystemMain.ProcessPurchase(Player)

    local AccountID = Player:getAccountID();
    local VipLevel  = Player:getVip(); 
    local Name      = Player:getName();

    -- Validação de Segurança do VIP (Caso retorne algo estranho)
    if (VipLevel == nil or VipLevel < 0) then VipLevel = 0; end
    if (VipLevel > 3) then VipLevel = 3; end

    Utils.Log("[DEBUG] Processando para: "..AccountID.." | VIP: "..VipLevel, 3);

    -- 1. VERIFICA QUANTIDADE ATUAL (Leitura do Banco)
    -- Usa TABLE_MULT_WAREHOUSE e COLUMN_MULT_WAREHOUSE definidos na Ferramentas.lua
    local CurrentVaults = DataBase.GetNumberByString(TABLE_MULT_WAREHOUSE, COLUMN_MULT_WAREHOUSE, WHERE_MULT_WAREHOUSE, AccountID);
    
    -- Correção para valores nulos ou erro de leitura
    if (CurrentVaults == -1 or CurrentVaults == nil) then 
        CurrentVaults = 0; 
    end

    -- 2. VERIFICA LIMITE (Lógica do Warehouse.lua)
    local Limit = SystemConfigs.MaxVaults[VipLevel];
    
    if (CurrentVaults >= Limit) then
        NoticeSend(Player:getIndex(), 1, "[Baú]: Voce atingiu o limite maximo ("..CurrentVaults.."/"..Limit..").");
        if (VipLevel < 3) then
            NoticeSend(Player:getIndex(), 1, "[Baú]: Adquira VIP para aumentar o limite.");
        end
        Utils.Log("[DEBUG] Limite atingido para "..AccountID, 3);
        return;
    end

    -- 3. VERIFICA SALDO
    local Price     = SystemConfigs.Price[VipLevel];
    local CoinInfo  = Utility_Master.Map[SystemConfigs.CoinKey];

    if (not CoinInfo) then
        Utils.Log("[ERRO] Moeda "..SystemConfigs.CoinKey.." nao configurada na Ferramentas.lua", 2);
        return;
    end

    -- Define se busca saldo por Nome ou Conta
    local Target    = (CoinInfo.IdType == 1) and Name or AccountID;
    local Balance   = DataBase.GetNumberByString(CoinInfo.Table, CoinInfo.Column, CoinInfo.Where, Target);

    if (Balance < Price) then
        NoticeSend(Player:getIndex(), 1, "[Baú]: Saldo Insuficiente.");
        NoticeSend(Player:getIndex(), 0, "Preço: "..Price.." "..CoinInfo.Name..". (Voce tem: "..Balance..")");
        return;
    end

    -- 4. EXECUTA A COMPRA
    
    -- A) Desconta o valor
    Utility_Master.AddCoin(Player, SystemConfigs.CoinKey, -Price, 0);

    -- B) Adiciona o Baú (Query Direta para garantir)
    -- Isso evita erro se o DataBase.SetAddValue falhar com NULLs
    local AddQuery = string.format("UPDATE %s SET %s = %s + 1 WHERE %s = '%s'", 
        TABLE_MULT_WAREHOUSE, COLUMN_MULT_WAREHOUSE, COLUMN_MULT_WAREHOUSE, WHERE_MULT_WAREHOUSE, AccountID);
    
    SQLQuery(AddQuery);
    SQLClose();

    -- 5. MENSAGEM FINAL
    NoticeSend(Player:getIndex(), 0, ". : [ COMPRA SUCESSO ] : .");
    NoticeSend(Player:getIndex(), 0, "Novo Baú Adicionado! Total: "..(CurrentVaults + 1).."/"..Limit);
    NoticeSend(Player:getIndex(), 0, "Custo: "..Price.." "..CoinInfo.Name);
    NoticeSend(Player:getIndex(), 1, "[Aviso]: Selecione o servidor/relogue para usar o novo baú.");

    Utils.Log("[BuyVault]: "..AccountID.." comprou bau #"..(CurrentVaults + 1).." (VIP "..VipLevel..")", 4);

end