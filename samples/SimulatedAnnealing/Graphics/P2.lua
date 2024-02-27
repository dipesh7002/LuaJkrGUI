local normal_color = Theme.Colors.Button.Normal * 8
local hover_color = Theme.Colors.Button.Hover * 1.4
normal_color.w = 0.7
hover_color.w = 0.5
local large_font = Com.GetFont("font", "large")
local area_color = vec4(0.8, 0.8, 0.8, 0.5)

SN.Graphics.LayerListWindow = nil
SN.Graphics.CreatePopupLayerListWindow = function(inFunction)
    local AreaO = Com.AreaObject:New(vec3(0), vec3(0))
    Com.AreaObject.SetFillColor(AreaO, area_color)
    SN.Graphics.LayerListWindow = Com.MaterialWindow:New(vec3(0), vec3(0), vec2(400, 30), "CreateNN",
        Com.GetFont("font", "large"))

    local Layer1HLayout = Com.HLayout:New(0)
    local Layer1Text = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Layer1")
    local Layer1TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "25")
    Layer1HLayout:AddComponents({ Layer1Text, Layer1TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer2HLayout = Com.HLayout:New(0)
    local Layer2Text = Com.TextButton:New(vec3(200, 200, 2), vec3(300, 300, 2), large_font, "Layer2")
    local Layer2TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "6")
    Layer2HLayout:AddComponents({ Layer2Text, Layer2TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer3HLayout = Com.HLayout:New(0)
    local Layer3Text = Com.TextButton:New(vec3(300, 300, 3), vec3(300, 300, 3), large_font, "Layer3")
    local Layer3TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "5")
    Layer3HLayout:AddComponents({ Layer3Text, Layer3TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer4HLayout = Com.HLayout:New(0)
    local Layer4Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Layer4")
    local Layer4TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "4")
    Layer4HLayout:AddComponents({ Layer4Text, Layer4TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer5HLayout = Com.HLayout:New(0)
    local Layer5Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Layer5")
    local Layer5TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "")
    Layer5HLayout:AddComponents({ Layer5Text, Layer5TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer6HLayout = Com.HLayout:New(0)
    local Layer6Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Layer6")
    local Layer6TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "")
    Layer6HLayout:AddComponents({ Layer6Text, Layer6TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer7HLayout = Com.HLayout:New(0)
    local Layer7Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Layer7")
    local Layer7TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "")
    Layer7HLayout:AddComponents({ Layer7Text, Layer7TextLineEdit }, { 0.5, 1 - 0.5 })

    local Layer8HLayout = Com.HLayout:New(0)
    local Layer8Text = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Layer8")
    local Layer8TextLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "")
    Layer8HLayout:AddComponents({ Layer8Text, Layer8TextLineEdit }, { 0.5, 1 - 0.5 })

    local LearningRateHLayout = Com.HLayout:New(0)
    local LearningRateText = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "LearningRate")
    local LearningRateLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "0.05")
    LearningRateHLayout:AddComponents({ LearningRateText, LearningRateLineEdit }, { 0.5, 1 - 0.5 })

    local RadioImageOnOffHLayout = Com.HLayout:New(0)
    -- local RadioImageOnOffText= Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Create Img")
    local RadioImageOnOff = Com.RadioButton:New(large_font, 2, 2)
    RadioImageOnOff:Update(vec3(0), vec3(0), { "Images" }, { false })
    RadioImageOnOffHLayout:AddComponents({ Com.HLayout:New(0), RadioImageOnOff }, { 0.3, 1 - 0.3 })

    local CreateNNHLayout = Com.HLayout:New(0)
    local CreateNNButton = Com.TextButton:New(vec3(0), vec3(0), Com.GetFont("font", "large"), "Create NN & Img")
    CreateNNHLayout:AddComponents({ CreateNNButton, Com.HLayout:New(0) }, { 0.7, 1 - 0.7 })

    local HComponents = {
        Layer1HLayout,
        Layer2HLayout,
        Layer3HLayout,
        Layer4HLayout,
        Layer5HLayout,
        Layer6HLayout,
        Layer7HLayout,
        Layer8HLayout,
        -- Com.VLayout:New(0),
        LearningRateHLayout,
        -- Com.VLayout:New(0),
        RadioImageOnOffHLayout,
        Com.VLayout:New(0),
        CreateNNHLayout,
        Com.VLayout:New(0)
    }
    local HComponentsRatio = {}
    for i = 1, #HComponents, 1 do
        HComponentsRatio[i] = 0.04 * 2
    end
    HComponentsRatio[#HComponentsRatio] = 1 - (0.04 * 2 * (#HComponents - 1))
    local VLayout = Com.VLayout:New(0)
    VLayout:AddComponents(HComponents, HComponentsRatio)
    SN.Graphics.LayerListWindow:SetCentralComponent(VLayout)
    SN.Graphics.LayerListWindow:Update(vec3(0), vec3(0), vec2(0))

    VLayout.Update = function(self, inPosition_3f, inDimension_3f)
        Com.VLayout.Update(self, inPosition_3f, inDimension_3f)
        local AreaPos = vec3(self.mPosition_3f.x, self.mPosition_3f.y, self.mPosition_3f.z + 5)
        AreaO:Update(AreaPos, inDimension_3f)
    end

    local Obj = {}
    Obj.mRemoved = true
    Obj.PopUp = function()
        if Obj.mRemoved then
            local from = {mPosition_3f = vec3(0), mDimension_3f = vec3(0)}
            local to = {mPosition_3f = vec3(WindowDimension.x/4, WindowDimension.y / 4, 50), mDimension_3f = vec3(300, WindowDimension.y / 2, 1)}
            Com.NewSimultaneousUpdate()
            Com.AnimateSingleTimePosDimen(SN.Graphics.LayerListWindow, from, to, 0.3, 
            function ()
                SN.Graphics.LayerListWindow:Update(vec3(WindowDimension.x/4, WindowDimension.y / 4, 50), vec3(300, WindowDimension.y / 2, 1), vec2(300, 30))
            end
            )
            Obj.mRemoved = false
        else
            SN.Graphics.LayerListWindow:Update(vec3(0), vec3(0), vec2(0))
            Obj.mRemoved = true
        end
    end

    Obj.GetTopologyByTextFieldsLayer = function()
        local layer1_neurons = tonumber(Layer1TextLineEdit:GetText())
        local layer2_neurons = tonumber(Layer2TextLineEdit:GetText())
        local layer3_neurons = tonumber(Layer3TextLineEdit:GetText())
        local layer4_neurons = tonumber(Layer4TextLineEdit:GetText())
        local layer5_neurons = tonumber(Layer5TextLineEdit:GetText())
        local layer6_neurons = tonumber(Layer6TextLineEdit:GetText())
        local layer7_neurons = tonumber(Layer7TextLineEdit:GetText())
        local layer8_neurons = tonumber(Layer8TextLineEdit:GetText())
        return { layer1_neurons, layer2_neurons, layer3_neurons, layer4_neurons, layer5_neurons, layer6_neurons,
            layer7_neurons, layer8_neurons }
    end

    Obj.GetLearningRate = function()
        return tonumber(LearningRateLineEdit:GetText())
    end

    Obj.GetImageOnOffRadioButtonState = function()
        return Com.RadioButton.GetCheckedValue(RadioImageOnOff, 1)
    end

    CreateNNButton:SetFunctions(
        function()
            CreateNNButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            CreateNNButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            Obj.PopUp()
            inFunction()
        end
    )

    return Obj
end

SN.Graphics.CreateNNVisualizerWindow = function(CircularGraph)
    local Window = Com.MaterialWindow:New(vec3(WindowDimension.x - 400, 0, 50), vec3(400, WindowDimension.y, 1),
        vec2(400, 30), "NN Visualize", Com.GetFont("font", "large"))


    local CreateButtonHLayout = Com.HLayout:New(0)
    local CreateButton = Com.TextButton:New(vec3(200, 200, 1), vec3(300, 300, 1), large_font, "Create")
    local ClearButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Clear")
    CreateButtonHLayout:AddComponents({ CreateButton, ClearButton }, { 0.5, 1 - 0.5 })

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

    local TrainByBPHLayout = Com.HLayout:New(0)
    local TrainInverseButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Train BP")
    local TrainBySAButton = Com.TextButton:New(vec3(0), vec3(0), large_font, "Train SA")
    TrainByBPHLayout:AddComponents({ TrainInverseButton, TrainBySAButton }, { 0.5, 1 - 0.5 })

    local TrainingCountHLayout = Com.HLayout:New(0)
    local TrainingCountText = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "Count")
    local TrainingCountLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "1")
    TrainingCountHLayout:AddComponents({ TrainingCountText, TrainingCountLineEdit }, { 0.5, 1 - 0.5 })

    local LearningRateHLayout = Com.HLayout:New(0)
    local LearningRateText = Com.TextButton:New(vec3(400, 400, 4), vec3(400, 400, 4), large_font, "LearningRate")
    local LearningRateLineEdit = Com.MaterialLineEdit:New(vec3(0), vec3(0), large_font, "0.05")
    LearningRateHLayout:AddComponents({ LearningRateText, LearningRateLineEdit }, { 0.5, 1 - 0.5 })

    local HComponents = {
        CreateButtonHLayout,
        Com.HLayout:New(0),
        PropagateForwardPictureHLayout,
        PropagateBackwardPictureHLayout,
        UpdatePicHLayout,
        Com.HLayout:New(0),
        TrainByBPHLayout,
        LearningRateHLayout,
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

    ClearButton:SetFunctions(
        function()
            ClearButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            ClearButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            Com.ClearSingleTimes()
            SN.Graphics.CircularGraph.Clear(CircularGraph, vec4(0))
        end
    )

    -- ASSISTING SUBWINDOWS====================
    ----------------------------------------------------------------------------------------------------
    local update_to_image = true
    local CreateNNSubWindow = {}
    Com.NewSimultaneousUpdate()
    local createNNFunction = function()
        local c = SN.Graphics.InputPictureCanvas
        local o = SN.Graphics.OutputPictureCanvas
        local topology = CreateNNSubWindow.GetTopologyByTextFieldsLayer()
        local learningRate = CreateNNSubWindow.GetLearningRate()
        mero_NN = NN.SimpleNN:New(topology, learningRate)
        Com.ClearSingleTimes()
        local inputSize = math.round(math.sqrt(topology[1]))
        local outputSize = math.round(math.sqrt(topology[#topology]))
        if inputSize ~= SN.Graphics.InputPictureCanvas.mXSize or outputSize ~= SN.Graphics.OutputPictureCanvas.mXSize then
            if SN.Graphics.PictureWindow then
                SN.Graphics.PictureWindow:Update(vec3(0), vec3(0))
            end
            update_to_image = CreateNNSubWindow.GetImageOnOffRadioButtonState()
            if update_to_image then
                local inputCanvas = SN.Graphics.MakePictureCanvas(inputSize, inputSize)
                local outputCanvas = SN.Graphics.MakePictureCanvas(outputSize, outputSize)
                local expectOutCanvas = SN.Graphics.MakePictureCanvas(outputSize, outputSize)
                SN.Graphics.PictureWindow = SN.Graphics.MakePictureWindow(inputCanvas, outputCanvas, expectOutCanvas)
                SN.Graphics.PictureWindow:Update(vec3(WindowDimension.x - 600, WindowDimension.y - 600, 80),
                    vec3(200, 600, 80))
            end
        end
        -- SN.Graphics.CircularGraph.Clear(CircularGraph, vec4(1, 1, 1, 0))
        Com.NewSimultaneousUpdate()
        Com.NewSimultaneousSingleTimeUpdate(function()
            SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph,
                true)
        end)
    end
    Com.NewSimultaneousSingleTimeUpdate(function()
        CreateNNSubWindow = SN.Graphics.CreatePopupLayerListWindow(createNNFunction)
    end)
    ----------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------

    CreateButton:SetFunctions(
        function()
            CreateButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            CreateButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            CreateNNSubWindow.PopUp()
        end
    )

    local propForward = function()
        local ImageF = Com.Canvas.GetVectorFloatSingleChannel(SN.Graphics.InputPictureCanvas)
        mero_NN:PropagateForwardVecFloat(ImageF)
        local Output = NN.SimpleNN.GetOutputFloatVec(mero_NN, #mero_NN.mTopology - 1)
        if update_to_image then
            Com.NewSimultaneousSingleTimeDispatch(
                function()
                    Com.Canvas.DrawClearFromFloatSingleChannel(SN.Graphics.OutputPictureCanvas, Output)
                end
            )
        end
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

    local trainByBP = function(inShouldDisplay)
        if update_to_image then
            local i = SN.Graphics.InputPictureCanvas
            local eo = SN.Graphics.ExpectedOutputPictureCanvas
            local o = SN.Graphics.OutputPictureCanvas
            local InputOutputImageFloats = NN.ImageGetRandomInputInverseOutput(i.mXSize * i.mYSize, o.mXSize * o.mYSize)
            mero_NN:PropagateForwardVecFloat(InputOutputImageFloats[1])
            mero_NN:PropagateBackwardVecFloat(InputOutputImageFloats[2])
            local Output = NN.SimpleNN.GetOutputFloatVec(mero_NN, #mero_NN.mTopology - 1)
            if inShouldDisplay then
                Com.NewSimultaneousSingleTimeDispatch(
                    function()
                        Com.Canvas.DrawClearFromFloatSingleChannel(i, InputOutputImageFloats[1])
                        Com.Canvas.DrawClearFromFloatSingleChannel(eo, InputOutputImageFloats[2])
                        Com.Canvas.DrawClearFromFloatSingleChannel(o, Output)
                    end
                )
            end
        end
    end

    SN.Graphics.GetCurrentNN = function()
        return mero_NN
    end

    local AddSAData = function(inShouldDisplay)
        if update_to_image then
            local i = SN.Graphics.InputPictureCanvas
            local eo = SN.Graphics.ExpectedOutputPictureCanvas
            local o = SN.Graphics.OutputPictureCanvas
            local InputOutputImageFloats = NN.ImageGetRandomInputInverseOutput(i.mXSize * i.mYSize, o.mXSize * o.mYSize)
            -- mero_NN:PropagateForwardVecFloat(InputOutputImageFloats[1])
            mero_NN:AddSAData(InputOutputImageFloats[1], InputOutputImageFloats[2])
            local Output = NN.SimpleNN.GetOutputFloatVec(mero_NN, #mero_NN.mTopology - 1)
            if inShouldDisplay then
                Com.NewSimultaneousSingleTimeDispatch(
                    function()
                        Com.Canvas.DrawClearFromFloatSingleChannel(i, InputOutputImageFloats[1])
                        Com.Canvas.DrawClearFromFloatSingleChannel(eo, InputOutputImageFloats[2])
                        Com.Canvas.DrawClearFromFloatSingleChannel(o, Output)
                    end
                )
            end
        end
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
                trainByBP(false)
            end
            trainByBP(true)
            Com.NewSimultaneousSingleTimeUpdate(function()
                SN.Graphics.DrawNeuralNetworkToGraph(mero_NN, CircularGraph,
                    true)
            end)
        end
    )

    TrainBySAButton:SetFunctions(
        function()
            TrainBySAButton:SetFillColor(vec4(hover_color.x, hover_color.y, hover_color.z, hover_color.w))
        end,
        function()
            TrainBySAButton:SetFillColor(vec4(normal_color.x, normal_color.y, normal_color.z, normal_color.w))
        end,
        function()
            local Itrs = tonumber(TrainingCountLineEdit:GetText())
            for i = 1, Itrs, 1 do
                AddSAData(false)
            end
            mero_NN:ApplySA()
        end
    )
    return Window
end
