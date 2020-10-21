-- 驱使幽鬼
LinkLuaModifier("modifier_archon_passive_impel_ghost", "ability/archon_passive_impel_ghost", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_impel_ghost_buff", "ability/archon_passive_impel_ghost", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_archon_passive_impel_ghost_count", "ability/archon_passive_impel_ghost", LUA_MODIFIER_MOTION_NONE)

if archon_passive_impel_ghost == nil then 
	archon_passive_impel_ghost = class({})
end

----------------------------------------------------------------------
function archon_passive_impel_ghost:GetIntrinsicModifierName(  )
	return "modifier_archon_passive_impel_ghost"
end

if modifier_archon_passive_impel_ghost == nil then 
	modifier_archon_passive_impel_ghost = class({})
end

function modifier_archon_passive_impel_ghost:IsHidden()
	return false
end

function modifier_archon_passive_impel_ghost:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED, -- 攻击命中
	}
	return funcs
end

function modifier_archon_passive_impel_ghost:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then
		return 0
	end

	local hCaster = self:GetCaster()
	local ability = self:GetAbility()

	local chance = ability:GetSpecialValueFor("chance")

	local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
	end

	-- 1. 攻击命中后生成 modifier
	hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_archon_passive_impel_ghost_buff", { duration = 10 })
end

if modifier_archon_passive_impel_ghost_buff == nil then 
	modifier_archon_passive_impel_ghost_buff = class({})
end

-- 以逆时针方向旋转
function modifier_archon_passive_impel_ghost_buff:Rotation2D(vVector, radian)
	local fLength2D = vVector:Length2D()
	local vUnitVector2D = vVector / fLength2D
	local fCos = math.cos(radian)
	local fSin = math.sin(radian)
	return Vector(vUnitVector2D.x*fCos-vUnitVector2D.y*fSin, vUnitVector2D.x*fSin+vUnitVector2D.y*fCos, vUnitVector2D.z)*fLength2D
end

function modifier_archon_passive_impel_ghost_buff:IsHidden()
	return false
end

function modifier_archon_passive_impel_ghost_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_NONE
end

-- 2. 生成 modifier 
function modifier_archon_passive_impel_ghost_buff:OnCreated() -- 创建幽灵的buff
	if IsServer() then
		local hAbility = self:GetAbility()
		local hCaster = self:GetCaster()
		local ghost_multiple = hAbility:GetSpecialValueFor("ghost_multiple") -- 伤害倍数
		self.radius = hAbility:GetSpecialValueFor("radius") -- 半径
		self.cGhost = hAbility:GetSpecialValueFor("ghost_count") -- 幽灵的数量
		self.ghost_speed = hAbility:GetSpecialValueFor("ghost_speed") -- 幽灵的移动速度
		self.ghost_damage = hCaster:GetIntellect() + hCaster:GetIntellect() * ghost_multiple -- 智力的倍数伤害

		self.tGhosts = {} -- 创建一个幽灵的表
		self:StartIntervalThink(0.01) -- 创建一个modifier的计时器 用来实现幽灵的移动

		-- 3. 在身边显示出游离状态的幽灵

		-- 4. 寻找英雄500码范围内的敌人
		
		-- 5. 找到后进行移动并实现伤害
			
	end
end

function modifier_archon_passive_impel_ghost_buff:OnDestroy()
	if IsServer() then
		for n, hGhost in pairs(self.tGhosts) do
			if IsValidEntity(hGhost.hUnit) then
				hGhost.hUnit:RemoveModifierByName("modifier_archon_passive_impel_ghost_count")
			end
		end
	end
end

function modifier_archon_passive_impel_ghost_buff:GetEffectName()
	return "particles/units/heroes/hero_death_prophet/death_prophet_spirit_glow.vpcf"
end

function modifier_archon_passive_impel_ghost_buff:GetEffectAttachType()
	return PATTACH_ROOTBONE_FOLLOW
end

function modifier_archon_passive_impel_ghost_buff:OnIntervalThink()
	if IsServer() then 
		local hCaster = self:GetCaster()
		local hAbility = self:GetAbility()
		local hParent = self:GetParent()
		local hParent_pos = hCaster:GetAbsOrigin() -- 英雄当前位置

		if not IsValidEntity(hAbility) or not IsValidEntity(hCaster) then
			self:Destroy()
			return
		end

		if self:GetRemainingTime() <= -10 then
			print("OnDestroy()_1")
			self:Destroy()
			return
		end

		if #(self.tGhosts) < self.cGhost then -- 如果 幽鬼表里的数 小于 应该生成的数
			local vForward = RandomVector(1.0)
			local hGhost_table = 
				{
					hUnit = CreateModifierThinker(hCaster, hAbility, "modifier_archon_passive_impel_ghost_count", nil, hParent_pos, hCaster:GetTeamNumber(), false),
					vTargetPosition = nil, -- 目标的位置
					hTarget = nil, -- 目标
					bReturning = false -- 是否返回 
				}
			hGhost_table.hUnit:SetForwardVector(vForward)

			table.insert(self.tGhosts, hGhost_table)
		end
		
		local hAttackTarget = nil
		local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), 
											hCaster:GetAbsOrigin(), 
											nil, 
											self.radius,
											DOTA_UNIT_TARGET_TEAM_ENEMY, 
											DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
											DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
											FIND_ANY_ORDER, --FIND_CLOSEST,  
											false)
	
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				hAttackTarget = enemy
			end
		end

		-- 找到目标后进行移动并实现伤害
		for i = #self.tGhosts, 1, -1 do
			local hGhost = self.tGhosts[i] -- 得到每一个幽灵
			-- buff持续时间接近结束时 返回所有的幽灵
			if self:GetRemainingTime() > 0 and self:GetRemainingTime() < 1 then -- self:GetRemainingTime() <= 0 and 
				hGhost.bReturning = true
				hGhost.hTarget = hParent
			end

			if hGhost.bReturning == false then -- 如果幽灵在不返回的状态
				hGhost.hTarget = hAttackTarget

				if not IsValidEntity(hGhost.hTarget) then 
					if hGhost.vTargetPosition == nil or hGhost.hTarget == nil then -- 没有目标的时候 随机移动
						hGhost.vTargetPosition = hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(self.ghost_speed, self.radius)
					end
				else
					hGhost.vTargetPosition = nil
				end
			end
			
			-- 如果幽灵超过了半径的最大范围  则回到英雄身边
			if not hParent:IsPositionInRange(hGhost.hUnit:GetAbsOrigin(), self.radius) then
				--hGhost.hUnit:SetAbsOrigin(hParent:GetAbsOrigin())  --立即回到英雄身边

				-- 慢慢移动到英雄身边
				hGhost.bReturning = true
				hGhost.hTarget = hParent
			end	

			-- 所有的幽灵回到身边 才能结束buff的持续时间 --( 未实现 )
			-- if hGhost.hTarget == hParent and hGhost.bReturning == true and #self.tGhosts ~= 0 then
			-- 	print("1")
			-- 	self:SetDuration(1, true)	
			-- 	hGhost.vTargetPosition = hParent:GetAbsOrigin()
			-- 	if hGhost.vTargetPosition == hParent:GetAbsOrigin() then 
			-- 		print("2")
			-- 		hGhost.hUnit:RemoveModifierByName("modifier_archon_passive_impel_ghost_count")
			-- 		table.remove(self.tGhosts, i)
			-- 		if #self.tGhosts == 0 then
			-- 			self:Destroy()
			-- 			print("3")
			-- 			self:SetDuration(0, false)
			-- 			return
			-- 		end
			-- 	end
			-- end
--------------------------------------------- 移动-----------------------------------------------------------
			if IsValidEntity(hGhost.hUnit) then
				-- 有角度的速度
				local fAngularSpeed = self:GetRemainingTime() <= 0 and (1 / (1 / 30) * FrameTime()) or ((1 / 9) / (1 / 30) * FrameTime())
				-- 目标的位置
				local vTargetPosition = IsValidEntity(hGhost.hTarget) and hGhost.hTarget:GetAbsOrigin() or hGhost.vTargetPosition
				local vDirection = vTargetPosition - hGhost.hUnit:GetAbsOrigin() -- 得到幽灵距离目标的距离
				vDirection.z = 0
				vDirection = vDirection:Normalized() -- 得到移动到目标的方向

				local vForward = hGhost.hUnit:GetForwardVector() -- 得到前进的方向
				--得到角度 Clamp(v,a,b) v:输入的数据  a、b: 对v的限制
				local fAngle = math.acos(Clamp(vDirection.x * vForward.x + vDirection.y * vForward.y, -1, 1))

				fAngularSpeed = math.min(fAngularSpeed, fAngle) -- 重新得到 角度的速度与角度的最小值

				local vCross = vForward:Cross(vDirection) -- Cross 用于物体移动的平滑处理
				if vCross.z < 0 then
					fAngularSpeed = -fAngularSpeed
				end
				vForward = self:Rotation2D(vForward, fAngularSpeed) -- 计算幽灵旋转的角度的速度

				hGhost.hUnit:SetForwardVector(vForward) -- 设置幽灵的旋转角度
				-- 移动到目标的位置
				local vPosition = GetGroundPosition(hGhost.hUnit:GetAbsOrigin() + hGhost.hUnit:GetForwardVector() * (self.ghost_speed * FrameTime()), hParent)
				hGhost.hUnit:SetAbsOrigin(vPosition)

				-- 攻击伤害
				if hGhost.hUnit:IsPositionInRange(vTargetPosition, 32) then
					if hGhost.hTarget ~= nil then -- 当前目标不为空
						if hGhost.bReturning then -- 返回后消除实体
							hGhost.hTarget = nil
							hGhost.bReturning = false
							if self:GetRemainingTime() <= 0 then
								hGhost.hUnit:RemoveModifierByName("modifier_archon_passive_impel_ghost_count")
								table.remove(self.tGhosts, i)
								if #self.tGhosts == 0 then
									self:Destroy()
									return
								end
							end
						else
							local tDamageTable = 
								{
									ability = hAbility,
									attacker = hCaster,
									victim = hGhost.hTarget,
									damage = self.ghost_damage,
									damage_type = DAMAGE_TYPE_MAGICAL
								}
								ApplyDamage(tDamageTable)

								hGhost.hTarget = hParent
								hGhost.bReturning = true
						end
					else
						hGhost.vTargetPosition = hParent:GetAbsOrigin() + RandomVector(1) * RandomFloat(0, self.radius)
					end
				end
			end
		end
	end
end


--------------------------------------------创建幽灵---------------------------------------------
if modifier_archon_passive_impel_ghost_count == nil then 
	modifier_archon_passive_impel_ghost_count = class({})
end

function modifier_archon_passive_impel_ghost_count:OnDestroy()
	if IsServer() then
		print("OnDestroy()_2")
		self:GetParent():ForceKill(false) -- 删除创建的幽灵实体
	end
end

function modifier_archon_passive_impel_ghost_count:CheckState() -- 碰撞效果
	return 
		{
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true,               -- 跟英雄无碰撞
			[MODIFIER_STATE_INVULNERABLE] = true,                    -- 不可攻击的
			[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,-- 可飞行的
			[MODIFIER_STATE_OUT_OF_GAME] = true,                     -- 
			[MODIFIER_STATE_NO_HEALTH_BAR] = true,                   -- 没有血条
			--[MODIFIER_STATE_NO_UNIT_COLLISION] = true                
		}
end

function modifier_archon_passive_impel_ghost_count:DeclareFunctions()
	return 
		{
			MODIFIER_PROPERTY_MODEL_CHANGE,
			MODIFIER_PROPERTY_OVERRIDE_ANIMATION
		}
end

function modifier_archon_passive_impel_ghost_count:GetModifierModelChange(params)
	return "models/heroes/death_prophet/death_prophet_ghost.vmdl"
end

function modifier_archon_passive_impel_ghost_count:GetOverrideAnimation(params)
	return ACT_DOTA_RUN
end