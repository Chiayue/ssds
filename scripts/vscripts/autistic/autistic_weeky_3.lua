-- 小怪 腐蚀 死亡后会给敌人叠加DEBUFF，每秒造成1%最大生命的魔法伤害，最多可叠加20层，持续5秒。
-- BOSSS 受到攻击 会给敌人叠加DEBUFF
-- 敌人
LinkLuaModifier("modifier_autistic_week3_emeny", "autistic/autistic_weeky_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week3_boss", "autistic/autistic_weeky_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week3_emeny_effect", "autistic/autistic_weeky_3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_autistic_week3_ally", "autistic/autistic_weeky_3", LUA_MODIFIER_MOTION_NONE)

------------------------------------------------------------------------------------------
if modifier_autistic_week3_emeny == nil then modifier_autistic_week3_emeny = {} end
function modifier_autistic_week3_emeny:IsHidden() return false end
function modifier_autistic_week3_emeny:GetTexture() return "die_venom" end
function modifier_autistic_week3_emeny:DeclareFunctions() return { MODIFIER_EVENT_ON_DEATH } end
function modifier_autistic_week3_emeny:OnDeath(args) 
	if not IsServer() then return end
	if self:GetParent() == args.unit then
		local hAttack = args.attacker
		hAttack:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_autistic_week3_emeny_effect", { duration = 5} ) 
	end
end
------------------------------------------------------------------------------------------
if modifier_autistic_week3_boss == nil then modifier_autistic_week3_boss = {} end
function modifier_autistic_week3_boss:IsHidden() return false end
function modifier_autistic_week3_boss:GetTexture() return "die_venom" end
function modifier_autistic_week3_boss:DeclareFunctions() return { MODIFIER_EVENT_ON_TAKEDAMAGE } end
function modifier_autistic_week3_boss:OnTakeDamage(args) 
	if not IsServer() then return end
	if self:GetParent() == args.unit then
		local hAttack = args.attacker
		hAttack:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_autistic_week3_emeny_effect", { duration = 5} ) 
	end
end
------------------------------------------------------------------------------------------
if modifier_autistic_week3_emeny_effect == nil then modifier_autistic_week3_emeny_effect = {} end
function modifier_autistic_week3_emeny_effect:IsDebuff() return true end
function modifier_autistic_week3_emeny_effect:GetTexture() return "die_venom" end
function modifier_autistic_week3_emeny_effect:OnCreated()
	if not IsServer() then return end
	self:SetStackCount(1)
	self:StartIntervalThink(1)
end

function modifier_autistic_week3_emeny_effect:OnRefresh()
	if not IsServer() then return end
	if self:GetStackCount() < 10 then
		self:IncrementStackCount()
	else
		self:SetStackCount( self:GetStackCount() )
	end
end

function modifier_autistic_week3_emeny_effect:OnIntervalThink()
	if not IsServer() then return end
	local hUnit = self:GetParent()
	local nDamage = hUnit:GetMaxHealth() * 0.01 * self:GetStackCount()
	local damage = {
		victim = hUnit,
		attacker = self:GetCaster() ,
		damage = nDamage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage( damage )
end

function modifier_autistic_week3_emeny_effect:DeclareFunctions() 
	return { 
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_TOOLTIP
	} 
end

function modifier_autistic_week3_emeny_effect:OnTooltip() 
	return self:GetStackCount()
end
-- function modifier_autistic_week3_emeny_effect:OnDeath(args) 
-- 	if not IsServer() then return end
-- 	if self:GetParent() == args.unit then
-- 		self:GetParent():RemoveModifierByName("modifier_autistic_week3_emeny_effect")
-- 	end
-- end
---------------------------------------------
if modifier_autistic_week3_ally == nil then modifier_autistic_week3_ally = {} end
function modifier_autistic_week3_ally:GetTexture() return "archon_passive_light" end
function modifier_autistic_week3_ally:GetAttributes() return  MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_autistic_week3_ally:RemoveOnDeath() return false end