BridgeFunctionAttach("OnCommandManager", "Arrow_Command");

Arrow_Command = function(aIndex, code, arg)

    local qntd      = CommandGetArgNumber(arg, 0) > 0 and CommandGetArgNumber(arg, 0) or 0;
    local FreeSlot  = InventoryGetFreeSlotCount(aIndex);

    if (code == 115) then

        if FreeSlot > 0 and qntd <= FreeSlot or FreeSlot > 0 and qntd == 0 then

            if qntd > 0 then

                for x = 1, qntd, 1 do 
                    ItemGiveEx(aIndex,2063,9,255,0,0,0,0);
                end;

                NoticeSend(aIndex, 1, string.format("Você recebeu %dx255 arrows.", qntd));

            else

                ItemGiveEx(aIndex,2063,9,255,0,0,0,0);
                NoticeSend(aIndex, 1, "Você recebeu 255 arrows.");

            end;

        else

            NoticeSend(aIndex, 1, "Você não possui espaço suficiente no inventário.");

        end;
        
        return 1;
        
    elseif (code == 116) then

        if FreeSlot > 0 and qntd <= FreeSlot or FreeSlot > 0 and qntd == 0 then

            if qntd > 0 then

                for x = 1, qntd, 1 do 
                    ItemGiveEx(aIndex,2055,9,255,0,0,0,0);
                end;

                NoticeSend(aIndex, 1, string.format("Você recebeu %dx255 bolts.", qntd));

            else

                ItemGiveEx(aIndex,2055,9,255,0,0,0,0);
                NoticeSend(aIndex, 1, "Você recebeu 255 bolts.");

            end;

        else

            NoticeSend(aIndex, 1, "Você não possui espaço suficiente no inventário.");

        end;

        return 1; 

    end;

    return 0;

end;