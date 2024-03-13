--[============================================================[
        JKRGUI v2 - ALL RIGHT RESERVED (c)

*userdata - means table in which you cannot insert elements.
    This is similar to class in C++

*factory function - These are the functions that are prefixed
    CreateXXXX, that means you are creating an object.
    *A table is returned by the factory function,
    *all the local varia- bles in the factory function is
        to be treated like private member variable in C++

Notes:
1. All the factory functions that is not in the namespace Jkr,
    (is local to this file), will return userdata, that is
    you cannot extend the table. And those which are in the
    Jkr namespace will return a table which can be extended
    with your functionality.


CODING STANDARDS
    -- if the argument type is a table make it plural
            like inNumbers, inKeyframes etc
]============================================================]

-- True : Will compile and store caches
-- False: Will load caches instead of compiling the shaders
local ShouldLoadCaches_b = false

--[============================================================[
        DEFAULT RESOURCES

 These are all the shaders (vertex, fragment, compute) that
 are default but can be given by the application developer.
 The Compute shader is not used anywhere in renderers, but
 *can* be used, so we have kept it as is.

 Currently there is a Line Renderer and a Shape Renderer
]============================================================]

-- For no error squiggles in VSCode
Jkr = Jkr
Jmath = Jmath
vec3 = vec3
vec4 = vec4
vec2 = vec2
uvec2 = uvec2


local GetDefaultResource = function(inRenderer, inShaderType)
    --[============================================================[
            DEFAULT COMPUTE SHADER
    ]============================================================]

    if inShaderType == "Compute" then
        return [[
#version 450
#extension GL_EXT_debug_printf : enable
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
} push;

layout(set = 0, binding = 0) uniform sampler2D u_atlas8;

void GlslMain()
{
	uint gID = gl_GlobalInvocationID.x;
}

       ]]
    end

    --[============================================================[
            SHAPE RENDERER RESOURCES
    ]============================================================]


    if inRenderer == "ShapeFill" or inRenderer == "ShapeImage" then
        if inShaderType == "Vertex" then
            return [[
#version 450
#extension GL_EXT_debug_printf : enable

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec2 inTexCoord;
layout(location = 0) out vec2 outTexCoord;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
	vec4 mParams;
} push;


void GlslMain() {
	vec4 dx = vec4(inPosition.x, inPosition.y, inPosition.z, 1.0);
	gl_Position = push.Matrix * dx;
	outTexCoord = inTexCoord;
}
           ]]
        else
            if inRenderer == "ShapeFill" then
                return [[
#version 450
#extension GL_EXT_debug_printf : enable
layout(location = 0) out vec4 outColor;
layout(location = 0) in vec2 inTexCoord;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
	vec4 mParams;
} push;

void GlslMain()
{
	outColor = push.Color;
}
                ]]
            elseif inRenderer == "ShapeImage" then
                return [[
#version 450
#extension GL_EXT_debug_printf : enable

layout(location = 0) out vec4 outColor;
layout(set = 0, binding = 0) uniform sampler2D image;
layout(location = 0) in vec2 inTexCoord;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
	vec4 mParams;
} push;

void GlslMain()
{
	vec4 color = texture(image, inTexCoord);
	outColor = vec4(color.r * push.Color.r, color.g * push.Color.g, color.b * push.Color.b, color.a * push.Color.a);
}
                ]]
            elseif inRenderer == "ShapeImageVarDes" then
                return [[
#version 450
#extension GL_EXT_debug_printf : enable
#extension GL_EXT_nonuniform_qualifier : enable

layout(location = 0) out vec4 outColor;
layout(set = 0, binding = 0) uniform sampler2D u_image[];
layout(location = 0) in vec2 inTextCoord;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
	vec4 mParams;
} push;

void GlslMain()
{
	vec4 color = texture(u_image[int(push.mParams.x)], inTextCoord);
	outColor = vec4(color.r * push.Color.r, color.g * push.Color.g, color.b * push.Color.b, color.a * push.Color.a);
}
                ]]
            end
        end
    end

    --[============================================================[
         LINE RENDERER RESOURCES
    ]============================================================]


    if inRenderer == "Line" then
        if inShaderType == "Vertex" then
            return [[
#version 450
#extension GL_EXT_debug_printf : enable

layout(location = 0) in vec3 inPosition;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
} push;


void GlslMain() {
	vec4 dx = vec4(inPosition.x, inPosition.y, inPosition.z, 1.0);
	gl_Position = push.Matrix * dx;
}
        ]]
        elseif inShaderType == "Fragment" then
            return [[
#version 450
#extension GL_EXT_debug_printf : enable
layout(location = 0) out vec4 outColor;

layout(push_constant, std430) uniform pc {
	mat4 Matrix;
	vec4 Color;
} push;

void GlslMain()
{
	outColor = push.Color;
}
            ]]
        end
    end
end

--[============================================================[
        GET DEFAULT CACHES
    ]============================================================]

local DefaultCaches = {}
Jkr.GetDefaultCache = function(inInstance, inRend)
    if inRend == "Line" then
        DefaultCaches["Line"] = Jkr.PainterCache(inInstance, Jkr.PainterType.Line)
        if ShouldLoadCaches_b then
            DefaultCaches["Line"]:Load("cache2/LineRendererCache.glsl")
        else
            DefaultCaches["Line"]:Store("cache2/LineRendererCache.glsl",
                GetDefaultResource("Line", "Vertex"),
                GetDefaultResource("Line", "Fragment"),
                GetDefaultResource(nil, "Compute")
            )
        end
        return DefaultCaches["Line"]
    elseif inRend == "Shape" then
        DefaultCaches["Shape"] = Jkr.ShapeRendererResources()
        DefaultCaches["Shape"]:Add(
            inInstance,
            Jkr.FillType.Fill,
            Jkr.PipelineProperties.Default,
            "cache2/ShapeFillCache.glsl",
            GetDefaultResource("ShapeFill", "Vertex"),
            GetDefaultResource("ShapeFill", "Fragment"),
            GetDefaultResource(nil, "Compute"),
            ShouldLoadCaches_b
        )
        DefaultCaches["Shape"]:Add(
            inInstance,
            Jkr.FillType.Image,
            Jkr.PipelineProperties.Default,
            "cache2/ShapeImageCache.glsl",
            GetDefaultResource("ShapeImage", "Vertex"),
            GetDefaultResource("ShapeImage", "Fragment"),
            GetDefaultResource(nil, "Compute"),
            ShouldLoadCaches_b
        )
        DefaultCaches["Shape"]:Add(
            inInstance,
            Jkr.FillType.ContinousLine,
            Jkr.PipelineProperties.Line,
            "cache2/ShapeFillCache.glsl",
            GetDefaultResource("ShapeFill", "Vertex"),
            GetDefaultResource("ShapeFill", "Fragment"),
            GetDefaultResource(nil, "Compute"),
            ShouldLoadCaches_b
        )
        return DefaultCaches["Shape"]
    end
end


--[============================================================[
    CREATE JKR INSTANCE
]============================================================]


Jkr.CreateInstance = function(inVarDesSet, inPoolSize)
    if not inVarDesSet then inVarDesSet = 1000 end
    if not inPoolSize then inPoolSize = 1000 end
    return Jkr.Instance(inVarDesSet, inPoolSize)
end

--[============================================================[
    CREATE JKR WINDOW
]============================================================]

Jkr.CreateWindow = function(inJkrInstance, inTitle, inDimension_2f)
    if not inTitle then inTitle = "JkrGUIv2" end
    if not inDimension_2f then inDimension_2f = uvec2(900, 700) end
    return Jkr.Window(inJkrInstance, inTitle, inDimension_2f.x, inDimension_2f.y)
end

--[============================================================[
    CREATE JKR EVENT MANAGER
]============================================================]

Jkr.CreateEventManager = function()
    return Jkr.EventManager()
end


--[============================================================[
    CREATE LINE RENDERER
]============================================================]


local CreateLineRenderer = function(inInstance, inCompatibleWindow, inCache)
    local DefaultCache = inCache
    if not inCache then
        DefaultCache = Jkr.GetDefaultCache(inInstance, "Line")
    end
    return Jkr.LineRenderer(inInstance, inCompatibleWindow, DefaultCache)
end

Jkr.CreateLineRenderer = function(inInstance, inCompatibleWindow, inCache)
    local o = {}
    local lr = CreateLineRenderer(inInstance, inCompatibleWindow, inCache)
    o.handle = lr
    local recycleBin = Jkr.RecycleBin()

    o.Add = function(self, inP1_3f, inP2_3f)
        if not recycleBin:IsEmpty() then
            local i = recycleBin:Get()
            lr:Update(i, inP1_3f, inP2_3f)
            return i
        else
            return lr:Add(inP1_3f, inP2_3f)
        end
    end
    o.Remove = function(self, inIndex)
        recycleBin:Add(inIndex)
    end
    o.Draw = function(self, w, inColor, startId, endId, inMatrix)
        lr:Draw(w, inColor, startId, endId, inMatrix)
    end
    o.Bind = function(self, w)
        lr:Bind(w)
    end
    o.Dispatch = function(self, w)
        lr:Dispatch(w)
    end
    return o
end

--[============================================================[
    CREATE SHAPE RENDERER
]============================================================]

local CreateShapeRenderer = function(inInstance, inCompatibleWindow, inShapeRendererResouce)
    if inShapeRendererResouce then
        return Jkr.ShapeRenderer(inInstance, inCompatibleWindow, inShapeRendererResouce)
    else
        return Jkr.ShapeRenderer(inInstance, inCompatibleWindow, Jkr.GetDefaultCache(inInstance, "Shape"))
    end
end

Jkr.CreateShapeRenderer = function(inInstance, inCompatibleWindow, inShapeRendererResouce)
    local o = {}
    local sr = CreateShapeRenderer(inInstance, inCompatibleWindow, inShapeRendererResouce)
    o.handle = sr
    o.Add = function (self, inGenerator, inPosition_3f)
      return sr:Add(inGenerator, inPosition_3f)  
    end
    o.Update = function (self, inId, inGenerator, inPosition_3f)
       sr:Update(inId, inGenerator, inPosition_3f) 
    end
    o.BindShapes = function(self, w)
        sr:BindShapes(w)
    end
    o.BindFillMode = function (self, inFillMode, inWindow)
        sr:BindFillMode(inFillMode, inWindow) 
    end
    o.Draw = function (self, w, inColor_4f, inWindowW, inWindowH, inStartShapeId, inEndShapeId, inMatrix)
        sr:Draw(w, inColor_4f, inWindowW, inWindowH, inStartShapeId, inEndShapeId, inMatrix)
    end
    o.Dispatch = function (self, w)
        sr:Dispatch(w)    
    end
    return o
end

local CreateShapeRendererEXT = function(inInstance, inCompatibleWindow, inCaches)
    -- TODO
end

Jkr.CreateShaperRendererEXT = function(inInstance, inCompatibleWindow, inCache)
    -- TODO
end

--[============================================================[
    CREATE TEXT RENDERER
]============================================================]

Jkr.CreateTextRendererBestTextBase = function ()
    local o = {}
    o.handle = Jkr.BestText_base()
    return o
end

local CreateTextRendererBestTextAlt = function (inInstance, inShape, inBestTextBase, inCompatibleWindow)
    return Jkr.BestText_Alt(inInstance, inShape, inBestTextBase)  
end

Jkr.CreateTextRendererBestTextAlt = function (inInstance, inShape, inBestTextBase, inCompatibleWindow)
   local o = {} 
   local tr = CreateTextRendererBestTextAlt(inInstance, inShape, inBestTextBase.handle, inCompatibleWindow)
   o.handle = tr
   o.Add = function (inFontId, inPosition_3f, inText)
        return tr:Add(inFontId, inPosition_3f, inText)
   end
   o.Update = function (inImageId, inFontId, inPosition_3f, inText)
        tr:Update(inImageId, inFontId, inPosition_3f, inText)
   end
   o.UpdatePosOnly = function (inImageId, inFontId, inPosition_3f, inText)
        tr:UpdatePosOnly(inImageId, inFontId, inPosition_3f, inText)
   end
   o.Draw = function (inImageId, w, inColor, inMatrix)
        tr:Draw(inImageId, w, inColor, inMatrix) 
   end

   return o
end


--[============================================================[
    UTILITY FUNCTIONS
]============================================================]

function math.int(inX)
    return math.floor(inX)
end

--[============================================================[
    MAIN LOOPS
]============================================================]

Jkr.DebugMainLoop = function(w, e, inUpdate, inDispatch, inDraw, inPostProcess, inColor_4f)
    local oldTime = 0.0
    local i = 0
    while not e:ShouldQuit() do
        oldTime = w:GetWindowCurrentTime()
        e:ProcessEvents()

        -- /* All Updates are done here*/
        w:BeginUpdates()
        if (inUpdate) then inUpdate() end
        WindowDimension = w:GetWindowDimension()
        w:EndUpdates()

        -- /* All UI Renders are Recordeed here*/
        w:BeginUIs()
        if (inDraw) then inDraw() end
        w:EndUIs()

        -- /* All ComputeShader Invocations are Done here Renders are Recordeed here*/
        w:BeginDispatches()
        if (inDispatch) then inDispatch() end
        w:EndDispatches()

        -- /* All Draws (Main CmdBuffer Recording) is done here*/
        if inColor_4f then
            w:BeginDraws(inColor_4f.x, inColor_4f.y, inColor_4f.z, inColor_4f.a, 1)
        else
            w:BeginDraws(0, 0, 0, 1, 1)
        end

        w:ExecuteUIs() -- The UI CmdBuffer is executed onto the main CmdBuffer
        w:EndDraws()

        if (inPostProcess) then inPostProcess() end

        -- /* Finally is presented onto the screen */
        w:Present()
        local delta = w:GetWindowCurrentTime() - oldTime
        if (i % 100 == 0) then
            w:SetTitle("FrameRate: " .. 1000 / delta)
        end
        i = i + 1
    end
end
