LinkLuaModifier( "modifier_archon_passive_dark", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_dark_debuff", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_dark_debuff2", "ability/archon_passive_dark.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
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
	
	local hTarget = params.target
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	-- 创建效果
	local EffectName = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(400, 400, 400))
	-- 新建特效
	local EffectName_1 = "particles/econ/items/bristleback/bristle_spikey_spray/bristle_spikey_quill_spray.vpcf"
	local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_RENDERORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))

	local EffectName_2 = "particles/heroes/thtd_junko/ability_junko_03.vpcf"
	local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ABSORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(500, 500, 500))

	local abil_damage = self:GetCaster():GetStrength() + self:GetCaster():GetAgility() + self:GetCaster():GetIntellect()
	abil_damage = abil_damage * self:GetAbility():GetSpecialValueFor( "coefficient" )
	-- print("before:",abil_damage)
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

	EmitSoundOn( "Hero_Nevermore.Shadowraze", hTarget )
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
