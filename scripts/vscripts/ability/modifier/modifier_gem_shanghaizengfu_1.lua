if modifier_gem_shanghaizengfu_1 == nil then
	modifier_gem_shanghaizengfu_1 = class({})
end

function modifier_gem_shanghaizengfu_1:DeclareFunctions()
    local funcs = {
    }
    return funcs
end

function modifier_gem_shanghaizengfu_1:IsHidden()
    if self:GetCaster():HasModifier( "modifier_gem_shanghaizengfu_taozhuang" ) then
        return true
    else
        return false
    end
end

function modifier_gem_shanghaizengfu_1:OnCreated(params)
    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_shanghaizengfu_2") and hero:HasModifier("modifier_gem_shanghaizengfu_3") and hero:HasModifier("modifier_gem_shanghaizengfu_4") and not hero:HasModifier("modifier_gem_shanghaizengfu_taozhuang") then
            hero:AddNewModifier( hero, self:GetAbility(), "modifier_gem_shanghaizengfu_taozhuang", {} )
        end
    end
end

function modifier_gem_shanghaizengfu_1:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shanghaizengfu_1:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shanghaizengfu_1:GetTexture()
    return "baowu/shanghaizengfu_1"
end