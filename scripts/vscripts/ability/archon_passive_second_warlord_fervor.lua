LinkLuaModifier( "modifier_archon_passive_second_warlord_fervor", "ability/archon_passive_second_warlord_fervor.lua",LUA_MODIFIER_MOTION_NONE )


if archon_passive_second_warlord_fervor == nil then
	archon_passive_second_warlord_fervor = class({})
end

function archon_passive_second_warlord_fervor:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_warlord_fervor"
end
------------------
if modifier_archon_passive_second_warlord_fervor == nil then
	modifier_archon_passive_second_warlord_fervor = class({})
end

function modifier_archon_passive_second_warlord_fervor:DestroyOnExpire()
	return false
end

function modifier_archon_passive_second_warlord_fervor:IsHidden() 
	return ( self:GetStackCount() == 0 )
end

function modifier_archon_passive_second_warlord_fervor:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end

function modifier_archon_passive_second_warlord_fervor:OnCreated( kw )
	self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed" )
	self.max_stacks = self:GetAbility():GetSpecialValueFor( "max_stacks" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	self.flFierySoulDuration = 0

	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
end

function modifier_archon_passive_second_warlord_fervor:OnRefresh( kw )
	self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed" )
	self.max_stacks = self:GetAbility():GetSpecialValueFor( "max_stacks" )
	self.duration = self:GetAbility():GetSpecialValueFor( "duration" )
	if IsServer() then
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) ) 
	end
end

function modifier_archon_passive_second_warlord_fervor:OnIntervalThink()
	if IsServer() then
		self:StartIntervalThink( -1 )
		self:SetStackCount( 0 )
		-- ParticleManager:DestroyParticle(self.nFXIndex,true)
	end
end



function modifier_archon_passive_second_warlord_fervor:GetModifierAttackSpeedBonus_Constant( params )
	return self:GetStackCount() * self.attack_speed
end

function modifier_archon_passive_second_warlord_fervor:OnAttackLanded( params )
	local Target = params.target
	local Attacker = params.attacker
	if Attacker ~= nil and Attacker == self:GetParent() and Target ~= nil then
		-- print(DeepPrintTable(self))
		-- print("OnAttackLanded",self.max_stacks,self:GetStackCount())
		
		local chance = self:GetAbility():GetSpecialValueFor( "chance" )
		local nowChance = RandomInt(0,100)
		if nowChance > chance then
			return false
		end
		if self:GetStackCount() < self.max_stacks then
			self:IncrementStackCount()
		else
			self:SetStackCount( self:GetStackCount() )
			self:ForceRefresh()
		end

		self:SetDuration( self.duration, true )
		self:StartIntervalThink( self.duration )
	end
end
