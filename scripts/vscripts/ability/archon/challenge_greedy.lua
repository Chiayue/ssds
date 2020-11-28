if challenge_greedy == nil then challenge_greedy = {} end
function challenge_greedy:OnSpellStart() 
	print("OnSpellStart")
	if not IsServer() then return end
	local nPlayerID = self:GetCaster():GetPlayerID()
	local gameEvent = {}
	gameEvent[ "player_id" ] = nPlayerID
    gameEvent[ "teamnumber" ] = -1
    gameEvent[ "message" ] = "#DOTA_HUD_USE_GREED"
    FireGameEvent( "dota_combat_event_message", gameEvent )
    MonsterChallenge:OnRewardGold(nPlayerID)
    GlobalVarFunc.duliuLevel = GlobalVarFunc.duliuLevel + 1
    MonsterChallenge:OnDuLiuAddNum(nPlayerID)
    CustomNetTables:SetTableValue("common", "greedy_level", { greedy_level = GlobalVarFunc.duliuLevel})
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"challenge_greedy_success",{})
	--------------- 双倍
	if self:GetCaster():HasModifier("modifier_gem_devil_greed_additional") then
		local bDouble = false
		if RandomInt(1, 100) <= 35 then bDouble = true end
		if bDouble == true then
			-- local gameEvent = {}
			-- gameEvent[ "player_id" ] = nPlayerID
		 --    gameEvent[ "teamnumber" ] = -1
		 --    gameEvent[ "message" ] = "#DOTA_HUD_USE_GREED"
		 --    FireGameEvent( "dota_combat_event_message", gameEvent )
		    GlobalVarFunc.duliuLevel = GlobalVarFunc.duliuLevel + 1
		    CustomNetTables:SetTableValue("common", "greedy_level", { greedy_level = GlobalVarFunc.duliuLevel})
		    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"challenge_greedy_success",{})
		end
	end
	
	
end

function challenge_greedy:GetCooldown(nLevel) 
	local hCaster = self:GetCaster()
	local hGreedAbility = hCaster:FindAbilityByName("archon_passive_greed")
	local nStackGreed = hCaster:GetModifierStackCount("modifier_series_reward_talent_greed",hCaster)
	local nBaseCD = 300
	if hGreedAbility ~= nil then
		local nGreedLevel = hGreedAbility:GetLevel()
		if nGreedLevel >= 5 then
			nBaseCD = 60
		elseif nGreedLevel >= 2 then
			nBaseCD = 150
		end
	end
	if nStackGreed >=3 then nBaseCD = nBaseCD * 0.7 end
	if hCaster:HasModifier("modifier_gem_tanlan") == true then nBaseCD = nBaseCD * 0.8 end
	if hCaster:HasModifier("modifier_gem_devil_greed") == true then nBaseCD = nBaseCD * 0.9 end
	return nBaseCD
end