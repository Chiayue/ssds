LinkLuaModifier( "modifier_archon_blink_effect", "ability/archon_blink.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_blink", "ability/archon_blink.lua",LUA_MODIFIER_MOTION_NONE )
BLINK_NUBER = 0  -- 记录当前技能使用次数
------ 闪现 ---------
if archon_blink == nil then archon_blink = {} end

function archon_blink:GetCastRange() 
	if IsClient() then 
		return self:GetSpecialValueFor("blink_range") 
	end 
end

function archon_blink:GetIntrinsicModifierName()
 	return "modifier_archon_blink"
end

function archon_blink:GetCooldown() 
	local hCaster = self:GetCaster()
	local nDeputyBlink = hCaster:GetModifierStackCount("modifier_series_reward_deputy_blink", hCaster )
	local nBaseCD = 6
	if nDeputyBlink >= 2 then nBaseCD = 5 end
	if hCaster:HasModifier("modifier_autistic_every_week") then
		return 3
	end
	return nBaseCD

end
function archon_blink:OnSpellStart()
	
	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local direction = (vPos - hCaster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	EmitSoundOn("Hero_Antimage.Blink_out", hCaster )
	local max_dis = self:GetSpecialValueFor("blink_range")
	ProjectileManager:ProjectileDodge(hCaster)
	local pfx1_name = "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf"
	local pfx2_name = "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf"
	-- if HeroItems:UnitHasItem(caster, "ti7_immortal_armor.vmdl") then
	-- 	pfx1_name = "particles/econ/items/antimage/antimage_ti7/antimage_blink_start_ti7.vpcf"
	-- 	pfx2_name = "particles/econ/items/antimage/antimage_ti7/antimage_blink_ti7_end.vpcf"
	-- end

	local pfx1 = ParticleManager:CreateParticle(pfx1_name, PATTACH_CUSTOMORIGIN, hCaster)
	ParticleManager:SetParticleControl(pfx1, 0, hCaster:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(pfx1, 1, hCaster, PATTACH_CUSTOMORIGIN, "attach_hitloc", hCaster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlForward(pfx1, 0, direction)
	local distance = (vPos - hCaster:GetAbsOrigin()):Length2D()
	if distance <= max_dis then
		FindClearSpaceForUnit(hCaster, vPos, false)
	else
		vPos = hCaster:GetAbsOrigin() + direction * max_dis
		FindClearSpaceForUnit(hCaster, vPos, false)
	end
	local pfx2 = ParticleManager:CreateParticle(pfx2_name, PATTACH_POINT_FOLLOW, hCaster)
	ParticleManager:SetParticleControlEnt(pfx2, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetAbsOrigin(), true)

	ProjectileManager:ProjectileDodge(hCaster)
	ParticleManager:ReleaseParticleIndex(pfx1)
	ParticleManager:ReleaseParticleIndex(pfx2)
	EmitSoundOn("Hero_Antimage.Blink_in", hCaster )
	-- 套装效果
	local nDeputyBlink = hCaster:GetModifierStackCount("modifier_series_reward_deputy_blink", hCaster )
	if nDeputyBlink >= 3 then
		hCaster:AddNewModifier(hCaster, self, "modifier_archon_blink_effect", { duration = 3} ) 
	end

	-- 记录当前技能使用次数 
	BLINK_NUBER = BLINK_NUBER + 1
	hCaster:SetModifierStackCount( "modifier_archon_passive_shuttle", hCaster, BLINK_NUBER )
end

if modifier_archon_blink_effect == nil then modifier_archon_blink_effect = {} end
function modifier_archon_blink_effect:IsHidden() 
	return false
end
function modifier_archon_blink_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end
function modifier_archon_blink_effect:GetModifierAttackSpeedBonus_Constant()
	return 50
end

if modifier_archon_blink == nil then modifier_archon_blink = {} end
function modifier_archon_blink:IsHidden() return true end
function modifier_archon_blink:RemoveOnDeath() return false end
function modifier_archon_blink:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	} 
	return funcs
end
function modifier_archon_blink:CheckState()
	local state = {
		--[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}
	return state
end
function modifier_archon_blink:GetModifierAttackSpeedBonus_Constant() return 30 end

