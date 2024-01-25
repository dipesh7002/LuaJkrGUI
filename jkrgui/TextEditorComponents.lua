require "jkrgui.PrimitiveComponents"

Com.TextCursorObject = {
    mWidth = 0,
    mHeight = 0,
    mShapeId = 0,
    mPosition_3f = 0,
    mDimension_3f = 0,
    New = function(self, inPosition_3f, inDimension_3f, inColor_4f)
        local Obj = { }
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(inPosition_3f, inDimension_3f, nil,
        nil)
        ComTable[com_i].mFillColor = inColor_4f
        Obj.mWidth = inDimension_3f.x
        Obj.mShapeId = com_i
        Obj.mHeight = inDimension_3f.y
        Obj.mPosition_3f = inPosition_3f
        Obj.mDimension_3f = inDimension_3f
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        ComTable[self.mShapeId]:Update(inPosition_3f, inDimension_3f)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
    end
}

Com.VisualLineObject = {
    mTextObjectId = nil,
    mIndex = nil,
    mEndsWithNewLine = nil,
    mVisualDimension_2f = nil,
    mFontObject = nil,
    mUtf8Len = nil,
    mString = nil,
    New = function(self, inPosition_3f, inDimension_3f, inMaxChars, inFontObject)
        local Obj = { }
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.TextObject:New(string.rep(" ", inMaxChars),
        inPosition_3f,
        inFontObject)
        Obj.mTextObjectId = com_i
        Obj.mEndsWithNewLine = false
        Obj.mFontObject = inFontObject
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inString, inIndex, inEndsWithNewLine)
        ComTable[self.mTextObjectId]:Update(inPosition_3f, inDimension_3f, inString)
        self.mIndex = inIndex
        self.mEndsWithNewLine = inEndsWithNewLine
        self.mVisualDimension_2f = self.mFontObject:GetDimension(inString)
        self.mString = inString
        if inEndsWithNewLine then
            self.mUtf8Len = utf8.len(inString) + 1
        else
            self.mUtf8Len = utf8.len(inString)
        end
        print("UTF8LEN:", self.mUtf8Len)
    end
}

Com.VisualLineWrapperObject = {
    mStringBuffer = nil,
    mMaxNumLines = nil,
    mVerticalDrawSpacing = nil,
    mVisualLines = nil,
    New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxLines, inMaxChars,
            inVerticalDrawSpacing)
        local Obj = { }
        setmetatable(Obj, self)
        self.__index = self
        local linePosition = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        Obj.mMaxNumLines = inMaxLines
        Obj.mVerticalDrawSpacing = inVerticalDrawSpacing
        Obj.mFontObject = inFontObject
        Obj.mVisualLines = { }
        for i = 1, inMaxLines, 1 do
            Obj.mVisualLines[#Obj.mVisualLines + 1] = Com.VisualLineObject
            :New(linePosition, inDimension_3f, inMaxChars, inFontObject)
            linePosition.y = linePosition.y + inVerticalDrawSpacing
        end
        return Obj
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
        linePosition.y = linePosition.y + self.mVerticalDrawSpacing

        local lineIndex = 1
        local visualCharsCount = 0
        local newLinesCount = 0
        for Line in self.mStringBuffer:gmatch("(.-)\n") do
            lineIndex = self:WrapWithin(Line, lineIndex, linePosition, inDimension_3f,
            visualCharsCount + newLinesCount)
            newLinesCount = newLinesCount + 1
            visualCharsCount = visualCharsCount + utf8.len(Line)
        end
    end,
    EraseAll = function(self)
        for i = 1, #self.mVisualLines, 1 do
            self.mVisualLines[i]:Update(vec3(0), vec3(0), "")
        end
    end,
    WrapWithin = function(self, inString, inStartingIndex, inLinePosition_3f, inDimension_3f,
            inVisualLineIndex)
        local i = inStartingIndex
        local dimens = self.mFontObject:GetDimension(inString)
        local visualLineIndex = inVisualLineIndex
        if dimens.x > inDimension_3f.x then
            local sub = self.mFontObject:GetSubstringWithinDimension(inString,
            inDimension_3f.x)
            if self.mVisualLines[i] then
                self.mVisualLines[i]:Update(inLinePosition_3f, inDimension_3f,
                sub.s, visualLineIndex, false)
            end
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            i = self:WrapWithin(utf8.sub(inString, sub.n, utf8.len(inString)), i + 1,
            inLinePosition_3f, inDimension_3f, visualLineIndex + sub.n)
        else
            if self.mVisualLines[i] then
                self.mVisualLines[i]:Update(inLinePosition_3f, inDimension_3f,
                inString, visualLineIndex, true)
            end
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            i = i + 1
        end
        return i
    end
}

Com.VisualTextEditObject = {
    mCursor = nil,
    mCursorPosition = nil,
    -- this refers to position of the cursor with respect to the StringBuffer
    mCharOffset = nil,
    mLargeString = nil,
    New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxLines, inMaxChars,
            inVerticalDrawSpacing)
        local Obj = Com.VisualLineWrapperObject:New(inPosition_3f, inDimension_3f, inFontObject,
        inMaxLines, inMaxChars, inVerticalDrawSpacing)
        setmetatable(self, Com.VisualLineWrapperObject)
        setmetatable(Obj, self)
        self.__index = self
        Obj.mCursorPosition = 1
        Obj.mCharOffset = 0
        Obj.mLargeString = ""
        Obj.mCursor = Com.TextCursorObject:New(vec3(0), vec3(0.5), vec4(1, 0, 0, 1))
        return Obj
    end,
    GetGraphicalCursorPosition = function(self, inVisualCursorPosition)
        local line, char = inVisualCursorPosition.line, inVisualCursorPosition.char
        local str = self.mVisualLines[line].mString
        local dimens = vec2(0, 0)
        if str and char < self.mVisualLines[line].mUtf8Len then
            local substr = utf8.sub(str, 1, char)
            dimens = self.mFontObject:GetDimension(substr)
        end
        local depth = self.mCursor.mPosition_3f.z
        return vec3(dimens.x,(line - 1) * self.mVerticalDrawSpacing, depth)
    end,
    GetVisualPosition = function(self, inPosition)
        local visualLines = self.mVisualLines
        local lineIndex = 1
        local charsTraversedIndex = 1
        while inPosition >= charsTraversedIndex do
            charsTraversedIndex = charsTraversedIndex + visualLines[lineIndex].mUtf8Len
            lineIndex = lineIndex + 1
            if not visualLines[lineIndex] or visualLines[lineIndex].mUtf8Len == 0 then
                break
            end
        end
        local charIndex = 1

        if lineIndex ~= 1 then
            lineIndex = lineIndex - 1
        end

        if visualLines[lineIndex + 1] and visualLines[lineIndex + 1].mUtf8Len ~= 0 then
            -- If nextline is present is not empty
            charIndex = charsTraversedIndex - visualLines[lineIndex].mUtf8Len
            charIndex = inPosition - charIndex
        else
            if inPosition >= self:GetVisualExtreme() then
                charIndex = visualLines[lineIndex].mUtf8Len
            else
                charIndex = charsTraversedIndex - visualLines[lineIndex].mUtf8Len
                charIndex = inPosition - charIndex
            end

        end
        return { line = lineIndex, char = charIndex }

    end,
    GetVisualCursorPosition = function(self)
        return self:GetVisualPosition(self.mCursorPosition)
    end,
    GetLineExtremes = function(self, inVisualLineNo)
 	local left = self.mVisualLines[inVisualLineNo].mIndex
	local right = self.mVisualLines[inVisualLineNo].mIndex + self.mVisualLines[inVisualLineNo].mUtf8Len
	if self.mVisualLines[inVisualLineNo - 1] then
		if self.mVisualLines[inVisualLineNo - 1].mEndsWithNewLine then
			left = left + 2
		end
	end
        return {left = left, right = right }
    end,
    GetVisualExtreme = function(self)
        local chars = 0
        for i = 1, #self.mVisualLines, 1 do
            chars = chars + self.mVisualLines[i].mUtf8Len
        end
        return chars
    end,
    CursorInsert = function(self, inStr)
        local str = self.mLargeString
        local lhs = utf8.sub(str, 1, self.mCursorPosition + self.mCharOffset - 1)
        local toInsert = inStr
        local toInsertLen = utf8.len(toInsert)
        local rhs = utf8.sub(str, self.mCursorPosition + self.mCharOffset, utf8.len(str))
        local final = lhs .. toInsert .. rhs
        self.mLargeString = final

        for i = 1, toInsertLen, 1 do
            self:CursorMoveRight()
        end
    end,
    CursorRemove = function(self)
        local str = self.mLargeString
        if self.mCursorPosition > 1 then
            local lhs = utf8.sub(str, 1, self.mCursorPosition + self.mCharOffset - 2)
            local rhs = utf8.sub(str, self.mCursorPosition + self.mCharOffset, utf8.len(str))
            self.mLargeString = lhs .. rhs
        end
        self:CursorMoveLeft()
    end,
    CursorMoveRight = function(self)
        local isWithinRightBottomMostExtreme = self.mCursorPosition <= self:GetVisualExtreme()
        if isWithinRightBottomMostExtreme then
            self.mCursorPosition = self.mCursorPosition + 1
        end
    end,
    CursorMoveLeft = function(self)
        local isWithinTopLeftMostExtreme = self.mCursorPosition >= 1
        if isWithinTopLeftMostExtreme then
            self.mCursorPosition = self.mCursorPosition - 1
        end
    end,
    CursorMoveDown = function(self)
        local cursorPos = self:GetVisualCursorPosition()
        local extremePos = self:GetVisualPosition(self:GetVisualExtreme())
        if cursorPos.line < extremePos.line then
            local exCurrentLine = self:GetLineExtremes(cursorPos.line)
            local exNextLine = self:GetLineExtremes(cursorPos.line + 1)
            local lineSpanOfNextLine = exNextLine.right - exNextLine.left
            local moveRights = 0
            if cursorPos.char > lineSpanOfNextLine then
                moveRights = exNextLine.right -(exCurrentLine.left + cursorPos.char)
            else
                moveRights = exNextLine.left - exCurrentLine.left - 1
            end
            for i = 1, moveRights, 1 do
                self:CursorMoveRight()
            end
        end
    end,
    CursorMoveUp = function(self)
        local cursorPos = self:GetVisualCursorPosition()
        if cursorPos.line > 1 then
            local exCurrentLine = self:GetLineExtremes(cursorPos.line)
            local exPreviousLine = self:GetLineExtremes(cursorPos.line - 1)
            local lineSpanOfPreviousLine = exPreviousLine.right - exPreviousLine.left
            local moveLefts = 0
            if cursorPos.char > lineSpanOfPreviousLine then
                moveLefts = exCurrentLine.left + cursorPos.char - exPreviousLine.right
            else
                moveLefts = exCurrentLine.left - exPreviousLine.left - 1
            end
            for i = 1, moveLefts, 1 do
                self:CursorMoveLeft()
            end
        end
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inNewStringBuffer, inNewVerticalDrawSpacing, inCursorWidth)
        if inNewStringBuffer then
            self.mLargeString = inNewStringBuffer
        end
        local visualStringBuffer = utf8.sub(self.mLargeString, self.mCharOffset + 1, utf8.len(self.mLargeString))
        Com.VisualLineWrapperObject.Update(self, inPosition_3f, inDimension_3f, visualStringBuffer,
        inNewVerticalDrawSpacing)
        local vis = self:GetVisualCursorPosition()
        local cursorPos = self:GetGraphicalCursorPosition(vis)
        cursorPos.x = cursorPos.x + inPosition_3f.x
        cursorPos.y = cursorPos.y + inPosition_3f.y
        cursorPos.z = inPosition_3f.z
        if inCursorWidth then
            self.mCursor.mWidth = inCursorWidth
        end
        local cursorDimen = vec3(self.mCursor.mWidth, self.mVerticalDrawSpacing, 1)
        self.mCursor:Update(cursorPos, cursorDimen)
    end
}
