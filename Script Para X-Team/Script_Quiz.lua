local LQuiz = { Phase = nil, Configs = {} };

BridgeFunctionAttach("OnReadScript","Quiz_ReadScript");

Quiz_ReadScript = function()

    LQuiz.Configs["RewardName"]     = "Cash's";

    LQuiz.Configs["CommandCode"]    = 118;
    LQuiz.Configs["CommandName"]    = "/r";

    LQuiz.Configs["Schedule"]  = {    
        [1] = { wDay = nil, Hour = "11:45:00", NumberOfQuestions = 5 },
        [2] = { wDay = nil, Hour = "14:45:00", NumberOfQuestions = 5 },  
		[3] = { wDay = nil, Hour = "16:45:00", NumberOfQuestions = 5 },
        [4] = { wDay = nil, Hour = "18:45:00", NumberOfQuestions = 5 },
		[5] = { wDay = nil, Hour = "20:45:00", NumberOfQuestions = 5 },
        [6] = { wDay = nil, Hour = "22:45:00", NumberOfQuestions = 5 }
		
    };
    LQuiz.Configs["Questions"] = {
        [1]  = {"Qual atual time do CR7?"   ,                                          "Juventus"       , 5},
        [2]  = {"Como se chama o personagem Adolf...?" ,                               "Hitler"         , 5},
		[3]  = {"Como se escreve o número 55 em números romanos?" ,                    "LV"             , 5},
        [4]  = {"Qual o número mínimo de jogadores numa partida de futebol?" ,         "7"              , 5},       
        [5]  = {"Palavra PERDER em inglês ?"  ,                                        "lose"           , 5},
        [6]  = {"Quanto é 58 x 9 + 78?"  ,                                             "600"            , 5},
        [7]  = {"Quanto é 165 + 9 x 1 x 0?"  ,                                         "0"              , 5},
        [8]  = {"Qual o melhor amigo do homem?"   ,                                    "Cachorro"       , 5},
        [9]  = {"Uma marca de Video Games ?"  ,                                        "Sony"           , 5},
	    [10] = {"Qual o antônimo de forte?"  ,                                         "fraco"          , 5},
        [11] = {"De que país é a invenção do chuveiro elétrico?"   ,                   "Brasil"         , 5},
        [12] = {"Como é PORCO em inglês?"   ,                                          "Pig"            , 5},
        [13] = {"Quantas edições já tivemos da libertadores ?"  ,                      "60"             , 5},
	    [14] = {"Nome de uma fruta que comaça com P, 4 letras?"  ,                     "Pera"           , 5},
	    [15] = {"Animal mais alto do mundo"  ,                                         "Girafa"         , 5},
        [16] = {"Atualmente, quantos elementos químicos a tabela periódica possui?"   ,"118"            , 5},
        [17] = {"Usado para falar? M_C_O_O_E"   ,                                      "Microfone"      , 5},
        [18] = {"O que a palavra legend significa em português?"  ,                    "Lenda"          , 5},
		[19] = {"Quantos filmes há em uma trilogia?"   ,                               "3"              , 5},
        [20] = {"Qual o planeta é famoso por possuir anéis em sua volta?"  ,           "Saturno"        , 5},
	    [21] = {"Quantas letras há no alfabeto português, atualmente?"  ,              "26"             , 5},
	    [22] = {"Quantos minutos a luz do Sol demora para chegar à Terra?"  ,          "8"              , 5},
        [23] = {"Quantos dentes uma pessoa adulta possui, se não perdeu nenhum?"   ,   "32"             , 5},
        [24] = {"Quanto é 17 x 8 + 74 - 200 ?"  ,                                      "10"             , 5},
        [25] = {"Que level podemos criar MG?"  ,                                       "220"            , 5},
		[26] = {"Qual o acento gráfico da palavra PÁTIO?"  ,                           "Agudo"          , 5},
        [27] = {"Qual a maior estrela do Sistema Solar?"   ,                           "Sol"            , 5},
        [28] = {"Qual é o maior osso do corpo humano?"   ,                             "Fêmur"          , 5},
        [29] = {"Quantas cores há no arco-íris?"  ,                                    "7"              , 5},
	    [30] = {"O que é, o que é: cai em pé e corre deitado??"   ,                    "Chuva"          , 5},
        [31] = {"Qual o nome da profissão que apaga incêndios?"   ,                    "Bombeiro"       , 5},
        [32] = {"Qual a fruta envenenada que a Branca de Neve comeu?"  ,               "Maça"           , 5},
		[33] = {"Quantos estados existem no Brasil?"  ,                                "26"             , 5},
        [34] = {"Quantas vezes o Brasil foi campeão da copa do mundo?"   ,             "5"              , 5},
        [35] = {"Quantos dias têm um ano bissexto?"   ,                                "366"            , 5},
        [36] = {"Quem Deus mandou construir uma arca antes do dilúvio??"  ,            "Noé"            , 5},
		[37] = {"Em que lugar vivem mais cangurus do que pessoas?"  ,                  "Austrália"      , 5},
	    [38] = {"Quantos olhos a maior parte das aranhas têm?"   ,                     "8"              , 5},
        [39] = {"De que são constituídos os diamantes?"   ,                            "Carbono"        , 5},
        [40] = {"Qual a nacionalidade do sociólogo e filósofo Durkheim?"  ,            "Frances"        , 5},
		[41] = {"Como morreu Saddam Hussein?"  ,                                       "Enforcado"      , 5},
        [42] = {"Qual o primeiro personagem criado por Walt Disney?"   ,               "Mickey"         , 5},
        [43] = {"Manila é a capital de que país?"   ,                                  "Filipinas"      , 5},
        [44] = {"Em que ano aconteceu a primeira Copa do Mundo?"  ,                    "1930"           , 5},
		[45] = {"Quantos Deuses tem no Olimpo?"  ,                                     "12"             , 5},
	    [46] = {"Afrodite é filha de que Deus?"   ,                                    "Urano"          , 5},
        [47] = {"Qual é o nome do monstro que mora em um labirinto?"   ,               "Minotauro"      , 5},
        [48] = {"Qual deusa nasceu da cabeça de Zeus?"  ,                              "Atena"          , 5},
		[49] = {"Quem é a esposa de Zeus?"  ,                                          "Hera"           , 5},
        [50] = {"Quem foi rejeitado por nascer deficiente e então jogado no mar?"   ,  "Hefesto"        , 5},
        [51] = {"De qual país o clube Liverpool é?"   ,                                "Inglaterra"     , 5},
        [52] = {"Qual é a sigla da liga dos Estados Unidos?"  ,                        "MLS"            , 5},
		[53] = {"Qual pais criou a Taça do Mundo?"   ,                                 "Itália"         , 5},
        [54] = {"Qual o nome do machado de Thor?"  ,                                   "Mjolnir"        , 5},
		[55] = {"Qual time grande brasileiro já foi rebaixado para a Série C?"  ,      "Fluminense"     , 5},
        [56] = {"Em qual mês se comemora o Dia das Mães?"   ,                          "Maio"           , 5},
        [57] = {"Qual o primitivo de PAPELARIA?"   ,                                   "Papel"          , 5},
        [58] = {"Sorveteria é derivado de??"  ,                                        "Sorvete"        , 5},
        [59] = {"Em qual país fica a sede da FIFA?" ,                                  "Suiça"          , 5}
    };

end;



BridgeFunctionAttach("OnTimerThread","Quiz_TimerThread");

Quiz_TimerThread = function()

    if LQuiz.Phase == nil then

        local Hour = os.date("%X");
        local wDay = os.date("*t")["wday"];

        for Number in pairs(LQuiz.Configs["Schedule"]) do 

            local Selected = LQuiz.Configs["Schedule"][Number];

            if (Selected["wDay"] == nil or Selected["wDay"] == wDay) and (Selected["Hour"] == Hour) then

                LQuiz.Counter           = 0;
                LQuiz.Phase             = 1;
                LQuiz.QuestionsUsed     = {};
                LQuiz.NumberOfQuestions = Selected["NumberOfQuestions"];

                LogPrint("[Quiz]: Evento iniciado.");
                
                break;
            end;

        end;

    elseif LQuiz.Phase == 1 then

        if LQuiz.Counter%60 == 0 then

            if LQuiz.Counter == 0 then 

                NoticeSendToAll(0, ". : [ Quiz ] : .");
                NoticeSendToAll(0, "PREPAREM-SE PARA TESTAR OS SEUS CONHECIMENTOS!");
                NoticeSendToAll(1, string.format("[Quiz]: Primeira pergunta em 60s, sequência de %d perguntas.", LQuiz.NumberOfQuestions));

                LQuiz.Counter = LQuiz.Counter + 1;

            else

                LQuiz.Counter  = 0;
                LQuiz.Phase    = 2;
                LQuiz.Selected = RandomGetNumber(#LQuiz.Configs["Questions"]);
                LogPrint("[Quiz]: Fase de perguntas iniciada.");

            end;

        else

            LQuiz.Counter = LQuiz.Counter + 1;

        end;        

    elseif LQuiz.Phase == 2 then

        if LQuiz.Counter == 0 or LQuiz.Counter == 60 then

            if LQuiz.NumberOfQuestions == 0 then

                NoticeSendToAll(0, ". : [ Quiz ] : .");
                NoticeSendToAll(0, "SEM MAIS PERGUNTAS, ATÉ A PRÓXIMA!");

                LQuiz.Phase             = nil;
                LQuiz.Winner            = nil;
                LQuiz.Counter           = nil;
                LQuiz.Selected          = nil;
                LQuiz.QuestionsUsed     = nil;
                LQuiz.NumberOfQuestions = nil;

                LogPrint("[QUIZ]: Evento encerrado.");

            else

                while LQuiz.QuestionsUsed[LQuiz.Selected] ~= nil do 
                    LQuiz.Selected = math.random(1, #LQuiz.Configs["Questions"]); 
                    LQuiz.Selected = math.random(1, #LQuiz.Configs["Questions"]); 
                    LQuiz.Selected = math.random(1, #LQuiz.Configs["Questions"]); 
                end;

                NoticeSendToAll(1, string.format("[Quiz]: Pergunta -> %s", LQuiz.Configs["Questions"][LQuiz.Selected][1]));
                NoticeSendToAll(1, string.format("Valendo %d %s.", LQuiz.Configs["Questions"][LQuiz.Selected][3], LQuiz.Configs["RewardName"]));

                NoticeSendToAll(0, ". : [ Quiz ] : .");
                NoticeSendToAll(0, string.format("Pergunta: %s", LQuiz.Configs["Questions"][LQuiz.Selected][1]));
                NoticeSendToAll(0, string.format("Digite '%s <resp>' para responder.", LQuiz.Configs["CommandName"]));

                LQuiz.Winner            = "";
                LQuiz.Counter           = (LQuiz.Counter == 60) and 1 or LQuiz.Counter + 1;
                LQuiz.NumberOfQuestions = LQuiz.NumberOfQuestions - 1;

                LogPrint(string.format("[Quiz]: Pergunta selectionada: %d.", LQuiz.Selected));

            end;

        elseif LQuiz.Counter == 50 then

            NoticeSendToAll(1, "[Quiz]: Próxima pergunta em 10s, prepare-se!");

            if LQuiz.Winner == "" then
                NoticeSendToAll(1, "Tempo esgotado. Próxima pergunta em 10s, prepare-se!");
                LQuiz.Winner = "Tempo11Esgotado"; 
                LogPrint("[Quiz]: Não houve ganhador para esta pergunta.");
            end;

            LQuiz.QuestionsUsed[LQuiz.Selected] = 1; 
            LQuiz.Counter       = LQuiz.Counter + 1;

        else

            LQuiz.Counter = LQuiz.Counter + 1;

        end;

    end;

end;

BridgeFunctionAttach("OnCommandManager", "Quiz_Command");

Quiz_Command = function(aIndex, code, arg)

    if LQuiz.Configs["CommandCode"] == code then

        if LQuiz.Phase ~= nil then

            if LQuiz.Phase == 1 then

                NoticeSend(aIndex, 1, "[Quiz]: Fique atento, logo aparecerá uma pergunta!!");

            else

                if LQuiz.Winner == "Tempo11Esgotado" then

                    NoticeSend(aIndex, 1, string.format("[Quiz]: Tempo esgotado. Próxima pergunta em %d segundos.", 60-LQuiz.Counter));

                elseif LQuiz.Winner ~= "" then

                    NoticeSend(aIndex, 1, string.format("[Quiz]: Alguém já acertou. Próxima pergunta em %d segundos.", 60-LQuiz.Counter));

                else

                    local resp = string.format(CommandGetArgString(arg, 0));

                    if string.upper(resp) == string.upper(LQuiz.Configs["Questions"][LQuiz.Selected][2]) then

                        local ValueOfPayment = LQuiz.Configs["Questions"][LQuiz.Selected][3];
                        LQuiz.Winner         = GetObjectName(aIndex);
                        LQuiz.QuestionsUsed[LQuiz.Selected] = 1;
                        NoticeSendToAll(0, ". : [ QUIZ ] : .");
                        NoticeSendToAll(0, string.format("%s acertou!!!! Ganhou %d %s.", LQuiz.Winner, ValueOfPayment, LQuiz.Configs["RewardName"]));

                        SQLQuery(string.format("UPDATE MEMB_INFO SET cash = cash + %d WHERE memb___id = '%s'", ValueOfPayment, GetObjectAccount(aIndex)));
                        SQLClose();

                        LogPrint(string.format("[Quiz]: %s acertou uma pergunta e recebeu %d %s.", LQuiz.Winner, ValueOfPayment, LQuiz.Configs["RewardName"]));

                    else

                        NoticeSend(aIndex, 1, "[Quiz]: Resposta incorreta. Tente novamente!");

                    end;

                end;

            end;

        else

            NoticeSend(aIndex, 1, "[Quiz]: Evento indisponível no momento.");

        end;

        return 1;

    end;

    return 0;

end;