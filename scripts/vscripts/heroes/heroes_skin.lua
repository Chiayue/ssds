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
		local OriginalModel = hHero:GetModelName() 
		if OriginalModel == "models/items/windrunner/windrunner_arcana/wr_arcana_base.vmdl" then
			hHero:SetModel("models/heroes/windrunner/windrunner.vmdl")
			OriginalModel = "models/heroes/windrunner/windrunner.vmdl"
		end
		--print("OriginalModel")
		-- print(OriginalModel)
		hHero:AddNewModifier(hHero, nil, "modifier_wearable_hider_while_model_changes", {}).sOriginalModel = OriginalModel
		HeroesSkin:ChangeSkin(hHero,1)
	end
end

function HeroesSkin:ChangeSkin(hHero,skinId)
	local sHeroName = hHero:GetUnitName()
	local hSkin = hSkinData[sHeroName]
	--if hSkin == nil then return end
	WearableManager:RemoveOriginalWearables(hHero)
	WearableManager:RemoveAllWearable(hHero)
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
end