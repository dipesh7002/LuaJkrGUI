require "jkrgui.jkrgui"
Jmath3D = jmath3D

Com.Objec3D = {
    New = function(self)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self

        return Obj
    end
}