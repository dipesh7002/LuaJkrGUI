local ShouldLoadCaches = false

local GetDefaultResource = function(inRenderer, inShaderType)
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

    if inRenderer == "ShapeFill" then
        if inShaderType == "Vertex" then
            return [[

           ]]
        end
    end

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

Jmath = Jmath

Jkr.CreateInstance = function(inVarDesSet, inPoolSize)
    if not inVarDesSet then inVarDesSet = 1000 end
    if not inPoolSize then inPoolSize = 1000 end
    return Jkr.Instance(inVarDesSet, inPoolSize)
end

Jkr.CreateWindow = function(inJkrInstance, inTitle, inDimension_2f)
    if not inTitle then inTitle = "JkrGUIv2" end
    if not inDimension_2f then inDimension_2f = uvec2(900, 700) end
    return Jkr.Window(inJkrInstance, inTitle, inDimension_2f.x, inDimension_2f.y)
end

Jkr.CreateEventManager = function()
    return Jkr.EventManager()
end

local DefaultCaches = {}
Jkr.GetDefaultCache = function(inInstance, inRend)
    if inRend == "Line" then
        DefaultCaches["Line"] = Jkr.PainterCache(inInstance, Jkr.PainterType.Line)
        if ShouldLoadCaches then
            DefaultCaches["Line"]:Load("cache2/LineRendererCache.glsl")
        else
            DefaultCaches["Line"]:Store("cache2/LineRendererCache.glsl",
                GetDefaultResource("Line", "Vertex"),
                GetDefaultResource("Line", "Fragment"),
                GetDefaultResource(nil, "Compute")
            )
        end
        return DefaultCaches["Line"]
    end
end

Jkr.CreateLineRenderer = function(inInstance, inCompatibleWindow, inCache)
    if not inCache then
        local DefaultCache = Jkr.GetDefaultCache(inInstance, "Line")
        return Jkr.LineRenderer(inInstance, inCompatibleWindow, DefaultCache)
    else
        return Jkr.LineRenderer(inInstance, inCompatibleWindow, inCache)
    end
end

function Integer(inX)
    return math.floor(inX)
end

Jkr.DebugMainLoop = function(w, e, inUpdate, inDispatch, inDraw, inPostProcess)
    local oldTime = 0.0
    local i = 0
    while not e:ShouldQuit() do
        oldTime = w:GetWindowCurrentTime()
        e:ProcessEvents()

        -- /* All Updates are done here*/
        w:BeginUpdates()
        if (inUpdate) then inUpdate() end
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
        w:BeginDraws(1, 1, 1, 1, 1)
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
