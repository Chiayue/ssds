LinkLuaModifier( "modifier_archon_passive_second_mshot", "ability/archon_passive_second_mshot.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_second_mshot == nil then
	archon_passive_second_mshot = class({})
end

function archon_passive_second_mshot:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_mshot"
end

function archon_passive_second_mshot:OnProjectileHit( hTarget, vLocation )
	local attacker = self:GetCaster()
	local damage = attacker.GetAttackDamage(attacker)
	local info = {
		victim = hTarget,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
	}
	ApplyDamage(info)
end
--------------------------------------------------------------------------------
-- modifier
if modifier_archon_passive_second_mshot == nil then
	modifier_archon_passive_second_mshot = class({})
end


--------------------------------------------------------------------------------
function modifier_archon_passive_second_mshot:IsDebuff()
	return false
end

function modifier_archon_passive_second_mshot:IsHidden()
	return true
end

function modifier_archon_passive_second_mshot:OnCreated( kv )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	--self.great_cleave_radius = self:GetAbility():GetSpecialValueFor( "great_cleave_radius" )
end

--------------------------------------------------------------------------------

function modifier_archon_passive_second_mshot:OnRefresh( kv )
	self.chance = self:GetAbility():GetSpecialValueFor( "chance" )
	--self.great_cleave_radius = self:GetAbility():GetSpecialValueFor( "great_cleave_radius" )
end
----------------------
function modifier_archon_passive_second_mshot:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK ,
	}
	return funcs
end

function modifier_archon_passive_second_mshot:OnAttack( params )

	if params then

		local caster = params.attacker -- 这是一个实体
		local target = params.target
		if caster ~= self:GetParent() then
			return 0
		end
		local caster_location = caster:GetAbsOrigin()
		local projectile_speed = caster.GetProjectileSpeed(caster)
		local ability = self:GetAbility()
		local aoe = ability:GetSpecialValueFor("aoe")
		local max_targets = ability:GetSpecialValueFor("counts")
		local caster_location = target:GetAbsOrigin()
		--print(caster:GetBaseAttackRange())
		local split_shot_targets = FindUnitsInRadius(
			caster:GetTeamNumber(), 
			caster:GetOrigin(), 
			caster, 
			aoe, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false 
		)
		-- Create projectiles for units that are not the casters current attack target
		for _,v in pairs(split_shot_targets) do
			if v ~= params.target then
				local projectile_info = {
					EffectName = "particles/units/heroes/hero_medusa/medusa_base_attack.vpcf",
					Ability = ability,
					vSpawnOrigin = caster_location,
					Target = v,
					Source = caster,
					bHasFrontalCone = false,
					iMoveSpeed = projectile_speed,
					bReplaceExisting = false,
					bProvidesVision = false
				}
				ProjectileManager:CreateTrackingProjectile(projectile_info)
				max_targets = max_targets - 1
			end
			-- If we reached the maximum amount of targets then break the loop
			if max_targets == 0 then break end
		end
	end
	
end
--------------------------------------------------------------------------------

function modifier_archon_passive_second_mshot:OnProjectileHit( params )
	local caster = params.attacker
	local target = params.target
	local ability = self:GetAbility()
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = params.damage

	ApplyDamage(damage_table)
end