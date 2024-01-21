require "jkrgui.PrimitiveComponents"
require "jkrgui.ExtraComponents"

local MaterialFont = Jkr.FontObject:New("font.ttf", 4)


local CheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
    "icons_material/radio_button_checked/baseline-2x.png")
local UnCheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
    "icons_material/radio_button_unchecked/baseline-2x.png")
local MinimizeImage = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/minimize/baseline-4x.png")
local MaximizeImage = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/maximize/baseline-4x.png")
local CloseImage = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/close/baseline-4x.png")

Com.CheckButtonList = {
    New = function(self, inMaxNoOfEntries, inFontObject, inPadding, inLengthCellDimension, inMaxStringLength)
        local Obj = {
            mMaxNoOfEntries = inMaxNoOfEntries,
            mTableObjectForDescription = {},
            mButtonChecked = {},
            mButtonUnchecked = {},
            mPadding = inPadding,
            mLengthCellDimension = inLengthCellDimension,
            mIndex = nil,
            mCurrentStringTable = {}
        }

        setmetatable(Obj, self)
        self.__index = self
        Obj.mPosition_3f = {}
        Obj.mDimension_3f = {}
        for i = 0, inMaxNoOfEntries, 1 do
            Obj.mTableObjectForDescription[i] = Com.TextButtonObject:New(string.rep(" ", inMaxStringLength),
                inFontObject, vec3(0, 0, 80), vec3(0, 0, 0))
            Obj.mButtonChecked[i] = Com.ImageLabelObject:NewExisting(CheckedImagePreload, vec3(0, 0, 0), vec3(0, 0, 0))
            Obj.mButtonChecked[i]:TintColor(vec4(0, 0, 1, 1))
            Obj.mButtonUnchecked[i] = Com.ImageLabelObject:NewExisting(UnCheckedImagePreload, vec3(0, 0, 0),
                vec3(0, 0, 0))
            Obj.mButtonUnchecked[i]:TintColor(vec4(0, 0, 1, 1))
        end
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inStringTable)
        self.mCurrentStringTable = inStringTable
        local inNoOfEntries = #inStringTable
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        for i = 1, inNoOfEntries, 1 do
            if self.mIndex == i or self.mIndex == nil then
                if inStringTable[i].mFirst then
                    self.mButtonChecked[i]:Update(vec3(position.x, position.y, position.z), inDimension_3f)
                    self.mButtonUnchecked[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                else
                    self.mButtonUnchecked[i]:Update(vec3(position.x, position.y, position.z), inDimension_3f)
                    self.mButtonChecked[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                end
            end
            self.mPosition_3f[i] = vec3(position.x, position.y, position.z)
            self.mDimension_3f[i] = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
            position.y = position.y + inDimension_3f.y + self.mPadding
        end
        for i = 1, inNoOfEntries, 1 do
            self.mTableObjectForDescription[i]:Update(vec3(self.mPosition_3f[i].x + inDimension_3f.x + self.mPadding,
                self.mPosition_3f[i].y, self.mPosition_3f[i].z), vec3(self.mLengthCellDimension, inDimension_3f.y,
                inDimension_3f.z), inStringTable[i].name)
        end
    end,
    Event = function(self)
        local inNoOfEntries = #self.mCurrentStringTable
        local MousePos = E.get_mouse_pos()
        for i = 1, inNoOfEntries, 1 do
            if E.is_left_button_pressed() then
                if MousePos.x > self.mPosition_3f[i].x and MousePos.x <
                    (self.mPosition_3f[i].x + self.mDimension_3f[i].x) and MousePos.y > self.mPosition_3f[i].y and
                    MousePos.y < (self.mPosition_3f[i].y + self.mDimension_3f[i].y) then
                    self.mCurrentStringTable[i].mFirst = not self.mCurrentStringTable[i].mFirst
                    self.mIndex = i
                    self:Update(self.mPosition_3f[1], self.mDimension_3f[1], self.mCurrentStringTable) -- first button ko position dinuprxaw
                end
            end
        end
    end

}



-- Com.ButtonLayout = {
--     mPosition_3f = nil,
--     mDimension_3f = nil,
--     mString = nil,
--     mComponentObject = nil,
--     mCentralComponent = nil,
--     mPressed = false,

--     New = function(self, inPosition_3f, inDimension_3f, inString)
--         local Obj = {}
--         setmetatable(Obj, self)
--         self.__index = self
--         Obj.mPosition_3f = inPosition_3f
--         Obj.mDimension_3f = inDimension_3f
--         Obj.mComponentObject = Jkr.ComponentObject:New(inPosition_3f, inDimension_3f)
--         if inString then
--         Obj.mString = Com.TextLabelObject:New(inString,
--             vec3(inPosition_3f.x + 10, inPosition_3f.y + inDimension_3f.y / 2, inPosition_3f.z),
--             MaterialFont)
--         end
--         Obj.mComponentObject.mFocusOnHover_b = false
--         return Obj
--     end,
--     SetCentralComponent = function(self, inComponent)
--         if inComponent.mId then
--             self.mCentralComponent = inComponent
--             self.mDraw = Com.ImageLabelObject:NewExisting(inComponent, self.mPosition_3f, self.mDimension_3f)
--             self.mDraw:TintColor(vec4(1, 0, 0, 1))
--             print("1st ma puge ma mg")
--         else
--             self.mCentralComponent = inComponent
--             self.mCentralComponent:Update(self.mPosition_3f, self.mDimension_3f)
--             print("2nd ma puge ma mg")

--         end
--         ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
--             function()
--                 self.mComponentObject:Event()
--                 if self.mComponentObject.mFocus_b and E.is_left_button_pressed() then
--                     self.mPressed = true
--                 end
--             end
--         )
--     end,
--     Update = function(self, inPosition_3f, inDimension_3f)
--         self.mCentralComponent:Update(inPosition_3f, inDimension_3f)
--     end

-- }



Com.MaterialWindow = {
    mTitleBarStack = nil,
    mVerticalLayout = nil,
    mTitleText = nil,
  
    New = function(self, inPosition_3f, inDimension_3f, inHitArea_2f, inTitleText)
        local Obj = Com.WindowLayout:New(inPosition_3f, inDimension_3f, inHitArea_2f)
      
        setmetatable(self, Com.WindowLayout) -- Inherits WindowLayout
        setmetatable(Obj, self)
        self.__index = self
        Obj.mVerticalLayout = Com.VLayout:New(0)
        Obj.mTitleText = inTitleText
        return Obj
    end,
    SetCentralComponent = function(self, inComponent)
        local ImageMinimize = Com.ImageLabelObject:NewExisting(MinimizeImage, vec3(0, 0, 1), vec3(0, 0, 1))
        ImageMinimize:TintColor(vec4(1, 0, 0, 1))
        local ImageMaximize = Com.ImageLabelObject:NewExisting(MaximizeImage, vec3(0, 0, 1), vec3(0, 0, 1))
        ImageMaximize:TintColor(vec4(0, 1, 0, 1))

        local ImageClose = Com.ImageLabelObject:NewExisting(CloseImage, vec3(0, 0, 1), vec3(0, 0, 1))
        ImageClose:TintColor(vec4(0, 0, 1, 1))

        local tb = Com.TextButtonObject:New(self.mTitleText, MaterialFont, self.mPosition_3f,
            vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
        local titleBarHlayout = Com.HLayout:New(0)
        local dummyStack = Com.StackLayout:New()

        titleBarHlayout:AddComponents({ dummyStack, ImageMinimize, ImageMaximize, ImageClose }, { 0.7, 0.1, 0.1 })
        self.mTitleBarStack = Com.StackLayout:New(self.mText)
        self.mTitleBarStack:AddComponents({tb, titleBarHlayout})
        self.mVerticalLayout = Com.VLayout:New(0)
        self.mVerticalLayout:AddComponents({self.mTitleBarStack, inComponent }, { 0.2, 0.8 })
        local titleText = self.mTitleText
        local windowobj = self

        local OverridenVLayoutUpdate = function(self, inPosition_3f, inDimension_3f)
            self.mComponents[1]:Update(inPosition_3f, vec3(inDimension_3f.x, windowobj.mHitArea_2f.y, 1), titleText)
            self.mComponents[2]:Update(vec3(inPosition_3f.x, inPosition_3f.y + windowobj.mHitArea_2f.y, inPosition_3f.z),
                vec3(inDimension_3f.x, inDimension_3f.y - windowobj.mHitArea_2f.y, 1))
        end
        self.mVerticalLayout.Update = nil
        self.mVerticalLayout.Update = OverridenVLayoutUpdate
        Com.WindowLayout.SetCentralComponent(self, self.mVerticalLayout)
    end
}
  