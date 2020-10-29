-- 七伤拳		ability_abyss_14

LinkLuaModifier("modifier_ability_abyss_14", "ability/mechanism_Boss/ability_abyss_14", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_14 == nil then 
	ability_abyss_14 = class({})
end

function ability_abyss_14:IsHidden( ... )
	return true
end

function ability_abyss_14:GetIntrinsicModifierName()
	return "modifier_ability_abyss_14"
end

if modifier_ability_abyss_14 == nil then 
	modifier_ability_abyss_14 = class({})
end

function modifier_ability_abyss_14:IsHidden( ... )
	return true
end

function modifier_ability_abyss_14:OnCreated( kv )
	self.swipes_buff_damage = 0
end

function modifier_ability_abyss_14:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, 
		}
end

function modifier_ability_abyss_14:OnAttackLanded( kv )
	local hParent = self:GetParent()
	local hAttacker = kv.attacker   -- 攻击者	
	local target = kv.target   		-- 受害者   

	if hAttacker ~= hParent then
		return 0
	end

	if hParent:HasModifier("modifier_fury_swipes_buff") then 
		local swipes_buff = hParent:FindModifierByName("modifier_fury_swipes_buff"):GetStackCount()
		self.swipes_buff_damage = swipes_buff * 200
	end

	ApplyDamage({
		ability = self:GetAbility(),
		victim = hAttacker,
		attacker = hAttacker,
		damage = hAttacker:GetAttackDamage() + self.swipes_buff_damage,
		damage_type = DAMAGE_TYPE_PURE,
	})
	
end