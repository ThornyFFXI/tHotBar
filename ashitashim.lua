local AshitaShim = { };

function AshitaShim:KbBind(kb, key, down, alt, apps, ctrl, shift, win, command)
    if ashita.interface_version < 4.3 then
        return kb:Bind(key, down, alt, apps, ctrl, shift, win, command)
    else
        return kb:Bind(key, down, alt, apps, ctrl, shift, win, true, false, command)
    end
end

function AshitaShim:KbUnbind(kb, key, down, alt, apps, ctrl, shift, win)
    if ashita.interface_version < 4.3 then
        return kb:Unbind(key, down, alt, apps, ctrl, shift, win)
    else
        return kb:Unbind(key, down, alt, apps, ctrl, shift, win, true, false)
    end
end

function AshitaShim:ImGUIBeginChild(imgui, childId, size, borders)
    if ashita.interface_version < 4.3 then
        return imgui.BeginChild(childId, size, false);
    else
        return imgui.BeginChild(childId, size, borders);
    end
end

return AshitaShim;
