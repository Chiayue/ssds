-- 普通攻击时有一定的几率对目标范围造成的伤害。 
-- 火焰光环：每2秒对自身攻击范围造成伤害。
LinkLuaModifier( "modifier_archon_passive_fire", "ability/archon_passive_fire.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_fire_debuff", "ability/archon_passive_fire.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
--Abilities
if archon_passive_fire == nil then
	archon_passive_fire = class({})
end

function archon_passive_fire:GetIntrinsicModifierName()
 	return "modifier_archon_passive_fire"
end

-- function archon_passive_fire:Precache(context)
-- 	PrecacheResource( "particle", sParticle, context )
-- end
--------------------------------------------------
if modifier_archon_passive_fire == nil then
	modifier_archon_passive_fire = class({})
end

function modifier_archon_passive_fire:IsHidden()
	return true
end

-- function modifier_archon_passive_fire:GetEffectName()
-- 	return "particles/units/heroes/hero_clinkz/clinkz_burning_army_ground_fire.vpcf"
-- end

function modifier_archon_passive_fire:OnCreated()
	if IsServer() then
		--self:StartIntervalThink(2) 
	end
end

function modifier_archon_passive_fire:OnRefresh()
	if IsServer() then
		-- print("OnRefresh")
		local nLevel = self:GetAbility():GetLevel()
		if nLevel >= ABILITY_AWAKEN_1 then
			local damage_cooldown_1 = self:GetAbility():GetSpecialValueFor( "damage_cooldown_1" )
			self:StartIntervalThink(damage_cooldown_1) 
		elseif nLevel >= ABILITY_AWAKEN_2 then
			local damage_cooldown_2 = self:GetAbility():GetSpecialValueFor( "damage_cooldown_2" )
			self:StartIntervalThink(damage_cooldown_2) 
		end
	end
end

function modifier_archon_passive_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_archon_passive_fire:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_fire:OnAttackLanded( params )
	--print("modifier_archon_passive_fire OnAttackLanded")
	-- if not IsServer() then return end
		if params.target:IsAlive() == false then return end
		local hTarget = params.target
		local hAttacker = params.attacker
		-- 普通攻击时有一定的几率对目标范围造成的伤害。 
		if hAttacker == self:GetParent() and hAttacker:HasAbility("archon_passive_fire") then
			if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
			local bHasTalentLight = hAttacker:HasModifier("modifier_series_reward_talent_light_effect")
			-- 套装效果
			if bHasTalentLight == true then
				-- hAttacker:RemoveModifierByName("modifier_series_reward_talent_light_effect")
			else 
				local nTalentLight = hAttacker:GetModifierStackCount("modifier_series_reward_talent_light", hAttacker )
				local chance = self:GetAbility():GetSpecialValueFor( "chance" )
				if nTalentLight >= 2 then
					chance = chance + 5
				end
				local nowChance = RandomInt(0,100)
				if nowChance  > chance then
					return 0
				end
			end
			local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
			local abil_damage = self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor( "coefficient" )
			-- 觉醒
			local nLevel = self:GetAbility():GetLevel()
			if nLevel >= ABILITY_AWAKEN_2 then
				local nMagicHurt  = math.floor(self:GetCaster():GetStrength() / 2000)
				local hDebuff = hTarget:FindModifierByName("modifier_archon_passive_fire_debuff")
				if hDebuff == nil then
					hDebuff =  hTarget:AddNewModifier(hAttacker, self:GetAbility(), "modifier_archon_passive_fire_debuff", { duration = 5} )
				end
				local nStackDebuff = hDebuff:GetStackCount()
				if nStackDebuff <= nMagicHurt then 
					hDebuff:SetStackCount(nMagicHurt) 
				end
			end
			-- 新增特效
			local EffectName_0 = "particles/heroes/mouko/ability_mokou_01_boom.vpcf"
			local nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_ABSORIGIN_FOLLOW, hTarget )
			ParticleManager:SetParticleControl(nFXIndex_0, 1, Vector(500, 500, 500))
			--------------------------------------------------------------
			EmitSoundOn( "Hero_OgreMagi.Fireblast.Target", hTarget )
			-- 范围
			local enemies = FindUnitsInRadius(
				hAttacker:GetTeamNumber(), 
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
			enemies = nil
		end

		------- 攻击命中
		-- 概率计算
		
	
end

function modifier_archon_passive_fire:OnIntervalThink(params)
	if IsServer() then
		-- 获取自身攻击范围
		-- print("OnIntervalThink")
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
		local hCaster = self:GetParent()
		local abil_damage = self:GetCaster():GetStrength() * self:GetAbility():GetSpecialValueFor( "coefficient" )
		-- 范围
		local impact_effect = "particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast_cast.vpcf"
		
		local enemies = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hCaster:GetOrigin(), 
			hCaster, 
			nAllRange, 
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
				-- local nFXIndex_2 = ParticleManager:CreateParticle( impact_effect, PATTACH_OVERHEAD_FOLLOW, enemy )
				ApplyDamage( damage )
			end
		end
		enemies = nil
	end
end

if modifier_archon_passive_fire_debuff == nil then modifier_archon_passive_fire_debuff = class({}) end
function modifier_archon_passive_fire_debuff:IsHidden() return false end
function modifier_archon_passive_fire_debuff:IsDebuff() return true end
function modifier_archon_passive_fire_debuff:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

