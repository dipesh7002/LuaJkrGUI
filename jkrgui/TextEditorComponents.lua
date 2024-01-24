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

Com.VisualLineObject = {
	mTextObjectId = nil,
	mIndex = nil,
	mEndsWithNewLine = nil,
	mVisualDimension_2f = nil,
	mFontObject = nil,
	mUtf8Len = nil,
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
		if inEndsWithNewLine then
			self.mUtf8Size = utf8.len(inString) + 1
		else
			self.mUtf8Size = utf8.len(inString)
		end
	end
}

Com.VisualWrapLinesObject = {
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
	Update = function (self, inPosition_3f, inDimension_3f, inNewStringBuffer, inNewVerticalDrawSpacing)
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
			lineIndex = self:WrapWithin(Line, lineIndex, linePosition, inDimension_3f, visualCharsCount + newLinesCount)
			newLinesCount = newLinesCount + 1
			visualCharsCount = visualCharsCount + utf8.len(Line)
		end
	end,
	EraseAll = function (self)
		for i = 1, self.mMaxNumLines, 1 do
			self.mVisualLines[i]:Update(vec3(0), vec3(0), " ")
		end	
	end,
	WrapWithin = function (self, inString, inStartingIndex, inLinePosition_3f, inDimension_3f, inVisualLineIndex)
		local i = inStartingIndex	
		local dimens = self.mFontObject:GetDimension(inString)
		local visualLineIndex = inVisualLineIndex
		if dimens.x > inDimension_3f.x then
			local sub = self.mFontObject:GetSubstringWithinDimension(inString, inDimension_3f.x)
			if self.mVisualLines[i] then
				self.mVisualLines[i]:Update(inLinePosition_3f, inDimension_3f, sub.s, visualLineIndex, false)	
			end 
			inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
			i = self:WrapWithin(utf8.sub(inString, sub.n, utf8.len(inString)), i + 1, inLinePosition_3f, inDimension_3f, visualLineIndex + sub.n)
		else
			if self.mVisualLines[i] then
				self.mVisualLines[i]:Update(inLinePosition_3f, inDimension_3f, inString, visualLineIndex, true)
			end
			inLinePosition_3f.y = inLinePosition_3f.y + self.mVerticalDrawSpacing
			i = i + 1
		end
		return i
	end
}
