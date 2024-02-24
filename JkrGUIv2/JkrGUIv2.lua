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

Jkr.CreateLineRenderer = function(inInstance, inCompatibleWindow, inCache)
    if not inCache then
        inCache = Jkr.PainterCache(inInstance, Jkr.PainterType.Line)
        if ShouldLoadCaches then
            inCache:Load("cache2/LineRendererCache.glsl")
        else
            inCache:Store("cache2/LineRendererCache.glsl",
                GetDefaultResource("Line", "Vertex"),
                GetDefaultResource("Line", "Fragment"),
                GetDefaultResource(nil, "Compute")
            )
        end
    end
    return Jkr.LineRenderer(inInstance, inCompatibleWindow, inCache)
end