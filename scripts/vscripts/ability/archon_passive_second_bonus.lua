LinkLuaModifier( "modifier_archon_passive_second_bonus_str", "ability/archon_passive_second_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_bonus_str_add", "ability/archon_passive_second_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_bonus_agi", "ability/archon_passive_second_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_bonus_agi_add", "ability/archon_passive_second_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_bonus_int", "ability/archon_passive_second_bonus.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_second_bonus_int_add", "ability/archon_passive_second_bonus.lua",LUA_MODIFIER_MOTION_NONE )

------------------ 属性增强 -------------

if archon_passive_second_bonus_str == nil then
	archon_passive_second_bonus_str = class({})
end

if archon_passive_second_bonus_agi == nil then
	archon_passive_second_bonus_agi = class({})
end

if archon_passive_second_bonus_int == nil then
	archon_passive_second_bonus_int = class({})
end

function archon_passive_second_bonus_str:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_bonus_str"
end

function archon_passive_second_bonus_agi:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_bonus_agi"
end

function archon_passive_second_bonus_int:GetIntrinsicModifierName()
 	return "modifier_archon_passive_second_bonus_int"
end
---------------------------------  STR -----------------------------

if modifier_archon_passive_second_bonus_str == nil then
	modifier_archon_passive_second_bonus_str = class({})
end

function modifier_archon_passive_second_bonus_str:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_second_bonus_str:IsHidden() 
	return true
end

function modifier_archon_passive_second_bonus_str:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nowChance = RandomInt(0,100)
	
	if nowChance > chance then
		return false
	end
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local max_stack = self:GetAbility():GetSpecialValueFor( "max_stack" )
	local hCaster = self:GetCaster()
	
	local ModifybonusName = "modifier_archon_passive_second_bonus_str_add" 

	local ModifiersTable = hCaster:FindAllModifiersByName(ModifybonusName)
	local nowStack = #ModifiersTable
	if nowStack >= max_stack then
		hCaster:RemoveModifierByName(ModifybonusName)
	end
	hCaster:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		ModifybonusName, 
		{ duration = duration} 
	)
end

---------------------------------------------------------------------------
if modifier_archon_passive_second_bonus_str_add == nil then
	modifier_archon_passive_second_bonus_str_add = class({})
end

function modifier_archon_passive_second_bonus_str_add:IsHidden() 
	return false
end

function modifier_archon_passive_second_bonus_str_add:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_second_bonus_str_add:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
	return funcs
end

function modifier_archon_passive_second_bonus_str_add:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetCaster():GetBaseStrength() * self:GetAbility():GetSpecialValueFor( "coefficient" )
end

function modifier_archon_passive_second_bonus_str_add:GetModifierBonusStats_Strength( kv )
	return self.bonus
end


---------------------------------  AGI -----------------------------

if modifier_archon_passive_second_bonus_agi == nil then
	modifier_archon_passive_second_bonus_agi = class({})
end

function modifier_archon_passive_second_bonus_agi:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_second_bonus_agi:IsHidden() 
	return true
end

function modifier_archon_passive_second_bonus_agi:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nowChance = RandomInt(0,100)
	if nowChance > chance then
		return false
	end
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local max_stack = self:GetAbility():GetSpecialValueFor( "max_stack" )
	local hCaster = self:GetCaster()
	
	local ModifybonusName = "modifier_archon_passive_second_bonus_agi_add" 

	local ModifiersTable = hCaster:FindAllModifiersByName(ModifybonusName)
	local nowStack = #ModifiersTable
	if nowStack >= max_stack then
		hCaster:RemoveModifierByName(ModifybonusName)
	end
	hCaster:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		ModifybonusName, 
		{ duration = duration} 
	)
end

---------------------------------------------------------------------------
if modifier_archon_passive_second_bonus_agi_add == nil then
	modifier_archon_passive_second_bonus_agi_add = class({})
end

function modifier_archon_passive_second_bonus_agi_add:IsHidden() 
	return true
end

function modifier_archon_passive_second_bonus_agi_add:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_second_bonus_agi_add:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
	return funcs
end

function modifier_archon_passive_second_bonus_agi_add:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetCaster():GetBaseAgility() * self:GetAbility():GetSpecialValueFor( "coefficient" )
end

function modifier_archon_passive_second_bonus_agi_add:GetModifierBonusStats_Agility( kv )
	return self.bonus
end

---------------------------------  INT -----------------------------

if modifier_archon_passive_second_bonus_int == nil then
	modifier_archon_passive_second_bonus_int = class({})
end

function modifier_archon_passive_second_bonus_int:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_archon_passive_second_bonus_int:IsHidden() 
	return true
end

function modifier_archon_passive_second_bonus_int:OnAttackLanded( params )
	if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local nowChance = RandomInt(0,100)
	if nowChance > chance then
		return false
	end
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local max_stack = self:GetAbility():GetSpecialValueFor( "max_stack" ) 
	local hCaster = self:GetCaster()
	local ModifybonusName = "modifier_archon_passive_second_bonus_int_add" 
	local ModifiersTable = hCaster:FindAllModifiersByName(ModifybonusName)
	local nowStack = #ModifiersTable
	if nowStack >= max_stack then
		hCaster:RemoveModifierByName(ModifybonusName)
	end
	hCaster:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		ModifybonusName, 
		{ duration = duration} 
	)
end

---------------------------------------------------------------------------
if modifier_archon_passive_second_bonus_int_add == nil then
	modifier_archon_passive_second_bonus_int_add = class({})
end

function modifier_archon_passive_second_bonus_int_add:IsHidden() 
	return true
end

function modifier_archon_passive_second_bonus_int_add:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_second_bonus_int_add:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

function modifier_archon_passive_second_bonus_int_add:OnCreated( kv )
	if not IsServer() then return end
	self.bonus = self:GetCaster():GetBaseIntellect() * self:GetAbility():GetSpecialValueFor( "coefficient" )
end

-- function modifier_archon_passive_second_bonus_int_add:OnRefresh( kv )
-- 	local bonus = kv.bonus
-- 	self.bonus = bonus
-- end

function modifier_archon_passive_second_bonus_int_add:GetModifierBonusStats_Intellect( kv )
	return self.bonus
end