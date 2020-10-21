-- 破甲攻击
LinkLuaModifier( "modifier_ability_flagstone_sunderarmor", "ability/flagstone/ability_flagstone_sunderarmor",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_sunderarmor_debuff", "ability/flagstone/ability_flagstone_sunderarmor",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
if ability_flagstone_sunderarmor == nil then ability_flagstone_sunderarmor = {} end

function ability_flagstone_sunderarmor:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_sunderarmor"
end
--------------------------------------------------
if modifier_ability_flagstone_sunderarmor == nil then modifier_ability_flagstone_sunderarmor = {} end
function modifier_ability_flagstone_sunderarmor:IsHidden()return true end
function modifier_ability_flagstone_sunderarmor:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_ability_flagstone_sunderarmor:OnAttackLanded( params )
	-- body
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then return end
	if params.target:IsAlive() == false then return end
	if params.target == self:GetParent() then return end
	local hTarget = params.target
	local hCaster = params.attacker
	local fReduceArmorRatio = self:GetAbility():GetSpecialValueFor( "reduce_armor" ) * 0.01
	local nReduceArmor = math.floor(hTarget:GetPhysicalArmorValue(false) * fReduceArmorRatio)
	-- print(nReduceArmor)
	local hDebuff = hTarget:FindModifierByName("modifier_ability_flagstone_sunderarmor_debuff")
	if hDebuff == nil then
		 hDebuff = hTarget:AddNewModifier( 
			self:GetCaster(), 
			self:GetAbility(), 
			"modifier_ability_flagstone_sunderarmor_debuff", 
			{ duration = 5} 
		)
	end
	local nStackDebuff = hDebuff:GetStackCount()
	if nStackDebuff <= nReduceArmor then 
		hDebuff:SetStackCount(nReduceArmor) 
	end
end
---------------
if modifier_ability_flagstone_sunderarmor_debuff == nil then modifier_ability_flagstone_sunderarmor_debuff = {} end
function modifier_ability_flagstone_sunderarmor_debuff:IsHidden() return false end
function modifier_ability_flagstone_sunderarmor_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
	return funcs
end

function modifier_ability_flagstone_sunderarmor_debuff:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_ability_flagstone_sunderarmor_debuff:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end

