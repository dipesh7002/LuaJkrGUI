local normal_color = Theme.Colors.Button.Normal * 8
local hover_color = Theme.Colors.Button.Hover * 1.4
local large_font = Com.GetFont("font", "large")
SN.Graphics.PathGame = {}
SN.Graphics.PathGame.DX = 8
SN.Graphics.PathGame.DY = 8

SN.Graphics.CreateProblem3SolverWindow = function(inCircularGraph)
    local pg = SN.Graphics.PathGame
    local problem = SN.Core.CreateSnakeProblem(pg.DX)
    problem.InitImage()

    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "Path Problem", Com.GetFont("font", "large"))
    SN.Graphics.PathGame = SN.Graphics.MakePictureCanvas(pg.DX, pg.DY)
    local VLayout = Com.VLayout:New(0)
    local VLayoutUIs = Com.VLayout:New(0)

    local RandomizeHLayout = Com.HLayout:New(0)
    local RandomizeButton = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "Randomize")
    local TowardsFood = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "TowardsFood")
    RandomizeHLayout:AddComponents({ RandomizeButton, TowardsFood }, { 0.5, 1 - 0.5 })

    local PropagateForwardHLayout = Com.HLayout:New(0)
    local PropagateForwardButton = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "PropagateForward")
    local PropagateBackward = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "PropagateBackward")
    PropagateForwardHLayout:AddComponents({ PropagateForwardButton, PropagateBackward }, { 0.5, 1 - 0.5 })

    local TrainHLayout = Com.HLayout:New(0)
    local TrainButtonBP = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "Train BP")
    local TrainButtonHP = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "Train SA")
    TrainHLayout:AddComponents({ TrainButtonBP, TrainButtonHP }, { 0.5, 1 - 0.5 })

    local TrainingCountHLayout = Com.HLayout:New(0)
    local TrainingCountText = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Count")
    local TrainingCountLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1")
    TrainingCountHLayout:AddComponents({ TrainingCountText, TrainingCountLineEdit }, { 0.5, 1 - 0.5 })

    local HComponents = {
        RandomizeHLayout,
        PropagateForwardHLayout,
        TrainHLayout,
        TrainingCountHLayout,
        Com.VLayout:New(0)
    }
    local HComponentsRatio = {}
    for i = 1, #HComponents, 1 do
        HComponentsRatio[i] = 0.04 * 2
    end
    HComponentsRatio[#HComponentsRatio] = 1 - (0.04 * 2 * (#HComponents - 1))
    VLayoutUIs:AddComponents(HComponents, HComponentsRatio)

    VLayout:AddComponents({ SN.Graphics.PathGame, VLayoutUIs }, { 0.5, 1 - 0.5 })

    Window:SetCentralComponent(VLayout)

    RandomizeButton:SetFunctions(
        function()
            RandomizeButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            RandomizeButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            problem.ClearImage()
            problem.RandomlyPutFoodAndSnake()
            Com.NewSimultaneousSingleTimeDispatch(
                function()
                    Com.Canvas.DrawClearFromFloatSingleChannel(SN.Graphics.PathGame, problem.GetImage())
                end
            )
        end
    )

    TowardsFood:SetFunctions(
        function()
            TowardsFood:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            TowardsFood:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            -- problem.ClearImage()
            local i = 5000
            while i ~= 0.0 do
                i = problem.MoveTowardsFood()[2]
                Com.NewSimultaneousSingleTimeDispatch(
                    function()
                        Com.Canvas.DrawClearFromFloatSingleChannel(SN.Graphics.PathGame, problem.GetImage())
                    end
                )
            end
        end
    )

    local PropForward = function()
        local mero_NN = SN.Graphics.GetCurrentNN()
        mero_NN:PropagateForwardVecFloat(problem.GetImage())
        local Output = NN.SimpleNN.GetOutputFloatVec(mero_NN, #mero_NN.mTopology - 1)

        local max = math.max(0, math.round(Output[1]))
        local max_i = 0
        for i = 1, #Output, 1 do
            if Output[i] > max then
                max_i = i; max = Output[i]
            end
        end
        problem.Move(max_i)

        Com.NewSimultaneousSingleTimeUpdate(function()
            SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, inCircularGraph, true)
            Com.NewSimultaneousSingleTimeDispatch(
                function()
                    Com.Canvas.DrawClearFromFloatSingleChannel(SN.Graphics.PathGame, problem.GetImage())
                end
            )
        end)
    end

    PropagateForwardButton:SetFunctions(
        function()
            PropagateForwardButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            PropagateForwardButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        PropForward
    )


    local problem_to_be_fed = SN.Core.CreateSnakeProblem(pg.DX)
    problem_to_be_fed.InitImage()

    local trainBP = function()
        local mero_NN = SN.Graphics.GetCurrentNN()

        for i = 1, tonumber(TrainingCountLineEdit:GetText()), 1 do
            -- problem_to_be_fed.ClearImage()
            problem_to_be_fed.RandomlyPutFoodAndSnake()
            local ii = 5000
            while ii ~= 0.0 do
                mero_NN:PropagateForwardVecFloat(problem_to_be_fed.GetImage())
                local eo_i = problem_to_be_fed.MoveTowardsFood()
                ii = eo_i[2]
                print("Dist", ii)
                local ExpectedOutput = eo_i[1]
                local vecfloatExpOutput = std_vector_float()
                for i = 1, #ExpectedOutput, 1 do
                    vecfloatExpOutput:add(ExpectedOutput[i])
                end
                mero_NN:PropagateBackwardVecFloat(ExpectedOutput)
            end
        end
        -- Com.NewSimultaneousSingleTimeDispatch(
        --     function()
        --         Com.Canvas.DrawClearFromFloatSingleChannel(SN.Graphics.PathGame, problem.GetImage())
        --     end
        -- )
    end

    TrainButtonBP:SetFunctions(
        function()
            TrainButtonBP:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            TrainButtonBP:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        trainBP
    )

    return Window
end
