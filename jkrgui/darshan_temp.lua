require "jkrgui.jkrgui"
require "jkrgui.MaterialComponents"

Jkr.GLSL.ClearD = [[
to_draw_at.x = to_draw_at.x + int(push.mPosDimen.x);
to_draw_at.y = to_draw_at.y + int(push.mPosDimen.y);
imageStore(storageImage, to_draw_at, vec4(push.mColor.x, push.mColor.y, push.mColor.z, push.mColor.w));
]]

local localInv = {x = 1, y = 1, z = 1}
local globalInv = {x = 1, y = 1, z = 1}

Com.DrawableArea = {
	mPainterImage = nil, 
	mIpClear =  nil,
	mIpPainter = nil,
	mImage = nil,
	mImageLabel = nil,
	New = function (self, inPosition_3f, inDimension_3f, inCanvasSize_2f)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		Obj.mPainterImage = Jkr.Components.Abstract.PainterImageObject:New(inCanvasSize_2f.x, inCanvasSize_2f.y)
		Obj.mIpClear = Jkr.Components.Util.ImagePainter:New("cache/ClearD.Compute", true, Jkr.GLSL.ClearD, localInv.x, localInv.y, localInv.z)
		Obj.mIpClear:RegisterImage(Obj.mPainterImage)
		Obj.mIpPainter = Jkr.Components.Util.ImagePainter:New("cache/RoundedCircle.Compute", false, Jkr.GLSL.RoundedCircle, localInv.x, localInv.y, localInv.z)
		Obj.mImage = Jkr.Components.Abstract.ImageObject:New(inCanvasSize_2f.x, inCanvasSize_2f.y)
		Obj.mImageLabel = Com.ImageLabelObject:NewExisting(Obj.mImage, inPosition_3f, inDimension_3f)

		return Obj
	end,
	Update = function (self, inPosition_3f, inDimension_3f)
		self.mImageLabel:Update(inPosition_3f, inDimension_3f)
	end,
	Paint = function (self, inColor, x, y, w, d)
		Com.NewComponent_SingleTimeDispatch()
		ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
			function ()
				self.mIpClear:BindImage()
				self.mIpClear:BindPainter()
				self.mIpClear:PaintEXT(vec4(x, y, 0.4, 0.4), inColor, vec4(1), self.mImage, self.mIpClear, w, d, globalInv.z)
			end
		)
	end,
	Clear = function(self, inColor)
		Com.NewComponent_SingleTimeDispatch()
		ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(
			function ()
				self.mIpClear:BindImage()
				self.mIpClear:BindPainter()
				self.mIpClear:PaintEXT(vec4(0, 0, 0.4, 0.4), inColor, vec4(0), self.mImage, self.mIpClear, globalInv.x, globalInv.y, globalInv.z)
			end
		)
	end

}

