if modifei_monster_movespeed == nil then
	modifei_monster_movespeed = class({})
end

function modifei_monster_movespeed:IsHidden()
	return true
end

function modifei_monster_movespeed:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifei_monster_movespeed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,     --移动速度（百分比增加移动速度，自身不叠加）
    }
    return funcs
end

--移动速度（百分比增加移动速度，自身不叠加） 
function modifei_monster_movespeed:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
        return 50
    else
        return 50
    end
end

function modifei_monster_movespeed:GetTexture()
    return "ancient_apparition_cold_feet"
end