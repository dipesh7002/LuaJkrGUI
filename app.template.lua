require "JkrGUIv2.JkrGUIv2"

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

ConfigureMultiThreading(MT)

Jkr.MultiThreadingInject(
          MT,
          {
                    { "__i__",        i },
                    { "__w__",        w },
                    { "__shape3d__",  shape3d },
                    { "__simple3d__", simple3d },
                    { "__mt__",       MT }
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
                              false
                    )
          end
)

MT:AddJobF(
          function()
                    local cubeId = __shape3d__:Add("res/models/Box.gltf")
                    __mt__:Inject("__cubeId__", cubeId)
                    print("Has been added", cubeId)
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
          MT:Wait()
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

function MTDraw()
          MT:AddJobF(
                    function()
                              local Def = Jkr.DefaultPushConstant3D()
                              local model = Jmath.GetIdentityMatrix4x4()                             -- model
                              model = Jmath.Scale(model, vec3(1, 1, 1))
                              local view = Jmath.LookAt(vec3(5, 5, 5), vec3(0, 0, 0), vec3(0, 1, 0)) -- view
                              local projection = Jmath.Perspective(0.45, 1, 0.1, 100)
                              Def.m1 = projection * view * model
                              Def.m2 = model
                              local cid = math.floor(__cubeId__)
                              local indexCount = __shape3d__:GetIndexCount(cid)
                              __w__:BeginThreadCommandBuffer(0)
                              __w__:SetDefaultViewport(0)
                              __w__:SetDefaultScissor(0)
                              __shape3d__:Bind(__w__, 0)
                              __simple3d__:Bind(__w__, 0)
                              __simple3d__:Draw(__w__, __shape3d__, Def, indexCount, 1, 0)
                              __w__:EndThreadCommandBuffer(0)
                    end
          )
end

function MTExecute()
          w:ExecuteThreadCommandBuffer(0)
end

Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, PostProcess, nil, MT, MTDraw, MTExecute)


--[[
require "JkrGUIv2.JkrGUIv2"
require "jkrguiApp"
jkrguiApp = jkrguiApp

local i = Jkr.CreateInstance(nil, nil, 4)
local MT = Jkr.MultiThreading(i)
local w = Jkr.CreateWindow(i, "Hello", vec2(500, 500))
local e = Jkr.CreateEventManager()
local l = Jkr.CreateLineRenderer(i, w)

local shape = Jkr.CreateShapeRenderer(i, w)
local TR = Jkr.CreateTextRendererBestTextAlt(i, shape)
local shape3d = Jkr.CreateShapeRenderer3D(i, w)
local simple3d = Jkr.CreateSimple3DRenderer(i, w)
local extended3d = Jkr.CreateSimple3DRenderer(i, w)
local CubeGenerator = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1))
shape3d:Add(CubeGenerator, vec3(0, 0, 0))

local line = l:Add(vec3(100, 100, 1), vec3(500, 500, 1))
local lGenerator = Jkr.Generator(Jkr.Shapes.RectangleFill, uvec2(50, 50))
local id = shape:Add(lGenerator, vec3(10, 10, 20))
local font = TR:AddFontFace("font.ttf", 20)
local font_small = TR:AddFontFace("font.ttf", 15)
local text = TR:Add(font, vec3(100, 100, 5), "जय श्री राम")



ConfigureMultiThreading(MT)
Jkr.MultiThreadingInject(
   MT,
   {
      { "__i__",          i },
      { "__w__",          w },
      { "__shape3d__",    shape3d },
      { "__simple3d__",   simple3d },
      { "__extended3d__", extended3d },
      { "__mt__",         MT }
   }
)

MT:InjectScriptF(
   function()
      require "jkrguiApp"
   end
)


local vshader = jkrguiApp.GetBRDFVertexShader()
local fshader = jkrguiApp.GetBRDFFragmentShader()
extended3d:Compile(
   i,
   w,
   "cache2/extended3D.glsl",
   vshader,
   fshader,
   GetDefaultResource("Simple3D", "Compute"),
   false
)
local Extended3dUniform = Jkr.Uniform3D(i, extended3d)
jkrguiApp.AddBufferToUniform(Extended3dUniform, 1)
Extended3dUniform:AddTexture(0, "res/models/CesiumLogoFlat.png")
MT:Inject("__extended3dUniform__", Extended3dUniform)

MT:AddJobF(
   function()
      local cubeId = __shape3d__:Add("res/models/BoxTextured.gltf")
      local duckId = __shape3d__:Add("res/models/Duck.gltf")
      __mt__:Inject("__cubeId__", cubeId)
   end
)

local shit__I = 0
function Update()
   MT:Wait()
   MT:Inject("I", shit__I)
   local view = Jmath.LookAt(vec3(5, 5, 5), vec3(0, 0, 0), vec3(0, 1, 0)) -- view
   local projection = Jmath.Perspective(0.45, 1, 0.1, 100)
   local ubo = jkrguiApp.GetUBO(view, projection, vec3(5, 5, 5), vec4(5, math.sin(shit__I * 1000) * 10, 5, 1))
   jkrguiApp.UpdateBufferToUniform(Extended3dUniform, 1, ubo)
   shit__I = shit__I + 0.0001
end

function Draw()
end

function Dispatch()
   l:Dispatch(w)
   shape:Dispatch(w)
end

function PostProcess()
end

function MTDraw()
   MT:AddJobF(
      function()
         __w__:BeginThreadCommandBuffer(0)
         __w__:SetDefaultViewport(0)
         __w__:SetDefaultScissor(0)
         local modelx = Jmath.GetIdentityMatrix4x4() -- model
         modelx = Jmath.Scale(modelx, vec3(1, 1, 1))
         modelx = Jmath.Rotate_deg(modelx, I * 10000, vec3(0, 0, 1))
         __shape3d__:Bind(__w__, 0)
         __extended3d__:Bind(__w__, 0)
         __extended3dUniform__:Bind(__w__, 0)
         jkrguiApp.DrawBRDF(__extended3d__, __w__, __shape3d__, 0, modelx, vec3(1, 1, 1), vec3(1, 1, 0), 0)

         local modely = Jmath.GetIdentityMatrix4x4() -- model
         modely = Jmath.Scale(modely, vec3(0.01, 0.01, 0.01))
         modely = Jmath.Translate(modely, vec3(8, 0.4, 0.4))
         modely = Jmath.Rotate_deg(modely, I * 10000, vec3(0, 0, 1))
         jkrguiApp.DrawBRDF(__extended3d__, __w__, __shape3d__, 2, modely, vec3(1, 1, 1), vec3(1, 1, 0), 0)
         __w__:EndThreadCommandBuffer(0)
      end
   )
end

function MTExecute()
   w:ExecuteThreadCommandBuffer(0)
end

Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, PostProcess, nil, MT, MTDraw, MTExecute)

]]
