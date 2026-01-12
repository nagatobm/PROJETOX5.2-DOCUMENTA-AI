-- --[[ 
    -- Script: WarKill (Versão Final - Strict Docs)
    -- Correção: Removido getLanguage (Usa Padrão 0)
    -- Engine: LuaBridge + Utility_Master (Ferramentas)
-- ]]--

-- local SystemMain        = {}
-- local SystemSupport     = {}

-- -- ============================================================
-- -- 1. CONFIGURAÇÃO
-- -- ============================================================
-- WarKill_Config = {}

-- WarKill_Config.Ativado = true
-- WarKill_Config.Tempo = 10 
-- WarKill_Config.GMObrigatorio = false

-- WarKill_Config.Comando = {
    -- GMID     = 128, -- /warkill (Abrir, Iniciar, Cancelar, Premiar)
    -- PlayerID = 129, -- /participar
    
    -- -- Sub-comandos de texto
    -- Abrir    = "abrir",
    -- Iniciar  = "iniciar",
    -- Cancelar = "cancelar",
    -- Premiar  = "premiar",
    -- Ir       = "/participar"
-- }

-- WarKill_Config.Local = {
    -- Move = { Mapa = 6, X = 60, Y = 160 },
    -- Area = { Mapa = 6, Inicio = {X=50, Y=150}, Fim = {X=70, Y=170} }
-- }

-- WarKill_Config.Pontos = {
    -- GanhaAoMatar = { Membro = 5, GM = 10 },
    -- PerdeAoMorrer = { Membro = 2, GM = 5 }
-- }

-- -- PREMIAÇÃO (SQL via Utility_Master)
-- WarKill_Config.Premio = {
    -- Guild = {
        -- [1] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=500, Where="memb___id" },
        -- [2] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=300, Where="memb___id" },
        -- [3] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=100, Where="memb___id" },
    -- },
    -- Membro = {
        -- [1] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=50, Where="memb___id", Tipo=0, Nome="Cash" },
        -- [2] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=30, Where="memb___id", Tipo=0, Nome="Cash" },
        -- [3] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=10, Where="memb___id", Tipo=0, Nome="Cash" },
    -- },
    -- GM = {
        -- [1] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=100, Where="memb___id", Tipo=0, Nome="Cash" },
        -- [2] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=50, Where="memb___id", Tipo=0, Nome="Cash" },
        -- [3] = { Tabela="MEMB_INFO", Coluna="CSPoints", Quantidade=20, Where="memb___id", Tipo=0, Nome="Cash" },
    -- }
-- }

-- -- MENSAGENS (Forçado para ID 0 pois getLanguage não existe)
-- WarKill_Config.Message = {
    -- [0] = { 
        -- [1] = { Text = "Evento ja aberto. Use cancelar.", Color = 1 },
        -- [2] = { Text = "Use: /warkill abrir [Minutos]", Color = 1 },
        -- [3] = { Text = "Evento Aberto! Digite %s para participar.", Color = 0 },
        -- [4] = { Text = "Inicia em %d minutos.", Color = 0 },
        -- [5] = { Text = "Entradas fechadas.", Color = 0 },
        -- [6] = { Text = "Aguarde o inicio.", Color = 0 },
        -- [7] = { Text = "Evento fechado.", Color = 1 },
        -- [8] = { Text = "Evento Cancelado.", Color = 1 },
        -- [9] = { Text = "Precisa ter Guild.", Color = 1 },
        -- [10] = { Text = "Voce foi para a Arena.", Color = 0 },
        -- [11] = { Text = "Minimo 2 Guilds.", Color = 1 },
        -- [12] = { Text = "Evento ja iniciou.", Color = 1 },
        -- [13] = { Text = "VALENDO! MATEM-SE!", Color = 0 },
        -- [14] = { Text = "Saiu da area -> Desclassificado.", Color = 1 },
        -- [15] = { Text = "Aguardando premiacao.", Color = 1 },
        -- [19] = { Text = "Evento fim. Use premiar.", Color = 1 },
        -- [20] = { Text = "Aguarde o combate.", Color = 1 },
        -- [21] = { Text = "[%s]%s Matou [%s]%s", Color = 0 },
        -- [22] = { Text = "Perdeu %d pontos.", Color = 1 },
        -- [23] = { Text = "Ganhou %d pontos.", Color = 0 },
        -- [24] = { Text = "Premio: %d %s", Color = 0 },
        -- [25] = { Text = "Erro ao premiar.", Color = 1 },
        -- [26] = { Text = "Guild desclassificada.", Color = 1 },
        -- [27] = { Text = "Guild %s removida.", Color = 0 },
        -- [28] = { Text = "Evento aberto. Use iniciar.", Color = 1 },
    -- }
-- }

-- -- ============================================================
-- -- 2. FUNÇÕES DE SUPORTE (COMPATIBILIDADE)
-- -- ============================================================

-- -- Parser Manual (Resolve erro de comando)
-- function SystemSupport.GetArg(argString, index)
    -- local words = {}
    -- for w in string.gmatch(argString, "%S+") do table.insert(words, w) end
    -- return words[index]
-- end

-- -- SQL Exec via Utility_Master
-- function SystemSupport.SQLExec(Query)
    -- if Utility_Master then
        -- if Utility_Master.Exec then Utility_Master.Exec(Query) return end
        -- if Utility_Master.Execute then Utility_Master.Execute(Query) return end
        -- if Utility_Master.Query then Utility_Master.Query(Query) return end
    -- end
    -- -- Fallback
    -- if DataBase and DataBase.Exec then DataBase.Exec(Query) end
-- end

-- -- SQL Get via Utility_Master
-- function SystemSupport.SQLGet(Query, ColName)
    -- if Utility_Master then
        -- if Utility_Master.GetString then return Utility_Master.GetString(Query) end
        -- if Utility_Master.GetValue then return Utility_Master.GetValue(Query) end
    -- end
    -- return nil
-- end

-- -- Mensagens
-- function SendMessage(msg, aIndex, color)
    -- NoticeSend(aIndex, 1, msg)
-- end

-- function SendMessageGlobal(msg, type)
    -- if SendMessageGlobal then _G.SendMessageGlobal(msg, type)
    -- elseif NoticeSendToAll then NoticeSendToAll(type, msg) end
-- end

-- -- Timers Simulados
-- local TimersList = {}
-- function SystemSupport.ProcessTimers()
    -- local now = os.time()
    -- for id, t in pairs(TimersList) do
        -- if now >= t.nextTick then
            -- if t.type == "timeout" then
                -- t.func(t.arg)
                -- TimersList[id] = nil
            -- elseif t.type == "interval" then
                -- t.func()
                -- t.nextTick = now + t.sec
            -- elseif t.type == "repeater" then
                -- t.func()
                -- t.count = t.count - 1
                -- if t.count <= 0 then TimersList[id] = nil
                -- else t.nextTick = now + t.sec end
            -- end
        -- end
    -- end
-- end

-- local Timer = {}
-- function Timer.Interval(s, f) local id = math.random(99999); TimersList[id]={type="interval", sec=s, func=f, nextTick=os.time()+s}; return id; end
-- function Timer.TimeOut(s, f, a) local id = math.random(99999); TimersList[id]={type="timeout", sec=s, func=f, arg=a, nextTick=os.time()+s}; return id; end
-- function Timer.Repeater(s, c, f) local id = math.random(99999); TimersList[id]={type="repeater", sec=s, func=f, count=c, nextTick=os.time()+s}; return id; end
-- function Timer.Cancel(id) TimersList[id] = nil end

-- -- ============================================================
-- -- 3. LÓGICA DO EVENTO
-- -- ============================================================
-- WarKill = {}

-- function WarKill.Define()
    -- WarKill_Config.Guild = {}
    -- WarKill_Config.Players = {}
    -- WarKill_Config.EventStatus = {
        -- Running = false, Started = false, Open = false, Waiting = false,
        -- Timer = 0, Time = WarKill_Config.Tempo, Repeat = 0,
        -- TimerPremiar = 0, TimerAnuncio = 0
    -- }
    -- WarKill_Config.GuildVencedora = {
        -- [1] = {Nome = "-", Pontos = -1, GM = ""},
        -- [2] = {Nome = "-", Pontos = -1, GM = ""},
        -- [3] = {Nome = "-", Pontos = -1, GM = ""},
    -- }
    -- WarKill_Config.TimerCheckUsers = 0
    -- WarKill_Config.GameMaster = 0
-- end

-- function WarKill.ComandoAbrir(aIndex, tempoArg)
    -- -- REMOVIDO: p:getLanguage()
    -- -- FIXO: Lang = 0
    -- local lang = 0 

    -- if WarKill_Config.EventStatus.Running then 
        -- SendMessage(WarKill_Config.Message[lang][1].Text, aIndex, 1)
        -- return
    -- end

    -- local tempo = tonumber(tempoArg)
    -- if tempo == nil or tempo <= 0 then
        -- tempo = WarKill_Config.Tempo
    -- end

    -- WarKill_Config.EventStatus.Running = true
    -- WarKill_Config.EventStatus.Open = true
    -- WarKill_Config.EventStatus.Repeat = tempo
    -- WarKill_Config.GameMaster = aIndex
    -- WarKill_Config.EventStatus.TimerAnuncio = Timer.Repeater(60, tempo, WarKill.AnnounceOpen)

    -- SendMessageGlobal("=== WarKill Aberto ===", 0)
    -- SendMessageGlobal(string.format(WarKill_Config.Message[lang][3].Text, WarKill_Config.Comando.Ir), 0)
    -- SendMessageGlobal(string.format(WarKill_Config.Message[lang][4].Text, tempo), 0)
-- end

-- function WarKill.ComandoIniciar(aIndex)
    -- local lang = 0

    -- if not WarKill_Config.EventStatus.Running then return end
    -- if WarKill_Config.EventStatus.Started then return end

    -- local gCount = 0
    -- for k,v in pairs(WarKill_Config.Guild) do gCount = gCount + 1 end

    -- if gCount < 2 then
        -- SendMessage(WarKill_Config.Message[lang][11].Text, aIndex, 1)
        -- return
    -- end

    -- WarKill_Config.TimerCheckUsers = Timer.Interval(2, WarKill.CheckUsers)
    -- WarKill_Config.EventStatus.Timer = Timer.TimeOut(WarKill_Config.Tempo*60, WarKill.EndEvent, 0)
    -- WarKill_Config.EventStatus.Started = true
    -- WarKill_Config.EventStatus.Open = false

    -- SendMessageGlobal("=== COMBATE INICIADO ===", 0)
    -- SendMessageGlobal(WarKill_Config.Message[lang][13].Text, 0)
-- end

-- function WarKill.ComandoCancelar(aIndex)
    -- if not WarKill_Config.EventStatus.Running then return end

    -- Timer.Cancel(WarKill_Config.TimerCheckUsers)
    -- Timer.Cancel(WarKill_Config.EventStatus.TimerPremiar)
    -- Timer.Cancel(WarKill_Config.EventStatus.TimerAnuncio)

    -- -- Retorna players
    -- for k, idx in pairs(WarKill_Config.Players) do
        -- local p = User.new(idx)
        -- if p:getConnected() == 1 then p:move(0, 125, 125) end
    -- end

    -- WarKill.Define()
    -- SendMessage(WarKill_Config.Message[0][8].Text, aIndex, 1)
-- end

-- function WarKill.ComandoIr(aIndex)
    -- local p = User.new(aIndex)
    -- local lang = 0
    -- local guild = p:getGuildName()
    -- local name = p:getName()
    -- local acc = p:getAccountID()

    -- if not WarKill_Config.EventStatus.Open then 
        -- SendMessage(WarKill_Config.Message[lang][5].Text, aIndex, 1)
        -- return 
    -- end
    
    -- if guild == nil or guild:len() <= 0 then
        -- SendMessage(WarKill_Config.Message[lang][9].Text, aIndex, 1)
        -- return
    -- end

    -- -- Registra Guild
    -- if WarKill_Config.Guild[guild] == nil then
        -- local gmaster = ""
        -- -- SQL via Utility_Master
        -- local q = string.format("SELECT G_Master FROM Guild WHERE G_Name = '%s'", guild)
        -- local res = SystemSupport.SQLGet(q, "G_Master")
        -- if res then gmaster = res end
        
        -- WarKill_Config.Guild[guild] = {Nome = guild, Pontos = 0, GM = gmaster}
    -- end

    -- -- Registra Player
    -- if WarKill_Config.Players[aIndex] == nil then
        -- WarKill_Config.Players[aIndex] = {Tipo = {[0] = acc, [1] = name}, Lang = lang, Guild = guild}
        -- p:move(WarKill_Config.Local.Move.Mapa, WarKill_Config.Local.Move.X, WarKill_Config.Local.Move.Y)
        -- SendMessage(WarKill_Config.Message[lang][10].Text, aIndex, 0)
    -- else
        -- SendMessage("Voce ja esta cadastrado.", aIndex, 1)
    -- end
-- end

-- function WarKill.CheckUsers()
    -- if not WarKill_Config.EventStatus.Started then return end
    
    -- for aIndex, data in pairs(WarKill_Config.Players) do
        -- local p = User.new(aIndex)
        -- if p:getConnected() == 0 then
            -- WarKill_Config.Players[aIndex] = nil 
        -- else
            -- local map = p:getMapNumber()
            -- local x = p:getX()
            -- local y = p:getY()
            
            -- local inMap = (map == WarKill_Config.Local.Area.Mapa)
            -- local inX = (x >= WarKill_Config.Local.Area.Inicio.X and x <= WarKill_Config.Local.Area.Fim.X)
            -- local inY = (y >= WarKill_Config.Local.Area.Inicio.Y and y <= WarKill_Config.Local.Area.Fim.Y)
            
            -- if not (inMap and inX and inY) then
                 -- p:move(0, 125, 125)
                 -- SendMessage(WarKill_Config.Message[0][14].Text, aIndex, 1)
                 -- WarKill_Config.Players[aIndex] = nil
            -- end
        -- end
    -- end
-- end

-- function WarKill.EndEvent(from)
    -- if from == 1 then Timer.Cancel(WarKill_Config.EventStatus.Timer) end
    -- Timer.Cancel(WarKill_Config.TimerCheckUsers)
    
    -- WarKill_Config.EventStatus.Started = false
    -- WarKill_Config.EventStatus.Waiting = true
    
    -- -- Cálcula Vencedores
    -- local ranking = {}
    -- for gName, data in pairs(WarKill_Config.Guild) do table.insert(ranking, data) end
    -- table.sort(ranking, function(a,b) return a.Pontos > b.Pontos end)
    
    -- for i=1,3 do
        -- if ranking[i] then WarKill_Config.GuildVencedora[i] = ranking[i] end
    -- end

    -- SendMessageGlobal("=== WarKill Finalizado ===", 0)
    -- SendMessageGlobal(string.format("1. %s (%d)", WarKill_Config.GuildVencedora[1].Nome, WarKill_Config.GuildVencedora[1].Pontos), 0)
    
    -- -- Retorna players
    -- for aIndex, data in pairs(WarKill_Config.Players) do
        -- local p = User.new(aIndex)
        -- if p:getConnected() == 1 then p:move(0, 125, 125) end
    -- end

    -- SendMessageGlobal("Premiando Automaticamente...", 0)
    -- WarKill.Premiar()
-- end

-- function WarKill.Premiar()
    -- -- SQL via Utility_Master
    -- for i=1,3 do
        -- local win = WarKill_Config.GuildVencedora[i]
        -- if win.Nome ~= "-" then
            -- local cfg = WarKill_Config.Premio.Guild[i]
            -- local q = string.format("UPDATE %s SET %s = %s + %d WHERE %s = '%s'", cfg.Tabela, cfg.Coluna, cfg.Coluna, cfg.Quantidade, cfg.Where, win.Nome)
            -- SystemSupport.SQLExec(q)
        -- end
    -- end

    -- for aIndex, data in pairs(WarKill_Config.Players) do
        -- local p = User.new(aIndex)
        -- if p:getConnected() == 1 then
            -- for i=1,3 do
                -- if data.Guild == WarKill_Config.GuildVencedora[i].Nome then
                     -- local premio = WarKill_Config.Premio.Membro[i]
                     -- if data.Tipo[1] == WarKill_Config.GuildVencedora[i].GM then
                        -- premio = WarKill_Config.Premio.GM[i]
                     -- end
                     
                     -- local q = string.format("UPDATE %s SET %s = %s + %d WHERE %s = '%s'", premio.Tabela, premio.Coluna, premio.Coluna, premio.Quantidade, premio.Where, data.Tipo[0])
                     -- SystemSupport.SQLExec(q)
                     
                     -- SendMessage(string.format(WarKill_Config.Message[0][24].Text, premio.Quantidade, premio.Nome), aIndex, 0)
                -- end
            -- end
        -- end
    -- end

    -- WarKill.Define()
    -- SendMessageGlobal("Premiacao Entregue. Fim.", 0)
-- end

-- function WarKill.AnnounceOpen()
    -- if WarKill_Config.EventStatus.Repeat > 0 then
        -- SendMessageGlobal(string.format(WarKill_Config.Message[0][3].Text, WarKill_Config.Comando.Ir), 0)
        -- WarKill_Config.EventStatus.Repeat = WarKill_Config.EventStatus.Repeat - 1
    -- else
        -- Timer.Cancel(WarKill_Config.EventStatus.TimerAnuncio)
        -- WarKill_Config.EventStatus.Open = false
        -- SendMessageGlobal(WarKill_Config.Message[0][5].Text, 0)
    -- end
-- end

-- -- ============================================================
-- -- 4. EVENTOS LUABRIDGE
-- -- ============================================================
-- BridgeFunctionAttach("OnReadScript", "evWarKill_ReadScript")
-- BridgeFunctionAttach("OnCommandManager", "evWarKill_CommandManager")
-- BridgeFunctionAttach("OnTimerThread", "evWarKill_TimerThread")
-- BridgeFunctionAttach("OnPlayerDie", "evWarKill_PlayerDie")
-- BridgeFunctionAttach("OnPlayerAttack", "evWarKill_PlayerAttack")

-- function evWarKill_ReadScript()
    -- WarKill.Define()
    -- Utils.Log("[WarKill] Carregado (Final Version)", 4)
-- end

-- function evWarKill_CommandManager(aIndex, code, arg)
    -- -- ID 130: GM
    -- if code == WarKill_Config.Comando.GMID then
        -- local p = User.new(aIndex)
        -- if p:getAuthority() < 1 then return 1 end

        -- local subCmd = SystemSupport.GetArg(arg, 1)
        -- if subCmd then subCmd = string.lower(subCmd) end

        -- if subCmd == WarKill_Config.Comando.Abrir then
            -- local tempo = SystemSupport.GetArg(arg, 2)
            -- WarKill.ComandoAbrir(aIndex, tempo)
        -- elseif subCmd == WarKill_Config.Comando.Iniciar then
            -- WarKill.ComandoIniciar(aIndex)
        -- elseif subCmd == WarKill_Config.Comando.Cancelar then
            -- WarKill.ComandoCancelar(aIndex)
        -- elseif subCmd == WarKill_Config.Comando.Premiar then
            -- WarKill.Premiar()
        -- else
            -- SendMessage("Use: /warkill [abrir|iniciar|cancelar|premiar]", aIndex, 1)
        -- end
        -- return 1
    -- end

    -- -- ID 131: Player
    -- if code == WarKill_Config.Comando.PlayerID then
        -- WarKill.ComandoIr(aIndex)
        -- return 1
    -- end
    -- return 0
-- end

-- function evWarKill_TimerThread()
    -- SystemSupport.ProcessTimers()
-- end

-- function evWarKill_PlayerDie(VictimIndex, KillerIndex)
    -- if not WarKill_Config.EventStatus.Started then return end
    -- if KillerIndex < 0 or KillerIndex > 10000 then return end

    -- local pKill = WarKill_Config.Players[KillerIndex]
    -- local pDie  = WarKill_Config.Players[VictimIndex]
    -- local lang = 0

    -- if pKill and pDie then
        -- local gKill = WarKill_Config.Guild[pKill.Guild]
        -- local gDie  = WarKill_Config.Guild[pDie.Guild]

        -- if gKill and gDie then
            -- if pKill.Guild == pDie.Guild then
                -- gDie.Pontos = math.max(0, gDie.Pontos - (WarKill_Config.Pontos.PerdeAoMorrer.Membro * 2))
                -- SendMessage("Fogo amigo! -Pontos", KillerIndex, 1)
            -- else
                -- gKill.Pontos = gKill.Pontos + WarKill_Config.Pontos.GanhaAoMatar.Membro
                -- gDie.Pontos  = math.max(0, gDie.Pontos - WarKill_Config.Pontos.PerdeAoMorrer.Membro)
                
                -- SendMessage(string.format(WarKill_Config.Message[lang][23].Text, WarKill_Config.Pontos.GanhaAoMatar.Membro), KillerIndex, 0)
                -- SendMessageGlobal(string.format(WarKill_Config.Message[lang][21].Text, pKill.Guild, pKill.Tipo[1], pDie.Guild, pDie.Tipo[1]), 0)
            -- end
        -- end
    -- end
-- end

-- function evWarKill_PlayerAttack(aIndex, bIndex)
    -- if WarKill_Config.EventStatus.Running and not WarKill_Config.EventStatus.Started then
        -- if WarKill_Config.Players[aIndex] and WarKill_Config.Players[bIndex] then
            -- return 1 -- Bloqueia
        -- end
    -- end
    -- return 0
-- end