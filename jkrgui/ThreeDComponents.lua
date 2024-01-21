require "jkrgui.jkrgui"
local Three = {}
local BindingGlobalUB = 1

Com.Load3DComponents = function ()
    Three = Jkr3d.three(Jkr3d.SizeOfUB_Default, Jkr3d.SizeOfSSBO_Default)
end

Com.Bind3DComponents = function(inBindPoint)
    Three:bind(inBindPoint)
end

--[[
    Object3D is the base class for all the objects 
]]

Com.Object3D = {
    mPosition_3f = nil,
    mDimension_3f = nil,
    mRotation_3f = nil,
    mModelMatrix = nil,
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
        self.mModelMatrix = GetIdentityMatrix()
        self.mModelMatrix = Jmath3D.scale(self.mModelMatrix, inDimension_3f)
        self.mModelMatrix = Jmath3D.rotate(self.mModelMatrix, Jmath3D.magnitude(inRotation_3f),  Jmath3D.normalize(inRotation_3f) )
        self.mModelMatrix = Jmath3D.translate(self.mModelMatrix, inPosition_3f)
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
    New = function(self, inPosition_3f, inDimension_3f, inCenterOfInterest_3f, inUpPosition_3f, inFieldOfView, inAspect, inNearZ, inFarZ, isOrtho)
        local Obj = Com.Object3D:New(inPosition_3f, vec3(0), vec3(0) )
        setmetatable(self, Com.Object3D)
        setmetatable(Obj, self)
        self.__index = self
        Obj.mIsOrtho = isOrtho
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
        else
            -- TODO Orthographic Projection
        end
    end
}

Com.SetCamera3D = function (inCamera)
    Three:write_to_global_ub_default(inCamera.mViewMatrix_4x4, inCamera.mProjMatrix_4x4, vec4(0))
end


Com.Painter3D = {
    mPainterId = nil,
    New = function (self, inCacheFileName, inShaderTable, inForceStore)
        local Obj = {}
        setmetatable(Obj, self)
        Obj.mPainterId = Three:add_painter(inCacheFileName, inShaderTable.v, inShaderTable.f, inShaderTable.c, inForceStore)
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

Com.Model3DglTF = {
    mModelId = nil,
    New = function(self, inFilename, inPosition_3f, inDimension_3f, inRotation_3f)
        local Obj = Com.Object3D:New(inPosition_3f, inDimension_3f, inRotation_3f)
        setmetatable(self, Com.Object3D)
        setmetatable(Obj, self)
        self.__index = self
        Obj.mModelId = Three:add_model(inFilename)
        return Obj
    end,
    Draw = function (self, inPainter, inBindpoint)
        inPainter:Bind(inBindpoint) 
        Three:painter_draw(inPainter.mPainterId, self.mModelId, inBindpoint, self.mModelMatrix, vec4(1), vec4(1)) --these are push constant stuffs, will be used when this matures further
    end
}