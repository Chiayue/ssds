-- 酷炫被动 暗影沉寂

LinkLuaModifier("modifier_archon_passive_shadow_quiet_debuff", "ability/modifier/modifier_gem_shadow_quiet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_shadow_quiet_frozen_debuff", "ability/modifier/modifier_gem_shadow_quiet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_shadow_quiet_sleep_debuff", "ability/modifier/modifier_gem_shadow_quiet", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_shadow_quiet_shadow_damage", "ability/modifier/modifier_gem_shadow_quiet", LUA_MODIFIER_MOTION_NONE)

--local timer_built_cooldown = true -- 内置冷却时间

if modifier_gem_shadow_quiet == nil then 
	modifier_gem_shadow_quiet = class({})
end

function modifier_gem_shadow_quiet:IsHidden( ... )
	return false
end

function modifier_gem_shadow_quiet:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_shadow_quiet:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_shadow_quiet:GetTexture()
	return "shadow_quiet"
end

function modifier_gem_shadow_quiet:OnCreated()
	--if IsServer() then 
		self:StartIntervalThink(15)
		self.timer_built_cooldown = true
	--end
end

function modifier_gem_shadow_quiet:OnIntervalThink( params )
	--if not IsServer() then return end
	self.timer_built_cooldown = true
end

function modifier_gem_shadow_quiet:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_gem_shadow_quiet:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local hTarget = params.target
	local hTarget_pos = hTarget:GetOrigin()
	local duration = 5
	local chance = 1
	local radius = 500
	local attack_multiple = 10
	local sleep_duration = 3 -- 睡眠效果持续时间

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	-- 不会同时触发两次效果
    if self.timer_built_cooldown == false then 
    	return
    end
    self.timer_built_cooldown = false
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
	-- 一开始就造成500范围内的敌人睡眠
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			
			local damage = {
				victim = enemy,
				attacker = hCaster,
				damage =  hCaster:GetAgility() * attack_multiple,
				damage_type = DAMAGE_TYPE_PHYSICAL,
			}

			ApplyDamage( damage )
			
			-- 敌人睡眠BUFF
			enemy:AddNewModifier( 
				hCaster, 
				self:GetAbility(), 
				"modifier_archon_passive_shadow_quiet_sleep_debuff", 
				{ duration = sleep_duration} 
			)
		end
	end

	-- 新建一个与NPC不相关的modifier 来实现伤害和减速的效果
	CreateModifierThinker(hCaster, self:GetAbility(), "modifier_archon_passive_shadow_quiet_debuff", {duration = duration}, hTarget_pos, hCaster:GetTeamNumber(), false)
end

if modifier_archon_passive_shadow_quiet_debuff == nil then 
	modifier_archon_passive_shadow_quiet_debuff = class({})
end

function modifier_archon_passive_shadow_quiet_debuff:IsHidden()
	return true
end

function modifier_archon_passive_shadow_quiet_debuff:IsDebuff( ... )
	return true
end

function modifier_archon_passive_shadow_quiet_debuff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_shadow_quiet_debuff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_shadow_quiet_debuff:IsAura()
	return true
end

function modifier_archon_passive_shadow_quiet_debuff:GetModifierAura()
	return "modifier_archon_passive_shadow_quiet_frozen_debuff"
end

function modifier_archon_passive_shadow_quiet_debuff:GetAuraRadius()
	--if not IsServer() then return end
	return self.radius
end

function modifier_archon_passive_shadow_quiet_debuff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_archon_passive_shadow_quiet_debuff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_archon_passive_shadow_quiet_debuff:OnCreated( params )
---------------------------------------------- 创建效果(组合特效) ---------------------------------------------------
	--if not IsServer() then return end
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()
	self.radius = 500

	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then
		local EffectName = "particles/units/heroes/hero_void_spirit/void_spirit_entryportal_2.vpcf" 
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl(hParent.nFXIndex, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 3, Vector(self.radius, 1, 1))

		local EffectName_1 = "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf" 
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl( hParent.nFXIndex_1, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hParent.nFXIndex_1, 3, Vector(self.radius, 1, 1))

		local EffectName_2 = "particles/units/heroes/hero_void_spirit/planeshift/void_spirit_planeshift_untargetable.vpcf" 
		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl( hParent.nFXIndex_2, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hParent.nFXIndex_2, 3, Vector(self.radius, 1, 1))
	end
----------------------------------------------------------------------------------------------------------
end

function modifier_archon_passive_shadow_quiet_debuff:OnRefresh(params)
	--if not IsServer() then return end
	self.radius = 500
end

function modifier_archon_passive_shadow_quiet_debuff:OnDestroy(params)
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
-----------------------------------------damge-----------------------------------------
if modifier_archon_passive_shadow_quiet_frozen_debuff == nil then 
	modifier_archon_passive_shadow_quiet_frozen_debuff = class({})
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:IsHidden()
	return true
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:IsDebuff()
	return true
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_shadow_quiet_frozen_debuff:RemoveOnDeath()
    return false -- 死亡不移除
end

-- 在命中的敌人脚下生成一个暗影特效。
function modifier_archon_passive_shadow_quiet_frozen_debuff:OnCreated(params)
	--if not IsServer() then return end
	--self.speed_cut = 100
	self.radius = 500

	self:StartIntervalThink(0.5)
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:OnIntervalThink( params )
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()

	if IsServer() then
		local duration = 5
		-- 范围寻找
		local enemies = FindUnitsInRadius(
			hCaster:GetTeamNumber(), 
			hParent:GetOrigin(), 
			hParent, 
			self.radius, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
			0, 0, false 
		)

		for _,enemy in pairs(enemies) do
			if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

				-- 敌人寒气BUFF
				enemy:AddNewModifier( 
					hCaster, 
					self:GetAbility(), 
					"modifier_archon_passive_shadow_quiet_shadow_damage", 
					{ duration = duration} 
				)
				
			end
		end
	end
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:OnRefresh( ... )
	--if not IsServer() then return end
	self.radius = 500
	--self.speed_cut = 100
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:DeclareFunctions( ... )
	return 
		{
			--MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
		}
end

function modifier_archon_passive_shadow_quiet_frozen_debuff:GetModifierMoveSpeedBonus_Constant( ... )
	--if not IsServer() then return end
	return -100
end

-- 敌人睡眠DeBuff
if modifier_archon_passive_shadow_quiet_sleep_debuff == nil then
	modifier_archon_passive_shadow_quiet_sleep_debuff = class({})
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:IsHidden()
	return true
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:IsDebuff( ... )
	return true
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:IsStunDebuff() -- 是否是眩晕的效果
	return true
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_shadow_quiet_sleep_debuff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:CheckState() -- 修饰器的状态 调整为启用
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
	return state
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
		}
end

-- function modifier_archon_passive_shadow_quiet_sleep_debuff:GetEffectName()
-- 	return "particles/newplayer_fx/npx_sleeping.vpcf" -- 睡眠特效
-- end

function modifier_archon_passive_shadow_quiet_sleep_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_archon_passive_shadow_quiet_sleep_debuff:GetOverrideAnimation( ... )
	return ACT_DOTA_DISABLED -- 出生动画      -- 睡眠动画
end

---------------------------------------------暗影持续伤害------------------------------------
if modifier_archon_passive_shadow_quiet_shadow_damage == nil then 
	modifier_archon_passive_shadow_quiet_shadow_damage = class({})
end

function modifier_archon_passive_shadow_quiet_shadow_damage:IsHidden()
	return false
end

function modifier_archon_passive_shadow_quiet_shadow_damage:GetTexture()
	return "shadow_quiet"
end

function modifier_archon_passive_shadow_quiet_shadow_damage:IsDebuff()
	return true
end

function modifier_archon_passive_shadow_quiet_shadow_damage:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_shadow_quiet_shadow_damage:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_shadow_quiet_shadow_damage:OnCreated(params)
	--if not IsServer() then return end
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	--self.timer_attack_multiple = 3
	
	local EffectName = "particles/units/heroes/hero_void_spirit/void_spirit_warp_dust_dark.vpcf" -- 暗影标志特效
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent)
	self:AddParticle(nFXIndex, false, false, -1, false, false)

	-- local EffectName_1 = "particles/killstreak/killstreak_fire_flames_lv2_hud.vpcf" -- 身体燃烧特效
	-- local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ROOTBONE_FOLLOW, hParent)
	-- self:AddParticle(nFXIndex_1, false, false, -1, false, false)

	self:StartIntervalThink(1)
end

function modifier_archon_passive_shadow_quiet_shadow_damage:OnIntervalThink( params )
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()

	if IsServer() then
		ApplyDamage(
		{
			attacker = hCaster,
			victim = hParent,
			damage = hCaster:GetAgility() * 3,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		)

	end
end

-- function modifier_archon_passive_shadow_quiet_shadow_damage:OnRefresh( ... )
-- 	--if not IsServer() then return end
-- 	self.timer_attack_multiple = 3
-- end