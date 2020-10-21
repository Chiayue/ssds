LinkLuaModifier( "modifier_archon_passive_ice", "ability/archon_passive_ice.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_ice_effect", "ability/archon_passive_ice.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_ice == nil then
	archon_passive_ice = class({})
end

if modifier_archon_passive_ice_effect == nil then
	modifier_archon_passive_ice_effect = class({})
end

function archon_passive_ice:GetIntrinsicModifierName()
 	return "modifier_archon_passive_ice"
end
--------------------------------------------------
if modifier_archon_passive_ice == nil then
	modifier_archon_passive_ice = class({})
end

function modifier_archon_passive_ice:IsHidden()
	return true
end

function modifier_archon_passive_ice:OnCreated()
	self.slow_duration = self:GetAbility():GetSpecialValueFor("slow_duration")
	-- if IsServer() and self:GetParent() ~= self:GetCaster() then
	-- 	--self:StartIntervalThink( 0.5 )
	-- end
end

function modifier_archon_passive_ice:OnIntervalThink()
	if self:GetCaster() ~= self:GetParent() and self:GetCaster():IsAlive() then
		self:Destroy()
	end
end

function modifier_archon_passive_ice:IsAura()
	return true
end

function modifier_archon_passive_ice:GetAuraRadius()
	return 1200
end

-- function modifier_archon_passive_ice:GetModifierAura()
-- 	return "modifier_archon_passive_ice_effect"
-- end

function modifier_archon_passive_ice:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

-- function modifier_archon_passive_ice:GetAuraSearchTeam()
-- 	return DOTA_UNIT_TARGET_TEAM_ENEMY
-- end


-- function modifier_archon_passive_ice:GetAuraSearchType()
-- 	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
-- end


-- function modifier_archon_passive_ice:GetAuraSearchFlags()
-- 	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
-- end


function modifier_archon_passive_ice:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_ice:GetEffectName()
	return "particles/econ/events/ti10/agh_aura_03.vpcf"
end

function modifier_archon_passive_ice:OnAttackLanded( params )
	-- if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_clod", self:GetCaster() )
	if nTalentStack >= 2 then
		chance = chance + 5
	end
	if nowChance  > chance then
		return 0
	end
	local nLevel = self:GetAbility():GetLevel()
	local hTarget = params.target
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local abil_damage = self:GetCaster():GetIntellect() * self:GetAbility():GetSpecialValueFor( "coefficient" )
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local EffectName = "particles/heroes/humei/ability_humei_011_ice_c.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	-- 新建特效
	local EffectName_1 = "particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf"
	local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))

	if nLevel >= ABILITY_AWAKEN_2 then
		abil_damage = abil_damage + ( self:GetCaster():GetIntellect() * 6 )
	elseif nLevel >= ABILITY_AWAKEN_1 then
		abil_damage = abil_damage + ( self:GetCaster():GetIntellect() * 2 )
	end
	EmitSoundOn( "Hero_Crystal.CrystalNova", hTarget )
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
	for _,enemy in pairs(enemies) do
		if enemy ~= nil then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = abil_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage( damage )
			if nLevel >= ABILITY_AWAKEN_1 then
				enemy:AddNewModifier( 
					self:GetCaster(), 
					self:GetAbility(), 
					"modifier_archon_passive_ice_effect", 
					{ duration = duration} 
				)
			end
		end
	end
	enemies = nil
end

-----------------------------
function modifier_archon_passive_ice_effect:OnCreated()
	self.slow_movespeed = self:GetAbility():GetSpecialValueFor( "debuff_slow_1" )
	-- self.slow_movespeed = 0
	-- self.slow_attackspeed = 0
	-- if not IsServer() then return end
	-- local nLevel = self:GetAbility():GetLevel()
	-- if nLevel >= ABILITY_AWAKEN_2 then
	-- 	self.slow_movespeed = self:GetAbility():GetSpecialValueFor( "debuff_slow_2" )
	-- 	self.slow_attackspeed = self:GetAbility():GetSpecialValueFor( "debuff_slow_2" )
	-- elseif nLevel >= ABILITY_AWAKEN_1 then
		
	-- 	self.slow_attackspeed = self:GetAbility():GetSpecialValueFor( "debuff_slow_1" )
	-- end
end

function modifier_archon_passive_ice_effect:IsDebuff()
	return true
end

function modifier_archon_passive_ice_effect:IsHidden()
	return true
end

function modifier_archon_passive_ice_effect:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_archon_passive_ice_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

-- --------------------------------------------------------------------------------
-- function modifier_archon_passive_ice_effect:GetModifierAttackSpeedBonus_Constant()
-- 	return -self.slow_attackspeed
-- end

function modifier_archon_passive_ice_effect:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow_movespeed 
end

