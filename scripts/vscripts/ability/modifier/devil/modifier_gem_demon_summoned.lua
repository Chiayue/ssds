-- 恶魔召唤 召唤5只BOSS，等同于270波BOSS，持续30秒，额外拥有机制技能，每杀死1只，仅召唤者10%概率获得紫装，90%概率金装 modifier_gem_demon_summoned

if modifier_gem_demon_summoned == nil then
	modifier_gem_demon_summoned = class({})
end

function modifier_gem_demon_summoned:IsHidden()
    return false
end

function modifier_gem_demon_summoned:OnCreated(params)
    if IsServer() then
        self:SetDuration( 60, true )
        local hParent = self:GetParent()
        local nPlayerID = hParent:GetOwner():GetPlayerID() -- modifier_gem_devil_subtract_damage
        self.boos_count = 0
        for i = 1, 3 do 
            local position = GlobalVarFunc:IsCanFindPath(1000, 3500)
            local bossModel = self:_addAbyssModel()
            local boss = CreateUnitByNameInPool(bossModel, position, true, nil, nil, DOTA_TEAM_BADGUYS)

            boss.nPlayerID = nPlayerID
            boss.name = boss:GetUnitName()
            self:setAbyssMonsterBaseInformation(boss) -- 基本属性

            --boss技能
            self:_addAbyssAbility(boss,3)
            self.boos_count = self.boos_count + 1
            boss:AddNewModifier(hParent, self:GetAbility(), "modifier_gem_devil_subtract_damage", {duration = self:GetDuration()}) 
            
        end
    end
end

function modifier_gem_demon_summoned:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_gem_demon_summoned:OnDeath(params)
    local hParent = self:GetParent()
    local nPlayerID = hParent:GetOwner():GetPlayerID()
    if params.unit.name == nil then return end
    if params.unit:GetUnitName() == params.unit.name then
        if self.boos_count > 0 then 
            local hPlayerID =  params.unit.nPlayerID
            local entity = PlayerResource:GetSelectedHeroEntity(hPlayerID)
            if entity == hParent then 
                local random_odds = RandomInt(1, 100)
                if random_odds <= 15 then 
                    SeriseSystem:CreateSeriesItemS2(hParent)      -- T4
                else--if random_odds <= 85 then 
                    SeriseSystem:CreateSeriesItem(hParent,4,1,3)
                end
                Archive:SaveServerEqui(nPlayerID)
            end
            self.boos_count = self.boos_count - 1
        else
            hParent:RemoveModifierByName("modifier_gem_demon_summoned")
        end
    end
end

function modifier_gem_demon_summoned:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_demon_summoned:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_demon_summoned:GetTexture()
    return "emozhaohuan"
end

function modifier_gem_demon_summoned:_addAbyssModel()
    local random = RandomInt(1,#abyss_boss)
    local abyssBossModel =  abyss_boss[random]
    return abyssBossModel
end

function modifier_gem_demon_summoned:setAbyssMonsterBaseInformation(unit)
    -- local health = self:abyss_Health()
    -- local healthRegen = self:abyss_HealthRegen()
    -- local attack = self:abyss_AttackDamage()
    -- local armor = self:abyss_Armor()
    -- local magicalResistance = self:abyss_MagicalResistance()
    -- local xp = self:abyss_DeathXP()
    -- local gold = self:abyss_DeathGold()

    health = 2000000000
    attack = 100000000
    
    unit:SetBaseMaxHealth(health)   
	unit:SetMaxHealth(health)
	unit:SetHealth(health)
	unit:SetBaseHealthRegen(150)
	--unit:SetDeathXP(xp)
	--unit:SetMaximumGoldBounty(gold)
	--unit:SetMinimumGoldBounty(gold)
	unit:SetBaseDamageMax(attack)
    unit:SetBaseDamageMin(attack)
    unit:SetPhysicalArmorBaseValue(400)
    unit:SetBaseMagicalResistanceValue(95)
	unit:CreatureLevelUp(1)
end

function modifier_gem_demon_summoned:_addAbyssAbility(unit, index)
    --添加ai
    unit:AddNewModifier(unit, nil, "modifier_cooldown_ai", nil)

    --添加技能
    local newAbyssAbilityTable = {}
    for i=1,#abyss_ability do
        newAbyssAbilityTable[i] = abyss_ability[i]
    end

    for i=1,index do
        local randomNum = RandomInt(1, #newAbyssAbilityTable)
        local abilityName = newAbyssAbilityTable[randomNum]
        table.remove( newAbyssAbilityTable, randomNum )

        local newAbility = unit:AddAbility(abilityName)
        newAbility:SetLevel(1)
    end
end