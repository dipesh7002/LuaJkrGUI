require "mainh"

Jkr.GLSL.ClearD = [[
to_draw_at.x = to_draw_at.x + int(push.mPosDimen.x);
to_draw_at.y = to_draw_at.y + int(push.mPosDimen.y);
imageStore(storageImage, to_draw_at, vec4(push.mColor.x, push.mColor.y, push.mColor.z, push.mColor.w));
]]

Jkr.GLSL.RoundedCircleD = [[
int xx = int(push.mPosDimen.x);
int yy = int(push.mPosDimen.y);
to_draw_at.x = to_draw_at.x + xx;
to_draw_at.y = to_draw_at.y + yy;
vec4 pure_color = push.mColor;

vec2 imageko_size = vec2(push.mPosDimen.z, push.mPosDimen.w); // GlobalInvocations
float x_cartesian = (float(gl_GlobalInvocationID.x) - float(imageko_size.x) / float(2)) / (float((imageko_size.x) / float(2)));
float y_cartesian = (float(imageko_size.y) / float(2) - float(gl_GlobalInvocationID.y)) / (float(imageko_size.y) / float(2));

vec2 xy_cartesian = vec2(x_cartesian, y_cartesian);
vec2 center = vec2(0, 0);
vec2 hw = vec2(0.9, 0.9);
float radius = hw.x;

float color = distance(xy_cartesian, center) - radius;
color = smoothstep(-1, 1, -color);

vec4 old_color = imageLoad(storageImage, to_draw_at);
vec4 final_color = vec4(push.mColor.x * color, push.mColor.y * color, push.mColor.z * color, push.mColor.w * color);
//final_color = mix(final_color, old_color, push.mParam.w);

if (color >= 0.7)
{
	imageStore(storageImage, to_draw_at, pure_color);
}
]]


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
	IpPainter = Jkr.Components.Util.ImagePainter:New("cache/RoundedCircleD.Compute", true,
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
	Font = Jkr.FontObject:New("font.ttf", FontSize(20))
	local apricot_color = vec4(0.98, 0.81, 0.69, 1)

	IpClear = Jkr.Components.Util.ImagePainter:New("cache/ClearD.Compute", false,
		Jkr.GLSL.ClearD, localInv.x, localInv.y, localInv.z)
	IpPainter = Jkr.Components.Util.ImagePainter:New("cache/RoundedCircleD.Compute", true,
		Jkr.GLSL.RoundedCircleD, localInv.x, localInv.y, localInv.z)

	local TopBarSizeFactor = 0.08
	local TopBar = Com.Canvas:New(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1))
	TopBar:AddPainterBrush(IpClear)
	local Vlayout = Com.VLayout:New(0)
	local PageLayout = Com.VLayout:New(0)
	Vlayout:AddComponents({ TopBar, PageLayout }, { TopBarSizeFactor, 1 - TopBarSizeFactor })
	TopBar:MakeCanvasImage(WindowDimension.x, WindowDimension.y * TopBarSizeFactor)
	Vlayout:Update(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1))


	Com.NewComponent_SingleTimeDispatch()
	ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
		function ()
			TopBar:Bind()	
			TopBar:Paint(vec4(0, 0, WindowDimension.x, WindowDimension.y * TopBarSizeFactor), apricot_color, vec4(1, 1, 1, 1))
		end
	)

	local topText = "संस्कृतम्"
	local tB = Com.TextLabelObject:New(topText, vec3(WindowDimension.x / 2 - Font:GetDimension(topText).x / 2, 0.02 * WindowDimension.y, 20), Font)

	-- local TopBarSizeFactor = 0.08
	-- TopBar = Com.DrawableArea:New(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1),
	-- 	vec2(WindowDimension.x, TopBarSizeFactor * WindowDimension.y), true, IpClear, IpPainter)
	-- Vlayout:AddComponents({ TopBar, PageLayout }, { TopBarSizeFactor, 1 - TopBarSizeFactor })
	-- Vlayout:Update(P(0, 0, 80), vec3(WindowDimension.x, WindowDimension.y, 1))


	-- Com.NewComponent_SingleTimeDispatch()
	-- ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
	-- 	function()
	-- 		TopBar:Bind()
	-- 		TopBar:Clear(vec4(1, 1, 1, 1))
	-- 		-- TopBar:Clear(apricot_color)
	-- 		TopBar:Bind()
	-- 		TopBar:PaintByPosition(vec4(1), vec4(WindowDimension.x * 2, WindowDimension.y, 1, 1), apricot_color)
	-- 	end
	-- )
end

LoadDarshan = function()
	Darshan.SanskritDictionary()
	-- Darshan.CanvasExperiment()
	-- Darshan.TextEditor()
end

