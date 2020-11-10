LinkLuaModifier( "modifier_archon_passive_natural", "ability/archon_passive_natural.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_natural_debuff", "ability/archon_passive_natural.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_natural == nil then
	archon_passive_natural = class({})
end

function archon_passive_natural:GetIntrinsicModifierName()
 	return "modifier_archon_passive_natural"
end
--------------------------------------------------
if modifier_archon_passive_natural == nil then
	modifier_archon_passive_natural = class({})
end

function modifier_archon_passive_natural:IsHidden()
	return true
end

-- function modifier_archon_passive_natural:GetEffectName()
-- 	return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
-- end

-- function modifier_archon_passive_natural:GetEffectAttachType()
-- 	return PATTACH_OVERHEAD_FOLLOW
-- end

function modifier_archon_passive_natural:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_natural:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then
		return 0
	end
	-- if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_flame", self:GetCaster() )
	local sModifierName = "modifier_archon_passive_natural_debuff"
	if nTalentStack >= 2 then
		chance = chance + 5
	end
	if nowChance  > chance then
		-- 普通攻击
		local abil_damage = self:GetCaster():GetAgility() * self:GetAbility():GetSpecialValueFor( "coefficient" )
		local current_stack = params.target:GetModifierStackCount( sModifierName, self:GetCaster() )
		if current_stack > 0 then
			local total_damage = current_stack * self:GetCaster():GetAgility()
			local damage = {
				victim = params.target,
				attacker = self:GetCaster(),
				damage = total_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}

			ApplyDamage( damage )
		end
		return 0
	end
	local hTarget = params.target
	local nLevel = self:GetAbility():GetLevel()
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local abil_damage = self:GetCaster():GetAgility() * self:GetAbility():GetSpecialValueFor( "coefficient" )
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )

	local EffectName = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_sullen_harvest_ambient_ground_smoke.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	ParticleManager:ReleaseParticleIndex(nFXIndex)
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("DestroyNatural"),
    function()
        ParticleManager:DestroyParticle(nFXIndex, true)
    end,1)

	-- 范围伤害
	EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", hTarget )
	-- print(hTarget:GetModifierStackCount( sModifierName, self:GetAbility() )) 
	local enemies = FindUnitsInRadius2(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 1, false 
	)
	
	for _,enemy in pairs(enemies) do
		if enemy ~= nil then
			local current_stack = enemy:GetModifierStackCount( sModifierName, self:GetCaster() )
			local total_damage = current_stack * self:GetCaster():GetAgility()
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = abil_damage + total_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}

			ApplyDamage( damage )

			if nLevel >= ABILITY_AWAKEN_2 then
				enemy:AddNewModifier( 
					self:GetCaster(), 
					self:GetAbility(), 
					sModifierName, 
					{ duration = duration} 
				)
				enemy:AddNewModifier( 
					self:GetCaster(), 
					self:GetAbility(), 
					sModifierName, 
					{ duration = duration} 
				)
			elseif nLevel >= ABILITY_AWAKEN_1 then
				enemy:AddNewModifier( 
					self:GetCaster(), 
					self:GetAbility(), 
					sModifierName, 
					{ duration = duration} 
				)
			end
	
		end
	end
end

----------------------

if modifier_archon_passive_natural_debuff == nil then
	modifier_archon_passive_natural_debuff = class({})
end

function modifier_archon_passive_natural_debuff:OnCreated()
	self.max_stacks = self:GetAbility():GetSpecialValueFor( "max_stacks" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.damage_type = DAMAGE_TYPE_PHYSICAL
	self:SetStackCount(1)
end

function modifier_archon_passive_natural_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_viper_strike_debuff.vpcf"
end
function modifier_archon_passive_natural_debuff:IsDebuff()
	return true
end
function modifier_archon_passive_natural_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_archon_passive_natural_debuff:OnRefresh()
	if not IsServer() then return end
	local nLevel = self:GetAbility():GetLevel()
	if nLevel >= ABILITY_AWAKEN_2 then 
		if self:GetStackCount() < 99 then
			self:IncrementStackCount()
		end
	else
		if self:GetStackCount() < 10 then
			self:IncrementStackCount()
		end
	end
	self:SetStackCount( self:GetStackCount() )
	self:SetDuration( self.duration, true )
end

function modifier_archon_passive_natural_debuff:IsHidden()
	return ( self:GetStackCount() == 0 )
end






