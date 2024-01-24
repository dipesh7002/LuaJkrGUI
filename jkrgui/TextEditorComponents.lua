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
		return pos +inCharacterIndex - 2
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
				return {line = lineIndex, charIndex = inAbsoluteCharIndex}
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
	CursorMoveLeft = function (self)
		
	end,
	CursorMoveRight = function (self)
		
	end,
	CursorMoveUp = function (self)
		
	end,
	CursorMoveDown = function (self)
		
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
