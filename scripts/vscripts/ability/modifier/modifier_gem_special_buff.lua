LinkLuaModifier("modifier_archon_passive_special_buff", "ability/modifier/modifier_gem_special_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_special_buff_all_damage", "ability/modifier/modifier_gem_special_buff", LUA_MODIFIER_MOTION_NONE)

if modifier_gem_special_buff == nil then 
    modifier_gem_special_buff = class({})
end

function modifier_gem_special_buff:IsHidden( ... )
	return false
end

function modifier_gem_special_buff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_special_buff:RemoveOnDeath()
    return false -- 死亡不移除
end

-- function modifier_gem_special_buff:GetTexture()
-- 	return "raging_fire_interrogate"
-- end

function modifier_gem_special_buff:OnCreated()
	local hParent = self:GetParent()  -- 不能添加本身的modifier名字
        if hParent:HasModifier("modifier_gem_die_venom") and 
            hParent:HasModifier("modifier_gem_earth_burst") and 
            hParent:HasModifier("modifier_gem_Ice_storm") and 
            hParent:HasModifier("modifier_gem_raging_fire_interrogate") and 
            hParent:HasModifier("modifier_gem_shadow_quiet") and 
            hParent:HasModifier("modifier_gem_void_lock")  and not 
            hParent:HasModifier("modifier_archon_passive_special_buff_all_damage") 
                then
                    hParent:AddNewModifier( hParent, self:GetAbility(), "modifier_archon_passive_special_buff_all_damage", {} )
                end
end

if modifier_archon_passive_special_buff_all_damage == nil then 
    modifier_archon_passive_special_buff_all_damage = class({})
end

function modifier_archon_passive_special_buff_all_damage:IsHidden( ... )
	return false
end

function modifier_archon_passive_special_buff_all_damage:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_special_buff_all_damage:RemoveOnDeath()
    return false -- 死亡不移除
end

-- function modifier_archon_passive_special_buff_all_damage:GetTexture()
-- 	return "raging_fire_interrogate"
-- end

function modifier_archon_passive_special_buff_all_damage:OnCreated()

end

function modifier_archon_passive_special_buff_all_damage:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_archon_passive_special_buff_all_damage:OnAttackLanded( params )
    if params.attacker ~= self:GetParent() then
		return 0
    end

    local hParent = self:GetParent()
    local hTarget = params.target
    local chance = 100

    local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
    end
    local all_damage = hParent:GetIntellect() + hParent:GetStrength() + hParent:GetAgility()
	ApplyDamage(
        victim = hTarget,
        attacker = hParent,
        damage = all_damage,
        damage_type = DAMAGE_TYPE_MAGICAL, 
        )
end