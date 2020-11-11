-- 维修模式

if ability_abyss_10 == nil then
	ability_abyss_10 = class({})
end
LinkLuaModifier( "modifier_ability_abyss_10", "ability/mechanism_Boss/ability_abyss_10", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function ability_abyss_10:Precache( context )
	--PrecacheItemByNameSync( "item_gold_egg", context )
end

function ability_abyss_10:GetIntrinsicModifierName()
	return "modifier_ability_abyss_10"
end

--------------------------------------------------------------------------------

if modifier_ability_abyss_10 == nil then
	modifier_ability_abyss_10 = class({})
end

function modifier_ability_abyss_10:IsPurgable()
	return false
end

function modifier_ability_abyss_10:IsHidden()
	return true
end

function modifier_ability_abyss_10:OnCreated( kv )
	if IsServer() then

		self.vCenter = Vector(0, 0, 0) + RandomVector( RandomFloat( 0, 10000 ) )
	
		ExecuteOrderFromTable({                               --从一个Script表发布命令 
			UnitIndex = self:GetParent():entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = self.vCenter
			})

		self:StartIntervalThink( 1.0 )
	end
end

function modifier_ability_abyss_10:DeclareFunctions()
	local funcs = 
	{
		-- MODIFIER_EVENT_ON_TAKEDAMAGE,
		-- MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		-- MODIFIER_PROPERTY_MIN_HEALTH,
		-- MODIFIER_EVENT_ON_TELEPORTED,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_ability_abyss_10:OnIntervalThink()
	if not IsServer() then
		return
	end

	ExecuteOrderFromTable({
		UnitIndex = self:GetParent():entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = FindPathablePositionNearby( self.vCenter, 0, 45000 )
		})	

end

function modifier_ability_abyss_10:OnDeath( params )
	local hParent = self:GetParent()
	local hUnit = params.unit
	--print("args")
	if IsValidEntity(hParent) and not hParent:IsAlive() then 
		--print("1")
		local newItem = CreateItem( "item_corrosive", nil, nil )
		local drop = CreateItemOnPositionSync( hUnit:GetAbsOrigin(), newItem ) 
		-- if hParent:GetHealth() <= 0 then 
		-- 	UTIL_Remove(hParent)
		-- end
	end
end

function FindPathablePositionNearby( vSourcePos, nMinDistance, nMaxDistance )

	local vPos = vSourcePos + RandomVector( RandomFloat( nMinDistance, nMaxDistance ) )

	local nAttempts = 0
	local nMaxAttempts = 10

	while ( ( not GridNav:CanFindPath( vSourcePos, vPos ) ) and ( nAttempts < nMaxAttempts ) ) do
		vPos = vSourcePos + RandomVector( RandomFloat( nMinDistance, nMaxDistance ) )
		nAttempts = nAttempts + 1
	end

	return vPos
end