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

SN.Core.SetProblem_SumOfTwoNumbers = function(inInitialTemperature, inSumValue)
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
