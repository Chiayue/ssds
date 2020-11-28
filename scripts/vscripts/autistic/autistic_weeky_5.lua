-- 敌人
LinkLuaModifier("modifier_autistic_week5_ally", "autistic/autistic_weeky_5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week5_ally_thinker", "autistic/autistic_weeky_5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week5_ally_debuff", "autistic/autistic_weeky_5", LUA_MODIFIER_MOTION_NONE)

-------------------------- 英雄 --------------------------
modifier_autistic_week5_ally = {}
function modifier_autistic_week5_ally:IsHidden() return false end
function modifier_autistic_week5_ally:GetTexture() return "qishangquan" end
function modifier_autistic_week5_ally:GetAttributes() return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_autistic_week5_ally:RemoveOnDeath() return false end
function modifier_autistic_week5_ally:IsHidden() return true end
function modifier_autistic_week5_ally:OnCreated() 
	if IsServer() then
		self.nLimitTime = 18
		self:StartIntervalThink(1)
		local EffectName_0 = "particles/test_particles/xulie/xulie.vpcf"
		self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(self.nLimitTime / 10), math.floor(self.nLimitTime % 10), 0))
	end
end

function modifier_autistic_week5_ally:OnIntervalThink()
	if IsServer() then
		if self:GetParent():IsAlive() == true then
			self:IncrementStackCount()
			local nStack = self:GetStackCount()
			local nCountDonw = self.nLimitTime - nStack
			if nCountDonw == 0 then
				self:SetStackCount(0)
				-- 触发效果
				CreateModifierThinker( 
					self:GetParent(), 
					self, 
					"modifier_autistic_week5_ally_thinker", 
					{ duration = 4}, 
					self:GetParent():GetAbsOrigin(), 
					self:GetCaster():GetTeamNumber(), 
					false 
				)
			end
			ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(nCountDonw / 10), math.floor(nCountDonw % 10), 0))
		end
	end
end
---------------------
modifier_autistic_week5_ally_thinker = {}
function modifier_autistic_week5_ally_thinker:OnCreated()
	self.radius = 1000
	if IsServer() then
		EmitSoundOn( "Hero_Gyrocopter.CallDown.Fire", self:GetParent() )
		
		self:StartIntervalThink(4)
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_gyrocopter/gyro_calldown_marker.vpcf", PATTACH_WORLDORIGIN, self:GetParent() )
		self:AddParticle(nFXIndex, false, false, -1, false, false)
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector(self.radius, 1, self.radius * (-1)))
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		local calldown_second_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_gyrocopter/gyro_calldown_second.vpcf", PATTACH_WORLDORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(calldown_second_particle, 0, Vector(600,500,500))
		ParticleManager:SetParticleControl(calldown_second_particle, 1, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(calldown_second_particle, 5, Vector(self.radius, self.radius, self.radius))
		ParticleManager:ReleaseParticleIndex(calldown_second_particle)
	end
end

function modifier_autistic_week5_ally_thinker:OnIntervalThink()
	if IsServer() then
		EmitSoundOn( "Hero_Gyrocopter.CallDown.Damage", self:GetParent() )
		local hHero = FindUnitsInRadius2(
				2, 
				self:GetParent():GetOrigin(), 
				self:GetParent(), 
				self.radius, 
				DOTA_UNIT_TARGET_TEAM_FRIENDLY, 
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
				0, 1, false 
			)

		for _, hUnit in pairs(hHero) do
			if hUnit:IsAlive() and hUnit:IsInvulnerable() == false then
				local nMaxHealth = hUnit:GetMaxHealth()
				ApplyDamage({
					victim 			= hUnit,
					damage 			= nMaxHealth * 0.7,
					damage_type		= DAMAGE_TYPE_MAGICAL,
					attacker 		= GlobalVarFunc.Luoli,
					ability 		= self
				})
				hUnit:AddNewModifier(GlobalVarFunc.Luoli, nil, "modifier_autistic_week5_ally_debuff", { duration = 15}) 
			end
		end
		
	end
end

modifier_autistic_week5_ally_debuff = {}
function modifier_autistic_week5_ally_debuff:GetTexture() return "pangolier_heartpiercer" end
function modifier_autistic_week5_ally_debuff:IsDeff() return true end
function modifier_autistic_week5_ally_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_TAKEDAMAGE_KILLCREDIT
	}
end
function modifier_autistic_week5_ally_debuff:GetDisableHealing()
	return 1
end