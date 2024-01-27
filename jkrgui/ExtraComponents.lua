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

Com.FileMenuBarObject = {
	mMainArea = nil,
	mHeight = nil,
	mFileMenu = nil,
	mDimension_3f = nil,
	New = function(self, inFileMenu, inHeight, inFontObject, inDepth)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		local mainareapos = vec3(0, 0, inDepth)
		local mainareadimen = vec3(WindowDimension.x, inHeight, 1)
		Obj.mMainArea = Com.AreaObject:New(mainareapos, mainareadimen)
		Obj.mHeight = inHeight
		Obj.mDepth = inDepth
		Obj.mButtons = {}
		Obj.mFileMenu = inFileMenu
		Obj.mNoOfEntries = #inFileMenu
		Obj.mDimension_3f = nil
		for i = 1, #inFileMenu, 1 do
			Obj.mButtons[i] = Com.TextButton:New(mainareapos, vec3(0, 0, 0),
				inFontObject, inFileMenu[i].name)
		end
		return Obj
	end,
	Update = function(self, inPosition_3f, inDimension_3f)
		self.mDimension_3f = inDimension_3f
		local ratiotable = {}

		for i = 1, self.mNoOfEntries, 1 do
			ratiotable[i] = 1 / self.mNoOfEntries
		end
		local horizontalcomponents = Com.HLayout:New(0)
		horizontalcomponents:AddComponents(self.mButtons, ratiotable)
		horizontalcomponents:Update(vec3(0, 0, self.mDepth), inDimension_3f)
		local position = horizontalcomponents:GetComponentPosition()
		for i = 1, self.mNoOfEntries, 1 do
			self.mButtons[i]:SetFunctions(
				function()
					local c = Theme.Colors.Area.Border
					ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor =
					vec4(c.x, c.y, c.z, c.w)
				end,
				function()
					local nc = Theme.Colors.Area.Normal
					ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor =
					vec4(nc.x, nc.y, nc.z, nc.w)
				end,
				function()
					local pos = vec3(position[i].x,
						position[i].y + self.mHeight,
						position[i].z)
					self.mFileMenu[i].action(pos)
				end
			)
		end
	end
}

Com.ContextMenu = {
	mMainArea = nil,
	mCellDimension_3f = vec3(0, 0, 0),
	mPosition_3f = nil,
	mButtons = nil,
	mMaxNoOfEntries = nil,
	New = function(self, inPosition_3f, inCellDimension_3f, inFontObject, inNoOfEntries, inMaxStringLength)
		local Obj = {
			mPosition_3f = inPosition_3f,
			mCellDimension_3f = inCellDimension_3f,
			mButtons = {},
			mMaxNoOfEntries = inNoOfEntries,
			mCurrentContextMenu = {}
		}
		setmetatable(Obj, self)
		self.__index = self
		local MainAreaDimen = vec3(0, 0, 1)
		Obj.mMainArea = Com.AreaObject:New(inPosition_3f, MainAreaDimen)
		local button_dimension = vec3(0, 0, 0)
		for i = 1, inNoOfEntries, 1 do
			local pos = vec3(inPosition_3f.x,
				inPosition_3f.y + inCellDimension_3f.y * (i - 1),
				inPosition_3f.z - 3)
			Obj.mButtons[i] = Com.TextButton:New(pos,
				button_dimension, inFontObject,
				string.rep(" ", inMaxStringLength))
		end
		return Obj
	end,
	Update = function(self, inPosition_3f, inCellDimension_3f, inContextMenuTable)
		self.mCurrentContextMenu = inContextMenuTable
		self.mMainArea:Update(vec3(0, 0, self.mMainArea.mPosition_3f.z), vec3(0, 0, 0))
		for index, value in ipairs(self.mButtons) do
			value:Update(vec3(0, 0, value.mPosition_3f.z), vec3(0, 0, 0), " ")
		end
		local inNoOfEntries = #inContextMenuTable
		local MainAreaDimension = vec3(inCellDimension_3f.x, inCellDimension_3f.y * inNoOfEntries,
			1)
		local mainareapos = vec3(inPosition_3f.x, inPosition_3f.y, self.mMainArea.mPosition_3f.z)
		self.mMainArea:Update(mainareapos, MainAreaDimension)
		for i = 1, inNoOfEntries, 1 do
			local pos = vec3(inPosition_3f.x,
				inPosition_3f.y + inCellDimension_3f.y * (i - 1),
				self.mButtons[i].mPosition_3f.z)
			self.mButtons[i]:Update(pos, inCellDimension_3f, inContextMenuTable[i].name)
			print(inContextMenuTable[i].name)
		end
		for i = 1, inNoOfEntries, 1 do
			self.mButtons[i]:SetFunctions(
				function()
					local nc = Theme.Colors.Area.Border
					ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor =
					vec4(nc.x, nc.y, nc.z, nc.w)
				end,
				function()
					local nc = Theme.Colors.Area.Normal
					ComTable[self.mButtons[i].mTextButton.mIds.y].mFillColor =
					vec4(nc.x, nc.y, nc.z, nc.w)
					if E.is_left_button_pressed() then
						self:Update(vec3(0, 0, 0),
							vec3(0, 0, 0),
							{})
					end
				end,
				function()
				end
			)
		end
	end,

}
