-- 凭什么和我打		ability_abyss_16

LinkLuaModifier("modifier_ability_abyss_16", "ability/mechanism_Boss/ability_abyss_16", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_16 == nil then 
	ability_abyss_16 = class({})
end

function ability_abyss_16:IsHidden( ... )
	return true
end

function ability_abyss_16:GetIntrinsicModifierName()
	return "modifier_ability_abyss_16"
end

if modifier_ability_abyss_16 == nil then 
	modifier_ability_abyss_16 = class({})
end

function modifier_ability_abyss_16:IsHidden( ... )
	return true
end

function modifier_ability_abyss_16:OnCreated( kv )
	local hParent = self:GetParent()
	self.heal_percentage = 0
	if IsServer() then 
		self:StartIntervalThink(1)
	end

	local EffectName = "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
	self.nFXIndex_3 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
	ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 0, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_1", hParent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 0, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_2", hParent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)

	self:AddParticle(self.nFXIndex_3, false, false, -1, false, true)
end

function modifier_ability_abyss_16:OnIntervalThink( ... )
	local hParent = self:GetParent()

	if IsServer() then 
		local reduce_max_heal = hParent:GetHealth() - hParent:GetMaxHealth() * 0.01
		hParent:SetHealth(reduce_max_heal)
		if reduce_max_heal == 0 then 
			hParent:ForceKill(true)
			return 0
		end
		local reduce_heal_percentage = hParent:GetHealthPercent()
		--print("heal_percentage>>>>>>>>>>>>>"..heal_percentage)
		self.heal_percentage = 100
		self.heal_percentage = self.heal_percentage - reduce_heal_percentage
		--print("self.heal_percentage>>>>>>>>>>>>>"..self.heal_percentage) 
	end
end

function modifier_ability_abyss_16:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, 
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		}
end

function modifier_ability_abyss_16:OnAttackLanded( kv )
	local hParent = self:GetParent()
	local hAttacker = kv.attacker   -- 攻击者	
	local target = kv.target   		-- 受害者   

	if hAttacker ~= hParent then
		return 0
	end
	
	local attack_damage_heal = hParent:GetAttackDamage()
	--print("attack_damage_heal>>>>>>>>>>>>>>>>>>>>>>>>>>>="..attack_damage_heal)
	hAttacker:Heal(attack_damage_heal, hAttacker)
end

function modifier_ability_abyss_16:GetModifierMoveSpeedBonus_Constant( kv )
	--print("self.heal_percentage>>>>>>>>>>>>>{MoveSpeed}="..self.heal_percentage * 3)
	return self.heal_percentage * 3
end

function modifier_ability_abyss_16:GetModifierAttackSpeedBonus_Constant( kv )
	--print("self.heal_percentage>>>>>>>>>>>>>{AttackSpeed}="..self.heal_percentage * 5)
	return self.heal_percentage * 5
end

function modifier_ability_abyss_16:GetModifierBaseAttack_BonusDamage()
	return self.heal_percentage * 20
end