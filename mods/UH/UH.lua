local log = require("klua.log"):new("UH")

local mod_utils = require("mod_utils")
local hook_utils = require("hook_utils")
local HOOK = hook_utils.HOOK
require("utils_UH")
local scripts = require("scripts")
local scripts5 = require("scripts_5")
local sys = require("systems")
local A = require("data.game_animations")
local A_db = require("animation_db")
local A_UH = require("animations_UH")
local template_UH = require("template_UH")
local scripts_UH = require("scripts_UH")
--local strings_UH = require("strings_UH")
local screen_map = require("screen_map")
local LU = require("level_utils")
local GS = require("game_settings")
local GU5 = require("gui_utils_5")
local DI = require("difficulty")
local game = require("game")
local game_gui = require("game_gui")
local i18n = require("i18n")
local S = require("sound_db")
local map_data = require("data.map_data")

balance = require("balance.balance")
local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end
local function CJK(default, zh, ja, kr)
	return i18n:cjk(default, zh, ja, kr)
end

local function load_UH()
	scripts_UH:init()
	scripts_UH:utils()
	scripts_UH:script_utils()
	scripts_UH:scripts()

	for i = 1, 5 do
		scripts_UH["enhance" .. i](self)
		template_UH["enhance" .. i](self)
	end
end

local hook = {}

setmetatable(hook, mod_utils.auto_table_mt)

function hook:init()
	require("game_scripts")
	require("game_scripts-1")
	require("game_scripts-2")
	require("game_scripts-4")
	require("game_scripts-5")

	--strings_UH:init()

	HOOK(E, "load", self.E.load)
	HOOK(E, "register_t", self.E.RT)
	HOOK(HeroRoomView, "initialize", self.hero_room.init)
	HOOK(HeroRoomView, "show", self.hero_room.show)
	HOOK(game_gui, "init", self.game_gui.init)
	HOOK(sys.level, "init", self.sys.level.init)
	HOOK(game, "mousepressed", self.game.mousepressed)
end

-- 将模板已存在时报错，改为返回已存在的模板
function hook.E.RT(register_t, self, name, base)
	if self.entities[name] then
		return self.entities[name]
	end

	return register_t(self, name, base)
end

function hook.E.load(load, self)
	package.loaded["game_scripts-1"] = nil
	package.loaded["game_scripts-2"] = nil
	package.loaded["game_scripts-4"] = nil
	package.loaded["game_scripts-5"] = nil

	load(self)

	if not self.save_o then
		template_UH:save_o()
		scripts_UH:save_o()
		self.save_o = true
	end

	-- 检测补强是否开启，开启则应用补强
	local user_data = storage:load_slot()
	if user_data.liuhui and user_data.liuhui.balance_hero then
		load_UH()
	end
end

function hook.sys.level.init(init, ...)
	init(...)

	local user_data = storage:load_slot()

	if user_data.liuhui and user_data.liuhui.balance_hero then
		A_UH:a1()
		A_UH:a2()
		A_UH:a3()
		A_UH:a4()
		A_UH:a5()
	end
end

-- 按钮
function hook.hero_room.init(init, self, sw, sh)
	init(self, sw, sh)

	if screen_map.user_data.liuhui == nil then
		screen_map.user_data.liuhui = {}
		screen_map.user_data.liuhui.balance_hero = false
		-- screen_map.user_data.liuhui.balance_hero_level = false
	end

	local kr3_y_offset = IS_KR3 and 4 or 0
	-- 是否开启补强按钮
	local balance_hero_button = GGButton:new("heroroom_btnDone_large_0001", "heroroom_btnDone_large_0002")
	local done_button = self.done_button

	balance_hero_button.anchor = v(math.floor(done_button.size.x / 2), done_button.size.y / 2)
	balance_hero_button.pos = v(self.back.size.x - 770 - done_button.size.x - 20, self.back.size.y - 32)
	balance_hero_button.label.size = v(100, 34)
	balance_hero_button.label.text_size = done_button.label.size
	balance_hero_button.label.pos = v(20, 19)
	balance_hero_button.label.font_size = 24
	balance_hero_button.label.vertical_align = CJK("middle-caps", "middle", "middle", "middle")
	balance_hero_button.label.text = screen_map.user_data.liuhui.balance_hero and _("FLBALANCE") or _("FLSTANDARD")
	balance_hero_button.label.fit_lines = 1
	function balance_hero_button.on_click()
		screen_map.user_data.liuhui.balance_hero = not screen_map.user_data.liuhui.balance_hero
		storage:save_slot(screen_map.user_data)

		E.entities = copy(template_UH.old.templates)
		scripts = copy(scripts_UH.old.scripts)
		scripts5 = copy(scripts_UH.old.scripts5)
		-- U = copy(scripts_UH.old.utils)

		if screen_map.user_data.liuhui and screen_map.user_data.liuhui.balance_hero then
			load_UH()
		end
		-- load_UF()
		UPGR:patch_templates(5)
		self:construct_hero(self.selected_index)

		self.balance_hero_button.label.text = screen_map.user_data.liuhui.balance_hero and _("FLBALANCE") or
		_("FLSTANDARD")

		S:queue("GUIButtonCommon")
	end

	self.back:add_child(balance_hero_button)
	self.balance_hero_button = balance_hero_button

	local cheat_up = KImageView:new("heroroom_012")

	cheat_up.pos = v(75, 36 + kr3_y_offset + 50)
	cheat_up.anchor = v(cheat_up.size.x / 2, cheat_up.size.y / 2)

	local function get_hero_stats(p)
		local out = {}
		local index, hero_name

		if type(p) == "number" then
			index = p
		else
			index = get_hero_index(p)
		end

		local data = screen_map.hero_data[index]

		hero_name = data.name

		local user_data = storage:load_slot()

		local status = user_data.heroes.status[hero_name]

		if not status then
			log.debug("hero status for %s not found in slot. overwritting from template", hero_name)

			local template = require("data.slot_template")

			user_data.heroes.status[hero_name] = template.heroes.status[hero_name]
			status = template.heroes.status[hero_name]
		end

		local h = E:create_entity(hero_name)

		h.hero.xp = status.xp

		local level, level_progress = U.get_hero_level(h.hero.xp, GS.hero_xp_thresholds)

		h.hero.level = level
		if h.hero.level < data.starting_level then
			h.hero.level = data.starting_level
			h.hero.xp = GS.hero_xp_thresholds[h.hero.level]
		end

		out.skill_names = {}
		out.skill_names_i18n = {}

		local used_points = 0

		for k, v in pairs(status.skills) do
			h.hero.skills[k].level = v

			local i = h.hero.skills[k].hr_order

			out.skill_names[i] = k
			out.skill_names_i18n[i] = h.hero.skills[k].key

			for j = 1, v do
				used_points = used_points + h.hero.skills[k].hr_cost[j]
			end
		end

		h.hero.fn_level_up(h, {}, true)

		local info = h.info.fn(h)

		out.index = index
		out.name = hero_name
		out.name_i18n = h.info.i18n_key or hero_name
		out.icon = data.icon
		out.thumb = data.thumb
		out.portrait = data.portrait
		out.level = h.hero.level
		out.xp = h.hero.xp
		out.level_progress = level_progress
		out.taunt = h.sound_events.change_rally_point .. "Select"
		out.hero_class = _(string.upper(out.name_i18n) .. "_CLASS")
		out.health = info.hp_max
		out.damage = info.damage_min .. " - " .. info.damage_max
		out.armor = GU5.armor_value_desc(info.armor)
		out.attack_rate = _(string.upper(out.name_i18n) .. "_ATTACKRATE")
		out.damage_icon = h.info.damage_icon or 1
		out.skills = h.hero.skills
		out.remaining_points = GS.skill_points_for_hero_level[h.hero.level] - used_points

		return out, h
	end

	function cheat_up.on_click()
		local user_data = storage:load_slot()
		local hero = get_hero_stats(self.selected_index)
		local status = user_data.heroes.status[hero.name]

		if hero.level < 10 then
			status.xp = GS.hero_xp_thresholds[hero.level]
		end

		storage:save_slot(user_data)
		self:construct_hero(self.selected_index)
	end

	self.back:add_child(cheat_up)
	self.cheat_up = cheat_up
end

-- 每次显示英雄殿堂刷新英雄属性
function hook.hero_room.show(show, self)
	show(self)

	self:construct_hero(self.selected_index)
end

-- game_gui 初始化
function hook.game_gui.init(init, self, w, h, game)
	init(self, w, h, game)

	self.mouse_pointer.window = self.mouse_pointer:get_window()
end

function hook.game.mousepressed(mousepressed, self, x, y, button, istouch)
	if not self.mp then
		self.mp = {
			pos = {},
			button = {},
			istouch = nil
		}
	end

	for i, v in pairs(self.mp.button) do
		i = nil
	end
	self.mp.pos = {}
	self.mp.istouch = nil

	mousepressed(self, x, y, button, istouch)

	if button == 2 then
		self.mp.button[2] = true
		self.mp.pos = v(x, y)
		self.mp.istouch = istouch
	end
end

return hook
