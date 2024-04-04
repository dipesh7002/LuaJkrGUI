
#include <lauxlib.h>
#include <lua.h>

#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT
#endif

extern "C" DLLEXPORT int luaopen_jkrguiApp(lua_State* L) { return 1; }
