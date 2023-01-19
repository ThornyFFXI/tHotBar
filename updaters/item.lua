local Updater = {};

local vanaOffset = 0x3C307D70;
local timePointer = ashita.memory.find('FFXiMain.dll', 0, '8B0D????????8B410C8B49108D04808D04808D04808D04C1C3', 2, 0);

local function GetTimeUTC()
    local ptr = ashita.memory.read_uint32(timePointer);
    ptr = ashita.memory.read_uint32(ptr);
    return ashita.memory.read_uint32(ptr + 0x0C);
end

local function GetRecastTimer(item)
    local resource = AshitaCore:GetResourceManager():GetItemById(item.Id);
    local currentTime = GetTimeUTC();
    local useTime = (struct.unpack('L', item.Extra, 5) + vanaOffset) - currentTime;
    if (useTime < -1) then
        useTime = 0;
    elseif (useTime == -1) then
        useTime = 1;
    end

    local equipTime;
    if (item.Flags == 5) then
        equipTime = (struct.unpack('L', item.Extra, 9) + vanaOffset) - currentTime;
        if (equipTime < -1) then
            equipTime = 0;
        elseif (equipTime == -1) then
            equipTime = 1;
        end
    else
        equipTime = resource.CastDelay;
    end
    return math.max(useTime, equipTime);
end

local function GetItemRecast(itemId)
    local resource = AshitaCore:GetResourceManager():GetItemById(itemId);
    local containers = T{ 0, 3 };
    local lowestRecast = 0;
    if (bit.band(resource.Flags, 0x800) ~= 0) then
        containers = T { 0, 8, 10, 11, 12, 13, 14, 15, 16 };
        lowestRecast = -1;
    end

    --Item is equippable.. so need to find a copy and check extdata.
    local invMgr = AshitaCore:GetMemoryManager():GetInventory();
    local count = 0;
    for _,c in ipairs(containers) do
        for i = 1,80 do
            local item = invMgr:GetContainerItem(c, i);
            if (item ~= nil) and (item.Id == itemId) then
                count = count + item.Count;
                if (lowestRecast ~= 0) then
                    local recast = GetRecastTimer(item);
                    if (lowestRecast == -1) or (recast < lowestRecast) then
                        lowestRecast = recast;
                    end
                end
            end
        end
    end
    
    return count, lowestRecast;
end

--Item timer is in full seconds not frames.
local function RecastToString(timer)
    if (timer >= 3600) then
        local h = math.floor(timer / (3600));
        local m = math.floor(timer / 60);
        return string.format('%i:%02i', h, m);
    elseif (timer >= 60) then
        local m = math.floor(timer / 60);
        local s = math.fmod(timer, 60);
        return string.format('%i:%02i', m, s);
    else
        return string.format('%i', timer);
    end
end

function Updater:New()
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function Updater:Initialize(square)
    self.Binding = square.Binding;
    self.Square  = square;
    self.Resource = AshitaCore:GetResourceManager():GetItemById(self.Binding.ActionId);
end

function Updater:Destroy()

end

function Updater:Render()
    --RecastReady will hold number of charges for charged abilities.
    local count, recastTimer = GetItemRecast(self.Resource.Id);

    if self.Activation then
        if (self.Square.ActivationTimer > os.clock()) then
            self.Activation.visible = true;
        else
            self.Activation.visible = false;
        end
    end
    
    if (self.Cost) then
        self.Cost.text = tostring(count);
        self.Cost.visible = true;
    end

    if self.Recast then
        if (recastTimer < 1) then
            self.Recast.visible = false;
        else
            self.Recast.text = RecastToString(recastTimer);
            self.Recast.visible = true;
        end
    end

    if self.Icon then
        if (recastTimer == 0) and (count > 0) then
            self.Icon.color = self.OpaqueColor;
        else
            self.Icon.color = self.DimmedColor;
        end
    end
end

return Updater;