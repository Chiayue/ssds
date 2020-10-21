LinkLuaModifier( "modifier_archon_passive_magic", "ability/archon_passive_magic.lua",LUA_MODIFIER_MOTION_NONE )
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
	-- if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	if params.target == nil then return end
	if params.target:IsAlive() == false then return end
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local hCaster = self:GetCaster()
	local mana = hCaster:GetMana()
	local mana_percent = hCaster:GetManaPercent()
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	if mana_percent < 99 then
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
			local hTarget = params.target
			local abil_damage = hCaster:GetIntellect() * self:GetAbility():GetSpecialValueFor( "notfull_damage" ) * mana_percent * 0.01
			local EffectName = "particles/units/heroes/hero_wisp/wisp_guardian_explosion.vpcf"
			local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_POINT, hTarget )
			ParticleManager:SetParticleControl(nFXIndex, 1, Vector(500, 500, 500))

			local EffectName_1 = "particles/heroes/lily/ability_lily_01.vpcf"
			local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_POINT, hTarget )
			ParticleManager:SetParticleControl(nFXIndex_1, 1, Vector(500, 500, 500))
			EmitSoundOn( "Hero_EarthShaker.Fissure", hTarget )
			
			-- 范围
			local enemies = FindUnitsInRadius(
				hCaster:GetTeamNumber(), 
				hTarget:GetOrigin(), 
				hTarget, 
				aoe, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 0, false 
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
	else
		
		hCaster:SpendMana(mana,self:GetAbility())
		local nLevel = self:GetAbility():GetLevel()
		if nLevel < ABILITY_AWAKEN_1 then return end
		-- 魔力爆发
		-- 获取自身攻击范围
		local nBowRange = 0
		local nTechRange = 0
		local nBaseRange = self:GetCaster():GetBaseAttackRange()
		local hBow = self:GetCaster():FindModifierByName("modifier_item_archer_bow")
		if hBow ~= nil then
			nBowRange = hBow:GetModifierAttackRangeBonus()
		end
		local hTeahRange = self:GetCaster():FindModifierByName("modifier_Upgrade_Range")
		if hTeahRange ~= nil then
			nTechRange = hTeahRange:GetModifierAttackRangeBonus()
		end
		local nAllRange = nBaseRange + nBowRange + nTechRange
		--
		local abil_damage = hCaster:GetIntellect() * self:GetAbility():GetSpecialValueFor( "full_damage" )
		local EffectName = "particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_POINT, hCaster )
		ParticleManager:SetParticleControl(nFXIndex, 1, Vector(nAllRange, nAllRange, nAllRange))

		-- 范围
		local enemies = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hCaster:GetOrigin(), 
			hCaster, 
			nAllRange, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false 
		)
		EmitSoundOn( "Hero_Invoker.EMP.Discharge", hCaster )
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
