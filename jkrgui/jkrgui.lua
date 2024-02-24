local AlternativeTextRenderer = true
function utf8.sub(s, i, j)
	i = utf8.offset(s, i)
	j = utf8.offset(s, j + 1) - 1
	return string.sub(s, i, j)
end
GetWindowDimensions = get_window_dimensions
GetIdentityMatrix = get_identity_matrix
Generator = generator
Shapes = shapes
Translate = translate
FillType = fill_type
Int = math.floor
Jkr = r;
Jkr3d = r3d;
Jmath3D = jmath3D
E = event_manager -- EventManager
S = Jkr.sh -- Shape Renderer
S.Add = S.add
S.AddImage = S.add_image
S.CopyImage = S.copy_image
S.Bind = S.bind
S.BindFillMode = S.bind_fill_mode
S.Draw = S.draw
S.BindImage = S.bind_image
S.Update = S.update
L = Jkr.ln -- Line Renderer
L.Add = L.add
L.Update = L.update
L.Draw = L.draw
L.Bind = L.bind
T = Jkr.bt -- Text Renderer
T.SetCurrentFace = T.set_current_face
T.Add = T.add
T.AddFontFace = T.add_font_face
T.Bind = T.bind
T.Draw = T.draw
T.SetTextProperty = T.set_text_property
T.GetTextDimension = T.get_text_dimension
T.Update = T.update
TextH = text_horizontal
TextV = text_vertical
vec2 = vec2
uvec2 = uvec2
vec3 = vec3
vec4 = vec4
Print_vec3 = function(inVec3)
	print(string.format("v(%f, %f, %f)", inVec3.x, inVec3.y, inVec3.z))
end
Key = key
require "jkrgui.Config" -- #include "Config" vane jastai C ma
Time = 0                                -- Increments each frame
WindowDimension = GetWindowDimensions() -- Can get Window dimensions just by doing WindowDimension.x, WindowDimension.y
DisplayDimension = get_display_dimensions()
local fY = DisplayDimension.y / 1080
local fX = DisplayDimension.x / 1920
local f = 0

if fX > fY then
	f = fX
else
	f = fY
end
-- To be called at Update Callback
function FrameUpdate()
	Time = Time + 1
	WindowDimension = GetWindowDimensions()
	-- WindowDimension = vec2()
end

function FontSize(inSize)
	return Int(inSize * f)
end

function P(inx, iny, ind)
	inx = inx * f
	iny = iny * f
	return vec3(inx, iny, ind)
end

function P2(inx, iny)
	inx = inx * f
	iny = iny * f
	return vec2(inx, iny)
end

function D(inx, iny, inz)
	inx = inx * f
	iny = iny * f
	return vec3(inx, iny, 1)
end

Jkr.FontObject = {
	mPath = " ",
	mId = 0,
	mSize = 0,
	New = function(self, inPath, inSize)
		local Object = {
			mPath = " ",
			mId = 0,
			mSize = 0
		}
		setmetatable(Object, self)
		self.__index =
			self -- Elle garne k ho vane Returned object bata Obj.GetDimension etc garna milxa
		Object.mPath = inPath
		Object.mSize = inSize
		Object.mId = T.AddFontFace(Object.mPath, Object.mSize)
		return Object
	end,
	-- returns vec2
	GetDimension = function(self, inString)
		return T.GetTextDimension(inString, Int(self.mId))
	end,
	GetSubstringWithinDimension = function(self, inString, inDimensionX)
		local i = 0
		local substr1 = utf8.sub(inString, 1, -2)
		while self:GetDimension(substr1).x >= inDimensionX do
			substr1 = utf8.sub(substr1, 1, -2)
			i = i + 1
		end
		return { s = substr1, n = utf8.len(inString) - i }
	end
}

Jkr.ComponentObject = {
	mPosition_3f = vec3(0, 0, 0),
	mDimension_3f = vec3(0, 0, 0),
	mFocus_b = false,
	mBoundedRectId_i = 0,
	mFocusOnHover_b = false,
	TransparentToMouse_b = false,
	ContinousPress = false,
	New = function(self, inPosition_3f, inDimension_3f)
		local Obj = {}
		--("Component Construction")
		setmetatable(Obj, self)
		self.__index = self

		Obj.mPosition_3f = inPosition_3f
		Obj.mDimension_3f = inDimension_3f
		Obj.mClicked_b = false
		Obj.mHovered_b = false
		Obj.TransparentToMouse_b = false
		Obj.ContinousPress = false
		local pos = vec2(Obj.mPosition_3f.x, Obj.mPosition_3f.y)
		local dim = vec2(Obj.mDimension_3f.x, Obj.mDimension_3f.y)
		Obj.mBoundedRectId_i = E.set_bounded_rect(pos, dim, Int(Obj.mPosition_3f.z))
		--("Component Construction Finished")
		return Obj
	end,

	-- This is function that has to run each frame, OR on demand
	Update = function(self, inPosition_3f, inDimension_3f)
		if (inPosition_3f.z ~= self.mPosition_3f.z) then
			E.update_bounded_rect(Int(self.mBoundedRectId_i), vec2(0, 0), vec2(0, 0),
				Int(self.mPosition_3f.z))
			self.mPosition_3f = inPosition_3f
			self.mDimension_3f = inDimension_3f
			local pos = vec2(self.mPosition_3f.x, self.mPosition_3f.y)
			local dim = vec2(self.mDimension_3f.x, self.mDimension_3f.y)
			self.mBoundedRectId_i = E.set_bounded_rect(pos, dim,
				Int(self.mPosition_3f.z))
		else
			self.mPosition_3f = inPosition_3f
			self.mDimension_3f = inDimension_3f
			local pos = vec2(self.mPosition_3f.x, self.mPosition_3f.y)
			local dim = vec2(self.mDimension_3f.x, self.mDimension_3f.y)
			E.update_bounded_rect(Int(self.mBoundedRectId_i), pos, dim,
				Int(self.mPosition_3f.z))
		end
	end,

	Event = function(self)
		if self.TransparentToMouse_b then
			self.mHovered_b = E.is_mouse_within(Int(self.mBoundedRectId_i),
				Int(self.mPosition_3f.z))
		else
			self.mHovered_b = E.is_mouse_on_top(Int(self.mBoundedRectId_i),
				Int(self.mPosition_3f.z))
		end
		if not self.ContinousPress then
			if self.mHovered_b and E.is_mousepress_event() and E.is_left_button_pressed() then
				self.mClicked_b = true
			else
				self.mClicked_b = false
			end
		else
			if self.mHovered_b and E.is_left_button_pressed_continous() then
				self.mClicked_b = true
			else
				self.mClicked_b = false
			end
		end
		self.mHovered_b = self.mHovered_b and not E.is_left_button_pressed_continous()
	end,

	GetTranslationMatrix = function(self)
		local matrix = GetIdentityMatrix()
		local matrix = Translate(matrix, vec3(self.mPosition.x, self.mPosition.y, 0))
		return matrix
	end
}

Jkr.Components = {}
Jkr.Components.Static = {}
Jkr.Components.Abstract = {}
Jkr.Components.Util = {}

Jkr.Components.Static.LineObject = {
	mPositon1 = vec2(0, 0),
	mPosition2 = vec2(0, 0),
	mLine_Id = nil,
	mColor_4f = nil,
	New = function(self, inPosition1_3f, inPosition2_3f)
		local Obj = {
			mPosition1 = vec2(inPosition1_3f.x, inPosition1_3f.y),
			mPosition2 = vec2(inPosition2_3f.x, inPosition2_3f.y),
			mLine_Id = nil,
		}
		setmetatable(Obj, self)
		self.__index = self
		Obj.mLine_Id = L.Add(Obj.mPosition1, Obj.mPosition2, inPosition1_3f.z)
		Obj.mColor_4f = vec4(0, 0, 0, 1)
		return Obj
	end,
	NewBatch = function (self, inLineCount)
		local Obj = {}
		Obj.mColor_4f = vec4(0, 0, 0, 1)
		Obj.mStartId = 0
		Obj.mEndId = 0
		Obj.mLines = {}
		for i = 1, inLineCount, 1 do
			Obj.mLines[#Obj.mLines+1] = L.Add(vec2(0), vec2(0), 0)	
		end
		Obj.mStartId = Obj.mLines[1]
		Obj.mEndId = Obj.mLines[#Obj.mLines]

		Obj.Draw = function (self)
			L.Bind()			
			L.Draw(Obj.mColor_4f, Int(WindowDimension.x), Int(WindowDimension.y), Obj.mStartId, Obj.mEndId, GetIdentityMatrix())
		end

		Obj.Update = function (self, inPosition1_3f, inPosition2_3f, inId)
			L.Update(inId, vec2(inPosition1_3f.x, inPosition1_3f.y), vec2(inPosition2_3f.x, inPosition2_3f.y), inPosition1_3f.z)	
		end
		
		Obj.SetColor = function (self, inColor_4f)
			Obj.mColor_4f = inColor_4f
		end

		return Obj
	end,
	Draw = function(self)
		L.Bind()
		L.Draw(self.mColor_4f, Int(WindowDimension.x), Int(WindowDimension.y), Int(self.mLine_Id),
			Int(self.mLine_Id),
			GetIdentityMatrix())
	end,
	Update = function(self, inPosition1_3f, inPosition2_3f)
		L.Update(Int(self.mLine_Id), vec2(inPosition1_3f.x, inPosition1_3f.y), vec2(inPosition2_3f.x, inPosition2_3f.y),
			inPosition1_3f.z)
	end,
	SetColor = function(self, inColor_4f)
		self.mColor_4f = inColor_4f
	end
}



Jkr.Components.Abstract.ImageObject = {
	mId = nil,
	New = function(self, inWidth, inHeight, inFileName)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		if inFileName then
			Obj.mId = S.AddImage(inFileName)
		else
			Obj.mId = S.AddImage(Int(inWidth), Int(inHeight))
		end
		return Obj
	end
}


Jkr.Components.Static.ShapeObject = {
	mShapeId = nil,
	mImageId = nil,
	mFillColor = nil,
	New = function(self, inPosition_3f, inDimension_3f, inImageObject)
		local Obj = {
			mShapeId = nil,
			mImageId = nil,
			mFillColor = nil
		}

		setmetatable(Obj, self)
		self.__index = self

		-- Obj.mComponentObject = Jkr.ComponentObject:New(inPosition_3f, inDimension_3f)
		local Dimension = vec2(inDimension_3f.x, inDimension_3f.y)
		local rect_gen = Generator(Shapes.rectangle, Dimension)
		Obj.mShapeId = S.Add(rect_gen, inPosition_3f)

		if inImageObject then
			Obj.mImageId = inImageObject.mId
		else
			Obj.mImageId = nil
		end

		Obj.mFillColor = vec4(1, 1, 1, 1)
		return Obj
	end,
	Update = function(self, inPosition_3f, inDimension_3f)
		local Dimension = vec2(inDimension_3f.x, inDimension_3f.y)
		local rect_gen = Generator(Shapes.rectangle, Dimension)
		S.Update(Int(self.mShapeId), rect_gen, inPosition_3f)
	end,
	Event = function(self)
		self.mComponentObject:Event()
	end,
	Draw = function(self)
		S.Bind()
		if self.mImageId then
			S.BindFillMode(FillType.image)
			S.BindImage(self.mImageId)
		else
			S.BindFillMode(FillType.fill)
		end
		S.Draw(self.mFillColor, Int(WindowDimension.x), Int(WindowDimension.y), Int(self.mShapeId),
			Int(self.mShapeId), GetIdentityMatrix())
	end
}

if not AlternativeTextRenderer then
	Jkr.Components.Static.TextObject = {
		mScissorPosition_2f = nil,
		mScissorDimension_2f = nil,
		mString = nil,
		mFont = nil, -- Font Object
		mId = nil,
		mDimension_2f = nil,
		mColor = Theme.Colors.Text.Normal,
		New = function(self, inText, inPosition_3f, inFontObject, inShouldAlignBottom)
			local Obj = {
				mScissorPosition_2f = nil,
				mScissorDimension_2f = nil,
				mString = nil,
				mFont = nil, -- Font Object
				mId = nil,
				mDimension_2f = nil,
				mColor = Theme.Colors.Text.Normal,
			}

			setmetatable(Obj, self)
			self.__index = self

			Obj.mString = inText
			Obj.mPosition_3f = inPosition_3f

			T.SetCurrentFace(inFontObject.mId)
			T.SetTextProperty(TextH.left, TextV.top)
			Obj.mId = T.Add(Obj.mString,
				vec3(Obj.mPosition_3f.x, Obj.mPosition_3f.y, Obj.mPosition_3f.z))
			Obj.mDimension_2f = inFontObject:GetDimension(Obj.mString)

			Obj.mFont = inFontObject

			return Obj
		end,
		GetLength = function(self)
			return self.mId.y
		end,
		Event = function(self)
		end,
		Draw = function(self)
			T.Bind()
			T.Draw(self.mColor, Int(WindowDimension.x), Int(WindowDimension.y),
				Int(self.mId.x),
				Int(self.mId.y), GetIdentityMatrix())
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inString, inShouldAlignBottom)
			tracy.ZoneBeginN("Jkr.TextObject.Update")
			self.mPosition_3f = inPosition_3f
			if (inString) then
				self.mString = inString
			end
			-- Make this Startup Time (Separate Class kinda thing)
			local str = string.rep(" ", self.mId.y)
			T.Update(Int(self.mId.x), str, self.mPosition_3f)
			T.Update(Int(self.mId.x), self.mString, self.mPosition_3f)
			tracy.ZoneEnd()
		end
	}
else
	Jkr.Components.Static.TextObject = {
		mScissorPosition_2f = nil,
		mScissorDimension_2f = nil,
		mString = nil,
		mFont = nil, -- Font Object
		mId = nil,
		mDimension_2f = nil,
		mColor = Theme.Colors.Text.Normal,
		New = function(self, inText, inPosition_3f, inFontObject, inShouldAlignBottom)
			local Obj = {
				mScissorPosition_2f = nil,
				mScissorDimension_2f = nil,
				mString = nil,
				mFont = nil, -- Font Object
				mId = nil,
				mDimension_2f = nil,
				mColor = Theme.Colors.Text.Normal,
				mAlt = AlternativeTextRenderer
			}

			setmetatable(Obj, self)
			self.__index = self

			Obj.mString = inText
			Obj.mPosition_3f = inPosition_3f

			local should_align_button = true
			if inShouldAlignBottom ~= nil then
				should_align_button = inShouldAlignBottom
			end
			Obj.mId = r.balt.add(inFontObject.mId, Obj.mString,
				vec3(Obj.mPosition_3f.x, Obj.mPosition_3f.y, Obj.mPosition_3f.z), should_align_button)

			Obj.mFont = inFontObject

			return Obj
		end,
		GetLength = function(self)
			return self.mId.y
		end,
		Event = function(self)
		end,
		Draw = function(self)
			S.Bind()
			S.BindFillMode(FillType.image)
			r.balt.draw(self.mColor, Int(WindowDimension.x), Int(WindowDimension.y),
				self.mId,
				GetIdentityMatrix())
		end,
		Update = function(self, inPosition_3f, inDimension_3f, inString, inShouldAlignBottom)
			tracy.ZoneBeginN("Jkr.TextObject.Update")
			self.mPosition_3f = inPosition_3f
			if (inString) then
				self.mString = inString
			end
			local should_align_button = true
			if inShouldAlignBottom ~= nil then
				should_align_button = inShouldAlignBottom
			end
			if inString then
				r.balt.update(self.mId, Int(self.mFont.mId), self.mPosition_3f, self.mString, should_align_button)
			else
				r.balt.update_pos_only(self.mId, Int(self.mFont.mId), self.mPosition_3f, self.mString,
					should_align_button)
			end
			tracy.ZoneEnd()
		end,
	}
end

Jkr.Components.Abstract.PainterImageObject = {
	mImage = nil,
	New = function(self, inWidth, inHeight)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		Obj.mImage = Jkr.painter_image(Int(inWidth), Int(inHeight))
		return Obj
	end,
	Register = function(self, inCompatibleImagePainter)
		self.mImage:register(inCompatibleImagePainter.mPainter)
	end,
	GetVectorUInt = function(self)
		return self.mImage:image_to_vector_uint()
	end,
	GetVectorFloatSingleChannel = function(self)
		return self.mImage:image_to_vector_single_channel_float()
	end
}

Jkr.Components.Util.ImagePainter = {
	mPainter = nil,
	mPainterRegisteredImageObject = nil,
	New = function(self, inFileName, inStore_b, inGLSL, inX, inY, inZ)
		local Obj = {}
		setmetatable(Obj, self)
		self.__index = self
		Obj.mPainter = Jkr.image_painter(inFileName, inGLSL, vec3(inX, inY, inZ))

		if inStore_b then
			Obj.mPainter:store()
		else
			Obj.mPainter:load()
		end
		return Obj
	end,
	RegisterImage = function(self, inPainterImageObject)
		self.mPainter:register_image(inPainterImageObject.mImage)
		self.mPainterRegisteredImageObject = inPainterImageObject
	end,
	BindImage = function(self)
		self.mPainter:bind_image()
	end,
	BindImageFromImage = function(self, inPainterImageObject)
		self.mPainter:bind_image_from_image(inPainterImageObject.mImage)
	end,
	BindPainter = function(self)
		self.mPainter:bind()
	end,
	Paint = function(self, inPosDimen_4f, inColor_4f, inParam_4f, inImageObject, inPainterWithRegisteredImage)
		self.mPainter:paint(inPosDimen_4f, inColor_4f, inParam_4f)
		S.CopyImage(Int(inImageObject.mId),
			inPainterWithRegisteredImage.mPainterRegisteredImageObject.mImage)
	end,
	PaintEXT = function(self, inPosDimen_4f, inColor_4f, inParam_4f, inImageObject, inImage, inX, inY, inZ)
		self.mPainter:paintext(inPosDimen_4f, inColor_4f, inParam_4f, Int(inX), Int(inY), Int(inZ))
		S.CopyImage(Int(inImageObject.mId),
			inImage.mImage)
	end,
	PaintImages = function(self, inPosDimen_4f, inColor_4f, inParam_4f, ...)
		self.mPainter:paint(inPosDimen_4f, inColor_4f, inParam_4f)
		local args = table.pack(...)
		for i, v in ipairs(args) do
			S.CopyImage(Int(v.mId), self.mPainter)
		end
	end
}

Jkr.Components.Abstract.Drawable = {
	mDrawFunction = nil,
	New = function(self, inDrawFunction)
		local Obj = {}
		Obj.Draw = inDrawFunction
		return Obj
	end
}

Jkr.Components.Abstract.Eventable = {
	mEventFunction = nil,
	New = function(self, inEventFunction)
		local Obj = {}
		Obj.Event = inEventFunction
		return Obj
	end
}


Jkr.Components.Abstract.Dispatchable = {
	mDispatchFunction = nil,
	New = function(self, indispatchfunction)
		local Obj = {}
		Obj.Dispatch = indispatchfunction
		return Obj
	end
}

Jkr.Components.Abstract.Updatable = {
	mUpdateFunction = nil,
	New = function(self, inupdateFunction)
		local Obj = {}
		Obj.Update = inupdateFunction
		return Obj
	end
}
