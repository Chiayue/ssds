LinkLuaModifier("modifier_store_reward_talent_bar", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_sage_stone", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_sage_stone_effect", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_technology_house", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_clearance_gifbag", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_vip_silver", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_vip_gold", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_vip_diamond", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_store_reward_aura_god", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_aura_god_effect", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)

-- LinkLuaModifier("modifier_store_reward_dark_wings", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_store_reward_dark_wings_effect", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_store_reward_arrow_infinite", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_arrow_infinite_effect", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_store_reward_golden_dragon", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_store_reward_golden_dragon_effect", "service/player_store_reward", LUA_MODIFIER_MOTION_NONE)
if PlayerStoreReward == nil then PlayerStoreReward = {} end

local sModiPrefix = "modifier_store_reward_"
local bIsHidden = true

-- 加载存档奖励



function PlayerStoreReward:OnStoreToggle(args)
	-- DeepPrintTable(args)
	local nPlayerID = args.PlayerID
	local CDOTAPlayer = PlayerResource:GetPlayer(nPlayerID)
    local hHero = CDOTAPlayer:GetAssignedHero()
    local hBonusAbility = hHero:FindAbilityByName("upgrade_ability_core")
    local sStoreName = args.goods_key
    local bShow = args.show
    local sEffectModi = "modifier_store_reward_"..sStoreName.."_effect"
    local sEffectArchive = "store_"..sStoreName.."_toggle"
    Archive:EditPlayerProfile(nPlayerID,sEffectArchive,bShow)
    CustomNetTables:SetTableValue("service", "player_archive", Archive:GetData())
    if bShow == 1 then
    	hHero:AddNewModifier(hHero, hBonusAbility, sEffectModi, {}) 
    else
    	hHero:RemoveModifierByName(sEffectModi)
    end

end

function PlayerStoreReward:Set(hHero,hCurrentStore)
	--print(type(hCurrentStore))
	if type(hCurrentStore) == "table"  then 
		local nPlayerID = hHero:GetPlayerID()
		local hArchive = Archive:GetData(nPlayerID)
		local hBonusAbility = hHero:FindAbilityByName("upgrade_ability_core")
	    if hBonusAbility == nil then
	        hBonusAbility = hHero:AddAbility("upgrade_ability_core")
	        hBonusAbility:SetLevel(1)
	    end
	    ----- 商品
	    hHero.Store = {}
		for sStoreName,nCounts in pairs(hCurrentStore) do
			local sToggleKey = "store_"..sStoreName.."_toggle"
			if sStoreName == "arrow_giftbag" then
				----------------
				-- 箭意礼包
				-- 初始全属性+10
				-- 初始木材+100
				----------------
				Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,10)
				Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,10)
				Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,10)
				Player_Data():AddPoint(nPlayerID,100)
			elseif sStoreName == "talent_bar" then
				----------------
				-- 天赋栏
				-- 解锁一个额外天赋 或者8级解锁
				-- 攻击速度+5%
				----------------
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			elseif sStoreName == "sage_stone" then
				----------------
				-- 贤者之石
				-- 获得贤者之石效果
				-- 全属性+5%
				-- 攻击速度+10%
				-- 物理暴力，法术暴击几率+3%
				----------------
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
				if hArchive[sToggleKey] ~= nil then
					if hArchive[sToggleKey] == 1 then
						hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName.."_effect", {}) 
					end
				else
					Archive:EditPlayerProfile(nPlayerID,sToggleKey,1)
				end
			elseif sStoreName == "technology_house" then
				----------------
				-- 科技屋
				-- 每次升级科技，返还15木材
				----------------
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			elseif sStoreName == "clearance_gifbag" then
				----------------
				-- 通关礼包
				-- 通关奖励+35%
				-- 初始金币+300
				----------------
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			elseif sStoreName == "vip_silver" then
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			elseif sStoreName == "vip_gold" then
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			elseif sStoreName == "vip_diamond" then
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			elseif sStoreName == "aura_god" then
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
				if hArchive[sToggleKey] ~= nil then
					if hArchive[sToggleKey] == 1 then
						hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName.."_effect", {}) 
					end
				else
					Archive:EditPlayerProfile(nPlayerID,sToggleKey,1)
				end
			-- elseif sStoreName == "dark_wings" then
			-- 	-- 开局获得一个宝物书<br>全属性+7%<br>最终伤害增加5%
			-- 	local baowu = hHero:AddItemByName("item_baowu_book_dark_wings")
			-- 	baowu:SetCurrentCharges(1)
			-- 	Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_STRENGTH,50)
			-- 	Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_AGILITY,50)
			-- 	Player_Data:AddBasebonus(hHero,DOTA_ATTRIBUTE_INTELLECT,50)
			-- 	hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
			-- 	if hArchive[sToggleKey] ~= nil then
			-- 		if hArchive[sToggleKey] == 1 then
			-- 			hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName.."_effect", {}) 
			-- 		end
			-- 	else
			-- 		Archive:EditPlayerProfile(nPlayerID,sToggleKey,1)
			-- 	end
			elseif sStoreName == "arrow_infinite" then
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
				if hArchive[sToggleKey] ~= nil then
					if hArchive[sToggleKey] == 1 then
						hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName.."_effect", {}) 
					end
				else
					Archive:EditPlayerProfile(nPlayerID,sToggleKey,1)
				end
			elseif sStoreName == "golden_dragon" then
				hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
				if hArchive[sToggleKey] ~= nil then
					if hArchive[sToggleKey] == 1 then
						hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName.."_effect", {}) 
					end
				else
					Archive:EditPlayerProfile(nPlayerID,sToggleKey,1)
				end
			end
		end

		----- 地图等级奖励
		local hMapsLevelReward = Store:GetGoodsFreeReward()
		
		local nLevel = GetPlayerMapLevel(hArchive["game_time"]) - 1
		local sArchiveAffix = "store_purchased_"
		for k,v in pairs(hMapsLevelReward) do
			if nLevel >= k then
				local sStoreName = v["key"]
				local bStack = v["stack"]
				local sArchiveLink = sArchiveAffix..sStoreName
				local bHasStore = hCurrentStore[sStoreName]
				if hArchive[sArchiveLink] == nil and bHasStore ~= nil then 
					local nRewardBonus = v["price"]
					if nRewardBonus ~= nil and bStack == 0 then
						Account:RewardMoney(nPlayerID,nRewardBonus,"地图等级达到"..nLevel.."且拥有"..sStoreName)
						Archive:SaveRowsToPlayer(nPlayerID,{[sArchiveLink] = 1})
					end
				end
				if bHasStore == nil or bStack == 1 then 
					hHero:AddNewModifier(hHero, hBonusAbility, sModiPrefix..sStoreName, {}) 
				end
			end
		end
	end
	
end

function PlayerStoreReward:CheckReward(nPlayerID,sReward)
	local hCurrentStore = Store:GetData(nPlayerID)
	for sStoreName,nCounts in pairs(hCurrentStore) do
		if sStoreName == sReward then
			return true
		end
	end 
	return false
end
---------- 特效基类 -------------
if modifier_store_reward_effect == nil then modifier_store_reward_effect = {} end
function modifier_store_reward_effect:IsHidden() return true end
function modifier_store_reward_effect:RemoveOnDeath() return false end
function modifier_store_reward_effect:GetAttributes()   
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
------------------------------------  奖励modifier  -----------------------------------
-- 奖励基类
if modifier_store_reward == nil then modifier_store_reward = {} end
function modifier_store_reward:GetAttributes()   
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT -- + MODIFIER_ATTRIBUTE_MULTIPLE 
end
function modifier_store_reward:IsHidden() return bIsHidden end
function modifier_store_reward:RemoveOnDeath() return false end
function modifier_store_reward:OnCreated() 
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_store_reward:OnRefresh() 
	if not IsServer() then return end
	self:IncrementStackCount()
end
----------- 天赋栏 -----------
if modifier_store_reward_talent_bar == nil then modifier_store_reward_talent_bar = class(modifier_store_reward) end
function modifier_store_reward_talent_bar:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_store_reward_talent_bar:GetModifierAttackSpeedBonus_Constant() return 5 end

-- 贤者之石
if modifier_store_reward_sage_stone == nil then modifier_store_reward_sage_stone = class(modifier_store_reward) end
function modifier_store_reward_sage_stone:OnCreated() 
	if not IsServer() then return end
	self:IncrementStackCount()
	local hCaster = self:GetParent()
end

function modifier_store_reward_sage_stone:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	} 
	return funcs
end
function modifier_store_reward_sage_stone:GetModifierAttackSpeedBonus_Constant() return 10 * self:GetStackCount() end
-- 对应特效
if modifier_store_reward_sage_stone_effect == nil then modifier_store_reward_sage_stone_effect = class(modifier_store_reward_effect) end
function modifier_store_reward_sage_stone_effect:GetEffectName()
	return "particles/econ/courier/courier_cluckles/patchouli_sorcererstone.vpcf"
end
function modifier_store_reward_sage_stone_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
---------------------------------------------------------------------
-- 科技屋
if modifier_store_reward_technology_house == nil then modifier_store_reward_technology_house = class(modifier_store_reward) end

-- 通关礼包
if modifier_store_reward_clearance_gifbag == nil then modifier_store_reward_clearance_gifbag = class(modifier_store_reward) end
function modifier_store_reward_clearance_gifbag:OnCreated( args )
	if not IsServer() then return end
	-- print("modifier_store_reward_clearance_gifbag OnCreated")
	local nPlayerID = self:GetParent():GetPlayerID()
	PlayerResource:ModifyGold(nPlayerID,300,true,DOTA_ModifyGold_Unspecified)
end
----------- 白银会员 -----------
if modifier_store_reward_vip_silver == nil then modifier_store_reward_vip_silver = class(modifier_store_reward) end
function modifier_store_reward_vip_silver:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_BONUS
	} 
	return funcs
end
function modifier_store_reward_vip_silver:GetModifierPhysicalArmorBonus() return 5 end
function modifier_store_reward_vip_silver:GetModifierConstantHealthRegen() return 20 end
function modifier_store_reward_vip_silver:GetModifierHealthBonus() return 300 end

----------- 黄金会员 -----------
if modifier_store_reward_vip_gold == nil then modifier_store_reward_vip_gold = class(modifier_store_reward) end
function modifier_store_reward_vip_gold:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
	} 
	return funcs
end
function modifier_store_reward_vip_gold:GetModifierBonusStats_Agility() return 25 end
function modifier_store_reward_vip_gold:GetModifierBonusStats_Intellect() return 25 end
function modifier_store_reward_vip_gold:GetModifierBonusStats_Strength() return 25 end
function modifier_store_reward_vip_gold:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nPlayerID = hCaster:GetPlayerID()
	PlayerResource:ModifyGold(nPlayerID,2,true,DOTA_ModifyGold_CreepKill)
	PopupGoldGain(hCaster, 2)
end
----------- 钻石会员 -----------
if modifier_store_reward_vip_diamond == nil then modifier_store_reward_vip_diamond = class(modifier_store_reward) end

function modifier_store_reward_vip_diamond:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_EVENT_ON_DEATH,
	} 
	return funcs
end
function modifier_store_reward_vip_diamond:GetModifierBonusStats_Agility() return 15 * self:GetStackCount() end
function modifier_store_reward_vip_diamond:GetModifierBonusStats_Intellect() return 15 * self:GetStackCount() end
function modifier_store_reward_vip_diamond:GetModifierBonusStats_Strength() return 15 * self:GetStackCount() end
function modifier_store_reward_vip_diamond:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nPlayerID = hCaster:GetPlayerID()
	PlayerResource:ModifyGold(nPlayerID,1,true,DOTA_ModifyGold_CreepKill)
	PopupGoldGain(hCaster, 1)
end
----------- 神赐光环 -----------
if modifier_store_reward_aura_god == nil then modifier_store_reward_aura_god = class(modifier_store_reward) end
function modifier_store_reward_aura_god:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
    }
end
function modifier_store_reward_aura_god:GetModifierIncomingDamage_Percentage(keys) return -10 * self:GetStackCount() end
-- 对应特效
if modifier_store_reward_aura_god_effect == nil then modifier_store_reward_aura_god_effect = class(modifier_store_reward_effect) end
function modifier_store_reward_aura_god_effect:GetEffectName()
	return "particles/ambient/ambient1.vpcf"
end

----------- 神箭无极 -----------
if modifier_store_reward_arrow_infinite == nil then modifier_store_reward_arrow_infinite = class(modifier_store_reward) end
function modifier_store_reward_arrow_infinite:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end
function modifier_store_reward_arrow_infinite:GetModifierMoveSpeedBonus_Constant() return 50 * self:GetStackCount() end
function modifier_store_reward_arrow_infinite:GetModifierBonusStats_Agility() return 30 * self:GetStackCount() end
function modifier_store_reward_arrow_infinite:GetModifierBonusStats_Intellect() return 30 * self:GetStackCount() end
function modifier_store_reward_arrow_infinite:GetModifierBonusStats_Strength() return 30 * self:GetStackCount() end
function modifier_store_reward_arrow_infinite:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	local nBonus = 3 * self:GetStackCount()
	local nPlayerID = hCaster:GetPlayerID()
	PlayerResource:ModifyGold(nPlayerID,nBonus,true,DOTA_ModifyGold_CreepKill)
	PopupGoldGain(hCaster, nBonus)
end
-- 对应特效
if modifier_store_reward_arrow_infinite_effect == nil then modifier_store_reward_arrow_infinite_effect = class(modifier_store_reward_effect) end
function modifier_store_reward_arrow_infinite_effect:OnCreated() 
	self.nFXIndex = ParticleManager:CreateParticle("particles/diy_particles/ambient5.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
end

function modifier_store_reward_arrow_infinite_effect:OnDestroy() 
	ParticleManager:DestroyParticle(self.nFXIndex,true)
end

----------- 无双金龙 -----------
if modifier_store_reward_golden_dragon  == nil then modifier_store_reward_golden_dragon = class(modifier_store_reward) end
function modifier_store_reward_golden_dragon:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_store_reward_golden_dragon:GetModifierBonusStats_Agility() return 15 * self:GetStackCount() end
function modifier_store_reward_golden_dragon:GetModifierBonusStats_Intellect() return 15 * self:GetStackCount() end
function modifier_store_reward_golden_dragon:GetModifierBonusStats_Strength() return 15 * self:GetStackCount() end
-- 对应特效
if modifier_store_reward_golden_dragon_effect == nil then modifier_store_reward_golden_dragon_effect = class(modifier_store_reward_effect) end
function modifier_store_reward_golden_dragon_effect:OnCreated() 
	self.nFXIndex = ParticleManager:CreateParticle("particles/diy_particles/ambient12.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_store_reward_golden_dragon_effect:OnDestroy() 
	ParticleManager:DestroyParticle(self.nFXIndex,true)
end


