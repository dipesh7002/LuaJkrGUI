require "jkrgui.PrimitiveComponents"
require "jkrgui.ExtraComponents"
require "jkrgui.LayoutComponents"
require "jkrgui.Resources"

function Lerp(a, b, t)
	return b * t + (1 - t) * a
end

function LoadMaterialComponents(inLoadCompute)
	local CheckedImagePreload = {}
	local UnCheckedImagePreload = {}
	local DropDown = {}
	local DropUp = {}

	if not inLoadCompute then
		CheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
			"icons_material/radio_button_checked/baseline-2x.png")
		UnCheckedImagePreload = Jkr.Components.Abstract.ImageObject:New(40, 40,
			"icons_material/radio_button_unchecked/baseline-2x.png")
		DropDown = Jkr.Components.Abstract.ImageObject:New(0, 0,
			"icons_material/arrow_drop_down/baseline-2x.png")
		DropUp = Jkr.Components.Abstract.ImageObject:New(0, 0,
			"icons_material/arrow_drop_up/baseline-2x.png")
	else
		-- These are ought to be cleaned up, but for now, this is it.
		local Painter_Image = Jkr.Components.Abstract.PainterImageObject:New(40, 40)
		local Ip_Clear = Jkr.Components.Util.ImagePainter:New("cache/Clear.Compute", false, Jkr.GLSL.Clear, 1, 1, 1)
		Ip_Clear:RegisterImage(Painter_Image)
		local Ip_RoundedCircle = Jkr.Components.Util.ImagePainter:New("cache/RoundedCircle.Compute", false,
			Jkr.GLSL.RoundedCircle, 16, 16, 1)
		local ImagePrev = Jkr.Components.Abstract.ImageObject:New(40, 40)
		Com.NewSimulataneousDispatch()
		Com.NewSimultaneousSingleTimeDispatch(
			function()
				Ip_Clear:BindImage()
				Ip_RoundedCircle:BindPainter()
				Ip_RoundedCircle:Paint(vec4(0, 0, 0.4, 0.4), vec4(1), vec4(0), ImagePrev, Ip_Clear)
			end
		)
		CheckedImagePreload = ImagePrev
		UnCheckedImagePreload = ImagePrev
		DropDown = ImagePrev
		DropUp = ImagePrev
	end


	Com.ComboBox = {
		New = function(self, inFontObject, inMaxNoOfEntries, inMaxNoStringLength, inDepth, inPadding)
			local Obj = {
				mFontObject = inFontObject,
				mButtons = {},
				mCurrentComboContent = {},
				mDepth = inDepth,
				mPosition_3f = {},
				mDimension_3f = {},
				ChoosenChoice = nil,
				mHeadString = nil,
				mPadding = inPadding
			}
			setmetatable(Obj, self)
			self.__index = self
			Obj.mHeading = Com.TextLabelObject:New(" ", vec3(0, 0, inDepth), inFontObject)
			Obj.Areaforicon = Com.AreaObject:New(vec3(0, 0, 0), vec3(0, 0, 0))
			Obj.mDropdown = Com.IconButton:New(vec3(0, 0, 0), vec3(0, 0, 0), DropDown)
			Obj.mDropup = Com.IconButton:New(vec3(0, 0, 0), vec3(0, 0, 0), DropUp)
			for i = 1, inMaxNoOfEntries, 1 do
				Obj.mButtons[i] = Com.TextButton:New(vec3(0, 0, inDepth), vec3(0, 0, 0), inFontObject,
					string.rep(" ", inMaxNoStringLength))
			end
			return Obj
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inOneCellDimension_3f, inComboContent,
						  inDefaultString, inHeadString)
			self.mCurrentComboContent = inComboContent
			self.mHeadString = inHeadString
			local inNoOfEntries = #inComboContent
			self.ChoosenChoice = inDefaultString
			local dimen_string = self.mFontObject:GetDimension(inHeadString)
			self.mHeading:Update(vec3(inPosition_3f.x,
					inPosition_3f.y + inOneCellDimension_3f.y / 2 +
					dimen_string.y / 2, self.mDepth),
				vec3(0, 0, 0),
				inHeadString)
			self.mPosition_3f = vec3(inPosition_3f.x + dimen_string.x + 5, inPosition_3f.y, self.mDepth)
			local position = vec3(inPosition_3f.x + dimen_string.x + 5, inPosition_3f.y, self.mDepth)
			local positionforicon = vec3(self.mPosition_3f.x + inOneCellDimension_3f.x + 5, self.mPosition_3f.y,
				self.mDepth)
			local dimensionoficon = vec3(inOneCellDimension_3f.y, inOneCellDimension_3f.y, inOneCellDimension_3f.z)
			self.Areaforicon:Update(positionforicon, dimensionoficon)
			self.mDropdown:Update(positionforicon, dimensionoficon)
			self.mDropup:Update(vec3(0, 0, 0), vec3(0, 0, 0))
			self.mButtons[1]:Update(position, inOneCellDimension_3f, self.ChoosenChoice)
			local TextButton = function(flag)
				if flag then
					for i = 2, inNoOfEntries + 1, 1 do
						position.y = position.y + inOneCellDimension_3f.y + self.mPadding
						self.mButtons[i]:Update(position, inOneCellDimension_3f, self.mCurrentComboContent[i - 1])
					end
				else
					for i = 2, inNoOfEntries + 1, 1 do
						position.y = position.y + inOneCellDimension_3f.y + 5
						self.mButtons[i]:Update(vec3(0, 0, 0), vec3(0, 0, 0), " ")
					end
				end
				position = vec3(self.mPosition_3f.x, self.mPosition_3f.y, self.mDepth)
			end
			local window = self
			self.mDropdown:SetFunctions(
				function()
					window.mDropdown.mImageButton:TintColor(vec4(1, 0, 0, 1))
				end,
				function()
					window.mDropdown.mImageButton:TintColor(vec4(0, 0, 0, 1))
				end,
				function()
					window.mDropdown:Update(vec3(0, 0, 0), vec3(0, 0, 0))
					TextButton(true)
					Com.NewComponent_SingleTimeUpdate()
					ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(
						function()
							window.mDropup:Update(positionforicon, dimensionoficon)
						end
					)
				end
			)
			self.mDropup:SetFunctions(
				function()
					window.mDropup.mImageButton:TintColor(vec4(1, 0, 0, 1))
				end,
				function()
					window.mDropup.mImageButton:TintColor(vec4(0, 0, 0, 1))
				end,
				function()
					window.mDropup:Update(vec3(0, 0, 0), vec3(0, 0, 0))
					TextButton(false)
					Com.NewComponent_SingleTimeUpdate()
					ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(
						function()
							window.mDropdown:Update(positionforicon, dimensionoficon)
						end
					)
				end
			)

			for i = 2, inNoOfEntries + 1, 1 do
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
					end,
					function()
						self.mButtons[1]:Update(self.mPosition_3f,
							inOneCellDimension_3f, self.mButtons[i].mText)
					end
				)
			end
		end,
	}


	Com.CheckButtonList = {
		New = function(self, inMaxNoOfEntries, inFontObject, inPadding, inLengthCellDimension,
					   inMaxStringLength)
			local Obj = {
				mMaxNoOfEntries = inMaxNoOfEntries,
				mTableObjectForDescription = {},
				mButtonChecked = {},
				mButtonUnchecked = {},
				mPadding = inPadding,
				mLengthCellDimension = inLengthCellDimension,
				mIndex = nil,
				mCurrentStringTable = {}
			}

			setmetatable(Obj, self)
			self.__index = self
			Obj.mPosition_3f = {}
			Obj.mDimension_3f = {}
			for i = 0, inMaxNoOfEntries, 1 do
				Obj.mTableObjectForDescription[i] = Com.TextButtonObject:New(
					string.rep(" ", inMaxStringLength),
					inFontObject, vec3(0, 0, 80), vec3(0, 0, 0))
				Obj.mButtonChecked[i] = Com.ImageLabelObject:NewExisting(
					CheckedImagePreload, vec3(0, 0, 0),
					vec3(0, 0, 0))
				Obj.mButtonChecked[i]:TintColor(vec4(0, 0, 1, 1))
				Obj.mButtonUnchecked[i] = Com.ImageLabelObject:NewExisting(
					UnCheckedImagePreload, vec3(0, 0, 0),
					vec3(0, 0, 0))
				Obj.mButtonUnchecked[i]:TintColor(vec4(0, 0, 1, 1))
			end
			return Obj
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inStringTable)
			self.mCurrentStringTable = inStringTable
			local inNoOfEntries = #inStringTable
			local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
			for i = 1, inNoOfEntries, 1 do
				if self.mIndex == i or self.mIndex == nil then
					if inStringTable[i].mFirst then
						self.mButtonChecked[i]:Update(
							vec3(position.x, position.y,
								position.z),
							inDimension_3f)
						self.mButtonUnchecked[i]
							:Update(vec3(0, 0, 0),
								vec3(0, 0, 0))
					else
						self.mButtonUnchecked[i]
							:Update(
								vec3(position.x, position
									.y, position.z),
								inDimension_3f)
						self.mButtonChecked[i]:Update(
							vec3(0, 0, 0), vec3(0, 0, 0))
					end
				end
				self.mPosition_3f[i] = vec3(position.x, position.y,
					position.z)
				self.mDimension_3f[i] = vec3(inDimension_3f.x,
					inDimension_3f.y, inDimension_3f.z)
				position.y = position.y + inDimension_3f.y + self.mPadding
			end
			for i = 1, inNoOfEntries, 1 do
				self.mTableObjectForDescription[i]:Update(
					vec3(
						self.mPosition_3f[i].x +
						inDimension_3f.x +
						self.mPadding,
						self.mPosition_3f[i].y,
						self.mPosition_3f[i].z),
					vec3(self.mLengthCellDimension,
						inDimension_3f.y,
						inDimension_3f.z),
					inStringTable[i].name)
			end
		end,
		Event = function(self)
			local inNoOfEntries = #self.mCurrentStringTable
			local MousePos = E.get_mouse_pos()
			for i = 1, inNoOfEntries, 1 do
				if E.is_left_button_pressed() then
					if MousePos.x > self.mPosition_3f[i].x and MousePos.x <
						(self.mPosition_3f[i].x + self.mDimension_3f[i].x) and MousePos.y > self.mPosition_3f[i].y and
						MousePos.y < (self.mPosition_3f[i].y + self.mDimension_3f[i].y) then
						self.mCurrentStringTable[i].mFirst = not
							self.mCurrentStringTable[i]
							.mFirst
						self.mIndex = i
						self:Update(
							self.mPosition_3f[1],
							self.mDimension_3f
							[1],
							self.mCurrentStringTable) -- first button ko position dinuprxaw
					end
				end
			end
		end
	}

	Com.TextButton = {
		mTextButton = nil,
		New = function(self, inPosition_3f, inDimension_3f, inFont, inString)
			local Obj = Com.ButtonProxy:New(inPosition_3f, inDimension_3f)
			setmetatable(self, Com.ButtonProxy) -- inherits Com.ButtonProxy
			setmetatable(Obj, self)
			self.__index = self
			Obj.mText = inString
			Obj.mTextButton = Com.TextButtonObject:New(inString, inFont, inPosition_3f, inDimension_3f)
			return Obj
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inString)
			tracy.ZoneBeginN("MaterialTextButton")
			self.mText = inString
			self.mTextButton:Update(inPosition_3f, inDimension_3f, inString)
			Com.ButtonProxy.Update(self, inPosition_3f, inDimension_3f)
			tracy.ZoneEnd()
		end,
		SetFillColor = function(self, inColor_4f)
			self.mTextButton:SetFillColor(inColor_4f)
		end
	}

	Com.IconButton = {
		mImageButton = nil,
		New = function(self, inPosition_3f, inDimension_3f, inIconName)
			local Obj = Com.ButtonProxy:New(inPosition_3f, inDimension_3f)
			setmetatable(self, Com.ButtonProxy) -- inherits Com.ButtonProxy
			setmetatable(Obj, self)
			self.__index = self
			Obj.mImageButton = Com.ImageLabelObject:NewExisting(inIconName,
				vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z),
				inDimension_3f)
			Obj.mImageButton:TintColor(vec4(0, 0, 0, 1))
			return Obj
		end,
		Update = function(self, inPosition_3f, inDimension_3f)
			self.mImageButton:Update(inPosition_3f, inDimension_3f)
			Com.ButtonProxy.Update(self, inPosition_3f, inDimension_3f)
		end,
		TintColor = function(self, inColor)
			self.mImageButton:TintColor(inColor)
		end
	}

	Com.AreaButton = {
		mImageButton = nil,
		New = function(self, inPosition_3f, inDimension_3f, inIconName)
			local Obj = Com.ButtonProxy:New(inPosition_3f, inDimension_3f)
			setmetatable(self, Com.ButtonProxy) -- inherits Com.ButtonProxy
			setmetatable(Obj, self)
			self.__index = self
			Obj.mArea = Com.AreaObject:New(inPosition_3f, inDimension_3f)
			-- Obj.mArea = Com.ImageLabelObject:NewExisting(inIconName, vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z), inDimension_3f)
			Obj.mArea:SetFillColor(vec4(0, 0, 0, 1))
			return Obj
		end,
		Update = function(self, inPosition_3f, inDimension_3f)
			self.mArea:Update(inPosition_3f, inDimension_3f)
			Com.ButtonProxy.Update(self, inPosition_3f, inDimension_3f)
		end,
		TintColor = function(self, inColor)
			self.mArea:SetFillColor(inColor)
		end
	}

	Com.MaterialWindow = {
		mVerticalLayout = nil,
		mTitleText = nil,
		New = function(self, inPosition_3f, inDimension_3f, inHitArea_2f, inTitleText, inFontObject)
			local Obj = Com.WindowLayout:New(inPosition_3f, inDimension_3f, inHitArea_2f)
			setmetatable(self, Com.WindowLayout)
			setmetatable(Obj, self)
			self.__index = self

			Obj.mPosition_3f = inPosition_3f
			Obj.mDimension_3f = inDimension_3f
			Obj.mTitleText = inTitleText
			Obj.mFontObject = inFontObject
			return Obj
		end,
		SetCentralComponent = function(self, inComponent)
			local titleBar = Com.TextButtonObject:New(self.mTitleText, self.mFontObject,
				self.mPosition_3f,
				vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
			local close_button = Com.IconButton:New(vec3(0, 0, self.mPosition_3f.z),
				vec3(0, 0, 0), DropDown)
			local minmax_button = Com.IconButton:New(vec3(0, 0, self.mPosition_3f.z),
				vec3(0, 0, 0), DropUp)
			local minimize_button = Com.IconButton:New(vec3(0, 0, self.mPosition_3f.z),
				vec3(0, 0, 0), DropUp)

			close_button:SetFunctions(
				function()
					close_button.mImageButton:TintColor(vec4(1, 0,
						0, 1))
				end,
				function()
					close_button.mImageButton:TintColor(vec4(0, 0,
						0, 1))
				end,
				function()
					self:Update(vec3(0, 0, 0), vec3(0, 0, 0))
				end
			)

			minmax_button:SetFunctions(
				function()
					minmax_button.mImageButton:TintColor(vec4(1, 0,
						1, 1))
				end,
				function()
					minmax_button.mImageButton:TintColor(vec4(0, 0,
						0, 1))
				end,
				function()

				end
			)

			minimize_button:SetFunctions(
				function()
					minimize_button.mImageButton:TintColor(vec4(0,
						1, 0, 1))
				end,
				function()
					minimize_button.mImageButton:TintColor(vec4(0,
						0, 0, 1))
				end,
				function()

				end
			)

			local horizontalcomponents = Com.HLayout:New(0)
			local blankspace = Com.StackLayout:New(0)
			horizontalcomponents:AddComponents(
				{ blankspace, minimize_button, minmax_button, close_button },
				{ 0.7, 0.1, 0.1, 0.1 })

			local Window = self
			horizontalcomponents.Update = function(self, inPosition_3f, inDimension_3f)
				local dimen = vec3(Window.mHitArea_2f.y, Window.mHitArea_2f
					.y, inDimension_3f.z)
				local position = vec3(
					inPosition_3f.x + inDimension_3f.x - dimen.x, inPosition_3f
					.y, inPosition_3f.z)
				for i = #self.mComponents, 2, -1 do
					self.mComponents[i]:Update(position, dimen)
					position.x = position.x - dimen.x
				end
			end
			horizontalcomponents:Update(
				vec3(self.mPosition_3f.x, self.mPosition_3f.y,
					self.mPosition_3f.z),
				vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
			local titlebar_buttons = Com.StackLayout:New(5)
			titlebar_buttons:AddComponents({ titleBar, horizontalcomponents })
			titlebar_buttons:Update(self.mPosition_3f,
				vec3(self.mHitArea_2f.x, self.mHitArea_2f.y, 1))
			local verticalLayout = Com.VLayout:New(0)
			verticalLayout:AddComponents({ titlebar_buttons, inComponent }, { 0.2, 0.8 })
			local ThisWindow = self
			verticalLayout.Update = function(self, inPosition_3f, inDimension_3f)
				local pos = vec3(inPosition_3f.x,
					inPosition_3f.y + ThisWindow.mHitArea_2f.y,
					inPosition_3f.z)
				local hitdimen = vec3(ThisWindow.mHitArea_2f.x,
					ThisWindow.mHitArea_2f.y, 1)
				self.mComponents[1]:Update(inPosition_3f, hitdimen)
				self.mComponents[2]:Update(pos, inDimension_3f)
			end
			Com.WindowLayout.SetCentralComponent(self, verticalLayout)
		end,
	}

	--[[
		Material Veritcal Scroll bar-- Can Scroll a component Vertically
			-- inComponentDimension_3f refers to the dimension of component, scroll garne area ma dimension lai scissor le kaatne ho,
				tei vaera, purai component kok dimension chae elle dine. Like euta text ma 1000 lines xa, ani scroll area ma 100
				lines scissor garya xa vane, tyo 1000 lines wala dimension chae yo ho
			-- inScrollbarArea_2f Scrollbar ko motapa (width) linxa, 2f vae pani y value le garne kei haina, just x value linxa
			-- inScrollbarSizeFactor vaneko scrollbar ma tyo scroll garne rectangle ko purai vertical area ko kati percent area hunxa vanne ho
				(normalized matlab 0.0 dekhi 1.0 samma hunxa yo value)
			-- inMaxYDisplacement, tyo scrollbar purai scrolled huda kheri (like sapse tala huda kheri) component lai kati le displace garne ho mathi tira
				that is this
		===================================================================================================
		-- Example (In Load Callback)

		LoadMaterialComponents()
		Font = Jkr.FontObject:New("font.ttf", 4)
		ImagePreload = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/4k/outline.png")

		local Window = Com.MaterialWindow:New(vec3(400, 100, 80), vec3(200, 10, 1), vec2(200, 20), "Fuck You",
			Font)
		local str =
		"There are many peoople in this world who\nWill kill their selves for world\nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn\n"
		local from = { mPosition_3f = vec3(0, 400, 80), mDimension_3f = vec3(200, 200, 1) }
		local to = { mPosition_3f = vec3(400, 100, 80), mDimension_3f = vec3(200, 100, 1) }
		Window:Start()
		local Inside = function()
			local TextObj = Com.PlainTextEditObject:New(vec3(0), vec3(0), Font, 4, 30, 30)
			TextObj:Update(vec3(0), vec3(200, 500, 1), str, 20, 1)
			local materialVerticalScrollArea = Com.MaterialVerticalScrollArea:New(vec3(200, 200, 5),
				vec3(200, 200, 1), vec3(200, 200, 1), 20, vec2(20, 200), 0.1, 0.3)
			materialVerticalScrollArea:SetScrollableComponent(TextObj)
			Window:SetCentralComponent(materialVerticalScrollArea)
		end
		Inside()
		Window:End()

		Com.AnimateSingleTimePosDimen(Window, from, to, 0.1)
	]]
	Com.MaterialVerticalScrollArea = {
		mScrollableComponent = nil,
		mScrollerComponentObject = nil,
		mScrolling = nil,
		mComponentDimension_3f = nil,
		mMaxYDisplacement = nil,
		New = function(self, inPosition_3f, inDimension_3f, inComponentDimension_3f, inMaxYDisplacement,
					   inScrollbarArea_2f, inScrollbarSensitivity, inScrollbarSizeFactor)
			local Obj = Com.ScrollProxy:New(inPosition_3f, inDimension_3f, inScrollbarArea_2f,
				inScrollbarSensitivity, inScrollbarSizeFactor)
			setmetatable(self, Com.ScrollProxy)
			setmetatable(Obj, self)
			self.__index = self
			Obj.mScrollerComponentObject = Jkr.ComponentObject:New(vec3(0), vec3(0))
			Obj.mScrolling = false
			Obj.mComponentDimension_3f = inComponentDimension_3f
			Obj.mMaxYDisplacement = inMaxYDisplacement
			return Obj
		end,
		SetScrollableComponent = function(self, inComponent)
			local IconUp = Com.IconButton:New(vec3(0), vec3(0), DropUp)
			local IconDown = Com.IconButton:New(vec3(0), vec3(0), DropDown)
			local scrollArea = Com.AreaObject:New(vec3(0), vec3(0))
			local NewColorArea = vec4(Theme.Colors.Area.Border.x, Theme.Colors.Area.Border.y,
				Theme.Colors.Area.Border.z, Theme.Colors.Area.Border.w)
			scrollArea:SetFillColor(NewColorArea)
			local scrollbarV = Com.VLayout:New(0)
			local horizontalArea = Com.HLayout:New(0)
			scrollbarV:AddComponents({ IconUp, scrollArea, IconDown }, { 0.1, 0.8, 0.1 })
			horizontalArea:AddComponents({ inComponent, scrollbarV }, { 0.9, 0.1 })
			local Scroller = Com.AreaObject:New(vec3(0), vec3(0))
			Scroller:SetFillColor(vec4(1, 0, 0, 1))

			local This = self
			horizontalArea.Update = function(self, inPosition_3f, inDimension_3f)
				local scrollArea_3f = vec3(This.mScrollbarArea_2f.x, inDimension_3f.y, 1)
				local componentArea_3f = vec3(inDimension_3f.x - scrollArea_3f.x,
					inDimension_3f.y, inDimension_3f.z)
				local scrollAreaPosition_3f = vec3(inPosition_3f.x + componentArea_3f.x,
					inPosition_3f.y, inPosition_3f.z)

				local componentDisplacePosition = Lerp(0, This.mMaxYDisplacement,
					This.mScrollbarPositionNormalized)
				local componentPosition = vec3(inPosition_3f.x,
					inPosition_3f.y - componentDisplacePosition, inPosition_3f.z)
				if This.mComponentDimension_3f then
					componentArea_3f.y = This.mComponentDimension_3f.y
				end

				self.mComponents[1]:Update(componentPosition, componentArea_3f)
				self.mComponents[2]:Update(scrollAreaPosition_3f, scrollArea_3f)
			end

			scrollbarV.Update = function(self, inPosition_3f, inDimension_3f)
				local upDownArea_3f = vec3(This.mScrollbarArea_2f.x, This.mScrollbarArea_2f.x,
					inDimension_3f.z)
				local iconUpPosition_3f = inPosition_3f
				local areaPos_3f = vec3(iconUpPosition_3f.x,
					iconUpPosition_3f.y + upDownArea_3f.y, iconUpPosition_3f.z)
				local areaDimension_3f = vec3(inDimension_3f.x,
					inDimension_3f.y - 2 * upDownArea_3f.y, inDimension_3f.z)
				local iconDownPosition_3f = vec3(areaPos_3f.x, areaPos_3f.y + areaDimension_3f.y,
					areaPos_3f.z)
				self.mComponents[1]:Update(iconUpPosition_3f, upDownArea_3f)
				self.mComponents[2]:Update(areaPos_3f, areaDimension_3f)
				self.mComponents[3]:Update(iconDownPosition_3f, upDownArea_3f)

				-- Scrollbar Position Calculation
				local Ypos = Lerp(areaPos_3f.y,
					areaPos_3f.y +
					(areaDimension_3f.y - This.mScrollbarSizeFactor * areaDimension_3f.y),
					This.mScrollbarPositionNormalized)
				local scrollerPosition = vec3(areaPos_3f.x, Ypos, areaPos_3f.z)
				local scrollerDimension = vec3(areaDimension_3f.x,
					areaDimension_3f.y * This.mScrollbarSizeFactor, areaDimension_3f.z)

				Scroller:Update(scrollerPosition, scrollerDimension)
				This.mScrollerComponentObject:Update(scrollerPosition, scrollerDimension)
			end
			self.mCentralComponent = horizontalArea

			Com.NewComponent_Event()
			ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
				function()
					self.mScrollerComponentObject:Event()
					if self.mScrollerComponentObject.mClicked_b or (self.mScrolling and E.is_left_button_pressed()) then
						local relpos = E.get_relative_mouse_pos()
						This.mScrollbarPositionNormalized = This
							.mScrollbarPositionNormalized + relpos.y / 30
						local sn = This.mScrollbarPositionNormalized
						if This.mScrollbarPositionNormalized >= 1 then
							This.mScrollbarPositionNormalized = 1
						elseif This.mScrollbarPositionNormalized <= 0 then
							This.mScrollbarPositionNormalized = 0
						end
						This:Update(This.mPosition_3f, This.mDimension_3f)
						self.mScrolling = true
					else
						self.mScrolling = false
					end
				end
			)
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inScrollbarArea_2f, inComponentDimension_3f,
						  inMaxYDisplacement)
			self.mPosition_3f = inPosition_3f
			self.mDimension_3f = inDimension_3f
			if inComponentDimension_3f then
				self.mComponentDimension_3f = inComponentDimension_3f
			end
			if inMaxYDisplacement then
				self.mMaxYDisplacement = inMaxYDisplacement
			end
			self.mCentralComponent:Update(inPosition_3f, inDimension_3f)
		end
	}


	Com.ContextMenu = {
		mMainArea = nil,
		mCellDimension_3f = vec3(0, 0, 0),
		mPosition_3f = nil,
		mButtons = nil,
		mMaxNoOfEntries = nil,
		New = function(self, inPosition_3f, inCellDimension_3f, inFontObject, inNoOfEntries,
					   inMaxStringLength)
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
			Obj.mCellDimension_3f = inCellDimension_3f
			Obj.mShouldNullifyContextMenuTableOnUpdate = true
			return Obj
		end,
		NullifyContextMenuTableOnUpdate = function(self, inBool)
			self.mShouldNullifyContextMenuTableOnUpdate = inBool
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inCellDimension_3f, inContextMenuTable)
			if self.mShouldNullifyContextMenuTableOnUpdate then
				self.mCurrentContextMenu = {}
			end

			if not inContextMenuTable then
				self:Update(inPosition_3f, inDimension_3f, inCellDimension_3f, self.mCurrentContextMenu)
			end

			if inContextMenuTable then
				self.mCurrentContextMenu = inContextMenuTable
			end
			if inCellDimension_3f then
				self.mCellDimension_3f = inCellDimension_3f
			end

			self.mMainArea:Update(vec3(0, 0, self.mMainArea.mPosition_3f.z), vec3(0, 0, 0))
			for index, value in ipairs(self.mButtons) do
				value:Update(vec3(0, 0, value.mPosition_3f.z), vec3(0, 0, 0), " ")
			end
			local inNoOfEntries = #self.mCurrentContextMenu
			local MainAreaDimension = vec3(self.mCellDimension_3f.x, self.mCellDimension_3f.y * inNoOfEntries,
				1)
			local mainareapos = vec3(inPosition_3f.x, inPosition_3f.y, self.mMainArea.mPosition_3f.z)
			self.mMainArea:Update(mainareapos, MainAreaDimension)
			for i = 1, inNoOfEntries, 1 do
				local pos = vec3(inPosition_3f.x,
					inPosition_3f.y + self.mCellDimension_3f.y * (i - 1),
					self.mButtons[i].mPosition_3f.z)
				self.mButtons[i]:Update(pos, self.mCellDimension_3f, self.mCurrentContextMenu[i].name)
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
					end,
					function()
					end
				)
			end
		end,

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

	Com.NavigationBar = {
		mLayout = nil,
		mNavBarIndicator = nil,
		mCurrentNavBarSelection = nil,
		mCurrentNavBarIndicatorDimension = nil,
		mNavBarIndicatorDimension = nil,
		mCurrentComponentCount = nil,
		mPosition_3f = nil,
		mDimension_3f = nil,
		New = function(self, inPosition_3f, inDimension_3f, inComponents, inPutIndicatorAtBottom)
			local Obj = {}
			setmetatable(Obj, self)
			self.__index = self
			Obj.mCurrentNavBarSelection = 2
			Obj.mPosition_3f = inPosition_3f
			Obj.mDimension_3f = inDimension_3f
			Obj.mIsIndicatorAtBottom = false
			if inPutIndicatorAtBottom then
				Obj.mIsIndicatorAtBottom = true
			end

			Obj.mLayout = Com.HLayout:New(0)
			local noOfComp = #inComponents
			local equalRatio = 1 / noOfComp
			local ratioTable = {}
			for i = 1, noOfComp, 1 do
				ratioTable[#ratioTable + 1] = equalRatio
			end
			Com.HLayout.AddComponents(Obj.mLayout, inComponents, ratioTable)
			Obj.mCurrentComponentCount = inComponents

			local NavBarPosition = Obj.mPosition_3f
			local NavBarDimension = Obj.mDimension_3f
			local NavBarIndicatorDimension = vec3(1 / #inComponents * NavBarDimension.x, 14, 1)
			local NavBarIndicatorPosition = vec3(
				NavBarPosition.x + (Obj.mCurrentNavBarSelection - 1) * NavBarIndicatorDimension.x,
				NavBarPosition.y - NavBarIndicatorDimension.y,
				NavBarPosition.z)
			Obj.mNavBarIndicator = Com.Canvas:New(NavBarIndicatorPosition, NavBarIndicatorDimension)
			Com.Canvas.AddPainterBrush(Obj.mNavBarIndicator, Com.GetCanvasPainter("Clear", false))
			Com.Canvas.AddPainterBrush(Obj.mNavBarIndicator, Com.GetCanvasPainter("RoundedRectangle", false))
			Com.Canvas.MakeCanvasImage(Obj.mNavBarIndicator, NavBarIndicatorDimension.x, NavBarIndicatorDimension.y)
			Obj.mCurrentNavBarIndicatorDimension = vec3(NavBarIndicatorDimension.x, NavBarIndicatorDimension.y,
				NavBarIndicatorDimension.z)
			Obj.mNavBarIndicatorInitialDimension = vec3(NavBarIndicatorDimension.x, NavBarIndicatorDimension.y,
				NavBarIndicatorDimension.z)

			Com.HLayout.Update(Obj.mLayout, Obj.mPosition_3f, Obj.mDimension_3f)
			return Obj
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inCurrentNavBarPosition)
			self.mPosition_3f = inPosition_3f
			self.mDimension_3f = inDimension_3f
			self.mLayout:Update(inPosition_3f, inDimension_3f)
			if inCurrentNavBarPosition then
				self.mCurrentNavBarSelection = inCurrentNavBarPosition
			end
			local NavBarIndicatorPosition = vec3(
				inPosition_3f.x + (self.mCurrentNavBarSelection - 1) * self.mCurrentNavBarIndicatorDimension.x,
				inPosition_3f.y - self.mCurrentNavBarIndicatorDimension.y,
				inPosition_3f.z)
			if self.mIsIndicatorAtBottom then
				NavBarIndicatorPosition = vec3(
					inPosition_3f.x + (self.mCurrentNavBarSelection - 1) * self.mCurrentNavBarIndicatorDimension.x,
					inPosition_3f.y + inDimension_3f.y - self.mCurrentNavBarIndicatorDimension.y,
					inPosition_3f.z)
			end

			self.mCurrentNavBarIndicatorDimension = vec3(1.0 / #self.mLayout.mComponents * inDimension_3f.x, 14, 1)
			Com.Canvas.Update(self.mNavBarIndicator, NavBarIndicatorPosition, self.mCurrentNavBarIndicatorDimension)
			self.mCurrentNavBarIndicatorDimension = self.mCurrentNavBarIndicatorDimension
		end,
		Animate = function(self, inPosition_3f, inDimension_3f, inNavBarSelection, inInverseSpeed)
			local getNavBarIndicatorPos = function(inNavBar)
				if not self.mIsIndicatorAtBottom then
					return vec3(
						inPosition_3f.x +
						(inNavBar.mCurrentNavBarSelection - 1) * inNavBar.mCurrentNavBarIndicatorDimension.x,
						inPosition_3f.y - self.mCurrentNavBarIndicatorDimension.y,
						inPosition_3f.z)
				else
					return vec3(
						inPosition_3f.x +
						(inNavBar.mCurrentNavBarSelection - 1) * inNavBar.mCurrentNavBarIndicatorDimension.x,
						inPosition_3f.y + inDimension_3f.y - self.mCurrentNavBarIndicatorDimension.y,
						inPosition_3f.z)
				end
			end

			local from_pos = getNavBarIndicatorPos(self)
			if inNavBarSelection ~= self.mCurrentNavBarSelection then
				self.mCurrentNavBarSelection = inNavBarSelection
				local to_pos = getNavBarIndicatorPos(self)
				local from = { mPosition_3f = from_pos, mDimension_3f = self.mCurrentNavBarIndicatorDimension }
				local to = { mPosition_3f = to_pos, mDimension_3f = self.mCurrentNavBarIndicatorDimension }
				Com.AnimateSingleTimePosDimen(self.mNavBarIndicator, from, to, inInverseSpeed)
			end
		end,
		-- This doesn't work good, to be tested to the best
		Dispatch = function(self, inColor_4f)
			self.mNavBarIndicatorColor = inColor_4f
			self.mNavBarIndicator.CurrentBrushId = 2
			self.mNavBarIndicator:Bind()
			Com.Canvas.Paint(self.mNavBarIndicator,
				vec4(-0.2 * self.mNavBarIndicatorInitialDimension.x, 0, self.mNavBarIndicatorInitialDimension.x * 1.4,
					self.mNavBarIndicatorInitialDimension.y),
				inColor_4f, vec4(1.2, 0.5, 0.8, 0.9), self.mNavBarIndicatorInitialDimension.x * 1.4,
				self.mNavBarIndicatorInitialDimension.y, 1)
		end,
		ClearDispatch = function(self, inColor_4f)
			self.mNavBarIndicatorColor = inColor_4f
			self.mNavBarIndicator.CurrentBrushId = 1
			self.mNavBarIndicator:Bind()
			Com.Canvas.Paint(self.mNavBarIndicator,
				vec4(0, 0, self.mCurrentNavBarIndicatorDimension.x, self.mCurrentNavBarIndicatorDimension.y), inColor_4f,
				vec4(0), self.mNavBarIndicatorInitialDimension.x, self.mNavBarIndicatorInitialDimension.y, 1)
		end
	}

	Com.MaterialLineEdit = {
		mLineEdit = nil,
		mLineIndicatorArea = nil,
		mLayout = nil,
		New = function(self, inPosition_3f, inDimension_3f, inFont, inInitialString)
			local Obj = {}
			setmetatable(Obj, self)
			self.__index = self
			Obj.mLineEdit = Com.PlainTextLineEditObject:New(inPosition_3f, inDimension_3f, inFont, 100)
			Obj.mLineIndicatorArea = Com.AreaObject:New(vec3(0), vec3(0))
			Com.PlainTextLineEditObject.Update(Obj.mLineEdit, inPosition_3f, vec3(2000, 2000, 1), "\n", 20, 2)
			if inInitialString then
				Com.VisualTextEditObject.CursorInsert(Obj.mLineEdit, inInitialString)
			end
			Obj.mLayout = Com.VLayout:New(0)
			Obj.mLayout:AddComponents({Com.VLayout:New(0), Obj.mLineEdit, Obj.mLineIndicatorArea}, {0.20, 0.7, 0.10})
			Obj.mLayout:Update(vec3(200, 200, 1), vec3(2000, 2000, 1))
			Obj.turnedOn = false
			Com.NewEvent(
				function ()
					if Obj.mLineEdit:IsClickedEvent() then
						Obj.turnedOn = not Obj.turnedOn
					end

				if E.is_mousepress_event() and E.is_left_button_pressed() and not Obj.mLineEdit:IsClickedEvent() then
						Obj.turnedOn = false
					end

					if Obj.turnedOn then
						Obj.mLineIndicatorArea:SetFillColor(vec4(1, 0, 0, 1))		
					else
						Obj.mLineIndicatorArea:SetFillColor(vec4(1, 1, 1, 1))		
					end
				end
			)
			return Obj
		end,
		Update = function (self, inPosition_3f, inDimension_3f)
			tracy.ZoneBeginN("Material Line Edit")
			self.mLayout:Update(inPosition_3f, inDimension_3f)
			tracy.ZoneEnd()
		end,
		GetText = function (self)
			return self.mLineEdit.mStringBuffer
		end
	}
end
