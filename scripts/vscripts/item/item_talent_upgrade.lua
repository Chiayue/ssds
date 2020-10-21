

local hTalent = {
	"archon_passive_fire",
	"archon_passive_earth",
	"archon_passive_ice",
	"archon_passive_natural",
	"archon_passive_dark",
	"archon_passive_light",
	"archon_passive_rage",
	"archon_passive_puncture",
	"archon_passive_magic",
	"archon_passive_bank",
	-- 新加英雄天赋
	"archon_passive_time",
	"archon_passive_resist_armour",
	"archon_passive_soul",
	"archon_passive_speed",
	"archon_passive_interspace",
	"archon_passive_shuttle",
    "archon_passive_greed",
}

if item_talent_upgrade == nil then
	item_talent_upgrade = {}
end

function item_talent_upgrade:GetTalent(hCaster)
	for _,v in pairs(hTalent) do
		local nAbility = hCaster:FindAbilityByName(v)
		if nAbility ~= nil then
			return nAbility
		end
	end
	return nil
end

function item_talent_upgrade:OnSpellStart() 
	local hCaster = self:GetCaster()
	local hTalentPassive = self:GetTalent(hCaster)
	local nPlayerID = hCaster:GetPlayerID() 
	if hTalentPassive ~= nil then
		local nLevel = hTalentPassive:GetLevel()
		if nLevel < 7 then
			hTalentPassive:SetLevel(nLevel+1)
			self:SpendCharge()
		else
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"send_error_message_client",{message="天赋已满级"})
		end
	end
	
end