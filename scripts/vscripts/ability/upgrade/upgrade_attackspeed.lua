LinkLuaModifier( "modifier_Upgrade_AttackSpeed", "ability/upgrade/Upgrade_AttackSpeed.lua",LUA_MODIFIER_MOTION_NONE )

-- 【幻影】攻击有7%几率额外攻击一次（虚空3技能） 可触发天赋被动
LinkLuaModifier("modifier_tech_max_attackspeed_multe", "ability/upgrade/Upgrade_AttackSpeed.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tech_max_attackspeed_multe_phantom", "ability/upgrade/Upgrade_AttackSpeed.lua", LUA_MODIFIER_MOTION_NONE)


if modifier_Upgrade_AttackSpeed == nil then
	modifier_Upgrade_AttackSpeed = {}
end

function modifier_Upgrade_AttackSpeed:GetTexture()
	return "gongsu"
end

function modifier_Upgrade_AttackSpeed:IsHidden()
	return true
end

function modifier_Upgrade_AttackSpeed:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_Upgrade_AttackSpeed:OnCreated()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_AttackSpeed" )
end

function modifier_Upgrade_AttackSpeed:OnRefresh()
	self.bonus = self:GetAbility():GetSpecialValueFor( "Upgrade_AttackSpeed" )
	if IsServer() then
		self:IncrementStackCount()
	end
	
end

function modifier_Upgrade_AttackSpeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end

function modifier_Upgrade_AttackSpeed:GetModifierAttackSpeedBonus_Constant()
	return self.bonus * self:GetStackCount()
end

function modifier_Upgrade_AttackSpeed:OnAttack(keys)
	if not IsServer() then return end
	if self:GetStackCount() ~= 10 then return end
	-- Make sure the attacker and target are valid
	if keys.attacker:HasModifier("modifier_tech_max_attackspeed_multe") == true then return end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled()  then
		local hCaster = self:GetCaster()
		self:GetAbility().HitTarget = keys.target
		if hCaster:HasModifier("modifier_tech_max_attackspeed_multe_phantom") then
			return
		end
		local nChance = RandomInt(0,100)
		if nChance  > 7 then
			return 0
		end
		hCaster:AddNewModifier( 
			self:GetCaster(), 
			self:GetAbility(), 
			"modifier_tech_max_attackspeed_multe", 
			{ duration = 1} 
		)
	end
end

if modifier_tech_max_attackspeed_multe == nil then
	modifier_tech_max_attackspeed_multe = class({})
end
-- 创建一个连击修饰器
function modifier_tech_max_attackspeed_multe:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_tech_max_attackspeed_multe:IsHidden() return true end
function modifier_tech_max_attackspeed_multe:OnIntervalThink()
	self:GetCaster():AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		"modifier_tech_max_attackspeed_multe_phantom", 
		{ duration = 0.5} 
	)
	-- local hCaster = self:GetCaster()
	-- local hTarget = self:GetAbility().HitTarget
	-- 	-- Prepare for the second attack
	-- local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", PATTACH_CUSTOMORIGIN, nil)
	-- ParticleManager:SetParticleControl(particle, 0, hCaster:GetAbsOrigin() )
	-- ParticleManager:SetParticleControl(particle, 1, hCaster:GetAbsOrigin() )
	-- ParticleManager:SetParticleControlEnt(particle, 2, self:GetParent(), PATTACH_CUSTOMORIGIN, "attach_hitloc", hCaster:GetAbsOrigin(), true)
	-- ParticleManager:ReleaseParticleIndex(particle)
	-- self:GetCaster():PerformAttack(hTarget, true, true, true, true, true, false, false)
	-- self:Destroy()
end

if modifier_tech_max_attackspeed_multe_phantom == nil then
	modifier_tech_max_attackspeed_multe_phantom = {}
end
function modifier_tech_max_attackspeed_multe_phantom:IsHidden() return true end
