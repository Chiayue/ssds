LinkLuaModifier( "modifier_archon_passive_soul", "ability/archon_passive_soul.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_soul_particles", "ability/archon_passive_soul.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_soul == nil then
	archon_passive_soul = class({})
end

function archon_passive_soul:GetIntrinsicModifierName()
 	return "modifier_archon_passive_soul"
end
--------------------------------------------------
if modifier_archon_passive_soul == nil then
	modifier_archon_passive_soul = class({})
end

function modifier_archon_passive_soul:IsHidden()
	return false
end

function modifier_archon_passive_soul:OnCreated()
	--if IsServer() then -- and self:GetParent() ~= self:GetCaster()
		local hCaster = self:GetCaster()
		self.present_kills = 0
		self.kills = 0

		local EffectName = "particles/units/heroes/hero_nevermore/nevermore_trail.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hCaster )
	--end
end

function modifier_archon_passive_soul:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_soul:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

function modifier_archon_passive_soul:GetTexture(  )
    return "linghun"
end

function modifier_archon_passive_soul:OnDeath(args)
	--if not IsServer() then return end
    local hAttacker = args.attacker
	local hCaster = self:GetParent()
	local nLevel = self:GetAbility():GetLevel()
	if hAttacker ~= hCaster then
		return
	end
	if args.unit:GetUnitName() == "create_operate_challenge_monster" then return end
	self.present_kills = self.present_kills + 1 -- 当前击杀数
    self.kills = self.kills + 1
    if nLevel >= ABILITY_AWAKEN_1 then 
		self.kills = self.kills + 1
	end
	--DeepPrintTable(args)

	if args.unit:GetContext("boss") then
		self.kills = self.kills + 20 
	end
	
	--print("kills=======================>", self.kills)
    hCaster:SetModifierStackCount( "modifier_archon_passive_soul", hCaster, self.kills )
end

function modifier_archon_passive_soul:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local hCaster = self:GetCaster()
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local damage_coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
	local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_ruin", self:GetCaster() )
	if nTalentStack >= 2 then
		chance = chance + 5
	end
	if nowChance  > chance then
		return 0
	end

	local hTarget = params.target
	local nLevel = self:GetAbility():GetLevel()
	--print("nLevel>>>>>>=",nLevel)
	
	-- 新建特效
	local EffectName_1 = "particles/down_particles/red/down_particles_red.vpcf"
	local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))
	ParticleManager:SetParticleControl(nFXIndex_1, 1, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(nFXIndex_1, 2, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(nFXIndex_1, 3, hTarget:GetAbsOrigin())
	ParticleManager:SetParticleControl(nFXIndex_1, 4, hTarget:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(nFXIndex_1)
	EmitSoundOn( "Hero_Nevermore.Shadowraze", hTarget )
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

	local abil_damage = self:GetParent():GetModifierStackCount("modifier_archon_passive_soul", nil) -- 灵魂数
	--print("abil_damage===========>>>>>>>>>>>>>>>>", abil_damage)
	for _,enemy in pairs(enemies) do
		if enemy ~= nil then
			if nLevel >= ABILITY_AWAKEN_2 then
				local all_damage_5 = abil_damage * abil_damage  * 0.2 * damage_coefficient
				--print("all_damage_5>>>>>>=+++++++++++++++++++++++++======================",all_damage_5)
				ApplyDamage({
					victim = enemy,
					attacker = self:GetCaster(),
					damage = all_damage_5,
					damage_type = self:GetAbility():GetAbilityDamageType(),
				})
			else
				local all_damage_1 = abil_damage * self.present_kills * 0.5 * damage_coefficient
				--print("all_damage_1>>>>>>=+++++++++++++++++++++++++======================",all_damage_1)
				ApplyDamage({
					victim = enemy,
					attacker = self:GetCaster(),
					damage = all_damage_1,
					damage_type = self:GetAbility():GetAbilityDamageType(),
				})
			end
		end
	end
end

function modifier_archon_passive_soul:OnTooltip()
	if IsValidEntity(self:GetCaster()) then
		return self:GetParent():GetModifierStackCount("modifier_archon_passive_soul", nil)
	end
	return 0
end