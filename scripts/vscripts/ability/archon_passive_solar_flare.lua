-- 被动技能(酷炫) 日炎耀斑
LinkLuaModifier("modifier_archon_passive_solar_flare", "ability/archon_passive_solar_flare", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_solar_flare_debuff", "ability/archon_passive_solar_flare", LUA_MODIFIER_MOTION_NONE)

local debuff_count = 0
local debuff_count_damage = 0

if archon_passive_solar_flare == nil then 
	archon_passive_solar_flare = class({})
end

function archon_passive_solar_flare:GetIntrinsicModifierName( ... )
	return "modifier_archon_passive_solar_flare"
end

if modifier_archon_passive_solar_flare == nil then 
	modifier_archon_passive_solar_flare = class({})
end

function modifier_archon_passive_solar_flare:IsHidden( ... )
	return true
end

function modifier_archon_passive_solar_flare:IsHidden()
	return true
end

function modifier_archon_passive_solar_flare:DeclareFunctions( ... )
	return 
		{
			MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
		}
end

function modifier_archon_passive_solar_flare:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local hTarget = params.target
	local duration = self:GetAbility():GetSpecialValueFor( "duration" )
	local radius = self:GetAbility():GetSpecialValueFor( "radius" )
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local attack_multiple = self:GetAbility():GetSpecialValueFor( "attack_multiple" )

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	-- -- 创建效果
	local EffectName_0 = "particles/thd2/heroes/utsuho/ability_utsuho01_effect.vpcf"
	local nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_ROOTBONE_FOLLOW, hTarget)
	
	local EffectName_1 = "particles/thd2/heroes/utsuho/ability_utsuho03_effect.vpcf"
	local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ROOTBONE_FOLLOW, hTarget)

	local EffectName_2 = "particles/thd2/heroes/utsuho/ability_utsuho03_effect_d.vpcf"
	local nFXIndex_2 = ParticleManager:CreateParticle( EffectName_2, PATTACH_ROOTBONE_FOLLOW, hTarget)

	local EffectName_3 = "particles/thd2/heroes/utsuho/ability_utsuho04_end.vpcf"
	local nFXIndex_3 = ParticleManager:CreateParticle( EffectName_3, PATTACH_ROOTBONE_FOLLOW, hTarget)

	local EffectName_4 = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
	local nFXIndex_4 = ParticleManager:CreateParticle( EffectName_4, PATTACH_ROOTBONE_FOLLOW, hTarget)

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
				damage = hCaster:GetAgility() * attack_multiple,
				damage_type = self:GetAbility():GetAbilityDamageType(),
			}

			ApplyDamage( damage )

			-- 敌人眩晕BUFF
			enemy:AddNewModifier( 
				self:GetCaster(), 
				self:GetAbility(), 
				"modifier_archon_passive_solar_flare_debuff", 
				{ duration = duration} 
			)
			
		end
	end

	
	-- print("x=", x)
	-- print("x_damage=", x_damage)
	-- 判断 当前敌人身上是否有这个buff  有计算伤害 减少一层buff 没有 就return
	if hTarget ~= nil then
		local x_name = hTarget:FindModifierByName("modifier_archon_passive_solar_flare_debuff")
		if x_name == nil then
			return
		end
		debuff_count = x_name:GetStackCount()
		debuff_count_damage = debuff_count * hCaster:GetAgility()
		x_name:DecrementStackCount()
	end
end

---------------------------------------眩晕BUFF---------------------------------------
if modifier_archon_passive_solar_flare_debuff == nil then 
	modifier_archon_passive_solar_flare_debuff = class({})
end

function modifier_archon_passive_solar_flare_debuff:IsDebuff( ... )
	return true
end

-- 被攻击后增加一层BUFF
function modifier_archon_passive_solar_flare_debuff:OnCreated() 
	self:SetStackCount(1)
end

function modifier_archon_passive_solar_flare_debuff:OnRefresh() 
	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_archon_passive_solar_flare_debuff:DeclareFunctions( ... )
	return 
		{
			--MODIFIER_PROPERTY_OVERRIDE_ANIMATION, -- 动画
			MODIFIER_EVENT_ON_ATTACKED, -- 被攻击
		}
end

function modifier_archon_passive_solar_flare_debuff:GetEffectName()
	return "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_cast_staff_fire.vpcf" -- 日炎特效
end

function modifier_archon_passive_solar_flare_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

-- function modifier_archon_passive_solar_flare_debuff:OnAttacked( ... )
-- 	local hParent = GetParent()

-- 	local hTarget_debuff_count = hParent:GetStackCount()
-- 	print("hTarget_debuff_count=", hTarget_debuff_count)
-- 	x_damage = hTarget_debuff_count * 10
-- 	hParent:DecrementStackCount()

-- 	--return x_damage
-- end