-- 普通攻击时有一定的几率对自身攻击范围造成伤害。
-- 被攻击时有一定有一定的几率对自身攻击范围造成伤害。
LinkLuaModifier( "modifier_archon_passive_earth", "ability/archon_passive_earth.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_earth_buff", "ability/archon_passive_earth.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_earth_particles", "ability/archon_passive_earth.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
--Abilities
if archon_passive_earth == nil then
	archon_passive_earth = class({})
end

if modifier_archon_passive_earth_debuff == nil then
	modifier_archon_passive_earth_debuff = class({})
end

function archon_passive_earth:GetIntrinsicModifierName()
 	return "modifier_archon_passive_earth"
end
--------------------------------------------------
if modifier_archon_passive_earth == nil then
	modifier_archon_passive_earth = class({})
end

function modifier_archon_passive_earth:IsHidden()
	return true
end

--------------------------------------------------------------------------------
function modifier_archon_passive_earth:OnCreated()
	self.bonus_maxhealth = 0
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_archon_passive_earth:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end


function modifier_archon_passive_earth:GetModifierPhysicalArmorBonus() return self.bonus_armor end
function modifier_archon_passive_earth:OnAttackLanded( params )
	-- print("modifier_archon_passive_earth OnAttackLanded")
	if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	-- 概率计算
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local hTarget = params.target
	local hAttacker = params.attacker
	local hCaster = self:GetParent()
	local bIsTrigger = false
	local nLevel = self:GetAbility():GetLevel()
	
	-- 被攻击触发
	if hAttacker ~= hCaster and hTarget:HasAbility("archon_passive_earth") and nLevel >= ABILITY_AWAKEN_1 and hTarget == hCaster then
		local nowChance1 = RandomInt(0,100)
		local nChance1 = 25
		local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_vitality", self:GetCaster() )
		if nTalentStack >= 2 then
			nChance1 = nChance1 + 5
		end
		if nowChance1 > nChance1 then
			return 0
		end
		bIsTrigger = true
	end
	-- 攻击触发
	if hAttacker == self:GetParent() and hAttacker:HasAbility("archon_passive_earth") then
		local nowChance2 = RandomInt(0,100)
		local nChance = self:GetAbility():GetSpecialValueFor( "chance" )
		local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_vitality", self:GetCaster() )
		if nTalentStack >= 2 then
			nChance = nChance + 5
		end
		if nowChance2  > nChance then
			return 0
		end
		bIsTrigger = true
	end
	if bIsTrigger == false then return end
	-- 获取自身攻击范围
	local nBowRange = 0
	local nTechRange = 0
	local nBaseRange = self:GetCaster():GetBaseAttackRange()
	local nAllRange = nBaseRange + GetUnitRange(self:GetCaster())
	if nAllRange < 300 then nAllRange = 300 end
	EmitSoundOn( "Hero_Ursa.Earthshock", hCaster )
	SendParticlesToClient("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_magical.vpcf",hCaster)
	-- 创建特效
	-- hCaster:AddNewModifier( hCaster, self:GetAbility(), "modifier_archon_passive_earth_particles", { duration = 1} )
	local abil_damage = self:GetCaster():GetMaxHealth() * self:GetAbility():GetSpecialValueFor( "coefficient" ) * 0.01
	-- 范围
	local enemies = FindUnitsInRadius2(
		hCaster:GetTeamNumber(), 
		hCaster:GetOrigin(), 
		hCaster, 
		nAllRange, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 1, false 
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

	--- 友军触发
	if nLevel >= ABILITY_AWAKEN_2 then
		local hFriendly = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hCaster:GetOrigin(), 
			hCaster, 
			nAllRange, 
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 1, false 
		)
		local nStack = math.floor(self:GetCaster():GetMaxHealth() / 50000)
		for _,hAllies in pairs(hFriendly) do
			if hAllies ~= nil  then
				local hBuff = hTarget:FindModifierByName("modifier_archon_passive_earth_buff")
				if hBuff == nil then
					hBuff = hAllies:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_earth_buff", { duration = 5} )
				end
				local nStackBuff = hBuff:GetStackCount()
				if nStackBuff <= nStack then 
					hBuff:SetStackCount(nStack) 
				end
			end
		end
		hFriendly = nil
	end 
	enemies = nil
end
------------------------------
if modifier_archon_passive_earth_buff == nil then modifier_archon_passive_earth_buff = {} end
function modifier_archon_passive_earth_buff:IsHidden() return false end
function modifier_archon_passive_earth_buff:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

--------------
modifier_archon_passive_earth_particles = {}
function modifier_archon_passive_earth_particles:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_earth_particles:IsHidden() return true end
function modifier_archon_passive_earth_particles:IsDebuff() return false end
function modifier_archon_passive_earth_particles:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		-- 创建效果
		local EffectName_1 = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_magical.vpcf"
		local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hCaster )
		ParticleManager:ReleaseParticleIndex(nFXIndex_1)
	end
	self:Destroy()
end