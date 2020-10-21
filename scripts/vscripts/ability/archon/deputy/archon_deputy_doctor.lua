LinkLuaModifier( "modifier_archon_deputy_doctor", "ability/archon/deputy/archon_deputy_doctor", LUA_MODIFIER_MOTION_NONE )	
--------------------
if archon_deputy_doctor == nil then archon_deputy_doctor = {} end
function archon_deputy_doctor:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster() 
	local aoe = self:GetSpecialValueFor( "aoe" )
	local nDuration = self:GetSpecialValueFor( "duration" )
	local nFXIndex0 = ParticleManager:CreateParticle( EffectName, PATTACH_POINT, hCaster)
	local nDeputyStack = hCaster:GetModifierStackCount("modifier_series_reward_deputy_doctor", hCaster )
	local hAllies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(), 
		self:GetCaster():GetOrigin(), 
		self:GetCaster(), 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	local EffectName = "particles/econ/events/ti8/mekanism_ti8.vpcf"
	for _,ally in pairs(hAllies) do
		if ally ~= nil then
			local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, ally)
			local nHealtBonus = ally:GetMaxHealth() * self:GetSpecialValueFor( "max_health" ) * 0.01
			ally:AddNewModifier(hCaster, self, "modifier_archon_deputy_doctor",{ duration = nDuration})
			ally:Heal(nHealtBonus,self:GetCaster())
			if nDeputyStack >= 3 then
				
				ally:AddNewModifier(hCaster, self, "modifier_series_reward_deputy_doctor_effect",{ duration = 10}) 
			end
		end
	end
end
-----------------

if modifier_archon_deputy_doctor == nil then modifier_archon_deputy_doctor = {} end
function modifier_archon_deputy_doctor:RemoveOnDeath() return false end
function modifier_archon_deputy_doctor:IsHidden() return false end
function modifier_archon_deputy_doctor:IsPurgable() return false end

function modifier_archon_deputy_doctor:OnCreated() 
	self.bonus_attackspeed = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
	self.bonus_movespeed = self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
	
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
end

function modifier_archon_deputy_doctor:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_TOOLTIP,
	} 
	return funcs
end

-- function modifier_archon_deputy_doctor:GetModifierBonusStats_Agility() 
-- 	return self.attr_agi 
-- end

-- function modifier_archon_deputy_doctor:GetModifierBonusStats_Intellect()	
-- 	return self.attr_int
-- end

-- function modifier_archon_deputy_doctor:GetModifierBonusStats_Strength() 
-- 	return self.attr_str
-- end

function modifier_archon_deputy_doctor:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attackspeed
end
function modifier_archon_deputy_doctor:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed
end