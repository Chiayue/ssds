-- 奔雷剑		ability_abyss_7

LinkLuaModifier("modifier_ability_abyss_7", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_7_damage", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_7_effects", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_7_Reduction_of_injury", "ability/mechanism_Boss/ability_abyss_7", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_7 == nil then 
	ability_abyss_7 = class({})
end

function ability_abyss_7:IsHidden( ... )
	return true
end

function ability_abyss_7:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	for i = 1, 5 do
		self.mob = CreateUnitByName("ability_abyss_7_unit", hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 1000), true, nil, nil, DOTA_TEAM_BADGUYS)
		self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_7", {})
		self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_7_effects", {})
		self.mob:SetOwner(hCaster)
		self.mob:SetTeam(4)
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
		local hCaster = self:GetCaster()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

		if number > 0 then
			local EffectName = "particles/white/xulie.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hCaster)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 0, Vector(0, 0, 50))
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)

			 -- 设置BUFF在头顶的层数

			self:DecrementStackCount()
		else
			hParent:AddNewModifier(hCaster, self:GetAbility(), "modifier_ability_abyss_7_damage", {}) -- duration = 2

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
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()
	local hTarget = keys.target

	if IsValidEntity(hParent) then 

		local EffectName = "particles/units/heroes/hero_rattletrap/clock_overclock_buff.vpcf"
		self.nFXIndex_2 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
		self:AddParticle(self.nFXIndex_2, false, false, -1, false, true)

		local EffectName = "particles/killstreak/killstreak_ice_topbar_lv2.vpcf"
		self.nFXIndex_3 = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hParent)
		ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 0, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_1", hParent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nFXIndex_3, 1, hParent, PATTACH_POINT_FOLLOW, "attach_batAss_4", hParent:GetAbsOrigin(), true)
		self:AddParticle(self.nFXIndex_3, false, false, -1, false, true)

		local enemys = FindUnitsInRadius(
			hParent:GetTeamNumber(), 
			hParent:GetAbsOrigin(), 
			hParent, 
			1000, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false)

		for _, enemy in pairs(enemys) do
			local x = enemy:GetMaxHealth() * 0.25
			--print("x===================", x)
			--if enemy == hCaster then return end
			ApplyDamage({
				victim = enemy,
				attacker = hParent,
				damage = x,
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
	local hCaster = self:GetCaster()
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
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
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

	self:IncrementStackCount()
	local count = self:GetStackCount()
	--print("count+++++++++++++++++=", count)

	local health = 10 * ( 10 - count ) / 10
	--print("health____+++_+__++++=", health)
	hParent:SetHealth( health )

	if count >= 10 then
		UTIL_Remove(hParent)
		self:Destroy()
	elseif health < 1 or count ~= 10 then
		hParent:SetHealth( health )
		hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_7_Reduction_of_injury", {})
	end

	if attacker:IsRealHero() then 
		if count >= 10 then
			UTIL_Remove(hParent)
			self:Destroy()
		elseif health < 1 or count ~= 10 then
			hParent:SetHealth( health )
			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_7_Reduction_of_injury", {})
		end
	end

	-- if mob_health <= 0 then
	-- 	self.mob:ForceKill(true)
	-- 	self:Destroy()
	-- end
end

function modifier_ability_abyss_7_effects:OnDestroy()
	ParticleManager:DestroyParticle( self.nFXIndex_2, false )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_2 )
	self.nFXIndex_2 = nil

	ParticleManager:DestroyParticle( self.nFXIndex_3, false )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_3 )
	self.nFXIndex_3 = nil

	ParticleManager:DestroyParticle( self.nFXIndex_4, false )
	ParticleManager:ReleaseParticleIndex( self.nFXIndex_4 )
	self.nFXIndex_4 = nil
end

if modifier_ability_abyss_7_Reduction_of_injury == nil then
	modifier_ability_abyss_7_Reduction_of_injury = class({})
end

function modifier_ability_abyss_7_Reduction_of_injury:IsHidden( ... )
	return true
end

function modifier_ability_abyss_7_Reduction_of_injury:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_7_Reduction_of_injury:GetModifierIncomingDamage_Percentage( ... )
	return -100
end