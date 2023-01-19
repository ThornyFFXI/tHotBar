local square    = require('square');
local primitives = require('primitives');
local structOffset = 12;
local structWidth = 644;

local SquareManager = {};

function SquareManager:Initialize(layout, pluginStruct)
    self.PluginStruct = ffi.cast('AbilitySquarePanelState_t*', pluginStruct);
    self.Layout = layout;

    local count = 0;
    self.Squares = T{};
    for _,squareInfo in ipairs(layout.Squares) do
        local newSquare = square:New(ffi.cast('AbilitySquareState_t*', pluginStruct + structOffset + (structWidth * count)), squareInfo.DefaultMacro);
        count = count + 1;
        newSquare.Index = count;
        newSquare.MinX = squareInfo.OffsetX + layout.ImageObjects.Frame.OffsetX;
        newSquare.MaxX = newSquare.MinX + layout.ImageObjects.Frame.Width;
        newSquare.MinY = squareInfo.OffsetY + layout.ImageObjects.Frame.OffsetY;
        newSquare.MaxY = newSquare.MinY + layout.ImageObjects.Frame.Height;
        self.Squares:append(newSquare);
    end

    if (self.Primitive ~= nil) then
        self.Primitive:destroy();
    end

    self.Primitive = primitives.new(layout.Background)
end

function SquareManager:Destroy()
    for _,square in ipairs(self.Squares) do
        square:Destroy();
    end
    
    if (self.Primitive ~= nil) then
        self.Primitive:destroy();
    end
end

function SquareManager:GetSquareByHitPosition(x, y)
    for _,square in ipairs(self.Squares) do
        if (x >= square.MinX) and (x <= square.MaxX) and (y >= square.MinY) and (y <= square.MaxY) then
            return square;
        end
    end
end

function SquareManager:HitTest(x, y)
    if (x >= gSettings.PositionX) and (y >= gSettings.PositionY) then
        local offsetX = x - gSettings.PositionX;
        local offsetY = y - gSettings.PositionY;
        if (offsetX < self.Layout.PanelWidth) and (offsetY < self.Layout.PanelHeight) then
            return true, self:GetSquareByHitPosition(offsetX, offsetY);
        end
    end
    return false;
end

function SquareManager:Tick()
    if (self.PluginStruct == nil) then
        return;
    end

    for _,squareClass in ipairs(self.Squares) do
        squareClass:Update();
    end

    -- Update font object and pass rendering information to renderer.
    self.Primitive.position_x   = gSettings.PositionX;
    self.Primitive.position_y   = gSettings.PositionY;
    self.PluginStruct.PositionX = gSettings.PositionX;
    self.PluginStruct.PositionY = gSettings.PositionY;
    self.PluginStruct.Render    = 1;
end

function SquareManager:UpdateBindings(bindings)
    for _,square in ipairs(self.Squares) do
        square:UpdateBinding(bindings[square.Index]);
    end
end

return SquareManager;