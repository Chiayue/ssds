-- 食人魔手套
LinkLuaModifier("modifier_item_ogre_glove", "item/item_ogre_glove", LUA_MODIFIER_MOTION_NONE)

if item_ogre_glove == nil then 
	item_ogre_glove = class({})
end

function item_ogre_glove:GetIntrinsicModifierName()
 	return "modifier_item_ogre_glove"
end
--------------------------------------------------
if modifier_item_ogre_glove == nil then
	modifier_item_ogre_glove = class({})
end

function modifier_item_ogre_glove:IsHidden() -- 隐藏图标
	return true
end

function modifier_item_ogre_glove:Passive() -- 默认拥有
	return true
end

function modifier_item_ogre_glove:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, -- 获得力量 + 绿字
		MODIFIER_PROPERTY_HEALTH_BONUS, -- 生命上限
		--MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, -- 生命回复
	}
	return funcs
end

function modifier_item_ogre_glove:OnCreated(kv)
	--local caster = self:GetCaster()
	--local ability = self:GetParent()
	self.strength = self:GetAbility():GetSpecialValueFor("strength")
	self.health = self:GetAbility():GetSpecialValueFor("health")
	--self.health_reply = self:GetAbility():GetSpecialValueFor("health_reply") -- 生命回复  是当前拥有血量的 0.5%
	--local strength = self:GetAbility():GetSpecialValueFor("strength")
	--print("strength", strength)

	--caster:AddNewModifier(caster, self:GetAbility(), "modifier_item_glove", {})
end

function modifier_item_ogre_glove:GetModifierBonusStats_Strength( kv ) -- 官方方法 返回获取到的属性值(力量) 到面板
	return self.strength
end

function modifier_item_ogre_glove:GetModifierHealthBonus( kv ) -- 返回生命上限到面板 的官方方法
	return self.health
end

--function modifier_item_glove:GetModifierHealthRegenPercentage( kv ) -- 返回生命回复速度
--	return self.health_reply
--end