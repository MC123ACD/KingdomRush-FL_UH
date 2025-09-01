local log = require("klua.log"):new("UH")

local HOOK = require("hook_utils").HOOK
require("UH.utils_UH")

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
local function creat_status_1(slot, hero)
	if not slot.heroes.status_1 then
		slot.heroes.status_1 = {}
	end

	if not slot.heroes.status_1[hero.template_name] then
		slot.heroes.status_1[hero.template_name] = {
			xp = 0
		}
	end

	return slot.heroes.status_1[hero.template_name]
end
local function re_hero_level(hero, status)
	local slot = storage:load_slot(nil, true)

	map_data = require("data.map_data")
	local hero_data = map_data.hero_data

	-- 若英雄来自一代，并且关闭补强，直接用原版升级机制
	if hero_game_ver(hero.template_name) == 1 and not (slot.liuhui and slot.liuhui.balance_hero) then
		hero.hero.xp = 0
		hero.hero.level = 1

		-- 若英雄来自一代，开启补强，改为局外升级，经验读取另一个存储位置
	elseif hero_game_ver(hero.template_name) == 1 then
		local status_1 = creat_status_1(slot, hero)

		-- 若另一个存储位置的经验不为 0
		if status_1.xp ~= 0 then
			status.xp = status_1.xp
		end

		hero.hero.xp = status.xp
		hero.hero.level = 10

		-- 若英雄来自一代之外，不变
	else
		hero.hero.xp = status.xp
		hero.hero.level = 10
	end
end
local function save_xp(hero)
	local slot = storage:load_slot()

	-- 若英雄来自一代之外，直接保存
	if hero_game_ver(hero.template_name) ~= 1 then
		slot.heroes.status[hero.template_name].xp = hero.hero.xp

		-- 若英雄来自一代，并且开启英雄补强，则保存到另一个存储经验的位置
	elseif hero_game_ver(hero.template_name) == 1 and slot.liuhui and slot.liuhui.balance_hero then
		local status_1 = creat_status_1(slot, hero)

		slot.heroes.status_1[hero.template_name].xp = hero.hero.xp
		slot.heroes.status[hero.template_name].xp = hero.hero.xp
	end

	storage:save_slot(slot)
end
local function load_UH()
	scripts_UH:init()
	scripts_UH:utils()
	scripts_UH:script_utils()
	scripts_UH:scripts()
    scripts_UH:enhance1()
    scripts_UH:enhance2()
    scripts_UH:enhance3()
    scripts_UH:enhance4()
    scripts_UH:enhance5()
    upgrades_hero:enhance1()
    upgrades_hero:enhance2()
    upgrades_hero:enhance3()
    upgrades_hero:enhance4()
    upgrades_hero:enhance5()
end
-- local function load_UF()
--     if user_data.liuhui_hero and user_data.liuhui_hero.usedoublehero then
--         upgrades_FL:enhance_hero1()
--         upgrades_FL:enhance_hero2()
--         upgrades_FL:enhance_hero3()
--     end
--     if user_data.liuhui_hero and not user_data.liuhui_hero.usedoublehero then
--         upgrades_FL:enhance_hero5()
--     end
-- end
local my_hook = {
    ok = false
}

-- 元表：自动创建不存在表
auto_table_mt = {
	__index = function(table, key)
		local new = {}
		setmetatable(new, auto_table_mt)

		rawset(table, key, new)
		return new
	end
}

setmetatable(my_hook, auto_table_mt)

function my_hook:init()
    if self.ok then
        return
    end

    require("game_scripts")
    require("game_scripts-1")
    require("game_scripts-2")
    require("game_scripts-4")
    require("game_scripts-5")

    HOOK(E, "load", self.E.load)
    HOOK(E, "register_t", self.E.RT)
    HOOK(A_db, "fni", self.A.fni)
    HOOK(HeroRoomView, "initialize", self.hero_room.init)
    HOOK(HeroRoomView, "show", self.hero_room.show)
	HOOK(screen_map, "init", self.screen_map.init)
	HOOK(game_gui, "init", self.game_gui.init)
	HOOK(game_gui, "go_to_map", self.game_gui.go_to_map)
	HOOK(game_gui, "restart_game", self.game_gui.restart_game)
    HOOK(LU, "insert_hero", self.LU.insert_hero)
    HOOK(LU, "insert_double_hero", self.LU.insert_double_hero)
	HOOK(sys.level, "init", self.sys.level.init)
	HOOK(DI, "patch_templates", self.DI.patch_templates)
    -- HOOK(screen_map, "init", self.screen_map_init)
	HOOK(game, "init", self.game.init)
	HOOK(game, "mousepressed", self.game.mousepressed)
    self.ok = true
end

-- 将模板已存在时报错，改为返回已存在的模板
function my_hook.E.RT(origin, self, name, base)
	if self.entities[name] then
        return self.entities[name]
	end

	local t

	if base then
		if type(base) == "string" then
			base = self.entities[base]
		end

		if base == nil then
			log.error("template base %s does not exist", base)

			return
		end

		t = copy(base)
	else
		t = {}
	end

	if self.debug_info then
		if t.hierarchy_debug then
			t.hierarchy_debug = t.hierarchy_debug .. "|" .. name
		else
			t.hierarchy_debug = name
		end
	end

	t.template_name = name
	self.entities[name] = t

	return t
end

function my_hook.E.load(origin, self, ...)
    package.loaded["game_scripts-1"] = nil
    package.loaded["game_scripts-2"] = nil
    package.loaded["game_scripts-4"] = nil
    package.loaded["game_scripts-5"] = nil

    origin(self, ...)

	if not self.save_o then
		upgrades_hero:save_o()
		scripts_UH:save_o()
		self.save_o = true
	end

	-- 检测补强是否开启，开启则应用补强
    local user_data = storage:load_slot()
    if user_data.liuhui and user_data.liuhui.balance_hero then
        load_UH()
    end
end

-- 为单独修改动画速度增加支持
function my_hook.A.fni(origin, self, animation, time_offset, loop, fps, tick_length)
    fps = animation.fps or self.fps
    
    return origin(self, animation, time_offset, loop, fps, tick_length)
end

function my_hook.sys.level.init(origin, ...)
    origin(...)

	local user_data = storage:load_slot()

	if user_data.liuhui and user_data.liuhui.balance_hero then
		A_UH:a1()
		A_UH:a2()
		A_UH:a3()
		A_UH:a4()
		A_UH:a5()
	end

	T("hero_alleria_g3").hero.level = 3
	T("hero_alleria_g3").hero.xp = 0

end

-- function my_hook.screen_map_init(origin, ...)
--     origin(...)

-- end

-- 按钮
function my_hook.hero_room.init(origin, self, sw, sh)
    origin(self, sw, sh)

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

        E.entities = copy(upgrades_hero.old.templates)
        scripts = copy(scripts_UH.old.scripts)
        scripts5 = copy(scripts_UH.old.scripts5)
		-- U = copy(scripts_UH.old.utils)

        if screen_map.user_data.liuhui and screen_map.user_data.liuhui.balance_hero then
            load_UH()
        end
        -- load_UF()
        UPGR:patch_templates(5)
        self:construct_hero(self.selected_index)

        self.balance_hero_button.label.text = screen_map.user_data.liuhui.balance_hero and _("FLBALANCE") or _("FLSTANDARD")

        S:queue("GUIButtonCommon")
    end

    self.back:add_child(balance_hero_button)
    self.balance_hero_button = balance_hero_button

	local cheat_up = KImageView:new("heroroom_012")

	cheat_up.pos = v(75, 36 + kr3_y_offset + 50)
	cheat_up.anchor = v(cheat_up.size.x / 2, cheat_up.size.y / 2)

	function cheat_up.on_click()
		local user_data = storage:load_slot()
		local hero = get_hero_stats(self.selected_index)
		local status = user_data.heroes.status[hero.name]

		if hero_game_ver(hero.name) == 1 and hero.level < 10 then
			local function creat_status_1(slot, hero)
				if not slot.heroes.status_1 then
					slot.heroes.status_1 = {}
				end

				if not slot.heroes.status_1[hero.name] then
					slot.heroes.status_1[hero.name] = {
						xp = 0
					}
				end

				return slot.heroes.status_1[hero.name]
			end
			local status_1 = creat_status_1(user_data, hero)
			status_1.xp = GS.hero_xp_thresholds[hero.level]
		end

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
function my_hook.hero_room.show(origin, self)
    origin(self)

    self:construct_hero(self.selected_index)
end

-- 修改地图按钮
function my_hook.screen_map.init(origin, self, w, h, done_callback)
	origin(self, w, h, done_callback)

	-- 修改敌人血量倍数按钮
	self.tower_room.children[1].children[1].children[12].on_click = function()
		local impossiblerate = screen_map.user_data.liuhui.impossiblerate
		if impossiblerate and impossiblerate < 3 then
			impossiblerate = impossiblerate + 0.05
		else
			impossiblerate = 3
		end
		screen_map.user_data.liuhui.impossiblerate = impossiblerate
		GS.difficulty_enemy_hp_max_factor[4] = screen_map.user_data.liuhui.impossiblerate
		storage:save_slot(screen_map.user_data)
		self.tower_room:update_selected_tower()
		S:queue("GUIButtonCommon")
	end
end

function my_hook.DI.patch_templates(origin, self)
    origin(self)

	local hp_rate = self.user_data.liuhui.impossiblerate

	GS.hero_xp_gain_per_difficulty_mode[4] = hp_rate * 0.9
	
    local gold_factor_enemy = hp_rate * 0.125

	if hp_rate >= 2 then
		for _, t in pairs(E:filter_templates("enemy")) do
			if self.level == 4 and gold_factor_enemy and self.user_data.liuhui.g3_hprate == true and t.enemy and t.enemy.gold then
				t.enemy.gold = math.floor(t.enemy.gold * (gold_factor_enemy + 1))
			end
		end
	end
end

-- 一代英雄改局外升级
function my_hook.LU.insert_hero(origin, store, name, pos)
    if store.level.locked_hero then
		log.debug("hero locked for level. will not insert")

		return
	end

	local template_name

	if not name then
		--这里是主英雄的插入口
		template_name = store.selected_hero and store.selected_hero or GS.default_hero

		if not template_name then
			store.level.locked_hero = true

			return
		end
	else
		template_name = name
	end

	local hero = E:create_entity(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)

		return
	end

	if not pos then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end

	hero.pos = V.vclone(pos)
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center

	if not name then
		store.main_hero = hero
		local status = store.selected_hero_status
		
		if status and status.skills and status.xp then
			re_hero_level(hero, status)

			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end
	
	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)
	-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
	
	if store.main_hero and store.main_hero.hero then
		local he = store.main_hero

		log.info("main_hero: %s, h.level:%d", he.template_name, he.hero.level)

		for sn, hs in pairs(he.hero.skills) do
			log.info("\t hero skill %s level: %d", sn, hs.level)
		end
	end

	return hero
end

function my_hook.LU.insert_double_hero(origin, store, name1, name2, pos)
    if store.level.locked_hero then
		log.debug("hero locked for level. will not insert")
		return
	end

	map_data = require("data.map_data")
	local hero_data = map_data.hero_data

	if not name1 then
		log.debug("name1 error")
		print("name1 error")
		return
	end

	if not name2 then
		log.debug("name2 error")
		print("name2 error")
		return
	end
	local template_name = name1

	local hero = E:create_entity(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)
		return
	end

	if not pos then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end

	hero.pos = V.vclone(pos)
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center
		
	if name1 then		
		local slot = storage:load_slot(nil, true)
		
		local status = slot.heroes.status[hero_data[screen_map.user_data.liuhui_hero.herolist[1]].name]

		if status and status.skills and status.xp then
			re_hero_level(hero, status)

			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end

	if not (name2 == name1) then
		store.main1_hero = hero
		print("load main1 hero")
	end

	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)
	

	local template_name = name2

	local hero = E:create_entity(template_name)

	if not hero then
		log.error("Could not create hero named %s", template_name)
		return
	end

	if not pos then
		if hero.hero.use_custom_spawn_point and store.level.custom_spawn_pos then
			if store.level.custom_spawn_pos.x then
				pos = store.level.custom_spawn_pos
			else
				pos = store.level.custom_spawn_pos[1].pos
			end
		else
			pos = store.level.locations.exits[1].pos
		end
	end

	store.main_hero = hero

	hero.pos = V.vclone(pos)
	hero.nav_rally.center = V.vclone(hero.pos)
	hero.nav_rally.pos = hero.nav_rally.center

	if name2 then

		local slot = storage:load_slot(nil, true)
		local status = slot.heroes.status[hero_data[screen_map.user_data.liuhui_hero.herolist[2]].name]

		if status and status.skills and status.xp then
			re_hero_level(hero, status)

			-- print("main_hero: %s, h.level:%d", hero.template_name, hero.hero.level)
			for i, th in ipairs(GS.hero_xp_thresholds) do
				if th > hero.hero.xp then
					hero.hero.level = i
					break
				end
			end

			for k, v in pairs(status.skills) do
				if not hero.hero.skills[k] then
					log.error("hero %s status missing skill %s", hero.template_name, k)
				else
					hero.hero.skills[k].level = v
				end
			end
		else
			log.error("Active slot has no hero status or xp info for %s", template_name)
		end
	end
	
	LU.queue_insert(store, hero)
	signal.emit("hero-added", hero)
	print("add hero done")

	return hero
end

-- game_gui 初始化
function my_hook.game_gui.init(origin, self, w, h, game)
	origin(self, w, h, game)

	self.mouse_pointer.window = self.mouse_pointer:get_window()
end

-- 避免关闭补强后英雄等级清零
function my_hook.game_gui.go_to_map(origin, self)
	if self.game.store.main_hero and not GS.hero_xp_ephemeral then
		save_xp(self.game.store.main_hero)
	end

	if self.game.store.main1_hero and not GS.hero_xp_ephemeral then
		save_xp(self.game.store.main1_hero)
	end

	S:stop_all()
	S:resume()
	signal.emit("game-quit", self.game.store)
	-- collectgarbage()
	local screen_map = require("screen_map")
	game_gui.game.done_callback({
		next_item_name = screen_map.map_view
	})
	-- collectgarbage()
end

function my_hook.game_gui.restart_game(origin, self)
    local user_data = storage:load_slot()

    if self.game.store.main_hero and not GS.hero_xp_ephemeral then
        save_xp(self.game.store.main_hero)
    end

	S:stop_all()
	S:resume()
	signal.emit("game-restart", self.game.store)
	game_gui.game:restart()
end

function my_hook.game.init(origin, self, screen_w, screen_h, done_callback)
	origin(self, screen_w, screen_h, done_callback)

	self.mp = {
		pos = {},
		button = {},
		istouch = nil
	}
end

function my_hook.game.mousepressed(origin, self, x, y, button, istouch)
	for i, v in pairs(self.mp.button) do
		i = nil
	end
	self.mp.pos = {}
	self.mp.istouch = nil

	origin(self, x, y, button, istouch)

	if button == 2 then
		self.mp.button[2] = true
		self.mp.pos = v(x, y)
		self.mp.istouch = istouch
	end
end

return my_hook