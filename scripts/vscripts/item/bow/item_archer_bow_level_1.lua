LinkLuaModifier("modifier_item_archer_bow", "item/bow/item_archer_bow_level_1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_archer_bow_multe", "item/bow/item_archer_bow_level_1", LUA_MODIFIER_MOTION_NONE)
local hBowList = {
	"item_archer_bow_level_1",
	"item_archer_bow_level_2",
}

local hBowUpgradeInfo = {
	item_archer_bow_level_1 = {
		cost = 1000,
		next = "item_archer_bow_level_2"
	},
	item_archer_bow_level_2 = {
		cost = 4000,
		next = "item_archer_bow_level_3"
	},
	item_archer_bow_level_3 = {
		cost = 16000,
		next = "item_archer_bow_level_4"
	},
	item_archer_bow_level_4 = {
		cost = 64000,
		next = "item_archer_bow_level_5"
	},
}

if item_archer_bow_class == nil then 
	item_archer_bow_class = class({})
end

function item_archer_bow_class:OnSpellStart() 
	local nLevel = self:GetLevel()
	local sItemName = self:GetAbilityName()
	local hCaster = self:GetCaster()
	local nPlayerID = self:GetCaster():GetPlayerID()
	local hUpgradeInfo = hBowUpgradeInfo[sItemName]
	if hUpgradeInfo == nil then return end
	-- print("Used Item Level",nLevel," ",sItemName," Playerid:",nPlayerID)
	if IsInToolsMode() then
		hCaster:TakeItem(self)
		hCaster:AddItemByName(hUpgradeInfo.next)
		return 
	end
	if nLevel == 6 then
		local nNowCost = PlayerResource:GetGold(nPlayerID)
		
		if hUpgradeInfo ~= nil then
			if nNowCost >= hUpgradeInfo.cost then
				PlayerResource:SpendGold(nPlayerID,hUpgradeInfo.cost,DOTA_ModifyGold_PurchaseItem)
				hCaster:TakeItem(self)
				hCaster:AddItemByName(hUpgradeInfo.next)
			else
				--print("cost is bugou")
				local message = "金币不足，需要:"..tostring(hUpgradeInfo.cost)
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message=message})
			end
		else
			--print("bow is max")
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="已达到最高等级"})
		end
	else
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="需要弓箭等级达到6级"})
		--print("level need 6")
	end


end

function item_archer_bow_class:GetItemName(hCaster,sItemName)
	for i = 0, 5 do
		local hItem = hCaster:GetItemInSlot(i)
		local sSlotItemName = hItem:GetAbilityName()
		if sSlotItemName == sItemName then
			return hItem
		end
	end
	return nil
end


function item_archer_bow_class:GetIntrinsicModifierName()
	return "modifier_item_archer_bow"
end

if item_archer_bow_level_1 == nil then item_archer_bow_level_1 = class(item_archer_bow_class) end
if item_archer_bow_level_2 == nil then item_archer_bow_level_2 = class(item_archer_bow_class) end
if item_archer_bow_level_3 == nil then item_archer_bow_level_3 = class(item_archer_bow_class) end
if item_archer_bow_level_4 == nil then item_archer_bow_level_4 = class(item_archer_bow_class) end
if item_archer_bow_level_5 == nil then item_archer_bow_level_5 = class(item_archer_bow_class) end

-------------- 通用的Modifier ----------
if modifier_item_archer_bow == nil then 
	modifier_item_archer_bow = class({})
end

function modifier_item_archer_bow:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_item_archer_bow:IsHidden()
	return false
end

function modifier_item_archer_bow:OnCreated()
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.bonus_attackspeed = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
	self.bonus_multiple_chance = self:GetAbility():GetSpecialValueFor( "bonus_multiple_chance" )
	self.limit_soul = self:GetAbility():GetSpecialValueFor( "limit_soul" )
	self.limit_soul_max = self:GetAbility():GetSpecialValueFor( "limit_soul_max" )
	self.limit_soul_max_damage = self:GetAbility():GetSpecialValueFor( "limit_soul_max_damage" )
	self.reward_damage = self:GetAbility():GetSpecialValueFor( "reward_damage" )
	local nLevel = self:GetAbility():GetLevel()
	self:SetStackCount( nLevel )
end

function modifier_item_archer_bow:OnRefresh()
	self.bonus_range = self:GetAbility():GetSpecialValueFor( "bonus_range" )
	self.bonus_damage = self:GetAbility():GetSpecialValueFor( "bonus_damage" )
	self.bonus_attackspeed = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
	self.bonus_multiple_chance = self:GetAbility():GetSpecialValueFor( "bonus_multiple_chance" )
	self.limit_soul = self:GetAbility():GetSpecialValueFor( "limit_soul" )
	self.limit_soul_max = self:GetAbility():GetSpecialValueFor( "limit_soul_max" )
	self.limit_soul_max_damage = self:GetAbility():GetSpecialValueFor( "limit_soul_max_damage" )
	self.reward_damage = self:GetAbility():GetSpecialValueFor( "reward_damage" )
	local nLevel = self:GetAbility():GetLevel()
	self:SetStackCount( nLevel )
	local nMaxLevel = 6
	if nLevel >= nMaxLevel then
		local nNowCharges = self:GetAbility():GetCurrentCharges()
		self.bonus_damage  = self.bonus_damage + (nNowCharges + 1) * self.limit_soul_max_damage
	end
end

function modifier_item_archer_bow:OnAttack(params)
	if IsServer() then
		if params.attacker ~= self:GetParent() then
			return 0
		end
		-- local projectname = params.attacker:GetRangedProjectileName()
		-- print(projectname)
		local nowChance = RandomInt(0,100)
		local nBonusChance = 0
		local hRageAbility = params.attacker:FindAbilityByName("archon_passive_rage")
		if hRageAbility ~= nil then
			local nLevel = hRageAbility:GetLevel()
			if nLevel >= ABILITY_AWAKEN_2 then
				nBonusChance = hRageAbility:GetSpecialValueFor( "bonus_lv7" )
			elseif nLevel >= ABILITY_AWAKEN_1 then
				nBonusChance = hRageAbility:GetSpecialValueFor( "bonus_lv4" )
			end
		end
		local nTotal = self.bonus_multiple_chance + nBonusChance
		if nowChance  > nTotal then
			return 0
		end
		local nTechRange = 0
		local hCaster = self:GetCaster()
		local nBaseAttackRange =  hCaster:GetBaseAttackRange()
		local nAttackRangeBonus =  self:GetModifierAttackRangeBonus()
		local hTeahRange = self:GetCaster():FindModifierByName("modifier_Upgrade_Range")
		if hTeahRange ~= nil then
			nTechRange = hTeahRange:GetModifierAttackRangeBonus()
		end
		local nAoeRadius = nBaseAttackRange + nAttackRangeBonus + nTechRange
		self:GetAbility().HitTarget = params.target
		self:GetAbility().AoeRadius = nAoeRadius
		
		hCaster:AddNewModifier( 
			self:GetCaster(), 
			self:GetAbility(), 
			"modifier_item_archer_bow_multe", 
			{ duration = 1} 
		)

		
	end
end

function modifier_item_archer_bow:OnDeath(params)
	-- body
	local hCaster = self:GetCaster()
	local hAttacker = params.attacker
	-- local hParent = self:GetParent()
	-- print(hCaster)
	-- print(hAttacker)
	-- print(hParent)
	if hAttacker ~= hCaster then
		return
	end
	local hItem = self:GetAbility()
	local nMaxLevel = hItem:GetMaxLevel()
	local nLevel =  hItem:GetLevel()
	local nNowCharges = hItem:GetCurrentCharges()
	if nLevel < nMaxLevel then
		if nNowCharges < self.limit_soul - 1 then
			hItem:SetCurrentCharges(nNowCharges + 1)
		else
			hItem:SetCurrentCharges(0)
			hItem:SetLevel(nLevel +1)
			self:ForceRefresh()
		end
	else
		if nNowCharges < self.limit_soul_max then
			hItem:SetCurrentCharges(nNowCharges + 1)
			self:ForceRefresh()
		end

	end
end

function modifier_item_archer_bow:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_archer_bow:GetModifierAttackRangeBonus()
	return self.bonus_range
end


function modifier_item_archer_bow:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attackspeed
end


----- 多目标攻击 ------
if modifier_item_archer_bow_multe == nil then modifier_item_archer_bow_multe = class({}) end

function modifier_item_archer_bow_multe:OnCreated()
	if IsServer() then
		local nMaxEmenys = 6
		local nHitCounts = 0
		local hCaster = self:GetCaster()
		local hTarget = self:GetAbility().HitTarget
		local nProjectileSpeed = hCaster:GetProjectileSpeed()
		local nBaseAttackRange =  hCaster:GetBaseAttackRange()
		local nAttackRangeBonus =  100
		local nAoeRadius = self:GetAbility().AoeRadius
		local enemies = FindUnitsInRadius( 
			hCaster:GetTeamNumber(), 
			hCaster:GetOrigin(), 
			hTarget, 
			nAoeRadius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
			0, 
			false 
		)
		local bUseCastAttackOrb = false
		local bProcessProcs = false
		local bSkipCooldown = true
		local bIgnoreInvis = true
		local bUseProjectile = true
		local bFakeAttack = false
		local bNeverMiss = false

		if #enemies > 0 then
			for _,hEnemy in pairs(enemies) do
				if hEnemy ~= nil and hEnemy ~= hTarget then
					hCaster:PerformAttack( 
						hEnemy, 
						bUseCastAttackOrb, 
						bProcessProcs,
						bSkipCooldown, 
						bIgnoreInvis, 
						bUseProjectile, 
						bFakeAttack, 
						bNeverMiss
					)
					nHitCounts = nHitCounts + 1
				end
				if nHitCounts == nMaxEmenys then break end
			end
		end
		enemies = nil
		self:Destroy()
	end
end

