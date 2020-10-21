if ability_tianjue_challenge == nil then
	ability_tianjue_challenge = class({})
end
LinkLuaModifier("modifier_ability_tianjue_challenge","ability/challenge/ability_tianjue_challenge",LUA_MODIFIER_MOTION_NONE )

function ability_tianjue_challenge:GetIntrinsicModifierName()
	return "modifier_ability_tianjue_challenge"
end

--------------------------------------------------------------------------------

if modifier_ability_tianjue_challenge == nil then
	modifier_ability_tianjue_challenge = class({})
end

function modifier_ability_tianjue_challenge:IsHidden()
	return true
end

function modifier_ability_tianjue_challenge:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_ability_tianjue_challenge:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

-- function modifier_ability_tianjue_challenge:OnCreated( kv )
--     self.attack_speed = self:GetAbility():GetSpecialValueFor( "attack_speed" ) or 40
--     self.range_bonus = self:GetAbility():GetSpecialValueFor( "range_bonus" ) or 120
--     self.kill_reward = self:GetAbility():GetSpecialValueFor( "kill_reward" ) or 12
--     self.attribute_promotion = self:GetAbility():GetSpecialValueFor( "attribute_promotion" ) or 500
-- end

-- 攻速
function modifier_ability_tianjue_challenge:GetModifierAttackSpeedBonus_Constant()
    return 40
end

--射程
function modifier_ability_tianjue_challenge:GetModifierAttackRangeBonus()
	return 120
end

--金币奖励
function modifier_ability_tianjue_challenge:OnDeath(args)
	local nAttacker = args.attacker
	local nCaster = self:GetParent()
    if nAttacker == nCaster then
        local PlayerID = nAttacker:GetOwner():GetPlayerID()
        PlayerResource:ModifyGold(PlayerID,12,true,DOTA_ModifyGold_Unspecified)
        PopupGoldGain(nAttacker, 12)       
	end
end

--力量
function modifier_ability_tianjue_challenge:GetModifierBonusStats_Strength()
    return 500
end

--智力
function modifier_ability_tianjue_challenge:GetModifierBonusStats_Intellect()
    return 500
end

--敏捷
function modifier_ability_tianjue_challenge:GetModifierBonusStats_Agility()
    return 500
end