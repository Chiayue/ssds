if modifier_stop_move == nil then
	modifier_stop_move = class({})
end

function modifier_stop_move:IsHidden()
	return true
end

function modifier_stop_move:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_stop_move:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,     --移动速度（百分比增加移动速度，自身不叠加）
    }
    return funcs
end

--移动速度（百分比增加移动速度，自身不叠加） 
function modifier_stop_move:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
        return -100
    else
        return -100
    end
end

function modifier_stop_move:GetTexture()
    return "ancient_apparition_cold_feet"
end