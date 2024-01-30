require "jkrgui.jkrgui"
require "jkrgui.MaterialComponents"

Jkr.GLSL.ClearD = [[
to_draw_at.x = to_draw_at.x + int(push.mPosDimen.x);
to_draw_at.y = to_draw_at.y + int(push.mPosDimen.y);
imageStore(storageImage, to_draw_at, vec4(push.mColor.x, push.mColor.y, push.mColor.z, push.mColor.w));
]]

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
	New = function(self, inPosition_3f, inDimension_3f, inCanvasSize_2f)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		Obj.mPainterImage = Jkr.Components.Abstract.PainterImageObject:New(inCanvasSize_2f.x,
			inCanvasSize_2f.y)
		Obj.mIpClear = Jkr.Components.Util.ImagePainter:New("cache/ClearD.Compute", false,
			Jkr.GLSL.ClearD, localInv.x, localInv.y, localInv.z)
		Obj.mIpClear:RegisterImage(Obj.mPainterImage)
		Obj.mIpPainter = Jkr.Components.Util.ImagePainter:New("cache/RoundedCircle.Compute", false,
			Jkr.GLSL.RoundedCircle, localInv.x, localInv.y, localInv.z)
		Obj.mImage = Jkr.Components.Abstract.ImageObject:New(inCanvasSize_2f.x, inCanvasSize_2f.y)
		Obj.mImageLabel = Com.ImageLabelObject:NewExisting(Obj.mImage, inPosition_3f,
			inDimension_3f)
		Obj.mCanvasSize_2f = inCanvasSize_2f

		Obj.mComponentObject = Jkr.ComponentObject:New(inPosition_3f, inDimension_3f)

		Com.NewComponent_Update()
		ComTable_Update[com_upd] = Jkr.Components.Abstract.Updatable:New(
			function()
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
									    Obj:PaintByPosition(m,
										    vec4(1, 1, 1, 1),
										    vec4(0, 0, 0, 1))
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
									    Obj:Bind()
									    Obj:PaintByPosition(
										    m,
										    vec4(1, 1, 1, 1),
										    vec4(1, 0, 0, 1))
								    end
							    )
						end
					end
				end
			end
		)
		print(#ComTable_Update)
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
	Paint = function(self, inColor, x, y, w, d)
		self.mIpClear:PaintEXT(vec4(x, y, 0.4, 0.4), inColor, vec4(1), self.mImage, self.mIpClear,
			w, d, globalInv.z)
	end,
	PaintByPosition = function(self, inPositionToDraw_2f, inBrushDimension_4f, inColor_4f)
		local localPos = vec2(inPositionToDraw_2f.x - self.mPosition_3f.x,
			inPositionToDraw_2f.y - self.mPosition_3f.y)
		local canvasSize = self.mCanvasSize_2f
		local imageSize = vec2(self.mDimension_3f.x, self.mDimension_3f.y)
		local factor = vec2(imageSize.x / canvasSize.x, imageSize.y / canvasSize.y)
		local x, y = localPos.x / factor.x, localPos.y / factor.y
		self.mIpClear:PaintEXT(vec4(x, y, inBrushDimension_4f.z, inBrushDimension_4f.w), inColor_4f,
			vec4(1), self.mImage, self.mIpClear, Int(inBrushDimension_4f.x),
			Int(inBrushDimension_4f.y), 1)
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
}


LoadDarshan = function()
	local DrawWableWindow = Com.MaterialWindow:New(P(400, 100, 75), D(500, 500, 1), P2(200, 20), "Canvas",
		Font)
	DrawWableWindow:Start()
	local DrawWableInside = function()
		local Area = Com.AreaObject:New(P(400, 100, 80), D(200, 10, 1))
		Area:SetFillColor(vec4(0.9, 0.9, 0.9, 1))
		Canvas = Com.DrawableArea:New(P(0, 0, 0), D(0, 0), vec2(20, 20))
		local Stack = Com.StackLayout:New(1)
		Stack:AddComponents({ Area, Canvas })
		DrawWableWindow:SetCentralComponent(Stack)
	end
	DrawWableInside()
	DrawWableWindow:End()

	Com.NewComponent_SingleTimeDispatch()
	ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
		function(self)
			Canvas:Bind()
			-- Canvas:Paint(vec4(0, 0, 0, 1), 0, 0, 20, 20)
			Canvas:Clear(vec4(0, 0, 0, 1))
			Canvas:Paint(vec4(0, 0, 0, 1), 0, 0, 1, 10)
			Canvas:Paint(vec4(1, 0, 0, 1), 5, 5, 1, 1)
			Canvas:Paint(vec4(1, 0, 0, 1), 19, 19, 1, 1)
		end
	)
end
