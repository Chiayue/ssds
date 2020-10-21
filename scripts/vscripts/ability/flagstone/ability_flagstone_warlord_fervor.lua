-- 破甲攻击
LinkLuaModifier( "modifier_ability_flagstone_warlord_fervor", "ability/flagstone/ability_flagstone_warlord_fervor",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ability_flagstone_warlord_fervor_stacks", "ability/flagstone/ability_flagstone_warlord_fervor",LUA_MODIFIER_MOTION_NONE )
-------------------------------------------------

if ability_flagstone_warlord_fervor == nil then ability_flagstone_warlord_fervor = {} end

function ability_flagstone_warlord_fervor:GetIntrinsicModifierName()
 	return "modifier_ability_flagstone_warlord_fervor"
end
--------------------------------------------------
if modifier_ability_flagstone_warlord_fervor == nil then modifier_ability_flagstone_warlord_fervor = {} end
function modifier_ability_flagstone_warlord_fervor:IsHidden()return true end
function modifier_ability_flagstone_warlord_fervor:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
	return funcs
end

function modifier_ability_flagstone_warlord_fervor:OnAttackLanded( params )
	-- body
	if params.attacker ~= self:GetParent() then return end
	if params.target == self:GetParent() then return end
	if params.attacker:HasModifier("modifier_ability_flagstone_warlord_fervor") then
		local hTarget = params.target
		local hCaster = params.attacker
		
		local hModifier = hCaster:FindModifierByNameAndCaster("modifier_ability_flagstone_warlord_fervor_stacks",hCaster)
		if hModifier then
			if hModifier.last_target == params.target then
				if hModifier:GetStackCount() < 5 then
					hModifier:IncrementStackCount()
				else
					hModifier:SetDuration(5,false)
				end
			else
				hCaster:RemoveModifierByName("modifier_ability_flagstone_warlord_fervor_stacks")
			end
		else
			hModifier = hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_ability_flagstone_warlord_fervor_stacks", { duration = 5} )
			hModifier.last_target = params.target
		end
	end
end

-------------------------------------------
modifier_ability_flagstone_warlord_fervor_stacks = modifier_ability_flagstone_warlord_fervor_stacks or class({})
function modifier_ability_flagstone_warlord_fervor_stacks:IsDebuff() return false end
function modifier_ability_flagstone_warlord_fervor_stacks:IsHidden() return false end
function modifier_ability_flagstone_warlord_fervor_stacks:IsPurgable() return false end
function modifier_ability_flagstone_warlord_fervor_stacks:RemoveOnDeath() return false end
-------------------------------------------
function modifier_ability_flagstone_warlord_fervor_stacks:OnCreated()
	if IsServer() then
		self:SetStackCount(1)
	end
end

