local Updater = {};

function Updater:New()
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function Updater:Initialize(square)
    self.Binding = square.Binding;
    self.Square  = square;
    
end

function Updater:Destroy()

end

function Updater:Render()

end

return Updater;