ffi.cdef[[
    typedef struct FontInitializer_t {
        int32_t OffsetX;
        int32_t OffsetY;
        int32_t BoxWidth;
        int32_t BoxHeight;
        int32_t OutlineWidth;
        int32_t FontHeight;
        char FontFamily[256];
        uint32_t FontFlags;
        uint32_t FontAlignment;
        uint32_t FontColor;
        uint32_t OutlineColor;
    } FontInitializer_t;

    typedef struct ImageInitializer_t {
        int32_t OffsetX;
        int32_t OffsetY;
        int32_t Width;
        int32_t Height;
    } ImageInitializer_t;

    typedef struct SquareInitializer_t {
        int32_t OffsetX;
        int32_t OffsetY;
    } SquareInitializer_t;

    typedef struct EventInitializer_t {
        char UniqueIdentifier[256];
        FontInitializer_t Cost;
        FontInitializer_t Macro;
        FontInitializer_t Name;
        FontInitializer_t Recast;
        ImageInitializer_t Frame;
        ImageInitializer_t Icon;
        ImageInitializer_t Overlay;
        float IconFadeAlpha;
        char FramePath[256];
        int32_t PanelHeight;
        int32_t PanelWidth;
        int32_t SquareHeight;
        int32_t SquareWidth;
        int32_t SquareCount;
        SquareInitializer_t Squares[100];
    } EventInitializer_t;

    typedef struct AbilitySquareState_t {
        uint32_t Fade;
        char Cost[32];
        char Macro[32];
        char Name[32];
        char Recast[32];
        char IconImage[256];
        char OverlayImage[256];
    } AbilitySquareState_t;

    typedef struct AbilitySquarePanelState_t {
        uint32_t Render;
        int32_t PositionX;
        int32_t PositionY;
        AbilitySquareState_t Squares[100];
    } AbilitySquarePanelState_t;
]];

local function lua_FontInitializerToStruct(font)
    local struct = ffi.new('FontInitializer_t');
    struct.OffsetX = font.OffsetX;
    struct.OffsetY = font.OffsetY;
    struct.BoxWidth = font.BoxWidth;
    struct.BoxHeight = font.BoxHeight;
    struct.OutlineWidth = font.OutlineWidth;
    struct.FontHeight = font.FontHeight;
    struct.FontFamily = font.FontFamily;
    struct.FontFlags = font.FontFlags;
    struct.FontAlignment = font.FontAlignment;
    struct.FontColor = font.FontColor;
    struct.OutlineColor = font.OutlineColor;
    return struct;
end

local function lua_ImageInitializerToStruct(image)
    local struct = ffi.new('ImageInitializer_t');
    struct.OffsetX = image.OffsetX;
    struct.OffsetY = image.OffsetY;
    struct.Width = image.Width;
    struct.Height = image.Height;
    return struct;
end

local function lua_SquareInitializerToStruct(square)
    local struct = ffi.new('SquareInitializer_t');
    struct.OffsetX = square.OffsetX;
    struct.OffsetY = square.OffsetY;
    return struct;
end

local function ResolvePath(path)
    if (ashita.fs.exists(path)) then
        return path;
    end

    local check = string.format('%sconfig/addons/%s/resources/%s', AshitaCore:GetInstallPath(), addon.name, path);
    if (ashita.fs.exists(check)) then
        return check;
    end

    return string.format('%saddons/%s/resources/%s', AshitaCore:GetInstallPath(), addon.name, path);
end

local function lua_EventInitializerToStruct(layout)
    local struct = ffi.new('EventInitializer_t');
    struct.UniqueIdentifier = layout.Path;
    struct.Cost = lua_FontInitializerToStruct(layout.FontObjects.Cost);
    struct.Macro = lua_FontInitializerToStruct(layout.FontObjects.Macro);
    struct.Name = lua_FontInitializerToStruct(layout.FontObjects.Name);
    struct.Recast = lua_FontInitializerToStruct(layout.FontObjects.Recast);
    struct.Frame = lua_ImageInitializerToStruct(layout.ImageObjects.Frame);
    struct.Icon = lua_ImageInitializerToStruct(layout.ImageObjects.Icon);
    struct.Overlay = lua_ImageInitializerToStruct(layout.ImageObjects.Overlay);
    struct.IconFadeAlpha = layout.IconFadeAlpha;
    struct.FramePath = ResolvePath(layout.FramePath);
    struct.PanelHeight = layout.PanelHeight;
    struct.PanelWidth = layout.PanelWidth;
    struct.SquareHeight = layout.SquareHeight;
    struct.SquareWidth = layout.SquareWidth;
    struct.SquareCount = 0;
    for _,square in ipairs(layout.Squares) do
        struct.Squares[struct.SquareCount] = lua_SquareInitializerToStruct(square);
        struct.SquareCount = struct.SquareCount + 1;
    end
    return struct;
end

local function LoadFile(filePath)
    if not ashita.fs.exists(filePath) then
        return nil;
    end

    local success, loadError = loadfile(filePath);
    if not success then
        print(chat.header(addon.name) .. chat.error('Failed to load resource file: ') .. chat.color1(2, filePath));
        print(chat.header(addon.name) .. chat.error(loadError));
        return nil;
    end

    local result, output = pcall(success);
    if not result then
        print(chat.header(addon.name) .. chat.error('Failed to call resource file: ') .. chat.color1(2, filePath));
        print(chat.header(addon.name) .. chat.error(loadError));
        return nil;
    end

    return output;
end

local function LoadLayout(interface, layoutName)
    if (interface.Layout) then
        if (interface.Layout.Name == layoutName) then
            -- If layout is already the active layout, don't bother changing anything.
            return true;
        else
            -- Clear saved position when changing layouts, so default can be used again.
            gSettings.PositionX = nil;
            gSettings.PositionY = nil;
        end
    end

    --Attempt to load layout file.
    local layouts = T{
        string.format('%sconfig/addons/%s/resources/layouts/%s.lua', AshitaCore:GetInstallPath(), addon.name, layoutName),
        string.format('%saddons/%s/resources/layouts/%s.lua', AshitaCore:GetInstallPath(), addon.name, layoutName),
    };

    for _,path in ipairs(layouts) do
        interface.Layout = LoadFile(path);
        if (interface.Layout ~= nil) then
            interface.Layout.Name = layoutName;
            interface.Layout.Path = path;
            break;
        end
    end

    if (interface.Layout == nil) then
        return false;
    end
            
    if (gSettings.PositionX == nil) or (gSettings.PositionY == nil) then
        --Fill in position from new layout..
        gSettings.PositionX = interface.Layout.DefaultX;
        gSettings.PositionY = interface.Layout.DefaultY;
        settings.save();
    end

    return true;
end

local interface = {};
interface.SquareManager = require('square_manager');

function interface:Clear()
    self.StructPointer = nil;
end

function interface:Destroy()
    self.SquareManager:Destroy();
    
    if (self.StructPointer ~= nil) then
        AshitaCore:GetPluginManager():RaiseEvent('tRenderer_Destroy', (self.Layout.Path .. '\x00'):totable());
    end
end

function interface:GetLayout()
    return self.Layout;
end

function interface:GetSquareManager()
    return self.SquareManager;
end

function interface:HandleEvent(e)
    if (e.name == self.EventIdentifier) and (self.StructPointer == nil) then
        self.StructPointer = struct.unpack('L', e.data, 1);
        self.SquareManager:Initialize(self.Layout, self.StructPointer);
        gSettings.layout = self.Layout.Name;
        settings.save();
    end
end

function interface:Initialize(layoutName)
    if (self.Initializer ~= nil) and (self.StructPointer == nil) then
        print(chat.header(addon.name) .. chat.error('Could not load layout.  Please wait for last layout to finish loading before changing again.'));
        return;
    end

    self.Initializer = nil;
    if (self.StructPointer ~= nil) then
        AshitaCore:GetPluginManager():RaiseEvent('tRenderer_Destroy', (self.Layout.Path .. '\x00'):totable());
        self.StructPointer = nil;
    end

    if (LoadLayout(self, layoutName)) then
        self.Initializer = lua_EventInitializerToStruct(self.Layout);
        self.EventIdentifier = string.format('tRenderer_Accessor_%s', self.Layout.Path);
        ashita.events.register('plugin_event', 'interface_event_cb', (function (self, e)
            self:HandleEvent(e);
        end):bind1(self));
    else
        print(chat.header(addon.name) .. chat.error('No layout loaded.  Please select a layout via ') .. chat.color1(2, '/tb') .. chat.error('.'));
    end
end

function interface:Tick()
    if (self.Initializer == nil) then
        return;
    end

    if (self.StructPointer == nil) then
        local eventStruct = ffi.string(self.Initializer, ffi.sizeof(self.Initializer)):totable();
        AshitaCore:GetPluginManager():RaiseEvent('tRenderer_Initialize', eventStruct);
        return;
    end

    self.SquareManager:Tick();
end

return interface;