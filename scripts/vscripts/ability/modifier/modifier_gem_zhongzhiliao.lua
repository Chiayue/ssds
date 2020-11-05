if modifier_gem_zhongzhiliao == nil then
	modifier_gem_zhongzhiliao = class({})
end

function modifier_gem_zhongzhiliao:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE ,
    }
    return funcs
end

function modifier_gem_zhongzhiliao:IsHidden()
    if self:GetCaster():HasModifier( "modifier_gem_zhiliao_taozhuang" ) then
        return true
    else
        return false
    end
end

function modifier_gem_zhongzhiliao:OnCreated(params)
    self.health_regen = 1

    if IsServer() then
        local hero = self:GetParent()
        if hero:HasModifier("modifier_gem_xiaozhiliao") and hero:HasModifier("modifier_gem_dazhiliao") and not hero:HasModifier("modifier_gem_zhiliao_taozhuang") then
            hero:AddNewModifier( hero, self:GetAbility(), "modifier_gem_zhiliao_taozhuang", {} )
        end
    end
end

function modifier_gem_zhongzhiliao:GetModifierHealthRegenPercentage()
    return self.health_regen
end

function modifier_gem_zhongzhiliao:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_zhongzhiliao:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_zhongzhiliao:GetTexture()
    return "baowu/zhongzhiliao"
end