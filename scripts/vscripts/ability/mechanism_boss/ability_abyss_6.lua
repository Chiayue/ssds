-- 过载模式		ability_abyss_6

LinkLuaModifier("modifier_ability_abyss_6", "ability/mechanism_Boss/ability_abyss_6", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_6_damage", "ability/mechanism_Boss/ability_abyss_6", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_6 == nil then 
	ability_abyss_6 = class({})
end

function ability_abyss_6:IsHidden( ... )
	return true
end

function ability_abyss_6:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	if hCaster:GetHealthPercent() > 10 then
		self:EndCooldown()
	-- 当释放者的血量不足10%
	elseif hCaster:GetHealthPercent() <= 10 then
		hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_6", {}) -- duration = 2
	end
end

if modifier_ability_abyss_6 == nil then 
	modifier_ability_abyss_6 = class({})
end

function modifier_ability_abyss_6:IsHidden( ... )
	return true
end

function modifier_ability_abyss_6:OnCreated( kv )
	local hCaster = self:GetCaster()
	
	if IsServer() then 

		self:StartIntervalThink(1)
		self:SetStackCount(2)
	end 
end

function modifier_ability_abyss_6:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数

		if number > 0 then
			local EffectName = "particles/test_particles/xulie/xulie.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)

			-- 设置BUFF在头顶的层数
			self:DecrementStackCount()
		else
			self.nFXIndex_0 = nil

			self:StartIntervalThink(-1)
			self:Destroy()

			hParent:AddNewModifier(hParent, self, "modifier_ability_abyss_6_damage", {}) -- duration = 2
		end
	end
end

-- 自身增加属性BUFF 并在10秒后自爆
if modifier_ability_abyss_6_damage == nil then 
	modifier_ability_abyss_6_damage = class({})
end

function modifier_ability_abyss_6_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_6_damage:OnCreated( ... )
	local hParent = self:GetParent()
	
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(10)
	end 

	local EffectName = "particles/units/heroes/hero_rattletrap/clock_overclock_buff.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
	self:AddParticle(self.nFXIndex_2, false, false, -1, false, true)

	local EffectName = "particles/killstreak/killstreak_ice_topbar_lv2.vpcf"
	self.nFXIndex_3 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
	ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 0, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_1", hParent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 1, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_4", hParent:GetAbsOrigin(), true)
	self:AddParticle(self.nFXIndex_3, false, false, -1, false, true)

end

function modifier_ability_abyss_6_damage:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

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
			self.nFXIndex_2 = nil
			self.nFXIndex_3 = nil

			self:StartIntervalThink(-1)
			self:Destroy()

			if hParent:IsAlive() then 
				self:FindEnemyRangeDamage(hParent)
			end

			hParent:ForceKill(true)
		end
	end
end

function modifier_ability_abyss_6_damage:DeclareFunctions( kv )
	return{
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,		-- 移动速度
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,	-- 百分比攻击
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,	-- 攻速
	}
end

function modifier_ability_abyss_6_damage:GetModifierMoveSpeed_Absolute( kv )
	return 888
end

function modifier_ability_abyss_6_damage:GetModifierDamageOutgoing_Percentage( kv )
	return 100
end

function modifier_ability_abyss_6_damage:GetModifierAttackSpeedBonus_Constant( kv )
	return 100
end

function modifier_ability_abyss_6_damage:FindEnemyRangeDamage( hParent )
	local enemys = FindUnitsInRadius(
				hParent:GetTeamNumber(),
				hParent:GetAbsOrigin(), 
				hParent,
				500, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 0, false)
	for _,enemy in pairs(enemys) do
			ApplyDamage(
				{
					victim = enemy,
					attacker = hParent,
					damage = 500000,
					damage_type = DAMAGE_TYPE_MAGICAL,
				})
	end
end