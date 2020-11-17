if HeroesSkin == nil then
	HeroesSkin = {}
end

local HeroName = {
	archon_passive_fire 		= "npc_dota_hero_lina",
    archon_passive_earth 		= "npc_dota_hero_lone_druid",
    archon_passive_ice 			= "npc_dota_hero_crystal_maiden",
    archon_passive_natural 		= "npc_dota_hero_enchantress",
    archon_passive_dark 		= "npc_dota_hero_drow_ranger",
    archon_passive_light 		= "npc_dota_hero_skywrath_mage",
    archon_passive_rage 		= "npc_dota_hero_troll_warlord",
    archon_passive_puncture 	= "npc_dota_hero_windrunner",
    archon_passive_magic		= "npc_dota_hero_rubick",
    archon_passive_bank 		= "npc_dota_hero_templar_assassin",
    --新加英雄
    archon_passive_time			= "npc_dota_hero_arc_warden",
    archon_passive_resist_armour= "npc_dota_hero_vengefulspirit",
    archon_passive_soul			= "npc_dota_hero_nevermore",
    archon_passive_speed		= "npc_dota_hero_gyrocopter",
    archon_passive_interspace	= "npc_dota_hero_sniper",
    archon_passive_shuttle		= "npc_dota_hero_tinker",
    archon_passive_greed		= "npc_dota_hero_invoker",
}

local hSkinData = {}
hSkinData["npc_dota_hero_lina"] 			=  require("heroes/skin_fire")
hSkinData["npc_dota_hero_lone_druid"] 		=  require("heroes/skin_earth")
hSkinData["npc_dota_hero_crystal_maiden"] 	=  require("heroes/skin_ice")
hSkinData["npc_dota_hero_enchantress"] 		=  require("heroes/skin_natural")
hSkinData["npc_dota_hero_drow_ranger"] 		=  require("heroes/skin_dark")
hSkinData["npc_dota_hero_skywrath_mage"] 	=  require("heroes/skin_light")
hSkinData["npc_dota_hero_troll_warlord"] 	=  require("heroes/skin_rage")
hSkinData["npc_dota_hero_windrunner"] 		=  require("heroes/skin_puncture")
hSkinData["npc_dota_hero_rubick"] 			=  require("heroes/skin_magic")
hSkinData["npc_dota_hero_templar_assassin"] =  require("heroes/skin_bank")
-- 新加英雄
hSkinData["npc_dota_hero_arc_warden"] 		=  require("heroes/skin_time")
hSkinData["npc_dota_hero_vengefulspirit"] 	=  require("heroes/skin_resist_armour")
hSkinData["npc_dota_hero_nevermore"] 		=  require("heroes/skin_soul")
hSkinData["npc_dota_hero_gyrocopter"] 		=  require("heroes/skin_speed")
hSkinData["npc_dota_hero_sniper"] 			=  require("heroes/skin_interspace")
hSkinData["npc_dota_hero_tinker"] 			=  require("heroes/skin_shuttle")
hSkinData["npc_dota_hero_invoker"] 			=  require("heroes/skin_greed")

function HeroesSkin:GetTalentToHero(sTanlentName)
	return HeroName[sTanlentName]
end

function HeroesSkin:Init(hHero)
	if hHero:FindModifierByName("modifier_wearable_hider_while_model_changes") == nil then
		local sHeroName = hHero:GetUnitName()
		hHero:AddNewModifier(hHero, nil, "modifier_wearable_hider_while_model_changes", {}).sOriginalModel = hSkinData[sHeroName][1].model
		if hSkinData[sHeroName][1].model ~= nil then hHero:SetModel(hSkinData[sHeroName][1].model) end
		HeroesSkin:ChangeSkin(hHero,1)
	end
end

function HeroesSkin:ChangeSkin(hHero,skinId)
	local sHeroName = hHero:GetUnitName()
	local hSkin = hSkinData[sHeroName]
	WearableManager:RemoveOriginalWearables(hHero)
	WearableManager:RemoveAllWearable(hHero)
	-- DeepPrintTable(hSkin[skinId])
	if hSkin[skinId].model ~= nil then hHero:SetModel(hSkin[skinId].model) end
	if hSkin[skinId].model_scale ~= nil then hHero:SetModelScale(hSkin[skinId].model_scale) end
	hHero:FindModifierByName("modifier_wearable_hider_while_model_changes").sOriginalModel = hSkin[skinId].model
	hHero:FindModifierByName("modifier_wearable_hider_while_model_changes"):ForceRefresh()
	if hSkin ~= nil then
		for k, v in pairs(hSkin[skinId].wearables) do
			WearableManager:AddNewWearable(hHero, v)
		end
	end
	-- 变更投射物
	if hSkin[skinId].attack_projectile ~= nil then
		hHero:SetRangedProjectileName(hSkin[skinId].attack_projectile)	
	end
	-- 添加对应 modifier
	if hSkin[skinId].modifier ~= nil then
		hHero:AddNewModifier(hHero, nil, hSkin[skinId].modifier, {})
	end
end



LinkLuaModifier("modifier_heroes_skin_template", "heroes/heroes_skin", LUA_MODIFIER_MOTION_NONE)
modifier_heroes_skin_template = {}
function modifier_heroes_skin_template:IsHidden() return true end
function modifier_heroes_skin_template:RemoveOnDeath() return false end
function modifier_heroes_skin_template:GetAttributes()   
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
------------------------------  部分皮肤特效 ------------------------------

----------------------- 雷米 芙兰
LinkLuaModifier("modifier_heroes_skin_flandre", "heroes/heroes_skin", LUA_MODIFIER_MOTION_NONE)
modifier_heroes_skin_flandre = class(modifier_heroes_skin_template)
function modifier_heroes_skin_flandre:GetEffectName() return "particles/diy_particles/ambient9.vpcf" end
function modifier_heroes_skin_flandre:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

----------------------- 琪露诺
LinkLuaModifier("modifier_heroes_skin_cirno", "heroes/heroes_skin", LUA_MODIFIER_MOTION_NONE)
modifier_heroes_skin_cirno = class(modifier_heroes_skin_template)
function modifier_heroes_skin_cirno:GetEffectName() return "particles/diy_particles/cirno_ambient.vpcf" end
function modifier_heroes_skin_cirno:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end

----------------------- 诗乃
LinkLuaModifier("modifier_heroes_skin_shinai", "heroes/heroes_skin", LUA_MODIFIER_MOTION_NONE)
modifier_heroes_skin_shinai = class(modifier_heroes_skin_template)
function modifier_heroes_skin_shinai:GetEffectName() return "particles/diy_particles/shinai_ambient.vpcf" end
function modifier_heroes_skin_shinai:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end