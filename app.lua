require "JkrGUIv2.JkrGUIv2"
local i = Jkr.CreateInstance()
local w = Jkr.CreateWindow(i, "Hello")
local e = Jkr.CreateEventManager()
local l = Jkr.CreateLineRenderer(i, w)


local i = 0
while not e:ShouldQuit() do
   e:ProcessEvents() 
   w:Draw(1, 1, 1, 1, 1)
   w:SetTitle("Fuck" .. i)
   i = i + 1
end
