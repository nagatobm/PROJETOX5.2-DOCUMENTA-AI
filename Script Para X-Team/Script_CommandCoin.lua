
BridgeFunctionAttach("OnCommandManager","Coin_CommandManager");

Coin_CommandManager = function(aIndex, code, arg)

	if code == 114 then
	
		SQLQuery("SELECT leilao FROM MEMB_INFO WHERE memb___id = '"..GetObjectAccount(aIndex).."'");
		SQLFetch();
		local aValue = tonumber(SQLGetNumber("leilao"));
		SQLClose();
	
		NoticeSend(aIndex, 1, string.format("[Bank]: Você possui %d moedas de leilão.", aValue));
		
		return 1;
		
	end

	return 0;
	
end