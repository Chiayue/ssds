---------------------- 混子副职 ------------------------
LinkLuaModifier( "modifier_archon_deputy_idler", "ability/archon/deputy/archon_deputy_idler", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_deputy_idler_effect", "ability/archon/deputy/archon_deputy_idler", LUA_MODIFIER_MOTION_NONE )
--------------------
if archon_deputy_idler == nil then archon_deputy_idler = {} end
function archon_deputy_idler:GetIntrinsicModifierName() return "modifier_archon_deputy_idler" end

if modifier_archon_deputy_idler == nil then modifier_archon_deputy_idler = {} end
function modifier_archon_deputy_idler:RemoveOnDeath() return false end
function modifier_archon_deputy_idler:IsHidden() return true end
function modifier_archon_deputy_idler:IsPurgable() return false end

function modifier_archon_deputy_idler:OnCreated() 
	self.kill_bonus = self:GetAbility():GetSpecialValueFor( "kill_bonus" )
	self.stand_bonus = self:GetAbility():GetSpecialValueFor( "stand_bonus" )
	if IsServer() then
		local hCaster = self:GetParent()
		hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_deputy_idler_effect", {})
	end
end

function modifier_archon_deputy_idler:DeclareFunctions() 
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_TOOLTIP,
	} 
	return funcs
end

function modifier_archon_deputy_idler:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker ~= self:GetCaster() then return 0 end
	local hCaster = self:GetCaster()
	self:StartIntervalThink(5)
	hCaster:RemoveModifierByName("modifier_archon_deputy_idler_effect")
end

function modifier_archon_deputy_idler:OnIntervalThink()
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_deputy_idler_effect", {})
end

if modifier_archon_deputy_idler_effect == nil then modifier_archon_deputy_idler_effect ={} end
function modifier_archon_deputy_idler_effect:IsHidden() return true end
function modifier_archon_deputy_idler_effect:OnCreated()
	self.stand_bonus = self:GetAbility():GetSpecialValueFor( "stand_bonus" )
end

function modifier_archon_deputy_idler_effect:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	} 
	return funcs
end

function modifier_archon_deputy_idler_effect:GetModifierAttackSpeedBonus_Constant()
	return self.stand_bonus
end
