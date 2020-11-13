LinkLuaModifier( "modifier_archon_passive_time", "ability/archon_passive_time.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_time_particles", "ability/archon_passive_time.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_time == nil then
	archon_passive_time = class({})
end

function archon_passive_time:GetIntrinsicModifierName()
 	return "modifier_archon_passive_time"
end
--------------------------------------------------
if modifier_archon_passive_time == nil then
	modifier_archon_passive_time = class({})
end

function modifier_archon_passive_time:IsHidden()
	return true
end

function modifier_archon_passive_time:OnCreated()
	if IsServer() and self:GetParent() ~= self:GetCaster() then
		
	end
end

function modifier_archon_passive_time:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_time:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_archon_passive_time:OnAttackLanded( params )
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
	local nTalentStack = hCaster:GetModifierStackCount("modifier_series_reward_talent_greed", hCaster )
	if nTalentStack >=2 then chance = chance + 5 end
	if nowChance  > chance then
		return 0
	end
	local nLevel = self:GetAbility():GetLevel()
	local hTarget = params.target
	local EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf"
	SendParticlesToClient(EffectName,hTarget)
	EmitSoundOn( "Hero_Zuus.StaticField", hTarget )
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

	-- 获取所有玩家等级 * （ 地图等级 * 100% ）
	local hlevel = hCaster:GetLevel()
	local nLevel = self:GetAbility():GetLevel()
	--local abil_damage = 0
	if nLevel >= ABILITY_AWAKEN_2 then
		local total_plauer_level = GetAllHeroesCountLevel()
		abil_damage = hlevel * total_plauer_level * damage_coefficient
	else
		abil_damage = hlevel * hlevel * damage_coefficient 
	end
	
	--print("abil_damage===========>", abil_damage,"total_plauer_level",total_plauer_level)
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

function modifier_archon_passive_time:OnDeath(args)
	--if not IsServer() then return end
	local hAttacker = args.attacker
	local hTarget = args.unit
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nLevel = self:GetAbility():GetLevel()
	if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
		local getXP = hTarget:GetDeathXP()
		getXP = getXP * 0.6
		hCaster:AddExperience(getXP, 1, false, false)
	elseif nLevel >= ABILITY_AWAKEN_2 then
		local getXP = hTarget:GetDeathXP() * 2
		hCaster:AddExperience(getXP, 1, false, false)
	end
end 

modifier_archon_passive_time_particles = {}
function modifier_archon_passive_time_particles:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_time_particles:IsDebuff() return false end
function modifier_archon_passive_time_particles:IsHidden() return true end
function modifier_archon_passive_time_particles:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		local EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
	self:Destroy()
end