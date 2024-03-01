require "jkrgui.all"
local normal_color = Theme.Colors.Button.Normal * 8
local hover_color = Theme.Colors.Button.Hover * 1.4
local large_font = Com.GetFont("font", "large")

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
    mPosition_3f = nil,
    mDimension_3f = nil,
    mLines = nil,
    New = function(self, inPosition_3f, inDimension_3f, inLineCount)
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
            Com.Canvas.Paint(Obj.mCanvas, vec4(0, 0, inDimension_3f.x, inDimension_3f.y), vec4(0, 0, 0, 0),
                vec4(1.2, 0, 0, 1), inDimension_3f.x, inDimension_3f.y, 1)
        end)

        Obj.mLineCount = 100000
        if inLineCount then
            Obj.mLineCount = inLineCount
        end
        -- LINE BATCH
        ------------------------------------------------------------------------------------
        Obj.mLineBatch = Jkr.Components.Static.LineObject:NewBatch(Obj.mLineCount)
        Obj.mLineBatch:SetColor(vec4(0, 0, 0, 0.1))
        Obj.mCurrentBatchLine = Obj.mLineBatch.mStartId
        Obj.mLinesMax = Obj.mLineBatch.mEndId
        Com.NewComponent()
        ComTable[com_i] = Jkr.Components.Abstract.Drawable:New(
            function()
                Obj.mLineBatch:Draw()
            end
        )

        Obj.mLinesNotCleared = 1

        Obj.UpdateGraphLineBatch = function(self, inPosition1_3f, inPosition2_3f)
            if Obj.mCurrentBatchLine + 1 <= Obj.mLinesMax then
                local newp1 = vec3(inPosition1_3f.x + self.mPosition_3f.x, inPosition1_3f.y + self.mPosition_3f.y, inPosition1_3f.z)
                local newp2 = vec3(inPosition2_3f.x + self.mPosition_3f.x, inPosition2_3f.y + self.mPosition_3f.y, inPosition2_3f.z)
                Obj.mLineBatch:Update(newp1, newp2, Obj.mCurrentBatchLine)
                Obj.mCurrentBatchLine = Obj.mCurrentBatchLine + 1
                Obj.mLinesNotCleared = Obj.mLinesNotCleared + 1
            end
        end
        Obj.ResetGraphLineBatch = function(self)
            Obj.mCurrentBatchLine = Obj.mLineBatch.mStartId
        end
        Obj.ClearGraphLineBatch = function(self)
            for i = Obj.mLineBatch.mStartId, Obj.mLinesNotCleared, 1 do
                Obj.mLineBatch:Update(vec3(0), vec3(0), i)
            end
            Obj.mLinesNotCleared = 1
            Obj:ResetGraphLineBatch()
        end
        -------------------------------------------------------------------------------------
        -- Obj.mLines = {}
        -- for i = 1, Obj.mLineCount, 1 do
        --     Com.NewComponent()
        --     ComTable[com_i] = Jkr.Components.Static.LineObject:New(vec3(0, 0, 1), vec3(0, 0, 1))
        --     Obj.mLines[#Obj.mLines + 1] = com_i
        -- end
        -- Obj.mCurrentLineId = 1


        Obj.mPosition_3f = inPosition_3f
        Obj.mDimension_3f = inDimension_3f
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        self.mCanvas:Update(inPosition_3f, inDimension_3f)
    end,
    PlotAt = function(self, inX, inY, inW, inH, inColor_4f, inBrushId, inSimultaneous)
        local gX = self.mPosition_3f.x
        local gY = self.mPosition_3f.y
        if inSimultaneous then
            Com.NewSimulataneousDispatch()
        end
        Com.NewSimultaneousSingleTimeDispatch(function()
            self.mCanvas.CurrentBrushId = inBrushId
            Com.Canvas.Bind(self.mCanvas)
            Com.Canvas.Paint(self.mCanvas, vec4(inX, inY, inW, inH), inColor_4f, vec4(1.2, 0, 0, 1), inW, inH, 1)
        end)
    end,
    Clear = function(self, inColor_4f)
        Com.NewSimultaneousSingleTimeDispatch(function()
            self.mCanvas.CurrentBrushId = 1
            Com.Canvas.Bind(self.mCanvas)
            Com.Canvas.Paint(self.mCanvas, vec4(0, 0, WindowDimension.x * 2, WindowDimension.y * 2), inColor_4f,
                vec4(1.2, 0, 0, 1), WindowDimension.x * 2, WindowDimension.y * 2, 1)
        end)

        -- for i = 1, #self.mLines, 1 do
        --     ComTable[self.mLines[i]]:Update(vec3(0), vec3(0))
        -- end
        -- self.mCurrentLineId = 1

        self:ClearGraphLineBatch()
    end,
    UpdateGraphLine = function(self, inPosition1_3f, inPosition2_3f, inColor_4f)
        local id = self.mLines[self.mCurrentLineId]
        local linePos1 = vec3(inPosition1_3f.x + self.mPosition_3f.x, inPosition1_3f.y + self.mPosition_3f.y,
            inPosition1_3f.z)
        local linePos2 = vec3(inPosition2_3f.x + self.mPosition_3f.x, inPosition2_3f.y + self.mPosition_3f.y,
            inPosition2_3f.z)
        ComTable[id]:Update(linePos1, linePos2)
        if inColor_4f then
            ComTable[id]:SetColor(inColor_4f)
        end
        self.mCurrentLineId = self.mCurrentLineId + 1
    end,
    ResetLines = function(self)
        self.mCurrentLineId = 1
    end
}

SN.Graphics.DrawNeuralNetworkToGraph = function(inNeuralNetwork, inGraph, inSimultaneousDispatch)
    local topo = inNeuralNetwork.mTopology

    local max = 0
    for i = 1, #topo, 1 do
        if topo[i] > max then
            max = topo[i]
        end
    end

    local total_layers        = #topo
    local dis_between_layers  = WindowDimension.x / (total_layers) / 1.6
    local dis_between_neurons = WindowDimension.y / (max) / 1.3
    local middle_pos_y        = dis_between_neurons / 2 * (max - 1)
    local middle_pos_x        = dis_between_layers / 2 * (total_layers - 1)

    local radius              = dis_between_neurons / 1.05
    local G                   = SN.Graphics.CircularGraph
    local callbackNeuronsOnly = function(inPos_2f, inValue, inLayerNeuronCount)
        local xpos = middle_pos_x - total_layers / 2 * dis_between_layers + dis_between_layers * inPos_2f.x
        local ypos = middle_pos_y - inLayerNeuronCount / 2 * dis_between_neurons + inPos_2f.y * dis_between_neurons
        G.PlotAt(inGraph, xpos, ypos, radius, radius, vec4(-inValue, inValue / 2, 1, 1), 2, inSimultaneousDispatch)
    end

    local callbackWeightLines = function(leftLayer, inLeftNeuron, inLeftNeuronCount, inRightLayer, inRightNeuron,
                                         inRightNeuronCount, inWeightValue)
        local xposl = middle_pos_x - total_layers / 2 * dis_between_layers + dis_between_layers * leftLayer + radius / 2
        local yposl = middle_pos_y - inLeftNeuronCount / 2 * dis_between_neurons + inLeftNeuron * dis_between_neurons +
            radius / 2

        local xposr = middle_pos_x - total_layers / 2 * dis_between_layers + dis_between_layers * inRightLayer +
            radius / 2
        local yposr = middle_pos_y - inRightNeuronCount / 2 * dis_between_neurons + inRightNeuron * dis_between_neurons +
            radius / 2
        -- SN.Graphics.CircularGraph.UpdateGraphLine(inGraph, vec3(xposl, yposl, 50), vec3(xposr, yposr, 50), color)
        for i = 1, math.abs(inWeightValue) * 10, 1 do
            inGraph:UpdateGraphLineBatch(vec3(xposl, yposl, 80), vec3(xposr, yposr, 80))
        end
    end

    inGraph:ClearGraphLineBatch()
    inNeuralNetwork:PrintNeurons(callbackNeuronsOnly) 
    inNeuralNetwork:PrintLines(callbackWeightLines)
    inGraph:ResetLines()
    inGraph:ResetGraphLineBatch()
end
