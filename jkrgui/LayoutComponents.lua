require "jkrgui.ExtraComponents"

Com.HLayout = {
    mComponents = nil,
    mRatioTable = nil,
    mPadding = nil,

    New = function(self, inPadding)
        local Obj = {
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self

        return Obj
    end,
    AddComponents = function(self, inComponentListTable, inRatioTable)
        self.mComponents = inComponentListTable
        self.mRatioTable = inRatioTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = inPosition_3f
        local dimension = inDimension_3f
        local paddingX = self.mPadding

        if self.mRatioTable then
            for index, value in ipairs(self.mComponents) do
                value:Update(vec3(position.x, position.y, position.z),
                    vec3(dimension.x * self.mRatioTable[index], dimension.y, dimension.z),
                    self.mComponents[index].mText)
                position.x = position.x + dimension.x * self.mRatioTable[index] + paddingX
            end
        end
    end
}

Com.VLayout = {
    mComponents = nil,
    mRatioTable = nil,
    mPadding = nil,

    New = function(self, inPadding)
        local Obj = {
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self
        return Obj
    end,
    AddComponents = function(self, inComponentListTable, inRatioTable)
        self.mComponents = inComponentListTable
        self.mRatioTable = inRatioTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = vec3(inPosition_3f.x ,inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x,inDimension_3f.y,inDimension_3f.z)
        local paddingY = self.mPadding 
        if self.mRatioTable then
            for index, value in ipairs(self.mComponents) do
                value:Update(vec3(position.x, position.y, position.z),
                    vec3(dimension.x, dimension.y * self.mRatioTable[index], dimension.z),
                    self.mComponents[index].mText)
                position.y = position.y + dimension.y * self.mRatioTable[index] + paddingY
            end
        end
    end
}

Com.WindowLayout = {
    mHitArea_2f = nil,
    mComponentObject = nil, -- yo hamro wala components haina, Jkr.ComponentObject wala component ho, esko naam fernu parlaa jasto xa TODO,
                            -- maintainence ko bela garnu parxa
    mCentralComponent = nil,
    mPosition_3f = nil,
    mDimension_3f = nil,
    mMoving = nil,
    New = function(self, inPosition_3f, inDimension_3f, inHitArea_2f)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mHitArea_2f = inHitArea_2f
        Obj.mComponentObject = Jkr.ComponentObject:New(inPosition_3f, vec3(inHitArea_2f.x, inHitArea_2f.y, 1))
        Obj.mComponentObject.mFocusOnHover_b = false
        Obj.mPosition_3f = inPosition_3f
        Obj.mDimension_3f = inDimension_3f
        Obj.mMoving = false
        return Obj
    end,
    Start = function(self)
        Com.NewComponent()
        local i = com_i
        ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(function ()
            local offset = vec2(self.mPosition_3f.x, self.mPosition_3f.y)
            local extent = vec2(self.mDimension_3f.x, self.mDimension_3f.y)
            Jkr.set_scissor(offset, extent)
        end)
    end,
    End = function(self)
        Com.NewComponent()
        local i = com_i
        ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(function ()
            Jkr.reset_scissor()
        end)
    end,
    SetCentralComponent = function(self, inComponent)
        self.mCentralComponent = inComponent
        self.mCentralComponent:Update(self.mPosition_3f, self.mDimension_3f)
        Com.NewComponent_Event()
        ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
            function()
                self.mComponentObject:Event()
                if self.mComponentObject.mFocus_b or (self.mMoving and E.is_left_button_pressed()) then
                    local mpos = E.get_relative_mouse_pos()
                    self.mPosition_3f.x = self.mPosition_3f.x + mpos.x
                    self.mPosition_3f.y = self.mPosition_3f.y + mpos.y
                    self.mCentralComponent:Update(self.mPosition_3f, self.mDimension_3f)
                    self.mComponentObject:Update(self.mPosition_3f, self.mDimension_3f)
                    self.mMoving = true
                else
                    self.mMoving = false
                end
            end
         )
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mCentralComponent:Update(inPosition_3f, inDimension_3f)
    end
}
