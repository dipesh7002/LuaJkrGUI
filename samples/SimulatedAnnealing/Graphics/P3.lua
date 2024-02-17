local normal_color = Theme.Colors.Button.Normal * 8
local hover_color = Theme.Colors.Button.Hover * 1.4
local large_font = Com.GetFont("font", "large")

SN.Graphics.CreateProblem3SolverWindow = function(inTable)
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "Problem 2", Com.GetFont("font", "large"))

    Window:SetCentralComponent(Com.VLayout:New(0))
    return Window
end