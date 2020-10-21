-- 酷炫被动 大地爆裂
LinkLuaModifier("modifier_archon_passive_earth_burst_debuff", "ability/modifier/modifier_gem_earth_burst", LUA_MODIFIER_MOTION_NONE)

if modifier_gem_earth_burst == nil then 
	modifier_gem_earth_burst = class({})
end

--local timer_built_cooldown = true -- 内置冷却时间

function modifier_gem_earth_burst:IsHidden( ... )
	return false
end

function modifier_gem_earth_burst:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_earth_burst:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_earth_burst:GetTexture()
	return "earth_burst"
end

function modifier_gem_earth_burst:OnCreated()
	--if IsServer() then 
		self:StartIntervalThink(15)
		self.timer_built_cooldown = true
	--end
end

function modifier_gem_earth_burst:OnIntervalThink( params )
	--if not IsServer() then return end
	self.timer_built_cooldown = true
end

function modifier_gem_earth_burst:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_gem_earth_burst:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local hTarget = params.target
	local duration = 1
	local chance = 1
	local radius = 500
	local attack_multiple = 30

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	-- 不会同时触发两次效果
    if self.timer_built_cooldown == false then 
    	return
    end
    self.timer_built_cooldown = false
	-- -- 创建效果
	local EffectName_0 = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_magical.vpcf"
	local nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_ROOTBONE_FOLLOW, hTarget)
	ParticleManager:DestroyParticle( nFXIndex_0, false )
	ParticleManager:ReleaseParticleIndex( nFXIndex_0 )
	
	local EffectName_1 = "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf"
	local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ROOTBONE_FOLLOW, hTarget)
	ParticleManager:DestroyParticle( nFXIndex_1, false )
	ParticleManager:ReleaseParticleIndex( nFXIndex_1 )

	local EffectName_2 = "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf"
	local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ROOTBONE_FOLLOW, hTarget)
	ParticleManager:DestroyParticle( nFXIndex_2, false )
	ParticleManager:ReleaseParticleIndex( nFXIndex_2 )

	local EffectName_3 = "particles/units/heroes/hero_brewmaster/brewmaster_pulverize.vpcf"
	local nFXIndex_3 = ParticleManager:CreateParticle( EffectName_3, PATTACH_ROOTBONE_FOLLOW, hTarget)
	ParticleManager:DestroyParticle( nFXIndex_3, false )
	ParticleManager:ReleaseParticleIndex( nFXIndex_3 )

	-- 范围搜索
	local enemies = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)
	-- 一开始就造成500范围内的敌人击飞 
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			
			local damage = {
				victim = enemy,
				attacker = hCaster,
				damage = hCaster:GetStrength() * attack_multiple,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

			ApplyDamage( damage )

			local knockbackModifierTable =
				{
				should_stun = 1,
				knockback_duration = duration,
				duration = duration,
				knockback_distance = 0,
				knockback_height = 100,
				center_x = hTarget:GetAbsOrigin().x,
				center_y = hTarget:GetAbsOrigin().y,
				center_z = hTarget:GetAbsOrigin().z
				}

			-- 敌人击飞   系统自带的击飞 modifier 
			enemy:AddNewModifier( hCaster, nil, "modifier_knockback", knockbackModifierTable )
			
		end
	end

end