require "jkrgui.all"

Jkr.GLSL["SimulatedAnnealingCircleGraphCanvas"] = CanvasHeader .. [[
	vec2 center = vec2(0, 0);
	vec2 hw = vec2(0.8, 0.8);
	float radius = hw.x;

	float color = distance(xy_cartesian, center) - radius;
	vec4 old_color = imageLoad(storageImage, to_draw_at);
	vec4 final_color = vec4(pure_color.x * color, pure_color.y * color, pure_color.z * color, pure_color.w * color);
	final_color = mix(final_color, old_color, color);
	final_color = mix(pure_color, final_color, color);
	final_color.a = smoothstep(0.95, 1, final_color.a);

    final_color = mix(old_color, final_color, final_color.a);

    imageStore(storageImage, to_draw_at, final_color);
]]

Jkr.GLSL["SimulatedAnnealingCircleGraphCanvas"] = CanvasHeader .. [[
	vec2 center = vec2(0, 0);
	vec2 hw = vec2(0.8, 0.8);
	float radius = hw.x;

	float color = distance(xy_cartesian, center) - radius;
	vec4 old_color = imageLoad(storageImage, to_draw_at);
	vec4 final_color = vec4(pure_color.x * color, pure_color.y * color, pure_color.z * color, pure_color.w * color);
	final_color = mix(final_color, old_color, color);
	final_color = mix(pure_color, final_color, color);
	final_color.a = smoothstep(0.95, 1, final_color.a);

    final_color = mix(old_color, final_color, final_color.a);

    imageStore(storageImage, to_draw_at, final_color);
]]

SN.Graphics = {}

SN.Graphics.CircularGraph = {
    mCanvas = nil,
    New = function (self, inPosition_3f, inDimension_3f)
       local Obj = {} 
       setmetatable(Obj, self)
       self.__index = self
        Obj.mCanvas = Com.Canvas:New(inPosition_3f, inDimension_3f)
        Com.Canvas.AddPainterBrush(Obj.mCanvas, Com.GetCanvasPainter("Clear", false))
        Com.Canvas.AddPainterBrush(Obj.mCanvas, Com.GetCanvasPainter("SimulatedAnnealingCircleGraph", true))
        Com.Canvas.MakeCanvasImage(Obj.mCanvas, inDimension_3f.x, inDimension_3f.y)

        Com.NewSingleTimeDispatch(function ()
            Obj.mCanvas.CurrentBrushId = 1
            Com.Canvas.Bind(Obj.mCanvas)
            Com.Canvas.Paint(Obj.mCanvas, vec4(0, 0, inDimension_3f.x, inDimension_3f.y), vec4(1, 1, 1, 1), vec4(1.2, 0, 0, 1), inDimension_3f.x, inDimension_3f.y, 1)
        end)
       return Obj
    end,
    Update = function (self, inPosition_3f, inDimension_3f)
        self.mCanvas:Update(inPosition_3f, inDimension_3f)
    end,
    PlotAt = function (self, inX, inY, inW, inH, inColor_4f, inBrushId)
        Com.NewSingleTimeDispatch(function ()
            self.mCanvas.CurrentBrushId = inBrushId
            Com.Canvas.Bind(self.mCanvas)
            Com.Canvas.Paint(self.mCanvas, vec4(inX, inY, inW, inH), inColor_4f, vec4(1.2, 0, 0, 1), inW, inH, 1)
        end) 
    end
}

SN.Graphics.CreateNumberSumSolverButton = function ()
    
end

SN.Graphics.CreateGUI = function ()
    LoadMaterialComponents(true)
    local Graph = SN.Graphics.CircularGraph:New(vec3(0), vec3(WindowDimension.x, WindowDimension.y, 1))
    local CallbackFunction = function(inS, inT)
        local Energy = SN.E(inS)
        local Temperature = inT / SN.InitialTemperature
        local EnergyVisualFactor = 3
        local i = inS.i
        local j = inS.j
        local rand_color = vec4(Temperature, math.random(), math.random(), 1)
        SN.Graphics.CircularGraph.PlotAt(Graph, i, j, Energy * EnergyVisualFactor, Energy * EnergyVisualFactor,
            rand_color, 2)
    end
    Graph:Update(vec3(0, 0, 90), vec3(WindowDimension.x, WindowDimension.y, 1))
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(350, 30), "Simulated Annealing", Com.GetFont("font", "large"))
    Window:Start()
    local insideWindow = function()
        local area = Com.AreaObject:New(vec3(0), vec3(0))
        Com.AreaObject.SetFillColor(area, vec4(0.8, 0.8, 0.8, 0.5))
        local color_navbarind = vec4(1, 0.4, 0.8, 1)
        local color_tint = vec4(1, 0, 0, 1)

        local Image1 = Jkr.Components.Abstract.ImageObject:New(0, 0, "book1.png")
        local Image2 = Jkr.Components.Abstract.ImageObject:New(0, 0, "book2.png")
        local Image3 = Jkr.Components.Abstract.ImageObject:New(0, 0, "PNG_transparency_demonstration_1.png")
        local NavBarElem1 = Com.IconButton:New(vec3(0), vec3(0), Image1)
        local NavBarElem2 = Com.IconButton:New(vec3(0), vec3(0), Image2)
        local NavBarElem3 = Com.IconButton:New(vec3(0), vec3(0), Image3)
        local NavBarDimension = vec3(WindowDimension.x, WindowDimension.y * 0.1, 1)
        local NavBarPosition = vec3(0, WindowDimension.y - NavBarDimension.y, 50)
        local NavBar = Com.NavigationBar:New(NavBarPosition, NavBarDimension, { NavBarElem1, NavBarElem2, NavBarElem3 }, true)

        local ClearNavBarColor = function()
            NavBarElem1:TintColor(vec4(1))
            NavBarElem2:TintColor(vec4(1))
            NavBarElem3:TintColor(vec4(1))
        end

        ClearNavBarColor()
        NavBarElem1:SetFunctions(nil, nil,
            function()
                ClearNavBarColor()
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 1)
                NavBarElem1:TintColor(color_tint)
            end)
        NavBarElem2:SetFunctions(nil, nil,
            function()
                ClearNavBarColor()
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 2)
                NavBarElem2:TintColor(color_tint)
            end)
        NavBarElem3:SetFunctions(nil, nil,
            function()
                ClearNavBarColor()
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 3)
                NavBarElem3:TintColor(color_tint)
            end)

        Com.NewSingleTimeDispatch(
            function ()
                Com.NavigationBar.Dispatch(NavBar, color_navbarind) 
            end
        )

        Com.NavigationBar.Update(NavBar, NavBarPosition, NavBarDimension, 1)


        local vlayout = Com.VLayout:New(0)
        local stack = Com.StackLayout:New(0)
        vlayout:AddComponents({NavBar, Com.VLayout:New(0)}, {0.05, 0.9})
        stack:AddComponents({area, vlayout})
        Window:SetCentralComponent(stack)
    end
    insideWindow()
    Window:End()
    Window:Update(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1))
    SN.Solve(SN.State:New(2, 1), 3000, CallbackFunction)

end