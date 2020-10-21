-- 反伤

LinkLuaModifier("modifier_ability_the_injury", "ability/mechanism_Boss/ability_the_injury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_the_injury_damage", "ability/mechanism_Boss/ability_the_injury", LUA_MODIFIER_MOTION_NONE)

if ability_the_injury == nil then 
	ability_the_injury = class({})
end

function ability_the_injury:IsHidden( ... )
	return true
end

function ability_the_injury:OnSpellStart(  )
	local hCaster = self:GetCaster()

	hCaster:AddNewModifier(hCaster, self, "modifier_ability_the_injury", {}) -- duration = 2
end

if modifier_ability_the_injury == nil then 
	modifier_ability_the_injury = class({})
end

function modifier_ability_the_injury:IsHidden( ... )
	return true
end

function modifier_ability_the_injury:OnCreated( ... )
	local hCaster = self:GetCaster()
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(2)
	end 
end

function modifier_ability_the_injury:OnIntervalThink( ... )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数
		--print("number=====", number)

		if number > 0 then
		local EffectName_0 = "particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf"
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
			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_the_injury_damage", {duration = 10})
		end
	end
end

-- 持续10秒的 反伤技能
if modifier_ability_the_injury_damage == nil then 
	modifier_ability_the_injury_damage = class({})
end

function modifier_ability_the_injury_damage:IsHidden( ... )
	return true
end

function modifier_ability_the_injury_damage:OnCreated( ... )
	local hParent = self:GetParent()
	local EffectName_0 = "particles/items_fx/blademail.vpcf"
		self.particleID = ParticleManager:CreateParticle(EffectName_0, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(self.particleID, 0, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)
end

function modifier_ability_the_injury_damage:OnDestroy( ... )
	ParticleManager:DestroyParticle( self.particleID, false )
		ParticleManager:ReleaseParticleIndex( self.particleID )
		self.particleID = nil
end

function modifier_ability_the_injury_damage:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACKED, -- 被攻击
		}
end

function modifier_ability_the_injury_damage:OnAttacked(kv)
	local hAttacker = kv.attacker   -- 攻击者	是我  -- V
	local units = kv.target   		-- 受害者   是怪物
	if units == self:GetParent() then
		--print("args") 
		if hAttacker:IsRealHero() then 
			--local hParent = self:GetParent()
			--print("hAttacker:GetAttackDamage()=======", hAttacker:GetAttackDamage())
			--print("units:GetAttackDamage()=======", units:GetAttackDamage())
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