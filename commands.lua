ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0 or string.lower(args[1]) ~= '/tb') then
        return;
    end
    e.blocked = true;

    if (#args == 1) then
        gConfigGUI:Show();
        return;
    end

    if (#args > 1) and (string.lower(args[2]) == 'activate') then
        if (#args > 2) then
            local macroIndex = tonumber(args[3]);
            gInterface:GetSquareManager():Activate(macroIndex);
        end
        return;
    end

    if (#args > 1) and (string.lower(args[2]) == 'palette') then
        gBindings:HandleCommand(args);
        return;
    end
end);