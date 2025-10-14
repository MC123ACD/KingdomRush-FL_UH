require("gg_views")
SU5 = require("script_utils_5")
U5 = require("utils_5")
GU5 = require("gui_utils_5")
map_data = require("data.map_data")
hero_game_ver = map_data.hero_game_ver
scripts_UH = require("scripts_UH")
upgrades_hero = require("upgrades_hero")
A_UH = require("animations_UH")

function hero_buy_template_set(t)
    if type(t) == "string" then
        local nt = string.gsub(t, "_2$", "")

        E.entities[t] = copy(T(nt))

        local hero = T(t).hero

        T(t).hero_insert = false
        hero.level = 10

        for _, v in pairs(hero.skills) do
            if v.xp_level_steps then
                v.xp_level_steps = {
                    [8] = 1,
                    [9] = 2,
                    [10] = 3
                }
            end
            if v.level then
                v.level = 3
            end
        end
    end
end
