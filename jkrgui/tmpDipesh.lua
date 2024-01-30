require "jkrgui.MaterialComponents"


-- slider to be made
-- icon text button

-- tab widget
local Slider = Jkr.Components.Abstract.ImageObject:New(0, 0,
    "icons_material/stop_circle/baseline-2x.png")
local Close = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/close/baseline-4x.png")


Com.Slider = {
    New = function(self, inPosition_3f, inDimension_3f, inFont, inLowerLimit, inHigherLimit)
        local Obj = {
            mPosition_3f = inPosition_3f,
            mDimension_3f = inDimension_3f,
            mCurrentNumberObject = nil
        }
        setmetatable(Obj, self)
        self.__index = self
        Obj.mArea = Com.AreaObject:New(inPosition_3f, inDimension_3f)
        Obj.mCurrentNumberHolder = Com.AreaObject:New(
            vec3(0, 0, inPosition_3f.z),
            vec3(0, 0, inDimension_3f.z))

        local SliderObject = Com.IconButton:New(vec3(inPosition_3f.x, inPosition_3f.y - 10, inPosition_3f.z),
            vec3(inDimension_3f.y, inDimension_3f.y + 20, inDimension_3f.z), Slider)
        SliderObject.mImageButton:TintColor(vec4(1, 127 / 255, 127 / 255, 1))

        local currentNumber = inLowerLimit
        Obj.mCurrentNumberObject = Com.TextLabelObject:New(tostring(currentNumber),
            vec3(0, 0, inPosition_3f.z),
            inFont)

        SliderObject:SetFunctions(
            function()
                SliderObject.mImageButton:TintColor(vec4(1, 0, 0, 1))
            end,
            function()
                SliderObject.mImageButton:TintColor(vec4(255 / 256, 127 / 256, 127 / 256, 0.8))
                --
            end,
            function()
                local mousePos = E.get_mouse_pos()
                if inPosition_3f.x <= mousePos.x and mousePos.x <= inPosition_3f.x + inDimension_3f.x then
                    currentNumber = Int(inLowerLimit +
                        (inHigherLimit - inLowerLimit) * (mousePos.x - inPosition_3f.x) / inDimension_3f.x)
                    Obj.mCurrentNumberObject:Update(vec3(mousePos.x, Obj.mPosition_3f.y + 60, Obj.mPosition_3f.z),
                        vec3(40, 25, 1),
                        tostring(currentNumber))
                    Obj.mCurrentNumberHolder:Update(vec3(mousePos.x, Obj.mPosition_3f.y + 40, Obj.mPosition_3f.z),
                        vec3(40, 25, 1))
                    SliderObject:Update(vec3(mousePos.x, Obj.mPosition_3f.y - 10, Obj.mPosition_3f.z),
                        vec3(Obj.mDimension_3f.y, Obj.mDimension_3f.y + 20, Obj.mDimension_3f.z))
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
                        self.mBottomAreas[index]:Update(vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z +1),inDimension_3f)
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
