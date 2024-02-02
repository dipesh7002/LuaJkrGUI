require "jkrgui.PrimitiveComponents"
require "jkrgui.MaterialComponents"
require "jkrgui.LayoutComponents"
Com.GridLayout = {
    mPadding = nil,
    mPosition_3f = nil,
    mDimension_3f = nil,

    New = function(self, inPadding)
        local Obj = {
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self

        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inNoOfCell_Row, inNoOfCell_Coloumn, inComponentTable)
        local position = vec3(inPosition_3f.x, inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x, inDimension_3f.y, inDimension_3f.z)
        local OneCellDimension = vec3(0, 0, inDimension_3f.z)
        local k = 1
        OneCellDimension.x = (dimension.x - (self.mPadding * (inNoOfCell_Row - 1))) / inNoOfCell_Row
        OneCellDimension.y = (dimension.y - (self.mPadding * (inNoOfCell_Coloumn - 1))) / inNoOfCell_Coloumn
        for i = 1, inNoOfCell_Coloumn, 1 do
            for j = 1, inNoOfCell_Row, 1 do
                inComponentTable[k]:Update(position, OneCellDimension)
                position.x = position.x + self.mPadding + OneCellDimension.x
                k = k + 1
            end
            position.y = position.y + self.mPadding + OneCellDimension.y
            position.x = inPosition_3f.x
        end
    end
}