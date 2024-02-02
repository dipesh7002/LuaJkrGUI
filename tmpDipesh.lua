require "jkrgui.MaterialComponents"
require "jkrgui.AnimationComponents"
require "jkrgui.ExtraComponents"
require "jkrgui.Resources"
require "jkrgui.LayoutComponents"



-- slider to be made
-- icon text button

-- tab widget
local Slider = Jkr.Components.Abstract.ImageObject:New(0, 0,
    "icons_material/folder/baseline-4x.png")
local Close = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/close/baseline-4x.png")

Dipesh = {}

Com.Slider = {
    New = function(self, inPosition_3f, inDimension_3f, inFont, inLowerLimit, inHigherLimit)
        local Obj = {
            mPosition_3f = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z),
            mDimension_3f = inDimension_3f,
            mCurrentNumberObject = nil,
            mSliderObject = nil,
            mSliderObjectIcon = nil,
            mHigherLimit = inHigherLimit,
            mLowerLimit = inLowerLimit,
            mStringDimensions = vec2(0, 0)
        }
        setmetatable(Obj, self)
        self.__index = self
        Obj.mArea = Com.AreaObject:New(inPosition_3f, inDimension_3f)
        Obj.mCurrentNumberHolder = Com.AreaObject:New(
            vec3(0, 0, inPosition_3f.z),
            vec3(0, 0, inDimension_3f.z))
        Obj.mIsPressed = false

        Obj.mSliderObject = Jkr.ComponentObject:New(vec3(inPosition_3f.x, inPosition_3f.y - 10, inPosition_3f.z),
            vec3(inDimension_3f.y, inDimension_3f.y + 20, inDimension_3f.z))
        Obj.mSliderObjectIcon = Com.ImageLabelObject:NewExisting(Slider,
            vec3(inPosition_3f.x, inPosition_3f.y - inDimension_3f.y / 5, inPosition_3f.z - 2),
            vec3(inDimension_3f.y + inDimension_3f.y / 2.5, inDimension_3f.y + inDimension_3f.y / 2.5, inDimension_3f.z))
        Obj.mSliderObjectIcon:TintColor(vec4(178 / 255, 102 / 255, 178 / 255, 1))


        local currentNumber = inLowerLimit
        Obj.mCurrentNumberObject = Com.TextLabelObject:New(tostring(currentNumber),
            vec3(0, 0, inPosition_3f.z),
            inFont)
        local mStringDimensions = inFont:GetDimension(tostring(inHigherLimit))
        Com.NewComponent_Event()
        ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
            function()
                Obj.mSliderObject:Event()

                if Obj.mSliderObject.mHovered_b then
                    print("bahira ni aaxaina machigne")
                    Obj.mSliderObjectIcon:TintColor(vec4(128 / 256, 0, 128 / 256, 1))
                else
                    Obj.mSliderObjectIcon:TintColor(vec4(178 / 255, 102 / 255, 178 / 255, 1))
                end

                if Obj.mSliderObject.mClicked_b then
                    print("harekchoty maderchod")
                    Obj.mIsPressed = true
                end
                if E.is_left_button_pressed_continous() and Obj.mIsPressed then
                    Obj.mSliderObjectIcon:TintColor(vec4(128 / 256, 0, 128 / 256, 1))

                    local mousePos = E.get_relative_mouse_pos()
                    Obj.mPosition_3f.x = mousePos.x + Obj.mPosition_3f.x
                    print("relative mouse pos", mousePos.x)

                    if Obj.mPosition_3f.x >= inPosition_3f.x and Obj.mPosition_3f.x <= inPosition_3f.x + inDimension_3f.x then
                        local currentNumber = Int(Obj.mLowerLimit +
                            (Obj.mHigherLimit - Obj.mLowerLimit) * (Obj.mPosition_3f.x - inPosition_3f.x) /
                            Obj.mDimension_3f.x)
                        print("position of x", Obj.mPosition_3f.x)

                        Obj.mCurrentNumberObject:Update(
                            vec3(Obj.mPosition_3f.x, Obj.mPosition_3f.y + 40,
                                Obj.mPosition_3f.z),
                            vec3(Obj.mStringDimensions.x, Obj.mStringDimensions.y, 1),
                            tostring(currentNumber))
                        Obj.mCurrentNumberHolder:Update(
                            vec3(Obj.mPosition_3f.x, Obj.mPosition_3f.y + 40,
                                Obj.mPosition_3f.z),
                            vec3(Obj.mStringDimensions.x, Obj.mStringDimensions.y, 1))
                        Obj.mSliderObject:Update(
                            vec3(Obj.mSliderObject.mPosition_3f.x, Obj.mPosition_3f.y - 10, Obj.mPosition_3f.z),
                            vec3(Obj.mDimension_3f.y, Obj.mDimension_3f.y + 20, Obj.mDimension_3f.z))
                        Obj.mSliderObjectIcon:Update(
                            vec3(Obj.mPosition_3f.x, inPosition_3f.y - inDimension_3f.y / 5, inPosition_3f.z - 2),
                            vec3(inDimension_3f.y + inDimension_3f.y / 2.5, inDimension_3f.y + inDimension_3f.y / 2.5,
                                inDimension_3f.z))
                    end
                else
                    Obj.mIsPressed = false

                    print("i am here all the time")
                end
            end
        )



        return Obj
    end

}

Com.IconTextButton = {
    New = function(self, inPosition_3f, inDimension_3f, inIconName, inText, inFontObject)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mText = Com.TextLabelObject:New(inText,
            vec3(inPosition_3f.x + inDimension_3f.y, inPosition_3f.y + inDimension_3f.y / 2, inPosition_3f.z),
            inFontObject)
        Obj.mImage = Com.ImageLabelObject:NewExisting(inIconName,
            vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z - 3), vec3(inDimension_3f.y, inDimension_3f.y, 1))
        Obj.mImage:TintColor(vec4(1, 0, 0, 1))
        Obj.mArea = Com.AreaObject:New(vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z), inDimension_3f)

        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mText:Update(inPosition_3f, inDimension_3f)
        Com.IconButton.Update(self, inPosition_3f, inDimension_3f)
    end
}

-- Com.OutlinedArea = {
--     New = function(self, inPosition_3f, inDimension_3f, inBorderColor)
--         local Obj = Com.AreaObject:New(vec3(inPosition_3f.x - 20, inPosition_3f.y - 2, inPosition_3f.z ),
--             vec3(inDimension_3f.x + 4, inDimension_3f.y + 4, inDimension_3f.z))
--         setmetatable(self, Com.AreaObject)
--         setmetatable(Obj, self)
--         self.__index = self
--         Obj.mFillColor = inBorderColor
--         Obj.mMainArea = Com.AreaObject:New(inPosition_3f, inDimension_3f)
--     end,
--     Update = function (self, inPosition_3f, inDimension_3f)
--             self.Update(self, inPosition_3f, inDimension_3f)
--             self.mMainArea:Update(inPosition_3f, inDimension_3f)
--     end
-- }

Com.IconTabWidget = {
    New = function(self, inFontObject, inMaxNoOfTabs, inMaxStringLength, inTabHeight)
        local Obj = {
            mCloseButton = {},
            mFontObject = inFontObject,
            mTabs = {},
            mTabNamesTable = {},
            mComponentObjects = {},
            mTabHeight = nil,
            mBottomAreas = {}

        }

        setmetatable(Obj, self)
        self.__index = self
        Obj.mTabHeight = inTabHeight
        for i = 1, inMaxNoOfTabs, 1 do
            Obj.mComponentObjects[i] = Jkr.ComponentObject:New(vec3(0, 0, 1), vec3(0, 0, 1))
            Obj.mTabs[i] = Com.AreaObject:New(vec3(0, 0, 1), vec3(0, 0, 1))
            Obj.mTabNamesTable[i] = Com.TextLabelObject:New(string.rep(" ", inMaxStringLength), vec3(0, 0, 1),
                inFontObject)
            Obj.mCloseButton[i] = Com.IconButton:New(vec3(0, 0, 1), vec3(0, 0, 1), Close)
            Obj.mBottomAreas[i] = Com.AreaObject:New(vec3(0, 0, 1), vec3(0, 0, 1))
        end

        return Obj
    end,

    Update = function(self, inPosition_3f, inDimension_3f, inTabNameTable)
        print("laofhoasfh")
        local sizeOfTable = #inTabNameTable

        for index, value in ipairs(inTabNameTable) do
            local tabsPosition = vec3(inPosition_3f.x + (index - 1) * inDimension_3f.x / sizeOfTable, inPosition_3f.y,
                inPosition_3f.z)
            local tabDimension = vec3(inDimension_3f.x / sizeOfTable, self.mTabHeight, inDimension_3f.z)
            self.mTabs[index]:Update(tabsPosition, tabDimension)

            self.mTabNamesTable[index]:Update(
                vec3(inPosition_3f.x + (index - 1) * inDimension_3f.x / sizeOfTable,
                    inPosition_3f.y + self.mTabHeight,
                    inPosition_3f.z), tabDimension, value)
            self.mComponentObjects[index]:Update(tabsPosition, tabDimension)
            Com.NewComponent()
            local i = com_i
            ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(function()
                local offset = vec2(self.mComponentObjects[index].mPosition_3f.x,
                    self.mComponentObjects[index].mPosition_3f.y)
                local extent = vec2(self.mComponentObjects[index].mDimension_3f.x,
                    self.mComponentObjects[index].mDimension_3f.y)

                if offset.x > 0 and offset.y > 0 then
                    Jkr.set_scissor(offset, extent)
                end
            end)
            Com.NewComponent()
            local i = com_i
            ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(function()
                Jkr.reset_scissor()
            end)
            Com.NewComponent_Event()
            ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
                function()
                    self.mComponentObjects[index]:Event()
                    if self.mComponentObjects[index].mHovered_b then
                        self.mCloseButton[index]:Update(tabsPosition,
                            vec3(tabDimension.x / 3, tabDimension.y / 3, tabDimension.z))
                        self.mCloseButton[index].mImageButton:TintColor(vec4(1, 0, 0, 1))
                    else
                        self.mCloseButton[index]:Update(vec3(0, 0, 1), vec3(0, 0, 1))
                        self.mBottomAreas[index]:Update(vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z + 1),
                            inDimension_3f)
                    end

                    if self.mComponentObjects[index].mClicked_b then
                        self.mBottomAreas[index]:Update(vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z + 2),
                            inDimension_3f)
                    end
                end
            )
        end
    end
}

Dipesh.CanvasPractice = function()

end
local CanvasHeader = [[
 int xx = int(push.mPosDimen.x);
 int yy = int(push.mPosDimen.y);
 to_draw_at.x = to_draw_at.x + xx;
 to_draw_at.y = to_draw_at.y + yy;
 vec4 pure_color = push.mColor;

 vec2 imageko_size = vec2(push.mPosDimen.z, push.mPosDimen.w); // GlobalInvocations
 float x_cartesian = (float(gl_GlobalInvocationID.x) - float(imageko_size.x) / float(2)) / (float((imageko_size.x) / float(2)));
 float y_cartesian = (float(imageko_size.y) / float(2) - float(gl_GlobalInvocationID.y)) / (float(imageko_size.y) / float(2));
 vec2 xy_cartesian = vec2(x_cartesian, y_cartesian);
]]
LoadDipesh = function()
    Jkr.GLSL["DipeshCanvas"] = CanvasHeader .. [[
        float color = distance(xy_cartesian, vec2(0, 0)) - 0.5;
        vec4 newcolor = vec4(1 - color, 0, 0, 1);
        newcolor.r = smoothstep(0.7, 1, newcolor.r);
        imageStore(storageImage, to_draw_at, newcolor);
     ]]

    NewCanvas = Com.Canvas:New(vec3(100, 100, 80), vec3(100, 100, 1))
    NewCanvas:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
    NewCanvas:AddPainterBrush(Com.GetCanvasPainter("RoundedRectangle", false))
    NewCanvas:AddPainterBrush(Com.GetCanvasPainter("Dipesh", true))

    NewCanvas:MakeCanvasImage(100, 100)
    Com.NewComponent_SingleTimeDispatch()
    ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
        function()
            NewCanvas.CurrentBrushId = 3
            NewCanvas:Bind()
            NewCanvas:Paint(vec4(0, 0, 100, 100), vec4(1, 0, 1, 1), vec4(1, 1, 1, 1), 100, 100, 1)
        end
    )
    LoadMaterialComponents(false)
    Font = Jkr.FontObject:New("font.ttf", FontSize(10))

    NewSlider = Com.Slider:New(vec3(400, 100, 80), vec3(200, 10, 1), Font, 1, 100)
end
