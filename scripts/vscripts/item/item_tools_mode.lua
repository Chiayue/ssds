-- 测试工具下调试
LinkLuaModifier("modifier_item_tools_mode", "item/item_tools_mode", LUA_MODIFIER_MOTION_NONE)

if item_tools_mode == nil then item_tools_mode = {} end

function item_tools_mode:OnSpellStart() 
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nPlayerID = hCaster:GetOwner():GetPlayerID()
	local nAllRange = 10000
	
	local EffectName = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hCaster )
	
	local enemies = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hCaster:GetOrigin(), 
		hCaster, 
		nAllRange, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	for _,enemy in pairs(enemies) do
		if enemy ~= nil  then
			local damage = {
				victim = enemy,
				attacker = hCaster,
				damage = 9999999,
				damage_type = DAMAGE_TYPE_PURE,
			}
			ApplyDamage( damage )
		end
	end


	-- Archive:LoadServerEqui(nPlayerID)
	-- GlobalVarFunc.isClearance = true
	-- game_playerinfo:SaveData()
	-- local nLayers = RandomInt(1, 1)
	-- Archive:SendRanking("normal",nLayers)
	-- GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	-- game_playerinfo:SaveData()
	-- GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
end

function item_tools_mode:GetIntrinsicModifierName()
	return "modifier_item_tools_mode"
end

if modifier_item_tools_mode == nil then modifier_item_tools_mode = {} end
function modifier_item_tools_mode:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_item_tools_mode:GetModifierBonusStats_Agility() 
	return 50000
end

function modifier_item_tools_mode:GetModifierBonusStats_Intellect()	
	return 50000
end

function modifier_item_tools_mode:GetModifierBonusStats_Strength() 
	return 50000
end