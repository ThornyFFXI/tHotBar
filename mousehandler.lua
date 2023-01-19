local lastPositionX, lastPositionY;
local dragActive = false;
local blockLeftClick = false;

ffi.cdef[[
    int16_t GetKeyState(int32_t vkey);
]]

ashita.events.register('mouse', 'mouse_cb', function (e)
    if (e.blocked) then
        return;
    end
    
    if dragActive then
        gSettings.PositionX = gSettings.PositionX + (e.x - lastPositionX);
        gSettings.PositionY = gSettings.PositionY + (e.y - lastPositionY);
        lastPositionX = e.x;
        lastPositionY = e.y;
        if (e.message == 514) or (bit.band(ffi.C.GetKeyState(0x10), 0x8000) == 0) then
            dragActive = false;
            e.blocked = true;
            blockLeftClick = false;
            settings.save();
            return;
        end        
    end

    local manager = gInterface:GetSquareManager();
    if (manager ~= nil) and (e.message == 513) then
        local hitFrame, hitSquare = manager:HitTest(e.x, e.y);
        if (hitFrame) then
            e.blocked = true;
            blockLeftClick = true;

            if (bit.band(ffi.C.GetKeyState(0x10), 0x8000) ~= 0) then
                dragActive = true;
                lastPositionX = e.x;
                lastPositionY = e.y;
                return;
            end

            if (hitSquare ~= nil) then
                if (bit.band(ffi.C.GetKeyState(0x11), 0x8000) ~= 0) then
                    hitSquare:
                    print(string.format('Bind:%u', hitSquare.Index));
                else
                    print(string.format('Activate:%u', hitSquare.Index));
                end
                return;
            end
        end
    end

    if (blockLeftClick) and (e.message == 514) then
        e.blocked = true;
        blockLeftClick = false;
    end
end);