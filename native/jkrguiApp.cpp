#include "Instance.hpp"
#include "Renderers/Renderer_base.hpp"
#include "Renderers/ThreeD/Shape3D.hpp"
#include "Renderers/ThreeD/glTF_Model.hpp"
#include <Misc/ThreeD/Uniform3D.hpp>
#include <Renderers/ThreeD/Simple3D.hpp>
#include <WindowMulT.hpp>
#include <sol/sol.hpp>

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT __attribute__((visibility("default")))
#endif

const std::string_view BRDFVertex = R"VertexShader(
layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec3 inNormal;
layout(location = 2) in vec2 inUV;
layout(location = 3) in vec3 inColor;

layout (location = 0) out vec2 vUV;
layout (location = 1) out vec3 vNormal;
layout(push_constant, std430) uniform pc {
	mat4 mvp;
	vec3 rough;
	vec3 rgb;
} push;

layout(set = 0, binding = 1) uniform UBO {
   mat4 view;
   mat4 proj;
   vec3 campos;
   vec4 lights[10];
} ubo;

void GlslMain()
{
	gl_Position = ubo.proj * ubo.view * push.mvp * vec4(inPosition, 1.0f);	
	vUV = inUV;
	vNormal = inNormal;
}
)VertexShader";

const std::string_view BRDFFragment = R"FragmentShader(
	layout(location = 0) in vec2 vUV;
	layout(location = 1) in vec3 vNormal;
	layout(location = 0) out vec4 out_color;
	layout(set = 0, binding = 0) uniform sampler2D image;

	layout(set = 0, binding = 1) uniform UBO {
	   mat4 view;
	   mat4 proj;
	   vec3 campos;
	   vec4 lights[10];
	} ubo;

	layout(push_constant, std430) uniform pc {
		mat4 mvp;
		vec3 roughness;
		vec3 rgb;
	} push;

	const float PI = 3.14159;
	vec3 materialcolor()
	{
		return vec3(texture(image, vUV));
		//return vec3(1, 1, 1);
	}

	// Normal Distribution Function

	float D_GGX(float dotNH, float roughness)
	{
		float alpha = roughness * roughness;
		float alpha2 = alpha * alpha;
		float denom = dotNH * dotNH * (alpha2 - 1.0) + 1.0;
		return (alpha2)/ (PI * denom * denom);
	}

	// Geometric Shadowing Function
	float G_SchlicksmithGGX(float dotNL, float dotNV, float roughness)
	{
		float r = roughness + 1.0;
		float k = (r * r) / 8.0;
		float GL = dotNL / (dotNL * (1.0 - k) + k);
		float GV = dotNV / (dotNV * (1.0 - k) + k);
		return GL * GV;
	}

	// Fresnel Function
	vec3 F_Schlick(float cosTheta, float metallic)
	{
		vec3 F0 = mix(vec3(0.04), materialcolor(), metallic); // material.specular
		vec3 F = F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
		return F;
	}

	// Specular BRDF composition
	vec3 BRDF(vec3 L, vec3 V, vec3 N, float metallic, float roughness)
	{
		vec3 H = normalize(V + L);
		float dotNV = clamp(dot(N, V), 0.0, 1.0);
		float dotNL = clamp(dot(N, L), 0.0, 1.0);
		float dotLH = clamp(dot(L, H), 0.0, 1.0);
		float dotNH = clamp(dot(N, H), 0.0, 1.0);

		// Light color fixed
		vec3 lightColor = vec3(1.0);

		vec3 color = vec3(0.0);

		if (dotNL > 0.0)
		{
			float rroughness = max(0.05, roughness);
			// D = Normal distribution (Distribution of the microfacets)
			float D = D_GGX(dotNH, roughness); 
			// G = Geometric shadowing term (Microfacets shadowing)
			float G = G_SchlicksmithGGX(dotNL, dotNV, rroughness);
			// F = Fresnel factor (Reflectance depending on angle of incidence)
			vec3 F = F_Schlick(dotNV, metallic);

			vec3 spec = D * F * G / (4.0 * dotNL * dotNV);

			color += spec * dotNL * lightColor;
		}

		return color;
	}

	void GlslMain()
	{
		vec3 N = normalize(vNormal);
		vec3 V = normalize(ubo.campos - vec3(0, 0, 0)); // TODO ubo.campos - PositioninWorld
		float roughness = push.roughness.x;
		// Specular Contribution
		vec3 Lo = vec3(0.0);
		vec3 L = normalize(vec3(ubo.lights[0]) - vec3(0, 0, 0)); // in World ko position
		Lo += BRDF(L, V, N, 1, roughness);

		// Combination With Ambient
		vec3 color = materialcolor() * 0.02;
		color += Lo;
		color = pow(color, vec3(0.4545));
		out_color = vec4(color, 1.0);
	}

)FragmentShader";

extern "C" DLLEXPORT int luaopen_jkrguiApp(lua_State* L) {
               sol::state_view s(L);
               auto jkrguiApp = s["jkrguiApp"].get_or_create<sol::table>();
               jkrguiApp.set_function("hello", []() { std::cout << "Hello World from jkrguiApp\n"; });
               jkrguiApp.set_function("GetBRDFVertexShader", [&]() { return BRDFVertex; });
               jkrguiApp.set_function("GetBRDFFragmentShader", [&]() { return BRDFFragment; });

               struct UBO {
                              alignas(16) glm::mat4 view;
                              alignas(16) glm::mat4 proj;
                              glm::vec3 campos;
                              alignas(16) glm::vec4 lights[10];
               } ubo;
               jkrguiApp.set_function("GetUBO", [](glm::mat4 inView, glm::mat4 inProj, glm::vec3 inCamPos, glm::vec4 inLightPos) {
                              UBO ubo;
                              ubo.view = inView;
                              ubo.proj = inProj;
                              ubo.campos = inCamPos;
                              ubo.lights[0] = inLightPos;
                              return ubo;
               });

               jkrguiApp.set_function("AddBufferToUniform", [](Jkr::Misc::_3D::Uniform3D& inUniform, int inDstBinding) { inUniform.AddUniformBuffer(inDstBinding, sizeof(UBO)); });

               jkrguiApp.set_function("UpdateBufferToUniform", [](Jkr::Misc::_3D::Uniform3D& inUniform, int inDstBinding, UBO inubo) { inUniform.UpdateUniformBuffer<UBO>(inDstBinding, inubo); });

               struct PushConstant {
                              glm::mat4 mvp;
                              glm::vec3 rough;
                              glm::vec3 rgb;
               };
               jkrguiApp.set_function("DrawBRDF",
                                      [](Jkr::Misc::_3D::Simple3D& inSimple3D,
                                         Jkr::WindowMulT& inWindow,
                                         Jkr::Renderer::_3D::Shape& inShape,
                                         int inModelId,
                                         glm::mat4 inModel,
                                         glm::vec3 inRough,
                                         glm::vec3 inRGB,
                                         Jkr::Window::ParameterContext inParam) {
                                                     PushConstant p = {.mvp = inModel, .rough = inRough, .rgb = inRGB};
                                                     inSimple3D.Draw<PushConstant>(inWindow, inShape, p, inShape.GetIndexOffsetAbsolute(inModelId), inShape.GetIndexCount(inModelId), 1, inParam);
                                      });
               return 1;
}
