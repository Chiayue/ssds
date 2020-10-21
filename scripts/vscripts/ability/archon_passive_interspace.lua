LinkLuaModifier( "modifier_archon_passive_interspace", "ability/archon_passive_interspace.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_interspace_particles", "ability/archon_passive_interspace.lua",LUA_MODIFIER_MOTION_NONE )

-------------------------------------------------
--Abilities
if archon_passive_interspace == nil then
	archon_passive_interspace = class({})
end

function archon_passive_interspace:GetIntrinsicModifierName()
 	return "modifier_archon_passive_interspace"
end
--------------------------------------------------
if modifier_archon_passive_interspace == nil then
	modifier_archon_passive_interspace = class({})
end

function modifier_archon_passive_interspace:IsHidden()
	return true
end

function modifier_archon_passive_interspace:OnCreated()
	if IsServer() then -- 
		self:StartIntervalThink(0.5)
		self.base_range = 0
		self.agi_of_ramge = 0
	end
end
function modifier_archon_passive_interspace:OnIntervalThink()
	if not IsServer() then return end
	local hCaster = self:GetCaster()
	local nLevel = self:GetAbility():GetLevel()
	if nLevel >= ABILITY_AWAKEN_1 and nLevel < ABILITY_AWAKEN_2 then
		self.base_range = 100
	elseif nLevel >= ABILITY_AWAKEN_2 then
		self.base_range = 350
	end

	-- 100点敏捷增加1点射程
	self.agi_of_ramge = hCaster:GetAgility() / 100
end

function modifier_archon_passive_interspace:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_archon_passive_interspace:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

-- function modifier_archon_passive_interspace:GetEffectName()
-- 	return "particles/econ/items/wisp/wisp_relocate_timer_buff_ti7_sparkle_blue.vpcf"
-- end

function modifier_archon_passive_interspace:OnAttackLanded( params )
	--if not IsServer() then return end
	if params.target:IsAlive() == false then return end
	if params.attacker ~= self:GetParent() then
		return 0
	end
	local hCaster = self:GetCaster()
	local hTarget = params.target
	if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
	local nowChance = RandomInt(0,100)
	local chance = self:GetAbility():GetSpecialValueFor( "chance" )
	local aoe = self:GetAbility():GetSpecialValueFor( "aoe" )
	local damage_coefficient = self:GetAbility():GetSpecialValueFor( "coefficient" )
	if nowChance  > chance then
		return 0
	end

	-- local EffectName = "particles/earth/sniper_techies/_2econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf"
	-- local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex, 1, hTarget:GetAbsOrigin())
	-- ParticleManager:SetParticleControl(nFXIndex, 3, hTarget:GetAbsOrigin())

	-- -- 新建特效
	-- local EffectName_1 = "particles/particles/earth/snapfire_cookie_landing/hero_snapfire_cooki_2e_landing.vpcf"
	-- local nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hTarget )
	-- ParticleManager:SetParticleControl(nFXIndex_1, 0, Vector(500, 500, 500))
	-- ParticleManager:SetParticleControl(nFXIndex_1, 1, hTarget:GetAbsOrigin())

	hTarget:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_interspace_particles", {duration = 1})

	-- 获取自身攻击的所有范围
	local nBowRange = 0				      		         -- 武器攻击范围奖励
	local nTechRange = 0								 -- 科技攻击范围奖励
	local nRewardRange = 0 								 -- 地图攻击范围奖励
	local nTreasureRange = 0 							 -- 宝物远攻击范围奖励
	local nBaseRange = hCaster:GetBaseAttackRange()  	 -- 自身攻击范围奖励
	local hBow = hCaster:FindModifierByName("modifier_item_archer_bow")
	if hBow ~= nil then
		nBowRange = hBow:GetAbility():GetSpecialValueFor( "bonus_range" )
	end
	local hTech = hCaster:FindModifierByName("modifier_Upgrade_Range")
	if hTech ~= nil then
		nTechRange = hTech:GetModifierAttackRangeBonus()
	end
	local hReward = hCaster:FindModifierByName("modifier_reward_range_bonus")
	if hReward ~= nil then
		nRewardRange = hReward:GetModifierAttackRangeBonus()
	end
	local hTreasure = hCaster:FindModifierByName("modifier_gem_yuanshemoshi")
	if hTreasure ~= nil then 
		nTreasureRange = hTreasure:GetModifierAttackRangeBonus()
	end
	-- print("nBowRange=====", nBowRange)
	-- print("nTechRange=====", nTechRange)	
	-- print("nBaseRange=====", nBaseRange)		
	-- print("nRewardRange=====", nRewardRange)		
	-- print("nTreasureRange=====", nTreasureRange)	
	-- print("self.agi_of_ramge======", self.agi_of_ramge)
	local nAllRange = nBaseRange + nBowRange + self.base_range + self.agi_of_ramge + nTechRange + nRewardRange + nTreasureRange
	-- print("base_range---------------------->",self.base_range)
	-- print("nAllRange=====================>", nAllRange)

	--EmitSoundOn( "Hero_Sniper.ShrapnelShoot", hTarget )

	EmitSoundOn( "Ability.Assassinate", hTarget )
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

	local abil_damage = ( nAllRange - 690 ) * ( nAllRange - 690 ) * damage_coefficient
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

function modifier_archon_passive_interspace:GetModifierAttackRangeBonus()
	if self.base_range == nil then return end  
	return self.base_range + self.agi_of_ramge --self.speed_of_damage
end

if modifier_archon_passive_interspace_particles == nil then 
	modifier_archon_passive_interspace_particles = class({})
end

function modifier_archon_passive_interspace_particles:IsHidden()
	return true
end

function modifier_archon_passive_interspace_particles:OnCreated( args )
	--if not IsServer() then return end
	local hParent = self:GetParent()
	--local hTarget = args.target
	if not hParent.nFXIndex and not hParent.nFXIndex_1 then
		local EffectName = "particles/earth/sniper_techies/_2econ/items/techies/techies_arcana/techies_suicide_arcana.vpcf"
		hParent.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_RENDERORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex, 1, hParent:GetAbsOrigin())
		ParticleManager:SetParticleControl(hParent.nFXIndex, 3, hParent:GetAbsOrigin())
		-- 新建特效
		local EffectName_1 = "particles/particles/earth/snapfire_cookie_landing/hero_snapfire_cooki_2e_landing.vpcf"
		hParent.nFXIndex_1 = ParticleManager:CreateParticle( EffectName_1, PATTACH_ABSORIGIN_FOLLOW, hParent )
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 0, Vector(500, 500, 500))
		ParticleManager:SetParticleControl(hParent.nFXIndex_1, 1, hParent:GetAbsOrigin())
	end
end

function modifier_archon_passive_interspace_particles:OnDestroy()
	--if not IsServer() then return end
	local hParent = self:GetParent()
	if hParent.nFXIndex and hParent.nFXIndex_1 then 
		ParticleManager:DestroyParticle( hParent.nFXIndex, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex )
		hParent.nFXIndex = nil

		ParticleManager:DestroyParticle( hParent.nFXIndex_1, false )
		ParticleManager:ReleaseParticleIndex( hParent.nFXIndex_1 )
		hParent.nFXIndex_1 = nil
	end
end