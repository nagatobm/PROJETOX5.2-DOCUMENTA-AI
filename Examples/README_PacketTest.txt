PacketTest (Lua) - Server -> Client

Objetivo
- Testar o sistema de packets custom (0xFA) e imprimir informações na mensagem global.
- Fluxo: Server envia INFO -> Client exibe na janela.

Arquivos
- Examples/PacketTest_Server.lua
  - Envio automático:
    - OnCharacterEntry: envia 1x ao entrar e avisa no global.
    - OnTimerThread: reenvia a cada ~5s enquanto conectado.
  - Payload: 1 string de tamanho fixo (60) com info do player (map/x/y/tick).

- Examples/PacketTest_Client.lua
  - Janela (InterfaceController) com a última INFO recebida.
  - Placeholder: PacketTest_OnClientPacket(head, packetName)

Ponto pendente (precisa do seu core/client)
- A doc enviada não lista qual callback/evento o client usa para receber packets vindos do server.
  Você precisa conectar o evento real do seu client para chamar:
    PacketTest_OnClientPacket(head, packetName)

Mensagem global
- O server usa NoticeGlobalSend(0, ...) para registrar o envio da INFO.

Observações
- O payload do packet está usando SetCharPacketLength (60) por falta de definição de offsets/layout na doc.
- Ajuste PACKET_SUB_INFO se colidir com outro packet do seu projeto.
