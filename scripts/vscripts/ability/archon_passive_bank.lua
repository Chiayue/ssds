require("player_data")
LinkLuaModifier( "modifier_archon_passive_bank", "ability/archon_passive_bank.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_archon_passive_bank_thinker", "ability/archon_passive_bank.lua",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------
--Abilities
if archon_passive_bank == nil then
	archon_passive_bank = class({})
end

function archon_passive_bank:GetIntrinsicModifierName()
 	return "modifier_archon_passive_bank"
end

local sParticle = "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf"

if modifier_archon_passive_bank == nil then
	modifier_archon_passive_bank = class({})
end


function modifier_archon_passive_bank:IsHidden()
	return true
end

function modifier_archon_passive_bank:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end


function modifier_archon_passive_bank:OnAttack( params )
	--if IsServer() then
		if params.attacker ~= self:GetParent() then
			return 0
		end
		--EmitSoundOn("Hero_Zuus.ArcLightning.Cast",params.attacker)
		if self:GetCaster():HasModifier("modifier_item_archer_bow_multe")  == true then return end
		local nLevel = self:GetAbility():GetLevel()
		local nowChance = RandomInt(0,100)
		local nBonusChance = 0
		if nLevel >= ABILITY_AWAKEN_1 then
			nBonusChance = 5
		end
		local chance = self:GetAbility():GetSpecialValueFor( "chance" ) + nBonusChance
		local nTalentStack = self:GetCaster():GetModifierStackCount("modifier_series_reward_talent_flame", self:GetCaster() )
		if nTalentStack >= 2 then
			chance = chance + 5
		end
		if nowChance  > chance then
			return 0
		end
		local hAttacker = params.attacker
		local hTarget = params.target
		local abil_damage = 1
		local hCaster = self:GetCaster()
		local nPlayerID = hCaster:GetPlayerID() 
		local hPlayerData = CustomNetTables:GetTableValue( "player_data", "common")
		local nIncomeLevel = hPlayerData[tostring(nPlayerID)]["Income_Level"]
		if nLevel >= ABILITY_AWAKEN_2 then
			local nIncomeAmount = hPlayerData[tostring(nPlayerID)]["Income_Amount"]
			self:GetAbility().nDamage = (nIncomeAmount * nIncomeLevel * self:GetAbility():GetSpecialValueFor( "coefficient" ) * 0.01 )+ 10
		else
			self:GetAbility().nDamage = (nIncomeLevel * nIncomeLevel * self:GetAbility():GetSpecialValueFor( "coefficient" ) * 0.01 )+ 10
		end
		self:GetAbility().hTargetsHit = {}
		self:HitTarget( hCaster,hTarget)
	--end
end

function modifier_archon_passive_bank:HitTarget( hOrigin,hTarget)
	if hTarget == nil then
		return
	end
	local lightningBolt = ParticleManager:CreateParticle(
		sParticle, 
		PATTACH_WORLDORIGIN, 
		hOrigin
	)
	ParticleManager:SetParticleControl(
		lightningBolt,
		0,
		Vector(hOrigin:GetAbsOrigin().x,hOrigin:GetAbsOrigin().y,hOrigin:GetAbsOrigin().z + hOrigin:GetBoundingMaxs().z )
	)   
	ParticleManager:SetParticleControl(
		lightningBolt,
		1,
		Vector(hTarget:GetAbsOrigin().x,hTarget:GetAbsOrigin().y,hTarget:GetAbsOrigin().z + hTarget:GetBoundingMaxs().z )
	)
	EmitSoundOn( "Hero_Zuus.ArcLightning.Cast", hTarget )
	hTarget:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		"modifier_archon_passive_bank_thinker", 
		{ duration = 1} 
	)

	table.insert( self:GetAbility().hTargetsHit, hTarget )
end


--------------------------------------------------
if modifier_archon_passive_bank_thinker == nil then
	modifier_archon_passive_bank_thinker = class({})
end

function modifier_archon_passive_bank_thinker:IsHidden() 
	return true
end
-- 伤害公式 投资等级*投资等级/14
function modifier_archon_passive_bank_thinker:OnCreated()
	if IsServer() then
		self.nMaxTargets = 10
		self:StartIntervalThink( 0.1 )
	end
end

function modifier_archon_passive_bank_thinker:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_archon_passive_bank_thinker:OnIntervalThink()
	if IsServer() then
		local hTarget =  self:GetParent()
		local enemies = FindUnitsInRadius( 
			self:GetCaster():GetTeamNumber(), 
			hTarget:GetOrigin(), 
			hTarget, 
			600, 
			DOTA_UNIT_TARGET_TEAM_ENEMY, 
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
			0, 
			false 
		)
		local hClosestTarget = nil
		local flClosestDist = 0.0
		-- 选取范围最近的1个单位
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil then

					local bIsHit = false

					if self:GetAbility().hTargetsHit ~= nil then
						for _,hHitEnemy in ipairs(self:GetAbility().hTargetsHit) do
							if enemy == hHitEnemy then
								bIsHit = true
							end 
						end
					end
					-- 如果单位没有被击中过，计算距离
					if bIsHit == false then
						local vToTarget = enemy:GetOrigin() - self:GetParent():GetOrigin()
						local flDistToTarget = vToTarget:Length()

						if hClosestTarget == nil or flDistToTarget < flClosestDist then
							hClosestTarget = enemy
							flClosestDist = flDistToTarget
						end
					end			
				end
			end
		end
		
		if hClosestTarget ~= nil and #self:GetAbility().hTargetsHit < self.nMaxTargets then
			self:HitTarget( hTarget,hClosestTarget)
		end
		

		local damage = {
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self:GetAbility().nDamage,
			damage_type = self:GetAbility():GetAbilityDamageType(),
			ability = self:GetAbility()
		}
		ApplyDamage( damage )
		enemies = nil
		self:Destroy()
	end
end

function modifier_archon_passive_bank_thinker:HitTarget( hOrigin,hTarget)
	if hTarget == nil then
		return
	end
	local lightningBolt = ParticleManager:CreateParticle(sParticle, PATTACH_WORLDORIGIN, hOrigin)
	ParticleManager:SetParticleControl(
		lightningBolt,
		0,
		Vector(hOrigin:GetAbsOrigin().x,hOrigin:GetAbsOrigin().y,hOrigin:GetAbsOrigin().z + hOrigin:GetBoundingMaxs().z )
	)   
	ParticleManager:SetParticleControl(
		lightningBolt,
		1,
		Vector(hTarget:GetAbsOrigin().x,hTarget:GetAbsOrigin().y,hTarget:GetAbsOrigin().z + hTarget:GetBoundingMaxs().z )
	)
	-- EmitSoundOn( "Hero_Zuus.ArcLightning.Cast", hTarget )
	table.insert( self:GetAbility().hTargetsHit, hTarget )
	hTarget:AddNewModifier( 
		self:GetCaster(), 
		self:GetAbility(), 
		"modifier_archon_passive_bank_thinker", 
		{ duration = 1} 
	)
end