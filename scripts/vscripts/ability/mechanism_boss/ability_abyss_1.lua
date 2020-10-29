-- 反伤

LinkLuaModifier("modifier_ability_abyss_1", "ability/mechanism_Boss/ability_abyss_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_1_damage", "ability/mechanism_Boss/ability_abyss_1", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_1 == nil then 
	ability_abyss_1 = class({})
end

function ability_abyss_1:IsHidden( ... )
	return true
end

function ability_abyss_1:OnSpellStart(  )
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_ability_abyss_1", {}) -- duration = 2
end

if modifier_ability_abyss_1 == nil then 
	modifier_ability_abyss_1 = class({})
end

function modifier_ability_abyss_1:IsHidden( ... )
	return true
end

function modifier_ability_abyss_1:OnCreated( ... )
	local hCaster = self:GetCaster()
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(2)
	end 
end

function modifier_ability_abyss_1:OnIntervalThink( ... )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

		if number > 0 then
		local EffectName_0 = "particles/test_particles/xulie/xulie.vpcf"
		self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hParent)
		ParticleManager:SetParticleControl(self.nFXIndex_0, 0, Vector(0, 0, 50))
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
			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_1_damage", {duration = 10})
		end
	end
end

-- 持续10秒的 反伤技能
if modifier_ability_abyss_1_damage == nil then 
	modifier_ability_abyss_1_damage = class({})
end

function modifier_ability_abyss_1_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_1_damage:OnCreated( ... )
	local hParent = self:GetParent()
	local EffectName_0 = "particles/items_fx/blademail.vpcf"
		self.particleID = ParticleManager:CreateParticle(EffectName_0, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(self.particleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)
end

function modifier_ability_abyss_1_damage:OnDestroy( ... )
	ParticleManager:DestroyParticle( self.particleID, false )
		ParticleManager:ReleaseParticleIndex( self.particleID )
		self.particleID = nil
end

function modifier_ability_abyss_1_damage:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACKED, -- 被攻击
		}
end

function modifier_ability_abyss_1_damage:OnAttacked(kv)
	local hAttacker = kv.attacker   -- 攻击者	是我  -- V
	local units = kv.target   		-- 受害者   是怪物
	if units == self:GetParent() then
		--print("args") 
		if hAttacker:IsRealHero() then 
			ApplyDamage({
						ability = self:GetAbility(),
						victim = hAttacker,
						attacker = units,
						damage = hAttacker:GetAttackDamage(),
						damage_type = DAMAGE_TYPE_MAGICAL,
					})
		end
	end
end