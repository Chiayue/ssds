-- 残败圣剑 物理爆伤+50% 移除残败之刃-20%物爆几率负面效果，物理爆伤+300% modifier_gem_falling_of_sword

if modifier_gem_falling_of_sword == nil then
	modifier_gem_falling_of_sword = class({})
end

function modifier_gem_falling_of_sword:IsHidden()
    if self:GetParent():HasModifier( "modifier_gem_falling_of_sword_additional" ) then
        return true
    else
        return false
    end
end

function modifier_gem_falling_of_sword:OnCreated(params)
    if not IsServer() then return end 
    self:StartIntervalThink(1)
end

function modifier_gem_falling_of_sword:OnIntervalThink()
    if not IsServer() then return end 
    local hParent = self:GetParent()

    if hParent:HasModifier("modifier_gem_canbaizhiren") and not hParent:HasModifier("modifier_gem_falling_of_sword_additional") then
        hParent:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_falling_of_sword_additional", {})
        hParent:RemoveModifierByName("modifier_gem_canbaizhiren")
        hParent:RemoveModifierByName("modifier_gem_falling_of_sword")
        self:StartIntervalThink(-1)
    end
end

function modifier_gem_falling_of_sword:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_falling_of_sword:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_falling_of_sword:GetTexture()
    return "canbaishengjian"
end

function modifier_gem_falling_of_sword:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_gem_falling_of_sword:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then
		return 0
	end

	local hParent = self:GetParent()
    local hTarget = params.target
    local chance = 100

	local nowChance = RandomInt(0,100)

    local all_damage = hParent:GetPhysicalArmorValue(false) * hParent:GetPhysicalArmorValue(false) * hParent:GetLevel() * 0.05
    -- print("all_damage>>>>>>>>",all_damage)
    -- print("GetPhysicalArmorValue>>>>>>>>",hParent:GetPhysicalArmorValue(false))
    -- print("GetLevel>>>>>>>>",hParent:GetLevel())
    ApplyDamage({
        victim = hTarget,
        attacker = hParent,
        damage = all_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    })
end