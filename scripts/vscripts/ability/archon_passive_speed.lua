LinkLuaModifier( "modifier_archon_passive_speed", "ability/archon_passive_speed.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_speed_particles", "ability/archon_passive_speed.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_speed == nil then
	archon_passive_speed = class({})
end

function archon_passive_speed:GetIntrinsicModifierName()
 	return "modifier_archon_passive_speed"
end
--------------------------------------------------
if modifier_archon_passive_speed == nil then
	modifier_archon_passive_speed = class({})
end

function modifier_archon_passive_speed:IsHidden()
	return true
end

function modifier_archon_passive_speed:OnCreated()
	if IsServer() then -- and self:GetParent() ~= self:GetCaster()
		self:StartIntervalThink(0.5)
		self.speed_of_damage = 0
	end
end

function modifier_archon_passive_speed:OnIntervalThink( ... )
	local hCaster = self:GetCaster()
	local nLevel = self:GetAbility():GetLevel()
	if IsServer() then 
		if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
			self.speed_of_damage = hCaster:GetDisplayAttackSpeed() * 0.5
		elseif nLevel >= ABILITY_AWAKEN_2 then 
			self.speed_of_damage = hCaster:GetDisplayAttackSpeed()
		end
	end
end

function modifier_archon_passive_speed:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}
	return funcs
end

-- function modifier_archon_passive_speed:GetEffectName()
-- 	return "particles/econ/items/wisp/wisp_relocate_timer_buff_ti7_sparkle_blue.vpcf"
-- end

function modifier_archon_passive_speed:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local hCaster = self:GetCaster()
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local damage_coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
	if nowChance  > chance then
		return 0
	end
	local hTarget = params.target
	
	-- particles/econ/courier/courier_cluckles/courier_cluckles_ambient_rocket_explosion.vpcf
	-- particles/units/heroes/hero_techies/techies_blast_off.vpcf
	-- particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_illumination.vpcf

	-- local EffectName = "particles/econ/courier/courier_cluckles/courier_cluckles_ambient_rocket_explosion.vpcf"
	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex, 3, hTarget:GetAbsOrigin())
	-- -- 新建特效 
	-- local EffectName_1 = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
	-- local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_1, 1, hTarget:GetAbsOrigin())

	-- local EffectName_2 = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_illumination.vpcf"
	-- local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(500, 500, 500))

	hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_speed_particles", {duration = 1})
		
	EmitSoundOn( "Ability.LightStrikeArray", hTarget )
	-- 范围伤害 
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	local abil_damage = hCaster:GetDisplayAttackSpeed() * hCaster:GetDisplayAttackSpeed() * damage_coefficient
	--print("speed_attack=============>", hCaster:GetDisplayAttackSpeed())
	--print("abil_damage===========>", abil_damage)
	--print("attacker_damage-------------------------->", self.speed_of_damage )
	for _,enemy in pairs(enemies) do
		if enemy ~= nil then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = abil_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage( damage )
			
		end
	end
end

function modifier_archon_passive_speed:GetModifierBaseAttack_BonusDamage()
	return self.speed_of_damage
end

if modifier_archon_passive_speed_particles == nil then 
	modifier_archon_passive_speed_particles = class({})
end

function modifier_archon_passive_speed_particles:IsHidden()
	return true
end

function modifier_archon_passive_speed_particles:OnCreated( args )
	--if not IsServer() then return end
	local hParent = self:GetParent()
	--local hTarget = args.target
	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then
		local EffectName = "particles/econ/courier/courier_cluckles/courier_cluckles_ambient_rocket_explosion.vpcf"
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 3, hParent:GetAbsOrigin())
		-- 新建特效
		local EffectName_1 = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 1, hParent:GetAbsOrigin())

		local EffectName_2 = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_illumination.vpcf"
		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 0, Vector(500, 500, 500))
	end
end

function modifier_archon_passive_speed_particles:OnDestroy()
	--if not IsServer() then return end
	local hParent = self:GetParent()
	if hParent.nFXIndex and hParent.nFXIndex_1 and hParent.nFXIndex_2 then 
		ParticleManager:DestroyParticle( hParent.nFXIndex, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex )
		hParent.nFXIndex = nil

		ParticleManager:DestroyParticle( hParent.nFXIndex_1, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_1 )
		hParent.nFXIndex_1 = nil

		ParticleManager:DestroyParticle( hParent.nFXIndex_2, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_2 )
		hParent.nFXIndex_2 = nil
	end
end