local log = require("klua.log"):new("animations_UH")
local mod_utils = require("mod_utils")

local animations_UH = {}

function animations_UH.a1()
	mod_utils:a_db_reset({
		-- 波林
		hero_bolin_mine = {
			prefix = "hero_artillery",
			to = 188,
			from = 173,
			fps = 35
		},

		-- 电击手
		hero_voltaire_toss = {
			prefix = "hero_voltaire",
			frames = {
				87,
				73,
				88,
				89,
				90,
				91,
				92,
				93,
				94,
				89,
				90,
				91,
				92,
				93,
				94,
				89,
				90,
				91,
				92,
				93,
				94,
				95,
				96,
				97,
				98,
				99,
				100,
				101,
				102,
				103,
				104,
				105,
				106,
				107,
				108,
				109,
				110,
				111,
				112,
				1
			},
			fps = 40
		},
	})
end

function animations_UH.a2()
	mod_utils:a_db_reset({
		-- 大法师
		hero_wizard_shoot = {
			prefix = "hero_mage",
			to = 51,
			from = 18,
			fps = 40
		},
		hero_wizard_teleport_out = {
			prefix = "hero_mage",
			to = 83,
			from = 52,
			fps = 40
		},
		hero_wizard_teleport_in = {
			prefix = "hero_mage",
			to = 124,
			from = 86,
			fps = 40
		},
		hero_wizard_missile_start = {
			prefix = "hero_mage",
			to = 153,
			from = 140,
			fps = 40
		},
		hero_wizard_disintegrate = {
			prefix = "hero_mage",
			to = 202,
			from = 162,
			fps = 50
		},
		hero_wizard_twister = {
			prefix = "hero_mage",
			to = 202,
			from = 162
		},

		-- 螃蟹
		hero_crab_burrow_in = {
			prefix = "hero_crabman",
			to = 135,
			from = 119,
			fps = 35
		},
		hero_crab_burrow_out = {
			prefix = "hero_crabman",
			to = 157,
			from = 136,
			fps = 35
		},
		hero_crab_pincer = {
			prefix = "hero_crabman",
			to = 68,
			from = 42,
			fps = 35
		},
		hero_crab_cannon_start = {
			prefix = "hero_crabman",
			to = 88,
			from = 69,
			fps = 20
		},
		hero_crab_cannon_loop = {
			prefix = "hero_crabman",
			to = 110,
			from = 88,
			fps = 40
		},
		hero_crab_cannon_end = {
			prefix = "hero_crabman",
			to = 118,
			from = 110,
			fps = 15
		},

		-- 库绍
		hero_monk_dragon = {
			prefix = "hero_kungFu",
			to = 325,
			from = 264,
			fps = 40
		},
		hero_monk_crane = {
			prefix = "hero_kungFu",
			to = 152,
			from = 119,
			fps = 40
		},
		hero_monk_leopard_start = {
			prefix = "hero_kungFu",
			to = 177,
			from = 165,
			fps = 40
		},
		hero_monk_leopard_hit1 = {
			prefix = "hero_kungFu",
			to = 184,
			from = 178,
			fps = 40
		},
		hero_monk_leopard_hit2 = {
			prefix = "hero_kungFu",
			to = 192,
			from = 185,
			fps = 40
		},
		hero_monk_leopard_hit3 = {
			prefix = "hero_kungFu",
			to = 200,
			from = 193,
			fps = 40
		},
		hero_monk_leopard_hit4 = {
			prefix = "hero_kungFu",
			to = 209,
			from = 201,
			fps = 40
		},
		hero_monk_leopard_end = {
			prefix = "hero_kungFu",
			to = 222,
			from = 214,
			fps = 40
		},
	})
end

function animations_UH.a3()
	mod_utils:a_db_reset({
		-- 艾莉丹
		hero_elves_archer_walk = {
			prefix = "archer_hero",
			to = 23,
			from = 19,
			fps = 26
		},
		hero_elves_archer_shoot = {
			prefix = "archer_hero",
			ranges = {
				{
					54,
					63
				},
				{
					74,
					79
				}
			},
			fps = 34
		},
		hero_elves_archer_nimble_fencer = {
			prefix = "archer_hero",
			to = 138,
			from = 123,
			fps = 40
		},

		-- 大瑞格
		hero_rag_layerX_shoot = {
			layer_to = 2,
			from = 53,
			layer_prefix = "razzAndRaggs_hero_layer%i",
			to = 73,
			layer_from = 1,
			fps = 35
		},
		hero_rag_layerX_throw_bolso = {
			layer_to = 2,
			from = 210,
			layer_prefix = "razzAndRaggs_hero_layer%i",
			to = 239,
			layer_from = 1,
			fps = 35
		},
		hero_rag_layerX_throw_anchor = {
			layer_to = 2,
			from = 240,
			layer_prefix = "razzAndRaggs_hero_layer%i",
			to = 269,
			layer_from = 1,
			fps = 35
		},
		hero_rag_layerX_throw_fungus = {
			layer_to = 2,
			from = 270,
			layer_prefix = "razzAndRaggs_hero_layer%i",
			to = 299,
			layer_from = 1,
			fps = 35
		},
		hero_rag_layerX_throw_pan = {
			layer_to = 2,
			from = 300,
			layer_prefix = "razzAndRaggs_hero_layer%i",
			to = 329,
			layer_from = 1,
			fps = 35
		},
		hero_rag_layerX_throw_chair = {
			layer_to = 2,
			from = 330,
			layer_prefix = "razzAndRaggs_hero_layer%i",
			to = 361,
			layer_from = 1,
			fps = 35
		},

		-- 莉恩
		hero_lynn_hexfury = {
			prefix = "lynn_hero",
			to = 35,
			from = 7,
			fps = 40
		},
		hero_lynn_teleport_out = {
			prefix = "lynn_hero",
			to = 187,
			from = 145,
			fps = 45
		},
		hero_lynn_curseOfDespair = {
			prefix = "lynn_hero",
			to = 192,
			from = 145,
			fps = 40
		},
		hero_lynn_weakeningCurse = {
			prefix = "lynn_hero",
			to = 240,
			from = 193,
			fps = 40
		},

		-- 堕天使
		hero_lilith_throw = {
		prefix = "fallen_angel_hero",
		to = 267,
		from = 235,
		fps = 40
		},
	})
end

function animations_UH.a4()
	
end

function animations_UH.a5()
	mod_utils:a_db_reset({
		-- 维斯珀
		hero_vesper_vesper_melee_attack_1 = {
			prefix = "hero_vesper_vesper",
			to = 64,
			from = 37,
			fps = 35
		},
		hero_vesper_vesper_melee_attack_2 = {
			prefix = "hero_vesper_vesper",
			to = 90,
			from = 65,
			fps = 35
		},
		hero_vesper_vesper_ranged_attack = {
			prefix = "hero_vesper_vesper",
			to = 110,
			from = 91,
			fps = 37
		},
		hero_vesper_vesper_ranged_attack_2 = {
			prefix = "hero_vesper_vesper",
			to = 110,
			from = 91,
			fps = 15
		},
		hero_vesper_vesper_arrow_to_the_knee = {
			prefix = "hero_vesper_vesper",
			to = 140,
			from = 111,
			fps = 36
		},
		hero_vesper_vesper_ricochet = {
			prefix = "hero_vesper_vesper",
			to = 169,
			from = 141,
			fps = 40
		},
		hero_vesper_vesper_martial_flourish = {
			prefix = "hero_vesper_vesper",
			to = 209,
			from = 170,
			fps = 37
		},
		hero_vesper_vesper_disengage = {
			prefix = "hero_vesper_vesper",
			to = 257,
			from = 210,
			fts = 40
		},

		-- 狮鹫
		gryph_character_stun = {
			prefix = "gryph_character",
			to = 148,
			from = 107,
			fps = 45
		},

		-- 蛛后
		hero_spider_05_hero_teleport_in = {
			prefix = "hero_spider_07_hero",
			to = 185,
			from = 163,
			fps = 35
		},
		hero_spider_05_hero_teleport_out = {
			prefix = "hero_spider_07_hero",
			to = 218,
			from = 186,
			fps = 50
		},
		hero_spider_05_hero_ability1 = {
			prefix = "hero_spider_07_hero",
			to = 162,
			from = 97,
			fps = 38
		},
	})
end

return animations_UH