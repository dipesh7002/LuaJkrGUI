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
    mPositionInMultiline = nil,
    New = function(self, inPosition_3f, inDimension_3f, inMaxChars, inFontObject)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.TextObject:New(string.rep(" ", inMaxChars), inPosition_3f, inFontObject)
        Obj.mTextObjectId = com_i
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inString, inPositionInMultiline)
        ComTable[self.mTextObjectId]:Update(inPosition_3f, inDimension_3f, inString)
        self.mPositionInMultiline = inPositionInMultiline
    end
}

Com.TextMultiLineObject = {
    mStringBuffer = " ",
    mLineStringBuffers = nil,
    mMaxNumLines = nil,
    mVerticalDrawSpacing = nil,
    mFontObject = nil,
    mShouldWrap = false,
    New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxNoOfLines, inMaxChars, inVerticalDrawSpacing, inShouldWrap)
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
    InsertAt = function (self, inPosition_3f, inDimension_3f, inLineNo, inCharacterIndex, inCharacter)
        local str = self.mStringBuffer
        local pos = self.mLineStringBuffers[inLineNo].mPositionInMultiline
        --local newstr = 
        --utf8.sub(str, )
    end,
    BackDeleteAt = function (self, inPosition_3f, inDimension_3f, inLineNo, inCharacterIndex)
        
    end,
    EraseAll = function(self)
        for i = 1, self.mMaxNumLines, 1 do
            self.mLineStringBuffers[i]:Update(vec3(0), vec3(0), " ")
        end
    end,
    GetCharacterPosition = function (self, inPosition_3f, inLineNo, inCharacterIndex)
        local str = ComTable[self.mLineStringBuffers[inLineNo].mTextObjectId].mString
        local substr = " "
        if str then
            substr = utf8.sub(str, 1, inCharacterIndex)
        end
        local dimens = self.mFontObject:GetDimension(substr)
        return vec3(inPosition_3f.x + dimens.x, inPosition_3f.y + (inLineNo - 1) * self.mVerticalDrawSpacing, inPosition_3f.z)
    end,
    WrapWithinDimensions = function(self, inString, inStartingIndex, inLinePosition_3f, inDimension_3f, inLinePosInMultiline)
        local i = inStartingIndex
        local dimens = self.mFontObject:GetDimension(inString)
        if dimens.x > inDimension_3f.x then
            local sub = self.mFontObject:GetSubstringWithinDimension(inString, inDimension_3f.x)
            self.mLineStringBuffers[i]:Update(inLinePosition_3f, inDimension_3f, sub.s, inLinePosInMultiline + sub.n)
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            self:WrapWithinDimensions(utf8.sub(inString, sub.n, utf8.len(inString)), i + 1, inLinePosition_3f,
                inDimension_3f, inLinePosInMultiline + sub.n)
        else
            self.mLineStringBuffers[i]:Update(inLinePosition_3f, inDimension_3f, inString, inLinePosInMultiline)
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
        local linepos = 1
        for Line in self.mStringBuffer:gmatch("(.-)\n") do
            i = self:WrapWithinDimensions(Line, i, linePosition, inDimension_3f, linepos)
            linepos = linepos + utf8.len(Line)
        end
    end
}

-- could've inherited
Com.TextMultiLineEditObject = {
    mTextMultiLineObject = nil,
    mCursor = nil,
    mCursorPos_2u = nil,
    mCursorWidth = nil,
    New = function ( self, inPosition_3f, inDimension_3f, inFontObject, inMaxNoOfLines, inMaxChars, inVerticalDrawSpacing, inShouldWrap, inCursorWidth)
        local Obj = {} 
        setmetatable(Obj, self)
        self.__index = self

        Obj.mTextMultiLineObject = Com.TextMultiLineObject:New(inPosition_3f, inDimension_3f, inFontObject, inMaxNoOfLines, inMaxChars, inVerticalDrawSpacing, inShouldWrap)
        Obj.mCursor = Com.TextCursorObject:New(inPosition_3f, vec3(0, 0, 1), vec4(1, 0, 0, 1))
        if inCursorWidth then
            Obj.mCursorWidth = inCursorWidth
        else
            Obj.mCursorWidth = 5
        end

        Obj:PutCursorAt(1, 1)
        return Obj
    end,
    Insert = function (self, inCharacter)
    end,
    Delete = function (self)
        
    end,
    SetCursor = function(self, inPosition_3f, inLine, inCharacterIndex, inCursorWidth)
        local pos = self.mTextMultiLineObject:GetCharacterPosition(inPosition_3f, inLine, inCharacterIndex)
        self.mCursorPos_2u = uvec2(inLine, inCharacterIndex)
        self.mCursor:Update(pos, vec3(inCursorWidth, self.mTextMultiLineObject.mVerticalDrawSpacing, 1))
    end,
    PutCursorAt = function (self, inLine, inCharacterIndex)
        self.mCursorPos_2u = uvec2(inLine, inCharacterIndex) 
    end,
    Update = function (self, inPosition_3f, inDimension_3f, inText)
        self.mTextMultiLineObject:Update(inPosition_3f, inDimension_3f, inText)
        self:SetCursor(inPosition_3f, self.mCursorPos_2u.x, self.mCursorPos_2u.y, self.mCursorWidth)
    end
}
