-- PacketTest_Server.lua
-- Teste de packet: Server -> Client, com logs em notice global.
--
-- Baseado na sua doc:
-- - Envio de packet: CreatePacket/Set*/SendPacket/ClearPacket (ServerSide/Packets Function)
-- - Mensagem global: NoticeGlobalSend / GlobalPostSend (ServerSide/Server - Function)
--
-- IMPORTANTE:
-- IMPORTANTE:
-- A doc não define o layout exato do payload/offsets.
-- Para evitar ambiguidade, este teste envia 1 string de tamanho fixo via SetCharPacketLength.

local PACKET_NAME = "PktTest"
local PACKET_SUB_INFO = 0x01
local PAYLOAD_LEN = 60

local SEND_INTERVAL_MS = 5000
local _lastSentTick = {}

local _packetFnsReady = nil
local _packetFnsWarned = false
local _sendWarned = false

local function resolve_packet_fns()
  if _packetFnsReady ~= nil then
    return _packetFnsReady
  end

  local create = _G.CreatePacket
  local setCharLen = _G.SetCharPacketLength
  local send = _G.SendPacket
  local clear = _G.ClearPacket

  -- Alguns cores expõem via tabela (ex: Packet.CreatePacket ou Packets.CreatePacket)
  if (not create) or (not setCharLen) or (not send) or (not clear) then
    local container = _G.Packet or _G.Packets
    if container then
      create = create or container.CreatePacket
      setCharLen = setCharLen or container.SetCharPacketLength
      send = send or container.SendPacket
      clear = clear or container.ClearPacket
    end
  end

  -- Fallback: varre _G procurando uma tabela que tenha todas as funções.
  if (not create) or (not setCharLen) or (not send) or (not clear) then
    for _, v in pairs(_G) do
      if type(v) == "table" then
        local c = v.CreatePacket
        local s = v.SetCharPacketLength
        local sp = v.SendPacket
        local cl = v.ClearPacket
        if type(c) == "function" and type(s) == "function" and type(sp) == "function" and type(cl) == "function" then
          create, setCharLen, send, clear = c, s, sp, cl
          break
        end
      end
    end
  end

  _packetFnsReady = (type(create) == "function")
    and (type(setCharLen) == "function")
    and (type(send) == "function")
    and (type(clear) == "function")

  if _packetFnsReady then
    -- cache as globals for use
    _G.__PKT_CreatePacket = create
    _G.__PKT_SetCharPacketLength = setCharLen
    _G.__PKT_SendPacket = send
    _G.__PKT_ClearPacket = clear
  end

  return _packetFnsReady
end

local function global_msg(text)
  -- type: 0 (padrão, conforme exemplos da doc)
  NoticeGlobalSend(0, text)
end

local function normalize_len(text, len)
  local s = tostring(text or "")
  if #s > len then
    return string.sub(s, 1, len)
  end
  if #s < len then
    return s .. string.rep(" ", len - #s)
  end
  return s
end

local function send_info_to_client(aIndex, payload)
  if not resolve_packet_fns() then
    if not _packetFnsWarned then
      _packetFnsWarned = true
      LogPrint("[PKT] ERRO: funções de packet não encontradas (CreatePacket/SetCharPacketLength/SendPacket/ClearPacket)")
      LogPrint("[PKT] Dica: verifique se o módulo/sistema de packets está carregado no servidor.")
      pcall(NoticeGlobalSend, 0, "[PKT] ERRO: servidor sem funcoes de packet (nao enviou ao client)")
    end
    return
  end

  -- Por segurança: se existir lixo antigo com o mesmo nome, limpe antes.
  pcall(_G.__PKT_ClearPacket, PACKET_NAME)

  _G.__PKT_CreatePacket(PACKET_NAME, PACKET_SUB_INFO)
  _G.__PKT_SetCharPacketLength(PACKET_NAME, normalize_len(payload, PAYLOAD_LEN), PAYLOAD_LEN)

  -- Alguns cores usam SendPacket(packetName, aIndex) (server), outros SendPacket(packetName) (client/socket).
  -- Tentamos com aIndex e, se falhar, tentamos sem.
  local ok = pcall(_G.__PKT_SendPacket, PACKET_NAME, aIndex)
  if not ok then
    ok = pcall(_G.__PKT_SendPacket, PACKET_NAME)
  end

  pcall(_G.__PKT_ClearPacket, PACKET_NAME)

  if not ok then
    LogPrint("[PKT] ERRO: SendPacket falhou (assinatura incompatível?)")
    if not _sendWarned then
      _sendWarned = true
      pcall(NoticeGlobalSend, 0, "[PKT] ERRO: SendPacket falhou (nao enviou ao client)")
    end
  end
end

local function build_payload(aIndex)
  local name = UserGetName(aIndex)
  local tick = tonumber(GetTickCount()) or 0
  local map = tonumber(UserGetMap(aIndex)) or 0
  local x = tonumber(UserGetX(aIndex)) or 0
  local y = tonumber(UserGetY(aIndex)) or 0
  return string.format("Name:%s Map:%d X:%d Y:%d T:%d", tostring(name), map, x, y, tick)
end

local function maybe_send(aIndex, now)
  if GetObjectConnected(aIndex) == 0 then
    return
  end

  local last = _lastSentTick[aIndex]
  if last ~= nil and (now - last) < SEND_INTERVAL_MS then
    return
  end

  local payload = build_payload(aIndex)
  send_info_to_client(aIndex, payload)
  _lastSentTick[aIndex] = now
  LogPrint(string.format("[PKT] auto-send to %s payload=%s", tostring(UserGetName(aIndex)), payload))
end

function PacketTest_OnCharacterEntry(aIndex)
  local now = tonumber(GetTickCount()) or 0
  maybe_send(aIndex, now)

  -- 1 aviso global ao entrar (evita spam no timer)
  global_msg(string.format("[PKT] INFO automática ativa p/ %s", tostring(UserGetName(aIndex))))
end

function PacketTest_OnCharacterClose(aIndex)
  _lastSentTick[aIndex] = nil
end

function PacketTest_OnTimerThread()
  local now = tonumber(GetTickCount()) or 0
  for i = GetMinUserIndex(), GetMaxUserIndex() - 1 do
    if GetObjectConnected(i) == 1 then
      maybe_send(i, now)
    end
  end
end

function PacketTest_OnReadScript()
  local ready = resolve_packet_fns()
  LogPrint("[PKT] PacketTest_Server carregado. Envio automático ativo")
  if not ready then
    LogPrint("[PKT] ATENÇÃO: funções de packet ainda não disponíveis no OnReadScript")
  end
end

-- Registros (ScriptCore)
BridgeFunctionAttach("OnReadScript", "PacketTest_OnReadScript")
BridgeFunctionAttach("OnCharacterEntry", "PacketTest_OnCharacterEntry")
BridgeFunctionAttach("OnCharacterClose", "PacketTest_OnCharacterClose")
BridgeFunctionAttach("OnTimerThread", "PacketTest_OnTimerThread")
