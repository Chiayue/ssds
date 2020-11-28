-- 解锁生命神力 modifier_gem_look_my_health_OnAttackLanded

if modifier_gem_look_my_health_OnAttackLanded == nil then
	modifier_gem_look_my_health_OnAttackLanded = class({})
end

function modifier_gem_look_my_health_OnAttackLanded:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_look_my_health_OnAttackLanded:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_look_my_health_OnAttackLanded:GetTexture()
    return "xieniudefanji"
end

function modifier_gem_look_my_health_OnAttackLanded:IsHidden()
    return false
end

function modifier_gem_look_my_health_OnAttackLanded:OnCreated(params)
    if IsServer() then 
	    local hParent = self:GetParent()
        if hParent:HasModifier("modifier_gem_zhiliao_taozhuang") then 
            hParent:RemoveModifierByName("modifier_gem_zhiliao_taozhuang")
            hParent:RemoveModifierByName("modifier_gem_zhongzhiliao")
            hParent:RemoveModifierByName("modifier_gem_xiaozhiliao")
            hParent:RemoveModifierByName("modifier_gem_dazhiliao")
        end
    end
end

function modifier_gem_look_my_health_OnAttackLanded:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_gem_look_my_health_OnAttackLanded:OnAttackLanded(params)
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

    local all_damage = hParent:GetHealth() * 2
    --print("all_damage>>>>>>>>",all_damage)
    ApplyDamage({
        victim = hTarget,
        attacker = hParent,
        damage = all_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    })
end