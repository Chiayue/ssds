LinkLuaModifier( "modifier_archon_passive_light", "ability/archon_passive_light.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_light_effect", "ability/archon_passive_light.lua",LUA_MODIFIER_MOTION_NONE )

local sParticle = "particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf"
-------------------------------------------------
--Abilities
if archon_passive_light == nil then
	archon_passive_light = class({})
end

function archon_passive_light:GetIntrinsicModifierName()
 	return "modifier_archon_passive_light"
end

function archon_passive_light:Precache(context)
	PrecacheResource( "particle", sParticle, context )
end
--------------------------------------------------
if modifier_archon_passive_light == nil then
	modifier_archon_passive_light = class({})
end

-- function modifier_archon_passive_light:GetEffectName()
-- 	return "particles/units/heroes/hero_fairy/fairy_flight_buff.vpcf"
-- end

function modifier_archon_passive_light:GetEffectAttachType()
	return PATTACH_RENDERORIGIN_FOLLOW
end

function modifier_archon_passive_light:IsHidden()
	return true
end


function modifier_archon_passive_light:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_light:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then
		return 0
	end
	-- if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local hCaster = self:GetCaster()
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )

	local bHasTalentLight = hCaster:HasModifier("modifier_series_reward_talent_light_effect")
	-- 套装效果
	if bHasTalentLight == true then
		-- hCaster:RemoveModifierByName("modifier_series_reward_talent_light_effect")
	else 
		local nTalentLight = hCaster:GetModifierStackCount("modifier_series_reward_talent_light", hCaster )
		if nTalentLight >= 2 then
			chance = chance + 5
		end
		if nowChance  > chance then
			return 0
		end
	end
	local hTarget = params.target
	
	local nLevel = self:GetAbility():GetLevel()
	local nBaseDamage = self:GetCaster():GetAgility() + self:GetCaster():GetIntellect()
	
	local nDamageRadius = self:GetAbility():GetSpecialValueFor( "damage_radius" )
	-- 对敌人范围
	EmitSoundOn( "Hero_Omniknight.Purification", hTarget )
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		nDamageRadius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)
	for _,enemy in pairs(enemies) do
		if enemy ~= nil  then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = nBaseDamage * self:GetAbility():GetSpecialValueFor( "coefficient" ),
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage( damage )
		end
	end

	-- 创建效果
	-- local EffectName = "particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf"
	local EffectName = "particles/units/heroes/hero_omniknight/omniknight_loadout.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget)
	-- 新加特效 -- 敌人
	local EffectName_2 = "particles/heroes/thtd_yuugi/ability_yuugi_01.vpcf"
	local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(nDamageRadius, nDamageRadius, nDamageRadius))

	-- 治疗值
	local nHealthAmount = nBaseDamage * self:GetAbility():GetSpecialValueFor( "health_coefficient" )
	EmitSoundOn( "Hero_Dazzle.Shadow_Wave", hCaster )
	-- 觉醒
	local nHealRadius = 0
	if nLevel >= ABILITY_AWAKEN_1 then
		local nHealRadius = self:GetAbility():GetSpecialValueFor( "heal_radius" )
		local allies = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hCaster:GetOrigin(), 
			hCaster, 
			nHealRadius, 
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false 
		)
		for _,ally in pairs(allies) do
			if ally ~= nil then
				ally:Heal(nHealthAmount,hCaster)
				self:HitTarget(hCaster,ally)
				if nLevel >= ABILITY_AWAKEN_2 then
					ally:AddNewModifier(ally, nil, "modifier_archon_passive_light_effect",{ duration = 5 })
				end
			end
		end
	else
		hCaster:Heal(nHealthAmount,hCaster)
	end
end

function modifier_archon_passive_light:HitTarget( hOrigin,hTarget)
	if hTarget == nil then
		return
	end
	local lightningBolt = ParticleManager:CreateParticle(
		sParticle, 
		PATTACH_WORLDORIGIN, 
		hOrigin
	)
	ParticleManager:SetParticleControl(
		lightningBolt,
		0,
		Vector(hOrigin:GetAbsOrigin().x,hOrigin:GetAbsOrigin().y,hOrigin:GetAbsOrigin().z + hOrigin:GetBoundingMaxs().z )
	)   
	ParticleManager:SetParticleControl(
		lightningBolt,
		1,
		Vector(hTarget:GetAbsOrigin().x,hTarget:GetAbsOrigin().y,hTarget:GetAbsOrigin().z + hTarget:GetBoundingMaxs().z )
	)
end

------------ 增伤BUFF ----------------
if modifier_archon_passive_light_effect == nil then modifier_archon_passive_light_effect = {} end
function modifier_archon_passive_light_effect:IsHidden() 
	return false
end
function modifier_archon_passive_light_effect:OnCreated() 
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_archon_passive_light_effect:OnRefresh() 
	if not IsServer() then return end
	if self:GetStackCount() < 20 then
		self:IncrementStackCount()
	else
		self:SetStackCount( 20 )
	end
end

function modifier_archon_passive_light_effect:GetTexture()
	return "archon_passive_light"
end

function modifier_archon_passive_light_effect:DeclareFunctions() return { MODIFIER_PROPERTY_TOOLTIP } end
function modifier_archon_passive_light_effect:OnTooltip() return self:GetStackCount() end