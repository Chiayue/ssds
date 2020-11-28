-- 缠绕  ability_abyss_22
LinkLuaModifier("modifier_ability_abyss_22_debuff", "ability/mechanism_Boss/ability_abyss_22", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_22_buff", "ability/mechanism_Boss/ability_abyss_22", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_22 == nil then 
    ability_abyss_22 = class({})
end

function ability_abyss_22:IsHidden( ... )
	return true
end

function ability_abyss_22:OnSpellStart( ... )
	local hCaster = self:GetCaster()

    hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_22_buff", {duration = 2})

    local enemys = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hCaster:GetAbsOrigin(), 
		hCaster, 
		99999, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
        0, 0, false)
        
    for _, enemy in pairs(enemys) do 
        enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_22_debuff", {duration = 2})
    end
end

if modifier_ability_abyss_22_buff == nil then 
    modifier_ability_abyss_22_buff = class({})
end

function modifier_ability_abyss_22_buff:IsHidden( ... )
	return false
end

function modifier_ability_abyss_22_buff:IsDebuff( ... )
	return false
end

function modifier_ability_abyss_22_buff:OnCreated( ... )
    -- if IsClient() then
	-- 	local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_bramble_root.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	-- 	self:AddParticle(iParticleID, false, false, -1, false, false)
	-- end
end

function modifier_ability_abyss_22_buff:CheckState()
	return {
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}
end

if modifier_ability_abyss_22_debuff == nil then 
    modifier_ability_abyss_22_debuff = class({})
end

function modifier_ability_abyss_22_debuff:IsHidden( ... )
	return false
end

function modifier_ability_abyss_22_debuff:IsDebuff( ... )
	return true
end

function modifier_ability_abyss_22_debuff:OnCreated( ... )
    if IsClient() then
		local iParticleID = ParticleManager:CreateParticle("particles/units/heroes/hero_treant/treant_bramble_root.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(iParticleID, false, false, -1, false, false)
	end
end

function modifier_ability_abyss_22_debuff:CheckState()
	return {
        [MODIFIER_STATE_ROOTED] = true,
		--[MODIFIER_STATE_STUNNED] = true
	}
end