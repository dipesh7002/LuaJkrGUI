require "jkrgui.jkrgui"


Jkr.GLSL = {}

Jkr.GLSL.RoundedRectangle = [[
vec2 center = vec2(push.mPosDimen.x, push.mPosDimen.y);
vec2 hw = vec2(push.mPosDimen.z, push.mPosDimen.w);
float radius = push.mParam.x;
vec2 Q = abs(xy - center) - hw;

float color = distance(max(Q, vec2(0.0)), vec2(0.0)) + min(max(Q.x, Q.y), 0.0) - radius;
color = smoothstep(-0.05, 0.05, -color);

vec4 old_color = imageLoad(storageImage, to_draw_at);
vec4 final_color = vec4(push.mColor.x * color, push.mColor.y * color, push.mColor.z * color, push.mColor.w * color);
final_color = mix(final_color, old_color, push.mParam.w);

imageStore(storageImage, to_draw_at, final_color);
]]

Jkr.GLSL.RoundedCircle = [[
vec2 center = vec2(push.mPosDimen.x, push.mPosDimen.y);
vec2 hw = vec2(push.mPosDimen.z, push.mPosDimen.w);
float radius = hw.x;

float color = distance(xy, center) - radius;
color = smoothstep(-0.05, 0.05, -color);

vec4 old_color = imageLoad(storageImage, to_draw_at);
vec4 final_color = vec4(push.mColor.x * color, push.mColor.y * color, push.mColor.z * color, push.mColor.w * color);
final_color = mix(final_color, old_color, push.mParam.w);

imageStore(storageImage, to_draw_at, final_color);
]]

Jkr.GLSL.Clear = [[
imageStore(storageImage, to_draw_at, vec4(0, 0, 0, 0));
]]

-- Threed Shaders Below

Jkr.GLSL.PushLayout = [[

    layout(push_constant, std430) uniform pc {
        mat4 mvp;
        vec3 rough;
        vec3 rgb;
    } push;

]]

Jkr.GLSL.UBLayout = [[

    layout(set = 0, binding = 1) uniform UBO {
        mat4 view;
        mat4 proj;
        vec3 campos;
        vec4 lights[10];
    } ubo;

]]


Jkr.GLSL.Constant3D = function ()
    local VShader = Jkr.GLSL.PushLayout .. Jkr.GLSL.UBLayout .. [[

        void GlslMain()
        {
            gl_Position = ubo.proj * ubo.view * push.mvp * vec4(inPosition, 1.0f);	
        }

    ]]

    local FShader = Jkr.GLSL.PushLayout .. Jkr.GLSL.UBLayout .. [[
    	layout(location = 0) out vec4 out_color;

        void GlslMain()
        {
            out_color = vec4(1, 0, 0, 1);
        }

    ]]

    local CShader = Jkr.GLSL.PushLayout .. Jkr.GLSL.UBLayout .. [[
        void GlslMain() 
        {

        }
    ]]

    return {v = VShader, f = FShader, c = CShader}
end