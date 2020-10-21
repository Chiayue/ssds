LinkLuaModifier("modifier_item_series", "item/series/item_series_s1", LUA_MODIFIER_MOTION_NONE)

-------------------------------------------- S1 词缀 --------------------------------
-------- S1副职 --------
LinkLuaModifier("modifier_series_reward_deputy_blink", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_investment", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_technology", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_doctor", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_killer", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_scavenging", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_forging", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_boxer", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_deputy_idler", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
-------- S1天赋 --------
LinkLuaModifier("modifier_series_reward_talent_light", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_talent_flame", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_talent_clod", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_talent_vitality", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_series_reward_talent_ruin", "item/series/series_reward", LUA_MODIFIER_MOTION_NONE)
-------------------------------------------- S2 词缀 --------------------------------
-------------------------------------------- S3 词缀 --------------------------------
if item_series_s1 == nil then item_series_s1 = {} end
function item_series_s1:GetIntrinsicModifierName()
	return "modifier_item_series"
end

if item_series_s1_t1_hand == nil 		then item_series_s1_t1_hand = class(item_series_s1) end
if item_series_s1_t1_chest == nil 		then item_series_s1_t1_chest = class(item_series_s1) end
if item_series_s1_t1_foot == nil	 	then item_series_s1_t1_foot = class(item_series_s1) end
if item_series_s1_t1_trousers == nil 	then item_series_s1_t1_trousers = class(item_series_s1) end

if item_series_s1_t2_hand == nil 		then item_series_s1_t2_hand = class(item_series_s1) end
if item_series_s1_t2_chest == nil 		then item_series_s1_t2_chest = class(item_series_s1) end
if item_series_s1_t2_foot == nil 		then item_series_s1_t2_foot = class(item_series_s1) end
if item_series_s1_t2_trousers == nil 	then item_series_s1_t2_trousers = class(item_series_s1) end

if item_series_s1_t3_hand == nil 		then item_series_s1_t3_hand = class(item_series_s1) end
if item_series_s1_t3_chest == nil 		then item_series_s1_t3_chest = class(item_series_s1) end
if item_series_s1_t3_foot == nil 		then item_series_s1_t3_foot = class(item_series_s1) end
if item_series_s1_t1_trousers == nil 	then item_series_s1_t3_trousers = class(item_series_s1) end

if modifier_item_series == nil then modifier_item_series = class({}) end



function modifier_item_series:IsHidden() 
	return true
end

function modifier_item_series:DeclareFunctions() 
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

	} 
	return funcs
end


function modifier_item_series:OnIntervalThink()
	if not IsServer() then return end
	-- print("OnIntervalThink")
	self:CheckCombine()
	self:StartIntervalThink( -1 )
end

function modifier_item_series:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_series:OnCreated()
	self.bonus_str = 0
	self.bonus_agi = 0
	self.bonus_int = 0
	if self:GetAbility() ~= nil then  
		if self:GetAbility().bonus ~= nil then
			local hCaster = self:GetParent()
			for k,sItemName in pairs(self:GetAbility().bonus.gemslot_info) do
				local hAttr = hGemAttrTable[sItemName]
				self.bonus_str = self.bonus_str + (hAttr["str"] or 0)
				self.bonus_agi = self.bonus_agi + (hAttr["agi"] or 0)
				self.bonus_int = self.bonus_int + (hAttr["int"] or 0)
			end
		end
		if not IsServer() then return end
		self:CheckCombine()
	end
end

function modifier_item_series:OnRefresh()
	if not IsServer() then return end

end

function modifier_item_series:OnDestroy()
	if not IsServer() then return end
	self:CheckCombine()
end

-- 读取套装词条
function modifier_item_series:CheckCombine()
	if not IsServer() then return end
	local hCaster = self:GetParent()
	local hAbility = self:GetParent():FindAbilityByName("upgrade_ability_core")
	Timer(0.1,function()
		local hSeriesItem = {}
		for i=0,5 do
			local hItem = hCaster:GetItemInSlot(i)
			if hItem ~= nil then
				--print(i,hItem:GetIntrinsicModifierName())
				if hItem:GetIntrinsicModifierName() == "modifier_item_series" then
					table.insert( hSeriesItem, hItem )
				end
			end
		end
		-- 获取羁绊词条
		local hDeputyAffix = {}
		local hTalentAffix = {}
		for k,v in pairs(hSeriesItem) do
			-- 副职
			local sDeputy = v.bonus.deputy
			if hDeputyAffix[sDeputy] == nil then
				hDeputyAffix[sDeputy] = 1
			else
				hDeputyAffix[sDeputy] = hDeputyAffix[sDeputy] + 1
			end
			-- 天赋
			local sTalent = v.bonus.talent
			if hTalentAffix[sTalent] == nil then
				hTalentAffix[sTalent] = 1
			else
				hTalentAffix[sTalent] = hTalentAffix[sTalent] + 1
			end
		end
		-- 副职
		--DeepPrintTable(hDeputyAffix)
		for Season,Affix in pairs(AFFIX_FOR_DEPUTY) do
			for _,sAffix in pairs(Affix) do
				local sModifierName = "modifier_series_reward_deputy_"..sAffix
				local nAmount = hDeputyAffix[sAffix]
				if nAmount == nil then nAmount = 0 end
				if nAmount > 1 then
					local hDeputyModi = hCaster:FindModifierByName(sModifierName)
					if hDeputyModi == nil then
						hDeputyModi = hCaster:AddNewModifier(hCaster, hAbility, sModifierName, {}) 
					end
					hDeputyModi:SetStackCount(0)
					for n=1,nAmount do
						hCaster:AddNewModifier(hCaster, hAbility, sModifierName, {}) 
					end
				else
					hCaster:RemoveModifierByName(sModifierName) 
				end
			end
		end
		-- 天赋
		for Season,Affix in pairs(AFFIX_FOR_TALENT) do
			for _,sAffix in pairs(Affix) do
				local sModifierName = "modifier_series_reward_talent_"..sAffix
				local nAmount = hTalentAffix[sAffix]
				if nAmount == nil then nAmount = 0 end
				if nAmount > 1 then
					local hTalentModi = hCaster:FindModifierByName(sModifierName)
					if hTalentModi == nil then
						hTalentModi = hCaster:AddNewModifier(hCaster, hAbility, sModifierName, {}) 
					end
					hTalentModi:SetStackCount(0)
					for n=1,nAmount do
						hCaster:AddNewModifier(hCaster, hAbility, sModifierName, {}) 
					end
					-- hCaster:SetModifierStackCount(sModifierName,hCaster,nAmount)
				else
					hCaster:RemoveModifierByName(sModifierName) 
				end
			end
		end
	end)
end

function modifier_item_series:GetModifierBonusStats_Strength() return self.bonus_str end
function modifier_item_series:GetModifierBonusStats_Agility() return self.bonus_agi end
function modifier_item_series:GetModifierBonusStats_Intellect() return self.bonus_int end