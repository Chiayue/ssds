if modifier_gem_zhiliao_taozhuang == nil then
	modifier_gem_zhiliao_taozhuang = class({})
end

function modifier_gem_zhiliao_taozhuang:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,  --减伤
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,   --回血百分比
        MODIFIER_EVENT_ON_ATTACK_LANDED,     
    }
    return funcs
end

function modifier_gem_zhiliao_taozhuang:IsHidden()
	return false
end

--减伤
function modifier_gem_zhiliao_taozhuang:GetModifierIncomingDamage_Percentage( params )
	return -50
end

--回血百分比
function modifier_gem_zhiliao_taozhuang:GetModifierHealthRegenPercentage()
    return 10
end

--攻击
function modifier_gem_zhiliao_taozhuang:OnAttackLanded(kv)
	local hAttacker = kv.attacker   -- 攻击者	
	local hTarget = kv.target   		-- 受害者   
	if hTarget == self:GetParent() then
		ApplyDamage({
			ability = self,
			victim = hAttacker,
			attacker = hTarget,
			damage = hTarget:GetHealth() * 10,
			damage_type = DAMAGE_TYPE_MAGICAL,
		})

	end
end

function modifier_gem_zhiliao_taozhuang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_zhiliao_taozhuang:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_zhiliao_taozhuang:GetTexture()
    return "baowu/zhiliao_taozhuang"
end