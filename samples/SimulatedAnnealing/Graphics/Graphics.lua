require "samples.SimulatedAnnealing.Graphics.CircularGraph"
require "samples.SimulatedAnnealing.Graphics.P1"
require "samples.SimulatedAnnealing.Graphics.P2"
require "samples.SimulatedAnnealing.Graphics.P3"

SN.Graphics.CreateProblemWindowsLayout = function(inTable)
    local problemWindows = Com.HLayout:New(0)
    problemWindows.mCurrentWindow = 1
    local Window1 = SN.Graphics.CreateNumberPythagoreanTripletSolverWindow(inTable[1])
    local Window2 = SN.Graphics.CreateNNVisualizerWindow(inTable[2])
    local Window3 = SN.Graphics.CreateProblem3SolverWindow(inTable[3])
    problemWindows.Update = function(self, inPosition_3f, inDimension_3f, inWindowNo, inInverseSpeed)
        if inWindowNo then
            self.mCurrentWindow = inWindowNo
        end
        local newPos = vec3(inPosition_3f.x - (inDimension_3f.x) * (self.mCurrentWindow - 1), inPosition_3f.y,
            inPosition_3f.z)
        local newDimen = vec3(inDimension_3f.x * 3, inDimension_3f.y, inDimension_3f.z)

        local invspeed = 0.1
        if inInverseSpeed then
            invspeed = inInverseSpeed
        end

        if inWindowNo then
            local oldPos = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
            local oldDimen = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
            local from = { mPosition_3f = oldPos, mDimension_3f = oldDimen }
            local to = { mPosition_3f = newPos, mDimension_3f = newDimen }
            Com.AnimateSingleTimePosDimenCallback(from, to, invspeed,
                function(pos, dimen)
                    Com.HLayout.Update(self, pos, dimen)
                end,
                function()
                    self.mPosition_3f = inPosition_3f
                    self.mDimension_3f = inDimension_3f
                    for i=1, #self.mComponents do
                        if i ~= inWindowNo then
                            self.mComponents[i]:Update(vec3(0), vec3(0))
                        end
                    end
                end)
            Com.HLayout.Update(self, newPos, newDimen)
        else
            Com.HLayout.Update(self, newPos, newDimen)
        end

        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
    end

    problemWindows:AddComponents({ Window1, Window2, Window3 }, { 1 / 3, 1 / 3, 1 / 3 })
    return problemWindows
end

SN.Graphics.MakePictureCanvas = function(inX, inY)
    local Canvas = Com.Canvas:New(vec3(0), vec3(0))
    Com.Canvas.AddPainterBrush(Canvas, Com.GetCanvasPainter("Clear", false))
    Com.Canvas.MakeCanvasImage(Canvas, inX, inY)
    Com.NewSimulataneousDispatch()
    Com.NewSimultaneousSingleTimeDispatch(function()
        Canvas.CurrentBrushId = 1
        Com.Canvas.Bind(Canvas)
        Com.Canvas.Paint(Canvas, vec4(0, 0, inX, inY), vec4(1, 0, 0, 1), vec4(0), inX, inY, 1)
    end)
    Canvas.mXSize = inX
    Canvas.mYSize = inY
    return Canvas
end

SN.Graphics.InputPictureCanvas = {}
SN.Graphics.OutputPictureCanvas = {}
SN.Graphics.ExpectedOutputPictureCanvas = {}

SN.Graphics.MakePictureWindow = function(InputPicCanvas, OutputPicCanvas, ExpectedOutputPictureCanvas)
    local PictureWindow = Com.MaterialWindow:New(vec3(WindowDimension.x - 600, WindowDimension.y - 600, 80), vec3(200, 600, 80), vec2(200, 30),
        "PD",
        Com.GetFont("font", "large"))
    PictureWindow:Start()
    SN.Graphics.InputPictureCanvas = InputPicCanvas
    SN.Graphics.OutputPictureCanvas = OutputPicCanvas
    SN.Graphics.ExpectedOutputPictureCanvas = ExpectedOutputPictureCanvas
    local VLayout = Com.VLayout:New(5)
    VLayout:AddComponents(
    { SN.Graphics.InputPictureCanvas, SN.Graphics.OutputPictureCanvas, SN.Graphics.ExpectedOutputPictureCanvas },
        { 1 / 3, 1 / 3, 1 / 3 })
    PictureWindow:SetCentralComponent(VLayout)
    PictureWindow:End()
    PictureWindow:Update(vec3(0), vec3(0))
    return PictureWindow
end

SN.Graphics.CreateGUI = function()
    local Background = Com.Canvas:New(vec3(-WindowDimension.x /2, -WindowDimension.y / 2, 83), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))
    -- local Graph = SN.Graphics.CircularGraph:New(vec3(0), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))
    -- SN.Graphics.CircularGraph.Clear(Graph, vec4(0, 0, 1, 0.5))
	Jkr.GLSL["GradientBackgroundCanvas"] = CanvasHeader .. [[
        float xxx = push.mParam.x;
        float range = (0.7 - 0.5) / 2;
        float offset = (0.7 + 0.5) / 2;
        float sinR = range * sin((2 * 3.1415 / 0.5) * xxx + 0.5) + offset;
        float x_ = 1 -  to_draw_at.x  / 10 * (1 - sinR);
        float y_ = 1 -  to_draw_at.y  / 10 * sinR;
        float oldx = x_;
        float oldy = y_;
        x_ = smoothstep(oldy, 0.3, oldx);
        y_ = smoothstep(oldx, 0.3, oldy);
        float z = 0.5;
        vec4 final_color = vec4(x_ + 0.8, 0, 0.5 + y_, 1);
		imageStore(storageImage, to_draw_at, final_color);
	]]
    Com.Canvas.AddPainterBrush(Background, Com.GetCanvasPainter("Clear", false))
    Com.Canvas.AddPainterBrush(Background, Com.GetCanvasPainter("GradientBackground", true))
    Com.Canvas.MakeCanvasImage(Background, 1920 / 2, 1080 / 2)
    Background:Update(vec3(-WindowDimension.x /2, -WindowDimension.y / 2, 90), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))
    --Graph:Update(vec3(0, 0, 83), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))
    local NewGraph = SN.Graphics.CircularGraph:New(vec3(0), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))
    NewGraph:Update(vec3(0, 0, 80), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))
    SN.Graphics.CircularGraph.Clear(NewGraph, vec4(0, 1, 1, 0.1))
    Background:Update(vec3(-WindowDimension.x /2, -WindowDimension.y / 2, 82), vec3(WindowDimension.x * 2, WindowDimension.y * 2, 1))

    --Graph:Update(vec3(0, 0, 80), vec3(0))
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(350, 30), "Simulated Annealing", Com.GetFont("font", "large"))
    -- TODO Error In Canvas NavBar if initialized here IDK Why
    Window:Start()
    local insideWindow = function()
        local area = Com.AreaObject:New(vec3(0), vec3(0))
        Com.AreaObject.SetFillColor(area, vec4(0.8, 0.8, 0.8, 0.5))
        local color_navbarind = vec4(0.5, 0.1, 0.2, 1)
        local color_tint = vec4(1, 0, 0, 0.01)

        local NavBarElem1 = Com.AreaButton:New(vec3(0), vec3(0))
        local NavBarElem2 = Com.AreaButton:New(vec3(0), vec3(0))
        local NavBarElem3 = Com.AreaButton:New(vec3(0), vec3(0))

        local NavBarDimension = vec3(WindowDimension.x, WindowDimension.y * 0.1, 1)
        local NavBarPosition = vec3(0, WindowDimension.y - NavBarDimension.y, 50)
        local NavBar = Com.NavigationBar:New(NavBarPosition, NavBarDimension, { NavBarElem1, NavBarElem2, NavBarElem3 },
            true)

        local ClearNavBarColor = function()
            NavBarElem1:TintColor(vec4(0.5))
            NavBarElem2:TintColor(vec4(0.5))
            NavBarElem3:TintColor(vec4(0.5))
        end
        ClearNavBarColor()

        local problemWindows = SN.Graphics.CreateProblemWindowsLayout({ NewGraph, NewGraph, NewGraph })

        Com.NavigationBar.Update(NavBar, NavBarPosition, NavBarDimension, 1)
        local vlayout = Com.VLayout:New(0)
        local stack = Com.StackLayout:New(0)
        vlayout:AddComponents({ NavBar, problemWindows }, { 0.05, 0.9 })
        stack:AddComponents({ area, vlayout })
        Window:SetCentralComponent(stack)

        NavBarElem1:SetFunctions(
            function() NavBarElem1:TintColor(color_tint) end,
            function() NavBarElem1:TintColor(vec4(0.1)) end,
            function()
                ClearNavBarColor()
                problemWindows:Update(problemWindows.mPosition_3f, problemWindows.mDimension_3f, 1, 0.2)
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 1, 0.2)
            end)
        NavBarElem2:SetFunctions(
            function() NavBarElem2:TintColor(color_tint) end,
            function() NavBarElem2:TintColor(vec4(0.1)) end,
            function()
                ClearNavBarColor()
                problemWindows:Update(problemWindows.mPosition_3f, problemWindows.mDimension_3f, 2, 0.2)
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 2, 0.2)
            end)
        NavBarElem3:SetFunctions(
            function() NavBarElem3:TintColor(color_tint) end,
            function() NavBarElem3:TintColor(vec4(0.1)) end,
            function()
                ClearNavBarColor()
                problemWindows:Update(problemWindows.mPosition_3f, problemWindows.mDimension_3f, 3, 0.2)
                Com.NavigationBar.Animate(NavBar, NavBar.mPosition_3f, NavBar.mDimension_3f, 3, 0.2)
            end)

        Com.NewSimultaneousSingleTimeDispatch(
            function()
                Com.NavigationBar.Dispatch(NavBar, color_navbarind)
            end
        )
    end
    insideWindow()
    Window:End()
    Window:Update(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1))
    SN.Graphics.PictureWindow = nil

    local background_i = 0
    Com.NewComponent_Dispatch()
    local canvas = Com.Canvas
    ComTable_Dispatch[com_disi] = Jkr.Components.Abstract.Dispatchable:New(
        function ()
            Background.CurrentBrushId = 2
            canvas.Bind(Background)	
            canvas.Paint(Background, vec4(0, 0, 1920 / 2, 1080 /2 ), vec4(1, 0, 0, 1), vec4(math.sin(background_i / 500), 0.4, 0, 0), 1920 / 2, 1080 /2, 1)
            background_i = background_i + 1
        end
    )

    Com.NewEvent(
        function()
            if E.is_keypress_event() and E.is_key_pressed(Key.SDLK_SPACE) then
                Window:Update(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1))
                if SN.Graphics.PictureWindow then
                    SN.Graphics.PictureWindow:Update(vec3(WindowDimension.x - 600, WindowDimension.y - 600, 80), vec3(200, 600, 80))
                end
            end
        end
    )

    Com.NewUpdate(
        function ()
           if E.is_key_pressed_continous(Key.SDL_SCANCODE_LALT) and E.is_left_button_pressed_continous() then
                local relmousepos = E.get_relative_mouse_pos() 
                NewGraph.mPosition_3f.x  = NewGraph.mPosition_3f.x + relmousepos.x
                NewGraph.mPosition_3f.y = NewGraph.mPosition_3f.y + relmousepos.y
                SN.Graphics.CircularGraph.Update(NewGraph, NewGraph.mPosition_3f, NewGraph.mDimension_3f)
           end
        end
    )
    -- SN.Graphics.CircularGraph.Clear(Graph, vec4(0, 0, 0, 0))
    --]]

    collectgarbage("collect")
end
