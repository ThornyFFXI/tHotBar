local Updater = {};

function Updater:New()
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

local function RecastToString(timer)
    if (timer >= 216000) then
        local h = math.floor(timer / (216000));
        local m = math.floor(math.fmod(timer, 216000) / 3600);
        return string.format('%i:%02i', h, m);
    elseif (timer >= 3600) then
        local m = math.floor(timer / 3600);
        local s = math.ceil(math.fmod(timer, 3600) / 60);
        return string.format('%i:%02i', m, s);
    else
        local s = math.ceil(timer / 60);
        return string.format('%i', s);
    end
end

function Updater:Initialize(square, binding)
    self.Binding       = binding;
    self.Square        = square;
    self.StructPointer = square.StructPointer;

    self.StructPointer.Fade = 0;
    self.StructPointer.Cost = '592';
    if (binding == nil) then
        self.StructPointer.Macro = square.DefaultMacro;
    else
        self.StructPointer.Macro = binding.MacroText;
    end
    self.StructPointer.Name = 'Test';
    self.StructPointer.Recast = '45:00';
    self.StructPointer.OverlayImage = '';
    self.StructPointer.IconImage = '';
end

function Updater:Destroy()

end

function Updater:Tick()
    if (math.random(1, 200) == 20) then
        self.StructPointer.Cost = tostring(math.random(1, 150));
        self.StructPointer.Recast = RecastToString(math.random(1, 432000));
    end
    if (math.random(1, 1000) == 50) then

        --[[
        local statusId = math.random(1,300);
        while (AshitaCore:GetResourceManager():GetStatusIconById(statusId) == nil) do
            statusId = math.random(1,300);
        end
        self.StructPointer.IconImage = string.format('STATUS:%u', statusId);
        ]]--

        if (math.random(1, 2) == 1) then
            local iconIndex = math.random(31, 970);
            local iconPath = string.format('%saddons//%s//resources//abilities//%u.png', AshitaCore:GetInstallPath(), addon.name, iconIndex);
            while (not ashita.fs.exists(iconPath)) do
                iconIndex = math.random(31, 970);
                iconPath = string.format('%saddons//%s//resources//abilities//%u.png', AshitaCore:GetInstallPath(), addon.name, iconIndex);        
            end
            self.StructPointer.IconImage = iconPath;
        else
            local itemId = math.random(1,2000);
            while (AshitaCore:GetResourceManager():GetItemById(itemId) == nil) do
                itemId = math.random(1,2000);
            end
            self.StructPointer.IconImage = string.format('ITEM:%u', itemId);
        end
    end
end

return Updater;