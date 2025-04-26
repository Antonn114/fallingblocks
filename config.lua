local love = require("love")

---@class config
config = {}


config.NOTHING_SQUARE = 0
config.RED_SQUARE = 1
config.GREEN_SQUARE = 2
config.BLUE_SQUARE = 3
config.YELLOW_SQUARE = 4
config.PURPLE_SQUARE = 5
config.CYAN_SQUARE = 6
config.ORANGE_SQUARE = 7

config.COLOR_SQUARE = {
    [config.RED_SQUARE] = { 1, 0, 0 },
    [config.GREEN_SQUARE] = { 0, 1, 0 },
    [config.BLUE_SQUARE] = { 0, 0, 1 },
    [config.PURPLE_SQUARE] = { 1, 0, 1 },
    [config.YELLOW_SQUARE] = { 1, 1, 0 },
    [config.CYAN_SQUARE] = { 0, 1, 1 },
    [config.ORANGE_SQUARE] = { 1, 0.5, 0 },
    [config.NOTHING_SQUARE] = { 0, 0, 0 }
}

config.grid_blind_height = 4
config.grid_height = 24
config.grid_width = 10
config.screen_height = 800
config.screen_width = 800

config.pause_menu_width = 400
config.pause_menu_height = 400

config.standard_margin = 20
config.play_area_margin = 40
config.button_margin = 10

config.square_grid_sidelength = (config.screen_height - config.play_area_margin * 2) / config.grid_height

return config
