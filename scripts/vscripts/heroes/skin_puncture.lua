return {
	{	-- 1 原始皮肤
		model = "models/heroes/windrunner/windrunner.vmdl",
		attack_projectile = "particles/units/heroes/hero_windrunner/windrunner_base_attack.vpcf",
		model_scale = 1,
		wearables = {
			{ID = "25", style = "0", model = "models/heroes/windrunner/windrunner_quiver.vmdl", particle_systems = {}},
			{ID = "23", style = "0", model = "models/heroes/windrunner/windrunner_shoulderpads.vmdl", particle_systems = {}},
			{ID = "24", style = "0", model = "models/heroes/windrunner/windrunner_cape.vmdl", particle_systems = {}},
			{ID = "21", style = "0", model = "models/heroes/windrunner/windrunner_head.vmdl", particle_systems = {}},
			{ID = "22", style = "0", model = "models/heroes/windrunner/windrunner_bow.vmdl", particle_systems = {}},
		},	
	},
	{	--  2
		model = "models/items/windrunner/windrunner_arcana/wr_arcana_base.vmdl",
		attack_projectile = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_base_attack.vpcf",
		model_scale = 1,
		wearables = {
			
			{ID = "12326", style = "0",model = "models/items/windrunner/windranger_ti8_immortal_shoulders/windranger_ti8_immortal_shoulders.vmdl", 
				particle_systems = {
					{   
						system = "particles/econ/items/windrunner/wr_ti8_immortal_shoulder/wr_ti8_ambients.vpcf",
						attach_type = PATTACH_ABSORIGIN_FOLLOW, 
						attach_entity = "self", 
						-- control_points = {
						--  	{
						--  		control_point_index = 0, 
						--  		attach_type = PATTACH_POINT_FOLLOW,
						--  	 	attachment = "attach_core"
						--  	}, 
						-- }
					}, 
				}
			},
			{ID = "13808", style = "0", model = "models/items/windrunner/windrunner_arcana/wr_arcana_quiver.vmdl", particle_systems = {}},
			{ID = "13804", style = "0", model = "models/items/windrunner/windrunner_arcana/wr_arcana_cape.vmdl", particle_systems = {}},
			{ID = "13806", style = "0", model = "models/items/windrunner/windrunner_arcana/wr_arcana_head.vmdl", particle_systems = {}},
			{ID = "13805", style = "0", model = "models/items/windrunner/windrunner_arcana/wr_arcana_weapon.vmdl", particle_systems = {}},


		},
	},
	{	-- 3 
		model = "models/npc/reisen/reisen.vmdl",
		attack_projectile = "particles/diy_particles/reisen_attack.vpcf",
		model_scale = 1.25,
		wearables = {
			
		},	
	},


}