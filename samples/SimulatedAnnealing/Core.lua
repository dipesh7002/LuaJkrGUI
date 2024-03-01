math.round = function(inX)
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
            Obj.mNN = neural.network(topology, inLearningRate)
        else
            Obj.mNN = neural.network(topology)
        end

        Obj.SaveToFile = function (inFileName)
           Obj.mNN:save_to_file(inFileName)
        end

        Obj.LoadFromFile = function (inFileName)
            Obj.mNN:load_from_file(inFileName)
            Obj.mTopology = {}
            local topo = Obj.mNN:get_topology()
            print("toposize", topo:size())
            for i = 1, #topo, 1 do
                print(topo[i])
                Obj.mTopology[#Obj.mTopology+1] = topo[i]
            end
            print("TopologySize", #Obj.mTopology)
        end
        return Obj
    end,
    PrintNeurons = function(self, inCallback_2fff)
        for i = 1, #self.mTopology, 1 do
            if i ~= #self.mTopology then
                for j = 0, self.mTopology[i], 1 do
                    local value = self.mNN:value_of_neuron(i - 1, j)
                    inCallback_2fff(vec2(i, j + 1), value, self.mTopology[i])
                end
            else
                for j = 0, self.mTopology[i] - 1, 1 do
                    local value = self.mNN:value_of_neuron(i - 1, j)
                    inCallback_2fff(vec2(i, j + 1), value, self.mTopology[i])
                end
            end
        end
    end,
    PrintLines = function(self, inCallback_fffffff)
        for i = 1, #self.mTopology - 1, 1 do
            local left = self.mTopology[i]
            local right = self.mTopology[i + 1]
            if (i ~= 1) or (i + 1 ~= #self.mTopology) then
                for x = 1, left + 1, 1 do
                    for y = 1, right, 1 do
                        local weight = self.mNN:weight_of_connection(i - 1, x - 1, y - 1)
                        inCallback_fffffff(i, x, self.mTopology[i], i + 1, y, self.mTopology[i + 1], weight)
                    end
                end
            else
                for x = 1, left, 1 do
                    for y = 1, right, 1 do
                        local weight = self.mNN:weight_of_connection(i - 1, x - 1, y - 1)
                        inCallback_fffffff(i, x, self.mTopology[i], i + 1, y, self.mTopology[i + 1], weight)
                    end
                end
            end
        end
    end,
    Train = function(self, inDataCount)
        print("This function is to be removed")
    end,
    PropagateForward = function(self, inFloats)
        local float_vec = std_vector_float()
        for i = 1, #inFloats, 1 do
            float_vec:add(inFloats[i])
        end
        self.mNN:propagate_forward(float_vec)
    end,
    PropagateForwardVecFloat = function(self, inVec)
        self.mNN:propagate_forward(inVec)
    end,
    PropagateBackwardVecFloat = function(self, inVec)
        self.mNN:propagate_backward_current(inVec)
    end,
    TrainEXT = function(self, inInput, inOutput)
        self.mNN:propagate_forward(inInput)
        self.mNN:propagate_backward_current(inOutput)
    end,
    GetOutputFloatVec = function(self, inLayerNum)
        return self.mNN:get_layer_vector_float(inLayerNum)
    end,
    AddSAData = function(self, inInput, inOutput)
        self.mNN:add_sa_data(inInput, inOutput)
    end,
    ApplySA = function(self, inTemperature, inIterations)
        if not inTemperature then inTemperature = 0.01 end
        if not inIterations then inIterations = 20000 end
        self.mNN:apply_sa(inTemperature, inIterations)
    end,
    PrintMeanSE = function(self)
        print("Current Mean SE:", self.mNN:get_current_mean_squared_error())
    end
}

NN.ImageGetRandomInputInverseOutput = function(inSizeInput, inSizeOutput)
    local invec = std_vector_float()

    for i = 1, inSizeInput, 1 do
        invec:add(math.random())
        -- invec:add(1)
    end

    local outvec = std_vector_float()
    for i = 1, inSizeOutput, 1 do
        outvec:add(1 - invec[i])
        --outvec:add(0)
    end
    return { invec, outvec }
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

SN.Core.SetProblem_SumTwoNumbers = function(inInitialTemperature, inSumValue)
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
        return math.abs(inS.i + inS.j - inSumValue)
    end

    SN.neighbour = function(inS)
        local randnum = math.random(1, 3)
        local randi = (-randnum) ^ math.random(1, 2)
        local randj = (-randnum) ^ math.random(1, 2)
        return SN.State:New(inS.i + randi, inS.j + randj)
    end
end

SN.Core.CreateSnakeProblem = function(inGridSize)
    local o = {}
    o.up = 1
    o.down = 2
    o.right = 3
    o.left = 4
    o.none = 5
    local img = {}

    o.CopyImage = function(inImage)
        img = std_vector_float()
        for y = 1, inGridSize do
            for x = 1, inGridSize do
                img:add(inImage[x + (y - 1) * inGridSize])
            end
        end
    end

    o.InitImage = function()
        img = std_vector_float()
        for y = 1, inGridSize do
            for x = 1, inGridSize do
                img:add(0)
            end
        end
        o.SnakePath = {}
    end

    o.ClearImage = function()
        for y = 1, inGridSize do
            for x = 1, inGridSize do
                img[x + (y - 1) * inGridSize] = 0
            end
        end
        o.SnakePath = {}
    end

    o.PrintImage = function()
        for y = 1, inGridSize do
            for x = 1, inGridSize do
                io.write(img[x + (y - 1) * inGridSize], " ")
            end
            io.write("\n")
        end
    end

    local foodpos = uvec2(1, 1)
    local snakepos = uvec2(1, 1)

    o.EraseAt = function(x, y)
        img[x + (y - 1) * inGridSize] = 0
    end

    o.PutFoodAt = function(x, y)
        o.EraseAt(foodpos.x, foodpos.y)
        img[x + (y - 1) * inGridSize] = 1.0
        foodpos = uvec2(x, y)
    end

    o.PutSnakeAt = function(x, y)
        -- o.EraseAt(snakepos.x, snakepos.y)
        o.SnakePath[#o.SnakePath + 1] = uvec2(x, y)
        for i = 1, #o.SnakePath, 1 do
            -- print("Put Snake At", x + (y - 1) * inGridSize)
            if i == 1 then
                 img[x + (y - 1) * inGridSize] = -1
            else
                img[x + (y - 1) * inGridSize] = -0.1 * (#o.SnakePath)
            end
        end
        snakepos = uvec2(x, y)
    end

    o.RandomlyPutFoodAndSnake = function()
        local food_atx, food_aty = math.random(1, inGridSize), math.random(1, inGridSize)
        local snake_atx, snake_aty = math.random(1, inGridSize), math.random(1, inGridSize)
        o.PutFoodAt(food_atx, food_aty)
        o.PutSnakeAt(snake_atx, snake_aty)
    end

    o.GetDistance = function()
        return math.sqrt((foodpos.x - snakepos.x) ^ 2 + (foodpos.x - snakepos.y) ^ 2)
    end

    o.GetMag = function(u1, u2)
        return math.sqrt((u1.x - u2.x) ^ 2 + (u1.y - u2.y) ^ 2)
    end
    local debug = function(inStr)
            -- print(inStr)
            -- print(snakepos.x, snakepos.y)
    end

    local move_functions = {
        function()
            o.PutSnakeAt(snakepos.x, snakepos.y - 1)
        end,
        function()
            o.PutSnakeAt(snakepos.x, snakepos.y + 1)
        end,
        function()
            o.PutSnakeAt(snakepos.x + 1, snakepos.y)
        end,
        function()
            o.PutSnakeAt(snakepos.x - 1, snakepos.y)
        end,
        function ()
            
        end
    }
    o.MoveTowardsFood = function()
        local move = o.none
        local foodpos = uvec2(foodpos.x, foodpos.y)
        local snakepos = uvec2(snakepos.x, snakepos.y)
        local mind = o.GetMag(foodpos, snakepos)

        -- up
        if snakepos.y - 1 >= 1 then
            local snakepos_up = uvec2(snakepos.x, snakepos.y - 1)
            local m = o.GetMag(foodpos, snakepos_up)
            if m <= mind and move ~= o.up then
                mind = m
                move = o.up
            end
        end

        -- down
        if snakepos.y + 1 <= inGridSize then
            local snakepos_down = uvec2(snakepos.x, snakepos.y + 1)
            local m = o.GetMag(foodpos, snakepos_down)
            if m <= mind and move ~= o.down then
                mind = m
                move = o.down
            end
        end

        -- right
        if snakepos.x + 1 <= inGridSize then
            local snakepos_right = uvec2(snakepos.x + 1, snakepos.y)
            local m = o.GetMag(foodpos, snakepos_right)
            if m <= mind and move ~= o.right then
                mind = m
                move = o.right
            end
        end

        --left
        if snakepos.x - 1 >= 1 then
            local snakepos_left = uvec2(snakepos.x - 1, snakepos.y)
            local m = o.GetMag(foodpos, snakepos_left)
            if m <= mind and move ~= o.left then
                mind = m
                move = o.left
            end
        end


        local newmind = o.GetMag(foodpos, snakepos)
        if newmind ~= 0 then
            o.Move(move)
        end
        local ret = { 0, 0, 0, 0 }
        if move ~= o.none then
            ret[move] = 1
        end
        return { ret, newmind }
    end

    o.Move = function(inMovement)
        move_functions[inMovement]()
    end

    o.SafeMove = function (inMovement)
        local should_move = false
        if inMovement == o.up or inMovement == o.down then
            should_move = (snakepos.y - 1 >= 1) and (snakepos.y + 1 <= inGridSize)
        elseif inMovement == o.right or inMovement == o.left then
            should_move = (snakepos.x - 1 >= 1) and (snakepos.x + 1 <= inGridSize)
        end
        if should_move then
            move_functions[inMovement]()
        end
    end

    o.GetImage = function()
        return img
    end

    return o
end
