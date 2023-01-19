local Updater = {};

local AbilityRecastPointer = ashita.memory.find('FFXiMain.dll', 0, '894124E9????????8B46??6A006A00508BCEE8', 0x19, 0);
AbilityRecastPointer = ashita.memory.read_uint32(AbilityRecastPointer);

local function ItemCost(updater, itemId)
    local resource = AshitaCore:GetResourceManager():GetItemById(itemId);
    local containers = T{ 0 };
    if (bit.band(resource.Flags, 0x800) ~= 0) then
        containers = T { 0, 8, 10, 11, 12, 13, 14, 15, 16 };
    end
    
    local invMgr = AshitaCore:GetMemoryManager():GetInventory();
    local itemCount = 0;
    for _,c in ipairs(containers) do
        for i = 1,80 do
            local item = invMgr:GetContainerItem(c, i);
            if (item ~= nil) and (item.Id == itemId) then
                itemCount = itemCount + item.Count;            
            end
        end
    end

    if (updater.Cost) then
        updater.Cost.text = tostring(itemCount);
        updater.Cost.visible = true;
    end

    return itemCount > 0;
end

local function ChargeCost(updater, recastReady)
    if (updater.Cost) then
        if (recastReady == nil) then
            updater.Cost.visible = false;
        else
            updater.Cost.text = tostring(recastReady);
            updater.Cost.visible = true;
        end
    end
    return (type(recastReady) == 'number') and (recastReady > 0);
end

local function FinishingMoveCost(updater, minimumMoves)
    local finishingMoves = 0;

    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local buffs = player:GetBuffs();
    local moveMap = {
        [381] = 1,
        [382] = 2,
        [383] = 3,
        [384] = 4,
        [385] = 5,
        [588] = 6
    };
    for i=1,32 do
        local count = moveMap[buffs[i]];
        if count ~= nil then
            finishingMoves = count;
        end
    end

    if (updater.Cost) then
        updater.Cost.text = tostring(finishingMoves);
        updater.Cost.visible = true;
    end

    return (finishingMoves >= minimumMoves);
end

local function RuneEnchantmentCost(updater)
    local runeCount = 0;

    local player = AshitaCore:GetMemoryManager():GetPlayer()
    local buffs = player:GetBuffs();
    for i=1,32 do
        local buff = buffs[i];
        if (buff > 522) and (buff < 531) then
            runeCount = runeCount + 1;
        end
    end

    if (updater.Cost) then
        updater.Cost.text = tostring(runeCount);
        updater.Cost.visible = true;
    end

    return (runeCount > 0);
end

local function GetAbilityTimerData(id)
    for i = 1,31 do
        local compId = ashita.memory.read_uint8(AbilityRecastPointer + (i * 8) + 3);
        if (compId == id) then
            return {
                Modifier = ashita.memory.read_uint32(AbilityRecastPointer + (i * 8) + 4);
                Recast = ashita.memory.read_uint32(AbilityRecastPointer + (i * 4) + 0xF8);
            };
        end
    end
    
    return {
        Modifier = 0,
        Recast = 0
    };
end

local function GetAbilityAvailable(resource)
    return AshitaCore:GetMemoryManager():GetPlayer():HasAbility(resource.Id);
end

local function GetAbilityCostMet(resource)
    if (resource.TPCost == 0) then
        return true;
    end
    return (AshitaCore:GetMemoryManager():GetParty():GetMemberTP(0) >= resource.TPCost);
end

--Returns the max number of stratagems and the recast time per stratagem.
local function GetStratagemCalculations()
    local playMgr = AshitaCore:GetMemoryManager():GetPlayer();
    local schLevel = playMgr:GetMainJobLevel();
    if (playMgr:GetMainJob() ~= 20) then
        if (playMgr:GetSubJob() == 20) then
            schLevel = playMgr:GetSubJobLevel();
        else
            return 0, 0;
        end
    end

    if (schLevel == 99) and (gPlayer:GetJobPointTotal(20) >= 550) then
        return 5, 33 * 60;
    elseif (schLevel >= 90) then
        return 5, 48 * 60;
    elseif (schLevel >= 70) then
        return 4, 60 * 60;
    elseif (schLevel >= 50) then
        return 3, 80 * 60;
    elseif (schLevel >= 30) then
        return 2, 120 * 60;
    else
        return 1, 240 * 60;
    end
end


local function GetRecastTimer(timerId)
    local mmRecast  = AshitaCore:GetMemoryManager():GetRecast();

    if (timerId == 0) then
        return mmRecast:GetAbilityTimer(0);
    end

    for x = 1, 31 do
        local id = mmRecast:GetAbilityTimerId(x);
        local timer = mmRecast:GetAbilityTimer(x);

        if (id == timerId) then
            return timer;
        end
    end

    return 0;
end

local function RecastToString(timer)
    if (timer >= 216000) then
        local h = math.floor(timer / (216000));
        local m = math.floor(timer / 3600);
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

--This call returns two values.
--First value is true/false for whether ability can be used based on current recast, to be used for dimming icons.
--Second value is a string to be displayed on recast element, or nil if the element should not be shown.
local function GetRecastData(resource)
    local timer = GetRecastTimer(resource.RecastTimerId);
    if (timer == 0) then
        return true, nil;
    else
        return false, RecastToString(timer);
    end
end


--Each of these calls returns two values.
--First value is number of charges available.
--Second value is time until next charge.
local function GetStratagemData()
    local count, recast = GetStratagemCalculations();
    if (count == 0) then
        return nil;
    end

    local timer = GetRecastTimer(231);
    if (timer == 0) then
        return count, recast;
    end

    local maxRecast = count * recast;
    local expendedRecast = maxRecast - timer;
    local availableStratagems = math.floor(expendedRecast / recast);
    local nextStratagem = math.fmod(timer, recast);
    return availableStratagems, RecastToString(nextStratagem);
end

local function GetQuickDrawData()
    local data = GetAbilityTimerData(195);
    if (data.Modifier == 0) and (data.Recast == 0) then
        return nil;
    end
    
    local baseRecast = 60 * (120 + data.Modifier);
    local chargeValue = baseRecast / 2;
    local timer = data.Recast;
    if timer == 0 then
        return 2, chargeValue;
    end

    local remainingCharges = math.floor((baseRecast - data.Recast) / chargeValue);
    local timeUntilNextCharge = math.fmod(data.Recast, chargeValue);
    return remainingCharges, RecastToString(timeUntilNextCharge);
end

local function GetReadyData()
    local data = GetAbilityTimerData(102);
    if (data.Modifier == 0) and (data.Recast == 0) then
        return nil;
    end

    local baseRecast = 60 * (90 + data.Modifier);
    local chargeValue = baseRecast / 3;
    local timer = data.Recast;
    if timer == 0 then
        return 3, chargeValue;
    end

    local remainingCharges = math.floor((baseRecast - data.Recast) / chargeValue);
    local timeUntilNextCharge = math.fmod(data.Recast, chargeValue);
    return remainingCharges, RecastToString(timeUntilNextCharge);
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
    self.Resource = AshitaCore:GetResourceManager():GetAbilityById(self.Binding.ActionId + 512);

    if (self.Cost) then
        if (self.Resource.TPCost > 0) then
            self.Cost.text = tostring(self.Resource.TPCost);
            self.Cost.visible = true;
        else
            self.Cost.visible = false;
        end
    end
    
    --Set recast function based on what the ability is.
    if (self.Resource.RecastTimerId == 102) then
        self.RecastFunction = GetReadyData;
        self.CostFunction = ChargeCost;
    elseif (self.Resource.RecastTimerId == 195) then
        self.RecastFunction = GetQuickDrawData;
        self.CostFunction = ChargeCost;
    elseif (self.Resource.RecastTimerId == 231) then
        self.RecastFunction = GetStratagemData;
        self.CostFunction = ChargeCost;
    else
        self.RecastFunction = GetRecastData;
    end

    if (self.Binding) then
        local flourishes = T{
            [204] = 1,
            [205] = 1,
            [206] = 1,
            [207] = 1,
            [208] = 1,
            [209] = 2,
            [264] = 1,
            [313] = 2,
            [314] = 3
        };
        local flourish = flourishes[self.Binding.ActionId];

        --Custom (for use with jugs and such)
        if (self.Binding.Item) then
            self.CostFunction = ItemCost:bind2(self.Binding.Item);

        --Angon
        elseif (self.Binding.ActionId == 170) then
            self.CostFunction = ItemCost:bind2(18259);

        --Tomahawk
        elseif (self.Binding.ActionId == 150) then
            self.CostFunction = ItemCost:bind2(18258);

        --Finishing Moves
        elseif flourish ~= nil then
            self.CostFunction = FinishingMoveCost:bind2(flourish);

        --Rune Enchantment
        elseif T{ 344, 366, 368, 369, 371, 372, 373, 375, 376 }:contains(self.Binding.ActionId) then
            self.CostFunction = RuneEnchantmentCost;
        end
    end
end

function Updater:Destroy()

end

function Updater:Render()
    --RecastReady will hold number of charges for charged abilities.
    local recastReady, recastDisplay = self.RecastFunction(self.Resource);
    local abilityAvailable           = GetAbilityAvailable(self.Resource);
    local abilityCostMet             = GetAbilityCostMet(self.Resource) and abilityAvailable;

    if self.Activation then
        if (self.Square.ActivationTimer > os.clock()) then
            self.Activation.visible = true;
        else
            self.Activation.visible = false;
        end
    end

    --recastReady being passed in to save multiple calculations of charges on charged abilities.
    if (self.CostFunction) then
        if not self:CostFunction(recastReady) then
            abilityCostMet = false;
        end
    end

    if self.Cross then
        if abilityAvailable == false then
            self.Cross.visible = true;
        else
            self.Cross.visible = false;
        end
    end

    if self.Recast then
        if (type(recastDisplay) ~= 'string') then
            self.Recast.visible = false;
        else
            self.Recast.text = recastDisplay;
            self.Recast.visible = true;
        end
    end

    if self.Icon then
        if abilityCostMet then
            self.Icon.color = self.OpaqueColor;
        else
            self.Icon.color = self.DimmedColor;
        end
    end
end

return Updater;