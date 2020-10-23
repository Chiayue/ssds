-- 敌人
LinkLuaModifier("modifier_autistic_week2_emeny_a", "autistic/autistic_weeky_2", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week2_emeny_b", "autistic/autistic_weeky_2", LUA_MODIFIER_MOTION_NONE)

--[[
A 50%物理伤害，200%魔法伤害
B 200%物理伤害，50%魔法伤害

H 造成的伤害减少20%
]]
------------------------------------------------------------------------------------------
if modifier_autistic_week2_emeny_a == nil then modifier_autistic_week2_emeny_a = {} end
function modifier_autistic_week2_emeny_a:IsHidden() return false end
function modifier_autistic_week2_emeny_a:GetTexture() return "hujia" end
function modifier_autistic_week2_emeny_a:OnCreated() 
	if IsServer() then
		self:GetParent():SetDisableResistanceGain(100) 
	end
end
function modifier_autistic_week2_emeny_a:DeclareFunctions() 
	return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN} 
end
function modifier_autistic_week2_emeny_a:GetModifierMoveSpeed_AbsoluteMin() 
	return 350
end
------------------------------------------------------------------------------------------
if modifier_autistic_week2_emeny_b == nil then modifier_autistic_week2_emeny_b = {} end
function modifier_autistic_week2_emeny_b:IsHidden() return false end
function modifier_autistic_week2_emeny_b:GetTexture() return "faceless_void_chronosphere" end
function modifier_autistic_week2_emeny_b:OnCreated() 
	if IsServer() then
		self:GetParent():SetDisableResistanceGain(100) 
	end
end
function modifier_autistic_week2_emeny_b:DeclareFunctions() 
	return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN} 
end
function modifier_autistic_week2_emeny_b:GetModifierMoveSpeed_AbsoluteMin() 
	return 350
end