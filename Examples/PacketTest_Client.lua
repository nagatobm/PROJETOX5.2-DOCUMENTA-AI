-- PacketTest_Client.lua
-- Teste de packet: Client recebe do server e mostra as informações em uma janela.
--
-- Baseado na sua doc:
-- - Mensagem no chat do client: SendMessageClient (ClienteSide/Client - Interface Function)
--
-- IMPORTANTE:
-- A documentação fornecida NÃO descreve qual evento/bridge o client usa para receber
-- packets vindos do server. Por isso, eu deixei 2 opções:
--
-- (A) Se o seu client chamar uma função Lua ao receber custom packet, conecte essa função
--     ao seu dispatcher/evento real e chame PacketTest_OnClientPacket(head, packetName).
--
-- Como este arquivo é apenas para exibir info recebida, não existe envio Client->Server aqui.

local PACKET_NAME = "PktTest"
local PACKET_SUB_INFO = 0x01
local PAYLOAD_LEN = 60

-- UI (referência: seu Advanced Interface System / InterfaceController)
local Theme = {
  bg = {0.06, 0.07, 0.09, 0.92},
  panel = {0.08, 0.10, 0.14, 0.90},
  line = {0.20, 0.90, 1.00, 0.70},
  accent = {0.95, 0.55, 0.20, 0.92},
  ok = {0.20, 0.85, 0.45, 0.92},
  danger = {0.95, 0.20, 0.25, 0.92},
  text = {255, 255, 255, 255},
  textDim = {185, 200, 215, 255},
}

local UI = {
  titleH = 26,
  pad = 10,
  btnH = 22,
  gap = 8,
}

local MainWindow = {
  enabled = true,
  minimized = false,
  x = 120,
  y = 90,
  width = 360,
  height = 170,
  title = "Packet Test (Client)",
  opacity = 0.95,
  dragging = false,
  dragOffsetX = 0,
  dragOffsetY = 0,
}

local State = {
  lastRecv = "",
  lastAction = "",
  message = "(aguardando...)" ,
  lastHead = "-",
}

local CloseButton = { w = 24, h = 18, y = 4, marginRight = 6 }

local function wideX()
  return (GetWideX and GetWideX() or 0)
end

local function mousePos()
  return (MousePosX and MousePosX() or 0), (MousePosY and MousePosY() or 0)
end

local function clamp(v, a, b)
  if v < a then return a end
  if v > b then return b end
  return v
end

local function hit(mx, my, x, y, w, h)
  return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function setText(rgba)
  if SetTextColor then
    SetTextColor(rgba[1], rgba[2], rgba[3], rgba[4])
  end
end

local function drawRect(x, y, w, h, c)
  if not (DrawBar and EndDrawBar and glColor4f) then return end
  glColor4f(c[1], c[2], c[3], c[4])
  DrawBar(x, y, w, h)
  EndDrawBar()
end

local function drawBorder(x, y, w, h, c)
  if not (DrawBar and EndDrawBar and glColor4f) then return end
  glColor4f(c[1], c[2], c[3], c[4])
  DrawBar(x, y, w, 1)
  DrawBar(x, y + h, w, 1)
  DrawBar(x, y, 1, h)
  DrawBar(x + w, y, 1, h)
  EndDrawBar()
end

local function safeChat(text)
  if SendMessageClient then
    SendMessageClient(text)
  end
end

local function chat(text)
  safeChat(text)
end

-- Chame isso quando o client receber um packet custom do server.
-- head: byte do header (esperado 0xFA se seguir o padrão citado no server)
-- packetName: nome do packet buffer (esperado "PktTest")
function PacketTest_OnClientPacket(head, packetName)
  if tostring(packetName) ~= PACKET_NAME then
    return
  end

  -- Se seu core expõe "sub" em outro lugar, você pode filtrar aqui.
  -- Como a doc do client não lista GetSub, mantemos apenas o nome do packet.

  State.lastHead = tostring(head)

  -- Payload: 1 string de tamanho fixo (PAYLOAD_LEN)
  -- IMPORTANTE: pela implementação (LuaSocket.cpp), para ler string você precisa usar pos < 0.
  local msgObj = GetCharPacketLength(PACKET_NAME, -1, PAYLOAD_LEN)
  local msg = tostring(msgObj or "")

  -- limpa \0 e espaços finais (display)
  msg = msg:gsub("%z", ""):gsub("%s+$", "")

  State.message = msg ~= "" and msg or "(vazio)"
  State.lastRecv = State.message
  State.lastAction = "INFO recebida"
  chat("[PKT] INFO recebida do server")
end

-- Hook real do Socket (conforme LuaSocket.cpp):
-- nInterface.m_Lua.Generic_Call("ClientProtocol", "is>", head, lpMsg->m_PacketName)
-- Para não quebrar outros scripts, encadeia com um handler anterior se existir.
do
  local prev = _G.ClientProtocol
  function ClientProtocol(head, packetName)
    pcall(function()
      PacketTest_OnClientPacket(head, packetName)
    end)

    if type(prev) == "function" then
      return prev(head, packetName)
    end
  end
end

-- =============================
-- UI Handlers (InterfaceController)
-- =============================

local function drawWindow()
  if not MainWindow.enabled then return end
  if EnableAlphaTest then EnableAlphaTest() end
  if GLSwitchBlend then GLSwitchBlend() end

  local ax = MainWindow.x + wideX()
  local a = MainWindow.opacity or 1.0

  -- shadow + panels
  drawRect(ax + 3, MainWindow.y + 3, MainWindow.width, MainWindow.height, {0, 0, 0, 0.30})
  drawRect(ax, MainWindow.y, MainWindow.width, MainWindow.height, {Theme.bg[1], Theme.bg[2], Theme.bg[3], Theme.bg[4] * a})
  drawRect(ax + 1, MainWindow.y + UI.titleH, MainWindow.width - 2, MainWindow.height - UI.titleH - 1, {Theme.panel[1], Theme.panel[2], Theme.panel[3], Theme.panel[4] * a})
  drawBorder(ax, MainWindow.y, MainWindow.width, MainWindow.height, {Theme.line[1], Theme.line[2], Theme.line[3], 0.80})

  if RenderText and SetFontType and SetTextColor then
    SetFontType(1)
    setText(Theme.text)
    RenderText(ax + 10, MainWindow.y + 6, MainWindow.title, MainWindow.width - 50, ALIGN_LEFT or 1)
  end

  -- close button
  local mx, my = mousePos()
  local closeX = ax + MainWindow.width - CloseButton.w - CloseButton.marginRight
  local closeY = MainWindow.y + CloseButton.y
  local hovered = hit(mx, my, closeX, closeY, CloseButton.w, CloseButton.h)
  local cc = hovered and Theme.danger or {Theme.panel[1], Theme.panel[2], Theme.panel[3], 0.95}
  drawRect(closeX, closeY, CloseButton.w, CloseButton.h, {cc[1], cc[2], cc[3], 0.95})
  drawBorder(closeX, closeY, CloseButton.w, CloseButton.h, {Theme.line[1], Theme.line[2], Theme.line[3], hovered and 0.95 or 0.35})
  if RenderText and SetFontType and SetTextColor then
    SetFontType(1)
    setText(Theme.text)
    RenderText(closeX, closeY + 3, "X", CloseButton.w, ALIGN_CENTER or 3)
  end

  if MainWindow.minimized then
    if GLSwitch then GLSwitch() end
    return
  end

  -- content
  local cx = ax + UI.pad
  local cy = MainWindow.y + UI.titleH + UI.pad
  local w = MainWindow.width - UI.pad * 2

  -- info
  if RenderText and SetFontType and SetTextColor then
    SetFontType(0)
    setText(Theme.textDim)
    RenderText(cx, cy, "Status:", w, ALIGN_LEFT or 1)
    setText(Theme.text)
    RenderText(cx, cy + 18, "LastRecv: " .. (State.lastRecv ~= "" and State.lastRecv or "-"), w, ALIGN_LEFT or 1)
    setText(Theme.textDim)
    RenderText(cx, cy + 36, "Action: " .. (State.lastAction ~= "" and State.lastAction or "-"), w, ALIGN_LEFT or 1)
    RenderText(cx, cy + 52, "Head: " .. tostring(State.lastHead or "-"), w, ALIGN_LEFT or 1)
    setText(Theme.ok)
    RenderText(cx, cy + 70, "Msg:", w, ALIGN_LEFT or 1)
    setText(Theme.text)
    RenderText(cx, cy + 88, tostring(State.message or ""), w, ALIGN_LEFT or 1)
    setText(Theme.textDim)
    RenderText(cx, cy + 110, "Dica: o server envia automaticamente", w, ALIGN_LEFT or 1)
  end

  glColor4f(1.0, 1.0, 1.0, 1.0)
  if GLSwitch then GLSwitch() end
end

function PacketTest_InterfaceClickHandler()
  if not MainWindow.enabled or MainWindow.minimized then return end
  local mx, my = mousePos()
  local ax = MainWindow.x + wideX()

  -- close
  local closeX = ax + MainWindow.width - CloseButton.w - CloseButton.marginRight
  local closeY = MainWindow.y + CloseButton.y
  if hit(mx, my, closeX, closeY, CloseButton.w, CloseButton.h) then
    MainWindow.enabled = false
    if PlaySound then PlaySound(2) end
    return
  end

  -- start drag from title
  if hit(mx, my, ax, MainWindow.y, MainWindow.width, UI.titleH) then
    MainWindow.dragging = true
    MainWindow.dragOffsetX = mx - ax
    MainWindow.dragOffsetY = my - MainWindow.y
  end
end

function PacketTest_InterfaceUpdateMouse()
  if not MainWindow.enabled or MainWindow.minimized then
    MainWindow.dragging = false
    return
  end
  if not MainWindow.dragging then return end
  if CheckClickClient and not CheckClickClient() then
    MainWindow.dragging = false
    return
  end
  local mx, my = mousePos()
  local ww = WindowGetWidth and WindowGetWidth() or 800
  local wh = WindowGetHeight and WindowGetHeight() or 600
  local nx = (mx - wideX()) - MainWindow.dragOffsetX
  local ny = my - MainWindow.dragOffsetY
  MainWindow.x = clamp(nx, 0, math.max(0, ww - MainWindow.width))
  MainWindow.y = clamp(ny, 0, math.max(0, wh - MainWindow.height))
end

function PacketTest_InterfaceKeyHandler(key)
  -- F1 alterna janela
  if key == 112 then
    MainWindow.enabled = not MainWindow.enabled
    safeChat("PacketTest UI: " .. (MainWindow.enabled and "ON" or "OFF"))
  end
  -- F2 minimiza
  if key == 113 then
    MainWindow.minimized = not MainWindow.minimized
  end
end

function PacketTest_InterfaceProc()
  drawWindow()
end

local function PacketTest_InterfaceInit()
  safeChat("[PKT] PacketTest_Client carregado (F1 UI)")
end

-- Registro no controller (mesmo padrão do seu script de referência)
if InterfaceController then
  local function safeRegister(handlerType, handlerFunc)
    pcall(function()
      InterfaceController[handlerType](handlerFunc)
    end)
  end

  safeRegister("MainProc", PacketTest_InterfaceProc)
  safeRegister("MainProcWorldKey", PacketTest_InterfaceKeyHandler)
  safeRegister("InterfaceClickEvent", PacketTest_InterfaceClickHandler)
  safeRegister("UpdateMouse", PacketTest_InterfaceUpdateMouse)
  safeRegister("FinalBoot", PacketTest_InterfaceInit)
else
  -- Se não tiver InterfaceController, o sistema de packet ainda funciona via chamadas diretas.
  safeChat("[PKT] Aviso: InterfaceController não encontrado (sem UI)")
end
