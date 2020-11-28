LinkLuaModifier( "modifier_Upgrade_AttackSpeed", "ability/upgrade/Upgrade_AttackSpeed.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_MaxDamage", "ability/upgrade/Upgrade_MaxDamage.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_Range", "ability/upgrade/Upgrade_Range.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_Base_Attackspeed", "ability/upgrade/Upgrade_Base_Attackspeed.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_Upgrade_Armor", "ability/upgrade/Upgrade_Armor.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_MaxHeath", "ability/upgrade/Upgrade_MaxHeath.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_HeathRegen", "ability/upgrade/Upgrade_HeathRegen.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_bonusBase_vampiric", "ability/upgrade/Upgrade_bonusBase_vampiric.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_Upgrade_Physical_Critical", "ability/upgrade/Upgrade_Physical_Critical.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_Physical_Critical_Damage", "ability/upgrade/Upgrade_Physical_Critical_Damage.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_Magic_Critical", "ability/upgrade/Upgrade_Magic_Critical.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_Magic_Critical_Damage", "ability/upgrade/Upgrade_Magic_Critical_Damage.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_Upgrade_bonusBase_Str", "ability/upgrade/Upgrade_bonusBase_Str.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_bonusBase_Agi", "ability/upgrade/Upgrade_bonusBase_Agi.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_bonusBase_Int", "ability/upgrade/Upgrade_bonusBase_Int.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Upgrade_Kill_Bonus", "ability/upgrade/Upgrade_Kill_Bonus.lua",LUA_MODIFIER_MOTION_NONE )

LinkLuaModifier( "modifier_upgrade_ability_core", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_armor", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_as", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_damage", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_mana_regen", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_health_regen", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_ms", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_range", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_series_attr_exp", "ability/upgrade/upgrade_ability_core.lua",LUA_MODIFIER_MOTION_NONE )


if upgrade_ability_core == nil then upgrade_ability_core = {} end
function upgrade_ability_core:GetIntrinsicModifierName() return "modifier_upgrade_ability_core" end

if modifier_upgrade_ability_core == nil then modifier_upgrade_ability_core = {} end
function modifier_upgrade_ability_core:GetAttributes() return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_upgrade_ability_core:IsHidden() return true end
-- 属性加成叠加 -- 
function modifier_upgrade_ability_core:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE
	} 
	return funcs
end

function modifier_upgrade_ability_core:OnCreated()
	self.nBonusAgi = 0
	self.nBonusStr = 0
	self.nBonusInt = 0
	self.nBonusHealth = 0
	self.nBonusMana = 0
	self.nBonusArmor = 0
	self.nBonusDamage = 0
	self.nBonusAS = 0
	self.nRegenMana = 0
	self.nRegenHealth = 0
	self.nRange = 0
	self.nMoveSpeed = 0
	if IsServer() then
		self:StartIntervalThink(1)
	end
end

local nBonusDamage = 0
function modifier_upgrade_ability_core:OnIntervalThink()
	-- body
	if IsServer() then
		local hCaster = self:GetCaster()
		if hCaster:IsAlive()  then
			self:GetCaster():CalculateStatBonus()
			local nSagaBonus = 0
			local nMaxUpgradeAgi = 0
			local nMaxUpgradeStr = 0
			local nMaxUpgradeInt = 0
			local nHealthMaxUpgrade = 0
			local nHealthBonusEarth = 0
			-------------------------------
			--- 获存档装备
			local hSeriesItem = {}
			for i=0,5 do
				local hItem = hCaster:GetItemInSlot(i)
				if hItem ~= nil then
					if hItem:GetIntrinsicModifierName() == "modifier_item_series" then
						table.insert( hSeriesItem, hItem )
					end
				end
			end
			-- 统计属性
			local hAttrTable = {}
			for k,v in pairs(hSeriesItem) do
				for affix,amount in pairs(v.bonus.attr) do
					if hAttrTable[affix] == nil then
						hAttrTable[affix] = tonumber(amount)
					else
						hAttrTable[affix] = hAttrTable[affix] + amount
					end
				end 
			end
			-- DeepPrintTable( hAttrTable )
			local nItem_Agi = (hAttrTable["agi"] and hAttrTable["agi"] or 0) * 0.01 --+ (hAttrTable["all"] and hAttrTable["all"] or 0)
			local nItem_Str = (hAttrTable["str"] and hAttrTable["str"] or 0) * 0.01 --+ (hAttrTable["all"] and hAttrTable["all"] or 0)
			local nItem_Int = (hAttrTable["int"] and hAttrTable["int"] or 0) * 0.01 --+ (hAttrTable["all"] and hAttrTable["all"] or 0)
			local nBonus_all =(hAttrTable["all"] and hAttrTable["all"] or 0) * 0.01
			local nItem_Mana = hAttrTable["mana"] and hAttrTable["mana"] or 0
			local nItem_Health = hAttrTable["health"] and hAttrTable["health"] or 0
			local nItem_MaxHealth = (hAttrTable["mh"] and hAttrTable["mh"] or 0) * 0.01
			local nItem_AS = hAttrTable["as"] and hAttrTable["as"] or 0
			local nItem_Armor = hAttrTable["armor"] and hAttrTable["armor"] or 0
			local nItem_Damage = hAttrTable["damage"] and hAttrTable["damage"] or 0
			local nItem_ms = (hAttrTable["ms"] and hAttrTable["ms"] or 0)
			local nItem_range = (hAttrTable["range"] and hAttrTable["range"] or 0)
			local nItem_exp = (hAttrTable["exp"] and hAttrTable["exp"] or 0)
			------------------------------
			local nBonusAgiStack = hCaster:GetModifierStackCount("modifier_Upgrade_bonusBase_Agi",  hCaster)
			local nBonusStrStack = hCaster:GetModifierStackCount("modifier_Upgrade_bonusBase_Str",  hCaster)
			local nBonusIntStack = hCaster:GetModifierStackCount("modifier_Upgrade_bonusBase_Int",  hCaster)
			local nBonusHealthStack = hCaster:GetModifierStackCount("modifier_Upgrade_MaxHeath",  hCaster)
			
			local bHasEarthAbility = hCaster:FindAbilityByName("archon_passive_earth")
			local nAttrAgi = self:GetCaster():GetAgility() - self:GetModifierBonusStats_Agility()
			local nAttrStr = self:GetCaster():GetStrength() - self:GetModifierBonusStats_Strength()
			local nAttrInt = self:GetCaster():GetIntellect() - self:GetModifierBonusStats_Intellect()
			local nMaxHealth = self:GetCaster():GetMaxHealth() - self:GetModifierHealthBonus()
			----- 贤者之石
			local nSagaBonus = hCaster:GetModifierStackCount("modifier_store_reward_sage_stone",hCaster) * 0.1

			----- 科技
			if nBonusStrStack >= 10 then nMaxUpgradeStr = 0.3 end
			if nBonusAgiStack >= 10 then nMaxUpgradeAgi = 0.3 end
			if nBonusIntStack >= 10 then nMaxUpgradeInt = 0.3 end
			-- 大地
			if bHasEarthAbility ~= nil then 
				local nEarthLevel = bHasEarthAbility:GetLevel()
				if nEarthLevel >= ABILITY_AWAKEN_2 then
					nHealthBonusEarth = 1
				else
					nHealthBonusEarth = bHasEarthAbility:GetSpecialValueFor( "bonus_maxhealth" ) * 0.01 
				end
			end

			if nBonusHealthStack >= 10 then nHealthMaxUpgrade = 0.5 end
			----- 箭魂加成
			local nArrowSoulStack = hCaster:GetModifierStackCount("modifier_arrowSoul_meditation",  hCaster)
			if nArrowSoulStack >= 13 then nMaxUpgradeStr = nMaxUpgradeStr + 0.05 end
			if nArrowSoulStack >= 14 then nMaxUpgradeAgi = nMaxUpgradeAgi + 0.05 end
			if nArrowSoulStack >= 15 then nMaxUpgradeInt = nMaxUpgradeInt + 0.05 end
			if nArrowSoulStack >= 36 then nBonus_all = nBonus_all + 0.03 end

			-- 钻石会员
			local bHasVipDiamond = hCaster:GetModifierStackCount("modifier_store_reward_vip_diamond",hCaster) * 0.03
			nBonus_all = nBonus_all + bHasVipDiamond
			
			-- 神赐光环
			local bHasAuraGod = hCaster:GetModifierStackCount("modifier_store_reward_aura_god",hCaster) * 0.05
			nBonus_all = nBonus_all + bHasAuraGod
			
			-- 漆黑之翅
			local bHasDarkWings = hCaster:GetModifierStackCount("modifier_store_reward_dark_wings",hCaster) * 0.07
			nBonus_all = nBonus_all + bHasDarkWings

			-- 无双金龙
			local nHasGoldDargon = hCaster:GetModifierStackCount("modifier_store_reward_golden_dragon",hCaster) * 0.09
			nBonus_all = nBonus_all + nHasGoldDargon
			-- 定制buff
			local bHasCustomized = hCaster:GetModifierStackCount("modifier_customized_reward_attr_max_health",hCaster) * 0.01
			nHealthMaxUpgrade = nHealthMaxUpgrade + bHasCustomized
			-- 套装【战神】
			nMaxUpgradeStr = nMaxUpgradeStr + (hCaster:HasModifier("modifier_gem_god_left_hand") and 0.15 or 0)
			nMaxUpgradeStr = nMaxUpgradeStr + (hCaster:HasModifier("modifier_gem_god_hand") and 0.6 or 0)
			-- 套装【风神】
			nMaxUpgradeAgi = nMaxUpgradeAgi + (hCaster:HasModifier("modifier_gem_bow_of_aeolus") and 0.15 or 0)
			nMaxUpgradeAgi = nMaxUpgradeAgi + (hCaster:HasModifier("modifier_gem_power_of_aeolus") and 0.6 or 0)
			-- 套装【匠神】
			nMaxUpgradeInt = nMaxUpgradeInt + (hCaster:HasModifier("modifier_gem_blacksmith_left_wristbands") and 0.15 or 0)
			nMaxUpgradeInt = nMaxUpgradeInt + (hCaster:HasModifier("modifier_gem_blacksmith_power") and 0.6 or 0)
			nHealthMaxUpgrade = nHealthMaxUpgrade + (hCaster:HasModifier("modifier_gem_blacksmith_right_wristbands") and 0.15 or 0)
			nHealthMaxUpgrade = nHealthMaxUpgrade + (hCaster:HasModifier("modifier_gem_blacksmith_power") and 0.6 or 0)
			-- 黑暗大法师
			local bHasDevil = hCaster:HasModifier("modifier_gem_devilzhili") 
			if bHasDevil == true then nBonus_all = nBonus_all + 0.66 end
			--------  恶魔宝物
			nMaxUpgradeStr = nMaxUpgradeStr + (hCaster:HasModifier("modifier_gem_strength_explode_additional") and 1 or 0)
			nMaxUpgradeAgi = nMaxUpgradeAgi + (hCaster:HasModifier("modifier_gem_agility_explode_additional") and 1 or 0)
			nMaxUpgradeInt = nMaxUpgradeInt + (hCaster:HasModifier("modifier_gem_intelligence_explode_additional") and 1 or 0)
			nMaxUpgradeStr = nMaxUpgradeStr + (hCaster:HasModifier("modifier_gem_ares_meaning_additional_attr") and 0.2 or 0)
			nMaxUpgradeAgi = nMaxUpgradeAgi + (hCaster:HasModifier("modifier_gem_wind_howling_additional_attr") and 0.2 or 0)
			nMaxUpgradeInt = nMaxUpgradeInt + (hCaster:HasModifier("modifier_gem_as_divine_wrath_additional_attr") and 0.2 or 0)
			-- 全属性 10%
			local bHasDrinking = hCaster:HasModifier("modifier_gem_devil_drinking_blood_jian_of_soul_additional") 
			if bHasDrinking == true then nBonus_all = nBonus_all + 0.1 end
			local bHasDevil2 = hCaster:HasModifier("modifier_gem_ripple_devil_additional_attr") 
			if bHasDevil2 == true then nBonus_all = nBonus_all + 0.66 end
			local bHasStorage = hCaster:HasModifier("modifier_gem_super_storage_yellow_purple_additional_attr") 
			if bHasStorage == true then nBonus_all = nBonus_all + 0.3 end
			-- 死亡BUFF
			local nStackUndead = hCaster:GetModifierStackCount("modifier_gem_the_power_of_the_undead",hCaster) * 0.01
			if nStackUndead > 0 then
				nBonus_all = nBonus_all + nStackUndead
			end
			--- 计算
			self.nMoveSpeed = nItem_ms
			self.nBonusStr = math.floor( nAttrStr * (nSagaBonus + nMaxUpgradeStr + nItem_Str + nBonus_all ) )
			self.nBonusAgi = math.floor( nAttrAgi * (nSagaBonus + nMaxUpgradeAgi + nItem_Agi + nBonus_all ) )
			self.nBonusInt = math.floor( nAttrInt * (nSagaBonus + nMaxUpgradeInt + nItem_Int + nBonus_all ) )
			self.nBonusHealth = math.floor( nMaxHealth * (nHealthMaxUpgrade + nHealthBonusEarth + nItem_MaxHealth) )
			--self.nBonusMana = math.floor(nMaxMana * ( nItem_Mana * 0.01 ))
			self.nBonusArmor = nItem_Armor
			self.nBonusDamage = nItem_Damage
			self.nBonusAS = nItem_AS
			self.nRegenHealth = nItem_Health
			self.nRegenMana = nItem_Mana
			self.nRange = nItem_range
			-- 护甲
			local hModifierArmor = hCaster:FindModifierByName("modifier_series_attr_armor")
			if hModifierArmor == nil then hModifierArmor = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_armor", {}) end
			hModifierArmor:SetStackCount(self.nBonusArmor)
			-- 攻击力
			local hModifierDamage = hCaster:FindModifierByName("modifier_series_attr_damage")
			if hModifierDamage == nil then hModifierDamage = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_damage", {}) end
			hModifierDamage:SetStackCount(self.nBonusDamage)
			-- 攻击速度
			local hModifierAs = hCaster:FindModifierByName("modifier_series_attr_as")
			if hModifierAs == nil then hModifierAs = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_as", {}) end
			hModifierAs:SetStackCount(self.nBonusAS)
			-- 最大生命恢复
			local hModiRegHealth = hCaster:FindModifierByName("modifier_series_attr_health_regen")
			if hModiRegHealth == nil then hModiRegHealth = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_health_regen", {}) end
			hModiRegHealth:SetStackCount(self.nRegenHealth)
			-- 最大发力恢复
			local hModiRegMana = hCaster:FindModifierByName("modifier_series_attr_mana_regen")
			if hModiRegMana == nil then hModiRegMana = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_mana_regen", {}) end
			hModiRegMana:SetStackCount(self.nRegenMana)
			-- 射程
			local hModiRange = hCaster:FindModifierByName("modifier_series_attr_range")
			if hModiRange == nil then hModiRange = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_range", {}) end
			hModiRange:SetStackCount(self.nRange)
			-- 移动速度
			local hModiMs = hCaster:FindModifierByName("modifier_series_attr_ms")
			if hModiMs == nil then hModiMs = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_ms", {}) end
			hModiMs:SetStackCount(self.nMoveSpeed)
			-- 额外经验加成
			local hModiExp = hCaster:FindModifierByName("modifier_series_attr_exp")
			if hModiExp == nil then hModiExp = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_series_attr_exp", {}) end
			hModiExp:SetStackCount(nItem_exp)
		end
	end
end

-- function modifier_upgrade_ability_core:GetModifierTotalPercentageManaRegen() 
-- 	return self.nRegenMana
-- end

-- function modifier_upgrade_ability_core:GetModifierHealthRegenPercentage() 
-- 	return self.nRegenHealth
-- end

function modifier_upgrade_ability_core:GetModifierBonusStats_Strength() 
	return self.nBonusStr 
end

function modifier_upgrade_ability_core:GetModifierBonusStats_Intellect() 
	return self.nBonusInt 
end

-- function modifier_upgrade_ability_core:GetModifierPhysicalArmorBonus() 
-- 	return self.nBonusArmor 
-- end

function modifier_upgrade_ability_core:GetModifierBonusStats_Agility() 
	return self.nBonusAgi 
end

function modifier_upgrade_ability_core:GetModifierHealthBonus() 
	return self.nBonusHealth 
end

-- function modifier_upgrade_ability_core:GetModifierManaBonus() 
-- 	return self.nBonusMana 
-- end

if modifier_series_attr == nil then modifier_series_attr = {} end
function modifier_series_attr:GetAttributes() return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_series_attr:IsHidden() return true end
function modifier_series_attr:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	} 
	return funcs
end

if modifier_series_attr_armor == nil then modifier_series_attr_armor = class(modifier_series_attr) end
function modifier_series_attr_armor:GetModifierPhysicalArmorBonus()
	return self:GetStackCount()
end

if modifier_series_attr_as == nil then modifier_series_attr_as = class(modifier_series_attr) end
function modifier_series_attr_as:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount()
end

if modifier_series_attr_damage == nil then modifier_series_attr_damage = class(modifier_series_attr) end
function modifier_series_attr_damage:GetModifierBaseDamageOutgoing_Percentage()
	return self:GetStackCount()
end

if modifier_series_attr_mana_regen == nil then modifier_series_attr_mana_regen = class(modifier_series_attr) end
function modifier_series_attr_mana_regen:GetModifierTotalPercentageManaRegen() 
	return self:GetStackCount()
end

if modifier_series_attr_ms == nil then modifier_series_attr_ms = class(modifier_series_attr) end
function modifier_series_attr_ms:GetModifierMoveSpeedBonus_Constant() 
	return self:GetStackCount()
end
if modifier_series_attr_range == nil then modifier_series_attr_range = class(modifier_series_attr) end
function modifier_series_attr_range:GetModifierAttackRangeBonus() 
	return self:GetStackCount()
end
if modifier_series_attr_health_regen == nil then modifier_series_attr_health_regen = class(modifier_series_attr) end
function modifier_series_attr_health_regen:GetModifierHealthRegenPercentage() 
	return self:GetStackCount() * 0.1
end

if modifier_series_attr_exp == nil then modifier_series_attr_exp = class(modifier_series_attr) end