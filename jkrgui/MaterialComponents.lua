require "jkrgui.PrimitiveComponents"
require "jkrgui.ExtraComponents"
CheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
"icons_material/radio_button_checked/baseline-2x.png")
UnCheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
"icons_material/radio_button_unchecked/baseline-2x.png")
Com.CheckButton = {
    New = function(self, inTableOfString, inFontObject, inPadding, inLengthCellDimension)
        local Obj = {
            mTableOfString = inTableOfString,
            mTableObjectForDescription = {},
            mButtonChecked = {},
            mButtonUnchecked = {},
            mPadding = inPadding,
            mLengthCellDimension = inLengthCellDimension,
            mFirst = true,
            mIndex = nil,
        }

        setmetatable(Obj, self)
        self.__index = self
        Obj.mPosition_3f = {}
        Obj.mDimension_3f = {}
        Obj.NoOfObject = #inTableOfString
        for index, value in ipairs(inTableOfString) do
            Obj.mTableObjectForDescription[index] = Com.TextButtonObject:New(inTableOfString[index].name,
                inFontObject, vec3(0, 0, 80), vec3(0, 0, 0))
            Obj.mButtonChecked[index] = Com.ImageLabelObject:NewExisting(CheckedImagePreload,
                vec3(0, 0, 0), vec3(0, 0, 0))
            Obj.mButtonChecked[index]:TintColor(vec4(0, 0, 1, 1))
            Obj.mButtonUnchecked[index] = Com.ImageLabelObject:NewExisting(
                UnCheckedImagePreload,
                vec3(0, 0, 0), vec3(0, 0, 0))
            Obj.mButtonUnchecked[index]:TintColor(vec4(0, 0, 1, 1))
        end
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        for i = 1, self.NoOfObject, 1 do
            if self.mIndex == i or self.mIndex == nil then
                if self.mFirst then
                    self.mButtonUnchecked[i]:Update(vec3(position.x, position.y, position.z), inDimension_3f)
                    self.mButtonChecked[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                else
                    self.mButtonChecked[i]:Update(vec3(position.x, position.y, position.z), inDimension_3f)
                    self.mButtonUnchecked[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                end
            end
            self.mPosition_3f[i] = vec3(position.x, position.y, position.z)
            self.mDimension_3f[i] = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
            position.y = position.y + inDimension_3f.y + self.mPadding
        end
        for i = 1, self.NoOfObject, 1 do
            self.mTableObjectForDescription[i]:Update(
            vec3(self.mPosition_3f[i].x + inDimension_3f.x + self.mPadding, self.mPosition_3f[i].y,
                self.mPosition_3f[i].z), vec3(self.mLengthCellDimension, inDimension_3f.y, inDimension_3f.z),
                self.mTableObjectForDescription[i].mText)
        end
    end,
    Event = function(self)
        local MousePos = E.get_mouse_pos()
        for i = 1, self.NoOfObject, 1 do
            if E.is_left_button_pressed() then
                
                if MousePos.x > self.mPosition_3f[i].x and MousePos.x < (self.mPosition_3f[i].x + self.mDimension_3f[i].x) and MousePos.y > self.mPosition_3f[i].y and MousePos.y < (self.mPosition_3f[i].y + self.mDimension_3f[i].y) then
                    self.mFirst = not self.mFirst
                    self.mIndex = i
                    self:Update(self.mPosition_3f[1], self.mDimension_3f[1]) --first button ko position dinuprxaw
                end
            end
        end
    end

}