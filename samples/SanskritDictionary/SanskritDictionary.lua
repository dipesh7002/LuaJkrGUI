require "jkrgui.all"
require "samples.SanskritDictionary.database"

Com.NavigationBar = {
	mLayout = nil,
	mNavBarIndicator = nil,
	mCurrentNavBarSelection = nil,
	mCurrentNavBarIndicatorDimension = nil,
	mNavBarIndicatorDimension = nil,
	mCurrentComponentCount = nil,
	mPosition_3f = nil,
	mDimension_3f = nil,
	New = function (self, inPosition_3f, inDimension_3f, inComponents)
		local Obj = {}	
		setmetatable(Obj, self)
		self.__index = self
		Obj.mCurrentNavBarSelection = 2
		Obj.mPosition_3f = inPosition_3f
		Obj.mDimension_3f = inDimension_3f

		Obj.mLayout = Com.HLayout:New(0)	
		local noOfComp = #inComponents
		local equalRatio = 1 / noOfComp
		local ratioTable = {}
		for i = 1, noOfComp, 1 do
			ratioTable[#ratioTable+1] = equalRatio	
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
		Obj.mCurrentNavBarIndicatorDimension = vec3(NavBarIndicatorDimension.x, NavBarIndicatorDimension.y, NavBarIndicatorDimension.z)

		Com.HLayout.Update(Obj.mLayout, Obj.mPosition_3f, Obj.mDimension_3f)
		return Obj
	end,
	Update = function (self, inPosition_3f, inDimension_3f, inCurrentNavBarPosition)
		if inCurrentNavBarPosition then
			self.mCurrentNavBarSelection = inCurrentNavBarPosition
		end
		local NavBarIndicatorPosition = vec3(
			inPosition_3f.x + (self.mCurrentNavBarSelection - 1) * self.mCurrentNavBarIndicatorDimension.x,
			inPosition_3f.y - self.mCurrentNavBarIndicatorDimension.y,
			inPosition_3f.z)
		local NavBarIndicatorDimension = vec3(1 / #self.mLayout.mComponents * inDimension_3f.x, 14, 1)
		Com.Canvas.Update(self.mNavBarIndicator, NavBarIndicatorPosition, NavBarIndicatorDimension)
		self.mCurrentNavBarIndicatorDimension = NavBarIndicatorDimension
	end,
	Animate = function (self, inPosition_3f, inDimension_3f, inNavBarSelection)

		local getNavBarIndicatorPos = function (inNavBar)
			return vec3(
			inPosition_3f.x + (inNavBar.mCurrentNavBarSelection - 1) * inNavBar.mCurrentNavBarIndicatorDimension.x,
			inPosition_3f.y - self.mCurrentNavBarIndicatorDimension.y,
			inPosition_3f.z
		)
		end

		local from_pos = getNavBarIndicatorPos(self)
		if inNavBarSelection ~= self.mCurrentNavBarSelection then
			self.mCurrentNavBarSelection = inNavBarSelection
			local to_pos = getNavBarIndicatorPos(self)
			local from = {mPosition_3f = from_pos, mDimension_3f = self.mCurrentNavBarIndicatorDimension}
			local to = {mPosition_3f = to_pos, mDimension_3f = self.mCurrentNavBarIndicatorDimension}
			Com.AnimateSingleTimePosDimen(self.mNavBarIndicator, from, to, 0.1)
		end
	end,
	Dispatch = function (self, inColor_4f)
		self.mNavBarIndicator.CurrentBrushId = 2
		self.mNavBarIndicator:Bind()
		Com.Canvas.Paint(self.mNavBarIndicator,
			vec4( -0.2 * self.mCurrentNavBarIndicatorDimension.x, 0, self.mCurrentNavBarIndicatorDimension.x * 1.4, self.mCurrentNavBarIndicatorDimension.y),
			inColor_4f, vec4(1.2, 0.5, 0.8, 0.9), self.mCurrentNavBarIndicatorDimension.x * 1.4,
			self.mCurrentNavBarIndicatorDimension.y, 1)
	end
}

local ComponentDimension = WindowDimension

local function ConfigureTopBar(TopBar, TopBarSizeFactor, hsizeTabBar)
	TopBar:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
	TopBar:AddPainterBrush(Com.GetCanvasPainter("RoundedRectangle", false))
	TopBar:MakeCanvasImage(ComponentDimension.x, ComponentDimension.y * TopBarSizeFactor)

	local Vlayout = Com.VLayout:New(0)
	local PageLayout = Com.VLayout:New(0)
	Vlayout:AddComponents({ TopBar, PageLayout }, { TopBarSizeFactor, 1 - TopBarSizeFactor })
	Vlayout:Update(vec3(0, 0, 50), vec3(hsizeTabBar, ComponentDimension.y, 1))

	local topText = "संस्कृतम्"
	local tB = Com.TextLabelObject:New(topText,
		vec3(ComponentDimension.x / 4 - BigFont:GetDimension(topText).x / 2, 0.01 * ComponentDimension.y,
			10),
		BigFont)
end

local function ConfigureScrollArea(SuggestionArea, cm, SuggestionPos, SuggestionDimen)
	local function insideScrollbar()
		cm:Update(vec3(100, 100, 30), nil, vec3(SuggestionDimen.x - 20, 30, 1), ContextMenuEntries_Run)
		SuggestionArea:SetScrollableComponent(cm)
		SuggestionArea:Update(vec3(100, 100, 30), vec3(100, 100, 1))
	end
	insideScrollbar()
	SuggestionArea:Update(SuggestionPos, SuggestionDimen)
end

local function ConfigureSearchBar(RoundedCircle, circlePImageSize, SearchBarPos, SearchBarDimen, searchBar)
	local searchTextEdit = Com.VLayout:New(0)
	local area = Com.AreaObject:New(vec3(10, 10, 10), vec3(10, 10, 1))
	searchBar:Update(vec3(200, 400, 20), vec3(100, 100, 1), "\n", 20, 1)
	searchTextEdit:AddComponents({ searchBar, area }, { 0.9, 0.05 })
	searchTextEdit:Update(vec3(ComponentDimension.x * 0.02, ComponentDimension.y * 0.1, 30),
		vec3(ComponentDimension.x * 0.8, ComponentDimension.y * 0.05, 30))
	RoundedCircle:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
	RoundedCircle:AddPainterBrush(Com.GetCanvasPainter("Circle", true))
	RoundedCircle:MakeCanvasImage(circlePImageSize.x, circlePImageSize.y)

	local Image = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/search/outline.png")
	local Icon = Com.ImageLabelObject:NewExisting(Image, vec3(30, 10, 9), vec3(100, 100, 1))
	Icon:TintColor(vec4(0, 0, 0, 1))

	local HLayout = Com.HLayout:New(5)
	HLayout.Update = function(self, inPosition_3f, inDimension_3f)
		Com.HLayout.Update(self, inPosition_3f, inDimension_3f)
		local pos = vec3(inPosition_3f.x, inPosition_3f.y - inDimension_3f.y / 4, inPosition_3f.z)
		self.mComponents[1]:Update(pos, vec3(40, 40, 1))
		local ipos = vec3(pos.x, pos.y, pos.z - 1)
		local idimen = vec3(circlePImageSize.x / 2, circlePImageSize.y / 2, 1)
		Icon:Update(vec3(pos.x + idimen.x / 2, pos.y + idimen.y / 2, 25), idimen)
	end

	HLayout:AddComponents({ RoundedCircle.mImageLabel, searchTextEdit, Com.HLayout:New(0) },
		{ 0.1, 0.8, 0.1 })
	HLayout:Update(SearchBarPos, SearchBarDimen)
end

local GetSanskritDictionarySuggestions = function()
	local Entry = {}

	for i = 1, #DictionaryData do
		Entry[i] = {
			name = DictionaryData[i][1],
			action = function()
				-- do nothing	
			end
		}
	end
	return Entry
end

function SanskritDictionaryLoad()
	LoadMaterialComponents(false)
	BigFont = Com.GetFont("font", "Large")
	local apricot_color = vec4(0.99, 0.83, 0.73, 1)

	local TopBar = Com.Canvas:New(vec3(0, 0, 30), vec3(ComponentDimension.x, ComponentDimension.y, 1))
	local TopBarSizeFactor = 0.08
	local hsizeTabBar = 300
	ConfigureTopBar(TopBar, TopBarSizeFactor, hsizeTabBar)

	local SearchBarPos = vec3(ComponentDimension.x * 0.02, ComponentDimension.y * 0.1, 80)
	local SearchBarDimen = vec3(ComponentDimension.x, ComponentDimension.y * 0.05, 30)
	local RoundedCircle = Com.Canvas:New(P(0, 0, 80), vec3(ComponentDimension.x, ComponentDimension.y, 1))
	local circlePImageSize = vec2(40, 40)
	local searchBar = Com.PlainTextLineEditObject:New(vec3(200, 400, 20), vec3(100, 100, 1),
		Com.GetFont("font", "Large"), 100)
	ConfigureSearchBar(RoundedCircle, circlePImageSize, SearchBarPos, SearchBarDimen, searchBar)

	local SuggestionPos = vec3(SearchBarPos.x + 0.1 * SearchBarDimen.x, SearchBarPos.y + SearchBarDimen.y,
		SearchBarPos.z)
	local SuggestionDimen = 0.8 * SearchBarDimen
	SuggestionDimen.y = 0.2 * ComponentDimension.y

	local SuggestionArea = Com.MaterialVerticalScrollArea:New(SearchBarPos, vec3(SearchBarDimen.x, 200, 1),
		vec3(SearchBarDimen.x, 200, 1), 20, vec2(20, 200), 0.1, 0.3)
	SuggestionArea:Start()
	local cm = Com.ContextMenu:New(vec3(200, 200, 50), vec3(SuggestionDimen.x, 100, 1),
		Com.GetFont("font", "large"), 10, 100)
	ConfigureScrollArea(SuggestionArea, cm, SuggestionPos, SuggestionDimen)
	SuggestionArea:End()
	SuggestionArea:Update(vec3(0), vec3(0))

	local Image = Jkr.Components.Abstract.ImageObject:New(0, 0, "PNG_transparency_demonstration_1.png")
	local NavBarElem1 = Com.IconButton:New(vec3(0), vec3(0), Image)
	NavBarElem1:TintColor(vec4(1, 0, 0, 1))
	local NavBarElem2 = Com.IconButton:New(vec3(0), vec3(0), Image)
	NavBarElem2:TintColor(vec4(0, 1, 0, 1))
	local NavBarElem3 = Com.IconButton:New(vec3(0), vec3(0), Image)
	NavBarElem3:TintColor(vec4(0, 0, 1, 1))

	local NavBarDimension = vec3(WindowDimension.x, WindowDimension.y * 0.1, 1)
	local NavBarPosition = vec3(0, WindowDimension.y - NavBarDimension.y, 50)
	local NavBar = Com.NavigationBar:New(NavBarPosition, NavBarDimension, {NavBarElem1, NavBarElem2, NavBarElem3})
	NavBarElem1:SetFunctions( nil, nil, function () Com.NavigationBar.Animate(NavBar, NavBarPosition, NavBarDimension, 1) end)
	NavBarElem2:SetFunctions( nil, nil, function () Com.NavigationBar.Animate(NavBar, NavBarPosition, NavBarDimension, 2) end)
	NavBarElem3:SetFunctions( nil, nil, function () Com.NavigationBar.Animate(NavBar, NavBarPosition, NavBarDimension, 3) end)
	Com.NavigationBar.Update(NavBar, NavBarPosition, NavBarDimension, 1)
	print(NavBar.mCurrentNavBarIndicatorDimension.x)

	Com.NewComponent_Event()
	ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
		function()
			local TextEditButtonIsClicked = E.is_mousepress_event() and E.is_left_button_pressed() and
			    searchBar:IsClickedEvent()
			--
			if TextEditButtonIsClicked then
				if not SuggestionArea.On then
					cm:NullifyContextMenuTableOnUpdate(true)
					local from = {
						mPosition_3f = SuggestionPos,
						mDimension_3f = vec3(
							SuggestionDimen.x, 0, SuggestionDimen.z)
					}
					local to = {
						mPosition_3f = SuggestionPos,
						mDimension_3f =
						    SuggestionDimen
					}
					Com.AnimateSingleTimePosDimen(SuggestionArea, from, to, 0.2,
						function()
							cm:NullifyContextMenuTableOnUpdate(false)
							cm:Update(SuggestionPos, SuggestionDimen,
								vec3(SuggestionDimen.x - 20, 30, 1),
								GetSanskritDictionarySuggestions())
						end)
					SuggestionArea.On = true
				else
					cm:NullifyContextMenuTableOnUpdate(true)
					local to = {
						mPosition_3f = SuggestionPos,
						mDimension_3f = vec3(
							SuggestionDimen.x, 0, SuggestionDimen.z)
					}
					local from = {
						mPosition_3f = SuggestionPos,
						mDimension_3f =
						    SuggestionDimen
					}
					Com.AnimateSingleTimePosDimen(SuggestionArea, from, to, 0.2)
					SuggestionArea.On = false
				end
			end
		end
	)

	Com.NewComponent_SingleTimeDispatch()
	ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
		function()
			TopBar.CurrentBrushId = 2
			TopBar:Bind()
			local startingY = -ComponentDimension.y + TopBarSizeFactor * ComponentDimension.y * 1.8
			local startingX = -ComponentDimension.x
			local endingX = ComponentDimension.x * 2
			local endingY = ComponentDimension.y + TopBarSizeFactor * ComponentDimension.y
			TopBar:Paint(vec4(startingX, startingY, endingX, endingY), apricot_color,
				vec4(1.2, 1, 1, 0.8), endingX, endingY, 1)

			RoundedCircle.CurrentBrushId = 2
			RoundedCircle:Bind()
			RoundedCircle:Paint(vec4(0, 0, circlePImageSize.x, circlePImageSize.y), apricot_color,
				vec4(1.8, 1, 1, 0.8), circlePImageSize.x, circlePImageSize.y, 1)

			-- NavBarIndicator.CurrentBrushId = 2
			-- NavBarIndicator:Bind()
			-- Com.Canvas.Paint(NavBarIndicator,
			-- 	vec4( -0.2 * NavBarIndicatorDimension.x, 0, NavBarIndicatorDimension.x * 1.4, NavBarIndicatorDimension.y),
			-- 	apricot_color, vec4(1.2, 0.5, 0.8, 0.9), NavBarIndicatorDimension.x * 1.4,
			-- 	NavBarIndicatorDimension.y, 1)
			NavBar:Dispatch(apricot_color)
		end
	)
end
