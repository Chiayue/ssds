-- 敌人Boss技能

-- 【潜力爆发】受到伤害移动速度提高
LinkLuaModifier("modifier_ability_boss_speed_burst", "autistic/autistic_boss", LUA_MODIFIER_MOTION_NONE)
ability_boss_speed_burst = {}
function ability_boss_speed_burst:GetIntrinsicModifierName()
	return "modifier_ability_boss_speed_burst"
end

modifier_ability_boss_speed_burst = {}
function modifier_ability_boss_speed_burst:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN
    }
end
function modifier_ability_boss_speed_burst:IsHidden() return false end
function modifier_ability_boss_speed_burst:OnCreated() self:SetStackCount(0) end
function modifier_ability_boss_speed_burst:GetModifierMoveSpeed_AbsoluteMin() return 250 + self:GetStackCount() * 20 end
function modifier_ability_boss_speed_burst:GetModifierIncomingDamage_Percentage(keys) 
	local nDamagePer = self:GetStackCount()
	if nDamagePer > 50 then nDamagePer = 50 end
	return -nDamagePer
end

function modifier_ability_boss_speed_burst:OnTakeDamage(keys)
	local hParent = self:GetParent()
	if keys.unit == hParent and self:GetAbility():IsCooldownReady() then
		self:GetAbility():UseResources(true, true, true)
		self:IncrementStackCount()
	end
end

-----------------------------  暗影冲刺 -------------------------
LinkLuaModifier("modifier_ability_boss_charge_of_darkness", "autistic/autistic_boss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_boss_charge_of_darkness_target", "autistic/autistic_boss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_boss_charge_of_darkness_buff", "autistic/autistic_boss", LUA_MODIFIER_MOTION_NONE)
---------
modifier_ability_boss_charge_of_darkness = {}
function modifier_ability_boss_charge_of_darkness:IsHidden() return true end
function modifier_ability_boss_charge_of_darkness:OnCreated()
	if not IsServer() then return end
	local hAllHero = HeroList:GetAllHeroes()
	local hTarget = hAllHero[ RandomInt(2, #hAllHero) ]
	hTarget:AddNewModifier(self:GetParent(), self, "modifier_ability_boss_charge_of_darkness_target", {})
	self:StartIntervalThink(0.25)
end
function modifier_ability_boss_charge_of_darkness:OnIntervalThink()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_ability_boss_charge_of_darkness:IsPurgable()	return false end
function modifier_ability_boss_charge_of_darkness:GetEffectName()
	return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf"
end
function modifier_ability_boss_charge_of_darkness:GetStatusEffectName()
	return "particles/status_fx/status_effect_charge_of_darkness.vpcf"
end
function modifier_ability_boss_charge_of_darkness:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_ability_boss_charge_of_darkness:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_EVENT_ON_ORDER
	}
end

function modifier_ability_boss_charge_of_darkness:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_ability_boss_charge_of_darkness:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount() * 10
end

---------- 显
modifier_ability_boss_charge_of_darkness_target = {}
function modifier_ability_boss_charge_of_darkness_target:CheckState()
	return {[MODIFIER_STATE_PROVIDES_VISION] = true}
end