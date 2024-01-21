require "jkrgui.jkrgui"
Jmath3D = jmath3D

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
    New = function(self)
        local Obj = Com.Objec3D:New()
        setmetatable(self, Com.Object3D)
        setmetatable(Obj, self)
        self.__index = self
        Obj.mIsOrtho = false
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