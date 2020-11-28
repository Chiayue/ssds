LinkLuaModifier( "modifier_archon_passive_natural", "ability/archon_passive_natural.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_natural_debuff", "ability/archon_passive_natural.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_natural_particles", "ability/archon_passive_natural.lua",LUA_MODIFIER_MOTION_NONE )

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
		local nCurrentStack = 0
		local hModifierInfo = params.target:FindAbilityByName(sModifierName)
		if hModifierInfo ~= nil then
			nCurrentStack = hModifierInfo:GetStackCount()
		end
		local abil_damage = self:GetCaster():GetAgility() * self:GetAbility():GetSpecialValueFor( "coefficient" )
		--local current_stack = params.target:GetModifierStackCount( sModifierName, self:GetCaster() )
		if nCurrentStack > 0 then
			local total_damage = nCurrentStack * self:GetCaster():GetAgility()
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
	-- 范围伤害
	EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", hTarget )
	local EffectName = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_sullen_harvest_ambient_ground_smoke.vpcf"
	local EffectName_1 = "particles/econ/items/monkey_king/arcana/death/monkey_king_spring_arcana_death.vpcf"
	SendParticlesToClient(EffectName,hTarget)
	SendParticlesToClient(EffectName_1,hTarget)
	-- hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_archon_passive_natural_particles", { duration = 1} )
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
			local nCurrentStack = 0
			local hModifierInfo = enemy:FindAbilityByName(sModifierName)
			if hModifierInfo ~= nil then
				nCurrentStack = hModifierInfo:GetStackCount()
			end
			-- local current_stack = enemy:GetModifierStackCount( sModifierName, self:GetCaster() )
			local total_damage = nCurrentStack * self:GetCaster():GetAgility()
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = abil_damage + total_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}

			ApplyDamage( damage )

			if nLevel >= ABILITY_AWAKEN_2 then
				for i=1,4 do
					enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), sModifierName, { duration = duration} )
				end
			elseif nLevel >= ABILITY_AWAKEN_1 then
				for i=1,2 do
					enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), sModifierName, { duration = duration} )
				end
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
		if self:GetStackCount() < 49 then
			self:IncrementStackCount()
		end
	end
	self:SetStackCount( self:GetStackCount() )
	self:SetDuration( self.duration, true )
end

function modifier_archon_passive_natural_debuff:IsHidden()
	return ( self:GetStackCount() == 0 )
end

---------------------------------------------------------------------------------------
modifier_archon_passive_natural_particles = {}
function modifier_archon_passive_natural_particles:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_natural_particles:IsDebuff() return false end
function modifier_archon_passive_natural_particles:IsHidden() return true end
function modifier_archon_passive_natural_particles:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		local EffectName = "particles/econ/items/necrolyte/necro_sullen_harvest/necro_sullen_harvest_ambient_ground_smoke.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget )
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
	self:Destroy()
end




