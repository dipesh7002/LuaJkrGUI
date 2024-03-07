require "JkrGUIv2.JkrGUIv2"
local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Hello")
local e = Jkr.CreateEventManager()
local l = Jkr.CreateLineRenderer(i, w)
local line = l:Add(vec3(100, 100, 5), vec3(200, 200, 5))


function Update()
   WindowDimension = w:GetWindowDimension()
end

function Draw()
   l:Bind(w)
   l:Draw(w, vec4(1, 0, 0, 1), Integer(WindowDimension.x), Integer(WindowDimension.y), line, line, Jmath.GetIdentityMatrix4x4())
end

function Dispatch()
   l:Dispatch(w)
end

function PostProcess()

end

Jkr.DebugMainLoop(w, e, Update, Dispatch, Draw, PostProcess)
