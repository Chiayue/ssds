-- 灵魂连接   ability_abyss_3

LinkLuaModifier("modifier_ability_abyss_3", "ability/mechanism_Boss/ability_abyss_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_3_deth", "ability/mechanism_Boss/ability_abyss_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_3_Reduction_of_injury", "ability/mechanism_Boss/ability_abyss_3", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_3 == nil then 
	ability_abyss_3 = class({})
end

function ability_abyss_3:IsHidden( ... )
	return true
end

function ability_abyss_3:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	local player_nuber = 0
	if hCaster:GetHealthPercent() > 80 then
		self:EndCooldown()
	-- 当释放者的血量不足80%
	elseif hCaster:GetHealthPercent() <= 80 then 
		-- 寻找自身1000范围的敌人
		local enemys = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hCaster:GetAbsOrigin(), 
			hCaster, 
			99999, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false)

		if #enemys <= 1 then
			player_nuber = 1
		else
			player_nuber = (#enemys/2)
		end

		for i, enemy in pairs(enemys) do
			-- 半数以上的敌人加上DEBUFF
			if i <= player_nuber then 
				enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_3", {})
				hCaster.index_modifier_ability_abyss_3 = enemy 		-- 保存那个实体添加的modifier 
			end
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
		}
end

function modifier_ability_abyss_3_deth:OnDeath( ... )
	if IsServer() then 
		local hParent = self:GetParent()
		local hCaster = self:GetCaster()
		if hParent:IsAlive() then return end 
		local hParent_modifier_ability_abyss_3 = hParent.index_modifier_ability_abyss_3		-- 得到拥有这个modified的实体
		if hParent_modifier_ability_abyss_3 == nil then return end
		if hParent_modifier_ability_abyss_3:HasModifier("modifier_ability_abyss_3") then
			hParent_modifier_ability_abyss_3:RemoveModifierByName("modifier_ability_abyss_3")
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
	-- ParticleManager:SetParticleControl(iParticleID, 2, Vector(speed, 1, 1))
	-- ParticleManager:SetParticleControl(iParticleID, 3, Vector(time, 1, 1))
	self:AddParticle(self.iParticleID, false, false, -1, false, false)

	if IsServer() then 
		self:StartIntervalThink(1)
	end
end

function modifier_ability_abyss_3:OnIntervalThink( ... )
	if IsServer() then 	
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()
		--local hparent_range = hParent:Script_GetAttackRange() + 500
		--print("hparent_range>>>>>>>>>>>>>=",hparent_range)
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