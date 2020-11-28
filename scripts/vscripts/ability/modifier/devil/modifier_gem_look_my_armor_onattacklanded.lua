-- 解锁护甲神力 modifier_gem_look_my_armor_onattacklanded

if modifier_gem_look_my_armor_OnAttackLanded == nil then
	modifier_gem_look_my_armor_OnAttackLanded = class({})
end

function modifier_gem_look_my_armor_OnAttackLanded:IsHidden()
    return false
end

function modifier_gem_look_my_armor_OnAttackLanded:OnCreated(params)
   if IsServer() then 
        local hParent = self:GetParent()
        if hParent:HasModifier("modifier_gem_hujia_taozhuang") then 
            hParent:FindModifierByName("modifier_gem_hujia_taozhuang").look_my_armor_disabled = true
        end
    end
end

function modifier_gem_look_my_armor_OnAttackLanded:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_look_my_armor_OnAttackLanded:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_look_my_armor_OnAttackLanded:GetTexture()
    return "roudundefanji"
end

function modifier_gem_look_my_armor_OnAttackLanded:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_gem_look_my_armor_OnAttackLanded:OnAttackLanded(params)
    if params.attacker ~= self:GetParent() then
		return 0
	end

	local hParent = self:GetParent()
    local hTarget = params.target
    local chance = 10

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

    local all_damage = hParent:GetPhysicalArmorValue(false) * hParent:GetPhysicalArmorValue(false) * hParent:GetLevel() * 0.25
    ApplyDamage({
        victim = hTarget,
        attacker = hParent,
        damage = all_damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
    })
end