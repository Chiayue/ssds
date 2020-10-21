LinkLuaModifier( "modifier_archon_deputy_boxer", "ability/archon/deputy/archon_deputy_boxer", LUA_MODIFIER_MOTION_NONE )	
--------------------
-- 基础300 每次加50   全属性 50
if archon_deputy_boxer == nil then archon_deputy_boxer = {} end
function archon_deputy_boxer:OnSpellStart() 
	if IsServer() then 
		local hCaster = self:GetCaster()
		local nPlayerID = hCaster:GetPlayerID()
		local nPoints = Player_Data:getPoints(nPlayerID)
		local nEveryCost = hCaster:GetModifierStackCount("modifier_archon_deputy_boxer", hCaster ) * self:GetSpecialValueFor("every_cost")
		local nCost = self:GetSpecialValueFor("Initial_cost") + nEveryCost

		if nPoints  >= nCost then
			hCaster:AddNewModifier(hCaster, self, "modifier_archon_deputy_boxer", {})
			local nDeputyStack = hCaster:GetModifierStackCount("modifier_series_reward_deputy_boxer", hCaster )
			local bCost = true
			local nChance = 15
			if nDeputyStack >= 2 then
				local nRandomChance = RandomInt(0,100)
				if nRandomChance < nChance then
					bCost = false
				end
			end
			if bCost == true then Player_Data:CostPoints(nPlayerID,nCost) end
			if nDeputyStack >= 3 then
				local nRandomChance = RandomInt(0,100)
				if nRandomChance < nChance then
					hCaster:AddNewModifier(hCaster, self, "modifier_archon_deputy_boxer", {})
				end
			end

			local particle = ParticleManager:CreateParticle(
				"particles/units/heroes/hero_faceless_void/faceless_void_time_lock_bash.vpcf", 
				PATTACH_CUSTOMORIGIN, 
				nil)
			ParticleManager:SetParticleControl(particle, 0, hCaster:GetAbsOrigin() )
			ParticleManager:SetParticleControl(particle, 1, hCaster:GetAbsOrigin() )
			ParticleManager:SetParticleControlEnt(particle, 2, hCaster, PATTACH_CUSTOMORIGIN, "attach_hitloc", hCaster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(particle)

		else
			local hPlayer = PlayerResource:GetPlayer(nPlayerID)
			CustomGameEventManager:Send_ServerToPlayer(hPlayer,"send_error_message_client",{message="木材不够，需求["..nCost.."]木材"})
		end
	end	
end
-----------------

if modifier_archon_deputy_boxer == nil then modifier_archon_deputy_boxer = {} end
function modifier_archon_deputy_boxer:RemoveOnDeath() return false end
function modifier_archon_deputy_boxer:IsHidden() return false end
function modifier_archon_deputy_boxer:IsPurgable() return false end

function modifier_archon_deputy_boxer:OnCreated() 
	self.all_status = self:GetAbility():GetSpecialValueFor( "all_status" )
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_archon_deputy_boxer:OnRefresh() 
	self.all_status = self:GetAbility():GetSpecialValueFor( "all_status" )
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_archon_deputy_boxer:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	} 
	return funcs
end

function modifier_archon_deputy_boxer:GetModifierBonusStats_Agility() 
	return self.all_status * self:GetStackCount() 
end

function modifier_archon_deputy_boxer:GetModifierBonusStats_Intellect()	
	return self.all_status * self:GetStackCount() 
end

function modifier_archon_deputy_boxer:GetModifierBonusStats_Strength() 
	return self.all_status * self:GetStackCount() 
end

function modifier_archon_deputy_boxer:OnTooltip() 
	return self:GetAbility():GetSpecialValueFor( "Initial_cost" ) + self:GetStackCount() * self:GetAbility():GetSpecialValueFor("every_cost")
end