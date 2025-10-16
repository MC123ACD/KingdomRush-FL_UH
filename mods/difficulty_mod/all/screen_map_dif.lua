local screen_map = require("screen_map")
local S = require("sound_db")
local i18n = require("i18n")
local function CJK(default, zh, ja, kr)
    return i18n:cjk(default, zh, ja, kr)
end
local IS_KR3 = KR_GAME == "kr3"

OptionsDifficultyView = class("OptionsDifficultyView", PopUpView)

function OptionsDifficultyView:initialize(sw, sh)
    PopUpView.initialize(self, V.v(sw, sh))

    self.back = KImageView:new("options_bg_notxt")
    self.back.anchor = v(self.back.size.x / 2, self.back.size.y / 2)
    self.back.pos = v(sw / 2, sh / 2 - 50)

    self:add_child(self.back)

    self.header = GGPanelHeader:new(_("OPTIONS"), 242)
    self.header.pos = v(240, CJK(41, 39, nil, 39) - (IS_KR3 and 19 or 0))

    self.back:add_child(self.header)

    self.close_button = KImageButton:new("levelSelect_closeBtn_0001", "levelSelect_closeBtn_0002",
        "levelSelect_closeBtn_0003")

    self.close_button.pos = v(sw / 2, sh / 2 + 90)

    function self.close_button.on_click()
        S:queue("GUIButtonCommon")
        self:hide()
    end

    self.back:add_child(self.close_button)
end

function OptionsDifficultyView:show()
    OptionsDifficultyView.super.show(self)
end

function OptionsDifficultyView:hide()
    OptionsDifficultyView.super.hide(self)
end
