LinkLuaModifier( "modifier_archon_passive_puncture", "ability/archon_passive_puncture.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_puncture_bonus", "ability/archon_passive_puncture.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_puncture == nil then
	archon_passive_puncture = class({})
end

function archon_passive_puncture:GetIntrinsicModifierName()
 	return "modifier_archon_passive_puncture"
end
--------------------------------------------------
if modifier_archon_passive_puncture == nil then
	modifier_archon_passive_puncture = class({})
end


function modifier_archon_passive_puncture:IsHidden()
	return true
end

function modifier_archon_passive_puncture:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK ,
	}
	return funcs
end

function modifier_archon_passive_puncture:OnAttack(params)
	if params.attacker ~= self:GetParent() then
		return 0
	end
	-- if not IsServer() then return end
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_ruin", self:GetCaster() )
	if nTalentStack >= 2 then
		chance = chance + 5
	end
	if nowChance  > chance then
		return 0
	end
	-- 获取自身攻击范围
	local nBowRange = 0
	local nTechRange = 0
	local nBaseRange = self:GetCaster():GetBaseAttackRange() + 500
	local hBow = self:GetCaster():FindModifierByName("modifier_item_archer_bow")
	if hBow ~= nil then
		nBowRange = hBow:GetModifierAttackRangeBonus()
	end
	local hTeahRange = self:GetCaster():FindModifierByName("modifier_Upgrade_Range")
	if hTeahRange ~= nil then
		nTechRange = hTeahRange:GetModifierAttackRangeBonus()
	end
	local nAllRange = nBaseRange + nBowRange + nTechRange
	--self.puncture_distance = self:GetAbility():GetSpecialValueFor( "puncture_distance" )
	self.puncture_distance = nAllRange
	self.puncture_speed = self:GetAbility():GetSpecialValueFor( "puncture_speed" )
	self.puncture_width_initial = self:GetAbility():GetSpecialValueFor( "puncture_width_initial" )
	self.puncture_width_end = self:GetAbility():GetSpecialValueFor( "puncture_width_end" )
	-- self:GetAbility().nHitCount = 0
	local nLevel = self:GetAbility():GetLevel()
	local BaseAttackRange = self:GetCaster():GetBaseAttackRange()
	local hTarget = params.target 
	local vPos = hTarget:GetOrigin()
	EmitSoundOn( "Ability.Powershot.Alt", self:GetCaster() )
	self:CreateLinear(vPos)
	if nLevel >= ABILITY_AWAKEN_2 then
		Timer(0.1,function()
			self:CreateLinear(vPos)
		end)
		Timer(0.2,function()
			self:CreateLinear(vPos)
		end)
	elseif nLevel >= ABILITY_AWAKEN_1 then
		Timer(0.1,function()
			self:CreateLinear(vPos)
		end)
	end
end

function modifier_archon_passive_puncture:CreateLinear(vPos)
	local vDirection = vPos - self:GetCaster():GetOrigin()
	vDirection = vDirection:Normalized()
	local EffectName = "particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_ti6.vpcf"
	local modelName = self:GetCaster():GetModelName()
	if modelName == "models/npc/reisen/reisen.vmdl" then
		EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot_reisen.vpcf"
	end
	local info = {
		EffectName = EffectName,
		Ability = self:GetAbility(),
		vSpawnOrigin = self:GetCaster():GetOrigin(), 
		fStartRadius = self.puncture_width_initial,
		fEndRadius = self.puncture_width_end,
		vVelocity = vDirection * self.puncture_speed,
		fDistance = self.puncture_distance,
		Source = self:GetCaster(),
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	}
	ProjectileManager:CreateLinearProjectile( info )

end
function archon_passive_puncture:OnProjectileHit( hTarget, vLocation )
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		-- self.nHitCount = self.nHitCount + 1
		local attack_damage = self:GetCaster():GetAttackDamage() * self:GetSpecialValueFor( "coefficient" )
		local nAttackDamage = self:GetCaster():GetAverageTrueAttackDamage(hTarget) * self:GetSpecialValueFor( "coefficient" )
		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = nAttackDamage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		ApplyDamage( damage )

		-- 觉醒伤害
		local nLevel = self:GetLevel()
		if nLevel >= ABILITY_AWAKEN_2 then
			local damage = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = nAttackDamage * 0.1,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self
			}
			ApplyDamage( damage )
		end
	end
	return false
end

if modifier_archon_passive_puncture_bonus == nil then
	modifier_archon_passive_puncture_bonus = {}
end
function modifier_archon_passive_puncture_bonus:IsHidden() 
	return false
end

function modifier_archon_passive_puncture_bonus:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(0.2)
	end
end

function modifier_archon_passive_puncture_bonus:OnRefresh()
	if IsServer() then
		self:IncrementStackCount()
		self:SetDuration( 1, true )
	end
end

function modifier_archon_passive_puncture_bonus:OnIntervalThink()
	if IsServer() then
		local nStacks = self:GetStackCount()
		if nStacks > 0 then
			self:SetStackCount(nStacks - 1)
			local vPos = self:GetAbility().vPos
			print("CreateLinear")
			modifier_archon_passive_puncture:CreateLinear(vPos)
		end
		if nStacks == 1 then
			self:Destroy()
		end
	end
end