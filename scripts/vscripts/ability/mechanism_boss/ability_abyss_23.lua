-- 毒性皮肤 ability_abyss_23

LinkLuaModifier("modifier_ability_abyss_23_passivity", "ability/mechanism_Boss/ability_abyss_23", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_23_debuff", "ability/mechanism_Boss/ability_abyss_23", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_23 == nil then 
    ability_abyss_23 = class({})
end

function ability_abyss_23:IsHidden( ... )
	return true
end

function ability_abyss_23:GetIntrinsicModifierName()
	return "modifier_ability_abyss_23_passivity"
end

if modifier_ability_abyss_23_passivity == nil then 
	modifier_ability_abyss_23_passivity = class({})
end

function modifier_ability_abyss_23_passivity:IsHidden( ... )
	return true
end

function modifier_ability_abyss_23_passivity:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_ability_abyss_23_passivity:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	local chance = 100

    local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
    end

    keys.attacker:AddNewModifier(hParent, nil, "modifier_ability_abyss_23_debuff", {duration = 3})
end

if modifier_ability_abyss_23_debuff == nil then 
	modifier_ability_abyss_23_debuff = class({})
end

function modifier_ability_abyss_23_debuff:IsHidden( ... )
	return false
end

function modifier_ability_abyss_23_debuff:OnCreated( ... )
    if IsServer() then 
        self:StartIntervalThink(1)
    end
end

function modifier_ability_abyss_23_debuff:OnIntervalThink( ... )
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()

    if IsServer() then 
        local attackdamage_caster = self:GetCaster():GetAttackDamage()* 0.1
        ApplyDamage({
            victim = hParent,
            attacker = hCaster,
            damage = attackdamage_caster ,
            damage_type = DAMAGE_TYPE_MAGICAL,
        })
    end
end

function modifier_ability_abyss_23_debuff:DeclareFunctions( ... )
	return{
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_abyss_23_debuff:GetModifierAttackSpeedBonus_Constant()
    -- 攻速变化
    return -100
end