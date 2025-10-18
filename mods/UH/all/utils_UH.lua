local P = require("path_db")

local function v(v1, v2)
    return {
        x = v1,
        y = v2
    }
end
local utils_UH = {}

function utils_UH:hero_buy_template_set(t)
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

function utils_UH.set_entity_pos(store, e, pos)
    e.pos = V.vclone(pos)

    local nodes = P:nearest_nodes(pos.x, pos.y, nil,
        nil, true)

    if #nodes < 1 then
        return false
    end

    local pi, spi, ni = unpack(nodes[1])
    local npos = P:node_pos(pi, spi, ni)

    if e.nav_path then
        e.nav_path.pi = pi
        e.nav_path.spi = spi
        e.nav_path.ni = ni
    elseif e.nav_rally then
        e.nav_rally.pos = npos
    end

    if e.enemy then
        U.unblock_all(store, e)
    elseif e.soldier then
        U.unblock_target(store, e)
    end

    return true, {pi, spi, ni}, npos
end

return utils_UH