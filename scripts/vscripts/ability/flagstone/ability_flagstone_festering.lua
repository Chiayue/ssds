-- 破甲攻击
LinkLuaModifier( "modifier_ability_flagstone_festering", "ability/flagstone/ability_flagstone_festering",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_festering_debuff", "ability/flagstone/ability_flagstone_festering",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
if ability_flagstone_festering == nil then ability_flagstone_festering = {} end

function ability_flagstone_festering:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_festering"
end
--------------------------------------------------
if modifier_ability_flagstone_festering == nil then modifier_ability_flagstone_festering = {} end
function modifier_ability_flagstone_festering:IsHidden()return true end
function modifier_ability_flagstone_festering:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_ability_flagstone_festering:OnAttackLanded( params )
	-- body
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsAlive() == false then return end
	if params.target == self:GetParent() then return end
	local hTarget = params.target
	local hCaster = params.attacker
	hTarget:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		"modifier_ability_flagstone_festering_debuff", 
		{ duration = 5} 
	)

end
---------------
if modifier_ability_flagstone_festering_debuff == nil then modifier_ability_flagstone_festering_debuff = {} end
function modifier_ability_flagstone_festering_debuff:IsHidden() return true end
function modifier_ability_flagstone_festering_debuff:IsDebuff() return true end
function modifier_ability_flagstone_festering_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function modifier_ability_flagstone_festering_debuff:GetModifierMagicalResistanceBonus()
	return -40
end

