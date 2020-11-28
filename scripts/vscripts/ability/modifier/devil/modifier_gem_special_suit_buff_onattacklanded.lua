-- 解锁法神领悟 凑齐BUFF套:10%概率对敌方造成自身全属性*个人等级*25%的魔法伤害 清除套装CD modifier_gem_special_suit_buff_OnAttackLanded

if modifier_gem_special_suit_buff_OnAttackLanded == nil then
	modifier_gem_special_suit_buff_OnAttackLanded = class({})
end

function modifier_gem_special_suit_buff_OnAttackLanded:IsHidden()
        return false
end

function modifier_gem_special_suit_buff_OnAttackLanded:OnCreated(params)
    if IsServer() then 
        self:StartIntervalThink(1)
    end
end

function modifier_gem_special_suit_buff_OnAttackLanded:OnIntervalThink(params)
    if not IsServer() then return end
    local hParent = self:GetParent()
    if hParent:HasModifier("modifier_gem_special_buff") then 
        hParent:RemoveModifierByName("modifier_gem_special_buff")
    end
end

function modifier_gem_special_suit_buff_OnAttackLanded:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_special_suit_buff_OnAttackLanded:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_special_suit_buff_OnAttackLanded:GetTexture()
    return "yuancishenguang"
end

function modifier_gem_special_suit_buff_OnAttackLanded:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_gem_special_suit_buff_OnAttackLanded:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then
		return 0
	end

	local hParent = self:GetParent()
    local hTarget = params.target
    local chance = 10

	local nowChance = RandomInt(0,100)

    local all_damage = ( hParent:GetStrength() + hParent:GetAgility() + hParent:GetIntellect() ) * hParent:GetLevel() * 0.25
    -- print("all_damage>>>>>>>>",all_damage)
    -- print("GetPhysicalArmorValue>>>>>>>>",hParent:GetStrength() + hParent:GetAgility() + hParent:GetIntellect())
    -- print("GetLevel>>>>>>>>",hParent:GetLevel())
    ApplyDamage({
        victim = hTarget,
        attacker = hParent,
        damage = all_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    })
end