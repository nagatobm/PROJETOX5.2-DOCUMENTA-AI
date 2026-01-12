-- =============================================================
-- CONFIGURAÇÕES GERAIS
-- =============================================================
local Quiz = {
    Phase = nil,
    Counter = 0,
    Winner = nil,
    Selected = nil,
    QuestionsUsed = {},
    NumberOfQuestions = 0,
    Configs = {}
}

-- CONFIGURAÇÃO DO BANCO DE DADOS
-- Atenção: Coloque aqui os dados do banco onde estão as CONTAS (Geralmente MuOnline)
local SQL_DB_NAME = "MuOnlineBase"
local SQL_USER    = "sa"
local SQL_PASS    = "iDs]4i3jq&w]:BY%by?$"

-- =============================================================
-- INICIALIZAÇÃO (OnReadScript)
-- =============================================================
function Quiz_ReadScript()
    -- Configurações de Premiação
    Quiz.Configs["RewardName"]   = "Cash"      
    
    -- CAMINHO COMPLETO DA TABELA PARA EVITAR ERROS
    -- Usa [Banco].[Schema].[Tabela] para garantir que o SQL ache a conta
    Quiz.Configs["TableReward"]  = "[MuOnlineBase].[dbo].[MEMB_INFO]" 
    Quiz.Configs["ColumnReward"] = "cash"      -- Nome da coluna (cash, Gold, CSPoints, etc)
    Quiz.Configs["UserColumn"]   = "memb___id" -- Coluna do Login

    Quiz.Configs["CommandCode"]  = 118
    Quiz.Configs["CommandName"]  = "/Tests"

    -- Horários
    Quiz.Configs["Schedule"] = {  
        [1] = { wDay = nil, Hour = "11:45:00", NumberOfQuestions = 5 },
        [2] = { wDay = nil, Hour = "14:45:00", NumberOfQuestions = 5 },  
        [3] = { wDay = nil, Hour = "16:45:00", NumberOfQuestions = 5 },
        [4] = { wDay = nil, Hour = "18:45:30", NumberOfQuestions = 5 },
        [5] = { wDay = nil, Hour = "20:45:00", NumberOfQuestions = 5 },
        [6] = { wDay = nil, Hour = "22:45:00", NumberOfQuestions = 5 }
    }

    -- Perguntas
    Quiz.Configs["Questions"] = {
        [1]  = {"Qual atual time do CR7?", "AlNassr", 5},
        [2]  = {"Como se chama o personagem Adolf...?", "Hitler", 5},
        [3]  = {"Como se escreve o numero 55 em numeros romanos?", "LV", 5},
        [4]  = {"Qual o numero minimo de jogadores numa partida de futebol?", "7", 5},        
        [5]  = {"Palavra PERDER em ingles?", "lose", 5},
        [6]  = {"Quanto e 58 x 9 + 78?", "600", 5},
        [7]  = {"Quanto e 165 + 9 x 1 x 0?", "165", 5},
        [8]  = {"Qual o melhor amigo do homem?", "Cachorro", 5},
        [9]  = {"Uma marca de Video Games?", "Sony", 5},
        [10] = {"Qual o antonimo de forte?", "fraco", 5},
        [11] = {"De que pais e a invencao do chuveiro eletrico?", "Brasil", 5},
        [12] = {"Como e PORCO em ingles?", "Pig", 5},
        [13] = {"Quantas edicoes ja tivemos da libertadores?", "60", 5},
        [14] = {"Nome de uma fruta que comeca com P, 4 letras?", "Pera", 5},
        [15] = {"Animal mais alto do mundo", "Girafa", 5},
        [16] = {"Atualmente, quantos elementos quimicos a tabela periodica possui?", "118", 5},
        [17] = {"Usado para falar? M_C_O_O_E", "Microfone", 5},
        [18] = {"O que a palavra legend significa em portugues?", "Lenda", 5},
        [19] = {"Quantos filmes ha em uma trilogia?", "3", 5},
        [20] = {"Qual o planeta e famoso por possuir aneis em sua volta?", "Saturno", 5},
        [21] = {"Quantas letras ha no alfabeto portugues, atualmente?", "26", 5},
        [22] = {"Quantos minutos a luz do Sol demora para chegar a Terra?", "8", 5},
        [23] = {"Quantos dentes uma pessoa adulta possui, se nao perdeu nenhum?", "32", 5},
        [24] = {"Quanto e 17 x 8 + 74 - 200 ?", "10", 5},
        [25] = {"Que level podemos criar MG?", "220", 5},
        [26] = {"Qual o acento grafico da palavra PATIO?", "Agudo", 5},
        [27] = {"Qual a maior estrela do Sistema Solar?", "Sol", 5},
        [28] = {"Qual e o maior osso do corpo humano?", "Femur", 5},
        [29] = {"Quantas cores ha no arco-iris?", "7", 5},
        [30] = {"O que e, o que e: cai em pe e corre deitado?", "Chuva", 5},
        [31] = {"Qual o nome da profissao que apaga incendios?", "Bombeiro", 5},
        [32] = {"Qual a fruta envenenada que a Branca de Neve comeu?", "Maca", 5},
        [33] = {"Quantos estados existem no Brasil?", "26", 5},
        [34] = {"Quantas vezes o Brasil foi campeao da copa do mundo?", "5", 5},
        [35] = {"Quantos dias tem um ano bissexto?", "366", 5},
        [36] = {"Quem Deus mandou construir uma arca antes do diluvio?", "Noe", 5},
        [37] = {"Em que lugar vivem mais cangurus do que pessoas?", "Australia", 5},
        [38] = {"Quantos olhos a maior parte das aranhas tem?", "8", 5},
        [39] = {"De que sao constituidos os diamantes?", "Carbono", 5},
        [40] = {"Qual a nacionalidade do sociologo e filosofo Durkheim?", "Frances", 5},
        [41] = {"Como morreu Saddam Hussein?", "Enforcado", 5},
        [42] = {"Qual o primeiro personagem criado por Walt Disney?", "Mickey", 5},
        [43] = {"Manila e a capital de que pais?", "Filipinas", 5},
        [44] = {"Em que ano aconteceu a primeira Copa do Mundo?", "1930", 5},
        [45] = {"Quantos Deuses tem no Olimpo?", "12", 5},
        [46] = {"Afrodite e filha de que Deus?", "Urano", 5},
        [47] = {"Qual e o nome do monstro que mora em um labirinto?", "Minotauro", 5},
        [48] = {"Qual deusa nasceu da cabeca de Zeus?", "Atena", 5},
        [49] = {"Quem e a esposa de Zeus?", "Hera", 5},
        [50] = {"Quem foi rejeitado por nascer deficiente e entao jogado no mar?", "Hefesto", 5},
        [51] = {"De qual pais o clube Liverpool e?", "Inglaterra", 5},
        [52] = {"Qual e a sigla da liga dos Estados Unidos?", "MLS", 5},
        [53] = {"Qual pais criou a Taca do Mundo?", "Italia", 5},
        [54] = {"Qual o nome do machado de Thor?", "Mjolnir", 5},
        [55] = {"Qual time grande brasileiro ja foi rebaixado para a Serie C?", "Fluminense", 5},
        [56] = {"Em qual mes se comemora o Dia das Maes?", "Maio", 5},
        [57] = {"Qual o primitivo de PAPELARIA?", "Papel", 5},
        [58] = {"Sorveteria e derivado de?", "Sorvete", 5},
        [59] = {"Em qual pais fica a sede da FIFA?", "Suica", 5}
    }
end

-- =============================================================
-- TIMER DO SERVIDOR (OnTimerThread)
-- =============================================================
function Quiz_TimerThread()
    -- Verifica início do evento
    if Quiz.Phase == nil then
        local Hour = os.date("%X")
        local wDay = os.date("*t")["wday"]

        for Number, Selected in pairs(Quiz.Configs["Schedule"]) do 
            if (Selected["wDay"] == nil or Selected["wDay"] == wDay) and (Selected["Hour"] == Hour) then
                Quiz.Counter            = 0
                Quiz.Phase              = 1
                Quiz.QuestionsUsed      = {}
                Quiz.NumberOfQuestions  = Selected["NumberOfQuestions"]
                
                LogPrint("[Quiz]: Evento iniciado.")
                break
            end
        end

    -- Fase 1: Anúncio Inicial
    elseif Quiz.Phase == 1 then
        if Quiz.Counter % 60 == 0 then
            if Quiz.Counter == 0 then 
                NoticeSendToAll(0, ". : [ Quiz ] : .")
                NoticeSendToAll(0, "PREPAREM-SE PARA TESTAR OS SEUS CONHECIMENTOS!")
                NoticeSendToAll(1, string.format("[Quiz]: Primeira pergunta em 60s. Total de %d perguntas.", Quiz.NumberOfQuestions))
                Quiz.Counter = Quiz.Counter + 1
            else
                -- Inicia perguntas
                Quiz.Counter   = 0
                Quiz.Phase     = 2
                Quiz.Selected  = math.random(1, #Quiz.Configs["Questions"])
                LogPrint("[Quiz]: Fase de perguntas iniciada.")
            end
        else
            Quiz.Counter = Quiz.Counter + 1
        end        

    -- Fase 2: Perguntas e Respostas
    elseif Quiz.Phase == 2 then
        if Quiz.Counter == 0 or Quiz.Counter == 60 then
            if Quiz.NumberOfQuestions <= 0 then
                NoticeSendToAll(0, ". : [ Quiz ] : .")
                NoticeSendToAll(0, "SEM MAIS PERGUNTAS, ATE A PROXIMA!")
                
                Quiz.Phase              = nil
                Quiz.Winner             = nil
                Quiz.Counter            = 0
                Quiz.Selected           = nil
                Quiz.QuestionsUsed      = {}
                Quiz.NumberOfQuestions  = 0
                
                LogPrint("[QUIZ]: Evento encerrado.")
            else
                -- Seleciona pergunta não usada
                local attempts = 0
                while (Quiz.QuestionsUsed[Quiz.Selected] ~= nil) and (attempts < 100) do 
                    Quiz.Selected = math.random(1, #Quiz.Configs["Questions"])
                    attempts = attempts + 1
                end

                local qData = Quiz.Configs["Questions"][Quiz.Selected]

                NoticeSendToAll(1, string.format("[Quiz]: Pergunta -> %s", qData[1]))
                NoticeSendToAll(1, string.format("Valendo %d %s.", qData[3], Quiz.Configs["RewardName"]))

                NoticeSendToAll(0, ". : [ Quiz ] : .")
                NoticeSendToAll(0, string.format("Pergunta: %s", qData[1]))
                NoticeSendToAll(0, string.format("Digite '%s <resp>' para responder.", Quiz.Configs["CommandName"]))

                Quiz.Winner            = ""
                Quiz.Counter           = 1
                Quiz.NumberOfQuestions = Quiz.NumberOfQuestions - 1

                LogPrint(string.format("[Quiz]: Pergunta selecionada ID: %d.", Quiz.Selected))
            end

        elseif Quiz.Counter == 50 then
            NoticeSendToAll(1, "[Quiz]: 10 segundos restantes!")
            Quiz.Counter = Quiz.Counter + 1

        elseif Quiz.Counter == 59 and Quiz.Winner == "" then
             NoticeSendToAll(1, "Tempo esgotado! Ninguem acertou.")
             Quiz.QuestionsUsed[Quiz.Selected] = 1
             Quiz.Counter = 60
             LogPrint("[Quiz]: Ninguem acertou a pergunta.")
        else
            Quiz.Counter = Quiz.Counter + 1
        end
    end
end

-- =============================================================
-- COMANDOS (OnCommandManager)
-- =============================================================
function Quiz_Command(aIndex, code, arg)
    if code == Quiz.Configs["CommandCode"] then
        
        if Quiz.Phase ~= 2 then
            NoticeSend(aIndex, 1, "[Quiz]: O evento nao esta recebendo respostas agora.")
            return 1
        end

        if Quiz.Winner ~= "" then
            NoticeSend(aIndex, 1, string.format("[Quiz]: Rodada encerrada. Aguarde a proxima em %d s.", 60 - Quiz.Counter))
            return 1
        end

        local resp = GetCommandString(arg, 1) 
        local gabarito = Quiz.Configs["Questions"][Quiz.Selected][2]
        
        if string.upper(resp) == string.upper(gabarito) then
            local ValueOfPayment = Quiz.Configs["Questions"][Quiz.Selected][3]
            Quiz.Winner          = GetObjectName(aIndex)
            Quiz.QuestionsUsed[Quiz.Selected] = 1
            Quiz.Counter = 55 

            NoticeSendToAll(0, ". : [ QUIZ ] : .")
            NoticeSendToAll(0, string.format("%s acertou!!!! Resposta: %s", Quiz.Winner, gabarito))
            NoticeSendToAll(0, string.format("Ganhou %d %s.", ValueOfPayment, Quiz.Configs["RewardName"]))

            -- =========================================================
            -- SISTEMA DE PREMIAÇÃO (BASEADO NO ORIGINAL - SINCRONO)
            -- =========================================================
            local account = GetObjectAccount(aIndex)
            
            -- 1. Cria a conexão Síncrona (Igual ao SQLQuery do original)
            local db = SQL.new()
            
            -- 2. Conecta no banco
            if db:connect(0, SQL_DB_NAME, SQL_USER, SQL_PASS) == 1 then
                
                -- 3. Executa a query direta
                -- Forçamos [MuOnline].[dbo].[MEMB_INFO] para não ter erro de banco
                local query = string.format("UPDATE %s SET %s = %s + %d WHERE %s = '%s'", 
                    Quiz.Configs["TableReward"], 
                    Quiz.Configs["ColumnReward"], 
                    Quiz.Configs["ColumnReward"], 
                    ValueOfPayment, 
                    Quiz.Configs["UserColumn"], 
                    account
                )
                
                local res = db:exec(query)
                
                if res == 0 then
                    LogPrint("[Quiz] ERRO: O update SQL falhou. Verifique a tabela/coluna.")
                else
                    LogPrint(string.format("[Quiz] Premio entregue para %s (%s).", Quiz.Winner, account))
                end
                
                -- 4. Limpa/Fecha a conexão (Igual ao SQLClose do original)
                db:clear()
            else
                LogPrint("[Quiz] ERRO: Falha na conexao SQL na hora de premiar.")
            end
            -- =========================================================

        else
            NoticeSend(aIndex, 1, "[Quiz]: Resposta incorreta. Tente novamente!")
        end

        return 1
    end
    return 0
end

-- =============================================================
-- REGISTRO DAS FUNÇÕES
-- =============================================================
BridgeFunctionAttach("OnReadScript", "Quiz_ReadScript")
BridgeFunctionAttach("OnTimerThread", "Quiz_TimerThread")
BridgeFunctionAttach("OnCommandManager", "Quiz_Command")

-- Inicializa
Quiz_ReadScript()