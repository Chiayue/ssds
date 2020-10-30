-- 天神之怒		ability_abyss_12

LinkLuaModifier("modifier_ability_abyss_12", "ability/mechanism_Boss/ability_abyss_12", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_12_damage", "ability/mechanism_Boss/ability_abyss_12", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_12 == nil then 
	ability_abyss_12 = class({})
end

function ability_abyss_12:IsHidden( ... )
	return true
end

function ability_abyss_12:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	if hCaster:GetHealthPercent() > 80 then
		self:EndCooldown()
	-- 当释放者的血量不足80%
	elseif hCaster:GetHealthPercent() <= 80 then
		hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_12", {}) -- duration = 2
	end
end

if modifier_ability_abyss_12 == nil then 
	modifier_ability_abyss_12 = class({})
end

function modifier_ability_abyss_12:IsHidden( ... )
	return true
end

function modifier_ability_abyss_12:OnCreated( kv )
	local hCaster = self:GetCaster()
	
	if IsServer() then 

		self:StartIntervalThink(1)
		self:SetStackCount(5)
	end 
end

function modifier_ability_abyss_12:OnIntervalThink( kv )
	if IsServer() then 
		local hCaster = self:GetCaster()
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
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self.nFXIndex_0 = nil

			self:StartIntervalThink(-1)
			self:Destroy()

			if hCaster:IsAlive() then 
				self:FindEnemyRangeDamage(hParent)
			end
		end
	end
end

function modifier_ability_abyss_12:FindEnemyRangeDamage(hParent)

 	local enemys = FindUnitsInRadius(
			hParent:GetTeamNumber(), 
			hParent:GetAbsOrigin(), 
			hParent, 
			99999, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false)

	for _, enemy in pairs(enemys) do
		local EffectName = "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf"
		self.nFXIndex_3 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
		ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 0, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_1", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 1, enemy, PATTACH_POINT_FOLLOW, "attach_batAss_1", enemy:GetAbsOrigin(), true)
		self:AddParticle(self.nFXIndex_3, false, false, -1, false, true)

		ApplyDamage({
			victim = enemy,
			attacker = hParent,
			damage = enemy:GetMaxHealth() * 0.8,
			damage_type = DAMAGE_TYPE_MAGICAL,
		})
	end
end