if modifier_gem_special_buff == nil then 
    modifier_gem_special_buff = class({})
end

function modifier_gem_special_buff:IsHidden( ... )
	return false
end

function modifier_gem_special_buff:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_special_buff:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_special_buff:GetTexture()
	return "benleijian"
end

function modifier_gem_special_buff:OnCreated()
	if IsServer() then 
		self:StartIntervalThink(1)
		self.timer_built_cooldown = true
		self.timer_count = 0
	end
end

function modifier_gem_special_buff:OnIntervalThink( params )
	if not IsServer() then return end -- 设置内置冷却时间 15 秒
	
	if self.timer_built_cooldown == false and self.timer_count == 15 then 
		self.timer_built_cooldown = true
		self.timer_count = 0
	elseif self.timer_built_cooldown == false then 
		self.timer_count = self.timer_count + 1
	end
end

function modifier_gem_special_buff:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
end

function modifier_gem_special_buff:OnAttackLanded( params )
    if params.attacker ~= self:GetParent() then
		return 0
    end

	if self.timer_built_cooldown == false then 
    	return 0
    end

    local hParent = self:GetParent()
    local hTarget = params.target
    local chance = 100

    local nowChance = RandomInt(0,100)
	if nowChance  > chance then
		return 0
    end

    local EffectName = "particles/thd2/items/item_qijizhixing.vpcf"
	self.nFXIndex = ParticleManager:CreateParticle( EffectName, PATTACH_ABSORIGIN, hTarget)
	ParticleManager:SetParticleControl( self.nFXIndex, 0, hTarget:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndex, 1, hTarget:GetAbsOrigin() )
	ParticleManager:SetParticleControl( self.nFXIndex, 3, hTarget:GetAbsOrigin() )

    local enemies = GetAOEMostTargetsSpellTarget(
		hParent:GetTeamNumber(), 
		hTarget:GetOrigin(), 
		hTarget, 
		500, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	)

    local all_damage = (hParent:GetIntellect() + hParent:GetStrength() + hParent:GetAgility()) * hParent:GetLevel() * 0.5
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
			ApplyDamage({
                victim = enemy,
                attacker = hParent,
                damage = all_damage,
                damage_type = DAMAGE_TYPE_MAGICAL, 
            })
		end
	end
	self.timer_built_cooldown = false
end