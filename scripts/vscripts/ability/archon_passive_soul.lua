LinkLuaModifier( "modifier_archon_passive_soul", "ability/archon_passive_soul.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_soul_particles", "ability/archon_passive_soul.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_soul == nil then
	archon_passive_soul = class({})
end

function archon_passive_soul:GetIntrinsicModifierName()
 	return "modifier_archon_passive_soul"
end
--------------------------------------------------
if modifier_archon_passive_soul == nil then
	modifier_archon_passive_soul = class({})
end

function modifier_archon_passive_soul:IsHidden()
	return false
end

function modifier_archon_passive_soul:OnCreated()
	--if IsServer() then -- and self:GetParent() ~= self:GetCaster()
		local hCaster = self:GetCaster()
		self.kills = 0

		local EffectName = "particles/units/heroes/hero_nevermore/nevermore_trail.vpcf"
		local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hCaster )
	--end
end

function modifier_archon_passive_soul:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_soul:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_TOOLTIP,
	}
	return funcs
end

-- function modifier_archon_passive_soul:GetEffectName()
-- 	return "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_echoslam_proj_detail.vpcf"
-- end

function modifier_archon_passive_soul:GetTexture(  )
    return "linghun"
end

function modifier_archon_passive_soul:OnDeath(args)
	--if not IsServer() then return end
    local hAttacker = args.attacker
	local hCaster = self:GetParent()
	local nLevel = self:GetAbility():GetLevel()
	if hAttacker ~= hCaster then
		return
	end
    self.kills = self.kills + 1
    if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then 
		self.kills = self.kills + 1
	elseif nLevel >= ABILITY_AWAKEN_2 then
		self.kills = self.kills + 3
	end
	--print("kills=======================>", self.kills)
    hCaster:SetModifierStackCount( "modifier_archon_passive_soul", hCaster, self.kills )
end

function modifier_archon_passive_soul:OnAttackLanded( params )
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

	-- particles/econ/items/centaur/centaur_ti9/centaur_double_edge_ti9_hit_tgt.vpcf
	-- particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf
	-- local EffectName = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))	
	
	-- -- 新建特效
	-- local EffectName_1 = "particles/down_particles/red/down_particles_red.vpcf"
	-- local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_1, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_1, 2, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_1, 3, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_1, 4, hTarget:GetAbsOrigin())

	-- local EffectName_2 = "particles/econ/items/centaur/centaur_ti9/centaur_double_edge_ti9_hit_tgt.vpcf"
	-- local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_2, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_2, 2, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex_2, 3, hTarget:GetAbsOrigin())

	hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_soul_particles", {duration = 1})

	EmitSoundOn( "Hero_Nevermore.Shadowraze", hTarget )
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

	local abil_damage = self:GetParent():GetModifierStackCount("modifier_archon_passive_soul", nil) * damage_coefficient
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

function modifier_archon_passive_soul:OnTooltip()
	if IsValidEntity(self:GetCaster()) then
		return self:GetParent():GetModifierStackCount("modifier_archon_passive_soul", nil)
	end
	return 0
end

if modifier_archon_passive_soul_particles == nil then 
	modifier_archon_passive_soul_particles = class({})
end

function modifier_archon_passive_soul_particles:IsHidden()
	return true
end

function modifier_archon_passive_soul_particles:OnCreated( args )
	--if not IsServer() then return end
	local hParent = self:GetParent()
	--local hTarget = args.target
	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then
		local EffectName = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 3, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 4, hParent:GetAbsOrigin())
		-- 新建特效
		local EffectName_1 = "particles/down_particles/red/down_particles_red.vpcf"
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 2, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 3, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 4, hParent:GetAbsOrigin())

		local EffectName_2 = "particles/econ/items/centaur/centaur_ti9/centaur_double_edge_ti9_hit_tgt.vpcf"
		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 2, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex_2, 3, hParent:GetAbsOrigin())
	end
end

function modifier_archon_passive_soul_particles:OnDestroy()
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