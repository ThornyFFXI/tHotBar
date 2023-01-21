local updaters     = {
    ['Ability']     = require('updaters.ability'),
    ['Command']     = require('updaters.command'),
    ['Empty']       = require('updaters.empty'),
    ['Item']        = require('updaters.item'),
    ['Spell']       = require('updaters.spell'),
    ['Test']        = require('updaters.test'),
    ['Trust']       = require('updaters.trust'),
    ['Weaponskill'] = require('updaters.weaponskill'),
};

local modifiers = T{
    ['%!'] = 'alt',
    ['%^'] = 'ctrl',
    ['%@'] = 'win',
    ['%#'] = 'apps',
    ['%+'] = 'shift'
};

local function bind(hotkey, index)
    local defaults = {
        alt = false,
        ctrl = false,
        win = false,
        apps = false,
        shift =  false
    };

    local working = hotkey;
    for key,entry in pairs(modifiers) do
        local newString = string.gsub(working, key, '');
        if (newString ~= working) then
            defaults[entry] = true;
            working = newString;
        end
    end

    local kb = AshitaCore:GetInputManager():GetKeyboard();
    kb:Bind(kb:S2D(string.sub(working, 1, 1)), true, defaults.alt, defaults.apps, defaults.ctrl, defaults.shift, defaults.win,
    string.format('/tb activate %u', index));
end

local function unbind(hotkey)
    local defaults = {
        alt = false,
        ctrl = false,
        win = false,
        apps = false,
        shift =  false
    };

    local working = hotkey;
    for key,entry in pairs(modifiers) do
        local newString = string.gsub(working, key, '');
        if (newString ~= working) then
            defaults[entry] = true;
            working = newString;
        end
    end

    local kb = AshitaCore:GetInputManager():GetKeyboard();
    kb:Unbind(kb:S2D(working[1]), true, defaults.alt, defaults.apps, defaults.ctrl, defaults.shift, defaults.win);
end

local function DoMacro(macro)
    for _,line in ipairs(macro) do
        if (string.sub(line, 1, 6) == '/wait ') then
            local waitTime = tonumber(string.sub(line, 7));
            if type(waitTime) == 'number' then
                if (waitTime < 0.1) then
                    coroutine.sleepf(1);
                else
                    coroutine.sleep(waitTime);
                end
            end
        else
            AshitaCore:GetChatManager():QueueCommand(-1, line);
        end
    end
end

local Square = {};

function Square:New(structPointer, hotkey, index)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.StructPointer = structPointer;
    local updater = updaters.Empty;
    o.Activation = 0;
    o.Hotkey = hotkey;
    o.Index = index;
    if (o.Hotkey ~= '') then
        bind(o.Hotkey, o.Index);
    end
    o.Updater = updater:New();
    o.Updater:Initialize(o);
    return o;
end

function Square:Activate()
    self.Activation = os.clock() + 0.25;
    if (self.Binding ~= nil) then
        DoMacro:bind1(self.Binding.Macro):oncef(0);
    end
end

function Square:Bind()
    gBindingGUI:Show(self.Hotkey, self.Binding);
end

function Square:Destroy()
    if (self.Hotkey ~= '') then
        unbind(self.Hotkey);
    end
    self.Updater:Destroy();
end

function Square:Update()
    self.Updater:Tick();
end

function Square:UpdateBinding(binding)
    if (binding == self.Binding) then
        return;
    end

    if (self.Updater ~= nil) then
        self.Updater:Destroy();
    end

    self.Binding = binding;
    local updater = updaters.Empty;
    if (type(self.Binding) == 'table') and (self.Binding.ActionType ~= nil) then
        local newUpdater = updaters[self.Binding.ActionType];
        if (newUpdater ~= nil) then
            updater = newUpdater;
        end
    end

    self.Updater = updater:New();
    self.Updater:Initialize(self, self.Binding);
end

return Square;