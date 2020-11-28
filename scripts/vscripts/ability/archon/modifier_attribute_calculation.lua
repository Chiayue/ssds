if modifier_attribute_calculation == nil then modifier_attribute_calculation = {} end
function modifier_attribute_calculation:OnCreated()
	
	self.bIsCrit = false
	self.crit_multiplier = 0
	self.crit_chance = 0
	self.bounty = 0
	self.range = 0
	self:StartIntervalThink(1)
	
end
function modifier_attribute_calculation:GetTexture() return "huifu" end
function modifier_attribute_calculation:IsHidden() return false end
function modifier_attribute_calculation:GetAttributes()
	return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_attribute_calculation:DeclareFunctions()
	local funcs = {
		-- MODIFIER_EVENT_ON_ATTACK,
		-- MODIFIER_EVENT_ON_ATTACK_LANDED,
		-- MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	return funcs
end

function modifier_attribute_calculation:GetModifierAttackRangeBonus()
	return 80
end

function modifier_attribute_calculation:OnDeath(args)
	if not IsServer() then return end
	local hAttacker = args.attacker
	local hCaster = self:GetParent()
	if hAttacker ~= hCaster then
		return
	end
	if self.bounty > 0 then
		local nPlayerID = hCaster:GetPlayerID()
		PlayerResource:ModifyGold(nPlayerID,self.bounty,true,DOTA_ModifyGold_CreepKill)
		PopupGoldGain(hCaster, self.bounty)
	end
end


function modifier_attribute_calculation:OnIntervalThink()
	if IsServer() then
		local hHero = self:GetParent()
		local nPlayerID = hHero:GetOwner():GetPlayerID() 
		--- 获存档装备
		local hSeriesItem = {}
		for i=0,5 do
			local hItem = hHero:GetItemInSlot(i)
			if hItem ~= nil then
				if hItem:GetIntrinsicModifierName() == "modifier_item_series" then
					table.insert( hSeriesItem, hItem )
				end
			end
		end
		-- 统计属性
		local hAttrTable = {}
		for k,v in pairs(hSeriesItem) do
			for affix,amount in pairs(v.bonus.attr) do
				if hAttrTable[affix] == nil then
					hAttrTable[affix] = tonumber(amount)
				else
					hAttrTable[affix] = hAttrTable[affix] + amount
				end
			end 
		end
		-- DeepPrintTable( hAttrTable )
		local nItemFD = (hAttrTable["fd"] and hAttrTable["fd"] or 0) * 0.01
		local nItemPD = (hAttrTable["pd"] and hAttrTable["pd"] or 0) * 0.01
		local nItemPC = (hAttrTable["pc"] and hAttrTable["pc"] or 0) 
		local nItemPCD = (hAttrTable["pcd"] and hAttrTable["pcd"] or 0) 
		local nItemMD = (hAttrTable["md"] and hAttrTable["md"] or 0) * 0.01
		local nItemMC = (hAttrTable["mc"] and hAttrTable["mc"] or 0) 
		local nItemMCD = (hAttrTable["mcd"] and hAttrTable["mcd"] or 0) 
		self.bounty = hAttrTable["bounty"] and hAttrTable["bounty"] or 0
		local nInv = (hAttrTable["inv"] and hAttrTable["inv"] or 0) * 0.01
		GlobalVarFunc.EquiInvestment[nPlayerID + 1] = nInv + 1
		------------------------- 箭魂层数
		local nArrowSoulStack = hHero:GetModifierStackCount("modifier_arrowSoul_meditation",  hHero)
		------------------------- 玩家暴击几率&最终伤害 ------
		local hAttr = GlobalVarFunc.attr[nPlayerID + 1]
		------------------------- 会员伤害乘区 -------------------
		local nFdamage_a = 0
		local nDiamond = hHero:GetModifierStackCount("modifier_store_reward_vip_diamond", hHero) * 0.03
		local nDarkWings = hHero:GetModifierStackCount("modifier_store_reward_dark_wings", hHero) * 0.05
		local nArrowInfinite = hHero:GetModifierStackCount("modifier_store_reward_arrow_infinite", hHero) * 0.1
		local nAuraGod = hHero:GetModifierStackCount("modifier_store_reward_aura_god", hHero) * 0.05
		local nGoldedDragon = hHero:GetModifierStackCount("modifier_store_reward_golden_dragon", hHero) * 0.07
		nFdamage_a = nFdamage_a + nDiamond + nDarkWings + nArrowInfinite + nGoldedDragon
		hAttr["fdamage_a"] = nFdamage_a
		------------------------- 装备伤害乘区 -------------------
		hAttr["fdamage_b"] = 0
		local hBow = hHero:FindModifierByName("modifier_item_archer_bow")
		if hBow ~= nil then
			hAttr["fdamage_b"] = (hBow.reward_damage*0.01) or 0
		end
		---- 毁灭3件套
		if hHero:HasAbility("archon_passive_puncture") or hHero:HasAbility("archon_passive_rage") or hHero:HasAbility("archon_passive_soul")  then
			local nRuinStack = hHero:GetModifierStackCount("modifier_series_reward_talent_ruin", hHero )
			if nRuinStack >= 3 then
				hAttr["fdamage_b"] = hAttr["fdamage_b"] + 0.2
			end
		end
		------------------------- BUFF乘区  --------------------
		hAttr["fdamage_c"] = 0
		-- 神圣技能BUFF 
		local hLightBuff = hHero:FindModifierByName("modifier_archon_passive_light_effect")
		if hLightBuff ~= nil then
			local nLightStack = hLightBuff:GetStackCount()
			hAttr["fdamage_c"] = hAttr["fdamage_c"] + (nLightStack * 0.01)
		end
		-- 大地BUFF
		local hEarthBuff = hHero:FindModifierByName("modifier_archon_passive_earth_buff")
		if hEarthBuff ~= nil then
			local nEarthStack = hEarthBuff:GetStackCount()
			hAttr["fdamage_c"] = hAttr["fdamage_c"] + (nEarthStack * 0.01)
		end
		-- 宝物
		local nZengfu1 = hHero:HasModifier("modifier_gem_shanghaizengfu_1") and 0.08 or 0
		local nZengfu2 = hHero:HasModifier("modifier_gem_shanghaizengfu_2") and 0.12 or 0
		local nZengfu3 = hHero:HasModifier("modifier_gem_shanghaizengfu_3") and 0.16 or 0
		local nZengfu4 = hHero:HasModifier("modifier_gem_shanghaizengfu_4") and 0.20 or 0
		local nZengfuT = hHero:HasModifier("modifier_gem_shanghaizengfu_taozhuang") and 0.35 or 0
		hAttr["fdamage_c"] = hAttr["fdamage_c"] + nZengfu1 + nZengfu2 + nZengfu3 + nZengfu4 + nZengfuT 
		------------------------- 团队增益乘区 -----------
		hAttr["fdamage_d"] = 0
		local nTeamStack = hHero:GetModifierStackCount("modifier_team_buff", hHero ) * 0.01
		local nEndlessStack = hHero:GetModifierStackCount("modifier_reward_damage_bonus",hHero) * 0.01
		hAttr["fdamage_d"] = nTeamStack + nEndlessStack
		------------------------- 爆裂模式
		hAttr["fdamage_e"] = 0
		local nBurstMode = hHero:HasModifier("modifier_bonus_base_attackspeed") and 1 or 0
		hAttr["fdamage_e"] = hAttr["fdamage_e"] + nBurstMode
		------------------------- 其他
		hAttr["fdamage_f"] = nItemFD
		
		---------------------通用暴击爆伤----------------------------
		-- 通用暴击
		local nSageBonus = hHero:GetModifierStackCount("modifier_store_reward_sage_stone", hHero ) * 3
		-- 通用爆伤
		local nFlameBonus = hHero:GetModifierStackCount("modifier_series_reward_talent_flame_effect", hHero ) * 3
		local nHeimo = hHero:HasModifier( "modifier_gem_yongmengzhiren_heimo" ) and 200 or 0
		-------------------- 物理暴击几率 --------------------
		local nPhysicalCritUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Physical_Critical", hHero ) * 4
		local nPhysicalCritUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_critical_buff", hHero ) * 3
		local nCanbaiCrit = hHero:HasModifier( "modifier_gem_canbaizhiren") and -20 or 0
		local nShufuCrit = hHero:HasModifier( "modifier_gem_shufuzhiren" ) and 20 or 0
		hAttr["physical_crit"] = nPhysicalCritUp1 + nPhysicalCritUp2 + nCanbaiCrit + nShufuCrit + nSageBonus + nItemPC
		self.crit_chance = hAttr["physical_crit"] 
		-------------------- 物理爆伤 --------------------
		local nAgiCritDamage =  0--hHero:GetAgility() * 0.05
		local nPhysicalCritDamageUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Physical_Critical_Damage", hHero ) * 40
		local nPhysicalCritDamageUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_critical_damage_buff", hHero ) * 25
		if nArrowSoulStack >= 17 then nPhysicalCritDamageUp1 = nPhysicalCritDamageUp1 + 25 end
		if nArrowSoulStack >= 32 then nPhysicalCritDamageUp1 = nPhysicalCritDamageUp1 + 30 end
		-- 宝物
		local nShufuDamage = hHero:HasModifier( "modifier_gem_shufuzhiren" ) and -75 or 0
		local nCanbaiDamage = hHero:HasModifier( "modifier_gem_canbaizhiren" ) and 120  or 0
		local nYongmengDa = hHero:HasModifier( "modifier_gem_yongmengzhiren_da" ) and 70 or 0
		local nYongmengXiao = hHero:HasModifier( "modifier_gem_yongmengzhiren_xiao") and 30 or 0
		local nYongmengZhong = hHero:HasModifier( "modifier_gem_yongmengzhiren_zhong" ) and 50 or 0
		local nSword = hHero:HasModifier( "modifier_gem_falling_of_sword" ) and 50 or 0
		local nSwordAdd = hHero:HasModifier( "modifier_gem_falling_of_sword_additional" ) and 300 or 0
		hAttr["physical_crit_damage"] = 150 
		+ nAgiCritDamage + nPhysicalCritDamageUp1 + nPhysicalCritDamageUp2 
		+ nYongmengDa + nYongmengXiao + nYongmengZhong + nCanbaiDamage + nShufuDamage
		+ nFlameBonus + nHeimo + nItemPCD
		+ nSword + nSwordAdd
		self.crit_multiplier = hAttr["physical_crit_damage"]
		-------------------- 法术暴击几率 --------------------
		local nMagicCritUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Magic_Critical", hHero ) * 4
		local nMagicCritUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_magic_buff", hHero ) * 3
		-- 宝物
		local nDuohunCrit = hHero:HasModifier( "modifier_gem_duohunfazhang" ) and 20 or 0
		local nShihunCrit = hHero:HasModifier( "modifier_gem_shihunshengbei" ) and -20 or 0
		hAttr["magic_crit"] = nMagicCritUp1 + nMagicCritUp2 + nDuohunCrit + nShihunCrit + nSageBonus + nItemMC
		-------------------- 法术暴击伤害 --------------------
		local nIntCritDamage =  0 -- hHero:GetIntellect() * 0.05
		local nMagicCritDamageUp1 = hHero:GetModifierStackCount("modifier_Upgrade_Magic_Critical_Damage", hHero ) * 40
		local nMagicCritDamageUp2 = hHero:GetModifierStackCount( "modifier_tech_max_physical_critical_damage_buff", hHero ) * 25
		if nArrowSoulStack >= 18 then nMagicCritDamageUp1 = nMagicCritDamageUp1 + 25 end
		if nArrowSoulStack >= 33 then nMagicCritDamageUp1 = nMagicCritDamageUp1 + 30 end
		local nGodCup = hHero:HasModifier( "modifier_gem_eats_the_soul_god_cup" ) and 50 or 0
		local nGodCupAdd = hHero:HasModifier( "modifier_gem_eats_the_soul_god_cup_additional" ) and 300 or 0
		-- 宝物
		local nDuohunDamage = hHero:HasModifier( "modifier_gem_duohunfazhang" ) and -75 or 0
		local nShihunDamage = hHero:HasModifier( "modifier_gem_shihunshengbei" ) and 120 or 0
		local nYongmengDa_mag = hHero:HasModifier( "modifier_gem_yongmengzhiren_da" ) and 70 or 0
		local nYongmengXiao_mag = hHero:HasModifier( "modifier_gem_yongmengzhiren_xiao") and 30 or 0
		local nYongmengZhong_mag = hHero:HasModifier( "modifier_gem_yongmengzhiren_zhong" ) and 50 or 0
		hAttr["magic_crit_damage"] = 150 
			+ nMagicCritDamageUp1 + nMagicCritDamageUp2 + nDuohunDamage 
			+ nShihunDamage + nFlameBonus + nIntCritDamage + nYongmengXiao_mag 
			+ nYongmengZhong_mag + nYongmengDa_mag + nHeimo + nItemMCD
			+ nGodCup + nGodCupAdd
		------ 伤害加成 通用 --------
		---- 最终伤害
		local nFinalDamage = hHero:GetStrength() * 0.0001 -- 1W点100% 0.01%
		if nArrowSoulStack >= 39 then nFinalDamage = nFinalDamage + 0.03 end
		hAttr["final_damage"] = nFinalDamage
		-------------------- 物理伤害加成 --------------------
		local nPhysicalDamage =  hHero:GetAgility() * 0.0003 -- 1W点200%
		if nArrowSoulStack >= 37 then nPhysicalDamage = nPhysicalDamage + 0.05 end
		hAttr["physical_damage"] = nPhysicalDamage + nFinalDamage + nItemPD
		-------------------- 法术伤害加成 --------------------
		local nMagicDamage = hHero:GetIntellect() * 0.0008 -- 1W点800% 
		if nArrowSoulStack >= 38 then nMagicDamage = nMagicDamage + 0.05 end
		hAttr["magic_damage"] = nMagicDamage + nFinalDamage + nItemMD
		-- DeepPrintTable( hAttr )
		hHero:CalculateStatBonus()
	end 
end



function modifier_attribute_calculation:OnAttackLanded( params )
	if IsServer() then
		-- play sounds and stuff
		if self:GetParent() == params.attacker then
			local hTarget = params.target
			if hTarget ~= nil and self.bIsCrit then
				local vDir = ( self:GetParent():GetAbsOrigin() - hTarget:GetAbsOrigin() ):Normalized()
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent() )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true )
				ParticleManager:SetParticleControl( nFXIndex, 1, hTarget:GetAbsOrigin() )
				ParticleManager:SetParticleControlForward( nFXIndex, 1, vDir )
				ParticleManager:SetParticleControlEnt( nFXIndex, 10, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetAbsOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
				EmitSoundOn( "Hero_PhantomAssassin.CoupDeGrace", self:GetParent() )
				self.bIsCrit = false
			end
		end
	end

	return 0.0

end

-- 普通攻击暴击
function modifier_attribute_calculation:GetModifierPreAttack_CriticalStrike( params )
	if IsServer() then
		local hTarget = params.target
		local hAttacker = params.attacker
		if hTarget and ( hTarget:IsBuilding() == false ) and ( hTarget:IsOther() == false ) 
				and hAttacker and ( hAttacker == self:GetParent() )
				and ( hAttacker:GetTeamNumber() ~= hTarget:GetTeamNumber() ) then
			if RollPseudoRandomPercentage( self.crit_chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, hAttacker ) == true then
				self.bIsCrit = true
				-- 暴击几率
				return self.crit_multiplier
			end
		end
	end
	return 0.0
end