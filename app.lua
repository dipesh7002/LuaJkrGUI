require "JkrGUIv2.JkrGUIv2"

local i = Jkr.CreateInstance()
local MultiThreading = Jkr.MultiThreading(i)
local w = Jkr.CreateWindow(i, "Hello", vec2(500, 500))
local e = Jkr.CreateEventManager()
local l = Jkr.CreateLineRenderer(i, w)

local shape = Jkr.CreateShapeRenderer(i, w)
local TR = Jkr.CreateTextRendererBestTextAlt(i, shape)

local line = l:Add(vec3(100, 100, 1), vec3(500, 500, 1))
local lGenerator = Jkr.Generator(Jkr.Shapes.RectangleFill, uvec2(50, 50))
local id = shape:Add(lGenerator, vec3(10, 10, 20))
local font = TR:AddFontFace("font.ttf", 20)
local font_small = TR:AddFontFace("font.ttf", 15)
local text = TR:Add(font, vec3(100, 100, 5), "जय श्री राम")

local f___ = l
local b__ = {
   [1] = function()
      print("What the fuck is Happending")
   end
}


local shittyp = 15

function CreateObject()
   local OBJECT = {}
   OBJECT.ddd = Jkr.DefaultCustomImagePainterPushConstant()
   local ddd = { { 7, 6, 5, function()
      print("This is a function begin called", shittyp)
   end }, 5, Jkr.DefaultCustomImagePainterPushConstant() }
   ddd[3].x.x = 0

   OBJECT.FUCKYOU = function(self)
      print(ddd[1][1], ddd[2], ddd[3])
      return ddd
   end


   return OBJECT
end

local dfff = Jkr.DefaultCustomImagePainterPushConstant()
dfff.x = vec4(0)
dfff.y = vec4(1)
dfff.z = vec4(2)

MultiThreading:Inject("SUSPECT", CreateObject())
MultiThreading:Inject("LineRenderer", l)
MultiThreading:Inject("window", w)
MultiThreading:Inject("fffd", dfff)
MultiThreading:Inject("FUCK", b__)
MultiThreading:Inject("mmmm", MultiThreading)

MultiThreading:AddJobF(function()
   --local uu = mmmm:CastToType(SUSPECT.ddd, Jkr.AllTypes.DefaultCustomImagePainterPushConstant)
   --print(SUSPECT.ddd)
   --   print(LineRenderer.recycleBin)
   local func = load(string.dump(LineRenderer.CreateMethods))
   func(LineRenderer)
   local i = LineRenderer:Add(vec3(5, 4, 6), vec3(6, 7, 4))
   mmmm:Inject("Result", i)
end)

-- local xxxx = MultiThreading:Get("fffd")
-- print(xxxx.y.x)
for i = 1, 10, 1 do
   MultiThreading:AddJobF(function()
   end)
end


local Matrix = function()
   return Jmath.Ortho(
      0.0,
      WindowDimension.x,
      0.0,
      WindowDimension.y,
      100,
      -100
   )
end


local I = 0
function Update()
   Matrix = function()
      local Ortho = Jmath.Ortho(
         0.0,
         WindowDimension.x,
         0.0,
         WindowDimension.y,
         100,
         -100
      )
      local Translate = Jmath.Translate(Ortho, vec3(WindowDimension.x / 2, WindowDimension.y / 2, 1))
      local Rotation = Jmath.Rotate_deg(Translate, I, vec3(0, 0, 1))
      I = I + 0.5
      return Rotation
   end
end

function Draw()
   l:Bind(w)
   l:Draw(w, vec4(1, 0, 0, 1), line, line, Matrix())
   shape:BindShapes(w)
   shape:BindFillMode(Jkr.FillType.Fill, w)
   shape:Draw(w, vec4(1, 0, 0, 1), id, id, Matrix())
   shape:BindShapes(w)
   shape:BindFillMode(Jkr.FillType.Image, w)
   TR:Draw(text, w, vec4(1, 0, 0, 1), Matrix())
end

function Dispatch()
   l:Dispatch(w)
   shape:Dispatch(w)
end

function PostProcess()
end

Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, PostProcess)
