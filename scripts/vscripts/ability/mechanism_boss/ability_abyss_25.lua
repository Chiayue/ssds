-- 命运数字 ability_abyss_25
-- LinkLuaModifier("modifier_ability_abyss_25_debuff", "ability/mechanism_Boss/ability_abyss_25", LUA_MODIFIER_MOTION_NONE)
-- LinkLuaModifier("modifier_ability_abyss_25_buff", "ability/mechanism_Boss/ability_abyss_25", LUA_MODIFIER_MOTION_NONE)

if ability_abyss_25 == nil then 
    ability_abyss_25 = class({})
end

function ability_abyss_25:IsHidden( ... )
	return true
end

function ability_abyss_25:OnSpellStart( ... )
    local hCaster = self:GetCaster()
    
    local number = RandomInt(1, 6)

    local EffectName_0 = "particles/test_particles/xulie/xulie.vpcf"
    self.nFXIndex_0 = ParticleManager:CreateParticle( EffectName_0, PATTACH_OVERHEAD_FOLLOW, hCaster)
    ParticleManager:SetParticleControl(self.nFXIndex_0, 1, Vector(math.floor(number / 10), math.floor(number % 10), 0))  -- Vector(0, number, 0)
    Timer(2,function()
        ParticleManager:DestroyParticle( self.nFXIndex_0, false )
        ParticleManager:ReleaseParticleIndex( self.nFXIndex_0 )

        --print("number>>>>>>>=",number)
        if number%2 == 1 then -- 奇数
            hCaster:AddNewModifier(hCaster, hAbility, "modifier_stunned", {duration = 2})
        else
            local enemys = FindUnitsInRadius(
            hCaster:GetTeamNumber(), 
            hCaster:GetAbsOrigin(), 
            hCaster, 
            99999, 
            DOTA_UNIT_TARGET_TEAM_ENEMY, 
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
            0, 0, false)
            
            for _, enemy in pairs(enemys) do 
                enemy:AddNewModifier(hCaster, self, "modifier_stunned", {duration = 2})
            end
        end
    end)
end