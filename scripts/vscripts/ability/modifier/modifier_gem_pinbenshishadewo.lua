LinkLuaModifier("modifier_gem_pinbenshishadewo_effect", "ability/modifier/modifier_gem_pinbenshishadewo", LUA_MODIFIER_MOTION_NONE)

if modifier_gem_pinbenshishadewo == nil then modifier_gem_pinbenshishadewo = class({}) end
if modifier_gem_pinbenshishadewo_effect == nil then modifier_gem_pinbenshishadewo_effect = class({}) end

function modifier_gem_pinbenshishadewo:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
    return funcs
end

function modifier_gem_pinbenshishadewo:GetAttributes()
    return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_gem_pinbenshishadewo:IsHidden()
	return false
end

function modifier_gem_pinbenshishadewo:OnCreated()
    if not IsServer() then return end
end

function modifier_gem_pinbenshishadewo:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_pinbenshishadewo:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_pinbenshishadewo:GetTexture()
    return "baowu/pinbenshishadewo"
end

function modifier_gem_pinbenshishadewo:OnDeath(args)
    if not IsServer() then return end
    local hUnit = args.unit
    local hCaster = self:GetCaster()
    if hUnit ==  hCaster then
        self:IncrementStackCount()
    end
end
function modifier_gem_pinbenshishadewo:GetModifierBonusStats_Agility() return 40 * self:GetStackCount() end
function modifier_gem_pinbenshishadewo:GetModifierBonusStats_Intellect() return 40 * self:GetStackCount() end
function modifier_gem_pinbenshishadewo:GetModifierBonusStats_Strength() return 40 * self:GetStackCount() end

------------
