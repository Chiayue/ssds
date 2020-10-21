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
    local nLevel = self:GetAbility():GetLevel()
	if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
		if nInCooldown == 0 then
    		hDuliu["duliu_max_cd"] = 150
    	end
	elseif nLevel >= ABILITY_AWAKEN_2 then
		if nInCooldown == 0 then
    		hDuliu["duliu_max_cd"] = 60
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
	if nowChance  > chance then
		return 0
	end

	local hTarget = params.target

	-- local EffectName = "particles/down_particles/violet/down_particles_violet.vpcf"
	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex, 3, hTarget:GetAbsOrigin())

	-- -- 新建特效
	-- local EffectName_1 = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
	-- local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_1, 2, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_1, 1, hTarget:GetAbsOrigin())

	-- local EffectName_2 = "particles/units/heroes/hero_void_spirit/debut/void_spirit_channel.vpcf"
	-- local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_2, 2, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_2, 1, hTarget:GetAbsOrigin())

	hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_greed_particles", {duration = 1})

	EmitSoundOn( "Hero_EarthShaker.Fissure", hTarget )
	-- 范围伤害   
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		aoe, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	--local nPlayerID = hCaster:GetPlayerID()
	local greed_nuber = CustomNetTables:GetTableValue( "common", "greedy_level" )
	local nGreedLevel = greed_nuber.greedy_level
	--print("nGreedLevel---------->", nGreedLevel)
	local attack_speed_damage = ( 7 + nGreedLevel ) * ( 7 + nGreedLevel ) * ( 7 + nGreedLevel ) * damage_coefficient
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

if modifier_archon_passive_greed_particles == nil then 
	modifier_archon_passive_greed_particles = class({})
end

function modifier_archon_passive_greed_particles:IsHidden()
	return true
end

function modifier_archon_passive_greed_particles:OnCreated( args )
	--if not IsServer() then return end
	local hParent = self:GetParent()
	--local hTarget = args.target
	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then
		local EffectName = "particles/down_particles/violet/down_particles_violet.vpcf"
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 3, hParent:GetAbsOrigin())
		-- 新建特效
		local EffectName_1 = "particles/units/heroes/hero_void_spirit/astral_step/void_spirit_astral_step.vpcf"
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 2, hParent:GetAbsOrigin())

		local EffectName_2 = "particles/units/heroes/hero_void_spirit/debut/void_spirit_channel.vpcf"
		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 2, hParent:GetAbsOrigin())

	end
end

function modifier_archon_passive_greed_particles:OnDestroy()
	--if not IsServer() then return end
	local hParent = self:GetParent()
	if hParent.nFXIndex and hParent.nFXIndex_1 and hParent.nFXIndex_2 then 
		ParticleManager:DestroyParticle( hParent.nFXIndex, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex )
		hParent.nFXIndex = nil

		ParticleManager:DestroyParticle( hParent.nFXIndex_1, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_1 )
		hParent.nFXIndex_1 = nil

		ParticleManager:DestroyParticle( hParent.nFXIndex_2, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_2 )
		hParent.nFXIndex_2 = nil
	end
end