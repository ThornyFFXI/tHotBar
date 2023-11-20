local d3d8 = require('d3d8');
local Element = require('element');
local ffi = require('ffi');
local gdi = require('gdifonts.include');
ffi.cdef[[
    int16_t GetKeyState(int32_t vkey);
]]

local function IsControlPressed()
    return (bit.band(ffi.C.GetKeyState(0x11), 0x8000) ~= 0);
end

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

local Display = { Valid = false };

function Display:Destroy()
    self.Layout = nil;
    if type(self.Elements) == 'table' then
        local bindSetting = AshitaCore:GetInputManager():GetKeyboard():GetSilentBinds();
        AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(true);
        for _,element in ipairs(self.Elements) do
            unbind(element.State.Hotkey);
        end
        AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(bindSetting);
    end
    self.Elements = T{};
    self.Valid = false;
end

function Display:Initialize(layout)
    self.Layout = layout;
    self.Elements = T{};

    local position = gSettings.Position;

    local bindSetting = AshitaCore:GetInputManager():GetKeyboard():GetSilentBinds();
    AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(true);
    for _,data in ipairs(layout.Elements) do
        local newElement = Element:New(data.DefaultMacro, layout);
        newElement.OffsetX = data.OffsetX;
        newElement.OffsetY = data.OffsetY;
        newElement:SetPosition(position);
        self.Elements:append(newElement);
        bind(data.DefaultMacro, #self.Elements);
    end
    AshitaCore:GetInputManager():GetKeyboard():SetSilentBinds(bindSetting);

    if (self.Sprite == nil) then
        local sprite = ffi.new('ID3DXSprite*[1]');
        if (ffi.C.D3DXCreateSprite(d3d8.get_device(), sprite) == ffi.C.S_OK) then
            self.Sprite = d3d8.gc_safe_release(ffi.cast('ID3DXSprite*', sprite[0]));
        else
            Error('Failed to create Sprite in Display:Initialize.');
        end
    end
    
    self.Valid = (self.Sprite ~= nil);
    local obj = gdi:create_object(self.Layout.Palette, true);
    obj.OffsetX = self.Layout.Palette.OffsetX;
    obj.OffsetY = self.Layout.Palette.OffsetY;
    self.PaletteDisplay = obj;

    if (self.Valid) then
        gBindings:Update();
    end
end

function Display:Activate(index)
    if (self.Valid == false) then
        return;
    end

    local element = self.Elements[index];
    if element then
        element:Activate();
    end
end

local d3dwhite = d3d8.D3DCOLOR_ARGB(255, 255, 255, 255);
local vec_position = ffi.new('D3DXVECTOR2', { 0, 0, });
function Display:Render()
    if (self.Valid == false) then
        return;
    end

    local pos = gSettings.Position;
    local sprite = self.Sprite;
    sprite:Begin();

    for _,object in ipairs(self.Layout.FixedObjects) do
        local component = self.Layout.Textures[object.Texture];
        vec_position.x = pos[1] + object.OffsetX;
        vec_position.y = pos[2] + object.OffsetY;
        sprite:Draw(component.Texture, component.Rect, component.Scale, nil, 0.0, vec_position, d3dwhite);
    end
    
    local paletteText = gBindings:GetDisplayText();
    if (gSettings.ShowPalette) and (paletteText) then
        local obj = self.PaletteDisplay;
        obj:set_text(paletteText);
        local texture, rect = obj:get_texture();
        local posX = obj.OffsetX + pos[1];
        if (obj.settings.font_alignment == 1) then
            vec_position.x = posX - (rect.right / 2);
        elseif (obj.settings.font_alignment == 2) then
            vec_position.x = posX - rect.right;
        else
            vec_position.x = posX;;
        end
        vec_position.y = obj.OffsetY + pos[2];
        sprite:Draw(texture, rect, vec_font_scale, nil, 0.0, vec_position, d3dwhite);
    end

    for _,element in ipairs(self.Elements) do
        element:RenderIcon(sprite);
    end

    for _,element in ipairs(self.Elements) do
        element:RenderText(sprite);
    end
    
    if (self.AllowDrag) then
        local component = self.Layout.Textures[self.Layout.DragHandle.Texture];
        vec_position.x = pos[1] + self.Layout.DragHandle.OffsetX;
        vec_position.y = pos[2] + self.Layout.DragHandle.OffsetY;
        sprite:Draw(component.Texture, component.Rect, component.Scale, nil, 0.0, vec_position, d3dwhite);
    end

    sprite:End();
end

local dragPosition = { 0, 0 };
local dragActive = false;
function Display:DragTest(e)
    local handle = self.Layout.DragHandle;
    local pos = gSettings.Position;
    local minX = pos[1] + handle.OffsetX;
    local maxX = minX + handle.Width;
    if (e.x < minX) or (e.x > maxX) then
        return false;
    end

    local minY = pos[2] + handle.OffsetY;
    local maxY = minY + handle.Height;
    return (e.y >= minY) and (e.y <= maxY);
end

function Display:HandleMouse(e)
    if (self.Valid == false) then
        return;
    end

    if dragActive then
        local pos = gSettings.Position;
        pos[1] = pos[1] + (e.x - dragPosition[1]);
        pos[2] = pos[2] + (e.y - dragPosition[2]);
        dragPosition[1] = e.x;
        dragPosition[2] = e.y;
        self:UpdatePosition();
        if (e.message == 514) or (not self.AllowDrag) then
            dragActive = false;
            settings.save();
        end
    elseif (self.AllowDrag) and (e.message == 513) and self:DragTest(e) then
        dragActive = true;
        dragPosition[1] = e.x;
        dragPosition[2] = e.y;
        e.blocked = true;
        return;
    end

    if (e.message == 513) then
        local hitElement = self:HitTest(e.x, e.y);
        if hitElement then
            if IsControlPressed() then
                gBindingGUI:Show(hitElement.State.Hotkey, hitElement.Binding);
                e.blocked = true;
            elseif (gSettings.ClickToActivate) then
                hitElement:Activate();
                e.blocked = true;
            end
        end
    end
end

function Display:HitTest(x, y)
    if (self.Valid == false) then
        return;
    end

    local pos = gSettings.Position;
    if (x < pos[1]) or (y < pos[2]) then
        return false;
    end

    if (x > (pos[1] + self.Layout.Panel.Width)) then
        return false;
    end

    if (y > (pos[2] + self.Layout.Panel.Height)) then
        return false;
    end

    for index,element in ipairs(self.Elements) do
        if (element:HitTest(x, y)) then
            return element;
        end
    end
end

function Display:UpdateBindings(bindings)
    if (self.Valid == false) then
        return;
    end

    for index,element in ipairs(self.Elements) do
        element:UpdateBinding(bindings[element.State.Hotkey]);
    end
end

function Display:UpdatePosition()
    if (self.Valid == false) then
        return;
    end
    
    local position = gSettings.Position;

    for _,element in ipairs(self.Elements) do
        element:SetPosition(position);
    end
end

return Display;