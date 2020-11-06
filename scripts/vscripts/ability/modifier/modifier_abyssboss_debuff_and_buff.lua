LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage", "ability/modifier/modifier_abyssBoss_DeBuff_and_Buff", LUA_MODIFIER_MOTION_NONE)

--[[
	减少攻击力
	减少攻速
	减少移速
	减少攻击范围
	减少最大血量
	减少全属性
	减少暴击几率
	减少爆伤
	减少法术暴击
	减少法术爆伤
	增加受到的伤害
]]
local DeBuffList = { -- 减益BUFF 给所有敌人增加
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage",
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed",
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed",
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange",
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal",
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties", -- 全属性
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike", -- 物理暴击
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage",
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike", -- 法术暴击
	"modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage",
	"modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage",
}

--[[
	增加攻击力，
	增加攻速
	增加移速，
	增加攻击范围
	增加最大血量
	增加护甲
	增加魔抗
	增加闪避
	增加生命值回复
	状态免疫(异常状态:眩晕、冰冻、减速)
	减少受到的伤害
]]
local BuffList = {  -- 增益BUFF 给Boss自身增加
	"modifier_abyssBoss_DeBuff_and_Buff_ToneUp_Damage",
}

if modifier_abyssBoss_DeBuff_and_Buff == nil then 
	modifier_abyssBoss_DeBuff_and_Buff = class({})
end

function modifier_abyssBoss_DeBuff_and_Buff:AddModifierDeBuff( ... ) -- 添加 减益BUFF
	local random = RandomInt(1, #DeBuffList)
	local abyssModifierName =  DeBuffList[random]
    return abyssModifierName
end

function modifier_abyssBoss_DeBuff_and_Buff:AddModifierBuff( ... ) -- 添加 增益BUFF
	local random = RandomInt(1, #BuffList)
	local abyssModifierName =  BuffList[random]
    return abyssModifierName
end

function modifier_abyssBoss_DeBuff_and_Buff:IsHidden( ... )
	return false
end

function modifier_abyssBoss_DeBuff_and_Buff:IsDebuff( ... )
end

function modifier_abyssBoss_DeBuff_and_Buff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_abyssBoss_DeBuff_and_Buff:RemoveOnDeath()
    return false -- 死亡不移除
end

-- 给敌人增加Debuff -- 减攻击
function modifier_abyssBoss_DeBuff_and_Buff:OnCreated( ... )
	if IsServer() then 
		self.time = 0
		self:StartIntervalThink(1)
	end
end

function modifier_abyssBoss_DeBuff_and_Buff:OnIntervalThink( ... )
	if IsServer() then 
		local hParent = self:GetParent()
		self.time = self.time + 1
		
		if self.time == 15 then 
			local random = RandomInt(2, 10)
			--if random % 2 == 1 then -- 添加DeBuff
				print("1")
				local a = self:AddModifierDeBuff()
				print("a>>>>>>>>>>>>>>>>>>>>=",a)
				local enemys = FindUnitsInRadius(
					hParent:GetTeamNumber(), 
					hParent:GetOrigin(), 
					hParent, 
					99999, 
					DOTA_UNIT_TARGET_TEAM_ENEMY, 
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
					0, 0, false 
				)

				for _,enemy in pairs(enemys) do
					if enemy ~= nil then --  and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() )
						-- 敌人添加buff
						enemy:AddNewModifier( hParent, self:GetAbility(), a, { duration = 10} )
					end
				end
			-- else -- 添加Buff  -- if random % 2 == 0 then
			-- 	print("0")
			-- 	local b = self:AddModifierBuff()
			-- 	print("b>>>>>>>>>>>>>>>>>>>>=",b)
			-- 	hParent:AddNewModifier(hParent, nil, b, {duration = 10})
			-- end	
			self.time = 0
		end

		--local x = hParent:FindAllModifiers()
		-- for _,midifier_name in pairs(x) do
		-- 	--print("midifier_name<>><><><><><><=========",midifier_name:GetName())
		-- 	if midifier_name:GetName() == "modifier_abyssBoss_DeBuff_and_Buff" then 	
		-- 	end
		-- end
	end
end

---------------------------------------------------------全部减益DeBuff---------------------------------------------------------
-- 减少10%攻击力
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage:DeclareFunctions( ... ) return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Damage:GetModifierPreAttack_BonusDamage( ... ) return -self:GetParent():GetAverageTrueAttackDamage(self:GetParent()) * 0.1 end
-- 减少10%攻速
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed:DeclareFunctions( ... ) return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackSpeed:GetModifierAttackSpeedBonus_Constant( ... ) return -self:GetParent():GetAttackSpeed() * 0.1 end
-- 减少10%移速
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed:DeclareFunctions( ... ) return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MoveSpeed:GetModifierMoveSpeedBonus_Constant( ... ) return -self:GetParent():GetBaseMoveSpeed() * 0.1 end
-- 减少攻击范围
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange:DeclareFunctions( ... ) return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AttackRange:GetModifierAttackRangeBonus( ... ) return -( self:GetParent():GetBaseAttackRange() + self:GetParent():GetUnitRange( self:GetParent() )() ) * 0.1 end
-- 减少10%的最大血量
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal:DeclareFunctions( ... ) return {MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_MaxHeal:GetModifierHealthBonus( ... ) return -self:GetParent():GetMaxHealth() * 0.1 end 
-- 减少10%力量
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:DeclareFunctions( ... ) 
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:GetModifierBonusStats_Strength( ... ) return -self:GetParent():GetStrength() * 0.1 end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:GetModifierBonusStats_Agility( ... ) return -self:GetParent():GetAgility() * 0.1 end
  function modifier_abyssBoss_DeBuff_and_Buff_Reduce_AllProperties:GetModifierBonusStats_Intellect( ... ) return -self:GetParent():GetIntellect() * 0.1 end
--减少物理暴击几率 50%
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrike:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
--减少物理暴击伤害 50%
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Physics_CriticalStrikeDamage:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
--减少法术暴击几率 50%
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrike:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
--减少法术暴击伤害 50%
if modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage == nil then modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Reduce_Magic_CriticalStrikeDamage:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
-- 增加10%的所受到的伤害
if modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage == nil then modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage = class({}) end
function modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage:IsHidden( ... ) return false end
function modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage:IsDebuff( ... ) return true end
function modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage:GetTexture() return "baowu/gem_xueshiyuanbo_lua" end
function modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage:DeclareFunctions( ... ) return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_abyssBoss_DeBuff_and_Buff_Increase_IncomingDamage:GetModifierIncomingDamage_Percentage( ... ) return 10 end 
--------------------------------------------------------全部增益Buff-------------------------------------------------------------
