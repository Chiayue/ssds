-- 冰晶穹顶		ability_abyss_5

LinkLuaModifier("modifier_ability_abyss_5", "ability/mechanism_Boss/ability_abyss_5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_5_damage", "ability/mechanism_Boss/ability_abyss_5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_5_avoid_injury", "ability/mechanism_Boss/ability_abyss_5", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_5 == nil then 
	ability_abyss_5 = class({})
end

function ability_abyss_5:IsHidden( ... )
	return true
end

function ability_abyss_5:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_5", {}) -- duration = 2
	hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_5_avoid_injury", {duration = 8})   -- 免伤

end

if modifier_ability_abyss_5_avoid_injury == nil then 
	modifier_ability_abyss_5_avoid_injury = class({})
end

function modifier_ability_abyss_5_avoid_injury:IsHidden()
	return true
end

function modifier_ability_abyss_5_avoid_injury:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_ability_abyss_5_avoid_injury:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_ability_abyss_5_avoid_injury:IsAura()
	return true
end

function modifier_ability_abyss_5_avoid_injury:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_ability_abyss_5_avoid_injury:GetModifierAura()
	return "modifier_ability_abyss_5_damage"
end

function modifier_ability_abyss_5_avoid_injury:GetAuraRadius()
	return 1000
end

function modifier_ability_abyss_5_avoid_injury:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_ability_abyss_5_avoid_injury:OnCreated( ... )
	hParent = self:GetParent()

	local EffectName_0 = "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf"
	self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_RENDERORIGIN_FOLLOW, hParent)
	ParticleManager:SetParticleControl(self.nFXIndex_0, 1, hParent:GetAbsOrigin())  -- Vector(0, number, 0)
	ParticleManager:SetParticleControl(self.nFXIndex_0, 2, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_0, 4, hParent:GetAbsOrigin())
	self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)
end

-- 所有的玩家  免伤效果
if modifier_ability_abyss_5_damage == nil then 
	modifier_ability_abyss_5_damage = class({})
end

function modifier_ability_abyss_5_damage:IsHidden()
	return true
end

function modifier_ability_abyss_5_damage:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_5_damage:GetModifierIncomingDamage_Percentage( ... )
	return -100
end

-- 读条效果
if modifier_ability_abyss_5 == nil then 
	modifier_ability_abyss_5 = class({})
end

function modifier_ability_abyss_5:IsHidden( ... )
	return true
end

function modifier_ability_abyss_5:OnCreated( kv )
	local hCaster = self:GetCaster()
	
	if IsServer() then 

		self:StartIntervalThink(1)
		self:SetStackCount(8)
	end 
end

function modifier_ability_abyss_5:OnIntervalThink( kv )
	if IsServer() then 
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数

		if number > 0 then
			local EffectName = "particles/test_particles/xulie/xulie.vpcf"
			self.nFXIndex_1 = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_1, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_1, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )
			self:AddParticle(self.nFXIndex_1, false, false, -1, false, true)

			 -- 设置BUFF在头顶的层数
			self:DecrementStackCount()
		else
			self.nFXIndex_1 = nil

			self:StartIntervalThink(-1)
			self:Destroy()

			if hCaster:IsAlive() then 
				self:FindEnemyRangeDamage(hParent)
			end
		end
	end
end

function modifier_ability_abyss_5:FindEnemyRangeDamage(hParent)

 	local EffectName = "particles/units/heroes/hero_oracle/oracle_false_promise_dmg.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent)
	ParticleManager:SetParticleControl(self.nFXIndex_2, 1, hParent:GetAbsOrigin())  -- Vector(0, number, 0)
	ParticleManager:SetParticleControl(self.nFXIndex_2, 2, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_2, 4, hParent:GetAbsOrigin())
	self:AddParticle(self.nFXIndex_2, false, false, -1, false, true)

 	-- 敌人
	local enemys = FindUnitsInRadius(
		hParent:GetTeamNumber(), 
		hParent:GetAbsOrigin(), 
		hParent, 
		300, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false)

	for _, enemy in pairs(enemys) do
		ApplyDamage({
				victim = enemy,
				attacker = hParent,
				damage = enemy:GetMaxHealth() * 0.6,
				damage_type = DAMAGE_TYPE_MAGICAL,
			})

	end
end