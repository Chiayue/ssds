LinkLuaModifier( "modifier_archon_passive_resist_armour", "ability/archon_passive_resist_armour.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_resist_armour_particles", "ability/archon_passive_resist_armour.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_resist_armour == nil then
	archon_passive_resist_armour = class({})
end

function archon_passive_resist_armour:GetIntrinsicModifierName()
 	return "modifier_archon_passive_resist_armour"
end
--------------------------------------------------
if modifier_archon_passive_resist_armour == nil then
	modifier_archon_passive_resist_armour = class({})
end

function modifier_archon_passive_resist_armour:IsHidden()
	return true
end

function modifier_archon_passive_resist_armour:OnCreated()
	if IsServer() then -- and self:GetParent() ~= self:GetCaster() 
		self.armour_nuber = 0
	 	self.heroes_level = 0
		self:StartIntervalThink(0.5)
	end
end

function modifier_archon_passive_resist_armour:OnIntervalThink( ... )
	if IsServer() then 
		local hCaster = self:GetCaster()
		local nLevel = self:GetAbility():GetLevel()
		local hLevel = hCaster:GetLevel()
		
		if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
			if hLevel > self.heroes_level then 
				self.armour_nuber = self.armour_nuber + 1
				hCaster:SetModifierStackCount( "modifier_archon_passive_resist_armour", hCaster, self.armour_nuber )  -- 给修饰器堆栈计数
				self.heroes_level = hLevel
			end
		elseif nLevel >= ABILITY_AWAKEN_2 then 
			if hLevel > self.heroes_level then 
				self.armour_nuber = self.armour_nuber + 3
				hCaster:SetModifierStackCount( "modifier_archon_passive_resist_armour", hCaster, self.armour_nuber )  -- 给修饰器堆栈
				self.heroes_level = hLevel
			end
		end
	end
end

function modifier_archon_passive_resist_armour:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_resist_armour:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_archon_passive_resist_armour:OnAttackLanded( params )
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
	local nLevel = self:GetAbility():GetLevel()
	local hTarget = params.target

	local EffectName = "particles/down_particles/blue/down_particles_blue.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	ParticleManager:SetParticleControl(nFXIndex, 1, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(nFXIndex, 3, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(nFXIndex, 4, hTarget:GetAbsOrigin())

	EmitSoundOn( "Hero_VengefulSpirit.WaveOfTerror", hTarget )
	-- 范围伤害
	-- local enemies = FindUnitsInRadius(
	-- 	self:GetCaster():GetTeamNumber(), 
	-- 	hTarget:GetOrigin(), 
	-- 	hTarget, 
	-- 	aoe, 
	-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, 
	-- 	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
	-- 	0, 0, false 
	-- )

	local enemies = GetAOEMostTargetsSpellTarget(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC )

	local abil_damage = hCaster:GetPhysicalArmorValue(false) * hCaster:GetPhysicalArmorValue(false) * damage_coefficient
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

function modifier_archon_passive_resist_armour:GetModifierPhysicalArmorBonus()
	 return self:GetCaster():GetModifierStackCount("modifier_archon_passive_resist_armour", nil)
end