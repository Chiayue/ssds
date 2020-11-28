-- 灵魂连接   ability_abyss_3

LinkLuaModifier("modifier_ability_abyss_3", "ability/mechanism_Boss/ability_abyss_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_3_deth", "ability/mechanism_Boss/ability_abyss_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_3_Reduction_of_injury", "ability/mechanism_Boss/ability_abyss_3", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_3 == nil then 
	ability_abyss_3 = class({})
end
index_naber = {}
function ability_abyss_3:IsHidden( ... )
	return true
end

function ability_abyss_3:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	local linkNuber = 0
	-- 寻找自身所有的敌人
	local enemys = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hCaster:GetAbsOrigin(), 
		hCaster, 
		99999, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false)
	if index_naber ~= nil then 
		for _, unity_enemy in pairs(index_naber) do
			if unity_enemy:HasModifier("modifier_ability_abyss_3") then
				unity_enemy:RemoveModifierByName("modifier_ability_abyss_3")
				index_naber = {}
			end
		end
	end
	
	linkNuber = #enemys/2
	if linkNuber <= 1 then
		linkNuber = 1
	end
	for i = 1, linkNuber do 
		local x = RandomInt(1, #enemys)
		-- 半数以上的敌人加上DEBUFF 
		if enemys[x] ~= nil then 
			enemys[x]:AddNewModifier(hCaster, self, "modifier_ability_abyss_3", {})
			table.insert(index_naber, enemys[x])
			table.remove(enemys, x)
		end
	end
end

function ability_abyss_3:GetIntrinsicModifierName()
 	return "modifier_ability_abyss_3_deth"
end

if modifier_ability_abyss_3_deth == nil then 
	modifier_ability_abyss_3_deth = class({})
end

function modifier_ability_abyss_3_deth:IsHidden( ... )
	return true
end

function modifier_ability_abyss_3_deth:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_DEATH,
			MODIFIER_EVENT_ON_ATTACK_LANDED,
		}
end

function modifier_ability_abyss_3_deth:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()

	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	if not attacker:HasModifier("modifier_ability_abyss_3") then 
		hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_3_Reduction_of_injury", {duration = 1})
	end
end

function modifier_ability_abyss_3_deth:OnDeath( kys ) 
	local hParent = self:GetParent()
	if hParent:IsAlive() then return end 
	for _,  index in pairs(index_naber) do
		-- local hParent_modifier_ability_abyss_3 = index		-- 得到拥有这个modified的实体
		--if index == nil or index:IsAlive() then return end
		if index:HasModifier("modifier_ability_abyss_3") then
			index:RemoveModifierByName("modifier_ability_abyss_3")
			index_naber = {}
		end
	end
end

if modifier_ability_abyss_3 == nil then
	modifier_ability_abyss_3 = class({})
end

function modifier_ability_abyss_3:IsHidden( ... )
	return false
end

function modifier_ability_abyss_3:IsDebuff( ... )
	return true
end

function modifier_ability_abyss_3:OnCreated( ... )
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()

	-- 灵魂连接特效
	local EffectName_0 = "particles/econ/items/razor/razor_punctured_crest_golden/razor_static_link_blade_golden.vpcf"
	self.iParticleID = ParticleManager:CreateParticle(EffectName_0, PATTACH_ROOTBONE_FOLLOW, hParent)
	ParticleManager:SetParticleControlEnt(self.iParticleID, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), false)
	ParticleManager:SetParticleControlEnt(self.iParticleID, 1, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), false)
	self:AddParticle(self.iParticleID, false, false, -1, false, false)

	if IsServer() then 
		self:StartIntervalThink(1)
	end
end

function modifier_ability_abyss_3:OnDestroy( ... )
	ParticleManager:DestroyParticle( self.iParticleID, false )
	ParticleManager:ReleaseParticleIndex( self.iParticleID )
	self.iParticleID = nil
end

function modifier_ability_abyss_3:OnIntervalThink( ... )
	if IsServer() then 	
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()

		local enemys = FindUnitsInRadius(
			hParent:GetTeamNumber(), 
			hParent:GetAbsOrigin(), 
			hParent, 
			hParent:Script_GetAttackRange() + 500, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false)

		for _, enemy  in pairs(enemys) do
			if not enemy:HasModifier("modifier_ability_abyss_3") and enemy ~= hCaster then
				enemy:AddNewModifier(hCaster, self:GetAbility(), "modifier_ability_abyss_3_Reduction_of_injury", {duration = 1})
			end

		end
	end
end

if modifier_ability_abyss_3_Reduction_of_injury == nil then
	modifier_ability_abyss_3_Reduction_of_injury = class({})
end

function modifier_ability_abyss_3_Reduction_of_injury:IsHidden( ... )
	return true
end


function modifier_ability_abyss_3_Reduction_of_injury:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_3_Reduction_of_injury:GetModifierIncomingDamage_Percentage( ... )
	return -100
end