require "jkrgui.PrimitiveComponents"
require "jkrgui.ExtraComponents"
require "jkrgui.LayoutComponents"

function LoadMaterialComponents()
    local CheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
        "icons_material/radio_button_checked/baseline-2x.png")
    local UnCheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
        "icons_material/radio_button_unchecked/baseline-2x.png")
    local DropDown = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/arrow_drop_down/baseline-2x.png")
    local DropUp = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/arrow_drop_up/baseline-2x.png")

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
                Obj.mButtonChecked[i] = Com.ImageLabelObject:NewExisting(CheckedImagePreload, vec3(0, 0, 0),
                    vec3(0, 0, 0))
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
                self.mTableObjectForDescription[i]:Update(
                vec3(self.mPosition_3f[i].x + inDimension_3f.x + self.mPadding,
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
    --[[ yesma chai user le new function ( font, maximumentries kati halnu xa, kati max string length, z ko value) use greraw
 combo box ko object bnauna sakxa
 update grna ko (position of first cell, ani dimension of that cell, table of options jun chai hru select graunu xa, first cell ma agadi dekh kun option choose hunu prxa ki khali rakhnu prxaw, baksa ko agadi k description lekhne ko string)
 even ma tyo object lai call gresi chaluna sakinxa
 feature ko kura grda normal jsto xa bahira click grda bnda hune aru kura afai use grraw herda hunxa
 -----------------------------------------------------------------------------------------------------
 Top of MaterialsComponent.lua
For loading image
           local DropDown = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/arrow_drop_down/baseline-2x.png")
           local DropUp = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/arrow_drop_up/baseline-2x.png")

 In load
         Combo = Com.ComboBox:New(Font,10,20,80)
         Combo:Update(vec3(100,100,5),vec3(150,25,2),{"raja","ram","rule"}," ","choose")
In event
       Combo:Event()
-----------------------------------------------------------------------------------------------------------------]]
    Com.ComboBox = {
        New = function(self, inFontObject, inMaxNoOfEntries, inMaxNoStringLength, inDepth)
            local Obj = {
                mFontObject = inFontObject,
                mButtons = {},
                mCurrentComboContent = {},
                mDepth = inDepth,
                mIndex = nil,
                mPosition_3f = {},
                mDimension_3f = {},
                Flag = false,
                ChoosenChoice = nil,
                isDropDown = true,
                mHeadString = nil,
            }
            setmetatable(Obj, self)
            self.__index = self
            Obj.mHeading = Com.TextLabelObject:New(" ", vec3(0, 0, inDepth), inFontObject)
            Obj.AreaForDropButton = Com.AreaObject:New(vec3(0, 0, inDepth), vec3(0, 0, 0))
            Obj.DropDownButton = Com.ImageLabelObject:NewExisting(DropDown, vec3(0, 0, 0), vec3(0, 0, 0))
            Obj.DropDownButton:TintColor(vec4(0, 0, 0, 1))
            Obj.DropUpButton = Com.ImageLabelObject:NewExisting(DropUp, vec3(0, 0, 0), vec3(0, 0, 0))
            Obj.DropUpButton:TintColor(vec4(0, 0, 0, 1))
            for i = 1, inMaxNoOfEntries, 1 do
                Obj.mButtons[i] = Com.TextButtonObject:New(string.rep(" ", inMaxNoStringLength), inFontObject,
                    vec3(0, 0, inDepth), vec3(0, 0, 0))
            end
            return Obj
        end,
        Update = function(self, inPosition_3f, inOneCellDimension_3f, inComboContent, inDefaultString, inHeadString)
            self.mCurrentComboContent = inComboContent
            self.mHeadString = inHeadString
            local inNoOfEntries = #inComboContent
            local position = vec3(inPosition_3f.x, inPosition_3f.y, self.mDepth)
            self.ChoosenChoice = inDefaultString
            local dimen_string = self.mFontObject:GetDimension(inHeadString)
            self.mHeading:Update(vec3(inPosition_3f.x - dimen_string.x - 5,
                inPosition_3f.y + inOneCellDimension_3f.y / 2 + dimen_string.y / 2, self.mDepth), vec3(0, 0, 0),
                inHeadString)
            for i = 1, inNoOfEntries + 1, 1 do
                if i == 1 then
                    self.mButtons[i]:Update(position, inOneCellDimension_3f, inDefaultString)
                else
                    if self.Flag then
                        self.mButtons[i]:Update(position, inOneCellDimension_3f, inComboContent[i - 1])
                    else
                        self.mButtons[i]:Update(vec3(0, 0, self.mDepth), vec3(0, 0, 0), " ")
                    end
                end
                self.mPosition_3f[i] = vec3(position.x, position.y, position.z)
                self.mDimension_3f[i] = inOneCellDimension_3f
                position.y = position.y + inOneCellDimension_3f.y
            end
            self.AreaForDropButton:Update(
                vec3(self.mPosition_3f[1].x + self.mDimension_3f[1].x, self.mPosition_3f[1].y, self.mDepth),
                vec3(self.mDimension_3f[1].y + 5, self.mDimension_3f[1].y, self.mDimension_3f[1].z))
            if self.isDropDown then
                self.DropDownButton:Update(
                    vec3(self.mPosition_3f[1].x + self.mDimension_3f[1].x, self.mPosition_3f[1].y, self.mDepth - 5),
                    vec3(self.mDimension_3f[1].y + 5, self.mDimension_3f[1].y, self.mDimension_3f[1].z))
                self.DropUpButton:Update(vec3(0, 0, 0), vec3(0, 0, 0))
            else
                self.DropUpButton:Update(
                    vec3(self.mPosition_3f[1].x + self.mDimension_3f[1].x, self.mPosition_3f[1].y, self.mDepth - 5),
                    vec3(self.mDimension_3f[1].y + 5, self.mDimension_3f[1].y, self.mDimension_3f[1].z))
                self.DropDownButton:Update(vec3(0, 0, 0), vec3(0, 0, 0))
            end
        end,
        Event = function(self)
            local inNoOfEntries = #self.mCurrentComboContent
            local MousePos = E.get_mouse_pos()

            if E.is_left_button_pressed() then
                for i = 2, inNoOfEntries + 1, 1 do
                    if MousePos.x > self.mPosition_3f[i].x and MousePos.x <
                        (self.mPosition_3f[i].x + self.mDimension_3f[i].x) and MousePos.y > self.mPosition_3f[i].y and
                        MousePos.y < (self.mPosition_3f[i].y + self.mDimension_3f[i].y) then
                        self.ChoosenChoice = self.mCurrentComboContent[i - 1]
                        self:Update(self.mPosition_3f[1], self.mDimension_3f[1], self.mCurrentComboContent,
                            self.ChoosenChoice, self.mHeadString)
                    end
                end
                if not (MousePos.x > self.mPosition_3f[1].x and MousePos.x <
                        (self.mPosition_3f[1].x + self.mDimension_3f[1].x) and MousePos.y > self.mPosition_3f[1].y and
                        MousePos.y < (self.mPosition_3f[inNoOfEntries + 1].y + self.mDimension_3f[1].y)) then
                    if MousePos.x > (self.mPosition_3f[1].x + self.mDimension_3f[1].x) and MousePos.x < (self.mPosition_3f[1].x + self.mDimension_3f[1].x + self.mDimension_3f[1].y + 5) and MousePos.y > self.mPosition_3f[1].y and
                        MousePos.y < (self.mPosition_3f[1].y + self.mDimension_3f[1].y) then
                        self.isDropDown = not self.isDropDown
                        if self.isDropDown then
                            self.Flag = false

                            self:Update(self.mPosition_3f[1], self.mDimension_3f[1], self.mCurrentComboContent,
                                self.ChoosenChoice, self.mHeadString)
                        else
                            self.Flag = true
                            self:Update(self.mPosition_3f[1], self.mDimension_3f[1], self.mCurrentComboContent,
                                self.ChoosenChoice, self.mHeadString)
                        end
                    else
                        self.Flag = false
                        self.isDropDown = true
                        self:Update(self.mPosition_3f[1], self.mDimension_3f[1], self.mCurrentComboContent,
                            self.ChoosenChoice, self.mHeadString)
                    end
                end
            end

            --  else

            --[[for i = 2, inNoOfEntries + 1 , 1 do
            self.mButtons[i]:Event()
            print("pressed1")
            if self.mButtons[i].mPressed then
                print("Pressed2")
                self:Update(self.mPosition_3f,self.mDimension_3f,self.mCurrentComboContent[i])
            end

        end]]
        end
    }

    Com.IconButton = {
        mImageButton = nil,
        New = function(self, inPosition_3f, inDimension_3f, inIconName)
            local Obj = Com.ButtonProxy:New(inPosition_3f, inDimension_3f)
            setmetatable(self, Com.ButtonProxy) -- inherits Com.ButtonProxy
            setmetatable(Obj, self)
            self.__index = self
            Obj.mImageButton = Com.ImageLabelObject:NewExisting(inIconName,
                vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z),
                inDimension_3f)
            Obj.mImageButton:TintColor(vec4(0, 0, 0, 1))
            return Obj
        end,
        Update = function(self, inPosition_3f, inDimension_3f)
            self.mImageButton:Update(inPosition_3f, inDimension_3f)
            Com.ButtonProxy.Update(self, inPosition_3f, inDimension_3f)
        end
    }
    Com.TextButton = {
        New = function(self, inPosition_3f, inDimension_3f, inFont)
            local Obj = Com.ButtonProxy:New(inPosition_3f, inDimension_3f)
            setmetatable(self, Com.ButtonProxy) -- inherits Com.ButtonProxy
            setmetatable(Obj, self)
            self.__index = self
            Obj.Text = Com.TextButtonObject:New("raja", inFont,
                vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z + 20),
                inDimension_3f)
            Obj.mHoverFunction = function()
                print("Pressed1")
            end
            Obj.mClickedFunction = function()
                print("pressed2")
            end
            Obj.mClickedOutfunction = function()
                print("Preseed3")
            end
            return Obj
        end
    }
    Com.MaterialWindow = {
        mVerticalLayout = nil,
        mTitleText = nil,
        New = function(self, inPosition_3f, inDimension_3f, inHitArea_2f, inTitleText, inFontObject)
            local Obj = Com.WindowLayout:New(inPosition_3f, inDimension_3f, inHitArea_2f)
            setmetatable(self, Com.WindowLayout)
            setmetatable(Obj, self)
            self.__index = self

            Obj.mPosition_3f = inPosition_3f
            Obj.mDimension_3f = inDimension_3f
            Obj.mTitleText = inTitleText
            Obj.mFontObject = inFontObject
            return Obj
        end,
        SetCentralComponent = function(self, inComponent)
            local titleBar = Com.TextButtonObject:New(self.mTitleText, self.mFontObject, self.mPosition_3f,
                vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
            local close_button = Com.IconButton:New(vec3(0, 0, self.mPosition_3f.z), vec3(0, 0, 0), DropDown)
            local minmax_button = Com.IconButton:New(vec3(0, 0, self.mPosition_3f.z), vec3(0, 0, 0), DropUp)
            local minimize_button = Com.IconButton:New(vec3(0, 0, self.mPosition_3f.z), vec3(0, 0, 0), DropUp)

            close_button:SetFunctions(
                function()
                    close_button.mImageButton:TintColor(vec4(1, 0, 0, 1))
                end,
                function()
                    close_button.mImageButton:TintColor(vec4(0, 0, 0, 1))
                end,
                function()
                    self:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                end
            )

            minmax_button:SetFunctions(
                function()
                    minmax_button.mImageButton:TintColor(vec4(1, 0, 1, 1))
                end,
                function()
                    minmax_button.mImageButton:TintColor(vec4(0, 0, 0, 1))
                end,
                function()

                end
            )

            minimize_button:SetFunctions(
                function()
                    minimize_button.mImageButton:TintColor(vec4(0, 1, 0, 1))
                end,
                function()
                    minimize_button.mImageButton:TintColor(vec4(0, 0, 0, 1))
                end,
                function()

                end
            )

            local horizontalcomponents = Com.HLayout:New(0)
            local blankspace = Com.StackLayout:New(0)
            horizontalcomponents:AddComponents({ blankspace, minimize_button, minmax_button, close_button },
                { 0.7, 0.1, 0.1, 0.1 })

            local Window = self
            horizontalcomponents.Update = function(self, inPosition_3f, inDimension_3f)
                local dimen = vec3(Window.mHitArea_2f.y, Window.mHitArea_2f.y, inDimension_3f.z)
                local position = vec3(inPosition_3f.x + inDimension_3f.x - dimen.x, inPosition_3f.y, inPosition_3f.z)
                for i = #self.mComponents, 2, -1 do
                    self.mComponents[i]:Update(position, dimen)
                    position.x = position.x - dimen.x
                end
            end
            horizontalcomponents:Update(vec3(self.mPosition_3f.x, self.mPosition_3f.y, self.mPosition_3f.z),
                vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))


            local titlebar_buttons = Com.StackLayout:New(5)
            titlebar_buttons:AddComponents({ titleBar, horizontalcomponents })
            titlebar_buttons:Update(self.mPosition_3f, vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
            local verticalLayout = Com.VLayout:New(0)
            verticalLayout:AddComponents({ titlebar_buttons, inComponent }, { 0.2, 0.8 })
            Com.WindowLayout.SetCentralComponent(self, verticalLayout)
        end,
    }
end
