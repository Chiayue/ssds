-- 雷元素		item_ray_elements

LinkLuaModifier("modifier_item_ray_elements_debuff", "item/item_ray_elements", LUA_MODIFIER_MOTION_NONE)

if item_ray_elements == nil then 
	item_ray_elements = class({})
end

function item_ray_elements:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_item_ray_elements_debuff", {duration = 1})
	self:SpendCharge()
end

if modifier_item_ray_elements_debuff == nil then 
	modifier_item_ray_elements_debuff = class({})
end

function modifier_item_ray_elements_debuff:IsHidden()
	return false
end

function modifier_item_ray_elements_debuff:GetTexture()
	return "item_lei"
end

function modifier_item_ray_elements_debuff:IsStunDebuff()
	return true
end

function modifier_item_ray_elements_debuff:IsDebuff()
	return true
end

function modifier_item_ray_elements_debuff:OnCreated( ... )
	local hParent = self:GetParent()
	
	local EffectName = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_stunned.vpcf"
	self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hParent)
	ParticleManager:SetParticleControl( self.nFXIndex_0, 0, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl( self.nFXIndex_0, 4, hParent:GetAbsOrigin())
end

function modifier_item_ray_elements_debuff:OnDestroy( ... )
	ParticleManager:DestroyParticle( self.nFXIndex_0, false )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
	self.nFXIndex_0 = nil
end

function modifier_item_ray_elements_debuff:CheckState( ... )
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_item_ray_elements_debuff:DeclareFunctions(  ) -- 修改动画  声明修改内容
	local funs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funs
end

function modifier_item_ray_elements_debuff:GetOverrideAnimation( ... )
	return ACT_DOTA_DISABLED
end