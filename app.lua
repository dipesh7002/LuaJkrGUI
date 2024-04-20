require "JkrGUIv2.Basic"
require "JkrGUIv2.Widgets"

local SampraInstance = Jkr.CreateInstance()
local SampraWindow = Jkr.CreateWindow(SampraInstance, "Samprahar Returns", vec2(600, 300))
local SampraEvent = Jkr.CreateEventManager()
local SampraWidget = Jkr.CreateWidgetRenderer(SampraInstance, SampraWindow)
local Font = SampraWidget.CreateFont("res/fonts/font.ttf", 16)
local TextLabel = SampraWidget.CreateTextLabel(vec3(200, 200, 20), vec3(0), Font, "Hellow", vec4(1, 1, 1, 1))

local CustomImage = Jkr.CreateCustomPainterImage(SampraInstance, SampraWindow, 100, 100)
local CustomPainter = Jkr.CreateCustomImagePainter("res/cache/CustomPainter.glsl",
   Jkr.GetDefaultResource("CustomImagePainter", "RoundedRectangle"))
CustomPainter:Store(SampraInstance, SampraWindow)
CustomImage:Register(SampraInstance, CustomPainter.handle) -- TODO Wrap This

local Rectangle = Jkr.Generator(Jkr.Shapes.RectangleFill, uvec2(50, 50))
local ShapeRenderer = Jkr.CreateShapeRenderer(SampraInstance, SampraWindow)
local RectangleId = ShapeRenderer:Add(Rectangle, vec3(50, 50, 50))
local Image = ShapeRenderer:AddImage(100, 100)

local Draw = function()
   SampraWidget.Draw()
end

local Update = function()
   SampraWidget.Event()
   SampraWidget.Update()
end

local Dispatch = function()
   CustomPainter:Bind(SampraWindow, Jkr.CmdParam.None)
   CustomPainter:BindImageFromImage(SampraWindow, CustomImage, Jkr.CmdParam.None)
   local pc = Jkr.DefaultCustomImagePainterPushConstant()
   pc.x = vec4(10, 5, 5, 5)
   pc.y = vec4(1, 0, 0, 1)
   pc.z = vec4(0.8, 5, 5, 5)
   --CustomPainter:Draw(SampraWindow, pc, 50, 50, 1, Jkr.CmdParam.None)
   ShapeRenderer:CopyToImage(Image, CustomImage)
   ShapeRenderer:Dispatch(SampraWindow)

   SampraWidget.Dispatch()
end

Jkr.DebugMainLoop(SampraWindow, SampraEvent, Update, Dispatch, Draw, nil, vec4(0, 0, 0, 1))
