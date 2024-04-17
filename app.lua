require "JkrGUIv2.JkrGUIv2"
ImportShared("jkrguiApp")

local i = Jkr.CreateInstance(nil, nil, 4)
local MT = Jkr.MultiThreading(i)
local w = Jkr.CreateWindow(i, "Hello", vec2(500, 500))
local e = Jkr.CreateEventManager()
--local l = Jkr.CreateLineRenderer(i, w)

local shape = Jkr.CreateShapeRenderer(i, w)
local TR = Jkr.CreateTextRendererBestTextAlt(i, shape)
local shape3d = Jkr.CreateShapeRenderer3D(i, w)
local simple3d = Jkr.CreateSimple3DRenderer(i, w)
local extended3d = Jkr.CreateSimple3DRenderer(i, w)
local skinned3d = Jkr.CreateSimple3DRenderer(i, w)
local CubeGenerator = Jkr.Generator(Jkr.Shapes.Cube3D, vec3(1, 1, 1))
--shape3d:Add(CubeGenerator, vec3(0, 0, 0))

--local line = l:Add(vec3(100, 100, 1), vec3(500, 500, 1))
local lGenerator = Jkr.Generator(Jkr.Shapes.RectangleFill, uvec2(50, 50))
local id = shape:Add(lGenerator, vec3(10, 10, 20))
local font = TR:AddFontFace("res/fonts/font.ttf", 20)
local font_small = TR:AddFontFace("res/fonts/font.ttf", 15)
local text = TR:Add(font, vec3(100, 100, 5), "जय श्री राम")

ConfigureMultiThreading(MT)
Jkr.MultiThreadingInject(
   MT,
   {
      { "_i_",          i },
      { "_w_",          w },
      { "_shape3d_",    shape3d },
      { "_simple3d_",   simple3d },
      { "_extended3d_", extended3d },
      { "_mt_",         MT },
   }
)

MT:InjectScriptF(
   function()
      ImportShared("jkrguiApp")
   end
)



function CompileBRDFShader()
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
end
CompileBRDFShader()



local Extended3dUniform = Jkr.Uniform3D(i, extended3d)
jkrguiApp.AddBufferToUniform(Extended3dUniform, 1)
Extended3dUniform:AddTexture(0, "res/models/CesiumLogoFlat.png")
MT:Inject("_extended3dUniform_", Extended3dUniform)

local SimpleSkinUniform = Jkr.Uniform3D(i, extended3d)
local SimpleSkinModel = Jkr.glTF_Model("res/models/SimpleSkin/SimpleSkin.gltf")
local simpleSkin = shape3d:Add(SimpleSkinModel)
Jkr.GetGLTFInfo(SimpleSkinModel, true)


function CompileSkinnedShader()
      local vshader = [[

#version 450
#pragma shader_stage(vertex)
#extension GL_EXT_debug_printf : enable
layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inUV;
layout(location = 3) in vec3 inColor;
layout(location = 0) out vec3 outColor;
      ]] .. Jkr.GetGLTFShaderLayoutString(SimpleSkinModel) .. 
      [[


layout(push_constant, std430) uniform pc {
   mat4 m1;
   mat4 m2;
} push;

void GlslMain()
{
               gl_Position = push.m1 * vec4(inPosition, 1.0);
               gl_Position.y = - gl_Position.y;
               outColor = inColor;
}
      ]]

      skinned3d:Compile(
            i, 
            w,
            "res/models/SimpleSkin/VFC.glsl",
            vshader,
            GetDefaultResource("Simple3D", "Fragment"),
            GetDefaultResource("Simple3D", "Compute"),
            false
      )
end
CompileSkinnedShader()

local skinnedShaderUniform3D = Jkr.Uniform3D(i, skinned3d, SimpleSkinModel, 0, true)

MT:AddJobF(
   function()
      --local CubeModel = Jkr.glTF_Model("res/models/Duck.gltf")
      local CubeModel = Jkr.glTF_Model("res/models/SimpleSkin/SimpleSkin.gltf")
      local cubeId = _shape3d_:Add(CubeModel)
      _mt_:Inject("_cubeId_", cubeId)
   end
)

local shit_I = 0
function Update()
   MT:Wait()
   MT:Inject("I", shit_I)
   local view = Jmath.LookAt(vec3(0, -5, 5), vec3(0, 0, 0), vec3(0, 1, 0)) -- view
   local projection = Jmath.Perspective(0.45, 1, 0.1, 100)
   local ubo = jkrguiApp.GetUBO(Jmath.GetIdentityMatrix4x4(), Jmath.GetIdentityMatrix4x4(), vec3(5, 5, 5), vec4(math.sin(shit_I * 1000) * 5, 10, 5, 1))
   jkrguiApp.UpdateBufferToUniform(Extended3dUniform, 1, ubo)
   -- shit_I = shit_I + 0.0001
end

function Draw()
end

function Dispatch()
   --   l:Dispatch(w)
   shape:Dispatch(w)
end

function PostProcess()
end

function MTDraw()
   MT:AddJobF(
      function()
         _w_:BeginThreadCommandBuffer(0)
         _w_:SetDefaultViewport(0)
         _w_:SetDefaultScissor(0)
         local modelx = Jmath.GetIdentityMatrix4x4() -- model
         modelx = Jmath.Scale(modelx, vec3(1, 1, 1))
         modelx = Jmath.Rotate_deg(modelx, I * 10000, vec3(1, 0, 0))
         _shape3d_:Bind(_w_, 0)
         _extended3d_:Bind(_w_, 0)
         _extended3dUniform_:Bind(_w_, _extended3d_, 0)
         jkrguiApp.DrawBRDF(_extended3d_, _w_, _shape3d_, 0, modelx, vec3(1, 1, 1), vec3(1, 1, 0), 0)

         _w_:EndThreadCommandBuffer(0)
      end
   )
end

function MTExecute()
   w:ExecuteThreadCommandBuffer(0)
end

Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, PostProcess, nil, MT, MTDraw, MTExecute)
