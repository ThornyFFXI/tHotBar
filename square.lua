local updaters     = {
    ['Ability']     = require('updaters.ability'),
    ['Empty']       = require('updaters.empty'),
    ['Item']        = require('updaters.item'),
    ['Spell']       = require('updaters.spell'),
    ['Test']      = require('updaters.test'),
    ['Weaponskill'] = require('updaters.weaponskill'),
};

local Square = {};

function Square:New(structPointer, defaultMacro)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.StructPointer = structPointer;
    local updater = updaters.Empty;
    o.DefaultMacro = defaultMacro;
    o.Updater = updater:New();
    o.Updater:Initialize(o);
    return o;
end

function Square:Destroy()
    self.Updater:Destroy();
end

function Square:Update()
    self.Updater:Tick();
end

function Square:UpdateBinding(binding)
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