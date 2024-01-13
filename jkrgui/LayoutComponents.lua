require "jkrgui.ExtraComponents"
Com.HLayout = {
    mComponents = nil,
    mRatioTable = nil,
    mPadding = nil,

    New = function(self, inPadding)
        local Obj = {
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self

        return Obj
    end,
    AddComponents = function(self, inComponentListTable, inRatioTable)
        self.mComponents = inComponentListTable
        self.mRatioTable = inRatioTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = inPosition_3f
        local dimension = inDimension_3f
        local paddingX = self.mPadding

        if self.mRatioTable then
            for index, value in ipairs(self.mComponents) do
                value:Update(vec3(position.x, position.y, position.z),
                    vec3(dimension.x * self.mRatioTable[index], dimension.y, dimension.z),
                    self.mComponents[index].mText)
                position.x = position.x + dimension.x * self.mRatioTable[index] + paddingX
            end
        end
    end
}
Com.VLayout = {
    mComponents = nil,
    mRatioTable = nil,
    mPadding = nil,

    New = function(self, inPadding)
        local Obj = {
            mPadding = inPadding
        }
        setmetatable(Obj, self)
        self.__index = self
        return Obj
    end,
    AddComponents = function(self, inComponentListTable, inRatioTable)
        self.mComponents = inComponentListTable
        self.mRatioTable = inRatioTable
    end,
    Update = function(self, inPosition_3f, inDimension_3f)
        local position = vec3(inPosition_3f.x ,inPosition_3f.y, inPosition_3f.z)
        local dimension = vec3(inDimension_3f.x,inDimension_3f.y,inDimension_3f.z)
        local paddingY = self.mPadding 
        if self.mRatioTable then
            for index, value in ipairs(self.mComponents) do
                value:Update(vec3(position.x, position.y, position.z),
                    vec3(dimension.x, dimension.y * self.mRatioTable[index], dimension.z),
                    self.mComponents[index].mText)
                position.y = position.y + dimension.y * self.mRatioTable[index] + paddingY
            end
        end
    end
}
