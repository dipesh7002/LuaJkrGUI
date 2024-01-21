require "jkrgui.jkrgui"
local Three = {}
local BindingGlobalUB = 1

Com.Load3DComponents = function ()
    Three = Jkr3d.three(Jkr3d.SizeOfUBDefault, Jkr3d.SizeOfSSBO_Default)
end

--[[
    Object3D is the base class for all the objects, that has a position, rotation and dimension
]]

Com.Object3D = {
    mPosition_3f = nil,
    mDimension_3f = nil,
    mRotation_3f = nil,
    New = function(self, inPosition_3f, inDimension_3f, inRotation_3f)
        local Obj = {}
        setmetatable(Obj, self)
        self.__index = self
        Obj:Update(inPosition_3f, inDimension_3f, inRotation_3f)
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inRotation_3f)
        self.mPosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        self.mRotation = inRotation_3f
    end
}

Com.Camera3D = {
    mEyePosition_3f = nil,
    mViewDirection_3f = nil,
    mUpPosition_3f = nil,
    mRightPosition_3f = nil,
    mCenterOfInterest_3f = nil,
    mViewMatrix_4x4 = nil,
    mProjMatrix_4x4 = nil,
    mAspect = nil,
    mIsOrtho = false,
    New = function(self, inPosition_3f, inDimension_3f, inCenterOfInterest_3f, inUpPosition_3f, inFieldOfView, inAspect, inNearZ, inFarZ)
        local Obj = Com.Objec3D:New()
        setmetatable(self, Com.Object3D)
        setmetatable(Obj, self)
        self.__index = self
        Obj.mIsOrtho = false
        Obj:Update(inPosition_3f, inDimension_3f, inCenterOfInterest_3f, inUpPosition_3f, inFieldOfView, inAspect, inNearZ, inFarZ)
        return Obj
    end,
    Update = function(self, inPosition_3f, inDimension_3f, inCenterOfInterest_3f, inUpPosition_3f, inFieldOfView, inAspect, inNearZ, inFarZ)
        self.mPosition_3f = inPosition_3f
        self.mEyePosition_3f = inPosition_3f
        self.mDimension_3f = inDimension_3f
        self.mCenterOfInterest_3f = inCenterOfInterest_3f
        self.mUpPosition_3f = inUpPosition_3f
        self.mAspect = inAspect
        self.mViewMatrix_4x4 = Jmath3D.lookat(self.mEyePosition_3f, self.mCenterOfInterest_3f, self.mUpPosition_3f)
        if not self.mIsOrtho then
            self.mProjMatrix_4x4 = Jmath3D.perspective(inFieldOfView, inAspect, inNearZ, inFarZ)
        end
    end
}

Com.SetCamera3D = function (inCamera)
    Three:write_to_global_ub_default(inCamera.mViewMatrix_4x4, inCamera.mProjMatrix_4x4, vec4(0, 0, 0))
end


Com.Painter3D = {
    mPainterId = nil,
    New = function (self, inCacheFileName, inShaderTable)
        local Obj = {}
        setmetatable(Obj, self)
        Obj.mPainterId = Three:add_painter(inCacheFileName, inShaderTable.v, inShaderTable.f, inShaderTable.c)
        self.__index = self
        return Obj
    end,
    Register = function (self)
        Three:register_global_ub_to_painter(self.mPainterId, 0, BindingGlobalUB, 0)
    end,
    Bind = function(self, inBindpoint)
        Three:painter_bind_for_draw(self.mPainterId, inBindpoint)
    end
}