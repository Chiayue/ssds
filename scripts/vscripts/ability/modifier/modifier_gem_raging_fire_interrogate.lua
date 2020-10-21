-- 被动技能(酷炫) 烈火审讯
LinkLuaModifier("modifier_archon_passive_raging_fire_interrogate_debuff", "ability/modifier/modifier_gem_raging_fire_interrogate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_raging_fire_interrogate_damge", "ability/modifier/modifier_gem_raging_fire_interrogate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_raging_fire_interrogate_duration_damge", "ability/modifier/modifier_gem_raging_fire_interrogate", LUA_MODIFIER_MOTION_NONE)

if modifier_gem_raging_fire_interrogate == nil then 
	modifier_gem_raging_fire_interrogate = class({})
end

--local timer_built_cooldown = true -- 内置冷却时间

function modifier_gem_raging_fire_interrogate:IsHidden( ... )
	return false
end

function modifier_gem_raging_fire_interrogate:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_raging_fire_interrogate:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_raging_fire_interrogate:GetTexture()
	return "raging_fire_interrogate"
end

function modifier_gem_raging_fire_interrogate:OnCreated()
	--if IsServer() then 
		self:StartIntervalThink(15)
		self.timer_built_cooldown = true
	--end
end

function modifier_gem_raging_fire_interrogate:OnIntervalThink( params )
	--if not IsServer() then return end
	self.timer_built_cooldown = true
end

function modifier_gem_raging_fire_interrogate:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_gem_raging_fire_interrogate:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local hTarget = params.target
	local hTarget_pos = hTarget:GetOrigin()
	local duration = 5
	local radius = 500
	local chance = 1
	local attack_multiple = 15
	

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	-- 不会同时触发两次效果
    if self.timer_built_cooldown == false then 
    	return
    end
    self.timer_built_cooldown = false
	-- 范围寻找
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
			local damage = 
				{
					victim = enemy,
					attacker = hCaster,
					damage = hCaster:GetStrength() * attack_multiple,
					damage_type = DAMAGE_TYPE_PHYSICAL,
				}
			ApplyDamage(damage)
		end
	end

	-- 新建一个与NPC不相关的modifier 来实现伤害和减速的效果
	CreateModifierThinker(hCaster, self:GetAbility(), "modifier_archon_passive_raging_fire_interrogate_debuff", {duration = duration}, hTarget_pos, hCaster:GetTeamNumber(), false)
end

---------------------------------------岩浆BUFF---------------------------------------
if modifier_archon_passive_raging_fire_interrogate_debuff == nil then 
	modifier_archon_passive_raging_fire_interrogate_debuff = class({})
end

function modifier_archon_passive_raging_fire_interrogate_debuff:IsHidden()
	return true
end

function modifier_archon_passive_raging_fire_interrogate_debuff:IsDebuff( ... )
	return true
end

function modifier_archon_passive_raging_fire_interrogate_debuff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_raging_fire_interrogate_debuff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_raging_fire_interrogate_debuff:IsAura()
	return true
end

function modifier_archon_passive_raging_fire_interrogate_debuff:GetModifierAura()
	return "modifier_archon_passive_raging_fire_interrogate_damge"
end

function modifier_archon_passive_raging_fire_interrogate_debuff:GetAuraRadius()
	--if not IsServer() then return end
	return self.radius
end

function modifier_archon_passive_raging_fire_interrogate_debuff:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_archon_passive_raging_fire_interrogate_debuff:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
end

function modifier_archon_passive_raging_fire_interrogate_debuff:OnCreated( params )
---------------------------------------------- 创建效果(组合特效) ---------------------------------------------------
	--if not IsServer() then return end
	local hCaster = self:GetCaster()
	local hParent = self:GetParent()
	self.radius = 500

	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then
		local EffectName = "particles/heroes/thtd_futo/ability_thtd_futo_03.vpcf" 
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl( hParent.nFXIndex, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hParent.nFXIndex, 3, Vector(self.radius, 1, 1))

		local EffectName_1 = "particles/units/heroes/hero_phoenix/phoenix_supernova_egg_loadout.vpcf" 
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl( hParent.nFXIndex_1, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hParent.nFXIndex_1, 3, Vector(self.radius, 1, 1))
	
		local EffectName_2 = "particles/units/heroes/hero_snapfire/hero_snapfire_ult_2imate_linger.vpcf" 
		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_WORLDORIGIN, hParent)
		ParticleManager:SetParticleControl( hParent.nFXIndex_2, 0, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl( hParent.nFXIndex_2, 3, Vector(self.radius, 1, 1))
	end
----------------------------------------------------------------------------------------------------------
end

function modifier_archon_passive_raging_fire_interrogate_debuff:OnRefresh(params)
	--if not IsServer() then return end
	self.radius = 500
end

function modifier_archon_passive_raging_fire_interrogate_debuff:OnDestroy(params)
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
if modifier_archon_passive_raging_fire_interrogate_damge == nil then 
	modifier_archon_passive_raging_fire_interrogate_damge = class({})
end

function modifier_archon_passive_raging_fire_interrogate_damge:IsHidden()
	return true
end

function modifier_archon_passive_raging_fire_interrogate_damge:IsDebuff()
	return true
end

function modifier_archon_passive_raging_fire_interrogate_damge:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_raging_fire_interrogate_damge:RemoveOnDeath()
    return false -- 死亡不移除
end

-- 在命中的敌人脚下生成一个火焰地带。只要有敌人经过  就必然燃烧 5秒 
-- 如果一直在上面，就一直刷新岩浆灼烧的持续时间
function modifier_archon_passive_raging_fire_interrogate_damge:OnCreated(params)
	--if not IsServer() then return end
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	self.radius = 500
	--self.speed_cut = 100

	--hParent:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_raging_fire_interrogate_duration_damge", {duration = duration})
	self:StartIntervalThink(0.5)
end

function modifier_archon_passive_raging_fire_interrogate_damge:OnIntervalThink( params )
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

				-- 敌人燃烧BUFF
				enemy:AddNewModifier( 
					hCaster, 
					self:GetAbility(), 
					"modifier_archon_passive_raging_fire_interrogate_duration_damge", 
					{ duration = duration} 
				)
				
			end
		end

	end
end

function modifier_archon_passive_raging_fire_interrogate_damge:OnRefresh( ... )
	--if not IsServer() then return end
	self.radius = 500
	--self.speed_cut = 100

end

function modifier_archon_passive_raging_fire_interrogate_damge:DeclareFunctions( ... )
	return 
		{
			--MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
		}
end

function modifier_archon_passive_raging_fire_interrogate_damge:GetModifierMoveSpeedBonus_Constant( ... )
	--if not IsServer() then return end
	return -100
end

----------------------------------------------------------------------------------------------

-- 敌人离开岩浆阵后  燃烧的依然持续造成伤害   直到持续时间结束
if modifier_archon_passive_raging_fire_interrogate_duration_damge == nil then
	modifier_archon_passive_raging_fire_interrogate_duration_damge = class({})
end


function modifier_archon_passive_raging_fire_interrogate_duration_damge:IsHidden()
	return false
end

function modifier_archon_passive_raging_fire_interrogate_duration_damge:GetTexture()
	return "raging_fire_interrogate"
end

function modifier_archon_passive_raging_fire_interrogate_duration_damge:IsDebuff()
	return true
end

function modifier_archon_passive_raging_fire_interrogate_duration_damge:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_archon_passive_raging_fire_interrogate_duration_damge:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_archon_passive_raging_fire_interrogate_duration_damge:OnCreated(params)
	--if not IsServer() then return end
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()
	--self.timer_attack_multiple = 5

	self:StartIntervalThink(1)
end

function modifier_archon_passive_raging_fire_interrogate_duration_damge:OnIntervalThink( params )
	local hParent = self:GetParent()
	local hCaster = self:GetCaster()

	if IsServer() then
		ApplyDamage(
		{
			attacker = hCaster,
			victim = hParent,
			damage = hCaster:GetStrength() * 5,
			damage_type = DAMAGE_TYPE_PHYSICAL,
		}
		)

	end
end

-- function modifier_archon_passive_raging_fire_interrogate_duration_damge:OnRefresh( ... )
-- 	--if not IsServer() then return end
-- 	self.timer_attack_multiple = 5
-- end