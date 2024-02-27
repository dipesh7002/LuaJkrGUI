local normal_color = Theme.Colors.Button.Normal * 8
local hover_color = Theme.Colors.Button.Hover * 1.4
normal_color.w = 0.7
hover_color.w = 0.5
local large_font = Com.GetFont("font", "large")
local area_color = vec4(0.8, 0.8, 0.8, 0.5)

SN.Graphics.CreateNumberPythagoreanTripletSolverWindow = function(CircularGraph)
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "Pythagorean Triplet", large_font)

    -- TODO event system optimization
    local RunButtonHLayout = Com.HLayout:New(0)
    local RunButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Run")
    local IterationsText = Com.TextButton:New(vec3(0), vec3(0), large_font, "Iterations")
    RunButtonHLayout:AddComponents({ RunButton, IterationsText }, { 0.5, 1 - 0.5 })

    local ClearButtonHLayout = Com.HLayout:New(0)
    local StopButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Stop")
    local ClearAllButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Clear")
    ClearButtonHLayout:AddComponents({ StopButton, ClearAllButton }, { 0.5, 1 - 0.5 })

    local TemperatureHLayout = Com.HLayout:New(0)
    local TemperatureText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Temperature")
    local TemperatureTextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1000")
    TemperatureHLayout:AddComponents({ TemperatureText, TemperatureTextLineEdit }, { 0.5, 1 - 0.5 })

    local IterationCountHLayout = Com.HLayout:New(0)
    local IterationCountText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Iterations")
    local IterationCountTextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "500")
    IterationCountHLayout:AddComponents({ IterationCountText, IterationCountTextLineEdit }, { 0.5, 1 - 0.5 })

    local SumOfCountHLayout = Com.HLayout:New(0)
    local SumOfCountText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Third Number")
    local SumOfCountTextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "50")
    SumOfCountHLayout:AddComponents({ SumOfCountText, SumOfCountTextLineEdit }, { 0.5, 1 - 0.5 })

    local NumIHLayout = Com.HLayout:New(0)
    local NumIText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "State:I")
    local NumITextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "3")
    NumIHLayout:AddComponents({ NumIText, NumITextLineEdit }, { 0.5, 1 - 0.5 })

    local NumJHLayout = Com.HLayout:New(0)
    local NumJText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "State:J")
    local NumJTextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "4")
    NumJHLayout:AddComponents({ NumJText, NumJTextLineEdit }, { 0.5, 1 - 0.5 })

    local SizeFactorHLayout = Com.HLayout:New(0)
    local SizeFactorText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "SizeFactor:")
    local SizeFactorTextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1")
    SizeFactorHLayout:AddComponents({ SizeFactorText, SizeFactorTextLineEdit }, { 0.5, 1 - 0.5 })

    local StatusText = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Status")
    local StatusText1 = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, " ")
    local StatusText2 = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, " ")
    local StatusText3 = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, " ")
    local StatusText4 = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, " ")
    local StatusText5 = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, " ")

    StatusText1:SetFillColor(vec4(0, 0, 0, 0))
    StatusText2:SetFillColor(vec4(0, 0, 0, 0))
    StatusText3:SetFillColor(vec4(0, 0, 0, 0))
    StatusText4:SetFillColor(vec4(0, 0, 0, 0))
    StatusText5:SetFillColor(vec4(0, 0, 0, 0))

    local HComponents = {
        RunButtonHLayout,
        ClearButtonHLayout,
        Com.HLayout:New(0),
        TemperatureHLayout,
        IterationCountHLayout,
        SumOfCountHLayout,
        Com.HLayout:New(0),
        NumIHLayout,
        NumJHLayout,
        SizeFactorHLayout,
        Com.HLayout:New(0),
        StatusText,
        StatusText1,
        StatusText2,
        StatusText3,
        StatusText4,
        StatusText5,
        Com.HLayout:New(0)
    }

    -- local HComponentsRatio = {0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 0.04, 1 - (0.04 * (#HComponents - 1))}
    local HComponentsRatio = {}
    for i = 1, #HComponents, 1 do
        HComponentsRatio[i] = 0.04
    end
    HComponentsRatio[#HComponentsRatio] = 1 - (0.04 * (#HComponents - 1))



    local VLayout = Com.VLayout:New(0)
    VLayout:AddComponents(HComponents, HComponentsRatio)
    Window:SetCentralComponent(VLayout)

    -- Note, not a good name, not a good heuristic
    local IterationsMax__ = 1000
    local SizeFactor__ = 3
    local gcg = SN.Graphics.CircularGraph
    local CallbackFunction = function(inS, inT, inK, inS_new)
        local Energy = SN.E(inS)
        local Temperature = inT / SN.InitialTemperature
        IterationsText:Update(IterationsText.mPosition_3f, IterationsText.mDimension_3f,
            tostring(Int(IterationsMax__ - inK)))
        StatusText1:Update(StatusText1.mPosition_3f, StatusText1.mDimension_3f,
            string.format("Accepted(%d, %d)", inS.i, inS.j))
        StatusText2:Update(StatusText2.mPosition_3f, StatusText2.mDimension_3f,
            string.format("New(%d, %d)", inS_new.i, inS_new.j))
        StatusText3:Update(StatusText3.mPosition_3f, StatusText3.mDimension_3f, string.format("(T%f, E%f)", inT, Energy))
        local rand_color = vec4(1 - Temperature, math.random(), math.random(), 1)
        local visualEnergy = Energy
        if SizeFactor__ == 0 then
            visualEnergy = 200
        else
            visualEnergy = Energy * SizeFactor__
        end

        if visualEnergy >= 10000 then
            visualEnergy = 100
        end

        gcg.PlotAt(CircularGraph, inS.i, inS.j, visualEnergy, visualEnergy,
            rand_color, 2)
    end
    RunButton:SetFunctions(
        function()
            RunButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            RunButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            local Iterations = tonumber(IterationCountTextLineEdit:GetText())
            local SumTo = tonumber(SumOfCountTextLineEdit:GetText())
            local Temperature = tonumber(TemperatureTextLineEdit:GetText())
            local I = tonumber(NumITextLineEdit:GetText())
            local J = tonumber(NumJTextLineEdit:GetText())
            local SizeFactor = tonumber(SizeFactorTextLineEdit:GetText())
            if Iterations then
                IterationsMax__ = Iterations
            end
            if SizeFactor then
                SizeFactor__ = SizeFactor
            end

            Com.ClearSingleTimes()
            SN.Core.SetProblem_PythagoreanTriplet(Temperature, SumTo)
            SN.Solve(SN.State:New(I, J), Iterations, CallbackFunction)
        end
    )

    StopButton:SetFunctions(
        function()
            StopButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            StopButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            Com.ClearSingleTimes()
        end
    )

    ClearAllButton:SetFunctions(
        function()
            ClearAllButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            ClearAllButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            Com.ClearSingleTimes()
            SN.Graphics.CircularGraph.Clear(CircularGraph, vec4(1, 1, 1, 0))
        end
    )
    return Window
end