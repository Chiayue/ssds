-- 怒意狂击		ability_abyss_15

LinkLuaModifier("modifier_ability_abyss_15", "ability/mechanism_Boss/ability_abyss_15", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_15_buff", "ability/mechanism_Boss/ability_abyss_15", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_15 == nil then 
	ability_abyss_15 = class({})
end

function ability_abyss_15:IsHidden( ... )
	return true
end

function ability_abyss_15:GetIntrinsicModifierName()
	return "modifier_ability_abyss_15"
end

if modifier_ability_abyss_15 == nil then 
	modifier_ability_abyss_15 = class({})
end

function modifier_ability_abyss_15:IsHidden( ... )
	return true
end

function modifier_ability_abyss_15:OnCreated( kv )
	 self.swipes_buff_damage = 0
end

function modifier_ability_abyss_15:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, 
			--MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_15:OnAttackLanded( kv )
	local hParent = self:GetParent()
	local hAttacker = kv.attacker   -- 攻击者	
	local hTarget = kv.target   		-- 受害者   

	if hAttacker ~= hParent then
		return 0
	end
	
	if hTarget:HasModifier("modifier_ability_abyss_15_buff") then 
		local swipes_buff = hTarget:FindModifierByName("modifier_ability_abyss_15_buff"):GetStackCount()
		--print("swipes_buff>>>>>>>>>>>>>>>>>="..swipes_buff)
		self.swipes_buff_damage = swipes_buff * 200
		--print("ability_abyss_15{self.swipes_buff_damage}>>>>>>>>>>>>>>>>>>>>>>>>>="..self.swipes_buff_damage)
	end

	ApplyDamage({
		ability = self:GetAbility(),
		victim = hTarget,
		attacker = hAttacker,
		damage = hAttacker:GetAttackDamage() + self.swipes_buff_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	})	

	hTarget:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_15_buff", {duration = 20})
end

if modifier_ability_abyss_15_buff == nil then 
	modifier_ability_abyss_15_buff = class({})
end

function modifier_ability_abyss_15_buff:IsHidden( ... )
	return false
end

function modifier_ability_abyss_15_buff:IsDebuff( ... )
	return true
end

function modifier_ability_abyss_15_buff:OnCreated( ... )
	if IsServer() then 
		self:SetStackCount(1)
	end
end

function modifier_ability_abyss_15_buff:OnRefresh( ... )
	if IsServer() then 
		self:IncrementStackCount()
	end
end