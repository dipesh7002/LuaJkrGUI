require "JkrGUIv2.JkrGUIv2"
local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Hello", vec2(800, 500))
local e = Jkr.CreateEventManager()
local l = Jkr.CreateLineRenderer(i, w)

local shape = Jkr.CreateShapeRenderer(i, w)
local textBase = Jkr.CreateTextRendererBestTextBase()
local TR = Jkr.CreateTextRendererBestTextAlt(i, shape, textBase, w)

local line = l:Add(vec3(100, 100, 1), vec3(500, 500, 1))
local lGenerator = Jkr.Generator(Jkr.Shapes.RectangleFill, uvec2(100, 100))
local id = shape:Add(lGenerator, vec3(10, 10, 20))

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
   shape:BindFillMode(Jkr.FillType.RectangleFill, w)
   shape:Draw(w, vec4(1, 0, 0, 1), id, id, Matrix())
end

function Dispatch()
   l:Dispatch(w)
   shape:Dispatch(w)
end

function PostProcess()
end

Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, PostProcess)
