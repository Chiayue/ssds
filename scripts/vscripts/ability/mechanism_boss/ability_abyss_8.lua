-- 钢铁护甲		ability_abyss_8

LinkLuaModifier("modifier_ability_abyss_8", "ability/mechanism_Boss/ability_abyss_8", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_8 == nil then 
	ability_abyss_8 = class({})
end

function ability_abyss_8:IsHidden( ... )
	return true
end

function ability_abyss_8:GetIntrinsicModifierName()
	return "modifier_ability_abyss_8"
end

if modifier_ability_abyss_8 == nil then 
	modifier_ability_abyss_8 = class({})
end

function modifier_ability_abyss_8:IsHidden( ... )
	return false
end

function modifier_ability_abyss_8:OnCreated( kv )
	local hCaster = self:GetCaster()
	self.IncomingDamage_value = -100
	if IsServer() then 
		self:SetStackCount(10)
		--hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_ability_abyss_8_Reduction_of_injury", {})
	end 
end

function modifier_ability_abyss_8:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACKED, 
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- 减伤
		}
end

function modifier_ability_abyss_8:OnAttacked( kv )
	local hAttacker = kv.attacker   -- 攻击者	英雄
	local target = kv.target   		-- 受害者   是我
	local units = kv.units
	--print("1")
	local IncomingDamage_Count = self:GetStackCount()

	if hAttacker ~= nil and IncomingDamage_Count > 0 then 
		
		self.IncomingDamage_value = (IncomingDamage_Count * (-10) )

	else
		self:GetParent():RemoveModifierByName("modifier_ability_abyss_8")
	end
end

function modifier_ability_abyss_8:GetModifierIncomingDamage_Percentage( ... )
	return self.IncomingDamage_value
end

function modifier_ability_abyss_8:OnIntervalThink( kv )
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
			--hParent:AddNewModifier(hParent, self, "modifier_ability_abyss_8_damage", {}) -- duration = 2

			self.nFXIndex_0 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
			
		end
	end
end