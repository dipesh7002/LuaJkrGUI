require "jkrgui.PrimitiveComponents"
Com.HorizontalLayout = {
    mTableForObject = {},
    New = function(self, inTableForObject)
        local Obj = {
            mTableForObject = inTableForObject,
        }
        setmetatable(Obj, self)
        self.__index = self
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, PartitionTable, inPadding)
        if PartitionTable then
            for index, value in ipairs(self.mTableForObject) do
                local pos = vec3(0, 0, 0)
                if value.mText then
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPositionToParent_3f.z)
                else
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPosition_3f.z)
                end
                local dimen = vec3(inDimension_3f.x * PartitionTable[index], inDimension_3f.y, inDimension_3f.z)
                value:Update(pos, dimen, value.mText)
                inPosition_3f.x = inPosition_3f.x + dimen.x + inPadding
            end
        else
            for index, value in ipairs(self.mTableForObject) do
                local pos = vec3(0, 0, 0)
                if value.mText then
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPositionToParent_3f.z)
                else
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPosition_3f.z)
                end
                local dimen = vec3(inDimension_3f.x , inDimension_3f.y, inDimension_3f.z)
                value:Update(pos, dimen, value.mText)
                inPosition_3f.x = inPosition_3f.x + dimen.x + inPadding
            end
        end
    end
}
Com.VerticalLayout = {
    mTableForObject = {},
    New = function(self, inTableForObject)
        local Obj = {
            mTableForObject = inTableForObject,
        }
        setmetatable(Obj, self)
        self.__index = self
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, PartitionTable, inPadding)
        if PartitionTable then
            for index, value in ipairs(self.mTableForObject) do
                local pos = vec3(0, 0, 0)
                if value.mText then
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPositionToParent_3f.z)
                else
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPosition_3f.z)
                end
                local dimen = vec3(inDimension_3f.x, inDimension_3f.y * PartitionTable[index], inDimension_3f.z)
                value:Update(pos, dimen, value.mText)
                inPosition_3f.y = inPosition_3f.y + dimen.y + inPadding
            end
        else
            for index, value in ipairs(self.mTableForObject) do
                local pos = vec3(0, 0, 0)
                if value.mText then
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPositionToParent_3f.z)
                else
                    pos = vec3(inPosition_3f.x, inPosition_3f.y, value.mPosition_3f.z)
                end
                local dimen = vec3(inDimension_3f.x , inDimension_3f.y, inDimension_3f.z)
                value:Update(pos, dimen, value.mText)
                inPosition_3f.y = inPosition_3f.y + dimen.y + inPadding
            end
        end
    end
}