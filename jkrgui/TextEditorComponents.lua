require "jkrgui.PrimitiveComponents"

Com.TextCursorObject = {
    mWidth = 0,
    mHeight = 0,
    mShapeId = 0,
    New = function(self, inPosition_3f, inDimension_3f, inColor_4f)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(inPosition_3f, inDimension_3f, nil, nil)
        ComTable[com_i].mFillColor = inColor_4f
        Obj.mWidth = inDimension_3f.x
        Obj.mShapeId = com_i
        Obj.mHeight = inDimension_3f.y
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        ComTable[self.mShapeId]:Update(inPosition_3f, inDimension_3f)
    end
}

Com.TextLineObject = {
    mTextObjectId = nil,
    New = function(self, inPosition_3f, inDimension_3f, inMaxChars, inFontObject)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.TextObject:New(string.rep(" ", inMaxChars), inPosition_3f, inFontObject)
        Obj.mTextObjectId = com_i
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inString)
        ComTable[self.mTextObjectId]:Update(inPosition_3f, inDimension_3f, inString)
    end
}

Com.TextMultiLineObject = {
    mStringBuffer = " ",
    mLineStringBuffers = nil,
    mMaxNumLines = nil,
    mVerticalDrawSpacing = nil,
    mFontObject = nil,
    mShouldWrap = false,
    New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxNoOfLines, inMaxChars, inVerticalDrawSpacing,
                   inShouldWrap)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mLineStringBuffers = {}
        local linePositionY = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        Obj.mMaxNumLines = inMaxNoOfLines
        Obj.mVerticalDrawSpacing = inVerticalDrawSpacing
        Obj.mFontObject = inFontObject
        if inShouldWrap then
            Obj.mShouldWrap = inShouldWrap
        else
            Obj.mShouldWrap = false
        end
        for i = 1, inMaxNoOfLines, 1 do
            Obj.mLineStringBuffers[#Obj.mLineStringBuffers + 1] = Com.TextLineObject:New(linePositionY, inDimension_3f,
                inMaxChars, inFontObject)
            linePositionY.y = linePositionY.y + inVerticalDrawSpacing
        end
        return Obj
    end,
    EraseAll = function(self)
        for i = 1, self.mMaxNumLines, 1 do
            self.mLineStringBuffers[i]:Update(vec3(0), vec3(0), " ")
        end
    end,
    WrapWithinDimensions = function(self, inString, inStartingIndex, inLinePosition_3f, inDimension_3f)
        local i = inStartingIndex
        local dimens = self.mFontObject:GetDimension(inString)
        if dimens.x > inDimension_3f.x then
            local sub = self.mFontObject:GetSubstringWithinDimension(inString, inDimension_3f.x)
            self.mLineStringBuffers[i]:Update(inLinePosition_3f, inDimension_3f, sub.s)
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            self:WrapWithinDimensions(utf8.sub(inString, sub.n, utf8.len(inString)), i + 1, inLinePosition_3f,
                inDimension_3f)
        else
            self.mLineStringBuffers[i]:Update(inLinePosition_3f, inDimension_3f, inString)
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            i = i + 1
        end
        return i
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inNewStringBuffer, inNewVerticalDrawSpacing)
        if inNewStringBuffer then
            self.mStringBuffer = inNewStringBuffer
        end

        if inNewVerticalDrawSpacing then
            self.mVerticalDrawSpacing = inNewVerticalDrawSpacing
        end

        self:EraseAll()
        local linePosition = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        linePosition.y = linePosition.y + self.mVerticalDrawSpacing -- The Text is drawn ABOVE the point, therefore a vertical-draw-spacing is being inserted

        local i = 1
        for Line in self.mStringBuffer:gmatch("(.-)\n") do
            i = self:WrapWithinDimensions(Line, i, linePosition, inDimension_3f)
        end
    end
}
