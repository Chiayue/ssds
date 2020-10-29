-- 灭地绝		ability_abyss_4

LinkLuaModifier("modifier_ability_abyss_4", "ability/mechanism_Boss/ability_abyss_4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_4_damage", "ability/mechanism_Boss/ability_abyss_4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_4_damage_effect", "ability/mechanism_Boss/ability_abyss_4", LUA_MODIFIER_MOTION_NONE)


if ability_abyss_4 == nil then 
	ability_abyss_4 = class({})
end

function ability_abyss_4:IsHidden( ... )
	return true
end

function ability_abyss_4:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	--if hCaster:GetHealthPercent() > 50 then
	--	self:EndCooldown()
	-- 当释放者的血量不足80%
	--elseif hCaster:GetHealthPercent() <= 50 then 
		UNIT_NAME = hCaster
		hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_4", {}) -- duration = 2

		local enemys = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hCaster:GetAbsOrigin(), 
			hCaster, 
			99999, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false)

		for _, enemy in pairs(enemys) do

			enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_4_damage", {})

		end
	--end
end

if modifier_ability_abyss_4 == nil then 
	modifier_ability_abyss_4 = class({})
end

function modifier_ability_abyss_4:IsHidden( ... )
	return true
end

function modifier_ability_abyss_4:OnCreated( kv )	
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(5)
	end 
end

function modifier_ability_abyss_4:OnIntervalThink( kv )
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
		end
	end
end

-- 所有的玩家  倒计时五秒后造成伤害
if modifier_ability_abyss_4_damage == nil then 
	modifier_ability_abyss_4_damage = class({})
end

function modifier_ability_abyss_4_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_4_damage:OnCreated( ... )
	local hParent = self:GetParent()
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(5)
	end 
end

function modifier_ability_abyss_4_damage:OnIntervalThink( )
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

			self:DecrementStackCount()
		else
			hParent:AddNewModifier(hParent, nil, "modifier_ability_abyss_4_damage_effect", {duration = 9})
			-- local EffectName_1 = "particles/units/heroes/heroes_underlord/underlord_pitofmalice.vpcf"
			-- self.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_RENDERORIGIN_FOLLOW, hParent)
			-- ParticleManager:SetParticleControl( self.nFXIndex_1, 0, hParent:GetAbsOrigin())
			-- ParticleManager:SetParticleControl( self.nFXIndex_1, 1, hParent:GetAbsOrigin())
			-- ParticleManager:SetParticleControl( self.nFXIndex_1, 3, hParent:GetAbsOrigin())
			-- self:AddParticle( self.nFXIndex_1, false, false, -1, false, true)

			-- ApplyDamage({
			-- 	victim = hParent,
			-- 	attacker = UNIT_NAME,
			-- 	damage = 1000, -- hParent:GetMaxHealth() * 0.9
			-- 	damage_type = DAMAGE_TYPE_MAGICAL,
			-- })

			self.nFXIndex_0 = nil
			self.nFXIndex_1 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
		end
	end
end

if modifier_ability_abyss_4_damage_effect == nil then 
	modifier_ability_abyss_4_damage_effect =class({})
end

function modifier_ability_abyss_4_damage_effect:IsHidden( ... )
	return true
end

function modifier_ability_abyss_4_damage_effect:OnCreated( ... )
	if IsServer() then 
		self:StartIntervalThink(0.5)
	end
end

function modifier_ability_abyss_4_damage_effect:OnIntervalThink( ... )
	if IsServer() then 
		local hParent = self:GetParent()
		local EffectName_1 = "particles/econ/items/legion/legion_overwhelming_odds_ti7/legion_commander_odds_ti7.vpcf"
		self.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_RENDERORIGIN_FOLLOW, hParent)
		ParticleManager:SetParticleControl( self.nFXIndex_1, 0, hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000))
		ParticleManager:SetParticleControl( self.nFXIndex_1, 1, hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000))
		ParticleManager:SetParticleControl( self.nFXIndex_1, 3, hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000))
		ParticleManager:SetParticleControl( self.nFXIndex_1, 3, hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000))
		ApplyDamage({
				victim = hParent,
				attacker = UNIT_NAME,
				damage = hParent:GetMaxHealth() * 0.05, -- hParent:GetMaxHealth() * 0.9
				damage_type = DAMAGE_TYPE_MAGICAL,
			})
	end
end