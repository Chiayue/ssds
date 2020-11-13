LinkLuaModifier( "modifier_archon_passive_dark", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_dark_debuff", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_dark_debuff2", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_dark_particles", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
local nDarkFXIndex = nil

--Abilities
if archon_passive_dark == nil then
	archon_passive_dark = class({})
end

if modifier_archon_passive_dark_debuff == nil then
	modifier_archon_passive_dark_debuff = class({})
end

function archon_passive_dark:GetIntrinsicModifierName()
 	return "modifier_archon_passive_dark"
end
--------------------------------------------------
if modifier_archon_passive_dark == nil then
	modifier_archon_passive_dark = class({})
end

function modifier_archon_passive_dark:IsHidden()
	return true
end

-- function modifier_archon_passive_dark:GetEffectName()
-- 	return "particles/units/heroes/hero_void_spirit/void_spirit_warp_dust_dark.vpcf"
-- end

function modifier_archon_passive_dark:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_dark:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then return end
	-- if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	
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
	local hCaster = self:GetCaster()
	local hTarget = params.target
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	-- 创建特效
	-- hTarget:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_archon_passive_dark_particles", { duration = 1} )
	EmitSoundOn( "Hero_Nevermore.Shadowraze", hTarget )
	SendParticlesToClient("particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf",hTarget)
	
	local abil_damage = self:GetCaster():GetStrength() + self:GetCaster():GetAgility() + self:GetCaster():GetIntellect()
	abil_damage = abil_damage * self:GetAbility():GetSpecialValueFor( "coefficient" )
	-- print("before:",abil_damage)
	-- 范围伤害
	local enemies = FindUnitsInRadius2(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 1, false 
	)
	local nLevel = self:GetAbility():GetLevel()
	-- L5觉醒
	if nLevel >= ABILITY_AWAKEN_2 then
		local nHurtStack  = math.floor(self:GetCaster():GetAgility() / 2000)
		local hDebuff = hTarget:FindModifierByName("modifier_archon_passive_dark_debuff2")
		if hDebuff == nil then
			hDebuff =  hTarget:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_archon_passive_dark_debuff2", { duration = 5} )
		end
		local nStackDebuff = hDebuff:GetStackCount()
		if nStackDebuff <= nHurtStack then 
			hDebuff:SetStackCount(nHurtStack) 
		end
	end
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
					"modifier_archon_passive_dark_debuff", 
					{ duration = duration} 
				)
			end


			
		end
	end
	enemies = nil
end

--------------------------------------------------------------------------------

function modifier_archon_passive_dark_debuff:IsDebuff()
	return true
end

function modifier_archon_passive_dark_debuff:OnCreated()
	local nLevel = self:GetAbility():GetLevel()
	if nLevel >= 5 then
		self.miss_rate = self:GetAbility():GetSpecialValueFor( "debuff_miss_2" )
	else
		self.miss_rate = self:GetAbility():GetSpecialValueFor( "debuff_miss_1" )
	end
	
end

function modifier_archon_passive_dark_debuff:OnRefresh()
	local nLevel = self:GetAbility():GetLevel()
	if nLevel >= 5 then
		self.miss_rate = self:GetAbility():GetSpecialValueFor( "debuff_miss_2" )
	else
		self.miss_rate = self:GetAbility():GetSpecialValueFor( "debuff_miss_1" )
	end
end

function modifier_archon_passive_dark_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
end

function modifier_archon_passive_dark_debuff:GetModifierMiss_Percentage()
	return self.miss_rate
end

----------------------------
if modifier_archon_passive_dark_debuff2 == nil then modifier_archon_passive_dark_debuff2 = class({}) end
function modifier_archon_passive_dark_debuff2:IsHidden() return false end
function modifier_archon_passive_dark_debuff2:IsDebuff() return true end
function modifier_archon_passive_dark_debuff2:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

--------------
modifier_archon_passive_dark_particles = {}
function modifier_archon_passive_dark_particles:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_dark_particles:IsDebuff() return false end
function modifier_archon_passive_dark_particles:IsHidden() return true end
function modifier_archon_passive_dark_particles:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		local EffectName = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
		local nFXIndex  = ParticleManager:CreateParticle( EffectName, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(nFXIndex, 0, hTarget:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
	self:Destroy()
end
