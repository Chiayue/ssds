-- 亡灵低语 宝物效果持续5分钟，期间每死亡1次，全属性+1%，上限30次 modifier_gem_the_power_of_the_undead

if modifier_gem_the_power_of_the_undead == nil then
	modifier_gem_the_power_of_the_undead = class({})
end

function modifier_gem_the_power_of_the_undead:IsHidden()
    return false
end

function modifier_gem_the_power_of_the_undead:OnCreated(params)
    self.death_count = 0
    self:SetDuration( 300, true )
end

function modifier_gem_the_power_of_the_undead:OnRefresh(params)
    -- self:SetDuration( 300, true )
end

function modifier_gem_the_power_of_the_undead:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_the_power_of_the_undead:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_the_power_of_the_undead:GetTexture()
    return "wanglingdiyu"
end

function modifier_gem_the_power_of_the_undead:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
    }
    return funcs
end

function modifier_gem_the_power_of_the_undead:OnDeath(args)
    local hParent = self:GetParent()
    if hParent:IsAlive() == false and hParent:IsIllusion() == false and hParent:IsHero() then
        self.death_count = self.death_count + 1
        if self.death_count > 30 then 
            self.death_count = 30
        end
        hParent:SetModifierStackCount("modifier_gem_the_power_of_the_undead", hParent, self.death_count)
    end
end

function modifier_gem_the_power_of_the_undead:OnTooltip()
	if IsValidEntity(self:GetCaster()) then
		return self:GetParent():GetModifierStackCount("modifier_gem_the_power_of_the_undead", nil)
	end
	return 0
end