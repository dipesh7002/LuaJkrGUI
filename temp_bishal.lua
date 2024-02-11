require "jkrgui.PrimitiveComponents"
require "jkrgui.MaterialComponents"
require "jkrgui.LayoutComponents"
require "jkrgui.ExtraComponents"
require "jkrgui.Resources"
require "jkrgui.TextEditorComponents"
local radio_button_checked = Jkr.Components.Abstract.ImageObject:New(0, 0,
    "icons_material/radio_button_checked/baseline-2x.png")
local radio_button_unchecked = Jkr.Components.Abstract.ImageObject:New(40, 40,
    "icons_material/radio_button_unchecked/baseline-2x.png")
local DropDown = Jkr.Components.Abstract.ImageObject:New(0, 0,
    "icons_material/arrow_drop_down/baseline-2x.png")
local DropUp = Jkr.Components.Abstract.ImageObject:New(0, 0,
    "icons_material/arrow_drop_up/baseline-2x.png")
Bishal = {}
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
        Com.ButtonProxy.Update(self, inPosition_3f, inDimension_3f)

        self.mImageButton:Update(inPosition_3f, inDimension_3f)
    end
}
Com.TextButton = {
    mTextButton = nil,
    New = function(self, inPosition_3f, inDimension_3f, inFont, inString)
        local Obj = Com.ButtonProxy:New(inPosition_3f, inDimension_3f)
        setmetatable(self, Com.ButtonProxy) -- inherits Com.ButtonProxy
        setmetatable(Obj, self)
        self.__index = self
        Obj.mText = inString
        Obj.mTextButton = Com.TextButtonObject:New(inString, inFont, inPosition_3f, inDimension_3f)
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inString)
        self.mText = inString
        self.mTextButton:Update(inPosition_3f, inDimension_3f, inString)
        Com.ButtonProxy.Update(self, inPosition_3f, inDimension_3f)
    end
}
Com.ComboBox_duplicate = {
    New = function(self, inFontObject, inMaxNoOfEntries, inMaxNoStringLength, inDepth, inPadding)
        local Obj = {
            mFontObject = inFontObject,
            mButtons = {},
            mCurrentComboContent = {},
            mDepth = inDepth,
            mPosition_3f = {},
            mDimension_3f = {},
            ChoosenChoice = nil,
            mHeadString = nil,
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self
        Obj.mHeading = Com.TextLabelObject:New(" ", vec3(0, 0, inDepth), inFontObject)
        Obj.Areaforicon = Com.AreaObject:New(vec3(0, 0, 0), vec3(0, 0, 0))
        Obj.mDropdown = Com.IconButton:New(vec3(0, 0, 0), vec3(0, 0, 0), DropDown)
        Obj.mDropup = Com.IconButton:New(vec3(0, 0, 0), vec3(0, 0, 0), DropUp)
        for i = 1, inMaxNoOfEntries, 1 do
            Obj.mButtons[i] = Com.TextButton:New(vec3(0, 0, inDepth), vec3(0, 0, 0), inFontObject,
                string.rep(" ", inMaxNoStringLength))
        end
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inOneCellDimension_3f, inComboContent,
                      inDefaultString, inHeadString)
        self.mCurrentComboContent = inComboContent
        self.mHeadString = inHeadString
        local inNoOfEntries = #inComboContent
        self.ChoosenChoice = inDefaultString
        local dimen_string = self.mFontObject:GetDimension(inHeadString)
        self.mHeading:Update(vec3(inPosition_3f.x,
                inPosition_3f.y + inOneCellDimension_3f.y / 2 +
                dimen_string.y / 2, self.mDepth),
            vec3(0, 0, 0),
            inHeadString)
        self.mPosition_3f = vec3(inPosition_3f.x + dimen_string.x + 5, inPosition_3f.y, self.mDepth)
        local position = vec3(inPosition_3f.x + dimen_string.x + 5, inPosition_3f.y, self.mDepth)
        local positionforicon = vec3(self.mPosition_3f.x + inOneCellDimension_3f.x + 5, self.mPosition_3f.y, self.mDepth)
        local dimensionoficon = vec3(inOneCellDimension_3f.y, inOneCellDimension_3f.y, inOneCellDimension_3f.z)
        self.Areaforicon:Update(positionforicon, dimensionoficon)
        self.mDropdown:Update(positionforicon, dimensionoficon)
        self.mDropup:Update(vec3(0, 0, 0), vec3(0, 0, 0))
        self.mButtons[1]:Update(position, inOneCellDimension_3f, self.ChoosenChoice)
        local TextButton = function(flag)
            if flag then
                for i = 2, inNoOfEntries + 1, 1 do
                    position.y = position.y + inOneCellDimension_3f.y + self.mPadding
                    self.mButtons[i]:Update(position, inOneCellDimension_3f, self.mCurrentComboContent[i - 1])
                end
            else
                for i = 2, inNoOfEntries + 1, 1 do
                    position.y = position.y + inOneCellDimension_3f.y + 5
                    self.mButtons[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0), " ")
                end
            end
            position = vec3(self.mPosition_3f.x, self.mPosition_3f.y, self.mDepth)
        end
        local window = self
        self.mDropdown:SetFunctions(
            function()
                window.mDropdown.mImageButton:TintColor(vec4(1, 0, 0, 1))
            end,
            function()
                window.mDropdown.mImageButton:TintColor(vec4(0, 0, 0, 1))
            end,
            function()
                window.mDropdown:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                TextButton(true)
                Com.NewComponent_SingleTimeUpdate()
                ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(
                    function()
                        window.mDropup:Update(positionforicon, dimensionoficon)
                    end
                )
            end
        )
        self.mDropup:SetFunctions(
            function()
                window.mDropup.mImageButton:TintColor(vec4(1, 0, 0, 1))
            end,
            function()
                window.mDropup.mImageButton:TintColor(vec4(0, 0, 0, 1))
            end,
            function()
                window.mDropup:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                TextButton(false)
                Com.NewComponent_SingleTimeUpdate()
                ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(
                    function()
                        window.mDropdown:Update(positionforicon, dimensionoficon)
                    end
                )
            end
        )

        for i = 2, inNoOfEntries + 1, 1 do
            self.mButtons[i]:SetFunctions(
                function()
                    local nc = Theme.Colors.Area.Border
                    ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor =
                        vec4(nc.x, nc.y, nc.z, nc.w)
                end,
                function()
                    local nc = Theme.Colors.Area.Normal
                    ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor =
                        vec4(nc.x, nc.y, nc.z, nc.w)
                end,
                function()
                    self.mButtons[1]:Update(self.mPosition_3f,
                        inOneCellDimension_3f, self.mButtons[i].mText)
                end
            )
        end
    end,
}
Com.RadioButton = {
    mPosition_3f = nil,
    mDimension_3f = nil,
    mFontObject = nil,
    mPadding = nil,
    mTextLabel = {},
    mRadioButtonChecked = {},
    mRadioButtonUnChecked = {},
    New = function(self, inFontObject, inMaxNoOfEntries, inPadding)
        local Obj = {
            mPosition_3f = nil,
            mDimension_3f = nil,
            mFontObject = inFontObject,
            mPadding = inPadding,
            mTextLabel = {},
            mRadioButtonChecked = {},
            mRadioButtonUnChecked = {},
            area = {}
        }
        setmetatable(Obj, self)
        self.__index = self
        for i = 1, inMaxNoOfEntries, 1 do
            Obj.mTextLabel[i] = Com.TextLabelObject:New(" ", vec3(0, 0, 0), inFontObject)
            Obj.mRadioButtonChecked[i] = Com.IconButton:New(vec3(0, 0, 0), vec3(0, 0, 0), radio_button_checked)
            Obj.mRadioButtonUnChecked[i] = Com.IconButton:New(vec3(0, 0, 0), vec3(0, 0, 0), radio_button_unchecked)
        end
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inTextLabelTable, inDefaultIndexTable)
        local no_of_entries = #inTextLabelTable
        self.mPosition_3f = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        self.mDimension_3f = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        local dimensionforicon = vec3(inDimension_3f.y, inDimension_3f.y, inDimension_3f.z)
        local positionforicon = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local position_each_button = {}
        for i = 1, no_of_entries, 1 do
            position_each_button[i] = vec3(positionforicon.x, positionforicon.y, positionforicon.z)
            for index, value in ipairs(inDefaultIndexTable) do
                if i == value then
                    self.mRadioButtonChecked[i]:Update(positionforicon, dimensionforicon)
                    positionforicon.y = positionforicon.y + dimensionforicon.y + self.mPadding
                    goto continue
                end
            end
            self.mRadioButtonUnChecked[i]:Update(positionforicon, dimensionforicon)
            positionforicon.y = positionforicon.y + dimensionforicon.y + self.mPadding
            ::continue::
        end

        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        for i = 1, no_of_entries, 1 do
            local dimens_string = self.mFontObject:GetDimension(inTextLabelTable[i])
            local positionfortext = vec3(position.x + dimensionforicon.x + 5,
                position.y + dimensionforicon.y / 2 + dimens_string.y / 2.5, position.z)
            self.mTextLabel[i]:Update(positionfortext, vec3(0, 0, 0), inTextLabelTable[i])
            position.y = position.y + dimensionforicon.y + self.mPadding
        end
        local This = self

        for i = 1, no_of_entries, 1 do
            self.mRadioButtonChecked[i]:SetFunctions(
                function()
                end,
                function()
                end,
                function()
                    This.mRadioButtonChecked[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                    Com.NewComponent_SingleTimeUpdate()
                    ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(
                        function()
                            This.mRadioButtonUnChecked[i]:Update(position_each_button[i], dimensionforicon)
                        end)
                end)
            self.mRadioButtonUnChecked[i]:SetFunctions(
                function()
                end,
                function()
                end,
                function()
                    This.mRadioButtonUnChecked[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0))
                    Com.NewComponent_SingleTimeUpdate()
                    ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(
                        function()
                            This.mRadioButtonChecked[i]:Update(position_each_button[i], dimensionforicon)
                        end)
                end)
        end
    end


}

Com.GridLayout = {
    mPadding = nil,
    mPosition_3f = nil,
    mDimension_3f = nil,

    New = function(self, inPadding)
        local Obj = {
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self

        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inNoOfCell_Row, inNoOfCell_Coloumn, inComponentTable)
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        local OneCellDimension = vec3(0, 0, inDimension_3f.z)
        local k = 1
        OneCellDimension.x = (dimension.x - (self.mPadding * (inNoOfCell_Row - 1))) / inNoOfCell_Row
        OneCellDimension.y = (dimension.y - (self.mPadding * (inNoOfCell_Coloumn - 1))) / inNoOfCell_Coloumn
        for i = 1, inNoOfCell_Coloumn, 1 do
            for j = 1, inNoOfCell_Row, 1 do
                inComponentTable[k]:Update(position, OneCellDimension)
                position.x = position.x + self.mPadding + OneCellDimension.x
                k = k + 1
            end
            position.y = position.y + self.mPadding + OneCellDimension.y
            position.x = inPosition_3f.x
        end
    end
}
Bishal.CanvasPractice = function()

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
LoadBishal = function()
    Jkr.GLSL["BishalCanvas"] = CanvasHeader .. [[
        float color = distance(xy_cartesian, vec2(0, 0)) - 0.5;
        vec4 newcolor = vec4(color, 0, 0, 1);
        newcolor.r = smoothstep(0.0, 0.1, newcolor.r);
        imageStore(storageImage, to_draw_at, newcolor);
     ]]

    NewCanvas = Com.Canvas:New(vec3(100, 100, 80), vec3(100, 100, 1))
    NewCanvas:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
    NewCanvas:AddPainterBrush(Com.GetCanvasPainter("RoundedRectangle", false))
    NewCanvas:AddPainterBrush(Com.GetCanvasPainter("Bishal", true))

    NewCanvas:MakeCanvasImage(100, 100)
    Com.NewComponent_SingleTimeDispatch()
    ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
        function()
            NewCanvas.CurrentBrushId = 3
            NewCanvas:Bind()
            NewCanvas:Paint(vec4(0, 0, 100, 100), vec4(1, 0, 1, 1), vec4(1, 1, 1, 1), 100, 100, 1)
        end
    )
end
