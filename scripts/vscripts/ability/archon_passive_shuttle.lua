LinkLuaModifier( "modifier_archon_passive_shuttle", "ability/archon_passive_shuttle.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cooldown_reduction", "ability/archon_passive_shuttle.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_shuttle_particles", "ability/archon_passive_shuttle.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_shuttle == nil then
	archon_passive_shuttle = class({})
end

function archon_passive_shuttle:GetIntrinsicModifierName()
 	return "modifier_archon_passive_shuttle"
end
--------------------------------------------------
if modifier_archon_passive_shuttle == nil then
	modifier_archon_passive_shuttle = class({})
end

function modifier_archon_passive_shuttle:IsHidden()
	return false
end

function modifier_archon_passive_shuttle:OnCreated()
	if IsServer() then -- and self:GetParent() ~= self:GetCaster()
		self:StartIntervalThink(0.5)
	end
end

function modifier_archon_passive_shuttle:OnIntervalThink(  )
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nLevel = self:GetAbility():GetLevel()

	local blink_cooldown = hCaster:FindAbilityByName("archon_blink")
	if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
	 	hCaster:AddNewModifier(hCaster, blink_cooldown, "modifier_cooldown_reduction", {duration = 30})
	elseif nLevel >= ABILITY_AWAKEN_2 then
	 	hCaster:AddNewModifier(hCaster, blink_cooldown, "modifier_cooldown_reduction", {duration = 50})
	end
end

function modifier_archon_passive_shuttle:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_shuttle:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TOOLTIP,
		--MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,  -- 百分比冷却
	}
	return funcs
end

function modifier_archon_passive_shuttle:OnTooltip()
	if IsValidEntity(self:GetCaster()) then
		return self:GetParent():GetModifierStackCount("modifier_archon_passive_shuttle", nil)
	end
	return 0
end

function modifier_archon_passive_shuttle:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local hCaster = self:GetCaster()
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local damage_coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
	if nowChance  > chance then
		return 0
	end
	
	local hTarget = params.target

	-- local EffectName = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex, 3, hTarget:GetAbsOrigin())
	-- -- 新建特效
	-- local EffectName_1 = "particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf"
	-- local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))
	-- -- ParticleManager:SetParticleControl(nFXIndex_1, 1, hTarget:GetAbsOrigin())
	-- -- ParticleManager:SetParticleControl(nFXIndex_1, 3, hTarget:GetAbsOrigin())
	-- -- ParticleManager:SetParticleControl(nFXIndex_1, 9, hTarget:GetAbsOrigin())

	-- local EffectName_2 = "particles/econ/items/tinker/tinker_ti10_immortal_laser/tinker_ti10_immortal_laser.vpcf"
	-- local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_2, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_2, 3, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_2, 9, hTarget:GetAbsOrigin())

	hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_shuttle_particles", {duration = 1})

	EmitSoundOn( "Hero_Tinker.Heat-Seeking_Missile", hTarget )
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

	local blink = self:GetParent():GetModifierStackCount("modifier_archon_passive_shuttle", nil)
	--print("blink------------->", blink)                         
	local abil_damage =  (20 + blink ) *  ( 20 + blink ) * damage_coefficient
	--print("abil_damage===========>", abil_damage)
	for _,enemy in pairs(enemies) do
		if enemy ~= nil then
			local damage = {
				victim = enemy,
				attacker = self:GetCaster(),
				damage = abil_damage,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}
			ApplyDamage( damage )
			
		end
	end
end

if modifier_archon_passive_shuttle_particles == nil then 
	modifier_archon_passive_shuttle_particles = class({})
end

function modifier_archon_passive_shuttle_particles:IsHidden()
	return true
end

function modifier_archon_passive_shuttle_particles:OnCreated( args )
	--if not IsServer() then return end
	local hParent = self:GetParent()
	--local hTarget = args.target
	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then
		local EffectName = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 3, hParent:GetAbsOrigin())
		-- 新建特效
		local EffectName_1 = "particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf"
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 0, Vector(500, 500, 500))

		local EffectName_2 = "particles/econ/items/tinker/tinker_ti10_immortal_laser/tinker_ti10_immortal_laser.vpcf"
		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 3, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 9, hParent:GetAbsOrigin())
	end
end

function modifier_archon_passive_shuttle_particles:OnDestroy()
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

------   减少冷却时间的modifier

if modifier_cooldown_reduction == nil then
	modifier_cooldown_reduction = class({})
end

function modifier_cooldown_reduction:IsHidden()
	return true
end
function modifier_cooldown_reduction:IsDebuff()
	return false
end
function modifier_cooldown_reduction:IsPurgable()
	return false
end
function modifier_cooldown_reduction:IsPurgeException()
	return false
end
function modifier_cooldown_reduction:AllowIllusionDuplicate()
	return false
end
function modifier_cooldown_reduction:RemoveOnDeath()
	return false
end
function modifier_cooldown_reduction:DestroyOnExpire()
	return false
end
function modifier_cooldown_reduction:IsPermanent()
	return true
end
function modifier_cooldown_reduction:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function modifier_cooldown_reduction:GetModifierPercentageCooldown(params)
	 return self:GetDuration()
end