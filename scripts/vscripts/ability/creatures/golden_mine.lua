LinkLuaModifier("modifier_golden_mine", "ability/creatures/golden_mine", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_golden_mine_buff", "ability/creatures/golden_mine", LUA_MODIFIER_MOTION_NONE)

golden_mine_passive = class({})

function golden_mine_passive:GetIntrinsicModifierName()
	return "modifier_golden_mine"
end

modifier_golden_mine = class({
	IsHidden = function(self) return true end,
	DeclareFunctions = function(self) return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
	}end,
})

function modifier_golden_mine:CanParentBeAutoAttacked()
	return false
end

function modifier_golden_mine:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_golden_mine:GetAbsoluteNoDamageMagical()
	return 1
end

function modifier_golden_mine:GetAbsoluteNoDamagePure()
	return 1
end

function modifier_golden_mine:OnDeath(args)
	if args.unit:GetUnitName() == "npc_dota_gold_mine" then
		local vector = args.unit:GetOrigin()
		local newItem = CreateItem( "item_baoWu_book", nil, nil )
		local drop = CreateItemOnPositionSync( vector, newItem )
		local dropTarget = vector 
		newItem:LaunchLoot( false, 300, 0.75, dropTarget )
		--添加特效提示
        ParticleManager:CreateParticle("particles/diy_particles/treasuretips.vpcf", PATTACH_ABSORIGIN_FOLLOW,newItem:GetContainer())
		--宝物音效
		GlobalVarFunc:OnGameSound("baowubook_sound")
	end
end

function modifier_golden_mine:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        ability.attacks_need = ability:GetSpecialValueFor("attacks_need")
        caster:SetBaseMaxHealth(ability.attacks_need)
        caster:SetMaxHealth(ability.attacks_need)
        caster:SetHealth(ability.attacks_need)
    end
end

function modifier_golden_mine:OnAttackLanded(data)
	local caster = self:GetCaster()
	local target = data.target
	local attacker = data.attacker
	
	if target == caster and attacker:IsRealHero() and not attacker:IsIllusion() then
		local ability = self:GetAbility()
		local gold_duration = ability:GetSpecialValueFor("gold_duration")

		attacker:AddNewModifier(attacker, ability, "modifier_golden_mine_buff", {duration = gold_duration})
		ability.attacks_need = ability.attacks_need - 1
		if ability.attacks_need == 0 then
			caster:Kill(nil, attacker)
		else
			caster:SetHealth(ability.attacks_need)
		end	
	end
end

modifier_golden_mine_buff = class({
	IsBuff = function(self) return true end,
})

function modifier_golden_mine_buff:IsHidden()
	return true
end

function modifier_golden_mine_buff:OnCreated()
	if IsClient() then return end
	
	local ability = self:GetAbility()
	self.parent = self:GetParent()
	self.gold_interval = ability:GetSpecialValueFor("gold_interval")
	self.gold = ability:GetSpecialValueFor("gold")*self.gold_interval
	self.xp = ability:GetSpecialValueFor("xp")*self.gold_interval
	
	self:StartIntervalThink(self.gold_interval)
end

function modifier_golden_mine_buff:OnIntervalThink()
	if IsClient() then return end
	
	local player = PlayerResource:GetPlayer(self.parent:GetPlayerID())
	if player then
		SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, self.parent, self.gold, nil )
		self.parent:AddExperience(self.xp, 0, true, true)
		self.parent:ModifyGold(self.gold, false, 0)
	end
end
