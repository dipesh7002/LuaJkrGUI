local normal_color = Theme.Colors.Button.Normal * 8
local hover_color = Theme.Colors.Button.Hover * 1.4
local large_font = Com.GetFont("font", "large")

SN.Graphics.CreateNNVisualizerWindow = function(CircularGraph)
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "NN Visualize", Com.GetFont("font", "large"))

    local CreateButtonHLayout = Com.HLayout:New(0)
    local CreateButton = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Create")
    CreateButtonHLayout:AddComponents({ CreateButton, Com.HLayout:New(0) }, { 0.5, 1 - 0.5 })

    local RunButtonHLayout = Com.HLayout:New(0)
    local RunButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Train")
    local ClearButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Clear")
    RunButtonHLayout:AddComponents({ RunButton, ClearButton }, { 0.5, 1 - 0.5 })

    local Layer1HLayout = Com.HLayout:New(0)
    local Layer1Text = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Layer1")
    local Layer1TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "2")
    Layer1HLayout:AddComponents({ Layer1Text, Layer1TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer2HLayout = Com.HLayout:New(0)
    local Layer2Text = Com.TextButton:New(vec3(200, 200, 2), vec3(300, 300, 2), large_font, "Layer2")
    local Layer2TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "3")
    Layer2HLayout:AddComponents({ Layer2Text, Layer2TextLineEdit }, { 0.5, 2 - 0.5 })

    local Layer3HLayout = Com.HLayout:New(0)
    local Layer3Text = Com.TextButton:New(vec3(300, 300, 3), vec3(300, 300, 3), large_font, "Layer3")
    local Layer3TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "2")
    Layer3HLayout:AddComponents({ Layer3Text, Layer3TextLineEdit }, { 0.5, 3 - 0.5 })

    local Layer4HLayout = Com.HLayout:New(0)
    local Layer4Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Layer4")
    local Layer4TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1")
    Layer4HLayout:AddComponents({ Layer4Text, Layer4TextLineEdit }, { 0.5, 4 - 0.5 })

    local Input1HLayout = Com.HLayout:New(0)
    local Input1Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Input1")
    local Input1TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1")
    Input1HLayout:AddComponents({ Input1Text, Input1TextLineEdit }, { 0.5, 4 - 0.5 })

    local Input2HLayout = Com.HLayout:New(0)
    local Input2Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Input2")
    local Input2TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "0")
    Input2HLayout:AddComponents({ Input2Text, Input2TextLineEdit }, { 0.5, 4 - 0.5 })

    local PropForwardButtonHLayout = Com.HLayout:New(0)
    local PropForwardButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Propagate Forward")
    PropForwardButtonHLayout:AddComponents({ PropForwardButton, Com.HLayout:New(0) }, { 0.5, 1 - 0.5 })

    local CreateNetworkByPictureHLayout = Com.HLayout:New(0)
    local CreateNetworkByPictureButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Create Net by Pic")
    CreateNetworkByPictureHLayout:AddComponents({ CreateNetworkByPictureButton, Com.HLayout:New(0) }, { 0.5, 1 - 0.5 })

    local PropagateForwardPictureHLayout = Com.HLayout:New(0)
    local PropagateForwardPictureButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Propagate Forward")
    PropagateForwardPictureHLayout:AddComponents({ PropagateForwardPictureButton, Com.HLayout:New(0) }, { 0.5, 1 - 0.5 })

    local PropagateBackwardPictureHLayout = Com.HLayout:New(0)
    local PropagateBackwardPictureButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Propagate Backward")
    PropagateBackwardPictureHLayout:AddComponents({ PropagateBackwardPictureButton, Com.HLayout:New(0) },
        { 0.5, 1 - 0.5 })

    local UpdatePicHLayout = Com.HLayout:New(0)
    local UpdatePicButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Update")
    UpdatePicHLayout:AddComponents({ UpdatePicButton, Com.HLayout:New(0) }, { 0.5, 1 - 0.5 })

    local TrainInverseHLayout = Com.HLayout:New(0)
    local TrainInverseButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Train Inverse")
    TrainInverseHLayout:AddComponents({ TrainInverseButton, Com.HLayout:New(0) }, { 0.5, 1 - 0.5 })

    local TrainingCountHLayout = Com.HLayout:New(0)
    local TrainingCountText = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Count")
    local TrainingCountLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1")
    TrainingCountHLayout:AddComponents({ TrainingCountText, TrainingCountLineEdit }, { 0.5, 4 - 0.5 })

    local HComponents = {
        CreateButtonHLayout,
        RunButtonHLayout,
        Com.HLayout:New(0),
        Layer1HLayout,
        Layer2HLayout,
        Layer3HLayout,
        Layer4HLayout,
        Com.HLayout:New(0),
        Input1HLayout,
        Input2HLayout,
        PropForwardButton,
        Com.HLayout:New(0),
        CreateNetworkByPictureHLayout,
        PropagateForwardPictureHLayout,
        PropagateBackwardPictureHLayout,
        UpdatePicHLayout,
        Com.HLayout:New(0),
        TrainInverseHLayout,
        TrainingCountHLayout,
        Com.HLayout:New(0)

    }

    local HComponentsRatio = {}
    for i = 1, #HComponents, 1 do
        HComponentsRatio[i] = 0.04
    end
    HComponentsRatio[#HComponentsRatio] = 1 - (0.04 * (#HComponents - 1))

    local VLayout = Com.VLayout:New(0)
    VLayout:AddComponents(HComponents, HComponentsRatio)
    Window:SetCentralComponent(VLayout)


    local mero_NN = {}
    local GetTopologyByTextFieldsLayer = function()
        local layer1_neurons = tonumber(Layer1TextLineEdit:GetText())
        local layer2_neurons = tonumber(Layer2TextLineEdit:GetText())
        local layer3_neurons = tonumber(Layer3TextLineEdit:GetText())
        local layer4_neurons = tonumber(Layer4TextLineEdit:GetText())
        return { layer1_neurons, layer2_neurons, layer3_neurons, layer4_neurons }
    end

    RunButton:SetFunctions(
        function()
            RunButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            RunButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            for i = 1, 50, 1 do
                Com.NewSimulataneousDispatch()
                Com.NewSimultaneousUpdate()
                Com.NewSimultaneousSingleTimeUpdate(
                    function()
                        mero_NN:Train(500)
                        SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph)
                    end
                )
            end
        end
    )

    ClearButton:SetFunctions(
        function()
            ClearButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            ClearButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            Com.ClearSingleTimes()
            SN.Graphics.CircularGraph.Clear(CircularGraph, vec4(1, 1, 1, 0))
        end
    )


    PropForwardButton:SetFunctions(
        function()
            PropForwardButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            PropForwardButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            local input1 = tonumber(Input1TextLineEdit:GetText())
            local input2 = tonumber(Input2TextLineEdit:GetText())
            mero_NN:PropagateForward({ input1, input2 })
            SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph)
        end
    )


    CreateButton:SetFunctions(
        function()
            CreateButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            CreateButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            mero_NN = NN.SimpleNN:New(GetTopologyByTextFieldsLayer())
            Com.ClearSingleTimes()
            SN.Graphics.CircularGraph.Clear(CircularGraph, vec4(1, 1, 1, 0))
            SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph, true)
        end
    )

    CreateNetworkByPictureButton:SetFunctions(
        function()
            CreateNetworkByPictureButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            CreateNetworkByPictureButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color
                .w))
        end,
        function()
            local c = SN.Graphics.InputPictureCanvas
            local o = SN.Graphics.OutputPictureCanvas
            local topology = GetTopologyByTextFieldsLayer()
            mero_NN = NN.SimpleNN:New(topology)
            Com.ClearSingleTimes()
            local inputSize = math.round(math.sqrt(topology[1]))
            local outputSize = math.round(math.sqrt(topology[#topology]))
            if inputSize ~= SN.Graphics.InputPictureCanvas.mXSize or outputSize ~= SN.Graphics.OutputPictureCanvas.mXSize then
                print("hi")
                local inputCanvas = SN.Graphics.MakePictureCanvas(inputSize, inputSize)
                local outputCanvas = SN.Graphics.MakePictureCanvas(outputSize, outputSize)
                local expectOutCanvas = SN.Graphics.MakePictureCanvas(outputSize, outputSize)
                SN.Graphics.PictureWindow = SN.Graphics.MakePictureWindow(inputCanvas, outputCanvas, expectOutCanvas)
                SN.Graphics.PictureWindow:Update(vec3(WindowDimension.x - 600, WindowDimension.y - 600, 80), vec3(200, 600, 80))
            end
            SN.Graphics.CircularGraph.Clear(CircularGraph, vec4(1, 1, 1, 0))
            Com.NewSingleTimeUpdate(function () SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph, true) end)
        end
    )

    local propForward = function()
        local ImageF = Com.Canvas.GetVectorFloatSingleChannel(SN.Graphics.InputPictureCanvas)
        mero_NN:PropagateForwardVecFloat(ImageF)
        local Output = NN.SimpleNN.GetOutputFloatVec(mero_NN, #mero_NN.mTopology - 1)
        Com.NewSimultaneousSingleTimeDispatch(
            function()
                Com.Canvas.DrawClearFromFloatSingleChannel(SN.Graphics.OutputPictureCanvas, Output)
            end
        )
        SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph, true)
    end
    local propBackward = function()
        local ImageF = Com.Canvas.GetVectorFloatSingleChannel(SN.Graphics.ExpectedOutputPictureCanvas)
        mero_NN:PropagateBackwardVecFloat(ImageF)
        SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph, true)
    end

    PropagateForwardPictureButton:SetFunctions(
        function()
            PropagateForwardPictureButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            PropagateForwardPictureButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z,
                normal_color.w))
        end,
        function()
            Com.NewSimultaneousSingleTimeUpdate(propForward)
        end
    )

    PropagateBackwardPictureButton:SetFunctions(
        function()
            PropagateBackwardPictureButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            PropagateBackwardPictureButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z,
                normal_color.w))
        end,
        function()
            Com.NewSimultaneousSingleTimeUpdate(propBackward)
        end
    )

    UpdatePicButton:SetFunctions(
        function()
            UpdatePicButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            UpdatePicButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph, true)
        end
    )

    local trainInverse = function()
        local i = SN.Graphics.InputPictureCanvas
        local eo = SN.Graphics.ExpectedOutputPictureCanvas
        local o = SN.Graphics.OutputPictureCanvas
        local InputOutputImageFloats = NN.ImageGetRandomInputInverseOutput(i.mXSize * i.mYSize, o.mXSize * o.mYSize)
        mero_NN:PropagateForwardVecFloat(InputOutputImageFloats[1])
        mero_NN:PropagateBackwardVecFloat(InputOutputImageFloats[2])
        local Output = NN.SimpleNN.GetOutputFloatVec(mero_NN, #mero_NN.mTopology - 1)


        Com.NewSimultaneousSingleTimeDispatch(
            function()
                Com.Canvas.DrawClearFromFloatSingleChannel(i, InputOutputImageFloats[1])
                Com.Canvas.DrawClearFromFloatSingleChannel(eo, InputOutputImageFloats[2])
                Com.Canvas.DrawClearFromFloatSingleChannel(o, Output)
            end
        )
        -- Com.NewSimultaneousSingleTimeUpdate(
        --     function()
        --         SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph, true)
        --     end
        -- )
    end

    TrainInverseButton:SetFunctions(
        function()
            TrainInverseButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            TrainInverseButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            local Itrs = tonumber(TrainingCountLineEdit:GetText())
            for i = 1, Itrs, 1 do
                trainInverse()
            end
        end
    )
    return Window
end
