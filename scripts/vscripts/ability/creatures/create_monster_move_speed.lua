if create_monster_move_speed == nil then
	create_monster_move_speed = class({})
end

function create_monster_move_speed:GetIntrinsicModifierName()
	return "modifier_create_monster_move_speed"
end

--------------------------------------------------------------------------------

if modifier_create_monster_move_speed == nil then
	modifier_create_monster_move_speed = class({})
end

function modifier_create_monster_move_speed:IsHidden()
	return true
end

function modifier_create_monster_move_speed:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_create_monster_move_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,     --移动速度（百分比增加移动速度，自身不叠加）
    }
    return funcs
end

--移动速度（百分比增加移动速度，自身不叠加） 
function modifier_create_monster_move_speed:GetModifierMoveSpeedBonus_Percentage()
    if IsServer() then
        return GlobalVarFunc.duliuLevel * 2
    else
        local duliu_level = CustomNetTables:GetTableValue( "common", "greedy_level" )
        return duliu_level.greedy_level * 2
    end
end

function modifier_create_monster_move_speed:GetTexture()
    return "ancient_apparition_cold_feet"
end