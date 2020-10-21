
---------------------- 科学家 ------------------------
if archon_deputy_technology == nil then
	archon_deputy_technology =  class({})
end

---------------------- 杀手 -----------------------
function archon_deputy_killer(params)
	local ability = params.ability
	local hCaster = params.caster
	local nowChance = RandomInt(0,100)
	local chance = ability:GetSpecialValueFor( "chance" )
	local nDeputyStack = hCaster:GetModifierStackCount( "modifier_series_reward_deputy_killer", hCaster )
	if nDeputyStack >=3 then chance = 50 end
	if nowChance  > chance then
		return 0
	end
	
	local modifier = "modifier_archon_deputy_killer"
	local nLevelBonus = ability:GetSpecialValueFor( "bonus_level_property" )
	
	if nDeputyStack >=3 then
		nLevelBonus = 35
	elseif nDeputyStack >=2 then
		nLevelBonus = 25
	end
	local nMaxStack = hCaster:GetLevel() * nLevelBonus
	local nCurrentStack = hCaster:GetModifierStackCount( modifier, hCaster )
	if nCurrentStack < nMaxStack then
		if nDeputyStack >=3 then
			hCaster:SetBaseStrength(hCaster:GetBaseStrength()  + 1)
			hCaster:SetBaseAgility(hCaster:GetBaseAgility()  + 1)
			hCaster:SetBaseIntellect(hCaster:GetBaseIntellect()  + 1)
		else
			local bonus_type = RandomInt(0,2)
			if bonus_type == DOTA_ATTRIBUTE_STRENGTH then
				local BaseProperty = hCaster:GetBaseStrength() 
				hCaster:SetBaseStrength(BaseProperty + 1)
			end
			if bonus_type == DOTA_ATTRIBUTE_AGILITY then
				local BaseProperty = hCaster:GetBaseAgility() 
				hCaster:SetBaseAgility(BaseProperty + 1)
			end
			if bonus_type == DOTA_ATTRIBUTE_INTELLECT then
				local BaseProperty = hCaster:GetBaseIntellect() 
				hCaster:SetBaseIntellect(BaseProperty + 1)
			end
		end
		hCaster:SetModifierStackCount( modifier, hCaster, nCurrentStack + 1 )
	end
	hCaster:CalculateStatBonus()
end
---------------------- 工匠大师 ------------------------
if archon_deputy_forging == nil then 
	archon_deputy_forging = class({})
end

local hGemTable = {
	str = {
		"item_strength_gemstone_0",
		"item_strength_gemstone_1",
		"item_strength_gemstone_2",
		"item_strength_gemstone_3",
		"item_strength_gemstone_4",
		"item_strength_gemstone_5",
		"item_strength_gemstone_6",
		"item_strength_gemstone_7",
		"item_strength_gemstone_8",
	},
	str_str = {
		"item_strength_gemstone_9",
	},
	str_agi = {
		"item_strength_gemstone_10"
	},
	str_int = {
		"item_strength_gemstone_11"
	},
	agi = {
		"item_agility_gemstone_0",
		"item_agility_gemstone_1",
		"item_agility_gemstone_2",
		"item_agility_gemstone_3",
		"item_agility_gemstone_4",
		"item_agility_gemstone_5",
		"item_agility_gemstone_6",
		"item_agility_gemstone_7",
		"item_agility_gemstone_8",
	},
	agi_str = {
		"item_agility_gemstone_11"
	},
	agi_agi = {
		"item_agility_gemstone_9"
	},
	agi_int = {
		"item_agility_gemstone_10"
	},
	int = {
		"item_intelligece_gemstone_0",
		"item_intelligece_gemstone_1",
		"item_intelligece_gemstone_2",
		"item_intelligece_gemstone_3",
		"item_intelligece_gemstone_4",
		"item_intelligece_gemstone_5",
		"item_intelligece_gemstone_6",
		"item_intelligece_gemstone_7",
		"item_intelligece_gemstone_8",
	},
	int_str = {
		"item_intelligece_gemstone_11"
	},
	int_agi = {
		"item_intelligece_gemstone_10"
	},
	int_int = {
		"item_intelligece_gemstone_9"
	}
}

function archon_deputy_forging:GetGemInfo(hItem)
	local sItemName = hItem:GetAbilityName()
	local nPlayerID = hItem:GetPurchaser():GetPlayerID()
	for k,v in pairs(hGemTable) do
		for k2,v2 in pairs(v) do
			if v2 == sItemName then
				return {IsGem = true,Level = k2, Category = k ,PlayerID = nPlayerID}
			end
		end
	end
	return {IsGem = false,Level = nil, Category = nil , PlayerID = nPlayerID}
end

function archon_deputy_forging:OnSpellStart()
	if not IsServer() then return end
	local hCaster = self:GetCaster() -- 技能拥有着
	--获取当前玩家背包里面的宝石
	local nDeputyStack =  hCaster:GetModifierStackCount("modifier_series_reward_deputy_forging", hCaster )
	-- 工匠套装
	local nProbability = 0
	if nDeputyStack >= 3 then 
		nProbability = 15
	elseif nDeputyStack >= 2 then
		nProbability = 5
	end
	local bBonusGem = false
	local nRandomChance = RandomInt(1,100) 
	if nRandomChance <= nProbability then
		bBonusGem = true
	end
	-----------------
	local tItemTable = {}
	for i=1,9 do 
		local hItem = hCaster:GetItemInSlot(i-1)
		tItemTable[i] = hItem
	end
	for k,hItem in pairs(tItemTable) do
		local GemInfo = self:GetGemInfo(hItem)
		if GemInfo.IsGem == true then
			local sCategory = GemInfo.Category
			local nLevel = GemInfo.Level
			local nPlayerID = GemInfo.PlayerID
			local nPurchaser = hItem:GetPurchaser()
			-- 如果宝石等级小于9级，则2个相同的合并
			if nLevel < 9 and #sCategory == 3 then
				for i = k+1,9 do 
					local hLeftItem = hCaster:GetItemInSlot(i-1)
					if hLeftItem ~= nil then
						local LeftGemInfo = self:GetGemInfo(hLeftItem)
						if LeftGemInfo.Level == nLevel and LeftGemInfo.Category == sCategory and  LeftGemInfo.PlayerID == nPlayerID then
							UTIL_Remove(hItem)
							UTIL_Remove(hLeftItem)
							local sNewItemName = hGemTable[sCategory][nLevel+1]
							local hNewItem = hCaster:AddItemByName(sNewItemName)
							hNewItem:SetPurchaser(nPurchaser)
							hNewItem:SetPurchaseTime(0)
							if bBonusGem == true then
								local hNewItem = hCaster:AddItemByName(sNewItemName)
								hNewItem:SetPurchaser(hCaster)
								hNewItem:SetPurchaseTime(0)
							end
							return 
						end
					end
				end
			elseif nLevel == 9 then
				for i = k+1,9 do 
					local hLeftItem = hCaster:GetItemInSlot(i-1)
					if hLeftItem ~= nil then
						local LeftGemInfo = self:GetGemInfo(hLeftItem)
						if LeftGemInfo.Level == nLevel and LeftGemInfo.PlayerID == nPlayerID then
							-- 根据宝石类型进行组合
							UTIL_Remove(hItem)
							UTIL_Remove(hLeftItem)
							local sNewItemCategory = sCategory.."_"..LeftGemInfo.Category
							local sNewItemName = hGemTable[sNewItemCategory][1]
							local hNewItem = hCaster:AddItemByName(sNewItemName)
							hNewItem:SetPurchaser(nPurchaser)
							hNewItem:SetPurchaseTime(0)
							if bBonusGem == true then
								local hNewItem = hCaster:AddItemByName(sNewItemName)
								hNewItem:SetPurchaser(hCaster)
								hNewItem:SetPurchaseTime(0)
							end
							return 
						end
					end
				end
			end
		end
	end
end

---------------------- 理财大师 ------------------------
if archon_deputy_investment == nil then
	archon_deputy_investment =  class({})
end

----------------------- 医生 ---------------------------
LinkLuaModifier( "modifier_archon_deputy_doctor", "ability/archon_deputy_ability.lua",LUA_MODIFIER_MOTION_NONE )
if archon_deputy_doctor == nil then	archon_deputy_doctor = class({}) end
function archon_deputy_doctor:GetCooldown() 
	local hCaster = self:GetCaster()
	local nDeputyBlink = hCaster:GetModifierStackCount("modifier_series_reward_deputy_doctor", hCaster )
	if nDeputyBlink >= 2 then
		return 45
	end
	return 70
end
function archon_deputy_doctor:GetCastRange() if IsClient() then return 1200 end end
function archon_deputy_doctor:OnSpellStart()
	local hCaster = self:GetCaster() 
	local aoe = self:GetSpecialValueFor( "aoe" )
	local nDuration = self:GetSpecialValueFor( "duration" )
	local nFXIndex0 = ParticleManager:CreateParticle( EffectName, PATTACH_POINT, hCaster)
	local nDeputyBlink = hCaster:GetModifierStackCount("modifier_series_reward_deputy_doctor", hCaster )
	local hAllies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(), 
		self:GetCaster():GetOrigin(), 
		self:GetCaster(), 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	local EffectName = "particles/econ/events/ti8/mekanism_ti8.vpcf"
	for _,ally in pairs(hAllies) do
		if ally ~= nil  then
			local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, ally)
			local nHealtBonus = ally:GetMaxHealth() * self:GetSpecialValueFor( "max_health" ) * 0.01
			ally:Heal(nHealtBonus,self:GetCaster())
			local hNewBuff = ally:AddNewModifier(hCaster, self, "modifier_archon_deputy_doctor",{ duration = nDuration})
			if ally == hCaster then
				hNewBuff:SetStackCount(2)
			end 
			if nDeputyBlink >= 3 then
				ally:AddNewModifier(hCaster, self, "modifier_series_reward_deputy_doctor_effect",{ duration = 5}) 
			end
		end
	end
end
if modifier_archon_deputy_doctor == nil then modifier_archon_deputy_doctor = class({}) end
function modifier_archon_deputy_doctor:IsHidden() return false end
function modifier_archon_deputy_doctor:OnCreated()
	self.bonus_attackspeed = self:GetAbility():GetSpecialValueFor( "bonus_attackspeed" )
	self.bonus_movespeed = self:GetAbility():GetSpecialValueFor( "bonus_movespeed" )
	if IsServer() then
		self:SetStackCount(1)
		self.nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) )
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
end
function modifier_archon_deputy_doctor:OnRefresh()
	if not IsServer() then return end
	ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self:GetStackCount(), 0, 0 ) ) 
end

function modifier_archon_deputy_doctor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end
function modifier_archon_deputy_doctor:GetModifierAttackSpeedBonus_Constant()
	return self.bonus_attackspeed * self:GetStackCount()
end
function modifier_archon_deputy_doctor:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed * self:GetStackCount()
end