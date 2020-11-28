-- 生命神力 每秒回血10% 攻击敌方造成【当前生命值*2】的魔法伤害 modifier_gem_look_my_health

if modifier_gem_look_my_health == nil then
	modifier_gem_look_my_health = class({})
end

function modifier_gem_look_my_health:IsHidden()
    if self:GetParent():HasModifier("modifier_gem_look_my_health_OnAttackLanded") then 
        return true
    else
        return false
    end
end

function modifier_gem_look_my_health:OnCreated(params)
    if IsServer() then 
        --self.health_gem_blacksmith_power = false
        self:StartIntervalThink(1)
    end
end

function modifier_gem_look_my_health:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE ,
    }
    return funcs
end

function modifier_gem_look_my_health:OnIntervalThink(params)
    if IsServer() then 
        local hParent = self:GetParent()
        
        if hParent:HasModifier("modifier_gem_zhiliao_taozhuang") and not hParent:HasModifier("modifier_gem_look_my_health_OnAttackLanded") then 
            hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_look_my_health_OnAttackLanded", {})
            --self.health_gem_blacksmith_power = true
            self:StartIntervalThink(-1)
        end
    end
end

function modifier_gem_look_my_health:GetModifierHealthRegenPercentage()
    return 10
end

function modifier_gem_look_my_health:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_look_my_health:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_look_my_health:GetTexture()
    return "shenmingshenli"
end

