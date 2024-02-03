require "jkrgui.all"

function SanskritDictionaryLoad()
	LoadMaterialComponents(false)
	BigFont = Com.GetFont("font", "Large")
	local apricot_color = vec4(0.99, 0.83, 0.73, 1)

	local TopBar = Com.Canvas:New(vec3(0, 0, 30), vec3(WindowDimension.x, WindowDimension.y, 1))
	local TopBarSizeFactor = 0.08
	local hsizeTabBar = 300
	local function topBar()
		TopBar:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
		TopBar:AddPainterBrush(Com.GetCanvasPainter("RoundedRectangle", false))
		TopBar:MakeCanvasImage(WindowDimension.x, WindowDimension.y * TopBarSizeFactor)

		local Vlayout = Com.VLayout:New(0)
		local PageLayout = Com.VLayout:New(0)
		Vlayout:AddComponents({ TopBar, PageLayout }, { TopBarSizeFactor, 1 - TopBarSizeFactor })
		Vlayout:Update(vec3(0, 0, 70), vec3(hsizeTabBar, WindowDimension.y, 1))

		local topText = "संस्कृतम्"
		local tB = Com.TextLabelObject:New(topText,
			vec3(WindowDimension.x / 4 - BigFont:GetDimension(topText).x / 2, 0.01 * WindowDimension.y,
				10),
			BigFont)
	end
	topBar()



	ContextMenuEntries_Run = {
		[1] = {
			name = "आरम्भः",
			action = function()

			end
		},
		[2] = {
			name = "परामर्शः",
			action = function()

			end
		},
		[3] = {
			name = "विस्तारः",
			action = function()
			end
		},
		[4] = {
			name = "विस्तारः",
			action = function()
			end
		},
		[5] = {
			name = "विस्तारः",
			action = function()
			end
		}
	}


	local SearchBarPos = vec3(WindowDimension.x * 0.02, WindowDimension.y * 0.1, 80)
	local SearchBarDimen = vec3(WindowDimension.x, WindowDimension.y * 0.05, 30)
	local RoundedCircle = Com.Canvas:New(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1))
	local circlePImageSize = vec2(40, 40)
	local SearchBarPlainText = {}
	local function searchBar()
		local searchTextEdit = Com.VLayout:New(0)
		local area = Com.AreaObject:New(vec3(10, 10, 10), vec3(10, 10, 1))
		local searchBar = Com.PlainTextLineEditObject:New(vec3(200, 400, 20), vec3(100, 100, 1),
			Com.GetFont("font", "Large"), 100)
		searchBar:Update(vec3(200, 400, 20), vec3(100, 100, 1), "\n", 20, 1)
		searchTextEdit:AddComponents({ searchBar, area }, { 0.9, 0.05 })
		searchTextEdit:Update(vec3(WindowDimension.x * 0.02, WindowDimension.y * 0.1, 30),
			vec3(WindowDimension.x * 0.8, WindowDimension.y * 0.05, 30))
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
		SearchBarPlainText = searchBar
	end
	searchBar()

	local SuggestionPos = vec3(SearchBarPos.x + 0.1 * SearchBarDimen.x, SearchBarPos.y + SearchBarDimen.y, SearchBarPos.z)
	local SuggestionDimen = 0.8 * SearchBarDimen
	SuggestionDimen.y = 0.2 * WindowDimension.y
	local SuggestionArea = Com.MaterialVerticalScrollArea:New(SearchBarPos, vec3(SearchBarDimen.x, 200, 1), vec3(SearchBarDimen.x, 200, 1), 20,
		vec2(20, 200), 0.1, 0.3)
	local function scrollArea()
		SuggestionArea:Start()
		local function insideScrollbar()
			local cm = Com.ContextMenu:New(vec3(200, 200, 50), vec3(SuggestionDimen.x, 100, 1),
				Com.GetFont("font", "large"), 10, 100)
			cm:Update(vec3(100, 100, 30), nil, vec3(SuggestionDimen.x - 20, 30, 1), ContextMenuEntries_Run)
			SuggestionArea:SetScrollableComponent(cm)
			SuggestionArea:Update(vec3(100, 100, 30), vec3(100, 100, 1))
		end
		insideScrollbar()
		SuggestionArea:Update(SuggestionPos, SuggestionDimen)
		SuggestionArea:End()
	end
	scrollArea()
	SuggestionArea:Update(vec3(0), vec3(0))

	Com.NewComponent_Event()
	ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
		function()
			if E.is_mousepress_event() and E.is_left_button_pressed() then
				if SearchBarPlainText.mTextInputStarted then
					SuggestionArea:Update(SuggestionPos, SuggestionDimen)
				else
					SuggestionArea:Update(vec3(0), vec3(0))
				end
			end	
		end
	)

	Com.NewComponent_SingleTimeDispatch()
	ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
		function()
			TopBar.CurrentBrushId = 2
			TopBar:Bind()
			local startingY = -WindowDimension.y + TopBarSizeFactor * WindowDimension.y * 1.8
			local startingX = -WindowDimension.x
			local endingX = WindowDimension.x * 2
			local endingY = WindowDimension.y + TopBarSizeFactor * WindowDimension.y
			TopBar:Paint(vec4(startingX, startingY, endingX, endingY), apricot_color,
				vec4(1.2, 1, 1, 0.8), endingX, endingY, 1)

			RoundedCircle.CurrentBrushId = 2
			RoundedCircle:Bind()
			RoundedCircle:Paint(vec4(0, 0, circlePImageSize.x, circlePImageSize.y), apricot_color,
				vec4(1.8, 1, 1, 0.8), circlePImageSize.x, circlePImageSize.y, 1)
		end
	)
end
