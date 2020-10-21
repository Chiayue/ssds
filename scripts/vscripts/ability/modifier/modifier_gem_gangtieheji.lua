if modifier_gem_gangtieheji == nil then
	modifier_gem_gangtieheji = class({})
end

function modifier_gem_gangtieheji:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
    return funcs
end

function modifier_gem_gangtieheji:IsHidden()
    if self:GetCaster():GetModifierStackCount( "modifier_gem_gangtieheji" , nil ) == 0 then
        return true
    else
        return false
    end
end

function modifier_gem_gangtieheji:OnCreated(params)
    self.attribute_promotion = 1600
    self.current_stack = 300
    
    self:StartIntervalThink(1)
end

function modifier_gem_gangtieheji:OnIntervalThink()
    if IsServer() then 
        local hCaster = self:GetCaster()
        if self.current_stack == 0 then
            self.attribute_promotion = 0
            self:StartIntervalThink(-1)
        else
            self.current_stack = self.current_stack - 1
            hCaster:SetModifierStackCount( "modifier_gem_gangtieheji", hCaster, self.current_stack )
        end
    end
end

--力量
function modifier_gem_gangtieheji:GetModifierBonusStats_Strength()
    return self.attribute_promotion
end

--智力
function modifier_gem_gangtieheji:GetModifierBonusStats_Intellect()
    return self.attribute_promotion
end

--敏捷
function modifier_gem_gangtieheji:GetModifierBonusStats_Agility()
    return self.attribute_promotion
end

function modifier_gem_gangtieheji:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_gangtieheji:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_gangtieheji:GetTexture(  )
    return "baowu/gangtieheji"
end