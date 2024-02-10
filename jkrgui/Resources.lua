require "jkrgui.jkrgui"

Com.Fonts = {}
Com.GetFont = function(inFontName, inSize)
	local size = inSize
	if size == "large" then
		size = FontSize(16)
	elseif size == "Small" then
		size = FontSize(12)
	elseif size == "Large" then
		size = FontSize(20)
	end
	if not Com.CanvasPainters[inFontName .. inSize] then
		Com.Fonts[inFontName .. inSize] = Jkr.FontObject:New(inFontName .. ".ttf", size)
	end
	return Com.Fonts[inFontName .. inSize]
end
-- FONT MANAGEMENT

-- These are legacy Stuff that we will sort out during maintainence time
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

-- /* ForCanvas */
-- /* These are for the Canvas */
CanvasHeader = [[
	int xx = int(push.mPosDimen.x);
	int yy = int(push.mPosDimen.y);
	to_draw_at.x = to_draw_at.x + xx;
	to_draw_at.y = to_draw_at.y + yy;
	vec4 pure_color = push.mColor;

	vec2 imageko_size = vec2(push.mPosDimen.z, push.mPosDimen.w); // GlobalInvocations
	float x_cartesian = (float(gl_GlobalInvocationID.x) - float(imageko_size.x) / float(2)) / (float((imageko_size.x) / float(2)));
	float y_cartesian = (float(imageko_size.y) / float(2) - float(gl_GlobalInvocationID.y)) / (float(imageko_size.y) / float(2));
	vec2 xy_cartesian = vec2(x_cartesian, y_cartesian);
]]

Jkr.GLSL["ClearCanvas"] = CanvasHeader .. [[
	imageStore(storageImage, to_draw_at, vec4(push.mColor.x, push.mColor.y, push.mColor.z, push.mColor.w));
]]

Jkr.GLSL["CircleCanvas"] = CanvasHeader .. [[
	vec2 center = vec2(0, 0);
	vec2 hw = vec2(0.8, 0.8);
	float radius = hw.x;

	float color = distance(xy_cartesian, center) - radius;
	vec4 old_color = imageLoad(storageImage, to_draw_at);
	vec4 final_color = vec4(pure_color.x * color, pure_color.y * color, pure_color.z * color, pure_color.w * color);
	final_color = mix(final_color, old_color, color);
	final_color = mix(pure_color, final_color, color);
	final_color.a = smoothstep(0.95, 1, final_color.a);

	imageStore(storageImage, to_draw_at, vec4(pure_color.xyz, final_color.a));
]]

Jkr.GLSL["RoundedRectangleCanvas"] = CanvasHeader .. [[
	vec2 center = vec2(0, 0);
	vec2 hw = vec2(0.5, 0.5);
	float radius = push.mParam.x;
	vec2 Q = abs(xy_cartesian - center) - hw;

	float color = distance(max(Q, vec2(0.0)), vec2(0.0)) + min(max(Q.x, Q.y), 0.0) - radius;
	vec4 old_color = imageLoad(storageImage, to_draw_at);
	vec4 final_color = vec4(pure_color.x * color, pure_color.y * color, pure_color.z * color, pure_color.w * color);
	final_color = mix(final_color, old_color, 1 - color);
	final_color = mix(pure_color, final_color, 1 - color);
	final_color.a = smoothstep(0.95, 1, final_color.a);

	imageStore(storageImage, to_draw_at, vec4(pure_color.xyz, final_color.a));
]]

Jkr.GLSL["RoundedRectangleGradientCanvas"] = CanvasHeader .. [[
	vec2 center = vec2(0, 0);
	vec2 hw = vec2(0.5, 0.5);
	float radius = push.mParam.x;
	vec2 Q = abs(xy_cartesian - center) - hw;

	float color = distance(max(Q, vec2(0.0)), vec2(0.0)) + min(max(Q.x, Q.y), 0.0) - radius;
	vec4 old_color = imageLoad(storageImage, to_draw_at);
	vec4 final_color = vec4(pure_color.x * color, pure_color.y * color, pure_color.z * color, pure_color.w * color);
	final_color = mix(final_color, old_color, 1 - color);
	final_color = mix(pure_color, final_color, 1 - color);
	final_color.a = smoothstep(0.95, 1, final_color.a);

	imageStore(storageImage, to_draw_at, final_color);

]]

Com.CanvasPainters = {}

Com.GetCanvasPainter = function(inPainterNameString, inShouldCompile)
	if not Com.CanvasPainters[inPainterNameString] or inShouldCompile then
		Com.CanvasPainters[inPainterNameString] = Jkr.Components.Util.ImagePainter:New("cache/" .. inPainterNameString ..  "Canvas.Compute", inShouldCompile, Jkr.GLSL[inPainterNameString .. "Canvas"], 1, 1, 1)
	end
	return Com.CanvasPainters[inPainterNameString]
end

-- Threed Shaders Below

Jkr.GLSL.PushLayout = [[

    layout(push_constant, std430) uniform pc {
        mat4 mvp;
        vec4 rough;
        vec4 rgb;
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

    local CShader = [[
        void GlslMain() 
        {

        }
    ]]

    return {v = VShader, f = FShader, c = CShader}
end



