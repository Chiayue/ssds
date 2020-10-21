-- 被动技能(酷炫) 虚空锁定
LinkLuaModifier("modifier_archon_passive_void_lock_debuff", "ability/modifier/modifier_gem_void_lock", LUA_MODIFIER_MOTION_NONE)

if modifier_gem_void_lock == nil then 
	modifier_gem_void_lock = class({})
end

--local timer_built_cooldown = true -- 内置冷却时间

function modifier_gem_void_lock:IsHidden()
	return false
end

function modifier_gem_void_lock:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_void_lock:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_void_lock:GetTexture()
	return "faceless_void_chronosphere"
end

function modifier_gem_void_lock:OnCreated()
	--if IsServer() then 
		self:StartIntervalThink(15)
		self.timer_built_cooldown = true
	--end
end

function modifier_gem_void_lock:OnIntervalThink( params )
	--if not IsServer() then return end
	self.timer_built_cooldown = true
end

function modifier_gem_void_lock:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_gem_void_lock:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local hTarget = params.target
	local duration = 3
	local int_multiple_damage = 30
	local radius = 500
	local chance = 1
	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	-- 不会同时触发两次效果
    if self.timer_built_cooldown == false then 
    	return
    end
    self.timer_built_cooldown = false
	-- 创建效果
	local EffectName = "particles/test_particles/void_chronosphere/hero_faceless_void_2faceless_void_chronosphere.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ROOTBONE_FOLLOW, hTarget)
	ParticleManager:SetParticleControl(nFXIndex, 0, Vector(radius, radius, radius))
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	-- 范围伤害
	local enemies = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			local damage = {
				victim = enemy,
				attacker = hCaster,
				damage = hCaster:GetIntellect() * int_multiple_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}

			ApplyDamage( damage )

			-- 敌人眩晕BUFF
			enemy:AddNewModifier( 
				self:GetCaster(), 
				self:GetAbility(), 
				"modifier_archon_passive_void_lock_debuff", 
				{ duration = duration} 
			)
			
		end
	end
end

---------------------------------------眩晕BUFF---------------------------------------
if modifier_archon_passive_void_lock_debuff == nil then 
	modifier_archon_passive_void_lock_debuff = class({})
end

function modifier_archon_passive_void_lock_debuff:IsHidden()
	return false
end

function modifier_archon_passive_void_lock_debuff:GetTexture()
	return "faceless_void_chronosphere"
end

function modifier_archon_passive_void_lock_debuff:IsDebuff( ... )
	return true
end

function modifier_archon_passive_void_lock_debuff:IsStunDebuff() -- 是否是眩晕的效果
	return true
end

function modifier_archon_passive_void_lock_debuff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_void_lock_debuff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_void_lock_debuff:CheckState() -- 修饰器的状态 调整为启用
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
	return state
end

function modifier_archon_passive_void_lock_debuff:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
		}
end

-- function modifier_archon_passive_void_lock_debuff:GetEffectName()
-- 	return "particles/generic_gameplay/generic_stunned.vpcf" -- 眩晕特效
-- end

function modifier_archon_passive_void_lock_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_archon_passive_void_lock_debuff:GetOverrideAnimation( ... )
	return ACT_DOTA_DISABLED -- 伤残动画
end