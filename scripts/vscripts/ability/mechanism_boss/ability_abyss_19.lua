-- 追踪导弹		ability_abyss_19

LinkLuaModifier("modifier_ability_abyss_19", "ability/mechanism_Boss/ability_abyss_19", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_19_move", "ability/mechanism_Boss/ability_abyss_19", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_19_control", "ability/mechanism_Boss/ability_abyss_19", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_19 == nil then
	ability_abyss_19 = class({})
end

function ability_abyss_19:IsHidden( ... )
	return true
end

function ability_abyss_19:OnSpellStart( ... )
    local hCaster = self:GetCaster()

    self.mob = CreateUnitByName("track_missiles_unit", hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 100), true, nil, nil, DOTA_TEAM_BADGUYS)
    self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_19_move", {})
    --self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_7_effects", {})
    self.mob:SetOwner(hCaster)
    self.mob:SetTeam(3)

	-- local enemys = FindUnitsInRadius(
	-- 			hCaster:GetTeamNumber(),
	-- 			hCaster:GetAbsOrigin(), 
	-- 			hCaster,
	-- 			99999, 
	-- 			DOTA_UNIT_TARGET_TEAM_ENEMY, 
	-- 			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
	-- 			0, 0, false)
	-- for _,enemy in pairs(enemys) do
    --     Unity_Name = hCaster
    --     if #enemy <= 1 then 
    --         enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_19_damage", {})
    --     end
	-- end
end

function ability_abyss_19:GetIntrinsicModifierName()
	return "modifier_ability_abyss_19"
end

if modifier_ability_abyss_19 == nil then 
	modifier_ability_abyss_19 = class({})
end

function modifier_ability_abyss_19:IsHidden( ... )
	return true
end

function modifier_ability_abyss_19:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_AVOID_DAMAGE, -- return 	keys.damage  直接免伤所有伤害(包括技能带来的所有伤害)
	}
end

function modifier_ability_abyss_19:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	local max_heal = hParent:GetHealth()
	local health = (max_heal - 1)
	hParent:SetHealth( health )
	if attacker:IsRealHero() then 
		if health <= 0 then
			hParent:ForceKill(true)
		end
	end
end

function modifier_ability_abyss_19:GetModifierAvoidDamage( keys )
	return keys.damage
end

-- 导弹的移动
if modifier_ability_abyss_19_move == nil then 
    modifier_ability_abyss_19_move = class({})
end

function modifier_ability_abyss_19_move:IsHidden( ... )
	return true
end

function modifier_ability_abyss_19_move:OnCreated( ... )
    local hParget = self.GetParent()

    self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, hParget) 
	ParticleManager:SetParticleControlEnt(self.particle, 1, hParget, PATTACH_POINT_FOLLOW, "attach_hitloc", hParget:GetAbsOrigin(), true)
end

