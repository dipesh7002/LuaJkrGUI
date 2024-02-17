require "neural" -- dll written in C++
math.round = function (inX)
   return math.floor(inX + 0.5) 
end

-- NEURAL NETWORK
NN = {}
NN.SimpleNN = {
    mTopology = nil,
    mNN = nil,
    New = function(self, inTopology, inLearningRate)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.mTopology = inTopology

        local topology = std_vector_int()
        for i = 1, #inTopology, 1 do
            topology:add(inTopology[i])
        end
        if inLearningRate then
            Obj.mNN = neur.network(topology, inLearningRate)
        else
            Obj.mNN = neur.network(topology)
        end
        return Obj
    end,
    PrintNeurons = function(self, inCallback_2fff)
        for i = 1, #self.mTopology, 1 do
            for j = 0, self.mTopology[i] - 1, 1 do
                local value = self.mNN:value_of_neuron(i - 1, j)
                inCallback_2fff(vec2(i, j + 1), value, self.mTopology[i])
            end
        end
    end,
    PrintLines = function(self, inCallback_fffffff)
        for i = 1, #self.mTopology - 1, 1 do
            local left = self.mTopology[i]
            local right = self.mTopology[i + 1]
            for x = 1, left, 1 do
                for y = 1, right, 1 do
                    local weight = self.mNN:weight_of_connection(i - 1, x - 1, y - 1)
                    inCallback_fffffff(i, x, self.mTopology[i], i + 1, y, self.mTopology[i + 1], weight)
                end
            end
        end
    end,
    Train = function(self, inDataCount)
        self.mNN:dummy_train(inDataCount)
    end,
    PropagateForward = function (self, inFloats)
       local float_vec = std_vector_float() 
       for i = 1, #inFloats, 1 do
            float_vec:add(inFloats[i]) 
       end
       self.mNN:propagate_forward(float_vec)
    end,
    PropagateForwardVecFloat = function (self, inVec)
        self.mNN:propagate_forward(inVec) 
    end,
    PropagateBackwardVecFloat = function (self, inVec)
        self.mNN:propagate_backward_current(inVec) 
    end,
    TrainEXT = function (self, inInput, inOutput)
       self.mNN:propagate_forward(inInput) 
       self.mNN:propagate_backward_current(inOutput) 
    end,
    GetOutputFloatVec = function (self, inLayerNum)
       return self.mNN:get_layer_vector_float(inLayerNum) 
    end

}

NN.ImageGetRandomInputInverseOutput = function (inSizeInput, inSizeOutput)
    local invec = std_vector_float()

    for i = 1, inSizeInput, 1 do
        invec:add(math.round(math.random()))
        -- invec:add(1)
    end

    local outvec = std_vector_float()
    for i = 1, inSizeOutput, 1 do
       outvec:add(math.round(invec[i])) 
       --outvec:add(0)
    end
    return {invec, outvec}
end

-- SIMULATED ANNEALING
SN = {}

SN.State = {
    New = function(self, i, j, index)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj.i = i
        Obj.j = j
        Obj.index = index
        return Obj
    end
}

SN.P = function(inE, inE_new, inT) -- Formulation by patrik et al.
    if (inE_new < inE) then
        return 1
    else
        return math.exp(-(inE_new - inE) / inT)
    end
end

SN.Solve = function(inStartingState, inK_max, inCallbackFunction)
    local s = inStartingState
    for k = 0, inK_max - 1 do
        Com.NewSimultaneousSingleTimeUpdate(
            function()
                local T = SN.temperature(1 - (k + 1) / inK_max)
                local s_new = SN.neighbour(s)
                local P = SN.P(SN.E(s), SN.E(s_new), T)
                if P >= math.random() then
                    s = s_new
                end
                if inCallbackFunction then
                    inCallbackFunction(s, T, k, s_new)
                end
            end
        )
    end
end

SN.Core = {}

SN.Core.SetProblem_PythagoreanTriplet = function(inInitialTemperature, inSumValue)
    SN.State = {
        New = function(self, i, j)
            local Obj = {}
            setmetatable(Obj, self)
            self.__index = self
            Obj.i = i
            Obj.j = j
            return Obj
        end,
        Print = function(self)
            io.write(string.format("State(%d, %d, %d)\n", self.i, self.j, SN.E(self)))
        end
    }

    SN.InitialTemperature = inInitialTemperature
    SN.CurrentTemperature = SN.InitialTemperature -- Initial Temperature
    SN.temperature = function(inK)
        SN.CurrentTemperature = SN.CurrentTemperature * inK
        return SN.CurrentTemperature
    end

    SN.E = function(inS) -- Energy Function
        return math.abs(inS.i ^ 2 + inS.j ^ 2 - inSumValue ^ 2)
    end

    SN.neighbour = function(inS)
        local randnum = math.random(1, 3)
        local randi = (-randnum) ^ math.random(1, 2)
        local randj = (-randnum) ^ math.random(1, 2)
        return SN.State:New(inS.i + randi, inS.j + randj)
    end
end
