if CustomizedReward == nil then CustomizedReward = {} end
LinkLuaModifier("modifier_customized_reward", "customized_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_customized_reward_attr", "customized_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_customized_reward_attr_health", "customized_reward", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_customized_reward_attr_gain_all", "customized_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_customized_reward_attr_max_health", "customized_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_customized_reward_attr_move_speed", "customized_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_customized_reward_attr_attack_speed", "customized_reward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_customized_reward_attr_range", "customized_reward", LUA_MODIFIER_MOTION_NONE)

-- ListenToGameEvent( "dota_player_gained_level" ,Dynamic_Wrap(ArrowSoulMeditation,"OnPlayerGainedLevel"),self)
--441173392
local hRewardTable = {
	[441173392] = { 
		["npc_dota_hero_troll_warlord"] = {
			["skin_id"] = 3,
			["attr"] 	= { 
				gain_all = 10,
				max_health = 10, 
				attack_speed = 25,
				move_speed = 25,
				range = 125,
			},
			["kill_bonus"] = {
				gold = 2,
				health = 1,
			},
			["particle"] = {
				["particles/diy_particles/ambient9.vpcf"] = PATTACH_ABSORIGIN_FOLLOW
			},
			["model"] = "models/heroes/troll_warlord/leimi.vmdl"
		}
		
	},
	[421754271] = { 
		["npc_dota_hero_troll_warlord"] = {
			["skin_id"] = 3,
			["attr"] 	= { 
				gain_all = 10,
				max_health = 10, 
				attack_speed = 25,
				move_speed = 25,
				range = 125,
			},
			["kill_bonus"] = {
				gold = 2,
				health = 1,
			},
			["particle"] = {
				["particles/diy_particles/ambient9.vpcf"] = PATTACH_ABSORIGIN_FOLLOW
			},
			["model"] = "models/heroes/troll_warlord/leimi.vmdl"
		}
		
	},
	[188898517] = { 
		["npc_dota_hero_troll_warlord"] = {
			["skin_id"] = 5,
			["model_scale"] = 1.4,
			["particle"] = {
				["particles/diy_particles/shinai_ambient.vpcf"] = PATTACH_ABSORIGIN_FOLLOW
			},
		}
		
	},
	[193839061] = { 
		["npc_dota_hero_troll_warlord"] = {
			["skin_id"] = 4,
			["model"] = "models/npc/spirit_archer/spirit_archer.vmdl",
			["model_scale"] = 0.65
		}
	},
	[104282686] = { 
		["npc_dota_hero_troll_warlord"] = {
			["skin_id"] = 4,
			["model"] = "models/npc/spirit_archer/spirit_archer.vmdl",
			["model_scale"] = 0.65
		}
	},
	[162191065] = { 
		["npc_dota_hero_troll_warlord"] = {
			["skin_id"] = 5,
			["model_scale"] = 1.4,
			["particle"] = {
				["particles/diy_particles/shinai_ambient.vpcf"] = PATTACH_ABSORIGIN_FOLLOW
			},
		}
	},
}



-- 加载定制奖励
function CustomizedReward:SetReward(hHero)
	local nPlayerID = hHero:GetPlayerID()
	local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)
	if hRewardTable[nSteamID] ~= nil then
		local hRewardList = hRewardTable[nSteamID] 
		local sHeroName = hHero:GetUnitName()
		local hRewardInfo = hRewardList[sHeroName]
		if hRewardInfo ~= nil then
			local nSkinID = hRewardInfo["skin_id"]
			if nSkinID ~= nil then  HeroesSkin:ChangeSkin(hHero,nSkinID) end
			if hRewardInfo["model"] ~= nil then  hHero:SetModel(hRewardInfo["model"]) end
			if hRewardInfo["model_scale"] ~= nil then  hHero:SetModelScale(hRewardInfo["model_scale"]) end
			
			local sAuraParticels = hRewardInfo["particle"] or {}
			local hAttr = hRewardInfo["attr"]
			local hCustomized = {}
			hCustomized["particle"] = sAuraParticels
			hCustomized["attr"] = {}
			if hAttr ~= nil then
				for k,v in pairs(hAttr) do
					hCustomized["attr"] [k] = v
				end
			end
			hHero.customized = hCustomized
			if IsServer() then
				hHero:AddNewModifier(hHero, nil, "modifier_customized_reward", {})
			end
			
		end
	end
end

if modifier_customized_reward == nil then modifier_customized_reward = {} end
function modifier_customized_reward:IsHidden() return true end
function modifier_customized_reward:RemoveOnDeath() return false end
function modifier_customized_reward:IsPurgable() return false end
function modifier_customized_reward:OnCreated()
	if not IsServer() then return end
	-- 加载特效
	for k,v in  pairs(self:GetParent().customized.particle) do
		ParticleManager:CreateParticle(k, v, self:GetParent())
	end
	-- 添加属性
	for sAttName,nStack in  pairs(self:GetParent().customized.attr) do
		local sModiName = "modifier_customized_reward_attr_"..sAttName
		local hRewardModi = self:GetParent():AddNewModifier(self:GetParent(), nil, sModiName, {})
		hRewardModi:SetStackCount(nStack)
	end
end

function modifier_customized_reward:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_customized_reward:OnDeath(args) 
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then return end
	local nPlayerID = hCaster:GetPlayerID()
	-- 击杀奖励
	local hKillBonus = hCaster.customized.kill_bonus or {}
	local nBonus = hKillBonus["gold"] or 0
	if nBonus > 0 then
		PlayerResource:ModifyGold(nPlayerID,nBonus,true,DOTA_ModifyGold_CreepKill)
		PopupGoldGain(hCaster, nBonus)
	end
	-- 击杀奖励生命
	if hKillBonus["health"] ~= nil then
		hCaster:AddNewModifier(hCaster, nil, "modifier_customized_reward_attr_health", {})
	end
end
if modifier_customized_reward_attr == nil then modifier_customized_reward_attr = {} end
function modifier_customized_reward_attr:GetAttributes()   
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT -- + MODIFIER_ATTRIBUTE_MULTIPLE 
end
function modifier_customized_reward_attr:IsHidden() return true end
function modifier_customized_reward_attr:IsPurgable() return false end
function modifier_customized_reward_attr:RemoveOnDeath() return false end
function modifier_customized_reward_attr:OnCreated()
	if not IsServer() then return end
	self:IncrementStackCount()
end
function modifier_customized_reward_attr:OnRefresh()
	if not IsServer() then return end
	self:IncrementStackCount()
end

function modifier_customized_reward_attr:DeclareFunctions() 
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	} 
	return funcs
end

---------------
if modifier_customized_reward_attr_health == nil then modifier_customized_reward_attr_health = class(modifier_customized_reward_attr) end
function modifier_customized_reward_attr_health:GetModifierHealthBonus() return self:GetStackCount() end

if modifier_customized_reward_attr_attack_speed == nil then modifier_customized_reward_attr_attack_speed = class(modifier_customized_reward_attr) end
function modifier_customized_reward_attr_attack_speed:GetModifierAttackSpeedBonus_Constant() return self:GetStackCount() end
------------ 三围成长
if modifier_customized_reward_attr_gain_all == nil then modifier_customized_reward_attr_gain_all = class(modifier_customized_reward_attr) end
------------ 最大生命
if modifier_customized_reward_attr_max_health == nil then modifier_customized_reward_attr_max_health = class(modifier_customized_reward_attr) end
------------ 移动速度
if modifier_customized_reward_attr_move_speed == nil then modifier_customized_reward_attr_move_speed = class(modifier_customized_reward_attr) end
function modifier_customized_reward_attr_move_speed:GetModifierMoveSpeedBonus_Constant() return self:GetStackCount() end
------------ 射程
if modifier_customized_reward_attr_range == nil then modifier_customized_reward_attr_range = class(modifier_customized_reward_attr) end
function modifier_customized_reward_attr_range:GetModifierAttackRangeBonus() return self:GetStackCount() end