-- 敌人
LinkLuaModifier("modifier_autistic_week4_ally", "autistic/autistic_weeky_4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week4_emeny", "autistic/autistic_weeky_4", LUA_MODIFIER_MOTION_NONE)

-------------------------- 英雄 --------------------------
modifier_autistic_week4_ally = {}
function modifier_autistic_week4_ally:IsHidden() return false end
function modifier_autistic_week4_ally:DeclareFunctions() 
	return { 
	MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
} 
end
function modifier_autistic_week4_ally:GetTexture() return "qishangquan" end
function modifier_autistic_week4_ally:GetModifierMoveSpeed_AbsoluteMin() return 800 end
function modifier_autistic_week4_ally:GetAttributes() return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_autistic_week4_ally:RemoveOnDeath() return false end
function modifier_autistic_week4_ally:GetModifierIncomingDamage_Percentage(keys) return -30 end

-------------------------- 小怪 --------------------------
modifier_autistic_week4_emeny = {}
function modifier_autistic_week4_emeny:IsHidden() return false end