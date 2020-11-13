LinkLuaModifier( "modifier_archon_passive_greed", "ability/archon_passive_greed.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_greed_particles", "ability/archon_passive_greed.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_greed == nil then
	archon_passive_greed = class({})
end

function archon_passive_greed:GetIntrinsicModifierName()
 	return "modifier_archon_passive_greed"
end
--------------------------------------------------
if modifier_archon_passive_greed == nil then
	modifier_archon_passive_greed = class({})
end

function modifier_archon_passive_greed:IsHidden()
	return true
end

function modifier_archon_passive_greed:OnCreated()
	if IsServer() then -- 
		self:StartIntervalThink(0.5)
	end
end

function modifier_archon_passive_greed:OnIntervalThink()
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nPlayerID = hCaster:GetPlayerID()
    local hDuliu = Player_Data:GetStatusInfo(nPlayerID)
    local nInCooldown = hDuliu["duliu_in_cd"]
    local nTalentStack = hCaster:GetModifierStackCount("modifier_series_reward_talent_greed", hCaster )
    local nLevel = self:GetAbility():GetLevel()
    local nCoefficient = 1
    if nTalentStack >= 3 then nCoefficient = 0.7 end
	if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
		if nInCooldown == 0 then
    		hDuliu["duliu_max_cd"] = 150 * nCoefficient
    	end
	elseif nLevel >= ABILITY_AWAKEN_2 then
		if nInCooldown == 0 then
    		hDuliu["duliu_max_cd"] = 60 * nCoefficient
   		end	
   	else
   		if nInCooldown == 0 then
    		hDuliu["duliu_max_cd"] = 300 * nCoefficient
   		end	
	end
end


function modifier_archon_passive_greed:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_greed:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		--MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

-- function modifier_archon_passive_greed:GetEffectName()
-- 	return "particles/econ/items/wisp/wisp_relocate_timer_buff_ti7_sparkle_blue.vpcf"
-- end

function modifier_archon_passive_greed:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local hCaster = self:GetCaster()
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local damage_coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local nTalentStack = hCaster:GetModifierStackCount("modifier_series_reward_talent_greed", hCaster )
	if nTalentStack >=2 then chance = chance + 5 end
	if nowChance  > chance then
		return 0
	end

	local hTarget = params.target
	EmitSoundOn( "Hero_EarthShaker.Fissure", hTarget )
	SendParticlesToClient("particles/down_particles/violet/down_particles_violet.vpcf",hTarget)
	-- 范围伤害   
	local enemies = FindUnitsInRadius2(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	local nPlayerID = hCaster:GetPlayerID()
	local nGreedLevel = 0
	local greed_nuber = CustomNetTables:GetTableValue( "gameInfo", "challenge" )
	for k, v in pairs(greed_nuber) do
		if tonumber(k) == nPlayerID then
			--print("args")
            nGreedLevel = v.DuLiuNum
        end
	end
	
	--print("nGreedLevel---------->", nGreedLevel)
	local attack_speed_damage = self:GetCaster():GetIntellect() * ( 10 + nGreedLevel ) * damage_coefficient
	--print("attack_speed_damage===========>", attack_speed_damage)
	for _,enemy in pairs(enemies) do
		if enemy ~= nil then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = attack_speed_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage( damage )
			
		end
	end
end

--------------
modifier_archon_passive_greed_particles = {}
function modifier_archon_passive_greed_particles:GetAttributes() return  MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_archon_passive_greed_particles:IsDebuff() return false end
function modifier_archon_passive_greed_particles:IsHidden() return true end
function modifier_archon_passive_greed_particles:OnCreated()
	local hCaster = self:GetCaster()
	local hTarget = self:GetParent()
	if IsServer() then 
	else
		-- 创建效果
		local EffectName = "particles/down_particles/violet/down_particles_violet.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
		ParticleManager:ReleaseParticleIndex(nFXIndex)
	end
	self:Destroy()
end