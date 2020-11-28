-- 奇门八卦 ability_abyss_26

LinkLuaModifier("modifier_ability_abyss_26_buff", "ability/mechanism_Boss/ability_abyss_26", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_26_debuff", "ability/mechanism_Boss/ability_abyss_26", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_26 == nil then 
    ability_abyss_26 = class({})
end

function ability_abyss_26:IsHidden( ... )
	return true
end

function ability_abyss_26:OnSpellStart( ... )
    local hCaster = self:GetCaster()

    local enemies = GetAOEMostTargetsSpellTarget(
		hCaster:GetTeamNumber(), 
		hCaster:GetOrigin(), 
		hCaster, 
		99999, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
    )
    
    for _,enemy in pairs(enemies) do
	    CreateModifierThinker(hCaster, self, "modifier_ability_abyss_26_buff", {duration = 3}, enemy:GetAbsOrigin(), hCaster:GetTeamNumber(), false)
    end
end

if modifier_ability_abyss_26_buff == nil then 
    modifier_ability_abyss_26_buff = class({})
end

function modifier_ability_abyss_26_buff:IsHidden( ... )
	return true
end

function modifier_ability_abyss_26_buff:IsAura()
	return true
end

function modifier_ability_abyss_26_buff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_ability_abyss_26_buff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_ability_abyss_26_buff:GetModifierAura()
	return "modifier_ability_abyss_26_debuff"
end

function modifier_ability_abyss_26_buff:GetAuraRadius()
	return 500
end

function modifier_ability_abyss_26_buff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_ability_abyss_26_buff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_ability_abyss_26_buff:OnCreated( ... )
    local hParent = self:GetParent()

    local EffectName = "particles/econ/items/monkey_king/arcana/water/monkey_king_spring_cast_arcana_water.vpcf"
    self.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent)
    ParticleManager:SetParticleControl( self.nFXIndex, 0, hParent:GetAbsOrigin())
    ParticleManager:SetParticleControl( self.nFXIndex, 3, hParent:GetAbsOrigin())
    ParticleManager:SetParticleControl( self.nFXIndex, 4, hParent:GetAbsOrigin())
end

function modifier_ability_abyss_26_buff:OnDestroy( ... )
    if self.nFXIndex ~= nil then 
        ParticleManager:DestroyParticle( self.nFXIndex, false )
		ParticleManager:ReleaseParticleIndex( self.nFXIndex )
		self.nFXIndex = nil
    end
end

if modifier_ability_abyss_26_debuff == nil then 
    modifier_ability_abyss_26_debuff = class({})
end

function modifier_ability_abyss_26_debuff:IsHidden( ... )
	return true
end

function modifier_ability_abyss_26_debuff:OnCreated( ... )
    if IsServer() then 
        self:StartIntervalThink(2)
    end
end

function modifier_ability_abyss_26_debuff:OnIntervalThink( ... )
    local hParent = self:GetParent()
	local hCaster = self:GetCaster()

    if IsServer() then 
        local enemies = GetAOEMostTargetsSpellTarget(
            hCaster:GetTeamNumber(), 
            hParent:GetOrigin(), 
            hParent, 
            500, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
            )

        for _,enemy in pairs(enemies) do
            local all_damage = enemy:GetMaxHealth() * 0.2
            print("all_damage", all_damage)
            ApplyDamage({
                attacker = hCaster,
                victim = enemy,
                damage = all_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
            })
        end
    end
end