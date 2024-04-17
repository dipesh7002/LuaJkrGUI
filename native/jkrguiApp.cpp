#include "jkrguiApp.hpp"

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
