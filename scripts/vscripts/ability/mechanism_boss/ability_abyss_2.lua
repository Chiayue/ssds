-- 旋风斩   

if ability_abyss_2 == nil then 
	ability_abyss_2 = class({})
end

function ability_abyss_2:IsHidden( ... )
	return true
end

function ability_abyss_2:OnSpellStart( ... )
	local hCaster = self:GetCaster()
	
	
	-- 寻找自身1000范围的敌人
	local enemys = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hCaster:GetAbsOrigin(), 
		hCaster, 
		1000, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false)

	for _, enemy in pairs(enemys) do
		ApplyDamage({
			victim = enemy,
			attacker = hCaster,
			damage = 2000,
			damage_type = DAMAGE_TYPE_MAGICAL,
		})
	end

	-- particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf
	local EffectName_0 = "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser.vpcf"
	self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_RENDERORIGIN_FOLLOW, hCaster)
	ParticleManager:SetParticleControl(self.nFXIndex_0, 0, Vector(1000, 1000, 1000))  -- Vector(0, number, 0)
	-- ParticleManager:DestroyParticle( self.nFXIndex_0, false )
	-- ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )
	-- self:AddParticle(self.nFXIndex_0, false, false, -1, false, true)
end