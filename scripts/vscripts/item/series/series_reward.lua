if modifier_series_reward_deputy == nil then modifier_series_reward_deputy = {} end
-- 副职基类
function modifier_series_reward_deputy:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_series_reward_deputy:IsHidden()  return true end
function modifier_series_reward_deputy:RemoveOnDeath() return false end
function modifier_series_reward_deputy:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end
-- 天赋基类
if modifier_series_reward_talent == nil then modifier_series_reward_talent = {} end
function modifier_series_reward_talent:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
function modifier_series_reward_talent:IsHidden()  return true end
function modifier_series_reward_talent:RemoveOnDeath() return false end
function modifier_series_reward_talent:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end
-------------------------------------------- S1 词缀 ----------------------------------
-------- S1副职
if modifier_series_reward_deputy_blink == nil then modifier_series_reward_deputy_blink = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_investment == nil then modifier_series_reward_deputy_investment = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_technology == nil then modifier_series_reward_deputy_technology = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_doctor == nil then modifier_series_reward_deputy_doctor = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_deputy_killer == nil then modifier_series_reward_deputy_killer = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_scavenging == nil then modifier_series_reward_deputy_scavenging = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_forging == nil then modifier_series_reward_deputy_forging = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_boxer == nil then modifier_series_reward_deputy_boxer = class(modifier_series_reward_deputy) end
if modifier_series_reward_deputy_idler == nil then modifier_series_reward_deputy_idler = class(modifier_series_reward_deputy) end

function modifier_series_reward_deputy_blink:GetTexture() return "antimage_blink" end
function modifier_series_reward_deputy_investment:GetTexture() return "alchemist_goblins_greed" end
function modifier_series_reward_deputy_technology:GetTexture() return "elder_titan_natural_order" end
function modifier_series_reward_deputy_doctor:GetTexture() return "deputy_doctor" end
-----------------------------------------------------
LinkLuaModifier("modifier_series_reward_deputy_doctor_effect", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
if modifier_series_reward_deputy_doctor_effect == nil then modifier_series_reward_deputy_doctor_effect = {} end
function modifier_series_reward_deputy_doctor_effect:GetTexture() return "dazzle_shallow_grave" end
function modifier_series_reward_deputy_doctor_effect:DeclareFunctions()
    local funcs = { 
	    MODIFIER_PROPERTY_MIN_HEALTH,
	    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
    return funcs
end
function modifier_series_reward_deputy_doctor_effect:OnCreated( params ) 
	local hParent = self:GetCaster()
	self.attr_str = hParent:GetStrength() * 0.1
	self.attr_agi = hParent:GetAgility() * 0.1
	self.attr_int = hParent:GetIntellect() * 0.1
end

function modifier_series_reward_deputy_doctor_effect:GetModifierBonusStats_Agility() return self.attr_agi end
function modifier_series_reward_deputy_doctor_effect:GetModifierBonusStats_Intellect() return self.attr_int end
function modifier_series_reward_deputy_doctor_effect:GetModifierBonusStats_Strength() return self.attr_str end
function modifier_series_reward_deputy_doctor_effect:GetMinHealth( params ) return 1 end
-----------------------------------------------------
function modifier_series_reward_deputy_killer:GetTexture() return "phantom_assassin_arcana_blur" end
function modifier_series_reward_deputy_scavenging:GetTexture() return "rubick_spell_steal" end
function modifier_series_reward_deputy_forging:GetTexture() return "earthshaker_fissure_alt_gold" end
-------- S1天赋词条
-- 光能
if modifier_series_reward_talent_light == nil then modifier_series_reward_talent_light = class(modifier_series_reward_talent) end
function modifier_series_reward_talent_light:GetTexture() return "archon_passive_light" end
function modifier_series_reward_talent_light:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
	local nStack = self:GetStackCount()
	if nStack >= 3 then self:StartIntervalThink( 8 ) else self:StartIntervalThink( -1 ) end
end
function modifier_series_reward_talent_light:OnIntervalThink()
	local hCaster = self:GetParent()
	local hAbility = self:GetAbility()
	if hCaster:HasAbility("archon_passive_light") or hCaster:HasAbility("archon_passive_fire") then
		hCaster:AddNewModifier(hCaster, hAbility, "modifier_series_reward_talent_light_effect",{ duration = 2})
	end
end
LinkLuaModifier("modifier_series_reward_talent_light_effect", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
if modifier_series_reward_talent_light_effect == nil then modifier_series_reward_talent_light_effect = {} end
function modifier_series_reward_talent_light_effect:IsHidden() return false end
function modifier_series_reward_talent_light_effect:GetTexture() return "archon_passive_light" end
function modifier_series_reward_talent_light_effect:GetEffectName() return "particles/econ/events/ti8/bottle_ti8.vpcf" end
function modifier_series_reward_talent_light_effect:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

-- 烈焰
if modifier_series_reward_talent_flame == nil then modifier_series_reward_talent_flame = class(modifier_series_reward_talent) end
function modifier_series_reward_talent_flame:GetTexture() return "archon_passive_fire" end
LinkLuaModifier("modifier_series_reward_talent_flame_effect", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
if modifier_series_reward_talent_flame_effect == nil then modifier_series_reward_talent_flame_effect = {} end
function modifier_series_reward_talent_flame_effect:IsHidden() return false end
function modifier_series_reward_talent_flame_effect:GetTexture() return "archon_passive_fire" end
function modifier_series_reward_talent_flame_effect:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(1)
end
function modifier_series_reward_talent_flame_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end
function modifier_series_reward_talent_flame_effect:OnTooltip()
	return self:GetStackCount() * 3
end
if modifier_series_reward_talent_clod == nil then modifier_series_reward_talent_clod = class(modifier_series_reward_talent) end
function modifier_series_reward_talent_clod:GetTexture() return "archon_passive_ice" end

if modifier_series_reward_talent_vitality == nil then modifier_series_reward_talent_vitality = class(modifier_series_reward_talent) end
function modifier_series_reward_talent_vitality:GetTexture() return "huixue" end
function modifier_series_reward_talent_vitality:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
	local nStack = self:GetStackCount()
	if nStack >= 3 then self:StartIntervalThink( 2 ) else self:StartIntervalThink( -1 ) end
end
function modifier_series_reward_talent_vitality:OnIntervalThink()
	local hCaster = self:GetParent() 
	-- 恢复最大5%和100%魔法值
	local nMaxMana = hCaster:GetMaxMana()
	hCaster:GiveMana(nMaxMana)
	local nMaxHealth = hCaster:GetMaxHealth()
	local nHealHealth = nMaxHealth * 0.05
	hCaster:Heal( nHealHealth, hCaster )
	local EffectName = "particles/econ/events/ti6/mekanism_ti6.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster)
end

if modifier_series_reward_talent_ruin == nil then modifier_series_reward_talent_ruin = class(modifier_series_reward_talent) end
function modifier_series_reward_talent_ruin:GetTexture() return "wulibaoji" end
-------------------------------------------- S1 词缀 END----------------------------------