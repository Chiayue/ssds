LinkLuaModifier( "modifier_archon_passive_magic", "ability/archon_passive_magic.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_magic_particles", "ability/archon_passive_magic.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_magic_particles2", "ability/archon_passive_magic.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_magic == nil then
	archon_passive_magic = class({})
end

function archon_passive_magic:GetIntrinsicModifierName()
 	return "modifier_archon_passive_magic"
end
--------------------------------------------------
if modifier_archon_passive_magic == nil then
	modifier_archon_passive_magic = class({})
end


function modifier_archon_passive_magic:IsHidden()
	return true
end

function modifier_archon_passive_magic:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

-- 魔力爆发
-- 魔力之箭
function modifier_archon_passive_magic:OnAttack( params )
	if params.attacker ~= self:GetParent() then return 0 end
	if params.target == nil then return end
	if params.target:IsAlive() == false then return end
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local hCaster = self:GetCaster()
	local mana = hCaster:GetMana()
	local mana_percent = hCaster:GetManaPercent()
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local hTarget = params.target
	if 	mana_percent > 98 then
		hCaster:SpendMana(mana,self:GetAbility())
		local nLevel = self:GetAbility():GetLevel()
		if nLevel < ABILITY_AWAKEN_1 then return end
		-- 魔力爆发
		EmitSoundOn( "Hero_Invoker.EMP.Discharge", hCaster )
		local EffectName = "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf"
		SendParticlesToClient(EffectName,hCaster)
		local abil_damage = hCaster:GetIntellect() * self:GetAbility():GetSpecialValueFor( "full_damage" )
		local enemies = FindUnitsInRadius2(
			hCaster:GetTeamNumber(), 
			hTarget:GetOrigin(), 
			hTarget, 
			aoe, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 1, false 
		)
		
		for _,enemy in pairs(enemies) do
			if enemy ~= nil  then
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

	if mana_percent < 98 then
		-- 魔力之箭
		local add_mana = hCaster:GetAgility() * self:GetAbility():GetSpecialValueFor( "recovery_ratio" )
		add_mana = add_mana + (0.01 * hCaster:GetMaxMana() * (hCaster:GetAgility() / hCaster:GetIntellect()))
		hCaster:GiveMana(add_mana)
		local nowChance = RandomInt(0,100)
		local chance = self:GetAbility():GetSpecialValueFor( "chance" )
		local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_vitality", self:GetCaster() )
		if nTalentStack >= 2 then
			chance = chance + 5
		end
		if nowChance  < chance then
			local abil_damage = hCaster:GetIntellect() * self:GetAbility():GetSpecialValueFor( "notfull_damage" ) * mana_percent * 0.01
			EmitSoundOn( "Hero_EarthShaker.Fissure", hTarget )
			
			local EffectName = "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf"
			SendParticlesToClient(EffectName,hTarget)
			-- 范围
			local enemies = FindUnitsInRadius2(
				hCaster:GetTeamNumber(), 
				hTarget:GetOrigin(), 
				hTarget, 
				aoe, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 1, false 
			)

			for _,enemy in pairs(enemies) do
				if enemy ~= nil  then
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
	end
end
---------------------------------------------------------------------------------------
modifier_archon_passive_magic_particles = {}
function modifier_archon_passive_magic_particles:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_magic_particles:IsDebuff() return false end
function modifier_archon_passive_magic_particles:IsHidden() return true end
function modifier_archon_passive_magic_particles:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		local EffectName = "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_POINT, hCaster )
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
	self:Destroy()
end
---------------------------------------------------------------------------------------
modifier_archon_passive_magic_particles2 = {}
function modifier_archon_passive_magic_particles2:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_magic_particles2:IsDebuff() return false end
function modifier_archon_passive_magic_particles2:IsHidden() return true end
function modifier_archon_passive_magic_particles2:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		local EffectName = "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_POINT, hTarget )
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
	self:Destroy()
end