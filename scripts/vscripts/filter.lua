require("player_data")
require("randomEvents/random_events")
if Filter == nil then
	Filter = class({})
end

--- 过滤系统加载
function Filter:init()
	--print("Filter:init()")
	GameRules: GetGameModeEntity(): SetDamageFilter(Dynamic_Wrap(Filter,"DamageFilterS1"),Filter)
	-- GameRules: GetGameModeEntity(): SetDamageFilter(Dynamic_Wrap(Filter,"DamageFilterS2"),Filter)
	GameRules: GetGameModeEntity(): SetHealingFilter(Dynamic_Wrap(Filter,"HealingFilter"),Filter)
	GameRules: GetGameModeEntity(): SetModifyExperienceFilter(Dynamic_Wrap(Filter,"ExperienceFilter"),Filter)


end

function Filter:ExperienceFilter( params )
	local hParent = EntIndexToHScript(params.hero_entindex_const or -1)
	if hParent == nil then return false end
	if hParent:GetTeam() == 2 then
		local hTimeAbility = hParent:FindAbilityByName("archon_passive_time")
		if hTimeAbility ~= nil then
			if hTimeAbility:GetLevel() >= 5 then
				params.experience = params.experience * 1.6
			elseif hTimeAbility:GetLevel() >= 2 then
				params.experience = params.experience * 2
			end
		end
		local nExpBuff = hParent:GetModifierStackCount("modifier_series_attr_exp", hParent ) * 0.01
		params.experience = params.experience * ( 1 + nExpBuff)
	end
	return true
end
-- 伤害过滤器 S1
function Filter:DamageFilterS1( params )
	-- body
	local hAttacker = EntIndexToHScript(params.entindex_attacker_const or -1)
	local hTarget = EntIndexToHScript(params.entindex_victim_const or -1)
	local targetName = hTarget:GetUnitName()
	if hAttacker == nil then return true end
	local team = hAttacker:GetTeam()
	if team == 2 then
		--- 判断面向
		local nBossBulwark = hTarget:GetModifierStackCount("modifier_ability_boss_bulwark", hTarget )
		if nBossBulwark > 0 then
			local forwardVector			= hTarget:GetForwardVector()
			local forwardAngle			= math.deg(math.atan2(forwardVector.x, forwardVector.y))
			local reverseEnemyVector	= (hTarget:GetAbsOrigin() - hAttacker:GetAbsOrigin()):Normalized()
			local reverseEnemyAngle		= math.deg(math.atan2(reverseEnemyVector.x, reverseEnemyVector.y))
			local difference = math.abs(forwardAngle - reverseEnemyAngle)
			if difference >= 80 then
				params.damage = params.damage * (100 - nBossBulwark) * 0.01
			elseif difference <= 60 then
				params.damage = params.damage * 1.5
			end
		end

		local damageType =  damagetype_const -- 1物理 2魔法 4真实
		local nPlayerID = hAttacker:GetOwner():GetPlayerID()
		local iDamageType = params.damagetype_const
		local hAttr =  GlobalVarFunc.attr[nPlayerID + 1]
		-- 伤害乘区
		-- print(params.damage)
		local nFinal = ( 1+ hAttr["fdamage_a"] ) 
			* ( 1 + hAttr["fdamage_b"] ) 
			* ( 1 + hAttr["fdamage_c"] ) 
			* ( 1 + hAttr["fdamage_d"] ) 
			* ( 1 + hAttr["fdamage_e"] )
			* ( 1 + hAttr["fdamage_f"] )
			* ( 1 + hAttr["fdamage_g"] )
		--print(nFinal)
		params.damage = params.damage * nFinal
		-- 寒冷3件套
		if hAttacker:HasAbility("archon_passive_ice") or hAttacker:HasAbility("archon_passive_dark")  then
			local nClodStack = hAttacker:GetModifierStackCount("modifier_series_reward_talent_clod", hAttacker )
			if nClodStack >= 3 then
				local nDebuffDamage = 0
				local hAllModi = hTarget:FindAllModifiers()
				for k,hBuff in pairs(hAllModi) do
					if hBuff:IsDebuff() == true then nDebuffDamage = nDebuffDamage + 0.1 end
				end
				params.damage = params.damage * (1 + nDebuffDamage )
			end
		end
		-- print(params.damage)
		if iDamageType == 1 then
			-- 自闭减伤Or加伤
			if hTarget:HasModifier("modifier_autistic_week2_emeny_a") then params.damage = params.damage * 0.2 end
			if hTarget:HasModifier("modifier_autistic_week2_emeny_b") then params.damage = params.damage * 2 end
			--print(params.damage)
			-------------------
			local hDebuff = hTarget:FindModifierByName("modifier_archon_passive_dark_debuff2" )
			local nDebuffStack = 0
			if hDebuff ~= nil then
				nDebuffStack = hDebuff:GetStackCount() * 0.01
				params.damage = params.damage * (1 + nDebuffStack )
			end
			-- 物理伤害加成
			-- print(nFinal * (1+ nDebuffStack) * hAttr["physical_damage"] )
			--print(params.damage)
			params.damage = params.damage * (1 + hAttr["physical_damage"]  )
			--print(params.damage)
			-- 物理暴击几率
			local nPhysCrit = hAttr["physical_crit"]
			local chance = RandomInt(0, 100) 
			-----------
			if chance < nPhysCrit then
				-- 物理暴击伤害
				params.damage = params.damage * hAttr["physical_crit_damage"] * 0.01
				PopupCriticalDamage(hTarget,params.damage)
				-- 烈焰3件套
				local nFlameStack = hAttacker:GetModifierStackCount("modifier_series_reward_talent_flame", hAttacker )
				if nFlameStack >= 3 then
					if hAttacker:HasAbility("archon_passive_bank") or hAttacker:HasAbility("archon_passive_natural")  then
						local hFlameEffect = hAttacker:FindModifierByName("modifier_series_reward_talent_flame_effect")
						if hFlameEffect == nil then
							hAttacker:AddNewModifier(hAttacker, nil, "modifier_series_reward_talent_flame_effect", { duration = 5} )
						else
							local nStackCount = hFlameEffect:GetStackCount()
							hAttacker:SetModifierStackCount("modifier_series_reward_talent_flame_effect",hAttacker,nStackCount + 1)
						end
					end
				end
			end
		end
		if iDamageType == 2 then
			-- 自闭减伤Or加伤
			if hTarget:HasModifier("modifier_autistic_week2_emeny_a") then params.damage = params.damage * 2 end
			if hTarget:HasModifier("modifier_autistic_week2_emeny_b") then params.damage = params.damage * 0.2 end
			-- print(params.damage)
			-------------------
			-- 魔法伤害DEBUFF
			--print(params.damage)
			local hDebuff = hTarget:FindModifierByName("modifier_archon_passive_fire_debuff" )
			if hDebuff ~= nil then
				local nDebuffStack = hDebuff:GetStackCount() * 0.01
				params.damage = params.damage * (1 + nDebuffStack )
			end
			-- 魔法伤害加成
			--print(params.damage)
			params.damage = params.damage * (1 + hAttr["magic_damage"] )
			--print(params.damage)
			--print("==========")
			-- 魔法暴击几率
			local nMagicCrit = hAttr["magic_crit"]
			local chance = RandomInt(0, 100) 
			if chance < nMagicCrit then
				params.damage = params.damage * hAttr["magic_crit_damage"] * 0.01
				PopupMagicDamage(hTarget,params.damage)
				-- 烈焰3件套
				local nFlameStack = hAttacker:GetModifierStackCount("modifier_series_reward_talent_flame", hAttacker )
				if nFlameStack >= 3 then
					if hAttacker:HasAbility("archon_passive_bank") or hAttacker:HasAbility("archon_passive_natural")  then
						local hFlameEffect = hAttacker:FindModifierByName("modifier_series_reward_talent_flame_effect")
						if hFlameEffect == nil then
							hAttacker:AddNewModifier(hAttacker, nil, "modifier_series_reward_talent_flame_effect", { duration = 5} )
						else
							local nStackCount = hFlameEffect:GetStackCount()
							hAttacker:SetModifierStackCount("modifier_series_reward_talent_flame_effect",hAttacker,nStackCount + 1)
						end
					end
				end
			end
		end
		if iDamageType == 4 then
			-- 真实伤害
		end
		params.damage = math.floor(params.damage)
		if targetName == "npc_dota_creature_damege_baoxiang" then
			RandomEvents:InputPlayersBoxDamage(nPlayerID,params.damage/10000)
        end
        
        if GlobalVarFunc.game_mode ~= "endless" then
	        GlobalVarFunc.damage[nPlayerID+1] = GlobalVarFunc.damage[nPlayerID+1] + params.damage/10000
		elseif string.sub(targetName,0,22)  == "npc_dota_creature_boss" then
			GlobalVarFunc.damage[nPlayerID+1] = GlobalVarFunc.damage[nPlayerID+1] + params.damage/10000
		end
	end
	
	return true
end
function Filter:DamageFilterS2( params )
	local hAttacker = EntIndexToHScript(params.entindex_attacker_const or -1)
	local hTarget = EntIndexToHScript(params.entindex_victim_const or -1)
	local sTargetName = hTarget:GetUnitName()
	if hAttacker == nil then return true end
	if hAttacker:GetTeam() == 2 then
		local iPlayerID = hAttacker:GetPlayerOwnerID()
		if PlayerResource:IsValidPlayerID(iPlayerID) then
			local targetName = hTarget:GetUnitName()
			local nDamageType = params.damagetype_const
			local fDamage = params.damage
			GlobalVarFunc.damage[iPlayerID+1] = GlobalVarFunc.damage[iPlayerID+1] + params.damage/10000
		end
	end
	return true
end
-- 治疗过滤
function Filter:HealingFilter( params )
	local hTarget = EntIndexToHScript(params.entindex_target_const or -1)
	local hHealer = EntIndexToHScript(params.entindex_inflictor_const or -1)
	if hHealer == nil then return true end
	--DeepPrintTable(params)
	local nTeam = hHealer:GetTeam()
	if nTeam == 2 then
		local nHeal = params.heal
		local hDoctor = hHealer:FindAbilityByName("archon_deputy_doctor")

		if hDoctor ~= nil then
			params.heal = params.heal * 1.3
			if params.heal > 99 then
				local nRadius = hDoctor:GetSpecialValueFor( "damage_radius" )
				local enemies = FindUnitsInRadius(
					hHealer:GetTeamNumber(), 
					hTarget:GetOrigin(), 
					hTarget, 
					nRadius, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					0, 0, false 
				)
				local sEffectName = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_pu_ti6_heal_hammers.vpcf"
				local nFXIndex_2 = ParticleManager:CreateParticle( sEffectName, PATTACH_CUSTOMORIGIN_FOLLOW, hTarget )
				ParticleManager:SetParticleControl(nFXIndex_2, 0, Vector(nRadius, nRadius, nRadius))
				ParticleManager:ReleaseParticleIndex(nFXIndex_2)
				for _,enemy in pairs(enemies) do
					if enemy ~= nil  then
						local damage = {
							victim = enemy,
							attacker = hHealer,
							damage = params.heal,
							damage_type = hDoctor:GetAbilityDamageType(),
						}
						ApplyDamage( damage )
					end
				end
			end
		end

		if hTarget ~= nil and params.heal > 99 then
			PopupHealing(hTarget, params.heal,2)			
		end
	end
	
	return true
end