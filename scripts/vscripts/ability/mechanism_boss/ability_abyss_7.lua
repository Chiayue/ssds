-- 奔雷剑		ability_abyss_7

LinkLuaModifier("modifier_ability_abyss_7", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_7_damage", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_7_effects", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_7 == nil then 
	ability_abyss_7 = class({})
end

function ability_abyss_7:IsHidden( ... )
	return true
end

function ability_abyss_7:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	if hCaster:GetHealthPercent() > 80 then
		self:EndCooldown()
	-- 当释放者的血量不足80%
	elseif hCaster:GetHealthPercent() <= 80 then
		for i = 1, 5 do
			self.mob = CreateUnitByName("the_running_of_the_security_unit", hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), true, nil, nil, DOTA_TEAM_BADGUYS)
			self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_7", {})
			self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_7_effects", {})
			self.mob:SetOwner(hCaster)
			self.mob:SetTeam(3)
		end
	end
end

if modifier_ability_abyss_7 == nil then 
	modifier_ability_abyss_7 = class({})
end

function modifier_ability_abyss_7:IsHidden( ... )
	return true
end

function modifier_ability_abyss_7:OnCreated( kv )
	local hCaster = self:GetCaster()

	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(15)
	end 
end

function modifier_ability_abyss_7:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数

		if number > 0 then
			local EffectName = "particles/test_particles/xulie/xulie.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 0, Vector(0, 0, 50))
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)

			-- 设置BUFF在头顶的层数
			self:DecrementStackCount()
		else
			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_7_damage", {}) -- duration = 2

			self.nFXIndex_0 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
			if not hParent:IsRealHero() then 
				UTIL_Remove(hParent)
			end
		end
	end
end

-- 自身增加属性BUFF 并在10秒后自爆
if modifier_ability_abyss_7_damage == nil then 
	modifier_ability_abyss_7_damage = class({})
end

function modifier_ability_abyss_7_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_7_damage:OnCreated( keys )
	local hParent = self:GetParent()
	local hTarget = keys.target

	if IsValidEntity(hParent) then 
		local enemys = FindUnitsInRadius(
			hParent:GetTeamNumber(), 
			hParent:GetAbsOrigin(), 
			hParent, 
			99999, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false)

		for _, enemy in pairs(enemys) do
			local EffectName = "particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_end.vpcf"
			self.nFXIndex_4 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, enemy)
			ParticleManager:SetParticleControl(self.nFXIndex_4, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.nFXIndex_4, 1, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.nFXIndex_4, 2, enemy:GetAbsOrigin())
			self:AddParticle(self.nFXIndex_4, false, false, -1, false, true)
			--local x = enemy:GetMaxHealth() * 0.25
			--print("x===================", x)
			ApplyDamage({
				victim = enemy,
				attacker = hParent,
				damage = enemy:GetMaxHealth() * 0.25,
				damage_type = DAMAGE_TYPE_MAGICAL,
			})
		end
	end
end

if modifier_ability_abyss_7_effects == nil then 
	modifier_ability_abyss_7_effects = class({})
end 

function modifier_ability_abyss_7_effects:IsHidden( ... )
	return true
end

function modifier_ability_abyss_7_effects:OnCreated( ... )
	local hParent = self:GetParent()
	 
	local EffectName = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_gravemarker.vpcf"
	self.nFXIndex_2 = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN, hParent)
	ParticleManager:SetParticleControl(self.nFXIndex_2, 0, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_2, 6, hParent:GetAbsOrigin())
	self:AddParticle(self.nFXIndex_2, false, false, -1, false, true)

	
	local EffectName = "particles/econ/events/ti7/teleport_end_ti7_lvl2.vpcf"
	self.nFXIndex_3 = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN, hParent)
	ParticleManager:SetParticleControl(self.nFXIndex_3, 0, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_3, 1, hParent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.nFXIndex_3, 2, hParent:GetAbsOrigin())
	self:AddParticle(self.nFXIndex_3, false, false, -1, false, true)

	
	local EffectName = "particles/units/heroes/hero_razor/razor_static_link_projectile.vpcf"
	self.nFXIndex_4 = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN, hParent)
	ParticleManager:SetParticleControl(self.nFXIndex_4, 0, hParent:GetAbsOrigin())
	--ParticleManager:SetParticleControl(self.nFXIndex_4, 2, Vector(0,0,500))
	self:AddParticle(self.nFXIndex_4, false, false, -1, false, true)
end

function modifier_ability_abyss_7_effects:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_AVOID_DAMAGE, -- return 	keys.damage  直接免伤所有伤害(包括技能带来的所有伤害)
	}
end

function modifier_ability_abyss_7_effects:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
	--local maxAttacks	= keys.max_hero_attacks

	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	local max_heal = hParent:GetHealth()
	local health = (max_heal - 1)
	hParent:SetHealth( health )
	if attacker:IsRealHero() then 
		if health <= 0 then
			UTIL_Remove(hParent)
			self.nFXIndex_2 = nil
			self.nFXIndex_3 = nil
			self.nFXIndex_4 = nil
			self:Destroy()
		end
	end
end

function modifier_ability_abyss_7_effects:GetModifierAvoidDamage( keys )
	return keys.damage
end