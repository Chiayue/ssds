-- 死亡不屈 ability_abyss_24

LinkLuaModifier("modifier_ability_abyss_24_passivity", "ability/mechanism_Boss/ability_abyss_24", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_24_debuff", "ability/mechanism_Boss/ability_abyss_24", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_24 == nil then 
    ability_abyss_24 = class({})
end

function ability_abyss_24:IsHidden( ... )
	return true
end

function ability_abyss_24:GetIntrinsicModifierName()
	return "modifier_ability_abyss_24_passivity"
end

if modifier_ability_abyss_24_passivity == nil then 
	modifier_ability_abyss_24_passivity = class({})
end

function modifier_ability_abyss_24_passivity:IsHidden( ... )
	return true
end

function modifier_ability_abyss_24_passivity:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_ability_abyss_24_passivity:OnDeath( keys )
    local hParent = self:GetParent()
    
	local enemys = FindUnitsInRadius(
		hParent:GetTeamNumber(), 
		hParent:GetAbsOrigin(), 
		hParent, 
		99999, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        0, 0, false)
        
    for _, enemy in pairs(enemys) do 
        local ability_bink = enemy:FindAbilityByName("archon_blink")
        if ability_bink ~= nil then 
            local ability_bink_level = ability_bink:GetLevel()
            local ability_bink_cooldown = ability_bink:GetCooldown(ability_bink_level)

            if not ability_bink:IsFullyCastable() then
                return
            else
                ability_bink:StartCooldown(ability_bink_cooldown)
            end
        end
    end
end

if modifier_ability_abyss_24_debuff == nil then 
	modifier_ability_abyss_24_debuff = class({})
end

function modifier_ability_abyss_24_debuff:IsHidden( ... )
	return false
end

function modifier_ability_abyss_24_debuff:OnCreated( ... )
    if IsServer() then 
        self:StartIntervalThink(1)
    end
end

function modifier_ability_abyss_24_debuff:OnIntervalThink( ... )
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

function modifier_ability_abyss_24_debuff:DeclareFunctions( ... )
	return{
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end

function modifier_ability_abyss_24_debuff:GetModifierAttackSpeedBonus_Constant()
    -- 攻速变化
    return -100
end