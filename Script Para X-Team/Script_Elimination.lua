--[[ 
    Desenvolvido por: 
                        Jonathan C.
]]--

local SYSTEM_MAIN       = {};
local SYSTEM_CONFIGS    = {};

BridgeFunctionAttach("OnReadScript","evElimination_ReadScript");
BridgeFunctionAttach("OnTimerThread","evElimination_TimerThread");
BridgeFunctionAttach("OnCommandManager","evElimination_CommandManager");
BridgeFunctionAttach("OnCharacterClose","evElimination_CharacterClose");

function evElimination_ReadScript()
    
    SYSTEM_CONFIGS.Map                      = 0;                -- Mapa onde o evento ocorrerá.
    
    SYSTEM_CONFIGS.GM_CordXY                = {177, 110};       -- Coordenada onde o GM que startar irá nascer.
	SYSTEM_CONFIGS.CordXY					= {177, 110};		-- Coordenada onde os players irão nascer;

    SYSTEM_CONFIGS.TimerAlert               = 2;                -- Tempo, em minutos, para duração do alerta de entrada.
    SYSTEM_CONFIGS.TimerQuiz                = 30;               -- Tempo, em segundos, para aparecer a pergunta na tela.
    SYSTEM_CONFIGS.TimerElimination         = 60;               -- Tempo, em segundos, para o player eliminar alguém.

    SYSTEM_CONFIGS.MaxPlayers               = 10;                -- Número máximo de participantes.
    SYSTEM_CONFIGS.MinPlayers               = 1;                -- Número mínimo de participantes.

    SYSTEM_CONFIGS.nmCommandEntry           = "/elimination";   -- Nome do comando no CommandManager.
    SYSTEM_CONFIGS.cdCommandEntry           = 106;              -- Código do comando no CommandManager.
    SYSTEM_CONFIGS.nmCommandResp            = "/responder";
    SYSTEM_CONFIGS.cdCommandResp            = 107;
    SYSTEM_CONFIGS.nmCommandElimination     = "/eliminar"
    SYSTEM_CONFIGS.cdCommandElimination     = 108;

    SYSTEM_CONFIGS.cdCommandStart           = 109;
    SYSTEM_CONFIGS.cdCommandResetEvent      = 110;              -- no total sao 6, sendo 3 pros gms e 3 pros participantes
    SYSTEM_CONFIGS.cdCommandResetQuestion   = 111;

    SYSTEM_CONFIGS.NameReward               = "gold";
    SYSTEM_CONFIGS.ValueReward              = 1;

    SYSTEM_CONFIGS.QuizQuestions, SYSTEM_CONFIGS.QuizR = {}, {};
    SYSTEM_CONFIGS.QuizQuestions[1], SYSTEM_CONFIGS.QuizR[1] = "Que dia inaugurou o mu fast?", "25";
    SYSTEM_CONFIGS.QuizQuestions[2], SYSTEM_CONFIGS.QuizR[2] = "Quem usa speed no mu fast?", "Junior";
    SYSTEM_CONFIGS.QuizQuestions[3], SYSTEM_CONFIGS.QuizR[3] = "Que dia reinaugurou o mu fast?", "25";

end

function evElimination_TimerThread()

    if (SYSTEM_MAIN.Stage == nil) then

        return 

    elseif (SYSTEM_MAIN.Stage == 1) then

        if (SYSTEM_MAIN.Count%60 == 0) then

            if (SYSTEM_MAIN.Timer == 0) then

                if (#SYSTEM_MAIN.Users >= SYSTEM_CONFIGS.MinPlayers) then

                    SYSTEM_MAIN.Stage               = 2;
                    SYSTEM_MAIN.Count               = 1;
                    SYSTEM_MAIN.Quiz                = 1;
                    SYSTEM_MAIN.UserCount           = nil;

                    SYSTEM_MAIN.ResetQuestion();

                    NoticeSendToAll(0, ". : [ ELIMINATION ] : .");
                    NoticeSendToAll(0, "Tempo esgotado, evento iniciado.");
                    LogPrint("[ELIMINATION]: Tempo esgotado, evento iniciado.");

                else

                    SYSTEM_MAIN.ResetEvent();

                    NoticeSendToAll(0, ". : [ ELIMINATION ] : .");
                    NoticeSendToAll(0, "Evento cancelado, mínimo de participantes não atingido.");
                    LogPrint("[ELIMINATION]: Evento cancelado, mínimo de participantes não atingido.");

                end

            else

                NoticeSendToAll(0, ". : [ ELIMINATION ] : .");
                NoticeSendToAll(0, "O evento iniciará em "..SYSTEM_MAIN.Timer.. " minuto(s).");
                NoticeSendToAll(0, "Digite "..SYSTEM_CONFIGS.nmCommandEntry.." para participar.");

                SYSTEM_MAIN.Timer  = SYSTEM_MAIN.Timer - 1;
                SYSTEM_MAIN.Count  = SYSTEM_MAIN.Count + 1;

            end

        else

            SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

        end

    elseif (SYSTEM_MAIN.Stage == 2) then

        if (#SYSTEM_MAIN.Users == 1) then

            NoticeSendToAll(0, ". : [ ELIMINATION ] : .");
            NoticeSendToAll(0, "Evento encerrado. Vencedor(a): "..GetObjectName(SYSTEM_MAIN.Users[1]["Index"])..".");
            MoveUserEx(SYSTEM_MAIN.GameMaster, 0, 125, 125);
            NoticeSend(SYSTEM_MAIN.Users[1]["Index"], 1, "[Elimination]: Você recebeu "..SYSTEM_CONFIGS.ValueReward.." "..SYSTEM_CONFIGS.NameReward..".");

            SYSTEM_MAIN.RewardS4(SYSTEM_MAIN.Users[1]["Index"]);
            SYSTEM_MAIN.ResetEvent();

            LogPrint("Evento encerrado. Vencedor(a): "..GetObjectName(SYSTEM_MAIN.Users[1]["Index"])..".");

        elseif(SYSTEM_MAIN.Quiz == 1) then

            if (SYSTEM_MAIN.Count%SYSTEM_CONFIGS.TimerQuiz == 0) then

                SYSTEM_MAIN.NoticeUsers(0, ". : [ PERGUNTA ] : .");
                SYSTEM_MAIN.NoticeUsers(0, SYSTEM_CONFIGS.QuizQuestions[SYSTEM_MAIN.SelectedQuestion]);
                SYSTEM_MAIN.NoticeUsers(0, "Digite '"..SYSTEM_CONFIGS.nmCommandResp.." <resposta>' para responder.");

                SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

            elseif (SYSTEM_CONFIGS.TimerQuiz-SYSTEM_MAIN.Count <= 10) and (SYSTEM_CONFIGS.TimerQuiz-SYSTEM_MAIN.Count > 0) then

                SYSTEM_MAIN.NoticeUsers(1, "[Elimination]: A pergunta surgirá em "..SYSTEM_CONFIGS.TimerQuiz-SYSTEM_MAIN.Count.." segundo(s), prepare-se!");
                
                SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

            else

                SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

            end

        elseif (SYSTEM_MAIN.Quiz == 2) then

            if (SYSTEM_MAIN.Count == SYSTEM_CONFIGS.TimerElimination) then

                SYSTEM_MAIN.ResetQuestion();
                SYSTEM_MAIN.NoticeUsers(0, "Tempo máximo para eliminação excedido. Etapa resetada.");
                SYSTEM_MAIN.NoticeUsers(0, "Preparem-se para próxima pergunta!");

            elseif (SYSTEM_CONFIGS.TimerElimination-SYSTEM_MAIN.Count <= 10) then

                NoticeSend(GetObjectIndexByName(SYSTEM_MAIN.SelectedUser), 1, "[Elimination] Você tem "..SYSTEM_CONFIGS.TimerElimination-SYSTEM_MAIN.Count.." segundo(s) para eliminar alguém.");
                NoticeSend(GetObjectIndexByName(SYSTEM_MAIN.SelectedUser), 1, "[Elimination]: Digite '"..SYSTEM_CONFIGS.nmCommandElimination.." <nome>' para eliminar.");

                SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;

            else

                SYSTEM_MAIN.Count = SYSTEM_MAIN.Count + 1;
            
            end

        end

    end

end

function evElimination_CommandManager(aIndex, code, arg)

    if (code == SYSTEM_CONFIGS.cdCommandStart) then

        if (GetObjectAuthority(aIndex) == 32) then

            if (SYSTEM_MAIN.Stage == nil) then

                SYSTEM_MAIN.Stage            = 1;
                SYSTEM_MAIN.UserCount        = 1;
                SYSTEM_MAIN.Count            = 0;
                SYSTEM_MAIN.Quiz             = 0;
                SYSTEM_MAIN.SelectedQuestion = 0;
                SYSTEM_MAIN.SelectedUser     = "";
                SYSTEM_MAIN.Users            = {};
                SYSTEM_MAIN.GameMaster       = aIndex;
                SYSTEM_MAIN.Timer            = SYSTEM_CONFIGS.TimerAlert;

                MoveUserEx(aIndex, SYSTEM_CONFIGS.Map, SYSTEM_CONFIGS.GM_CordXY[1], SYSTEM_CONFIGS.GM_CordXY[2]);
                NoticeSend(aIndex, 1, "[Elimination]: O evento foi iniciado com sucesso!");
                LogPrint("[ELIMINATION]: O evento foi iniciado por "..GetObjectName(aIndex)..".");

            else   

                NoticeSend(aIndex, 1, "[Elimination]: O evento já está em andamento.");
                
            end
            
        else
            
            NoticeSend(aIndex, 1, "[Elimination]: Você não tem autorização para utilizar este comando.");

        end

        return 1;

    elseif (code == SYSTEM_CONFIGS.cdCommandResetEvent) then

        if (GetObjectAuthority(aIndex) == 32) then

            if (SYSTEM_MAIN.Stage == nil) then

                SYSTEM_MAIN.ResetEvent();

                NoticeSend(aIndex, 1, "[Elimination]: O evento foi resetado com sucesso!");
                LogPrint("[ELIMINATION]: O evento foi resetado por "..GetObjectName(aIndex)..".");

            else   

                NoticeSend(aIndex, 1, "[Elimination]: O evento não foi iniciado para ser resetado.");
                
            end
            
        else
            
            NoticeSend(aIndex, 1, "[Elimination]: Você não tem autorização para utilizar este comando.");

        end

        return 1;

    elseif (code == SYSTEM_CONFIGS.cdCommandEntry) then

        if (SYSTEM_MAIN.Stage ~= nil) then

            if (SYSTEM_MAIN.Stage == 1) then

                if (SYSTEM_MAIN.GetUser(aIndex) ~= 0) then

                    NoticeSend(aIndex, 1, "[Elimination]: Você já está participando deste evento.");

                else

                    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]            = {};
                    SYSTEM_MAIN.Users[SYSTEM_MAIN.UserCount]["Index"]   = aIndex;
                    SYSTEM_MAIN.UserCount                               = SYSTEM_MAIN.UserCount + 1;

                    PermissionRemove(aIndex, 12);
                    MoveUserEx(aIndex, SYSTEM_CONFIGS.Map, SYSTEM_CONFIGS.CordXY[1], SYSTEM_CONFIGS.CordXY[2]);
                    NoticeSend(aIndex, 1, "[Elimination]: Você entrou no evento. Evite perder a vaga desconectando-se!");
                    NoticeSend(aIndex, 0, "Você entrou no evento. Evite perder a vaga desconectando-se!");

                    if (#SYSTEM_MAIN.Users == SYSTEM_CONFIGS.MaxPlayers) then

                        SYSTEM_MAIN.Stage       = 2;
                        SYSTEM_MAIN.Count       = 1;
                        SYSTEM_MAIN.Quiz        = 1;
                        SYSTEM_MAIN.UserCount   = nil;

                        SYSTEM_MAIN.ResetQuestion();
                        
                        SYSTEM_MAIN.NoticeUsers(0, ". : [ ELIMINATION ] : .");
                        SYSTEM_MAIN.NoticeUsers(0, "Evento iniciado, prepare-se para a primeira pergunta!");

                        LogPrint("[ELIMINATION]: Máximo de participantes atingido, evento iniciado.");

                    end

                end

            else

                NoticeSend(aIndex, 1, "[Elimination]: O período de entrada foi encerrado.");

            end

        else

            NoticeSend(aIndex, 1, "[Elimination]: Comando indisponível no momento.");

        end

        return 1;

    elseif (SYSTEM_CONFIGS.cdCommandResp == code) then

        if (SYSTEM_MAIN.Stage ~= nil) then

            if (SYSTEM_MAIN.GetUser(aIndex) ~= 0) then

                if (SYSTEM_MAIN.Stage == 1) then

                    NoticeSend(aIndex, 1, "[Elimination]: Você não pode utilizar este comando.");

                elseif (SYSTEM_MAIN.Stage == 2) then

                    if (SYSTEM_MAIN.SelectedUser ~= "") then

                        NoticeSend(aIndex, 1, "[Elimination]: Alguém já acertou a pergunta, aguarde a próxima...");

                    else

                        if (SYSTEM_MAIN.Count > SYSTEM_CONFIGS.TimerQuiz) then

                            if (CommandGetArgString(arg,0) == SYSTEM_CONFIGS.QuizR[SYSTEM_MAIN.SelectedQuestion]) then

                                SYSTEM_MAIN.SelectedUser = GetObjectName(aIndex);
                                SYSTEM_MAIN.Count        = 0;
                                SYSTEM_MAIN.Quiz         = 2;

                                SYSTEM_MAIN.NoticeUsers(0, GetObjectName(aIndex).." acertou! R: "..SYSTEM_CONFIGS.QuizR[SYSTEM_MAIN.SelectedQuestion]..".");
                                SYSTEM_MAIN.NoticeUsers(0, "Aguardando eliminação, máximo de  "..SYSTEM_CONFIGS.TimerElimination.." segundos.");

                                NoticeSend(aIndex, 1, "[Elimination]: Resposta certa, parabéns!");
                                NoticeSend(aIndex, 1, "[Elimination]: Você tem "..SYSTEM_CONFIGS.TimerElimination.." segundos para eliminar alguém.");
                                NoticeSend(aIndex, 1, "[Elimination]: Digite '"..SYSTEM_CONFIGS.nmCommandElimination.." <nome>' para eliminar.");

                            else

                                NoticeSend(aIndex, 1, "[Elimination]: Resposta incorreta.");

                            end
                        
                        else
                        
                            NoticeSend(aIndex, 1, "[Elimination]: Você ainda não pode fazer isso!");

                        end

                    end
                
                else
                
                    NoticeSend(aIndex, 1, "[Elimination]: Você não pode utilizar este comando.");

                end                

            end

        else 

            NoticeSend(aIndex, 1, "[Elimination]: O evento não está ativo no momento.");

        end

        return 1;


                    end

                else

                    NoticeSend(aIndex, 1, "[Elimination]: Acerte a questão para utilizar este comando!");

                end

            else

                NoticeSend(aIndex, 1, "[Elimination]: Você ainda não pode utilizar este comando.");

            end


        else

            NoticeSend(aIndex, 1, "[Elimination]: O evento não está ativo no momento.");

        end

        return 1;

    elseif (code == SYSTEM_CONFIGS.cdCommandResetQuestion) then

        if (GetObjectAuthority(aIndex) == 32) then

            if (SYSTEM_MAIN.Stage == 2) then

                SYSTEM_MAIN.ResetQuestion();
                SYSTEM_MAIN.NoticeUsers(1, "[Elimination]: "..GetOBjectName(aIndex).." resetou a pergunta. Aguarde...");

                NoticeSend(aIndex, 1, "[Elimination]: A questão foi resetada com sucesso!");
                LogPrint("[ELIMINATION]: "..GetOBjectName(aIndex).." resetou a questão do evento.");

            else   

                NoticeSend(aIndex, 1, "[Elimination]: Você ainda não pode fazer isso.");
                
            end
            
        else
            
            NoticeSend(aIndex, 1, "[Elimination]: Você não tem autorização para utilizar este comando.");

        end

        return 1;

    end

    return 0;

end

function evElimination_CharacterClose(aIndex)

    if (SYSTEM_MAIN.Stage ~= nil) and (SYSTEM_MAIN.GetUser(aIndex) ~= 0) then

        SYSTEM_MAIN.NoticeUsers(1, "[Elimination]: O jogador(a) "..GetObjectName(aIndex).." desconectou-se e foi removido do evento.");
        
        SYSTEM_MAIN.DelUser(aIndex);

        if (SYSTEM_MAIN.Stage == 1) then SYSTEM_MAIN.UserCount = SYSTEM_MAIN.UserCount - 1 end;

    end

end

function SYSTEM_MAIN.GetUser(aIndex)

    for x = 1, #SYSTEM_MAIN.Users, 1 do

        if (SYSTEM_MAIN.Users[x]["Index"] == aIndex) then

            return x;

        end

    end

    return 0;

end

function SYSTEM_MAIN.DelUser(aIndex)

    for x = 1, #SYSTEM_MAIN.Users, 1 do

        if (SYSTEM_MAIN.Users[x]["Index"] == aIndex) then

            PermissionInsert(aIndex, 12);
            MoveUserEx(aIndex, 0, 125, 125);
            table.remove(SYSTEM_MAIN.Users, x);

            break;

        end

    end

end

function SYSTEM_MAIN.NoticeUsers(iType, sMessage)

    if (iType == 0) then

        for x = 1, #SYSTEM_MAIN.Users, 1 do

            NoticeSend(SYSTEM_MAIN.Users[x]["Index"], 0, sMessage);

        end

        NoticeSend(SYSTEM_MAIN.GameMaster, 0, sMessage);

    elseif (iType == 1) then

        for x = 1, #SYSTEM_MAIN.Users, 1 do

            NoticeSend(SYSTEM_MAIN.Users[x]["Index"], 1, sMessage);
            
        end
        
        NoticeSend(SYSTEM_MAIN.GameMaster, 1, sMessage);

    end

end

function SYSTEM_MAIN.ResetQuestion()

    SYSTEM_MAIN.Quiz             = 1;
    SYSTEM_MAIN.Count            = 1;
    SYSTEM_MAIN.SelectedUser     = "";
    SYSTEM_MAIN.SelectedQuestion = math.random(314, 65847);
    SYSTEM_MAIN.SelectedQuestion = math.random(1, #SYSTEM_CONFIGS.QuizQuestions);
    SYSTEM_MAIN.SelectedQuestion = math.random(1, #SYSTEM_CONFIGS.QuizQuestions);
    SYSTEM_MAIN.SelectedQuestion = math.random(1, #SYSTEM_CONFIGS.QuizQuestions);

end

function SYSTEM_MAIN.ResetEvent()

    while (#SYSTEM_MAIN.Users > 0) do

        MoveUserEx(SYSTEM_MAIN.Users[1]["Index"], 0, 125, 125);
        PermissionInsert(SYSTEM_MAIN.Users[1]["Index"], 12);
        table.remove(SYSTEM_MAIN.Users, 1);

    end

    SYSTEM_MAIN.Stage            = nil;
    SYSTEM_MAIN.UserCount        = nil;
    SYSTEM_MAIN.Count            = nil;
    SYSTEM_MAIN.Users            = nil;
    SYSTEM_MAIN.GameMaster       = nil;
    SYSTEM_MAIN.SelectedQuestion = nil;
    SYSTEM_MAIN.SelectedUser     = nil;
    SYSTEM_MAIN.Timer            = nil;
    SYSTEM_MAIN.Quiz             = nil;

end

function SYSTEM_MAIN.RewardS4(aIndex)

    SQLQuery("UPDATE memb_info SET gold = gold +"..SYSTEM_CONFIGS.ValueReward.." WHERE memb___id = '"..GetObjectAccount(aIndex).."'");
    SQLClose();

end