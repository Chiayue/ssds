--------- 正面减伤
LinkLuaModifier("modifier_ability_boss_bulwark", "autistic/ability_boss_bulwark", LUA_MODIFIER_MOTION_NONE)
ability_boss_bulwark = {}
function ability_boss_bulwark:GetIntrinsicModifierName()
	return "modifier_ability_boss_bulwark"
end

modifier_ability_boss_bulwark = {}
function modifier_ability_boss_bulwark:IsHidden() return true end
function modifier_ability_boss_bulwark:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(60)
end

----------  幽冥突袭
LinkLuaModifier("modifier_ability_boss_strike", "autistic/ability_boss_bulwark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_boss_strike_debuff", "autistic/ability_boss_bulwark", LUA_MODIFIER_MOTION_NONE)
ability_boss_strike = {}
function ability_boss_strike:GetIntrinsicModifierName()
	return "modifier_ability_boss_strike"
end

modifier_ability_boss_strike = {}
function modifier_ability_boss_strike:IsHidden() return true end
function modifier_ability_boss_strike:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_ability_boss_strike:OnTakeDamage( keys )
	if keys.unit == self:GetParent() then
		local distance = ( keys.attacker:GetAbsOrigin() - keys.unit:GetAbsOrigin()):Length()
		if distance > 1000 and self:GetAbility():IsCooldownReady() then
			local hParent = self:GetParent()
			self:GetAbility():UseResources(true, true, true)
			local nEndParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_end.vpcf", PATTACH_ABSORIGIN, hParent)
			ParticleManager:ReleaseParticleIndex(nEndParticle)
			local nStartParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_begin.vpcf", PATTACH_ABSORIGIN, hParent)
			FindClearSpaceForUnit(hParent, keys.attacker:GetAbsOrigin() + ((keys.attacker:GetAbsOrigin() - hParent:GetAbsOrigin()):Normalized() * (54)), false)
			ProjectileManager:ProjectileDodge(hParent)
			ParticleManager:SetParticleControl(nStartParticle, 2, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(nStartParticle)

			hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_ability_boss_strike_debuff", { duration = 0.5} )
		end
	end
end

modifier_ability_boss_strike_debuff = {}
function modifier_ability_boss_strike_debuff:IsHidden() return true end
function modifier_ability_boss_strike_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE]	= true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		-- [MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_STUNNED] = true,
		-- [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		-- [MODIFIER_STATE_ATTACK_IMMUNE] = true,
		-- [MODIFIER_STATE_MAGIC_IMMUNE] = true,
		-- [MODIFIER_STATE_SILENCED] = true,
	}
	return state
end

function modifier_ability_boss_strike_debuff:OnDestroy()
	local nEndParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_nether_strike_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:ReleaseParticleIndex(nEndParticle)
end