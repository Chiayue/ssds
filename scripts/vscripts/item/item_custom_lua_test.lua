LinkLuaModifier("modifier_item_custom_lua_test", "item/item_custom_lua_test", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_custom_lua_test_bonus", "item/item_custom_lua_test", LUA_MODIFIER_MOTION_NONE)

if item_custom_lua_test == nil then 
	item_custom_lua_test = class({})
end

function item_custom_lua_test:GetIntrinsicModifierName()
	return "modifier_item_custom_lua_test"
end


if modifier_item_custom_lua_test == nil then 
	modifier_item_custom_lua_test = class({})
end

function modifier_item_custom_lua_test:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
end


function modifier_item_custom_lua_test:OnDeath(args)
	-- body
	local nAttacker = args.attacker
	local nCaster = self:GetParent()
	if nAttacker == nCaster then
		local modifier_name = "modifier_item_custom_lua_test_bonus"
		nCaster:AddNewModifier(	
				nCaster,
				self:GetAbility(),
				modifier_name,
				{ duration = -1}
			)
	end
end

if modifier_item_custom_lua_test_bonus == nil then 
	modifier_item_custom_lua_test_bonus = class({})
end


function modifier_item_custom_lua_test_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function modifier_item_custom_lua_test_bonus:OnCreated()
	self:SetStackCount(1)
end

function modifier_item_custom_lua_test_bonus:OnRefresh( kv )
	if IsServer() then
		self:IncrementStackCount()
		self:GetParent():CalculateStatBonus()
	end
end

function modifier_item_custom_lua_test_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}
end

function modifier_item_custom_lua_test_bonus:GetModifierHealthBonus()
	return self:GetStackCount() * 10
end

