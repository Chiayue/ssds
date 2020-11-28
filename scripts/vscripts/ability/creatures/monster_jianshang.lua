if monster_jianshang == nil then
	monster_jianshang = class({})
end

function monster_jianshang:GetIntrinsicModifierName()
	return "modifier_monster_jianshang"
end

--减伤
LinkLuaModifier( "modifier_monster_jianshang", "ability/creatures/monster_jianshang.lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

if modifier_monster_jianshang == nil then
	modifier_monster_jianshang = class({})
end

function modifier_monster_jianshang:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    }
    return funcs
end

function modifier_monster_jianshang:IsHidden()
	return true
end

function modifier_monster_jianshang:GetModifierIncomingDamage_Percentage( params )
    if GlobalVarFunc.game_type == 1003 then
        if GlobalVarFunc.MonsterWave >= 50 then
            local damageAdd = (GlobalVarFunc.MonsterWave - 50) * 0.5
            if damageAdd >= 99 then
                damageAdd = 99
            end
            return -damageAdd
        end
    else
        if GlobalVarFunc.MonsterWave >= 600 then
            return -98
        elseif GlobalVarFunc.MonsterWave >= 500 then
            return -97
        elseif GlobalVarFunc.MonsterWave >= 400 then
            return -96
        elseif GlobalVarFunc.MonsterWave >= 300 then
            return -95
        elseif GlobalVarFunc.MonsterWave >= 100 then
            local damageAdd = (GlobalVarFunc.MonsterWave - 100) * 0.5 
            if damageAdd >= 94 then
                damageAdd = 94
            end
            return -damageAdd
        end
    end
end

function modifier_monster_jianshang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_monster_jianshang:RemoveOnDeath()
    return true -- 死亡移除
end

function modifier_monster_jianshang:GetTexture()
    return "rubick_arcane_supremacy"
end