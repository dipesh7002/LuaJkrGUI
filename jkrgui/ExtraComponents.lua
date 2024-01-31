require "jkrgui.PrimitiveComponents"

Com.NumberSliderObject = {
	mPositionToParent_3f = vec3(0, 0, 0),
	mPosition = vec3(0, 0, 0),
	mRodId = 0,
	mKnobId = 0,
	mValueRange = vec2(0, 0),
	mDimension_3f = vec3(0, 0, 0),
	mFactor = 0.0,
	mShouldSlide = false,
	New = function(self, inValue, inValueRangle_2f, inPosition_3f, inDimension_3f)
		-- "NumberSliderObject Construction")
		local Obj = {
			mRodId = 0,
			mKnobId = 0,
			mValueRange = inValueRangle_2f,
			mPosition_3f = inPosition_3f,
			mDimension_3f = inDimension_3f,
			mPositionToParent_3f = inPosition_3f,
			mFactor = 0.0
		}
		setmetatable(Obj, self)
		self.__index = self
		local p = inPosition_3f
		local d = inDimension_3f
		local RodHeight = 10
		local RodPosition = vec3(p.x, p.y + d.y / 2 - RodHeight / 2, p.z)
		local RodDimension = vec3(d.x, RodHeight, 1)

		local Factor = inValue / (Obj.mValueRange.y - Obj.mValueRange.x)
		local KnobWidth = 20
		local KnobPosition = vec3(p.x + d.x * Factor - KnobWidth / 2, p.y, p.z - 3)
		local KnobDimension = vec3(KnobWidth, d.y, d.z)
		Obj.mFactor = Factor
		Obj.mShouldSlide = false
		-- string.format(
		Obj.mRodId = Com.AreaObject:New(RodPosition, RodDimension)
		Obj.mKnobId = Com.AreaObject:New(RodPosition, RodDimension)
		-- "NumberSLiderObject Construction Finished")
		return Obj
	end,
	Event = function(self)
		self.mKnobId:Event()
		local RelativeMousePos = E.get_relative_mouse_pos()

		local p = self.mKnobId.mPosition_3f
		local d = self.mKnobId.mDimension_3f
		local up = vec3(p.x, p.y, p.z)
		local Factor = (p.x - d.x) / self.mDimension_3f.x

		if ComTable[self.mKnobId.mAreaId].mComponentObject.mFocus_b or ComTable[self.mRodId.mAreaId].mComponentObject.mFocus_b then
			self.mShouldSlide = true
		end

		if self.mShouldSlide then
			up = vec3(p.x + RelativeMousePos.x, p.y, p.z)
			self.mKnobId:Update(up, d)
			if not E.is_left_button_pressed() then
				self.mShouldSlide = false
			end
		end

		local rodx = self.mRodId.mPosition_3f.x
		local rodw = self.mRodId.mDimension_3f.x
		if up.x < rodx then
			up = vec3(rodx, p.y, p.z)
			self.mKnobId:Update(up, d)
		elseif up.x > rodx + rodw - d.x then
			up = vec3(rodx + rodw - d.x, p.y, p.z)
			self.mKnobId:Update(up, d)
		else
		end

		self.mFactor = Factor
	end,
	SetParent = function(self, inObject)
		local pos = vec3(inObject.mPosition_3f.x + self.mPositionToParent_3f.x,
			inObject.mPosition_3f.y + self.mPositionToParent_3f.y, self.mPosition_3f.z)
		local p = pos
		local d = self.mDimension_3f
		local RodHeight = 10
		local RodPosition = vec3(p.x, p.y + d.y / 2 - RodHeight / 2, p.z)
		local RodDimension = vec3(d.x, RodHeight, d.z)

		local Factor = self.mFactor
		local KnobWidth = 20
		local KnobPosition = vec3(p.x + d.x * Factor - KnobWidth / 2, p.y, p.z)
		local KnobDimension = vec3(KnobWidth, d.y, d.z)

		self.mRodId:Update(RodPosition, RodDimension)
		self.mKnobId:Update(KnobPosition, KnobDimension)

		-- if inObject.mPosition_3f.x > 0 and inObject.mPosition_3f.y > 0 then
		--     ComTable[self.mRodId].mScissorPosition_2f = vec2(inObject.mPosition_3f.x, inObject.mPosition_3f.y)
		--     ComTable[self.mRodId].mScissorDimension_2f = vec2(inObject.mDimension_3f.x, inObject.mDimension_3f.y)
		-- end
		-- TODO
	end
}

Com.ListSelectorObject = {
	mPositionToParent_3f = nil,
	mPosition_3f = nil,
	mDimension_3f = nil,
	mLeftbutton = nil,
	mRightButton = nil,
	mTextArea = nil,
	mList = nil,
	mMaxChars = nil,
	mCurrentSelection = 1,
	mButtonWidth = 0,
	New = function(self, inList, inPosition_3f, inDimension_3f, inButtonWidth, inFontObject, inMaxChars,
		inParent)
		-- "List Selector Construction")
		local p = inPosition_3f
		local d = inDimension_3f
		local lb_p = vec3(p.x, p.y, p.z)
		local lb_d = vec3(inButtonWidth, d.y, d.z)
		local txt_p = vec3(p.x + lb_d.x, p.y, p.z)
		local txt_d = vec3(d.x - 2 * inButtonWidth, d.y, d.z)
		local rb_p = vec3(p.x + txt_d.x + inButtonWidth, p.y, p.z)
		local rb_d = vec3(inButtonWidth, d.y, d.z)
		-- inList[1])
		local Obj = {}
		Obj.mList = inList
		Obj.mCurrentSelection = 1
		Obj.mLeftbutton = Com.TextButtonObject:New(" <", inFontObject, lb_p, lb_d, inParent)
		Obj.mRightButton = Com.TextButtonObject:New(" >", inFontObject, rb_p, rb_d, inParent)
		Obj.mTextArea = Com.TextButtonObject:New(string.rep(" ", inMaxChars), inFontObject, txt_p,
			txt_d, inParent)
		Obj.mTextArea:Update(txt_p, txt_d, Obj.mList[Obj.mCurrentSelection])
		Obj.mPosition_3f = inPosition_3f
		Obj.mDimension_3f = inDimension_3f
		Obj.mPositionToParent_3f = inPosition_3f
		Obj.mButtonWidth = inButtonWidth
		Obj.mMaxChars = inMaxChars


		setmetatable(Obj, self)
		self.__index = self
		-- "List Selector Construction Finished")
		return Obj
	end,
	Event = function(self)
		self.mLeftbutton:Event()
		self.mRightButton:Event()
		local p = self.mPosition_3f
		local d = self.mDimension_3f
		local lb_p = vec3(p.x, p.y, p.z)
		local lb_d = vec3(self.mButtonWidth, d.y, d.z)
		local txt_p = vec3(p.x + lb_d.x, p.y, p.z)
		local txt_d = vec3(d.x - 2 * self.mButtonWidth, d.y, d.z)
		local rb_p = vec3(p.x + txt_d.x + self.mButtonWidth, p.y, p.z)
		local rb_d = vec3(self.mButtonWidth, d.y, d.z)
		if self.mLeftbutton.mPressed then
			if self.mCurrentSelection > 1 then
				self.mCurrentSelection = self.mCurrentSelection - 1
			end
			self.mTextArea:Update(txt_p, txt_d, string.rep(" ", self.mMaxChars))
			self.mTextArea:Update(txt_p, txt_d, self.mList[self.mCurrentSelection])
		elseif self.mRightButton.mPressed then
			if self.mCurrentSelection < #self.mList then
				self.mCurrentSelection = self.mCurrentSelection + 1
			end
			self.mTextArea:Update(txt_p, txt_d, string.rep(" ", self.mMaxChars))
			self.mTextArea:Update(txt_p, txt_d, self.mList[self.mCurrentSelection])
			-- "Pressed")
		end
	end,
	SetParent = function(self, inObject)
		Com.TextButtonObject.SetParent(self.mLeftbutton, inObject)
		Com.TextButtonObject.SetParent(self.mRightButton, inObject)
		Com.TextButtonObject.SetParent(self.mTextArea, inObject)
	end
}


Com.Canvas = {
	mPainterBrushes = nil,
	mPainterImage = nil,
	mImageLabel = nil,
	mImage = nil,
	mPosition_3f = nil, 
	mDimension_3f = nil,
	CurrentBrushId = nil,
	New = function (self, inPosition_3f, inDimension_3f)
		local Obj = {}	
		setmetatable(Obj, self)
		self.__index = self
		Obj.mPosition_3f = inPosition_3f
		Obj.mDimension_3f = inDimension_3f

		Obj.mPainterBrushes = {}
		Obj.CurrentBrushId = 1
		return Obj
	end,
	AddPainterBrush = function (self, inBrush)
		local ret = #self.mPainterBrushes + 1
		self.mPainterBrushes[#self.mPainterBrushes+1] = inBrush
		return ret
	end,
	MakeCanvasImage = function (self, inWidth, inHeight)
		self.mPainterImage = Jkr.Components.Abstract.PainterImageObject:New(inWidth, inHeight)
		self.mPainterBrushes[1]:RegisterImage(self.mPainterImage)	
		self.mImage = Jkr.Components.Abstract.ImageObject:New(inWidth, inHeight)
		self.mImageLabel = Com.ImageLabelObject:NewExisting(self.mImage, self.mPosition_3f, self.mDimension_3f)
	end,
	Bind = function (self)
		self.mPainterBrushes[1]:BindImage()
		self.mPainterBrushes[self.CurrentBrushId]:BindPainter()
	end,
	Paint = function (self, inBrushPosDimen_4f, inColor_4f, inParam_4f, inX, inY, inZ)
		self.mPainterBrushes[self.CurrentBrushId]:PaintEXT(inBrushPosDimen_4f, inColor_4f, inParam_4f, self.mImage, self.mPainterBrushes[1], inX, inY, inZ)
	end,
	Update = function(self, inPosition_3f, inDimension_3f)
		self.mPosition_3f = inPosition_3f
		self.mDimension_3f = inDimension_3f
		self.mImageLabel:Update(inPosition_3f, inDimension_3f)
	end,
}



