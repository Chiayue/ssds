-- 连环闪电
LinkLuaModifier("modifier_archon_passive_arc_lightning", "ability/archon_passive_arc_lightning", LUA_MODIFIER_MOTION_NONE)

if archon_passive_arc_lightning == nil then 
	archon_passive_arc_lightning = class({})
end

function archon_passive_arc_lightning:GetIntrinsicModifierName()
 	return "modifier_archon_passive_arc_lightning"
end
--------------------------------------------------
if modifier_archon_passive_arc_lightning == nil then
	modifier_archon_passive_arc_lightning = class({})
end

function modifier_archon_passive_arc_lightning:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
	}
	return funcs
end

function modifier_archon_passive_arc_lightning:IsHidden() -- 隐藏图标
	return true
end

----------------------------------------------------------------------------------------------------------------------
--if IsServer() then
	-- 计时器
	function modifier_archon_passive_arc_lightning:Timer(sContextName, fInterval, funcThink)
		if funcThink == nil then
			funcThink = fInterval
			fInterval = sContextName
			sContextName = DoUniqueString("Timer") -- 使用任意的根字符串构造一个保证在VM脚本运行周期内唯一的字符串。当给表增加数据但不确定已用关键字时有用
		end
		self:GetAbility():SetContextThink(sContextName, function() -- 在这个实体上设置一个计时器
			local result = funcThink()
			if type(result) == "number" then
				result = math.max(FrameTime(), result) -- FrameTime() 获取上一帧在服务器上花费的时间
			end
			return result
		end, fInterval)
		return sContextName
	end

-- 游戏计时器
function modifier_archon_passive_arc_lightning:GameTimer(sContextName, fInterval, funcThink)
	--print(sContextName, fInterval, funcThink)
	if funcThink == nil then
		funcThink = fInterval
		fInterval = sContextName
		sContextName = DoUniqueString("GameTimer")
	end
	local fTime = GameRules:GetGameTime() + math.max(FrameTime(), fInterval) -- math.max 返回 fInterval 中的最高值
	return self:Timer(sContextName, fInterval, function()
		if GameRules:GetGameTime() >= fTime then
			local result = funcThink()
			if type(result) == "number" then
				fTime = fTime + math.max(FrameTime(), result)
			end
			return result -- 返回最高时间值
		end
		return 0
	end)
end
--end

-- 从表里寻找值的键
function modifier_archon_passive_arc_lightning:TableFindKey( t, v )
	if t == nil then
		return nil
	end

	for _k, _v in pairs( t ) do
		if v == _v then
			return _k
		end
	end
	return nil
end
--                       						获取弹射目标   现在目标      队伍         选择位置   范围    队伍过滤      类型过滤      特殊过滤     选择方式 单位记录表  是否可以弹射回来（缺省false）
function modifier_archon_passive_arc_lightning:GetBounceTarget(last_target, team_number, position, radius, team_filter, type_filter, flag_filter, order, unit_table, can_bounce_bounced_unit)
		local first_targets = FindUnitsInRadius(team_number, position, nil, radius, team_filter, type_filter, flag_filter, order, false)
		if IsValidEntity(last_target) then
			for i = #first_targets, 1, -1 do -- #  把这个表的里面的长度转换为数值
				local unit = first_targets[i]
				if unit == last_target then
					table.remove(first_targets, i)
				end
			end
		end

		local second_targets = {}
		for k, v in pairs(first_targets) do
			second_targets[k] = v
		end

		if unit_table and type(unit_table) == "table" then
			for i = #first_targets, 1, -1 do
				if self:TableFindKey(unit_table, first_targets[i]) then
					table.remove(first_targets, i)
				end
			end
		end

		local first_target = first_targets[1]
		local second_target = second_targets[1]

		if can_bounce_bounced_unit ~= nil and type(can_bounce_bounced_unit) == "boolean" and can_bounce_bounced_unit == true then
			return first_target or second_target
		else
			return first_target
		end
	end
--                                             技能跳跃 施法者 目标者   半径    跳跃数      跳跃延迟     伤害    单位表  数字
function modifier_archon_passive_arc_lightning:Jump(hCaster, hTarget, radius, jump_count, jump_delay, damage, units, iCount)
	local ability = self:GetAbility()
	self:GameTimer(jump_delay, function()
		if not IsValidEntity(hCaster) then
			return
		end
		if not IsValidEntity(hTarget) then
			return
		end
		local hNewTarget = self:GetBounceTarget(hTarget, hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags()+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, units)
		if IsValidEntity(hNewTarget) then
			local EffectName = "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf"
			local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_POINT_FOLLOW, hTarget )
			ParticleManager:SetParticleControlEnt(nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(nFXIndex, 1, hNewTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hNewTarget:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(nFXIndex)
			local tDamageTable = {
				ability = self,
				attacker = hCaster,
				victim = hNewTarget,
				damage = damage,
				damage_type = ability:GetAbilityDamageType()
			}
			ApplyDamage(tDamageTable)
			if iCount < jump_count then
				table.insert(units, hNewTarget)
				self:Jump(hCaster, hNewTarget, radius, jump_count, jump_delay, damage, units, iCount+1)
			end
		end
	end)
end
--------------------------------------------------------------------------------------------------------------------

function modifier_archon_passive_arc_lightning:OnAttackLanded(params)
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local ability = self:GetAbility()
	local hTarget = params.target --self:GetCursorTarget()
	local radius = ability:GetSpecialValueFor("radius") -- 当前被攻击者的半径
	local intell_damage_multiple = ability:GetSpecialValueFor("intell_damage_multiple") -- 当前技能的伤害
	local chance = ability:GetSpecialValueFor("chance")
	local jump_count = ability:GetSpecialValueFor("jump_count")
	local jump_delay = ability:GetSpecialValueFor("jump_delay")
	local arc_damage = hCaster:GetIntellect() * intell_damage_multiple -- 伤害是智力的2倍伤害

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	local EffectName = "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf"
	local nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_POINT_FOLLOW, hTarget )
	ParticleManager:SetParticleControlEnt(nFXIndex, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_attack1", hCaster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(nFXIndex)

	local damage = 
	{
		ability = self,
		attacker = hCaster,
		victim = hTarget,
		damage = arc_damage,
		damage_type = ability:GetAbilityDamageType(),
	}

	ApplyDamage( damage )
	self:Jump(hCaster, hTarget, radius, jump_count, jump_delay, arc_damage, {hTarget}, 2)
end