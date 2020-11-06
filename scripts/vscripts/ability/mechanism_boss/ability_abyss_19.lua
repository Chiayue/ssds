-- 追踪导弹		ability_abyss_19

LinkLuaModifier("modifier_ability_abyss_19", "ability/mechanism_Boss/ability_abyss_19", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ability_abyss_19_move", "ability/mechanism_Boss/ability_abyss_19", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_ability_abyss_19_control", "ability/mechanism_Boss/ability_abyss_19", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_19 == nil then
	ability_abyss_19 = class({})
end

function ability_abyss_19:IsHidden( ... )
	return true
end

function ability_abyss_19:OnSpellStart( ... )
    local hCaster = self:GetCaster()

	local enemys = FindUnitsInRadius(
				hCaster:GetTeamNumber(),
				hCaster:GetAbsOrigin(), 
				hCaster,
				99999, 
				DOTA_UNIT_TARGET_TEAM_ENEMY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 0, false)
	for _,enemy in pairs(enemys) do
        if #enemy <= 1 then 
            Unity_Name = enemy
            Unity_Name.hit = false
            --enemy:AddNewModifier(hCaster, self, "modifier_ability_abyss_19_damage", {})
        end
    end

    local starting_distance = 20
    Unity_Name.position = hCaster:GetAbsOrigin() + starting_distance * hCaster:GetForwardVector()
    
    self.mob = CreateUnitByName("track_missiles_unit", hCaster:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, 100), true, nil, nil, DOTA_TEAM_BADGUYS)
    self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_19_move", {})
    self.mob:AddNewModifier(hCaster, self, "modifier_ability_abyss_19", {})
    self.mob:SetOwner(hCaster)
    self.mob:SetTeam(3)
end

-- function ability_abyss_19:GetIntrinsicModifierName()
-- 	return "modifier_ability_abyss_19"
-- end

if modifier_ability_abyss_19 == nil then 
	modifier_ability_abyss_19 = class({})
end

function modifier_ability_abyss_19:IsHidden( ... )
	return true
end

function modifier_ability_abyss_19:DeclareFunctions( ... )
	return{
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_AVOID_DAMAGE, -- return 	keys.damage  直接免伤所有伤害(包括技能带来的所有伤害)
	}
end

function modifier_ability_abyss_19:OnAttackLanded( keys )
	local attacker = keys.attacker
	local hParent = self:GetParent()
	if attacker:GetTeam() == DOTA_TEAM_BADGUYS then
		return
	end
	if hParent ~= keys.target then 
		return
	end

	local max_heal = hParent:GetHealth()
	local health = (max_heal - 1)
	hParent:SetHealth( health )
	if attacker:IsRealHero() then 
        if health <= 0 then
            hParent:RemoveModifierByName("modifier_ability_abyss_19_move")
            hParent:ForceKill(true)
            UTIL_Remove(hParent)
		end
	end
end

function modifier_ability_abyss_19:GetModifierAvoidDamage( keys )
	return keys.damage
end

-- 导弹的移动
if modifier_ability_abyss_19_move == nil then 
    modifier_ability_abyss_19_move = class({})
end

function modifier_ability_abyss_19_move:IsHidden( ... )
	return false
end

function modifier_ability_abyss_19_move:OnCreated( ... )
    local hParent = self:GetParent()
    self.time_passed = 0
    self.time_effect = 0

    local Effects_0 = "particles/units/heroes/hero_gyrocopter/gyro_homing_missile_fuse.vpcf"
    self.particle_1 = ParticleManager:CreateParticle(Effects_0, PATTACH_ABSORIGIN_FOLLOW, hParent) 
    ParticleManager:SetParticleControlEnt(self.particle_1, 1, hParent, PATTACH_POINT_FOLLOW, "attach_hitloc", hParent:GetAbsOrigin(), true)

    local Effects_2 = "particles/units/heroes/hero_gyrocopter/gyro_guided_missile_target.vpcf"
    self.particle_2 = ParticleManager:CreateParticle(Effects_2, PATTACH_OVERHEAD_FOLLOW, Unity_Name) 
    ParticleManager:SetParticleControl(self.particle_2, 0, Vector(0, 0, 0))

    if IsServer() then 
        self:StartIntervalThink(0.02)
    end
end

function modifier_ability_abyss_19_move:OnDestroy( ... )
    ParticleManager:DestroyParticle( self.particle_2, false )
    ParticleManager:ReleaseParticleIndex( self.particle_2 )
    self.particle_2 = nil
end

function modifier_ability_abyss_19_move:OnIntervalThink( ... )
    if not IsServer() then return end 
    local hParent = self:GetParent()
    -- 导弹与目标的位置
    local vector_distance = Unity_Name:GetAbsOrigin() - hParent:GetAbsOrigin()
    local distance = (vector_distance):Length2D()   -- 距离
    local direction = (vector_distance):Normalized() -- 方向

    local speed = 340 * 0.02
    local acceleration = 20 * 0.02 -- 加速度
    
    self.time_passed = self.time_passed + 0.02
    -- 准备时间结束
    if self.time_passed > 3 then
        if distance < 50 then 
            -- Unity_Name.hit = true 
            -- local travel_vector_distance = hParent:GetAbsOrigin() - Unity_Name.position
            -- local travel_distance = travel_vector_distance:Length2D()
            
            Unity_Name:AddNewModifier(hParent, self:GetAbility(), "modifier_stunned", {duration = 2})

            hParent:RemoveModifierByName("modifier_ability_abyss_19_move")
            hParent:ForceKill(true)
            UTIL_Remove(hParent)
        else 
            local Effects_0 = "particles/units/heroes/hero_gyrocopter/gyro_base_attack.vpcf"
            self.particle = ParticleManager:CreateParticle(Effects_0, PATTACH_ABSORIGIN_FOLLOW, hParent) 
            ParticleManager:SetParticleControlEnt(self.particle, 0, hParent, PATTACH_POINT_FOLLOW, "attach_fuse", hParent:GetAbsOrigin(), true) 
            ParticleManager:SetParticleControlEnt(self.particle, 1, hParent, PATTACH_POINT_FOLLOW, "attach_fuse", hParent:GetAbsOrigin(), true) 
            ParticleManager:SetParticleControlEnt(self.particle, 2, hParent, PATTACH_POINT_FOLLOW, "attach_fuse", hParent:GetAbsOrigin(), true) 
            ParticleManager:SetParticleControlEnt(self.particle, 3, hParent, PATTACH_POINT_FOLLOW, "attach_fuse", hParent:GetAbsOrigin(), true) 
            ParticleManager:DestroyParticle( self.particle, false )
            ParticleManager:ReleaseParticleIndex( self.particle )
            self.particle = nil

            -- 使导弹朝向目标
            hParent:SetForwardVector(Vector(direction.x/2, direction.y/2, -1))

            -- 计算发射后的时间，这样我们可以求解新的速度(在加速后)
            local move_duration = math.modf(self.time_passed - 10)
            speed = speed + acceleration * move_duration
            -- 移动导弹
            hParent:SetAbsOrigin(hParent:GetAbsOrigin() + direction * speed)
            hParent:SetAbsOrigin(Vector(hParent:GetAbsOrigin().x ,hParent:GetAbsOrigin().y, 300))
        end
    end
end