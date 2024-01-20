require "jkrgui.ComTable"


Com.AreaObject = {
    mIds = vec2(0, 0),
    mPosition_3f = vec3(0, 0, 0),
    mDimension_3f = vec3(0, 0, 0),
    mAreaId = nil,
    New = function(self, inPosition_3f, inDimension_3f)
        local Obj = {
            mIds = vec2(0, 0),
            mPosition_3f = vec3(0, 0, 0),
            mDimension_3f = vec3(0, 0, 0),
            mAreaId = 0,
        }
        -- "AreaObject Construction")
        setmetatable(Obj, self)
        self.__index = self
        Obj.mPosition_3f = inPosition_3f
        Obj.mDimension_3f = inDimension_3f

        local AreaPos = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local AreaDimen = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)

        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(AreaPos, AreaDimen, nil, nil)
        local nc = Theme.Colors.Area.Normal
        ComTable[com_i].mFillColor = vec4(nc.x, nc.y, nc.z, nc.w)
        Obj.mIds.y = com_i
        Obj.mAreaId = com_i
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        local i = self.mIds.x
        local AreaPos = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local AreaDimen = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        ComTable[self.mAreaId]:Update(AreaPos, AreaDimen)
    end
}

Com.TextLabelObject = {
    mIds = vec2(0, 0),
    mPosition_3f = vec3(0, 0, 0),
    mDimension_3f = vec3(0, 0, 0),
    New = function(self, inText, inPosition_3f, inFontObject)
        -- "TextLabelObject Construction")
        local Obj = {
            mIds = vec2(0, 0),
            mPosition_3f = vec3(0, 0, 0),
            mDimension_3f = vec3(0, 0, 0)
        }
        setmetatable(Obj, self)
        self.__index = self
        Obj.mPosition_3f = inPosition_3f
        Com.NewComponent()
        Obj.mIds.x = com_i
        ComTable[com_i] = Jkr.Components.Static.TextObject:New(inText, inPosition_3f, inFontObject)
        -- "TextLabelObject Construction Finished")
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inString)
        self.mPosition_3f = inPosition_3f
        if inString then
            ComTable[self.mIds.x].mString = inString
        end
        ComTable[self.mIds.x]:Update(inPosition_3f)
    end
}

Com.ImageLabelObject = {
    mImageObjectAbs = nil,
    mShapeId = nil,
    New = function (self, inFileName, inPosition_3f, inDimension_3f)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mImageObjectAbs = Jkr.Components.Abstract.ImageObject:New(0, 0, inFileName)
        Com.NewComponent() 
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(inPosition_3f, inDimension_3f, Obj.mImageObjectAbs)
        Obj.mShapeId = com_i
        return Obj
    end,
    NewEmpty  = function (self, inWidth, inHeight, inPosition_3f, inDimension_3f)
        local Obj = {} 
        setmetatable(Obj, self)
        self.__index = self
        Obj.mImageObjectAbs = Jkr.Components.Abstract.ImageObject:New(inWidth, inHeight, nil)
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(inPosition_3f, inDimension_3f, Obj.mImageObjectAbs)
        Obj.mShapeId = com_i
        return Obj
    end,
    NewExisting = function (self, inImageObject, inPosition_3f, inDimension_3f)
        local Obj = {} 
        setmetatable(Obj, self)
        self.__index = self
        Obj.mImageObjectAbs = inImageObject
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(inPosition_3f, inDimension_3f, inImageObject)
        Obj.mShapeId = com_i
        return Obj
    end,
    Update = function (self, inPosition_3f, inDimension_3f)
        ComTable[self.mShapeId]:Update(inPosition_3f, inDimension_3f)
    end,
    TintColor = function (self, inColor_4f)
        ComTable[self.mShapeId].mFillColor = inColor_4f
    end,
    PaintByComputeSingleTime = function(self, inPainterWithPainterParameters, inPainterWithRegisteredImage)
        local ip = inPainterWithPainterParameters
        Com.NewComponent_SingleTimeDispatch()
        ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
            function ()
                inPainterWithRegisteredImage:BindImage()
                ip.painter:BindPainter()
                ip.painter:Paint(ip.posdimen, ip.color, ip.param, self.mImageObjectAbs, inPainterWithRegisteredImage) 
            end
        )
    end,
    PaintByComputeDispatch = function(self, inPainterWithPainterParameters, inPainterWithRegisteredImage)
        local ip = inPainterWithPainterParameters
        inPainterWithRegisteredImage:BindImage()
        ip.painter:BindPainter()
        ip.painter:Paint(ip.posdimen, ip.color, ip.param, self.mImageObjectAbs, inPainterWithRegisteredImage) 
    end
}

Com.TextButtonObject = {
    mPadding = 5,
    mTextObject = nil,
    mFunction = nil,
    mPressed = false,
    New = function(self, inText, inFontObject, inPosition_3f, inDimension_3f)
        -- "TextButtonObject")
        local Obj = Com.AreaObject:New(inPosition_3f, inDimension_3f)
        setmetatable(self, Com.AreaObject) -- Inherits Com.AreaObject
        setmetatable(Obj, self)
        self.__index = self
        Obj.mText = inText
        Obj.mTextObject = {}
        Obj.mPadding = {}
        Obj.mFunction = {}
        Obj.mPressed = {}
        Obj.mPressed = false
        Obj.mPadding = 5
        local Position = vec3(inPosition_3f.x + Obj.mPadding, inPosition_3f.y + inDimension_3f.y - Obj.mPadding,
            inPosition_3f.z - 3)
        Obj.mTextObject = Com.TextLabelObject:New(inText, Position, inFontObject)
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inString)
        Com.AreaObject.Update(self, inPosition_3f, inDimension_3f)
        local Position = vec3(inPosition_3f.x + self.mPadding, inPosition_3f.y + inDimension_3f.y - self.mPadding,
            inPosition_3f.z - 3)
        if inString then
            self.mTextObject:Update(Position, nil, inString)
        end
    end,
    Event = function(self)
    end,
    SetFunction = function(self, inFunction)
        self.mFunction = inFunction
    end
}