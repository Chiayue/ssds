function Spawn( entityKeyValues )
    if not IsServer() then
		return
	end
    if thisEntity == nil then
		return
    end
    thisEntity:SetContextThink( "do_ability", do_ability, 0 )

end

function do_ability()
    local unit = thisEntity
    local ability_heal = unit:FindAbilityByName("the_injury")
    --local ability_fuhuo = unit:FindAbilityByName("tianshi_fuhuo")
    if unit:IsAlive() then
        if ability_heal:IsFullyCastable() then
            unit:CastAbilityImmediately(ability_heal,unit:GetEntityIndex())
        end
        return 1
    else
        return nil
    end
end