local square    = require('square');
local primitives = require('primitives');
local structOffset = 12;
local structWidth = 1156;

--Thanks to Velyn for the event system and interface hidden signatures!
local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, "8B480C85C974??8B510885D274??3B05", 16, 0);
local pEventSystem = ashita.memory.find('FFXiMain.dll', 0, "A0????????84C0741AA1????????85C0741166A1????????663B05????????0F94C0C3", 0, 0);
local pInterfaceHidden = ashita.memory.find('FFXiMain.dll', 0, "8B4424046A016A0050B9????????E8????????F6D81BC040C3", 0, 0);

local function GetMenuName()
    local subPointer = ashita.memory.read_uint32(pGameMenu);
    local subValue = ashita.memory.read_uint32(subPointer);
    if (subValue == 0) then
        return '';
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4);
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16);
    return string.gsub(menuName, '\x00', '');
end

local function GetEventSystemActive()
    if (pEventSystem == 0) then
        return false;
    end
    local ptr = ashita.memory.read_uint32(pEventSystem + 1);
    if (ptr == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(ptr) == 1);

end

local function GetInterfaceHidden()
    if (pEventSystem == 0) then
        return false;
    end
    local ptr = ashita.memory.read_uint32(pInterfaceHidden + 10);
    if (ptr == 0) then
        return false;
    end

    return (ashita.memory.read_uint8(ptr + 0xB4) == 1);
end

local SquareManager = {};
SquareManager.Squares = T{};

function SquareManager:Initialize(layout, pluginStruct)
    self.PluginStruct = ffi.cast('AbilitySquarePanelState_t*', pluginStruct);
    self.Layout = layout;
    self.Hidden = false;

    local count = 0;
    self.Squares = T{};
    local bindSetting = AshitaCore:GetInputManager():GetKeyboard():GetSilentBinds();
    AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(true);
    for _,squareInfo in ipairs(layout.Squares) do
        local newSquare = square:New(ffi.cast('AbilitySquareState_t*', pluginStruct + structOffset + (structWidth * count)), squareInfo.DefaultMacro, count + 1);
        count = count + 1;
        newSquare.MinX = squareInfo.OffsetX + layout.ImageObjects.Frame.OffsetX;
        newSquare.MaxX = newSquare.MinX + layout.ImageObjects.Frame.Width;
        newSquare.MinY = squareInfo.OffsetY + layout.ImageObjects.Frame.OffsetY;
        newSquare.MaxY = newSquare.MinY + layout.ImageObjects.Frame.Height;
        self.Squares:append(newSquare);
    end
    AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(bindSetting);

    self.Primitive = primitives.new(layout.Background)
end

function SquareManager:Activate(index)
    local square = self.Squares[index];
    if square then
        square:Activate();
    end
end

function SquareManager:Destroy()
    local bindSetting = AshitaCore:GetInputManager():GetKeyboard():GetSilentBinds();
    AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(true);
    for _,square in ipairs(self.Squares) do
        square:Destroy();
    end
    AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(bindSetting);
    
    if (self.Primitive ~= nil) then
        self.Primitive:destroy();
        self.Primitive = nil;
    end

    self.PluginStruct = nil;
end

function SquareManager:GetHidden()
    if (self.PluginStruct == nil) then
        return true;
    end

    if (gSettings.HideWhileZoning) then
        if (gPlayer:GetLoggedIn() == false) then
            return true;
        end
    end

    if (gSettings.HideWhileCutscene) then
        if (GetEventSystemActive()) then
            return true;
        end
    end

    if (gSettings.HideWhileMap) then
        if (string.match(GetMenuName(), 'map')) then
            return true;
        end
    end

    if (GetInterfaceHidden()) then
        return true;
    end
    
    return false;
end

function SquareManager:GetSquareByHitPosition(x, y)
    for _,square in ipairs(self.Squares) do
        if (x >= square.MinX) and (x <= square.MaxX) and (y >= square.MinY) and (y <= square.MaxY) then
            return square;
        end
    end
end

function SquareManager:HitTest(x, y)
    if (self.PluginStruct == nil) then
        return false;
    end

    local pos = gSettings.Position[gSettings.Layout];
    if (x >= pos[1]) and (y >= pos[2]) then
        local offsetX = x - pos[1];
        local offsetY = y - pos[2];
        if (offsetX < self.Layout.PanelWidth) and (offsetY < self.Layout.PanelHeight) then
            return true, self:GetSquareByHitPosition(offsetX, offsetY);
        end
    end
    return false;
end

function SquareManager:Tick()
    if (self.PluginStruct == nil) or (self:GetHidden()) then
        if (self.Primitive ~= nil) then
            self.Primitive.visible = false;
        end
        return;
    end

    for _,squareClass in ipairs(self.Squares) do
        squareClass:Update();
    end

    -- Update font object and pass rendering information to renderer.
    local pos = gSettings.Position[gSettings.Layout];
    self.Primitive.position_x   = pos[1];
    self.Primitive.position_y   = pos[2];
    self.Primitive.visible      = true;
    self.PluginStruct.PositionX = pos[1];
    self.PluginStruct.PositionY = pos[2];
    self.PluginStruct.Render    = 1;
end

function SquareManager:UpdateBindings(bindings)
    for _,square in ipairs(self.Squares) do
        square:UpdateBinding(bindings[square.Hotkey]);
    end
end

return SquareManager;