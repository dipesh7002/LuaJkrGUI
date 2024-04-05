require "JkrGUIv2.JkrGUIv2"
require "jkrguiApp"

local i = Jkr.CreateInstance(nil, nil, 4)
local MT = Jkr.MultiThreading(i)
local w = Jkr.CreateWindow(i, "Hello", vec2(500, 500))
local e = Jkr.CreateEventManager()
local l = Jkr.CreateLineRenderer(i, w)

local shape = Jkr.CreateShapeRenderer(i, w)
local TR = Jkr.CreateTextRendererBestTextAlt(i, shape)
local shape3d = Jkr.CreateShapeRenderer3D(i, w)
local simple3d = Jkr.CreateSimple3DRenderer(i, w)

local line = l:Add(vec3(100, 100, 1), vec3(500, 500, 1))
local lGenerator = Jkr.Generator(Jkr.Shapes.RectangleFill, uvec2(50, 50))
local id = shape:Add(lGenerator, vec3(10, 10, 20))
local font = TR:AddFontFace("font.ttf", 20)
local font_small = TR:AddFontFace("font.ttf", 15)
local text = TR:Add(font, vec3(100, 100, 5), "जय श्री राम")

jkrguiApp.hello()

ConfigureMultiThreading(MT)

Jkr.MultiThreadingInject(
   MT,
   {
      { "__i__",        i },
      { "__w__",        w },
      { "__shape3d__",  shape3d },
      { "__simple3d__", simple3d },
   }
)

MT:AddJobF(
   function()
      local __getResources = load(string.dump(__GetDefaultResource__))
      __simple3d__:Compile(
         __i__,
         __w__,
         "cache2/Simple3D.glsl",
         __getResources("Simple3D", "Vertex"),
         __getResources("Simple3D", "Fragment"),
         __getResources("Simple3D", "Compute"),
         true
      )
   end
)

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
