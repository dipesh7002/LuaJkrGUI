require "jkrgui.PrimitiveComponents"
require "jkrgui.MaterialComponents"
require "jkrgui.LayoutComponents"



Com.FileMenuBarObject_Duplicate = {
    mMainArea = nil,
    mHeight = nil,
    mFileMenu = nil,
    mDimension_3f = nil,
    New = function(self, inFileMenu, inHeight, inFontObject, inDepth)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        local mainareapos = vec3(0, 0, inDepth)
        local mainareadimen = vec3(WindowDimension.x, inHeight, 1)
        Obj.mMainArea = Com.AreaObject:New(mainareapos, mainareadimen)
        Obj.mHeight = inHeight
        Obj.mDepth = inDepth
        Obj.mButtons = {}
        Obj.mFileMenu = inFileMenu
        Obj.mNoOfEntries = #inFileMenu
        Obj.mDimension_3f = nil
        for i = 1, #inFileMenu, 1 do
            Obj.mButtons[i] = Com.TextButton:New(mainareapos, vec3(0, 0, 0), inFontObject, inFileMenu[i].name)
        end
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mDimension_3f = inDimension_3f
        local ratiotable = {}

        for i = 1, self.mNoOfEntries, 1 do
            ratiotable[i] = 1 / self.mNoOfEntries
        end
        local horizontalcomponents = Com.HLayout:New(0)
        horizontalcomponents:AddComponents(self.mButtons, ratiotable)
        horizontalcomponents:Update(vec3(0, 0, self.mDepth), inDimension_3f)
        local position = horizontalcomponents:GetComponentPosition()
        for i = 1, self.mNoOfEntries, 1 do
            self.mButtons[i]:SetFunctions(
                function()
                    ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor = vec4(0, 0, 1, 0.7)
                end,
                function()
                    local nc = Theme.Colors.Area.Normal
                    ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor = vec4(nc.x, nc.y, nc.z, nc.w)
                end,
                function()
                    local pos = vec3(position[i].x, position[i].y + self.mHeight, position[i].z)
                    self.mFileMenu[i].action(pos)
                end
            )
        end
    end
}


Com.ContextMenu_Duplicate = {
    mMainArea = nil,
    mCellDimension_3f = vec3(0, 0, 0),
    mPosition_3f = nil,
    mButtons = nil,
    mMaxNoOfEntries = nil,
    New = function(self, inPosition_3f, inCellDimension_3f, inFontObject, inNoOfEntries, inMaxStringLength)
        local Obj = {
            mPosition_3f = inPosition_3f,
            mCellDimension_3f = inCellDimension_3f,
            mButtons = {},
            mMaxNoOfEntries = inNoOfEntries,
            mCurrentContextMenu = {}
        }
        setmetatable(Obj, self)
        self.__index = self
        local MainAreaDimen = vec3(0, 0, 1)
        Obj.mMainArea = Com.AreaObject:New(inPosition_3f, MainAreaDimen)
        local button_dimension = vec3(0, 0, 0)
        for i = 1, inNoOfEntries, 1 do
            local pos = vec3(inPosition_3f.x, inPosition_3f.y + inCellDimension_3f.y * (i - 1), inPosition_3f.z - 3)
            Obj.mButtons[i] = Com.TextButton:New(pos,
                button_dimension, inFontObject, string.rep(" ", inMaxStringLength))
                
        end
        return Obj
    end,
    Update = function(self, inPosition_3f, inCellDimension_3f, inContextMenuTable)
        self.mCurrentContextMenu = inContextMenuTable
        self.mMainArea:Update(vec3(0, 0, self.mMainArea.mPosition_3f.z), vec3(0, 0, 0))
        for index, value in ipairs(self.mButtons) do
            value:Update(vec3(0, 0, value.mPosition_3f.z), vec3(0, 0, 0), " ")
        end
        local inNoOfEntries = #inContextMenuTable
        local MainAreaDimension = vec3(inCellDimension_3f.x, inCellDimension_3f.y * inNoOfEntries, 1)
        local mainareapos = vec3(inPosition_3f.x, inPosition_3f.y, self.mMainArea.mPosition_3f.z)
        self.mMainArea:Update(mainareapos, MainAreaDimension)
        for i = 1, inNoOfEntries, 1 do
            local pos = vec3(inPosition_3f.x, inPosition_3f.y + inCellDimension_3f.y * (i - 1),
                self.mButtons[i].mPosition_3f.z)
            self.mButtons[i]:Update(pos, inCellDimension_3f, inContextMenuTable[i].name)
        end
        for i = 1, inNoOfEntries, 1 do
            self.mButtons[i]:SetFunctions(
                function()
                    ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor = vec4(0.5, 0, 1, 0.7)
                end,
                function()
                    local nc = Theme.Colors.Area.Normal
                    ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor = vec4(nc.x, nc.y, nc.z, nc.w)
                    if E.is_left_button_pressed() then
                        self:Update(vec3(0, 0, 0), vec3(0, 0, 0), {})
                    end
                end,
                function()
                end
            )
        end
    end,

}
