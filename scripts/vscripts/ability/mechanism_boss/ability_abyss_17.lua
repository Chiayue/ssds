-- 点名		ability_abyss_17

LinkLuaModifier("modifier_ability_abyss_17", "ability/mechanism_Boss/ability_abyss_17", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_17_damage", "ability/mechanism_Boss/ability_abyss_17", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_17 == nil then
	ability_abyss_17 = class({})
end

function ability_abyss_17:IsHidden( ... )
	return true
end

function ability_abyss_17:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	local enemys = FindUnitsInRadius(
				hCaster:GetTeamNumber(),
				hCaster:GetAbsOrigin(), 
				hCaster,
				99999, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 0, false)
	for _,enemy in pairs(enemys) do
		if #enemy <= 1 then 
			Unity_Name = hCaster
			enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_17", {}) -- duration = 2
		end
	end
end

if modifier_ability_abyss_17 == nil then 
	modifier_ability_abyss_17 = class({})
end

function modifier_ability_abyss_17:IsHidden( ... )
	return true
end

function modifier_ability_abyss_17:OnCreated( kv )
	local hParent = self:GetParent()
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(2)
	end 
end

function modifier_ability_abyss_17:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数

		if number > 0 then
		local EffectName_0 = "particles/test_particles/xulie/xulie.vpcf"
		self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hParent)
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
			
			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_17_damage", {})
			
		end
	end
end

-- 被点名的玩家  倒计时五秒后造成伤害
if modifier_ability_abyss_17_damage == nil then 
	modifier_ability_abyss_17_damage = class({})
end

function modifier_ability_abyss_17_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_17_damage:OnCreated( ... )
	local hParent = self:GetParent()
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(5)
	end 
end

function modifier_ability_abyss_17_damage:OnIntervalThink( kv )
	if IsServer() then 
		local hCaster = self:GetCaster()
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数

		if number > 0 then
			local EffectName_0 = "particles/test_particles/xulie/xulie.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)

			-- 设置BUFF在头顶的点灯特效		particles/units/heroes/hero_axe/axe_battle_hunger.vpcf
			local EffectName_1 = "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
			self.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl( self.nFXIndex_1, 0, hParent:GetAbsOrigin())
			self:AddParticle( self.nFXIndex_1, false, false, -1, false, true)

			self:DecrementStackCount()
		else
			ParticleManager:DestroyParticle( self.nFXIndex_1, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )

			self.nFXIndex_0 = nil
			self.nFXIndex_1 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
			if Unity_Name:IsAlive() then 
				self:FindEnemyRangeDamage(hParent)
			end
		end
	end
end

function modifier_ability_abyss_17_damage:FindEnemyRangeDamage( hParent )
	local enemys = FindUnitsInRadius(
				hParent:GetTeamNumber(),
				hParent:GetAbsOrigin(), 
				hParent,
				500, 
				DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 0, false)
	for _,enemy in pairs(enemys) do
		if #enemys > 1 then 
			ApplyDamage(
				{
					victim = enemy,
					attacker = Unity_Name,
					damage = hParent:GetMaxHealth() * 0.9,
					damage_type = DAMAGE_TYPE_MAGICAL,
				})
		else
			ApplyDamage(
				{
					victim = enemy,
					attacker = Unity_Name,
					damage = 3000,
					damage_type = DAMAGE_TYPE_MAGICAL,
				})
		end
	end
end