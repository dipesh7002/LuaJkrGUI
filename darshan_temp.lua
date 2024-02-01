require "mainh"


-- LoadMainH()
local localInv = { x = 1, y = 1, z = 1 }
local globalInv = { x = 1, y = 1, z = 1 }

Com.DrawableArea = {
	mComponentObject = nil,
	mPainterImage = nil,
	mIpClear = nil,
	mIpPainter = nil,
	mImage = nil,
	mImageLabel = nil,
	mCanvasSize_2f = nil,
	mPosition_3f = nil,
	mDimension_3f = nil,
	mPainterBrushes = nil,
	mCurrentPainterBrushIndex = nil,
	mCurrentPainterBrushDimension = nil,
	mCurrentColor = nil,
	New = function(self, inPosition_3f, inDimension_3f, inCanvasSize_2f, inShouldNotReadEvents, inClearPainter,
		     inFirstPainter)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self

		Obj.mPainterImage = Jkr.Components.Abstract.PainterImageObject:New(inCanvasSize_2f.x,
			inCanvasSize_2f.y)

		Obj.mIpClear = inClearPainter
		Obj.mIpClear:RegisterImage(Obj.mPainterImage)
		Obj.mIpPainter = inFirstPainter

		Obj.mImage = Jkr.Components.Abstract.ImageObject:New(inCanvasSize_2f.x, inCanvasSize_2f.y)
		Obj.mImageLabel = Com.ImageLabelObject:NewExisting(Obj.mImage, inPosition_3f,
			inDimension_3f)
		Obj.mCanvasSize_2f = inCanvasSize_2f
		Obj.mComponentObject = Jkr.ComponentObject:New(inPosition_3f, inDimension_3f)


		Obj.mPainterBrushes = {}
		Obj.mPainterBrushes[#Obj.mPainterBrushes + 1] = Obj.mIpClear
		Obj.mPainterBrushes[#Obj.mPainterBrushes + 1] = Obj.mIpPainter
		Obj.mCurrentPainterBrushIndex = 2
		Obj.mCurrentPainterBrushDimension = vec2(50, 50)
		Obj.mCurrentColor = vec4(1, 0, 0.1, 1)
		Obj.mCurrentLocalBrushDimen = vec2(0.9, 0.9)
		Obj.mCurrentParams = vec4(0.5, 0.5, 0.5, 0.5)

		Obj.mClearColor = vec4(1, 1, 1, 1)

		if not inShouldNotReadEvents then
			Com.NewComponent_Event()
			ComTable_Event[com_evi] = Jkr.Components.Abstract.Eventable:New(
				function()
					if E.is_keypress_event() then
						if E.is_key_pressed(Key.SDLK_UP) then
							Obj.mCurrentPainterBrushDimension.x = Obj
							    .mCurrentPainterBrushDimension.x + 10
							Obj.mCurrentPainterBrushDimension.y = Obj
							    .mCurrentPainterBrushDimension.y + 10
						elseif E.is_key_pressed(Key.SDLK_DOWN) then
							if Obj.mCurrentPainterBrushDimension.x - 10 > 0 then
								Obj.mCurrentPainterBrushDimension.x = Obj
								    .mCurrentPainterBrushDimension.x - 10
								Obj.mCurrentPainterBrushDimension.y = Obj
								    .mCurrentPainterBrushDimension.y - 10
							end
						end
					end
				end
			)

			Com.NewComponent_Update()
			ComTable_Update[com_upd] = Jkr.Components.Abstract.Updatable:New(
				function()
					local pdi = Obj.mCurrentPainterBrushDimension
					local cc = Obj.mClearColor
					local curc = Obj.mCurrentColor
					if E.is_left_button_pressed_continous() then
						local m = E.get_mouse_pos()
						local isInsideImage = m.x > Obj.mPosition_3f.x and
						    m.y > Obj.mPosition_3f.y
						if isInsideImage then
							if E.is_key_pressed_continous(Key.SDL_SCANCODE_LSHIFT) then
								Com.NewComponent_SingleTimeDispatch()
								ComTable_SingleTimeDispatch[com_sdisi] =
								    Jkr.Components
								    .Abstract
								    .Dispatchable
								    :New(
									    function()
										    Obj:Bind()
										    Obj:PaintByPosition(
											    m,
											    vec4(
												    pdi.x,
												    pdi.y,
												    1,
												    1),
											    vec4(
												    cc.x,
												    cc.y,
												    cc.z,
												    cc.w))
									    end
								    )
							else
								Com.NewComponent_SingleTimeDispatch()
								ComTable_SingleTimeDispatch[com_sdisi] =
								    Jkr.Components
								    .Abstract
								    .Dispatchable
								    :New(
									    function()
										    Obj:BindBrush()
										    Obj:PaintByPosition(
											    m,
											    vec4(
												    pdi.x,
												    pdi.y,
												    Obj.mCurrentPainterBrushDimension
												    .x,
												    Obj.mCurrentPainterBrushDimension
												    .y),
											    vec4(
												    curc.x,
												    curc.y,
												    curc.z,
												    curc.w))
									    end
								    )
							end
						end
					end
				end
			)
		end
		return Obj
	end,
	Update = function(self, inPosition_3f, inDimension_3f)
		self.mImageLabel:Update(inPosition_3f, inDimension_3f)
		self.mComponentObject:Update(inPosition_3f, inDimension_3f)
		self.mPosition_3f = inPosition_3f
		self.mDimension_3f = inDimension_3f
	end,
	Bind = function(self)
		self.mIpClear:BindImage()
		self.mIpClear:BindPainter()
	end,
	BindBrush = function(self)
		self.mIpClear:BindImage()
		self.mPainterBrushes[self.mCurrentPainterBrushIndex]:BindPainter()
	end,
	Paint = function(self, inColor, x, y, w, d)
		self.mIpClear:PaintEXT(vec4(x, y, w, d), inColor, vec4(1), self.mImage, self.mIpClear,
			w, d, globalInv.z)
	end,
	PaintByPosition = function(self, inPositionToDraw_2f, inBrushDimension_2f, inColor_4f)
		local localPos = vec2(inPositionToDraw_2f.x - self.mPosition_3f.x,
			inPositionToDraw_2f.y - self.mPosition_3f.y)
		local canvasSize = self.mCanvasSize_2f
		local imageSize = vec2(self.mDimension_3f.x, self.mDimension_3f.y)
		local factor = vec2(imageSize.x / canvasSize.x, imageSize.y / canvasSize.y)
		local x, y = localPos.x / factor.x, localPos.y / factor.y
		self.mPainterBrushes[self.mCurrentPainterBrushIndex]:PaintEXT(
			vec4(x - inBrushDimension_2f.x / 2, y - inBrushDimension_2f.y / 2, inBrushDimension_2f.x,
				inBrushDimension_2f.y), inColor_4f,
			self.mCurrentParams, self.mImage, self.mIpClear, Int(inBrushDimension_2f.x),
			Int(inBrushDimension_2f.y), 1)
	end,
	Clear = function(self, inColor)
		local width, height = self.mCanvasSize_2f.x, self.mCanvasSize_2f.y
		local x, y = 1, 1
		while width / (x * globalInv.x) >= 1 do
			x = x * 2
		end
		while height / (y * globalInv.y) >= 1 do
			y = y * 2
		end

		print("Invocations:", x, y)
		self.mIpClear:PaintEXT(vec4(0, 0, 0.4, 0.4), inColor, vec4(0), self.mImage, self.mIpClear,
			x, y, globalInv.z)
	end,
	ReregisterImage = function(self)
		self.mIpClear:RegisterImage(self.mPainterImage)
	end
}


Darshan = {}

Darshan.TextEditor = function()
	ImagePreload = Jkr.Components.Abstract.ImageObject:New(0, 0, "icons_material/4k/outline.png")


	local Window = Com.MaterialWindow:New(P(400, 100, 75), D(200, 10, 1), P2(200, 20), "Fuck You", Font)
	local str = "\n"
	local from = { mPosition_3f = P(0, 400, 50), mDimension_3f = D(200, 200, 1) }
	local to = { mPosition_3f = P(100, 100, 50), mDimension_3f = D(200, 100, 1) }
	Window:Start()
	local Inside = function()
		local TextObj = Com.PlainTextEditObject:New(P(0, 0, 0), D(0, 0, 0), Font, 8, 30, 30)
		TextObj:Update(P(0, 0, 0), D(200, 500, 1), str, 20, 1)
		local materialVerticalScrollArea = Com.MaterialVerticalScrollArea:New(P(200, 200, 50),
			P(200, 200, 1), D(200, 200, 1), 20, P2(20, 200), 0.1, 0.3)
		materialVerticalScrollArea:SetScrollableComponent(TextObj)
		Window:SetCentralComponent(materialVerticalScrollArea)
	end
	Inside()
	Window:End()
	Com.AnimateSingleTimePosDimen(Window, from, to, 0.1)
end

Darshan.CanvasExperiment = function()
	IpClear = Jkr.Components.Util.ImagePainter:New("cache/ClearD.Compute", false,
		Jkr.GLSL.ClearD, localInv.x, localInv.y, localInv.z)
	IpPainter = Jkr.Components.Util.ImagePainter:New("cache/RoundedCircleD.Compute", false,
		Jkr.GLSL.RoundedCircleD, localInv.x, localInv.y, localInv.z)
	local DrawWableWindow = Com.MaterialWindow:New(P(400, 100, 80), D(500, 500, 1), P2(200, 20), "Canvas",
		Font)
	DrawWableWindow:Start()
	local DrawWableInside = function()
		local Area = Com.AreaObject:New(P(400, 100, 80), D(200, 10, 1))
		Area:SetFillColor(vec4(0.9, 0.9, 0.9, 1))
		Canvas = Com.DrawableArea:New(P(0, 0, 80), D(0, 0), vec2(500, 500), false, IpClear, IpPainter)
		local Stack = Com.StackLayout:New(0)
		Stack:AddComponents({ Area, Canvas })
		DrawWableWindow:SetCentralComponent(Stack)
	end
	DrawWableInside()
	DrawWableWindow:End()

	Com.NewComponent_SingleTimeDispatch()
	ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
		function(self)
			Canvas:Bind()
			Canvas:Clear(vec4(0, 1, 1, 1))
		end
	)
end

Darshan.SanskritDictionary = function()
	LoadMaterialComponents(false)
	BigFont = Com.GetFont("font", "Large")
	local apricot_color = vec4(0.99, 0.83, 0.73, 1)

	local TopBar = Com.Canvas:New(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1))
	local TopBarSizeFactor = 0.08
	local hsizeTabBar = 300
	local function topBar()
		TopBar:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
		TopBar:AddPainterBrush(Com.GetCanvasPainter("RoundedRectangle", false))
		TopBar:MakeCanvasImage(WindowDimension.x, WindowDimension.y * TopBarSizeFactor)

		local Vlayout = Com.VLayout:New(0)
		local PageLayout = Com.VLayout:New(0)
		Vlayout:AddComponents({ TopBar, PageLayout }, { TopBarSizeFactor, 1 - TopBarSizeFactor })
		Vlayout:Update(P(0, 0, 80), vec3(hsizeTabBar, WindowDimension.y, 1))

		local topText = "संस्कृतम्"
		local tB = Com.TextLabelObject:New(topText,
			vec3(WindowDimension.x / 4 - BigFont:GetDimension(topText).x / 2, 0.01 * WindowDimension.y,
				20),
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


	local RoundedCircle = Com.Canvas:New(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1))
	local circlePImageSize = vec2(40, 40)
	local function searchBar()
		local ha = Com.VLayout:New(0)
		local area = Com.AreaObject:New(vec3(10, 10, 10), vec3(10, 10, 1))
		local searchBar = Com.PlainTextLineEditObject:New(vec3(200, 400, 20), vec3(100, 100, 1),
			Com.GetFont("font", "Large"), 100)
		searchBar:Update(vec3(200, 400, 20), vec3(100, 100, 1), "\n", 20, 1)
		ha:AddComponents({ searchBar, area }, { 0.9, 0.05 })
		ha:Update(vec3(WindowDimension.x * 0.02, WindowDimension.y * 0.1, 30),
			vec3(WindowDimension.x * 0.8, WindowDimension.y * 0.05, 30))

		local HLayout = Com.HLayout:New(5)
		local Icon = Com.ImageLabelObject:New("icons_material/search/baseline.png", vec3(100, 100, 30), vec3(10, 10, 1))
		Icon:TintColor(vec4(0, 0, 0, 1))
		HLayout.Update = function (self, inPosition_3f, inDimension_3f)
			Com.HLayout.Update(self, inPosition_3f, inDimension_3f)
			local pos = vec3(inPosition_3f.x, inPosition_3f.y - inDimension_3f.y / 4, inPosition_3f.z)
			self.mComponents[1]:Update(pos, vec3(40, 40, 1))
			-- local ipos = vec3(pos.x, pos.y, pos.z - 1)
			-- Icon:Update(ipos, vec3(circlePImageSize.x, circlePImageSize.y, 1))
		end

		-- local ipos = vec3(pos.x, pos.y, pos.z - 1)
		-- Icon:Update(ipos, vec3(circlePImageSize.x, circlePImageSize.y, 1))

		RoundedCircle:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
		RoundedCircle:AddPainterBrush(Com.GetCanvasPainter("Circle", false))
		RoundedCircle:MakeCanvasImage(circlePImageSize.x, circlePImageSize.y)
		HLayout:AddComponents({ RoundedCircle.mImageLabel, ha, Com.HLayout:New(0) }, { 0.1, 0.8, 0.1 })
		HLayout:Update(vec3(WindowDimension.x * 0.02, WindowDimension.y * 0.1, 30),
			vec3(WindowDimension.x, WindowDimension.y * 0.05, 30))
	end
	searchBar()

	local function scrollArea()
		local sc = Com.MaterialVerticalScrollArea:New(P(200, 200, 50), P(200, 200, 1), D(200, 200, 1), 20,
			P2(20, 200), 0.1, 0.3)
		sc:Start()
		local function insideScrollbar()
			local cm = Com.ContextMenu:New(vec3(200, 200, 50), vec3(100, 100, 1),
				Com.GetFont("font", "large"), 10, 100)
			cm:Update(vec3(100, 100, 30), nil, vec3(100, 30, 1), ContextMenuEntries_Run)
			sc:SetScrollableComponent(cm)
			sc:Update(vec3(100, 100, 30), vec3(100, 100, 1))
		end
		insideScrollbar()
		sc:Update(vec3(100, 100, 30), vec3(100, 100, 1))
		sc:End()
	end
	-- scrollArea()

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
			RoundedCircle:Paint(vec4(0, 0, circlePImageSize.x, circlePImageSize.y), apricot_color, vec4(1.8, 1, 1, 0.8), circlePImageSize.x, circlePImageSize.y, 1)
		end
	)

end

LoadDarshan = function()
	Darshan.SanskritDictionary()
	-- Darshan.CanvasExperiment()
	-- LoadMainH()
	-- Darshan.TextEditor()
end
