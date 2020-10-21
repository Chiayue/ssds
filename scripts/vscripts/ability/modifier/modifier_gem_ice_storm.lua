-- 被动技能(酷炫) 冰川风暴
LinkLuaModifier("modifier_archon_passive_Ice_storm_aureole", "ability/modifier/modifier_gem_Ice_storm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_Ice_storm_frozen_debuff", "ability/modifier/modifier_gem_Ice_storm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_Ice_storm_damge", "ability/modifier/modifier_gem_Ice_storm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_Ice_storm_continue_damge", "ability/modifier/modifier_gem_Ice_storm", LUA_MODIFIER_MOTION_NONE)

if modifier_gem_Ice_storm == nil then 
	modifier_gem_Ice_storm = class({})
end

--local timer_built_cooldown = true -- 内置冷却时间

function modifier_gem_Ice_storm:IsHidden( ... )
	return false
end

function modifier_gem_Ice_storm:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_Ice_storm:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_Ice_storm:GetTexture()
	return "Ice_storm"
end

function modifier_gem_Ice_storm:OnCreated()
	--if IsServer() then 
		self:StartIntervalThink(15)
		self.timer_built_cooldown = true
	--end
end

function modifier_gem_Ice_storm:OnIntervalThink( params )
	--if not IsServer() then return end
	self.timer_built_cooldown = true
end

function modifier_gem_Ice_storm:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_gem_Ice_storm:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local hTarget = params.target
	local hTarget_pos = hTarget:GetOrigin()
	local duration = 5
	local frozen_duration = 3 -- 冰冻效果持续时间
	local chance = 1
	local radius = 500
	local attack_multiple = 10

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
	-- 一开始就造成500范围内的敌人冰冻 
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			
			local damage = {
				victim = enemy,
				attacker = hCaster,
				damage = hCaster:GetIntellect() * attack_multiple,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}

			ApplyDamage( damage )

			-- 敌人冰冻BUFF
			enemy:AddNewModifier( 
				self:GetCaster(), 
				self:GetAbility(), 
				"modifier_archon_passive_Ice_storm_frozen_debuff", 
				{ duration = frozen_duration} 
			)
			
		end
	end

	-- 在命中的敌人脚下生成一个冰川风暴。只要有敌人经过  就必然感染冷气 10秒 

	-- 新建一个与NPC不相关的modifier 来实现伤害和减速的效果
	CreateModifierThinker(hCaster, self:GetAbility(), "modifier_archon_passive_Ice_storm_aureole", {duration = duration}, hTarget_pos, hCaster:GetTeamNumber(), false)
end

---------------------------------------毒液光环---------------------------------------
if modifier_archon_passive_Ice_storm_aureole == nil then 
	modifier_archon_passive_Ice_storm_aureole = class({})
end

function modifier_archon_passive_Ice_storm_aureole:IsHidden()
	return true
end

function modifier_archon_passive_Ice_storm_aureole:IsDebuff( ... )
	return true
end

function modifier_archon_passive_Ice_storm_aureole:IsAura()
	return true
end

function modifier_archon_passive_Ice_storm_aureole:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_Ice_storm_aureole:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_Ice_storm_aureole:GetModifierAura()
	return "modifier_archon_passive_Ice_storm_damge"
end

function modifier_archon_passive_Ice_storm_aureole:GetAuraRadius()
	--if not IsServer() then return end
	return self.radius
end

function modifier_archon_passive_Ice_storm_aureole:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_archon_passive_Ice_storm_aureole:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_archon_passive_Ice_storm_aureole:OnCreated( params )
---------------------------------------------- 创建效果 ---------------------------------------------------
	--if not IsServer() then return end
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()
	self.radius = 500

	if not hParent.nFXIndex then
		local EffectName = "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7_2buff.vpcf" -- 冰川风暴特效
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl( hParent.nFXIndex, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hParent.nFXIndex, 3, Vector(self.radius, 1, 1))
	end
----------------------------------------------------------------------------------------------------------
end

function modifier_archon_passive_Ice_storm_aureole:OnRefresh(params)
	--if not IsServer() then return end
	self.radius = 500
end

function modifier_archon_passive_Ice_storm_aureole:OnDestroy(params)
	--if not IsServer() then return end
	local hParent = self:GetParent()
	if hParent.nFXIndex then 
		ParticleManager:DestroyParticle( hParent.nFXIndex, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex )
		hParent.nFXIndex = nil
	end
end
-----------------------------------------伤害--------------------------------------------------------------
if modifier_archon_passive_Ice_storm_damge == nil then 
	modifier_archon_passive_Ice_storm_damge = class({})
end

function modifier_archon_passive_Ice_storm_damge:IsHidden()
	return true
end

function modifier_archon_passive_Ice_storm_damge:IsDebuff()
	return true
end

function modifier_archon_passive_Ice_storm_damge:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_Ice_storm_damge:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_Ice_storm_damge:OnCreated(params)
	--if not IsServer() then return end
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	--self.speed_cut = 100
	self.radius = 500

	self:StartIntervalThink(0.5)
end

function modifier_archon_passive_Ice_storm_damge:OnIntervalThink( params )
	
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	local hAbility = self:GetAbility()

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
					"modifier_archon_passive_Ice_storm_continue_damge", 
					{ duration = duration} 
				)
				
			end
		end
	end
end

function modifier_archon_passive_Ice_storm_damge:OnRefresh( ... )
	--if not IsServer() then return end
	self.radius = 500
	--self.speed_cut = 100
end

function modifier_archon_passive_Ice_storm_damge:DeclareFunctions( ... )
	return 
		{
			--MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
		}
end

function modifier_archon_passive_Ice_storm_damge:GetModifierMoveSpeedBonus_Constant( ... )
	--if not IsServer() then return end
	return -100
end

-------------------------------------------冰冻BUFF--------------------------------------------
if modifier_archon_passive_Ice_storm_frozen_debuff == nil then
	modifier_archon_passive_Ice_storm_frozen_debuff = class({})
end

function modifier_archon_passive_Ice_storm_frozen_debuff:IsHidden()
	return true
end

function modifier_archon_passive_Ice_storm_frozen_debuff:IsDebuff( ... )
	return true
end

function modifier_archon_passive_Ice_storm_frozen_debuff:IsStunDebuff() -- 是否是眩晕的效果
	return true
end

function modifier_archon_passive_Ice_storm_frozen_debuff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_Ice_storm_frozen_debuff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_Ice_storm_frozen_debuff:CheckState() -- 修饰器的状态 调整为启用
	local state = 
	{
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
	}
	return state
end

function modifier_archon_passive_Ice_storm_frozen_debuff:DeclareFunctions( ... )
	return 
		{
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
		}
end

-- function modifier_archon_passive_Ice_storm_frozen_debuff:GetEffectName()
-- 	return "particles/heroes/cirno/ability_cirno_04_buff.vpcf" -- 冰冻特效
-- end

function modifier_archon_passive_Ice_storm_frozen_debuff:GetOverrideAnimation( ... )
	return ACT_DOTA_DISABLED -- 伤残动画
end

--------------------------------------------寒气的持续伤害----------------------------------------------
if modifier_archon_passive_Ice_storm_continue_damge == nil then
	modifier_archon_passive_Ice_storm_continue_damge = class({})
end

function modifier_archon_passive_Ice_storm_continue_damge:IsHidden()
	return false
end

function modifier_archon_passive_Ice_storm_continue_damge:GetTexture()
	return "Ice_storm"
end

function modifier_archon_passive_Ice_storm_continue_damge:IsDebuff()
	return true
end

function modifier_archon_passive_Ice_storm_continue_damge:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_Ice_storm_continue_damge:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_Ice_storm_continue_damge:OnCreated(params)
	--if not IsServer() then return end
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	--self.timer_attack_multiple = 3
	
	-- local EffectName = "particles/units/heroes/hero_invoker/invoker_ice_wall_debuff_frost.vpcf" -- 冰气特效
	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN_FOLLOW, hParent)
	-- self:AddParticle(nFXIndex, false, false, -1, false, false)

	self:StartIntervalThink(1)
end

function modifier_archon_passive_Ice_storm_continue_damge:OnIntervalThink( params )
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()

	if IsServer() then
		ApplyDamage(
		{
			attacker = hCaster,
			victim = hParent,
			damage = hCaster:GetIntellect() * 3,
			damage_type = DAMAGE_TYPE_MAGICAL,
		}
		)

	end
end

-- function modifier_archon_passive_Ice_storm_continue_damge:OnRefresh( ... )
-- 	--if not IsServer() then return end
-- 	self.timer_attack_multiple = 3
-- end