SN = {}

SN.CurrentTemperature = 10 -- Initial Temperature
SN.temperature = function(inK)
    SN.CurrentTemperature = SN.CurrentTemperature * inK
    return SN.CurrentTemperature
end

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
        -- print("EXP: inE_new, inE", inE_new, inE, math.exp(-(inE_new - inE) / inT))
        return math.exp(-(inE_new - inE) / inT)
    end
end

SN.Solve = function (inStartingState, inK_max)
    local s = inStartingState
    for k = 0, inK_max - 1 do
        local T = SN.temperature(1 - (k + 1) / inK_max)
        local s_new = SN.neighbour(s)

        -- print("=================================================================")
        -- io.write("S: ")
        -- s:Print()

        -- io.write("SNEW: ")
        -- s_new:Print()

        local P = SN.P(SN.E(s), SN.E(s_new), T)
        -- print("P:", P, "T:", T, "TParam:", 1 - (k + 1) / inK_max)

        if P >= math.random() then
            s = s_new
        end

        -- print("=================================================================")
    end
    s:Print()
end

SimulatedAnnealingLoad = function()
    SN.State = {
        New = function (self, i, j)
           local Obj = {} 
           setmetatable(Obj, self)
           self.__index = self
           Obj.i = i
           Obj.j = j
           return Obj
        end,
        Print = function (self)
           io.write(string.format("State(%d, %d, %d)\n", self.i, self.j, SN.E(self)))
        end
    }

    SN.E = function (inS) -- Energy Function
        return math.abs(inS.i + inS.j - 15) 
    end

    SN.neighbour = function (inS)
        local rand = (-1) ^ math.random(1, 2)
        -- inS.i = inS.i + rand
        -- inS.j = inS.j + rand
        return SN.State:New(inS.i + rand, inS.j + rand)
    end

    SN.Solve(SN.State:New(3, 4), 100)
end