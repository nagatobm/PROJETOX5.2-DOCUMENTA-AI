-- ===========================================================================
BridgeFunctionAttach('OnCharacterEntry','WelcomeMessage_OnCharacterEntry')
BridgeFunctionAttach('OnCharacterClose','WelcomeMessage_OnCharacterClose')
-- ===========================================================================

local function SafeCall(fn, defaultValue, ...)
	if type(fn) ~= 'function' then
		return defaultValue
	end
	local ok, result = pcall(fn, ...)
	if not ok then
		return defaultValue
	end
	if result == nil then
		return defaultValue
	end
	return result
end

local function SafeNotice(aIndex, noticeType, message)
	if type(NoticeSend) == 'function' and type(message) == 'string' and message ~= '' then
		NoticeSend(aIndex, noticeType, message)
	end
end

local function SafeNoticeAll(noticeType, message)
	if type(NoticeSendToAll) == 'function' and type(message) == 'string' and message ~= '' then
		NoticeSendToAll(noticeType, message)
	end
end

function WelcomeMessage_OnCharacterEntry(aIndex)
	-- Evita crash caso o índice esteja inválido/desconectado
	if type(GetObjectConnected) == 'function' and GetObjectConnected(aIndex) == 0 then
		return
	end
	
	local UserName = SafeCall(GetObjectName, '', aIndex)
	
	local UserAccountLevel = SafeCall(GetObjectAccountLevel, 0, aIndex)
	
	local UserAccountExpireDate = SafeCall(GetObjectAccountExpireDate, '', aIndex)

	if UserName == '' then
		UserName = 'Player'
	end

	SafeNotice(aIndex, 0, string.format('Bem-vindo, %s! (Sistema Lua ativo)', UserName))

	if UserAccountLevel == 0 then 
		SafeNotice(aIndex, 1, 'Conta Free')
		
	elseif UserAccountLevel == 1 then
		SafeNotice(aIndex, 1, string.format('VIP 1 ativo até: %s', tostring(UserAccountExpireDate)))
		
	elseif UserAccountLevel == 2 then
		SafeNotice(aIndex, 1, string.format('VIP 2 ativo até: %s', tostring(UserAccountExpireDate)))
		
	elseif UserAccountLevel == 3 then
		SafeNotice(aIndex, 1, string.format('VIP 3 ativo até: %s', tostring(UserAccountExpireDate)))
		
	end
	
	local Authority = SafeCall(GetObjectAuthority, 0, aIndex)
	if Authority > 0 then
		SafeNoticeAll(0, string.format('GM %s conectou!', UserName))
	end
	
	SafeNotice(aIndex, 0, 'Scripts Lua carregados: eventos e comandos disponíveis.')
	SafeNotice(aIndex, 0, 'Dica: veja Documentação.md para a lista de APIs e Bridges.')
	
end

function WelcomeMessage_OnCharacterClose(aIndex)
	-- Em alguns cores o player já pode estar desconectado aqui
	if type(GetObjectConnected) == 'function' and GetObjectConnected(aIndex) == 0 then
		return
	end

	local UserName = SafeCall(GetObjectName, '', aIndex)
	
	if UserName == '' then
		UserName = 'Player'
	end

	local Authority = SafeCall(GetObjectAuthority, 0, aIndex)
	if Authority > 0 then
		SafeNoticeAll(0, string.format('GM %s desconectou!', UserName))
	end
end