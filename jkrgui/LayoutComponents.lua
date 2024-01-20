require "jkrgui.ExtraComponents"

Com.HLayout = {
    mComponents = nil,
    mRatioTable = nil,
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
    AddComponents = function(self, inComponentListTable, inRatioTable)
        self.mComponents = inComponentListTable
        self.mRatioTable = inRatioTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)


        local paddingX = self.mPadding

        if self.mRatioTable then
            for index, value in ipairs(self.mComponents) do
                value:Update(vec3(position.x, position.y, position.z),
                    vec3(dimension.x * self.mRatioTable[index], dimension.y, dimension.z),
                    self.mComponents[index].mText)
                position.x = position.x + dimension.x * self.mRatioTable[index] + paddingX
            end
        end
    end,
    GetComponentPosition = function(self)
        local position = vec3(self.mPosition_3f.x, self.mPosition_3f.y, self.mPosition_3f.z)
        local dimension = vec3(self.mDimension_3f.x, self.mDimension_3f.y, self.mDimension_3f.z)
        local ComponentsPosition = {}
        for index, value in ipairs(self.mComponents) do
            ComponentsPosition[index] = vec3(position.x, position.y, position.z)
            position.x = position.x + dimension.x * self.mRatioTable[index] + self.mPadding
        end
        return ComponentsPosition
    end
}

Com.VLayout = {
    mComponents = nil,
    mRatioTable = nil,
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
    AddComponents = function(self, inComponentListTable, inRatioTable)
        self.mComponents = inComponentListTable
        self.mRatioTable = inRatioTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        local paddingY = self.mPadding
        if self.mRatioTable then
            for index, value in ipairs(self.mComponents) do
                value:Update(vec3(position.x, position.y, position.z),
                    vec3(dimension.x, dimension.y * self.mRatioTable[index], dimension.z),
                    self.mComponents[index].mText)
                position.y = position.y + dimension.y * self.mRatioTable[index] + paddingY
            end
        end
    end,
    GetComponentPosition = function(self)
        local position = vec3(self.mPosition_3f.x, self.mPosition_3f.y, self.mPosition_3f.z)
        local dimension = vec3(self.mDimension_3f.x, self.mDimension_3f.y, self.mDimension_3f.z)
        local ComponentsPosition = {}
        for index, value in ipairs(self.mComponents) do
            ComponentsPosition[index] = vec3(position.x, position.y, position.z)
            position.y = position.y + dimension.y * self.mRatioTable[index] + self.mPadding
        end
        return ComponentsPosition
    end
}
Com.StackLayout = {
    mComponents = nil,
    New = function(self, inChangingZvalue)
        local Obj = {
            mChangingZvalue = inChangingZvalue
        }
        setmetatable(Obj, self)
        self.__index = self
        return Obj
    end,
    AddComponents = function(self, inComponentListTable)
        self.mComponents = inComponentListTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        for index, value in ipairs(self.mComponents) do
            value:Update(vec3(position.x, position.y, position.z),
                vec3(dimension.x, dimension.y , dimension.z),
                self.mComponents[index].mText)
            position.z = position.z - self.mChangingZvalue
        end
    end
}


--[[
    Yo Chae WindowLayout ho,
    Esko euta CentralComponent Object hunxa,
    tyo mComponentObject vaneko chae Jkr.ComponentObject ho, gaera hernu tyaa k xa vanera
    mainly, tei event ko laagi ho mouse maathi aauda focus garne na garne, left button thichda focus hune na hune
    ani Z value anusaar kun chae Component(Jkr.ComponentObject) wala lai select garne jasto kura haru handle garxa

    ani yo use esari garne ho

    WindowLayout = Com.WindowLayout:New(..blah..blah) -- HitArea vaneko chae tyo area jaa thichda mouse lai respond garxa window le
    WindowLayout:Start() -- yo Start le scissor set garxa (scissor arthat kaichi, matlab tyo area ma matra draw hunxa, tyo area vanda baahira position xa vane draw hunna)
        -- aba yaa naya component  banaune Jun Window vitra halnu parne xa
        WindowLayout:SetCentralComponent(..componentname..)
    WindowLayout:End()

    Code Sample ---------------------------------------------------------------------------------------------------------------------------
                    ImagePreload = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material\\4k\\outline.png")

                    Window = Com.WindowLayout:New(vec3(400, 400, 80), vec3(100, 100, 1), vec2(100, 10))
                    Window:Start()
                            ImageLLable = Com.ImageLabelObject:NewExisting(ImagePreload, vec3(100, 100, 80), vec3(20, 20, 1))
                            ImageLLable:TintColor(vec4(1, 0, 0, 1))
                            ImageLLable2 = Com.ImageLabelObject:NewExisting(ImagePreload, vec3(100, 100, 80), vec3(20, 20, 1))
                            ImageLLable2:TintColor(vec4(0, 0, 0, 1))
                            VLayout = Com.VLayout:New(0)
                            VLayout:AddComponents({ImageLLable2, ImageLLable}, {0.1, 0.9})
                            Window:SetCentralComponent(VLayout)
                    Window:End()
    ---------------------------------------------------------------------------------------------------------------------------------------
]]
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
        Obj.mPosition_3f = inPosition_3f
        Obj.mDimension_3f = inDimension_3f
        Obj.mMoving = false
        return Obj
    end,
    Start = function(self)
        Com.NewComponent()
        local i = com_i
        ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(function()
            local offset = vec2(self.mPosition_3f.x, self.mPosition_3f.y)
            local extent = vec2(self.mDimension_3f.x, self.mDimension_3f.y)
            if offset.x > 0 and offset.y > 0 then
                Jkr.set_scissor(offset, extent)
            end
        end)
    end,
    End = function(self)
        Com.NewComponent()
        local i = com_i
        ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(function()
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
                if self.mComponentObject.mClicked_b or (self.mMoving and E.is_left_button_pressed()) then
                    local mpos = E.get_relative_mouse_pos()
                    self.mPosition_3f.x = self.mPosition_3f.x + mpos.x
                    self.mPosition_3f.y = self.mPosition_3f.y + mpos.y
                    self.mCentralComponent:Update(self.mPosition_3f, self.mDimension_3f)
                    self.mComponentObject:Update(self.mPosition_3f, vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
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


Com.ButtonProxy = {
    mComponentObject = nil,
    mPosition_3f = nil,
    mDimension_3f = nil,
    mHoverFunction = nil,
    mClickedFunction = nil,
    mClickedOutfunction = nil,

    New = function(self, inPosition_3f, inDimension_3f)
        local Obj = {
            mComponentObject = Jkr.ComponentObject:New(inPosition_3f, inDimension_3f),
            mPosition_3f = inPosition_3f,
            mDimension_3f = inDimension_3f,
            mHoverFunction = function() end,
            mClickedFunction = function() end,
            mHoverOutFunction = function () end,
        }
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent_Event()
        ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
            function()
                Obj.mComponentObject:Event()
                if Obj.mComponentObject.mHovered_b then
                    Obj.mHoverFunction()
                end

                if Obj.mComponentObject.mClicked_b then
                    Obj.mClickedFunction()
                end
                
            end
        )
        return Obj
    end,
    SetFunctions = function(self, inHoverFunction, inClickedFunction)
        self.mHoverFunction = inHoverFunction
        self.mClickedFunction = inClickedFunction
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        self.mComponentObject:Update(inPosition_3f, inDimension_3f)
    end
}
