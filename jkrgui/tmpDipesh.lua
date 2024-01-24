require "jkrgui.MaterialComponents"


-- slider to be made
-- icon text button

-- tab widget
local Slider = Jkr.Components.Abstract.ImageObject:New(0, 0,
    "icons_material/stop_circle/baseline-2x.png")


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
            vec3(0,0, inPosition_3f.z),
            vec3(0, 0, inDimension_3f.z))

        local SliderObject = Com.IconButton:New(vec3(inPosition_3f.x, inPosition_3f.y - 10, inPosition_3f.z),
            vec3(inDimension_3f.y, inDimension_3f.y + 20, inDimension_3f.z), Slider)
        SliderObject.mImageButton:TintColor(vec4(1, 127/255, 127/255, 1))

        local currentNumber = inLowerLimit
        Obj.mCurrentNumberObject = Com.TextLabelObject:New(tostring(currentNumber),
            vec3(0,0, inPosition_3f.z),
            inFont)

        SliderObject:SetFunctions(
            function()
                SliderObject.mImageButton:TintColor(vec4(1, 0, 0, 1))
                
            end,
            function()
                SliderObject.mImageButton:TintColor(vec4(255/256, 127/256, 127/256, 0.8))
-- 
            end,
            function()
                local mousePos = E.get_mouse_pos()
                if inPosition_3f.x <= mousePos.x and mousePos.x <= inPosition_3f.x + inDimension_3f.x then
                    currentNumber = Int(inLowerLimit + (inHigherLimit - inLowerLimit)* (mousePos.x - inPosition_3f.x)/inDimension_3f.x)
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
    New = function (self, inPosition_3f, inDimension_3f, inIconName, inText, inFontObject)
        local Obj = Com.IconButton:New(inPosition_3f, inDimension_3f, inIconName)
        setmetatable(self, Com.IconButton)
        setmetatable(Obj, self)
        self.__index = self
        Obj.mText = Com.TextLabelObject:New(inText, vec3(0, 0, inPosition_3f.z), inFontObject)
        Obj.mHorizontalLayout = Com.HLayout:New(5)
        Obj.mHorizontalLayout:AddComponents({Obj.mImageButton, Obj.mText}, {0.3, 0.7})
        Obj.mHorizontalLayout:Update(inPosition_3f, inDimension_3f)
        return Obj
    end,
    Update = function (self, inPosition_3f, inDimension_3f, inText)
        self.mText:Update(inPosition_3f, inDimension_3f, inText)
        Com.IconButton.Update(self, inPosition_3f, inDimension_3f)
    end
}
