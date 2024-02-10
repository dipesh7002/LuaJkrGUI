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
    New = function(self, inPosition_3f, inDimension_3f)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mCanvas = Com.Canvas:New(inPosition_3f, inDimension_3f)
        Com.Canvas.AddPainterBrush(Obj.mCanvas, Com.GetCanvasPainter("Clear", false))
        Com.Canvas.AddPainterBrush(Obj.mCanvas, Com.GetCanvasPainter("SimulatedAnnealingCircleGraph", false))
        Com.Canvas.MakeCanvasImage(Obj.mCanvas, inDimension_3f.x, inDimension_3f.y)

        Com.NewSingleTimeDispatch(function()
            Obj.mCanvas.CurrentBrushId = 1
            Com.Canvas.Bind(Obj.mCanvas)
            Com.Canvas.Paint(Obj.mCanvas, vec4(0, 0, inDimension_3f.x, inDimension_3f.y), vec4(1, 1, 1, 1),
                vec4(1.2, 0, 0, 1), inDimension_3f.x, inDimension_3f.y, 1)
        end)
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mCanvas:Update(inPosition_3f, inDimension_3f)
    end,
    PlotAt = function(self, inX, inY, inW, inH, inColor_4f, inBrushId)
        Com.NewSingleTimeDispatch(function()
            self.mCanvas.CurrentBrushId = inBrushId
            Com.Canvas.Bind(self.mCanvas)
            Com.Canvas.Paint(self.mCanvas, vec4(inX, inY, inW, inH), inColor_4f, vec4(1.2, 0, 0, 1), inW, inH, 1)
        end)
    end
}

SN.Graphics.CreateNumberSumSolverWindow = function()
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "Sum Two Numbers", Com.GetFont("font", "large"))

    Window:SetCentralComponent(Com.VLayout:New(0))
    return Window
end

SN.Graphics.CreateProblem2SolverWindow = function()
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "Problem 1", Com.GetFont("font", "large"))

    Window:SetCentralComponent(Com.VLayout:New(0))
    return Window
end

SN.Graphics.CreateProblem3SolverWindow = function()
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "Problem 2", Com.GetFont("font", "large"))

    Window:SetCentralComponent(Com.VLayout:New(0))
    return Window
end

SN.Graphics.CreateProblemWindowsLayout = function(inPosition_3f, inDimension_3f)
    local problemWindows = Com.HLayout:New(0)
    problemWindows.mCurrentWindow = 1
    local Window1 = SN.Graphics.CreateNumberSumSolverWindow()
    local Window2 = SN.Graphics.CreateProblem2SolverWindow()
    local Window3 = SN.Graphics.CreateProblem3SolverWindow()
    problemWindows.Update = function(self, inPosition_3f, inDimension_3f, inWindowNo)
        local oldPos = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local oldDimen = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        if inWindowNo then
            self.mCurrentWindow = inWindowNo
        end

        local newPos = vec3(inPosition_3f.x - (inDimension_3f.x) * (self.mCurrentWindow - 1), inPosition_3f.y,
            inPosition_3f.z)
        local newDimen = vec3(inDimension_3f.x * 3, inDimension_3f.y, inDimension_3f.z)


        if inWindowNo then
            local from = {mPosition_3f = oldPos, mDimension_3f = oldDimen}
            local to = {mPosition_3f = newPos, mDimension_3f = newDimen}
            Com.AnimateSingleTimePosDimenCallback(from, to, 0.1, function (pos, dimen)
                Com.HLayout.Update(self, pos, dimen)
            end, function ()
                self.mPosition_3f = inPosition_3f
                self.mDimension_3f = inDimension_3f
            end)    
        else
            Com.HLayout.Update(self, newPos, newDimen)
        end


        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
    end

    problemWindows:AddComponents({ Window1, Window2, Window3 }, { 1 / 3, 1 / 3, 1 / 3 })
    return problemWindows
end

SN.Graphics.CreateGUI = function()
    LoadMaterialComponents(true)
    local Graph = SN.Graphics.CircularGraph:New(vec3(0), vec3(WindowDimension.x, WindowDimension.y, 1))
    local CallbackFunction = function(inS, inT)
        local Energy = SN.E(inS)
        local Temperature = inT / SN.InitialTemperature
        local EnergyVisualFactor = 3
        local i = inS.i
        local j = inS.j
        local rand_color = vec4(1 - Temperature, math.random(), math.random(), 1)
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
        local NavBar = Com.NavigationBar:New(NavBarPosition, NavBarDimension, { NavBarElem1, NavBarElem2, NavBarElem3 },
            true)

        local ClearNavBarColor = function()
            NavBarElem1:TintColor(vec4(1))
            NavBarElem2:TintColor(vec4(1))
            NavBarElem3:TintColor(vec4(1))
        end

        ClearNavBarColor()



        local problemWindows = SN.Graphics.CreateProblemWindowsLayout()

        Com.NavigationBar.Update(NavBar, NavBarPosition, NavBarDimension, 1)
        local vlayout = Com.VLayout:New(0)
        local stack = Com.StackLayout:New(0)
        vlayout:AddComponents({ NavBar, problemWindows }, { 0.05, 0.9 })
        stack:AddComponents({ area, vlayout })
        Window:SetCentralComponent(stack)

        NavBarElem1:SetFunctions(nil, nil,
            function()
                ClearNavBarColor()
                problemWindows:Update(problemWindows.mPosition_3f, problemWindows.mDimension_3f, 1)
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 1)
                NavBarElem1:TintColor(color_tint)
            end)
        NavBarElem2:SetFunctions(nil, nil,
            function()
                ClearNavBarColor()
                problemWindows:Update(problemWindows.mPosition_3f, problemWindows.mDimension_3f, 2)
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 2)
                NavBarElem2:TintColor(color_tint)
            end)
        NavBarElem3:SetFunctions(nil, nil,
            function()
                ClearNavBarColor()
                problemWindows:Update(problemWindows.mPosition_3f, problemWindows.mDimension_3f, 3)
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 3)
                NavBarElem3:TintColor(color_tint)
            end)

        Com.NewSingleTimeDispatch(
            function()
                Com.NavigationBar.Dispatch(NavBar, color_navbarind)
            end
        )
    end
    insideWindow()
    Window:End()
    Window:Update(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1))
    SN.Solve(SN.State:New(150, 0), 3000, CallbackFunction)
end
