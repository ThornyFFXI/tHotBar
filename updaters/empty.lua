local Updater = {};

function Updater:New()
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function Updater:Initialize(square, binding)
    self.Binding       = binding;
    self.Square        = square;
    self.StructPointer = square.StructPointer;

    self.StructPointer.Fade = 0;
    self.StructPointer.Cost = '';
    if (binding == nil) then
        self.StructPointer.Macro = square.DefaultMacro;
    else
        self.StructPointer.Macro = binding.MacroText;
    end
    self.StructPointer.Name = '';
    self.StructPointer.Recast = '';
    self.StructPointer.OverlayImage = '';
    self.StructPointer.IconImage = '';
end

function Updater:Destroy()

end

function Updater:Tick()
    
end

return Updater;