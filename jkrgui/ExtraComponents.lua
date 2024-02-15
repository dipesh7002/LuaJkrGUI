require "jkrgui.PrimitiveComponents"

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
		self.mPainterImage:Register(self.mPainterBrushes[1])
		-- self.mPainterBrushes[1]:RegisterImage(self.mPainterImage)	
		self.mImage = Jkr.Components.Abstract.ImageObject:New(inWidth, inHeight)
		self.mImageLabel = Com.ImageLabelObject:NewExisting(self.mImage, self.mPosition_3f, self.mDimension_3f)
	end,
	Bind = function (self)
		-- self.mPainterBrushes[1]:BindImage()
		self.mPainterBrushes[self.CurrentBrushId]:BindPainter()
		self.mPainterBrushes[1]:BindImageFromImage(self.mPainterImage)
	end,
	Paint = function (self, inBrushPosDimen_4f, inColor_4f, inParam_4f, inX, inY, inZ)
		self.mPainterBrushes[self.CurrentBrushId]:PaintEXT(inBrushPosDimen_4f, inColor_4f, inParam_4f, self.mImage, self.mPainterImage, inX, inY, inZ)
	end,
	Update = function(self, inPosition_3f, inDimension_3f)
		self.mPosition_3f = inPosition_3f
		self.mDimension_3f = inDimension_3f
		self.mImageLabel:Update(inPosition_3f, inDimension_3f)
	end,
	PrintPicture = function (self)
		local vector_image = self.mPainterImage:GetVectorFloatSingleChannel()
		local vector_size = vector_image:size()
		print("SIZE OF IMAGE:", vector_image:size())
		for i = 1, vector_size, 1 do
			io.write(vector_image[i], ",")
		end
	end
}



