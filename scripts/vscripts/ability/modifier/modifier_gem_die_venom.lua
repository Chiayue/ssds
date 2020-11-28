-- 被动技能(酷炫) 死亡毒液
LinkLuaModifier("modifier_archon_passive_die_venom_debuff", "ability/modifier/modifier_gem_die_venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_die_venom_damge", "ability/modifier/modifier_gem_die_venom", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_die_venom_duration_damge", "ability/modifier/modifier_gem_die_venom", LUA_MODIFIER_MOTION_NONE)


if modifier_gem_die_venom == nil then 
	modifier_gem_die_venom = class({})
end

function modifier_gem_die_venom:GetTexture()
	return "pinshengmehewoda"
end

function modifier_gem_die_venom:IsHidden( ... )
	return false
end

function modifier_gem_die_venom:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_die_venom:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_die_venom:OnCreated()
	local hParent = self:GetParent()  -- 不能添加本身的modifier名字
        if hParent:HasModifier("modifier_gem_earth_burst") and  
            hParent:HasModifier("modifier_gem_Ice_storm") and 
            --hParent:HasModifier("modifier_gem_raging_fire_interrogate") and 
            --hParent:HasModifier("modifier_gem_shadow_quiet") and 
            hParent:HasModifier("modifier_gem_void_lock")  and not 
            hParent:HasModifier("modifier_gem_special_buff") 
                then
					hParent:AddNewModifier( hParent, self:GetAbility(), "modifier_gem_special_buff", {} )

					if hParent:HasModifier("modifier_gem_earth_burst") and
					hParent:HasModifier("modifier_gem_die_venom") and 
					hParent:HasModifier("modifier_gem_Ice_storm") and 
					hParent:HasModifier("modifier_gem_void_lock") then 
						hParent:RemoveModifierByName("modifier_gem_earth_burst")
						hParent:RemoveModifierByName("modifier_gem_die_venom")
						hParent:RemoveModifierByName("modifier_gem_Ice_storm")
						hParent:RemoveModifierByName("modifier_gem_void_lock")
					end
                end
end

function modifier_gem_die_venom:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_gem_die_venom:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hParent = self:GetParent()
	local hTarget = params.target
	local chance = 1

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	local EffectName = "particles/heroes/thtd_reimu/ability_reimu_04_explosion.vpcf" 
	self.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControl( self.nFXIndex, 0, hTarget:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndex, 1, hTarget:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndex, 3, hTarget:GetAbsOrigin() )

	local enemies = GetAOEMostTargetsSpellTarget(
		hParent:GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		500, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	)

	local all_damage = (hParent:GetAgility() + hParent:GetStrength() + hParent:GetIntellect()) * 0.1
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			ApplyDamage({
				victim = enemy,
				attacker = hParent,
				damage = all_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			})
		end
	end
end

-- function modifier_gem_die_venom:OnCreated()
-- 	if IsServer() then 
-- 		self:StartIntervalThink(1)
-- 		self.timer_built_cooldown = true
-- 		self.timer_count = 0
-- 	end
-- end

-- function modifier_gem_die_venom:OnIntervalThink( params )
-- 	if not IsServer() then return end -- 设置内置冷却时间 15 秒
	
-- 	if self.timer_built_cooldown == false and self.timer_count == 15 then 
-- 		self.timer_built_cooldown = true
-- 		self.timer_count = 0
-- 	elseif self.timer_built_cooldown == false then 
-- 		self.timer_count = self.timer_count + 1
-- 	end
-- end

-- function modifier_gem_die_venom:DeclareFunctions( ... )
-- 	return 
-- 		{
-- 			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
-- 		}
-- end

-- -- 在命中的敌人脚下生成一个毒液特效。只要有敌人经过  就必然感染毒液 5秒
-- function modifier_gem_die_venom:OnAttackLanded( params )
-- 	if params.attacker ~= self:GetParent() then
-- 		return 0
-- 	end
-- 	-- 不会同时触发两次效果
--     if self.timer_built_cooldown == false then 
--     	return 0
--     end
-- 	local hCaster = self:GetCaster()
-- 	local hTarget = params.target
-- 	local hTarget_pos = hTarget:GetOrigin()
-- 	local duration = 5   -- 持续时间
-- 	local chance = 1     -- 触发几率
-- 	local radius = 500   -- 范围
-- 	local attack_multiple = 15  -- 伤害倍数

-- 	local nowChance = RandomInt(0,100)
-- 	if nowChance  > chance then
-- 		return 0
-- 	end

-- 	-- 范围寻找
-- 		-- local enemies = FindUnitsInRadius(
-- 		-- 	hCaster:GetTeamNumber(), 
-- 		-- 	hTarget:GetOrigin(), 
-- 		-- 	hTarget, 
-- 		-- 	radius, 
-- 		-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, 
-- 		-- 	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
-- 		-- 	0, 0, false 
-- 		-- )
-- 		local enemies = GetAOEMostTargetsSpellTarget(
-- 			hCaster:GetTeamNumber(), 
-- 			hTarget:GetOrigin(), 
-- 			hTarget, 
-- 			radius, 
-- 			DOTA_UNIT_TARGET_TEAM_ENEMY, 
-- 			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
-- 		)

-- 		for _,enemy in pairs(enemies) do
-- 			if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
-- 				local damage = 
-- 					{
-- 						victim = enemy,
-- 						attacker = hCaster,
-- 						damage = hCaster:GetAgility() * attack_multiple,
-- 						damage_type = DAMAGE_TYPE_MAGICAL,
-- 					}
-- 					ApplyDamage(damage)
-- 			end
-- 		end

-- 	-- 新建一个与NPC不相关的modifier 来实现伤害和减速的效果
-- 	CreateModifierThinker(hCaster, self:GetAbility(), "modifier_archon_passive_die_venom_debuff", {duration = duration}, hTarget_pos, hCaster:GetTeamNumber(), false)
-- 	self.timer_built_cooldown = false
-- end

-- ---------------------------------------毒液BUFF---------------------------------------
-- if modifier_archon_passive_die_venom_debuff == nil then 
-- 	modifier_archon_passive_die_venom_debuff = class({})
-- end

-- function modifier_archon_passive_die_venom_debuff:IsHidden()
-- 	return true
-- end

-- function modifier_archon_passive_die_venom_debuff:IsDebuff( ... )
-- 	return true
-- end

-- function modifier_archon_passive_die_venom_debuff:IsAura()
-- 	return true
-- end

-- function modifier_archon_passive_die_venom_debuff:IsPurgable()
--     return false -- 无法驱散
-- end
 
-- function modifier_archon_passive_die_venom_debuff:RemoveOnDeath()
--     return false -- 死亡不移除
-- end

-- function modifier_archon_passive_die_venom_debuff:GetModifierAura()
-- 	return "modifier_archon_passive_die_venom_damge"
-- end

-- function modifier_archon_passive_die_venom_debuff:GetAuraRadius()
-- 	return self.radius
-- end

-- function modifier_archon_passive_die_venom_debuff:GetAuraSearchTeam()
-- 	return DOTA_UNIT_TARGET_TEAM_ENEMY
-- end

-- function modifier_archon_passive_die_venom_debuff:GetAuraSearchType()
-- 	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC 
-- end

-- function modifier_archon_passive_die_venom_debuff:OnCreated( params )
-- ---------------------------------------------- 创建效果 ---------------------------------------------------
-- 	local hCaster = self:GetCaster()
-- 	local hParent = self:GetParent()
-- 	self.radius = 500

-- 	if not hParent.nFXIndex and not hParent.nFXIndex_1 and not hParent.nFXIndex_2 then 
-- 		local EffectName = "particles/units/heroes/hero_rubick/rubick_supernova_egg_2.vpcf" 
-- 		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_WORLDORIGIN, hParent)
-- 		ParticleManager:SetParticleControl( hParent.nFXIndex, 0, hParent:GetAbsOrigin() )
-- 		ParticleManager:SetParticleControl( hParent.nFXIndex, 3, Vector(self.radius, 1, 1) )

-- 		local EffectName_1 = "particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf" 
-- 		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_WORLDORIGIN, hParent)
-- 		ParticleManager:SetParticleControl( hParent.nFXIndex_1, 0, hParent:GetAbsOrigin() )
-- 		ParticleManager:SetParticleControl( hParent.nFXIndex_1, 3, Vector(self.radius, 1, 1) )
		
-- 		local EffectName_2 = "particles/econ/items/viper/viper_immortal_tail_ti8/viper_immortal_ti8_nethertoxin.vpcf" 
-- 		hParent.nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_WORLDORIGIN, hParent)
-- 		ParticleManager:SetParticleControl( hParent.nFXIndex_2, 0, hParent:GetAbsOrigin() )
-- 		ParticleManager:SetParticleControl( hParent.nFXIndex_2, 3, Vector(self.radius, 1, 1) )
-- 	end
-- ----------------------------------------------------------------------------------------------------------
-- end

-- function modifier_archon_passive_die_venom_debuff:OnRefresh(params)
-- 	self.radius = 500
-- end

-- function modifier_archon_passive_die_venom_debuff:OnDestroy(params)
-- 	local hParent = self:GetParent()
-- 	if hParent.nFXIndex and hParent.nFXIndex_1 and hParent.nFXIndex_2 then 
-- 		ParticleManager:DestroyParticle( hParent.nFXIndex, false )
-- 		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex )
-- 		hParent.nFXIndex = nil

-- 		ParticleManager:DestroyParticle( hParent.nFXIndex_1, false )
-- 		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_1 )
-- 		hParent.nFXIndex_1 = nil

-- 		ParticleManager:DestroyParticle( hParent.nFXIndex_2, false )
-- 		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_2 )
-- 		hParent.nFXIndex_2 = nil
-- 	end
-- end
-- -----------------------------------------damge-----------------------------------------
-- if modifier_archon_passive_die_venom_damge == nil then 
-- 	modifier_archon_passive_die_venom_damge = class({})
-- end

-- function modifier_archon_passive_die_venom_damge:IsHidden()
-- 	return true
-- end

-- function modifier_archon_passive_die_venom_damge:IsDebuff()
-- 	return true
-- end

-- function modifier_archon_passive_die_venom_damge:IsPurgable()
--     return false -- 无法驱散
-- end
 
-- function modifier_archon_passive_die_venom_damge:RemoveOnDeath()
--     return false -- 死亡不移除
-- end

-- -- 如果一直在上面，就一直刷新毒液的持续时间
-- function modifier_archon_passive_die_venom_damge:OnCreated(params)
-- 	if IsServer() then 
-- 		local hParent = self:GetParent()
-- 		local hCaster = self:GetCaster()
-- 		self.radius = 500

-- 		self:StartIntervalThink(0.5)
-- 	end
-- end

-- function modifier_archon_passive_die_venom_damge:OnIntervalThink( params )
-- 	local hParent = self:GetParent()
-- 	local hCaster = self:GetCaster()

-- 	if IsServer() then
-- 		local duration = 5
-- 		-- 范围寻找	
-- 		-- local enemies = FindUnitsInRadius(
-- 		-- 	hCaster:GetTeamNumber(), 
-- 		-- 	hParent:GetOrigin(), 
-- 		-- 	hParent, 
-- 		-- 	self.radius, 
-- 		-- 	DOTA_UNIT_TARGET_TEAM_ENEMY, 
-- 		-- 	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
-- 		-- 	0, 0, false 
-- 		-- )
-- 		local enemies = GetAOEMostTargetsSpellTarget(
-- 			hCaster:GetTeamNumber(), 
-- 			hParent:GetOrigin(), 
-- 			hParent, 
-- 			self.radius, 
-- 			DOTA_UNIT_TARGET_TEAM_ENEMY, 
-- 			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
-- 		)

-- 		for _,enemy in pairs(enemies) do
-- 			if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

-- 				-- 敌人毒液BUFF
-- 				enemy:AddNewModifier( 
-- 					hCaster, 
-- 					self:GetAbility(), 
-- 					"modifier_archon_passive_die_venom_duration_damge", 
-- 					{ duration = duration} 
-- 				)
				
-- 			end
-- 		end

-- 	end
-- end

-- function modifier_archon_passive_die_venom_damge:OnRefresh( ... )
-- 	--if not IsServer() then return end
-- 	self.radius = 500
-- 	--self.speed_cut = 100
-- end

-- function modifier_archon_passive_die_venom_damge:DeclareFunctions( ... )
-- 	return 
-- 		{
-- 			--MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
-- 			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, -- 移动速度
-- 		}
-- end

-- function modifier_archon_passive_die_venom_damge:GetModifierMoveSpeedBonus_Constant( ... )
-- 	--if not IsServer() then return end
-- 	return -100
-- end

-- ----------------------------------------------------------------------------------------------

-- -- 敌人离开毒阵后  毒液的依然持续造成伤害   直到持续时间结束
-- if modifier_archon_passive_die_venom_duration_damge == nil then
-- 	modifier_archon_passive_die_venom_duration_damge = class({})
-- end


-- function modifier_archon_passive_die_venom_duration_damge:IsHidden()
-- 	return false
-- end

-- function modifier_archon_passive_die_venom_duration_damge:GetTexture()
-- 	return "die_venom"
-- end

-- function modifier_archon_passive_die_venom_duration_damge:IsDebuff()
-- 	return true
-- end

-- function modifier_archon_passive_die_venom_duration_damge:IsPurgable()
--     return false -- 无法驱散
-- end
 
-- function modifier_archon_passive_die_venom_duration_damge:RemoveOnDeath()
--     return true -- 死亡不移除
-- end

-- function modifier_archon_passive_die_venom_duration_damge:OnCreated(params)
-- 	if not IsServer() then return end
-- 	local hParent = self:GetParent()
-- 	local hCaster = self:GetCaster()
-- 	--self.timer_attack_multiple = 5

-- 	-- local EffectName = "particles/units/heroes/hero_pudge/pudge_swallow.vpcf" -- 毒液特效
-- 	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_OVERHEAD_FOLLOW, hParent)
-- 	-- self:AddParticle(nFXIndex, false, false, -1, false, false)

-- 	self:StartIntervalThink(1)
-- end

-- function modifier_archon_passive_die_venom_duration_damge:OnIntervalThink( params )
-- 	local hParent = self:GetParent()
-- 	local hCaster = self:GetCaster()

-- 	if IsServer() then
-- 		ApplyDamage(
-- 		{
-- 			attacker = hCaster,
-- 			victim = hParent,
-- 			damage = hCaster:GetAgility() * 5,
-- 			damage_type = DAMAGE_TYPE_MAGICAL
-- 		}
-- 		)

-- 	end
-- end

-- function modifier_archon_passive_die_venom_duration_damge:OnRefresh( ... )
-- 	--if not IsServer() then return end
-- 	self.timer_attack_multiple = 5
-- end