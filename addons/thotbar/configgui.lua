local header = { 1.0, 0.75, 0.55, 1.0 };
local imgui = require('imgui');
local scaling = require('scaling');
local state = {
    IsOpen = { false }
};

local function GetDefaultPosition(layout)
    if ((scaling.window.w == -1) or (scaling.window.h == -1) or (scaling.menu.w == -1) or (scaling.menu.h == -1)) then
        return { 0, 0 };
    else
        --Centered horizontally, vertically just above chat log.
        return {
            (scaling.window.w - layout.Panel.Width) / 2,
            scaling.window.h - (scaling.scale_height(136) + layout.Panel.Height)
        };
    end
end

local function GetLayouts()
    local layouts = T{};
    local layoutPaths = T{
        string.format('%sconfig/addons/%s/resources/layouts/', AshitaCore:GetInstallPath(), addon.name),
        string.format('%saddons/%s/resources/layouts/', AshitaCore:GetInstallPath(), addon.name),
    };

    for _,path in ipairs(layoutPaths) do
        if not (ashita.fs.exists(path)) then
            ashita.fs.create_directory(path);
        end
        local contents = ashita.fs.get_directory(path, '.*\\.lua');
        for _,file in pairs(contents) do
            file = string.sub(file, 1, -5);
            if not layouts:contains(file) then
                layouts:append(file);
            end
        end
    end

    state.Layouts = layouts;
    state.Scale = { gSettings.Scale };
    state.SelectedLayout = -1;
    for index,layout in ipairs(state.Layouts) do
        if (gSettings.Layout == layout) then
            state.SelectedLayout = index;
        end
    end
end

local function CheckBox(text, member)
    if (imgui.Checkbox(string.format('%s##Config_%s', text, text), { gSettings[member] })) then
        gSettings[member] = not gSettings[member];
        settings.save();
    end
end

local exposed = {};

function exposed:Render()
    if (state.IsOpen[1]) then
        if (imgui.Begin(string.format('%s v%s Configuration', addon.name, addon.version), state.IsOpen, ImGuiWindowFlags_AlwaysAutoResize)) then
            imgui.BeginGroup();
            if imgui.BeginTabBar('##tHotBarConfigTabBar', ImGuiTabBarFlags_NoCloseWithMiddleMouseButton) then
                if imgui.BeginTabItem('Layouts##tHotBarConfigLayoutsTab', 0, state.ForceTab and 6 or 4) then
                    state.ForceTab = nil;
                    imgui.TextColored(header, 'Layout');
                    if (imgui.BeginCombo('##tHotBarSingleLayoutSelectConfig', state.Layouts[state.SelectedLayout], ImGuiComboFlags_None)) then
                        for index,layout in ipairs(state.Layouts) do
                            if (imgui.Selectable(layout, index == state.SelectedLayout)) then
                                state.SelectedLayout = index;
                            end
                        end
                        imgui.EndCombo();
                    end
                    imgui.SliderFloat('##tHotBarDrawScale', state.Scale, 0.5, 3, '%.2f', ImGuiSliderFlags_AlwaysClamp);
                    if (gDisplay.Valid) then
                        local button = string.format('%s##tHotBarMoveToggle', gDisplay.AllowDrag and 'End Drag' or 'Allow Drag');
                        if (imgui.Button(button)) then
                            gDisplay.AllowDrag = not gDisplay.AllowDrag;
                        end
                        imgui.ShowHelp('Allows you to drag the display.', true);
                        imgui.SameLine();
                        if (imgui.Button('Reset##tHotBarReset')) then
                            gSettings.Position = GetDefaultPosition(gDisplay.Layout);
                            gDisplay:UpdatePosition();
                            settings.save();
                        end
                        imgui.ShowHelp('Resets display to default position.', true);
                        imgui.SameLine();
                    end
                    if (imgui.Button('Apply##tHotBarApply')) then
                        local layout = state.Layouts[state.SelectedLayout];
                        if (layout == nil) then
                            Error('You must select a valid layout to apply it.');
                        else
                            gSettings.Layout = layout;
                            gSettings.Scale = state.Scale[1];
                            gInitializer:ApplyLayout();
                            gSettings.Position = GetDefaultPosition(gDisplay.Layout);
                            gDisplay:UpdatePosition();
                            gBindings:Update();
                            settings.save();
                        end
                    end
                    imgui.ShowHelp('Applies the selected layout to your display.', true);
                    imgui.TextColored(header, 'Layout Files');
                    if (imgui.Button('Refresh')) then
                        GetLayouts();
                    end
                    imgui.ShowHelp('Reloads available layouts from disk.', true);
                    imgui.EndTabItem();
                end
                
                if imgui.BeginTabItem('Components##tHotBarConfigComponentsTab') then
                    imgui.BeginGroup();
                    CheckBox('Empty', 'ShowEmpty');
                    imgui.ShowHelp('Display empty macro elements.');
                    CheckBox('Frame', 'ShowFrame');
                    imgui.ShowHelp('Display frame for macro elements.');
                    CheckBox('Cost', 'ShowCost');
                    imgui.ShowHelp('Display action cost indicators.');
                    CheckBox('Trigger', 'ShowTrigger');
                    imgui.ShowHelp('Shows an overlay when you activate an action.');
                    CheckBox('SC Icon', 'ShowSkillchainIcon');
                    imgui.ShowHelp('Overrides weaponskill icons when a skillchain would be formed.');
                    CheckBox('SC Animation', 'ShowSkillchainAnimation');
                    imgui.ShowHelp('Animates a border around weaponskill icons when a skillchain would be formed.');
                    imgui.EndGroup();
                    imgui.SameLine();
                    imgui.BeginGroup();
                    CheckBox('Cross', 'ShowCross');
                    imgui.ShowHelp('Displays a X over actions you don\'t currently know.');
                    CheckBox('Fade', 'ShowFade');
                    imgui.ShowHelp('Fades the icon for actions where cooldown is not 0 or cost is not met.');
                    CheckBox('Recast', 'ShowRecast');
                    imgui.ShowHelp('Shows action recast timers.');
                    CheckBox('Hotkey', 'ShowHotkey');
                    imgui.ShowHelp('Shows hotkey labels.');
                    CheckBox('Name', 'ShowName');
                    imgui.ShowHelp('Shows action names.');
                    CheckBox('Palette', 'ShowPalette');
                    imgui.ShowHelp('Shows selected palette.');
                    imgui.EndGroup();
                    imgui.EndTabItem();
                end
                
                if imgui.BeginTabItem('Behavior##tHotBarConfigBehaviorTab') then
                    imgui.BeginGroup();
                    imgui.TextColored(header, 'Macro Elements');
                    CheckBox('Clickable', 'ClickToActivate');
                    imgui.ShowHelp('Makes macros activate when their icon is left clicked.');
                    imgui.TextColored(header, 'Trigger Duration');
                    local buff = { gSettings.TriggerDuration };
                    if imgui.SliderFloat('##TriggerDurationSlider', buff, 0.01, 1.5, '%.2f', ImGuiSliderFlags_AlwaysClamp) then
                        gSettings.TriggerDuration = buff[1];
                        settings.save();
                    end
                    imgui.ShowHelp('Determines how long the activation flash occurs for when ShowTrigger is enabled.')
                    imgui.TextColored(header, 'Hide UI');
                    CheckBox('While Zoning', 'HideWhileZoning');
                    imgui.ShowHelp('Hides UI while you are zoning or on title screen.');
                    CheckBox('During Cutscenes', 'HideWhileCutscene');
                    imgui.ShowHelp('Hides UI while the game event system is active.');
                    CheckBox('While Map Open', 'HideWhileMap');
                    imgui.ShowHelp('Hides UI while the map is the topmost menu.');
                    imgui.TextColored(header, 'Binding Menu');
                    CheckBox('Default To <st>', 'DefaultSelectTarget');
                    imgui.ShowHelp('When enabled, new bindings that can target anything besides yourself will default to <st>.');
                    imgui.EndTabItem();
                end
                
                imgui.EndTabBar();
            end
            imgui.End();
        end
    end

    if (state.IsOpen[1] == false) then
        gDisplay.AllowDrag = false;
    end
end

function exposed:Show()
    GetLayouts();
    state.ForceTab = true;
    state.IsOpen = { true };
end

return exposed;