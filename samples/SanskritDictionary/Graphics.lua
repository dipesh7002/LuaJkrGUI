require "jkrgui.all"
require "samples.SanskritDictionary.database"

SD = {}
local BigFont = Com.GetFont("font", "Large")

SD.CreateTopBar = function ()
    local TopBar = Com.Canvas:New(vec3(0), vec3(0))
 	TopBar:AddPainterBrush(Com.GetCanvasPainter("Clear", false))
 	TopBar:AddPainterBrush(Com.GetCanvasPainter("RoundedRectangle", false))
 	TopBar:MakeCanvasImage(500, 500)
    TopBar.DrawDispatch = function (inColor)
 			TopBar.CurrentBrushId = 2
 			TopBar:Bind()
 			-- local startingY = -TopBarSize_3f.y + TopBarSize_3f.y * 1.8
			-- local startingX = -TopBarSize_3f.x
 			-- local endingX = TopBarSize_3f.x * 2
 			-- local endingY = TopBarSize_3f.y + TopBarSize_3f.y
 			TopBar:Paint(vec4(-250, -250, 500, 500), inColor,
 				vec4(1.5, 1, 1, 0.8), 500, 500, 1)
    end
    return TopBar
end

SD.CreateTopBarText = function ()
 	local topText = "संस्कृतम्"
 	local tB = Com.TextLabelObject:New(topText, vec3(0), BigFont)
    return tB
end