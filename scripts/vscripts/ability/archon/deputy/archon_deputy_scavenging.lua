---------------------- 拾荒者副职 ------------------------
LinkLuaModifier( "modifier_archon_deputy_scavenging", "ability/archon/deputy/archon_deputy_scavenging", LUA_MODIFIER_MOTION_NONE )	
--------------------
if archon_deputy_scavenging == nil then archon_deputy_scavenging = {} end
function archon_deputy_scavenging:GetIntrinsicModifierName() return "modifier_archon_deputy_scavenging" end
function archon_deputy_scavenging:GetCastRange() if IsClient() then return self:GetSpecialValueFor( "pick_aoe" ) end end
function archon_deputy_scavenging:GetCooldown() 
	local hCaster = self:GetCaster()
	local nDeputyStack = hCaster:GetModifierStackCount("modifier_series_reward_deputy_scavenging", hCaster )
	if nDeputyStack >= 3 then
		return 4
	end
	return 5
end

function archon_deputy_scavenging:OnSpellStart() 
	if IsServer() then 
		local nAoeRadius = self:GetSpecialValueFor( "pick_aoe" )
		local fReward = self:GetSpecialValueFor( "reward" )
		local hCaster = self:GetCaster() 
		local nDeputyStack = hCaster:GetModifierStackCount("modifier_series_reward_deputy_scavenging", hCaster )
		if nDeputyStack >= 3 then
			fReward = 100 
		elseif nDeputyStack >= 2 then
			fReward = 40
		end
		local vc = hCaster:GetOrigin() 
		local nPlayerID = hCaster:GetPlayerID()
		local hPlayer = PlayerResource:GetPlayer(nPlayerID)
		local hEntities = Entities:FindAllByClassnameWithin("dota_item_drop",vc,nAoeRadius)
		if hEntities ~= nil then
			for k,v in pairs(hEntities) do
				local hItem = v:GetContainedItem()
				local sItemName = hItem:GetName()
				if sItemName == "item_archers_gold" then
					local nNum = hItem:GetCurrentCharges()
					local nAmount = math.floor(nNum * (1 + fReward * 0.01))
					PlayerResource:ModifyGold(nPlayerID,nAmount,true,DOTA_ModifyGold_Unspecified)
					PopupGoldGain(hCaster, nAmount)
					GlobalVarFunc:OnGameSound("jinbi_sound", nPlayerID)
					--UTIL_Remove(v)
					v:RemoveSelf() 
				elseif sItemName == "item_archers_wood" then
					local nNum = hItem:GetCurrentCharges()
					local nAmount = math.floor(nNum * (1 + fReward* 0.01))
					Player_Data():AddPoint(nPlayerID,nAmount)
        			PopupWoodGain(hCaster, nAmount)
        			GlobalVarFunc:OnGameSound("mutou_sound", nPlayerID)
					--UTIL_Remove(v)
					v:RemoveSelf() 
				end
			end
		end
	end	
end
-----------------
if modifier_archon_deputy_scavenging == nil then modifier_archon_deputy_scavenging = {} end
function modifier_archon_deputy_scavenging:OnCreated()

	if not IsServer() then return end
	self:SetDuration(0, true)
end

function modifier_archon_deputy_scavenging:IsHidden()			return self:GetDuration() > 0 end
function modifier_archon_deputy_scavenging:DestroyOnExpire()	return false end
function modifier_archon_deputy_scavenging:IsPurgable()			return false end
function modifier_archon_deputy_scavenging:RemoveOnDeath()		return false end


function modifier_archon_deputy_scavenging:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = (self:GetDuration() <= 0 and not self:GetCaster():HasModifier("modifier_autistic_every_week") ),
		[MODIFIER_STATE_NO_UNIT_COLLISION]	= self:GetDuration() <= 0,
	}
end

function modifier_archon_deputy_scavenging:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_DEATH,
	}
end

function modifier_archon_deputy_scavenging:GetModifierInvisibilityLevel()
	local level = math.floor( (( 15 - self:GetDuration() ) / 15) * 9 )
	return level
end

function modifier_archon_deputy_scavenging:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() then
		self:SetDuration(self:GetAbility():GetSpecialValueFor("invisible_delay"),true)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("invisible_delay"))
	end
end

function modifier_archon_deputy_scavenging:OnIntervalThink()
	self:SetDuration(0, true)
	self:StartIntervalThink(-1)
end

-- function modifier_archon_deputy_scavenging:OnDeath(args)
-- 	if not IsServer() then return end
-- 	local hAttacker = args.attacker
-- 	local hCaster = self:GetParent()
-- 	if hAttacker ~= hCaster then
-- 		return
-- 	end
-- 	local hUnit = args.unit
-- 	hUnit:SetMaximumGoldBounty(5)
-- 	hUnit:SetMinimumGoldBounty(5)
-- end