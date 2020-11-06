-- 寒冰之足		ability_abyss_18

LinkLuaModifier("modifier_ability_abyss_18", "ability/mechanism_Boss/ability_abyss_18", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_18_damage", "ability/mechanism_Boss/ability_abyss_18", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_18_control", "ability/mechanism_Boss/ability_abyss_18", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_18 == nil then
	ability_abyss_18 = class({})
end

function ability_abyss_18:IsHidden( ... )
	return true
end

function ability_abyss_18:OnSpellStart( ... )
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
		Unity_Name = hCaster
		enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_18_damage", {}) -- duration = 2
	end
end

function ability_abyss_18:GetIntrinsicModifierName()
	return "modifier_ability_abyss_18"
end

if modifier_ability_abyss_18 == nil then 
	modifier_ability_abyss_18 = class({})
end

function modifier_ability_abyss_18:IsHidden( ... )
	return true
end

function modifier_ability_abyss_18:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_AVOID_DAMAGE, -- return 	keys.damage  直接免伤所有伤害(包括技能带来的所有伤害)
	}
end

function modifier_ability_abyss_18:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
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
			hParent:ForceKill(true)
		end
	end
end

function modifier_ability_abyss_18:GetModifierAvoidDamage( keys )
	return keys.damage
end

if modifier_ability_abyss_18_damage == nil then 
	modifier_ability_abyss_18_damage = class({})
end

function modifier_ability_abyss_18_damage:IsHidden( ... )
	return true
end

function modifier_ability_abyss_18_damage:OnCreated( kv )
	local hParent = self:GetParent()
	if IsServer() then 
		self:StartIntervalThink(1)
		self:SetStackCount(5)
	end 
end

function modifier_ability_abyss_18_damage:OnIntervalThink( kv )
	if IsServer() then 
		local hParent = self:GetParent()

		local number = self:GetStackCount() -- 获取到当前的BUFF层数

		if number > 0 then
			local EffectName_0 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet.vpcf"
			self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hParent)
			ParticleManager:SetParticleControl(self.nFXIndex_0, 0, hParent:GetAbsOrigin())
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, hParent:GetAbsOrigin())
			self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)
			
			if number >= 5 then 
				self.target_pos = hParent:GetAbsOrigin()
			elseif number < 5 then
				self.target_pos_1 = hParent:GetAbsOrigin()
				local distance = (self.target_pos_1 - self.target_pos):Length2D()
				if distance > 500 then 
					hParent:RemoveModifierByName("modifier_ability_abyss_18_damage")
				end
			end
			
			-- 设置BUFF在头顶的层数
			self:DecrementStackCount()
		else
			ParticleManager:DestroyParticle( self.nFXIndex_0, false )
			ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
			self.nFXIndex_0 = nil

			self:StartIntervalThink(-1)
			self:Destroy()
			
			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_abyss_18_control", {duration = 2})
			
		end
	end
end

-- 所有玩家被控制2秒
if modifier_ability_abyss_18_control == nil then 
	modifier_ability_abyss_18_control = class({})
end

function modifier_ability_abyss_18_control:IsHidden( ... )
	return false
end

function modifier_ability_abyss_18_control:IsDebuff( ... )
	return true
end

function modifier_ability_abyss_18_control:OnCreated( ... ) 
    local hParent = self:GetParent()

    local EffectName_1 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_cold_feet_frozen.vpcf"
    self.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_OVERHEAD_FOLLOW, hParent)
    ParticleManager:SetParticleControl(self.nFXIndex_1, 0, hParent:GetAbsOrigin())
end

function modifier_ability_abyss_18_control:OnDestroy( ... ) 
    ParticleManager:DestroyParticle( self.nFXIndex_1, false )
    ParticleManager:ReleaseParticleIndex( self.nFXIndex_1 )
    self.nFXIndex_1 = nil
end

function modifier_ability_abyss_18_control:CheckState() -- 状态效果
    return 
        {
            [MODIFIER_STATE_FROZEN] = true,
            [MODIFIER_STATE_STUNNED] = true,
        }
end

function modifier_ability_abyss_18_control:GetOverrideAnimation( ... )
	return ACT_DOTA_DISABLED
end