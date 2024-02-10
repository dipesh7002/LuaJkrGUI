require "samples.SimulatedAnnealing.Core"
require "samples.SimulatedAnnealing.Graphics"

SimulatedAnnealingLoad = function()
    SN.Core.SetProblem_SumOfTwoNumbers()
    SN.Graphics.CreateGUI()
end
