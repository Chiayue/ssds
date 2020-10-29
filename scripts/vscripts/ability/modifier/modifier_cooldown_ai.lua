if modifier_cooldown_ai == nil then
	modifier_cooldown_ai = class({})
end

function modifier_cooldown_ai:IsHidden()
	return true
end
function modifier_cooldown_ai:IsDebuff()
	return false
end
function modifier_cooldown_ai:IsPurgable()
	return false
end
function modifier_cooldown_ai:IsPurgeException()
	return false
end
function modifier_cooldown_ai:AllowIllusionDuplicate()
	return false
end
function modifier_cooldown_ai:RemoveOnDeath()
	return false
end
function modifier_cooldown_ai:DestroyOnExpire()
	return false
end
function modifier_cooldown_ai:IsPermanent()
	return true
end

function modifier_cooldown_ai:OnCreated()
	if IsServer() then 
		self:StartIntervalThink(1)
	end
end

function modifier_cooldown_ai:OnIntervalThink( ... )
	local hParent = self:GetParent()

	if IsServer() then 
		for i=0,3 do
			local ability_fuhuo = hParent:GetAbilityByIndex(i)
			if ability_fuhuo ~= nil then 
	    		local ability_name = ability_fuhuo:GetAbilityName()
	    		--print("ability_name>>>>>>>>>>>>>>>>>>>>>>=",ability_name)
	    		if not ability_fuhuo:IsPassive() then 
	                print("args")
	                if ability_fuhuo:IsFullyCastable() then
	                    hParent:CastAbilityImmediately(ability_fuhuo,hParent:GetEntityIndex())
	                end
	            end
        	end
		end
	end
end