if modifier_gem_hujia_taozhuang == nil then
	modifier_gem_hujia_taozhuang = class({})
end

function modifier_gem_hujia_taozhuang:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS ,
        MODIFIER_EVENT_ON_ATTACK_LANDED,   --攻击命中
    }
    return funcs
end

function modifier_gem_hujia_taozhuang:IsHidden()
	return false
end

function modifier_gem_hujia_taozhuang:OnCreated(params)
end

function modifier_gem_hujia_taozhuang:GetModifierPhysicalArmorBonus()
    return 100
end

--攻击
function modifier_gem_hujia_taozhuang:OnAttackLanded(kv)
	local hAttacker = kv.attacker   -- 攻击者	
	local units = kv.target   		-- 受害者   
    if units == self:GetParent() then
        if units:IsRealHero() then 
			ApplyDamage({
						ability = self,
						victim = hAttacker,
						attacker = units,
						damage = kv.damage * 0.2,
						damage_type = DAMAGE_TYPE_PURE,
					})
		end
	end
end

function modifier_gem_hujia_taozhuang:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_hujia_taozhuang:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_hujia_taozhuang:GetTexture()
    return "baowu/gem_hujia_taozhuang"
end