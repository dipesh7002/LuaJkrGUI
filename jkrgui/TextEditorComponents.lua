require "jkrgui.PrimitiveComponents"

Com.TextCursorObject = {
<<<<<<< HEAD
	mWidth = 0,
	mHeight = 0,
	mShapeId = 0,
	mPosition_3f = 0,
	mDimension_3f = 0,
	New = function(self, inPosition_3f, inDimension_3f, inColor_4f)
		local Obj = {}
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
		local Obj = {}
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
	end
}

Com.VisualLineWrapperObject = {
	mStringBuffer = nil,
	mMaxNumLines = nil,
	mVerticalDrawSpacing = nil,
	mVisualLines = nil,
	New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxLines, inMaxChars,
		inVerticalDrawSpacing)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		local linePosition = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
		Obj.mMaxNumLines = inMaxLines
		Obj.mVerticalDrawSpacing = inVerticalDrawSpacing
		Obj.mFontObject = inFontObject
		Obj.mVisualLines = {}
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
		local visualCharsIndex = 1
		local newLinesCount = 0
		local stringBufferLength = utf8.len(self.mStringBuffer)
		for Line in self.mStringBuffer:gmatch("(.-)\n") do
			local len = utf8.len(Line)
			local _newline = newLinesCount + 1
			local _vischars = visualCharsIndex + len
			local probabaleNewLinePos = _newline + _vischars - 1
			local hasNewLine = false
			if probabaleNewLinePos <= stringBufferLength then
				if utf8.sub(self.mStringBuffer, probabaleNewLinePos, probabaleNewLinePos) == "\n" then
					hasNewLine = true
				end
			end
			lineIndex = self:WrapWithin(Line, lineIndex, linePosition, inDimension_3f,
				visualCharsIndex + newLinesCount, hasNewLine)
			newLinesCount = _newline
			visualCharsIndex = _vischars
		end
	end,
	EraseAll = function(self)
		for i = 1, #self.mVisualLines, 1 do
			self.mVisualLines[i]:Update(vec3(0), vec3(0), "")
		end
	end,
	WrapWithin = function(self, inString, inStartingIndex, inLinePosition_3f, inDimension_3f,
		       inVisualLineIndex, inEndsWithNewline)
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
				inLinePosition_3f, inDimension_3f, visualLineIndex + sub.n - 1, inEndsWithNewline)
		else
			if self.mVisualLines[i] then
				self.mVisualLines[i]:Update(inLinePosition_3f, inDimension_3f,
					inString, visualLineIndex, inEndsWithNewline)
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
	mPosition_3f = nil,
	mDimension_3f = nil,
	New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxLines, inMaxChars,
		inVerticalDrawSpacing)
		local Obj = Com.VisualLineWrapperObject:New(inPosition_3f, inDimension_3f, inFontObject,
			inMaxLines, inMaxChars, inVerticalDrawSpacing)
		setmetatable(self, Com.VisualLineWrapperObject)
		setmetatable(Obj, self)
		self.__index = self
		Obj.mCursorPosition = 1
		Obj.mCursor = Com.TextCursorObject:New(vec3(0), vec3(0.5), vec4(1, 0, 0, 1))
		return Obj
	end,
	GetGraphicalCursorPosition = function(self, inVisualCursorPosition)
		local line, char = inVisualCursorPosition.line, inVisualCursorPosition.char
		local str = self.mVisualLines[line].mString
		local dimens = vec2(0, 0)


		if str and char < self.mVisualLines[line].mUtf8Len then
			if self.mVisualLines[line].mEndsWithNewLine then
				local substr = utf8.sub(str, 1, char)
				dimens = self.mFontObject:GetDimension(substr)
			else
				local substr = utf8.sub(str, 1, char - 1)
				dimens = self.mFontObject:GetDimension(substr)
			end
		end

		local isLastLine = self.mVisualLines[line + 1] and self.mVisualLines[line + 1].mUtf8Len == 0 
		--and self.mVisualLines[line + 1].mEndsWithNewLine == false 
		if isLastLine then
			local substr = utf8.sub(str, 1, char)
			dimens = self.mFontObject:GetDimension(substr)
		end

		local depth = self.mCursor.mPosition_3f.z
		return vec3(dimens.x, (line - 1) * self.mVerticalDrawSpacing, depth)
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

		local nextLineExists = visualLines[lineIndex + 1] and visualLines[lineIndex + 1].mUtf8Len ~= 0
		if nextLineExists then
			charIndex = charsTraversedIndex - visualLines[lineIndex].mUtf8Len
			charIndex = inPosition - charIndex
		else
			if inPosition > self:GetVisualExtreme() then
				charIndex = visualLines[lineIndex].mUtf8Len
			else
				charIndex = charsTraversedIndex -
				(visualLines[lineIndex].mUtf8Len)
				charIndex = inPosition - charIndex
			end
		end
		return { line = lineIndex, char = charIndex }
	end,
	GetNearestGraphicalCharacterPosition = function (self, inX, inY)
		-- TODO	
	end,
	GetVisualCursorPosition = function(self)
		return self:GetVisualPosition(self.mCursorPosition)
	end,
	GetLineExtremes = function(self, inVisualLineNo)
		return {
			left = self.mVisualLines[inVisualLineNo].mIndex,
			right = self.mVisualLines[inVisualLineNo].mIndex + self.mVisualLines[inVisualLineNo].mIndex + self.mVisualLines[inVisualLineNo].mUtf8Len 
		}
	end,
	GetVisualExtreme = function(self)
		local chars = 0
		for i = 1, #self.mVisualLines, 1 do
			chars = chars + self.mVisualLines[i].mUtf8Len
		end
		return chars
	end,
	CursorInsert = function(self, inStr)
		local str = self.mStringBuffer
		local lhs = utf8.sub(str, 1, self.mCursorPosition - 1)
		local toInsert = inStr
		local toInsertLen = utf8.len(toInsert)
		local rhs = utf8.sub(str, self.mCursorPosition, utf8.len(str))
		local final = lhs .. toInsert .. rhs
		self.mStringBuffer = final
		self:Update(self.mPosition_3f, self.mDimension_3f)
		for i = 1, toInsertLen, 1 do
			self:CursorMoveRight()
		end
	end,
	CursorRemove = function(self)
		local str = self.mStringBuffer
		if self.mCursorPosition > 1 then
			local lhs = utf8.sub(str, 1, self.mCursorPosition - 2)
			local rhs = utf8.sub(str, self.mCursorPosition,
				utf8.len(str))
			self.mStringBuffer = lhs .. rhs
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
		local isWithinTopLeftMostExtreme = self.mCursorPosition > 1
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
				moveRights = exNextLine.right -
				(exCurrentLine.left + cursorPos.char)
			else
				moveRights = exNextLine.left - exCurrentLine.left
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
				moveLefts = exCurrentLine.left + cursorPos.char -
				exPreviousLine.right
			else
				moveLefts = exCurrentLine.left - exPreviousLine.left
			end
			for i = 1, moveLefts, 1 do
				self:CursorMoveLeft()
			end
		end
	end,
	Update = function(self, inPosition_3f, inDimension_3f, inNewStringBuffer, inNewVerticalDrawSpacing,
		   inCursorWidth)
		Com.VisualLineWrapperObject.Update(self, inPosition_3f, inDimension_3f, inNewStringBuffer, inNewVerticalDrawSpacing)
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
		self.mPosition_3f = inPosition_3f
		self.mDimension_3f = inDimension_3f
	end
}

Com.PlainTextEditObject = {
	New = function (self, inPosition_3f, inDimension_3f, inFontObject, inMaxLines, inMaxChars, inVerticalDrawSpacing)
		local Obj = Com.VisualTextEditObject:New(inPosition_3f, inDimension_3f, inFontObject, inMaxLines, inMaxChars, inVerticalDrawSpacing)
		setmetatable(self, Com.VisualTextEditObject)
		setmetatable(Obj, self)
		self.__index = self
		Com.NewComponent_Event()
		E.stop_text_input()
		ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
			function ()
				local is_backspace = E.is_key_pressed(Key.SDLK_BACKSPACE)
				local is_enter = E.is_key_pressed(Key.SDLK_RETURN)
				local is_up = E.is_key_pressed(Key.SDLK_UP)
				local is_down = E.is_key_pressed(Key.SDLK_DOWN)
				local is_left = E.is_key_pressed(Key.SDLK_LEFT)
				local is_right = E.is_key_pressed(Key.SDLK_RIGHT)
				if E.is_text_being_input() and not is_backspace then
					local input = E.get_input_text()
					Obj:CursorInsert(input)			
					Obj:Update(Obj.mPosition_3f, Obj.mDimension_3f)
				end
				if E.is_keypress_event() then
					if is_left then
						Obj:CursorMoveLeft()
					elseif is_right then
						Obj:CursorMoveRight()
					elseif is_up then
						Obj:CursorMoveUp()
					elseif is_down then
						Obj:CursorMoveDown()
					elseif is_backspace then
						Obj:CursorRemove()
					elseif is_enter then
						Obj:CursorInsert("\n")
					end	
					Obj:Update(Obj.mPosition_3f, Obj.mDimension_3f)
				end
			end
		)
		return Obj
	end 
}
=======
    mWidth = 0,
    mHeight = 0,
    mShapeId = 0,
    New = function(self, inPosition_3f, inDimension_3f, inColor_4f)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Static.ShapeObject:New(inPosition_3f, inDimension_3f, nil,
            nil)
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
        ComTable[com_i] = Jkr.Components.Static.TextObject:New(string.rep(" ", inMaxChars),
            inPosition_3f,
            inFontObject)
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
    New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxNoOfLines, inMaxChars,
                   inVerticalDrawSpacing, inShouldWrap)
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
            Obj.mLineStringBuffers[#Obj.mLineStringBuffers + 1] = Com.TextLineObject
                :New(linePositionY,
                    inDimension_3f,
                    inMaxChars, inFontObject)
            linePositionY.y = linePositionY.y + inVerticalDrawSpacing
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
        linePosition.y = linePosition.y +
            self
            .mVerticalDrawSpacing -- The Text is drawn ABOVE the point, therefore a vertical-draw-spacing is being inserted

        local i = 1
        local linepos = 1
        local j = 1
        for Line in self.mStringBuffer:gmatch("(.-)\n") do
            i = self:WrapWithinDimensions(Line, i, linePosition, inDimension_3f,
                linepos - 1 + j - 1)
            j = j + 1
            linepos = linepos + utf8.len(Line)
        end
    end,
    --[[ Protected Functions, to be used inside another Component ]]
    InsertAt = function(self, inLineNo, inCharacterIndex, inCharacter)
        local str = self.mStringBuffer
        local pos = self.mLineStringBuffers[inLineNo].mPositionInMultiline
        local lhs = utf8.sub(str, 1, pos + inCharacterIndex - 1)
        local toinsert = inCharacter
        local rhs = utf8.sub(str, pos + inCharacterIndex, utf8.len(str))
        local final = lhs .. toinsert .. rhs
        self.mStringBuffer = final
        return pos + inCharacterIndex - 1
    end,
    BackDeleteAt = function(self, inLineNo, inCharacterIndex)
        local str = self.mStringBuffer
        local pos = self.mLineStringBuffers[inLineNo].mPositionInMultiline
        local lhs = utf8.sub(str, 1, pos + inCharacterIndex - 2)
        local rhs = utf8.sub(str, pos + inCharacterIndex, utf8.len(str))
        local final = lhs .. rhs
        self.mStringBuffer = final
        return pos + inCharacterIndex - 2
    end,
    EraseAll = function(self)
        for i = 1, self.mMaxNumLines, 1 do
            self.mLineStringBuffers[i]:Update(vec3(0), vec3(0), " ")
        end
    end,
    GetCharacterPosition = function(self, inPosition_3f, inLineNo, inCharacterIndex)
        local str = ComTable[self.mLineStringBuffers[inLineNo].mTextObjectId].mString
        local substr = " "
        local dimens = vec2(0, 0)
        if str and inCharacterIndex <= utf8.len(str) then
            substr = utf8.sub(str, 1, inCharacterIndex - 1)
            dimens = self.mFontObject:GetDimension(substr)
        end
        return vec3(inPosition_3f.x + dimens.x,
            inPosition_3f.y + (inLineNo - 1) * self.mVerticalDrawSpacing,
            inPosition_3f.z)
    end,
    GetCharacterIndex = function(self, inAbsoluteCharIndex)
        local lineIndex = 1
        local traversedChars = 0
        local len = 0
        while traversedChars <= inAbsoluteCharIndex do
            local str = ComTable
                [self.mLineStringBuffers[lineIndex].mTextObjectId].mString
            len = utf8.len(str)
            if len >= inAbsoluteCharIndex and lineIndex == 1 then
                return { line = lineIndex, charIndex = inAbsoluteCharIndex }
            end
            traversedChars = traversedChars + len
            lineIndex = lineIndex + 1
        end
        local charIndex = inAbsoluteCharIndex - (traversedChars - len)
        lineIndex = lineIndex - 1
        return { line = lineIndex, charIndex = charIndex }
    end,
    GetCharacterAbsoluteIndex = function(self, inLineNo, inCharacterIndex)
        local lineNo = 1
        local traversedChars = 0
        while lineNo < inLineNo do
            local str = ComTable
                [self.mLineStringBuffers[lineNo].mTextObjectId].mString
            local len = utf8.len(str)
            traversedChars = traversedChars + len
            lineNo = lineNo + 1
        end
        return traversedChars + inCharacterIndex
    end,
    WrapWithinDimensions = function(self, inString, inStartingIndex, inLinePosition_3f, inDimension_3f,
                                    inLinePosInMultiline)
        local i = inStartingIndex
        local dimens = self.mFontObject:GetDimension(inString)
        local lineposmultiline = inLinePosInMultiline
        if dimens.x > inDimension_3f.x then
            local sub = self.mFontObject:GetSubstringWithinDimension(inString,
                inDimension_3f.x)
            self.mLineStringBuffers[i]:Update(inLinePosition_3f, inDimension_3f, sub.s,
                lineposmultiline)
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            i = self:WrapWithinDimensions(utf8.sub(inString, sub.n, utf8.len(inString)),
                i + 1,
                inLinePosition_3f,
                inDimension_3f, inLinePosInMultiline + sub.n - 1)
        else
            self.mLineStringBuffers[i]:Update(inLinePosition_3f, inDimension_3f,
                inString,
                lineposmultiline)
            inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
            i = i + 1
        end
        return i
    end,
}

Com.TextMultiLineEditObject = {
    mTextMultiLineObject = nil,
    mCursor = nil,
    mCursorPosAbsolute = nil,
    mCursorPos_2u = nil,
    mCursorWidth = nil,
    mPosition_3f = nil,
    mDimension_3f = nil,
    New = function(self, inPosition_3f, inDimension_3f, inFontObject, inMaxNoOfLines, inMaxChars,
                   inVerticalDrawSpacing, inShouldWrap, inCursorWidth)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mTextMultiLineObject = Com.TextMultiLineObject:New(inPosition_3f, inDimension_3f,
            inFontObject,
            inMaxNoOfLines, inMaxChars, inVerticalDrawSpacing, inShouldWrap)
        Obj.mCursor = Com.TextCursorObject:New(inPosition_3f, vec3(0, 0, 1), vec4(1, 0, 0, 1))
        Obj.mPosition_3f = inPosition_3f
        if inCursorWidth then
            Obj.mCursorWidth = inCursorWidth
        else
            Obj.mCursorWidth = 5
        end

        Obj:PutCursorAt(1, 1)
        return Obj
    end,
    Insert = function(self, inCharacter)
        local charIndexInMainBuffer = self.mTextMultiLineObject:InsertAt(self.mCursorPos_2u.x,
            self.mCursorPos_2u.y, inCharacter)
        return charIndexInMainBuffer + utf8.len(inCharacter) + 1
    end,
    BackDelete = function(self)
        return self.mTextMultiLineObject:BackDeleteAt(self.mCursorPos_2u.x, self.mCursorPos_2u.y)
    end,
    PutCursorAt = function(self, inLine, inCharacterIndex)
        self.mCursorPos_2u = uvec2(inLine, inCharacterIndex)
        local absindex = self.mTextMultiLineObject:GetCharacterAbsoluteIndex(inLine, inCharacterIndex)
        self.mCursorPosAbsolute = absindex
    end,
    PutCursorAtAbsolute = function(self, inCharacterIndex)
        self.mCursorPosAbsolute = inCharacterIndex
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inText)
        self.mTextMultiLineObject:Update(inPosition_3f, inDimension_3f, inText)
        local pos = self.mTextMultiLineObject:GetCharacterIndex(self.mCursorPosAbsolute)
        self.mCursorPos_2u = uvec2(pos.line, pos.charIndex)
        self:SetCursor(inPosition_3f, self.mCursorPos_2u.x, self.mCursorPos_2u.y, self.mCursorWidth)
        self.mPosition_3f = inPosition_3f
    end,
    CursorMoveLeft = function(self)

    end,
    CursorMoveRight = function(self)

    end,
    CursorMoveUp = function(self)

    end,
    CursorMoveDown = function(self)

    end,
    --[[ Private Functions, Not to be used from outside ]]
    SetCursor = function(self, inPosition_3f, inLine, inCharacterIndex, inCursorWidth)
        local pos = self.mTextMultiLineObject:GetCharacterPosition(inPosition_3f, inLine,
            inCharacterIndex)
        self.mCursorPos_2u = uvec2(inLine, inCharacterIndex)
        self.mCursor:Update(pos,
            vec3(inCursorWidth, self.mTextMultiLineObject.mVerticalDrawSpacing, 1))
    end
}

>>>>>>> b7c6ba2b8967060f1cdbcb742b58172bdc9f3916
