LinkLuaModifier( "modifier_bonus_base_attackspeed", "ability/upgrade/bonus_base_attackspeed",LUA_MODIFIER_MOTION_NONE )

if bonus_base_attackspeed == nil then bonus_base_attackspeed = {} end

function bonus_base_attackspeed:OnToggle( params)
	if not IsServer() then return end
	local hHero = self:GetCaster()
	
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_bonus_base_attackspeed",nil)
	else	
		local hBuff = self:GetCaster():FindModifierByName( "modifier_bonus_base_attackspeed" )
		if hBuff ~= nil then
			hBuff:Destroy()
		end
	end
end

if modifier_bonus_base_attackspeed == nil then modifier_bonus_base_attackspeed = {} end
function modifier_bonus_base_attackspeed:IsHidden() return false end
-- function modifier_bonus_base_attackspeed:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
-- 	}
-- 	return funcs
-- end
-- function modifier_bonus_base_attackspeed:OnCreated()
-- 	self.base_attackspeed =  self:GetAbility():GetSpecialValueFor( "base_attackspeed" )
-- end

-- function modifier_bonus_base_attackspeed:GetModifierBaseAttackTimeConstant()
-- 	return self.base_attackspeed
-- end