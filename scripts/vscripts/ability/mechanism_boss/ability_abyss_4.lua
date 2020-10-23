-- 灭地绝		ability_abyss_4

LinkLuaModifier("modifier_ability_abyss_4", "ability/mechanism_Boss/ability_abyss_4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_4_damage", "ability/mechanism_Boss/ability_abyss_4", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_4 == nil then 
	ability_abyss_4 = class({})
end

function ability_abyss_4:IsHidden( ... )
	return true
end

function ability_abyss_4:OnSpellStart( ... )
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_4", {}) -- duration = 2


	local enemys = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hCaster:GetAbsOrigin(), 
		hCaster, 
		1000, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false)

	for _, enemy in pairs(enemys) do

		enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_4_damage", {})

	end

end

if modifier_ability_abyss_4 == nil then 
	modifier_ability_abyss_4 = class({})
end

function modifier_ability_abyss_4:IsHidden( ... )
	return true
end

function modifier_ability_abyss_4:OnCreated( kv )
	local hCaster = self:GetCaster()
	
	if IsServer() then 
		--self.hTarget = kv.target

		self:StartIntervalThink(1)
		self:SetStackCount(5)
	end 
end

function modifier_ability_abyss_4:OnIntervalThink( kv )
	if IsServer() then 
		local hCaster = self:GetCaster()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

		if number > 0 then
		local EffectName_0 = "particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf"
		self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hCaster)
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

function modifier_ability_abyss_4_damage:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()
		local hCaster = self:GetCaster()
		--local hTarget = kv.target

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

		if number > 0 then
			local EffectName_0 = "particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)

			self:DecrementStackCount()
		else

			local EffectName_1 = "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf"
			self.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl( self.nFXIndex_1, 0, hParent:GetAbsOrigin())
			ParticleManager:SetParticleControl( self.nFXIndex_1, 1, hParent:GetAbsOrigin())
			ParticleManager:SetParticleControl( self.nFXIndex_1, 3, hParent:GetAbsOrigin())
			-- ParticleManager:DestroyParticle( self.nFXIndex_1, false )
			-- ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )
			self:AddParticle( self.nFXIndex_1, false, false, -1, false, true)

			local max_helth_damage = hParent:GetMaxHealth() * 0.9
			--print("max_helth_damage------------------->", max_helth_damage)

			ApplyDamage({
				victim = hParent,
				attacker = hCaster,
				damage = max_helth_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			})

			self.nFXIndex_0 = nil
			self.nFXIndex_1 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
		end
	end
end