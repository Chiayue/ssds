-- 风元素 	item_the_wind_elements_invulnerable

LinkLuaModifier("modifier_item_the_wind_elements_invincible_buff", "item/item_the_wind_elements_invulnerable", LUA_MODIFIER_MOTION_BOTH)

if item_the_wind_elements_invulnerable == nil then 
	item_the_wind_elements_invulnerable = class({})
end

function item_the_wind_elements_invulnerable:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_item_the_wind_elements_invincible_buff", {duration = 3})
	self:SpendCharge()
end

if modifier_item_the_wind_elements_invincible_buff == nil then 
	modifier_item_the_wind_elements_invincible_buff = class({})
end

function modifier_item_the_wind_elements_invincible_buff:IsHidden()
	return false
end
function modifier_item_the_wind_elements_invincible_buff:GetTexture()
	return "item_feng"
end

function modifier_item_the_wind_elements_invincible_buff:IsStunDebuff()
	return true
end

function modifier_item_the_wind_elements_invincible_buff:OnCreated( ... )
	if IsServer() then 
		if self:ApplyVerticalMotionController() and self:ApplyHorizontalMotionController() then
			local hCaster = self:GetCaster()
			local hParent = self:GetParent()

			self.fAngularSpeed = 490
			self.fDuration = self:GetDuration() * 0.2
			-- local fHeightDifference = 450
			local vUpVector = hParent:GetUpVector()
			self.vAcceleration = -vUpVector * 5000
			self.vStartVerticalVelocity = Vector(0, 0, 0) / self.fDuration - self.vAcceleration * self.fDuration / 2
			self.fTime = 0

			local EffectName = "particles/units/heroes/hero_invoker/invoker_tornado.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hCaster)
			ParticleManager:SetParticleControl( self.nFXIndex_0, 0, self:GetParent():GetAbsOrigin())
		else
			self:Destroy()
		end
	end
end

function modifier_item_the_wind_elements_invincible_buff:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nFXIndex_0, false )
		ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
		self.nFXIndex_0 = nil

		self:GetParent():RemoveHorizontalMotionController(self)
		self:GetParent():RemoveVerticalMotionController(self)
	end
end

function modifier_item_the_wind_elements_invincible_buff:UpdateVerticalMotion(me, dt)
	if IsServer() then
		if self:GetElapsedTime() <= self.fDuration / 2 then
			self.fTime = self.fTime + dt
			me:SetAbsOrigin(me:GetAbsOrigin() + (self.vAcceleration * self.fTime + self.vStartVerticalVelocity) * dt)
		elseif self:GetRemainingTime() <= self.fDuration / 2 then
			self.fTime = self.fTime + dt
			me:SetAbsOrigin(me:GetAbsOrigin() + (self.vAcceleration * self.fTime + self.vStartVerticalVelocity) * dt)
		end
		local vAngles = me:GetLocalAngles()
		me:SetLocalAngles(vAngles[1], vAngles[2] + self.fAngularSpeed * dt, vAngles[3])
	end
end

function modifier_item_the_wind_elements_invincible_buff:CheckState( ... )
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
	return state
end

function modifier_item_the_wind_elements_invincible_buff:DeclareFunctions(  ) -- 修改动画  声明修改内容
	local funs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funs
end

function modifier_item_the_wind_elements_invincible_buff:GetOverrideAnimation( ... )
	return ACT_DOTA_DISABLED
end