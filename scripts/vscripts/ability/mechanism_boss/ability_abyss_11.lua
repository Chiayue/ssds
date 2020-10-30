-- 黑影狂潮		ability_abyss_11

LinkLuaModifier("modifier_ability_abyss_11", "ability/mechanism_Boss/ability_abyss_11", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_11_damage", "ability/mechanism_Boss/ability_abyss_11", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_11_damage_debuff", "ability/mechanism_Boss/ability_abyss_11", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_11 == nil then 
	ability_abyss_11 = class({})
end

function ability_abyss_11:IsHidden( ... )
	return true
end

function ability_abyss_11:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	if hCaster:GetHealthPercent() > 80 then
		self:EndCooldown()
	-- 当释放者的血量不足80%
	elseif hCaster:GetHealthPercent() <= 80 then
		hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_11", {}) -- duration = 2
	end
end

if modifier_ability_abyss_11 == nil then 
	modifier_ability_abyss_11 = class({})
end

function modifier_ability_abyss_11:IsHidden( ... )
	return true
end

function modifier_ability_abyss_11:OnCreated( kv )
	local hCaster = self:GetCaster()
	
	if IsServer() then 

		self:StartIntervalThink(1)
		self:SetStackCount(10)
	end 
end

function modifier_ability_abyss_11:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

		if number > 0 then
			local EffectName = "particles/test_particles/xulie/xulie.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)

			CreateModifierThinker(hParent, self:GetAbility(), "modifier_ability_abyss_11_damage", {}, hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), hParent:GetTeamNumber(), false)

			-- 减少BUFF在头顶的层数
			self:DecrementStackCount()
		else
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self.nFXIndex_0 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
		end
	end
end

-- 创建后几秒后摧毁并造成伤害
if modifier_ability_abyss_11_damage == nil then 
	modifier_ability_abyss_11_damage = class({})
end

function modifier_ability_abyss_11_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_11_damage:OnCreated( ... )
	local hParent = self:GetParent()
	
	if IsServer() then 
		self:StartIntervalThink(3)
	end 

	local EffectName = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
	ParticleManager:SetParticleControl(self.nFXIndex_2, 0, Vector(0, 0, 0))
	ParticleManager:SetParticleControl(self.nFXIndex_2, 1, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_2, 3, hParent:GetAbsOrigin())
	self:AddParticle(self.nFXIndex_2, false, false, -1, false, true)

end

function modifier_ability_abyss_11_damage:OnIntervalThink( ... )
	if not IsServer() then return end 
	local hParent = self:GetParent()

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
				damage = 3000,
				damage_type = DAMAGE_TYPE_PURE,
			})

			enemy:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_11_damage_debuff", {duration = 20})
		end
		self:Destroy()
end

function modifier_ability_abyss_11_damage:OnDestroy( ... )
	ParticleManager:DestroyParticle( self.nFXIndex_2, false )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_2 )
	self.nFXIndex_2 = nil
end

if modifier_ability_abyss_11_damage_debuff == nil then 
	modifier_ability_abyss_11_damage_debuff = class({})
end

function modifier_ability_abyss_11_damage_debuff:IsHidden( ... )
	return false
end


function modifier_ability_abyss_11_damage_debuff:IsDebuff( ... )
	return true
end

function modifier_ability_abyss_11_damage_debuff:OnCreated( ... )
	self.IncomingDamage_value = 10
	if IsServer() then 
		self:SetStackCount(1)
	end
end

function modifier_ability_abyss_11_damage_debuff:OnRefresh( ... )
	if IsServer() then 
		self:IncrementStackCount()
	end
end

function modifier_ability_abyss_11_damage_debuff:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_11_damage_debuff:GetModifierIncomingDamage_Percentage( ... )
	return self.IncomingDamage_value * self:GetStackCount()
end