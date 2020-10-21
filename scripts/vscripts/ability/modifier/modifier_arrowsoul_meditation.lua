if modifier_arrowSoul_meditation == nil then
	modifier_arrowSoul_meditation = class({})
end

function modifier_arrowSoul_meditation:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH ,   --死亡
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS ,   --力量
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS ,    --智力
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS ,      --敏捷
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ,     --护甲
        MODIFIER_PROPERTY_HEALTH_BONUS ,            --生命值
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT ,     --攻击速度
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS ,         --射程
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT ,      --生命回复（固定值）
        MODIFIER_EVENT_ON_ATTACKED ,        --攻击
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE ,     --攻击力
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,     --移动速度（百分比增加移动速度，自身不叠加）
    }
    return funcs
end

function modifier_arrowSoul_meditation:IsHidden()
	return true
end

function modifier_arrowSoul_meditation:OnCreated(params)
    self:StartIntervalThink(1)
end

function modifier_arrowSoul_meditation:OnIntervalThink()

    if IsServer() then
        
        if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 28 then
            local nCaster = self:GetParent()
            local PlayerID = nCaster:GetOwner():GetPlayerID()
            PlayerResource:ModifyGold(PlayerID,3,true,DOTA_ModifyGold_Unspecified)
            PopupGoldGain(nCaster, 3)
        end

    end
    
	self:StartIntervalThink(1)
end

--力量
function modifier_arrowSoul_meditation:GetModifierBonusStats_Strength()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 35 then
        return 45
    elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 1 then
        return 15
    end
end

--智力
function modifier_arrowSoul_meditation:GetModifierBonusStats_Intellect()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 35 then
        return 45
    elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 3 then
        return 15
    end
end

--敏捷
function modifier_arrowSoul_meditation:GetModifierBonusStats_Agility()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 35 then
        return 45
    elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 2 then
        return 15
    end
end

--护甲
function modifier_arrowSoul_meditation:GetModifierPhysicalArmorBonus()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 26 then
        return 13
    elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 5 then
        return 3
    end
end

--生命值
function modifier_arrowSoul_meditation:GetModifierHealthBonus()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 6 then
        return 200
    end
end

--攻击速度
function modifier_arrowSoul_meditation:GetModifierAttackSpeedBonus_Constant()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 21 then
        return 25
    elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 8 then
        return 10
    end
end

--杀怪金币奖励
function modifier_arrowSoul_meditation:OnDeath(args)
    local gold = 0
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 19 then
        gold = 3
    elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 9 then
        gold = 1
    end

    local nAttacker = args.attacker
	local nCaster = self:GetParent()
    if nAttacker == nCaster then
        local PlayerID = nAttacker:GetOwner():GetPlayerID()
        PlayerResource:ModifyGold(PlayerID,gold,true,DOTA_ModifyGold_Unspecified)
        PopupGoldGain(nAttacker, gold)
	end
end

--射程
function modifier_arrowSoul_meditation:GetModifierAttackRangeBonus()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 20 then
        return 80
	elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 10 then
        return 30
    end
end

--生命回复（固定值）
function modifier_arrowSoul_meditation:GetModifierConstantHealthRegen()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 27 then
        return 50
	elseif self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 11 then
        return 10
    end
end

--攻击
function modifier_arrowSoul_meditation:OnAttacked(args)
    --攻击治疗
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 12 then
        if IsServer() then
            if args.attacker ~= self:GetParent() then
                return 0
            end
            local hAttacker = args.attacker
            local nHeal = 3
            hAttacker:Heal( nHeal, hAttacker )
        end
    end
end

--攻击力 +5%
function modifier_arrowSoul_meditation:GetModifierDamageOutgoing_Percentage()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 16 then
        return 5
    end
end

--移动速度（百分比增加移动速度，自身不叠加） +5%  （20点移动速度）
function modifier_arrowSoul_meditation:GetModifierMoveSpeedBonus_Percentage()
    if self:GetParent():GetModifierStackCount( "modifier_arrowSoul_meditation" , nil ) >= 34 then
        return 5
    end
end

function modifier_arrowSoul_meditation:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_arrowSoul_meditation:RemoveOnDeath()
    return false -- 死亡不移除
end

