-- 西瓦的守护
LinkLuaModifier("modifier_item_val_of_shield", "item/item_val_of_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_val_of_shield_custom_blast", "item/item_val_of_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_val_of_shield_custom_slow", "item/item_val_of_shield", LUA_MODIFIER_MOTION_NONE)
--LinkLuaModifier("modifier_item_val_of_shield_custom_particle", "item/item_val_of_shield", LUA_MODIFIER_MOTION_NONE)

--Abilities 
if item_val_of_shield == nil then
	item_val_of_shield = class({})
end
function item_val_of_shield:OnSpellStart()
	local hCaster = self:GetParent()
	local blast_radius = self:GetSpecialValueFor("blast_radius")
	local blast_speed = self:GetSpecialValueFor("blast_speed")
	local abil_damage = self:GetCaster():GetIntellect() * 100

	--hCaster:EmitSound("DOTA_Item.ShivasGuard.Activate") -- 播放声音
	hCaster:AddNewModifier(hCaster, self, "modifier_item_val_of_shield_custom_blast", {duration = blast_radius/blast_speed})

	-- 搜索范围内的敌人
	local enemies = FindUnitsInRadius(
		hCaster:GetTeamNumber(), 
		hCaster:GetOrigin(),
		hCaster, 
		blast_radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 0, false 
	)

	-- 减少敌人的移速
	for _,enemy in pairs(enemies) do
		if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then

			enemy:AddNewModifier(hCaster, self, "modifier_item_val_of_shield_custom_slow", {duration = blast_speed})
			local damage = {
				victim = enemy,
				attacker = hCaster,
				damage = abil_damage,
				damage_type = DAMAGE_TYPE_MAGICAL,
			}
			ApplyDamage(damage)	
		end
	end	
end

function item_val_of_shield:GetIntrinsicModifierName()
	return "modifier_item_val_of_shield"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_val_of_shield == nil then
	modifier_item_val_of_shield = class({})
end
function modifier_item_val_of_shield:IsHidden()
	return true
end
function modifier_item_val_of_shield:IsDebuff()
	return false
end
function modifier_item_val_of_shield:IsPurgable()
	return false
end
function modifier_item_val_of_shield:IsPurgeException()
	return false
end
function modifier_item_val_of_shield:IsStunDebuff()
	return false
end
function modifier_item_val_of_shield:AllowIllusionDuplicate()
	return false
end
function modifier_item_val_of_shield:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_item_val_of_shield:OnCreated(params)
	local hParent = self:GetParent()
	self.armor = self:GetAbility():GetSpecialValueFor("armor") -- 护甲
	self.spell_resistance = self:GetAbility():GetSpecialValueFor("spell_resistance") -- 魔抗
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health") -- 增加生命值
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana") -- 增加魔法值
	self.blast_radius = self:GetAbility():GetSpecialValueFor("blast_radius") -- 冲击波半径

end
function modifier_item_val_of_shield:OnRefresh(params) -- 刷新时运行
	local hParent = self:GetParent()

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(-self.bonus_health)
			 hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end

	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.blast_radius = self:GetAbility():GetSpecialValueFor("blast_radius")

	if IsServer() then
		if hParent:IsBuilding() then
			hParent:ModifyMaxHealth(self.bonus_health)
			hParent:ModifyMaxMana(self.bonus_mana)
		end
	end
end
function modifier_item_val_of_shield:OnDestroy()
	local hParent = self:GetParent()
	if IsServer() then
		if hParent:IsBuilding() then

			hParent:ModifyMaxHealth(-self.bonus_health)
			hParent:ModifyMaxMana(-self.bonus_mana)
		end
	end
end

function modifier_item_val_of_shield:DeclareFunctions()
	return 
	{
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, -- 护甲
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, -- 魔抗
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
	}
end

function modifier_item_val_of_shield:GetModifierPhysicalArmorBonus(params) -- 护甲
	return self.armor
end
function modifier_item_val_of_shield:GetModifierMagicalResistanceBonus(params) -- 魔抗
	return self.spell_resistance
end
function modifier_item_val_of_shield:GetModifierHealthBonus(params) -- 血量
	return self.bonus_health
end
function modifier_item_val_of_shield:GetModifierManaBonus(params) -- 魔法
	return self.bonus_mana
end
---------------------------------------------------------------------
if modifier_item_val_of_shield_custom_blast == nil then
	modifier_item_val_of_shield_custom_blast = class({})
end

function modifier_item_val_of_shield_custom_blast:IsHidden()
	return true
end

function modifier_item_val_of_shield_custom_blast:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_val_of_shield_custom_blast:OnCreated(params)
	local caster = self:GetParent()
	--print(DeepPrintTable(params))
	local blast_radius = self:GetAbility():GetSpecialValueFor("blast_radius") -- 特效范围
	--local blast_speed = self:GetAbility():GetSpecialValueFor("blast_speed") -- 特效持续时间
	
	--创建粒子特效
	local effName = "particles/items2_fx/shivas_guard_active.vpcf"
	local nFXIndex = ParticleManager:CreateParticle(effName, PATTACH_RENDERORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(blast_radius, blast_radius, blast_radius))
	
end
---------------------------------------------------------------------
if modifier_item_val_of_shield_custom_slow == nil then
	modifier_item_val_of_shield_custom_slow = class({})
end
function modifier_item_val_of_shield_custom_slow:IsHidden()
	return false
end

function modifier_item_val_of_shield_custom_slow:IsDebuff()
	return true
end

function modifier_item_val_of_shield_custom_slow:IsPurgable()
	return true
end

function modifier_item_val_of_shield_custom_slow:IsPurgeException()
	return true
end

function modifier_item_val_of_shield_custom_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_item_val_of_shield_custom_slow:OnCreated(keys)
	self.lower_speed = self:GetAbility():GetSpecialValueFor("lower_speed") -- 降低速度
end
function modifier_item_val_of_shield_custom_slow:GetModifierMoveSpeedBonus_Constant(params)
	return self.lower_speed
end
---------------------------------------------------------------------
--if modifier_item_val_of_shield_custom_particle == nil then
--	modifier_item_val_of_shield_custom_particle = class({}, nil, ParticleModifier)
--end
--function modifier_item_val_of_shield_custom_particle:OnCreated(params)
	--if IsClient() then
--		LocalPlayerAbilityParticle(self:GetAbility(), function()
--			local iParticleID = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
--			ParticleManager:ReleaseParticleIndex(iParticleID)
--		end, PARTICLE_DETAIL_LEVEL_LOW)
	--end
--end