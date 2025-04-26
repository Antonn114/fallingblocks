local love = require("love")
local Button = require("Button")
local config = require("config")
local game = require("game")

---@class ui
ui = {}

ui.game_title_font = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 40)
ui.game_normal_font = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 20)
ui.game_small_font = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 16)
ui.game_title_text = love.graphics.newText(ui.game_title_font, "FALLING BLOCKS")
ui.game_pause_text = love.graphics.newText(ui.game_title_font, "PAUSED")
ui.game_gameover_text = love.graphics.newText(ui.game_title_font, "GAME OVER")

ui.main_menu_button_list = {
    [1] = Button("PLAY", ui.game_normal_font, function()
        game.game_stage = game.PLAY
    end, nil, 300, 50),
    [2] = Button("OPTIONS", ui.game_normal_font, nil, nil, 300, 50),
    [3] = Button("QUIT", ui.game_normal_font, love.event.quit, nil, 300, 50)
}

ui.pause_menu_button_list = {
    [1] = Button("CONTINUE", ui.game_normal_font, function()
        game.game_stage = game.PLAY
    end, nil, 300, 50),
    [2] = Button("OPTIONS", ui.game_normal_font, nil, nil, 300, 50),
    [3] = Button("RETURN TO MENU", ui.game_normal_font, function()
        game.game_stage = game.MAIN_MENU
        game.Reset()
    end, nil, 300, 50)
}

ui.game_over_button_list = {
    [1] = Button("RESTART", ui.game_normal_font, function()
        game.game_stage = game.PLAY
        game.Reset()
    end, nil, 300, 50),
    [2] = Button("RETURN TO MENU", ui.game_normal_font, function()
        game.game_stage = game.MAIN_MENU
        game.Reset()
    end, nil, 300, 50)
}

function ui.DrawMainMenu()
    -- Title
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.draw(ui.game_title_text,
        config.screen_width / 2, config.screen_height / 3, 0, 1, 1,
        ui.game_title_text:getWidth() / 2,
        ui.game_title_text:getHeight() / 2)

    -- Buttons
    local button_cum_height = 0
    for k, button in pairs(ui.main_menu_button_list) do
        button:draw(config.screen_width / 2 - button:getWidth() / 2,
            config.screen_height / 2 + button_cum_height - button:getHeight() / 2)
        button_cum_height = button_cum_height + button:getHeight() + config.button_margin
    end
end

function ui.DrawPauseMenu()
    -- Background
    love.graphics.setColor({ 0, 0, 0, 0.5 })
    love.graphics.rectangle("fill", 0,
        0,
        config.screen_width,
        config.screen_height)
    love.graphics.setColor({ 0, 0, 0 })
    love.graphics.rectangle("fill", config.screen_width / 2 - config.pause_menu_width / 2,
        config.screen_height / 2 - config.pause_menu_height / 2,
        config.pause_menu_width,
        config.pause_menu_height)
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.rectangle("line", config.screen_width / 2 - config.pause_menu_width / 2,
        config.screen_height / 2 - config.pause_menu_height / 2,
        config.pause_menu_width,
        config.pause_menu_height)
    -- Title
    local title_y = config.screen_height / 2 - config.pause_menu_height / 2 + config.standard_margin +
        ui.game_pause_text:getHeight() / 2
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.draw(ui.game_pause_text,
        config.screen_width / 2,
        title_y, 0, 1,
        1,
        ui.game_pause_text:getWidth() / 2,
        ui.game_pause_text:getHeight() / 2)

    -- Buttons
    local bottom_title_y = title_y + ui.game_pause_text:getFont():getHeight() / 2 + config.standard_margin
    local remaining_height = config.pause_menu_height -
        (bottom_title_y - (config.screen_height / 2 - config.pause_menu_height / 2)) -
        config.standard_margin
    for k, button in pairs(ui.pause_menu_button_list) do
        button:draw(config.screen_width / 2 - button:getWidth() / 2,
            bottom_title_y + remaining_height / (#ui.pause_menu_button_list) * (k - 1))
    end
end

function ui.CheckIfFalling(x, y)
    for k = 1, #game.brick_shapes[game.falling_block.brick_shape], 1 do
        if (game.falling_block.x + game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation][k][1] == x
                and game.falling_block.y + game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation][k][2] == y) then
            return true
        end
    end
    return false
end

function ui.DrawPlay()
    love.graphics.setColor({ 0.5, 0.5, 0.5 })
    -- Phantom block
    local reach = game.PhantomThumper()
    local phantom_squares = {}
    for i = 1, #game.brick_shapes[game.falling_block.brick_shape], 1 do
        phantom_squares[i] = { game.falling_block.x + reach +
        game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation][i][1],
            game.falling_block.y +
            game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation][i][2] }
    end
    -- Play Area
    for i = config.grid_blind_height - 1, config.grid_height, 1 do
        for j = 1, config.grid_width, 1 do
            -- Locking effect
            local opacity = 1
            local is_falling = ui.CheckIfFalling(i, j)
            if (is_falling) then
                opacity = math.cos(game.stop_clock / 1 * math.pi * 2) / 2 + 0.7
            end
            love.graphics.setColor(config.COLOR_SQUARE[game.grid[i][j]][1], config.COLOR_SQUARE[game.grid[i][j]][2],
                config.COLOR_SQUARE[game.grid[i][j]][3], opacity)

            -- Current Square Drawn
            love.graphics.rectangle("fill",
                config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 +
                (j - 1) * config.square_grid_sidelength,
                config.screen_height / 2 - config.square_grid_sidelength * config.grid_height / 2 +
                (i - 1) * config.square_grid_sidelength,
                config.square_grid_sidelength,
                config.square_grid_sidelength)

            -- Draw Phantom Block
            if (not is_falling) then
                for k = 1, #game.brick_shapes[game.falling_block.brick_shape], 1 do
                    if phantom_squares[k][1] == i and phantom_squares[k][2] == j then
                        love.graphics.setColor({ 1, 1, 1, 0.5 })
                        love.graphics.rectangle("line",
                            config.screen_width / 2 -
                            (config.square_grid_sidelength) * config.grid_width / 2 +
                            (j - 1) * config.square_grid_sidelength + config.square_grid_sidelength * 0.05,
                            config.screen_height / 2 -
                            (config.square_grid_sidelength) * config.grid_height / 2 +
                            (i - 1) * config.square_grid_sidelength + config.square_grid_sidelength * 0.05,
                            config.square_grid_sidelength * 0.9,
                            config.square_grid_sidelength * 0.9)
                    end
                end
            end

            -- Draw Lattice
            love.graphics.setColor({ 0, 0, 0, 0.3 })
            love.graphics.rectangle("line",
                config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 +
                (j - 1) * config.square_grid_sidelength,
                config.screen_height / 2 - config.square_grid_sidelength * config.grid_height / 2 +
                (i - 1) * config.square_grid_sidelength,
                config.square_grid_sidelength,
                config.square_grid_sidelength)
        end
    end

    -- Play Area Border
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.rectangle("line", config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2,
        config.screen_height / 2 - config.square_grid_sidelength * (config.grid_height) / 2 +
        config.square_grid_sidelength * config.grid_blind_height,
        config.square_grid_sidelength * config.grid_width,
        config.square_grid_sidelength * (config.grid_height - config.grid_blind_height))

    -- Piece Queue Panel
    local piece_queue_panel_x = config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 +
        config.square_grid_sidelength * config.grid_width + config.standard_margin
    local piece_queue_panel_y = config.screen_height / 2 - config.square_grid_sidelength * (config.grid_height) / 2 +
        config.square_grid_sidelength * config.grid_blind_height

    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.rectangle("line", piece_queue_panel_x,
        piece_queue_panel_y,
        config.square_grid_sidelength * 6,
        config.square_grid_sidelength * 5 + (config.square_grid_sidelength * 5 + config.standard_margin / 2) * 2)
    for i = 1, 3, 1 do
        local this_piece = game.NextPieceFrom(game.piece_index + i - 1)
        local offset = 1.5
        if this_piece == game.BRICK_I then
            offset = 0
        else
            if this_piece == game.BRICK_O then
                offset = 1
            end
        end
        for k = 1, #game.brick_shapes[this_piece][1], 1 do
            love.graphics.setColor(config.COLOR_SQUARE[game.brick_color[this_piece]])
            love.graphics.rectangle("fill",
                piece_queue_panel_x + (game.brick_shapes[this_piece][1][k][2] + offset) * config
                .square_grid_sidelength,
                piece_queue_panel_y + (game.brick_shapes[this_piece][1][k][1] + offset) * config
                .square_grid_sidelength +
                (config.square_grid_sidelength * 5 + config.standard_margin / 2) * (i - 1),
                config.square_grid_sidelength,
                config.square_grid_sidelength)
            love.graphics.setColor({ 0, 0, 0, 0.3 })
            love.graphics.rectangle("line",
                piece_queue_panel_x + (game.brick_shapes[this_piece][1][k][2] + offset) * config.square_grid_sidelength,
                piece_queue_panel_y + (game.brick_shapes[this_piece][1][k][1] + offset) * config.square_grid_sidelength +
                (config.square_grid_sidelength * 5 + config.standard_margin / 2) * (i - 1),
                config.square_grid_sidelength,
                config.square_grid_sidelength)
        end
    end

    -- Hold Piece Panel
    love.graphics.setColor({ 1, 1, 1 })

    local hold_piece_panel_x = config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 -
        config.standard_margin - config.square_grid_sidelength * 6
    local hold_piece_panel_y = config.screen_height / 2 - config.square_grid_sidelength * (config.grid_height) / 2 +
        config.square_grid_sidelength * config.grid_blind_height + config.standard_margin * 3

    love.graphics.rectangle("line", hold_piece_panel_x,
        hold_piece_panel_y,
        config.square_grid_sidelength * 6,
        config.square_grid_sidelength * 5)
    local hold_piece = game.hold_block

    if (hold_piece == nil) then
        love.graphics.setColor({ 0.5, 0.5, 0.5 })

        love.graphics.print("NONE", ui.game_normal_font, hold_piece_panel_x + config.square_grid_sidelength * 3 - 40,
            hold_piece_panel_y + config.square_grid_sidelength * 2.5 - 10)
    else
        local offset = 1.5
        if hold_piece == game.BRICK_I then
            offset = 0
        else
            if hold_piece == game.BRICK_O then
                offset = 1
            end
        end
        for k = 1, #game.brick_shapes[hold_piece][1], 1 do
            love.graphics.setColor(config.COLOR_SQUARE[game.brick_color[hold_piece]])
            love.graphics.rectangle("fill",
                hold_piece_panel_x + (game.brick_shapes[hold_piece][1][k][2] + offset) * config
                .square_grid_sidelength,
                hold_piece_panel_y + (game.brick_shapes[hold_piece][1][k][1] + offset) * config
                .square_grid_sidelength,
                config.square_grid_sidelength,
                config.square_grid_sidelength)
            love.graphics.setColor({ 0, 0, 0, 0.3 })
            love.graphics.rectangle("line",
                hold_piece_panel_x + (game.brick_shapes[hold_piece][1][k][2] + offset) * config.square_grid_sidelength,
                hold_piece_panel_y + (game.brick_shapes[hold_piece][1][k][1] + offset) * config.square_grid_sidelength,
                config.square_grid_sidelength,
                config.square_grid_sidelength)
        end
    end



    -- Information UI
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.print(string.format("LEVEL %s", tostring(game.level)), ui.game_normal_font, 30, 50)
    love.graphics.print(string.format("LEVEL SCORE: %s", tostring(game.score)), ui.game_normal_font, 30, 80)
    love.graphics.print(string.format("TO BEAT: %s", tostring(game.level * 5)), ui.game_normal_font, 30, 110)
    love.graphics.print("NEXT PIECE", ui.game_normal_font, piece_queue_panel_x, piece_queue_panel_y - 30)
    love.graphics.print("HOLD", ui.game_normal_font, hold_piece_panel_x, hold_piece_panel_y - 30)
    love.graphics.print(
        "CONTROLS\n\n---\n\nLR - MOVE\n\nUP - ROTATE\nCLOCKWISE\n\nDOWN - SLOW\nDROP\n\nSPACE - HARD\nDROP\n\nC - HOLD PIECE",
        ui.game_small_font,
        hold_piece_panel_x - 40, hold_piece_panel_y + 200)
end

function ui.DrawGameOver()
    -- Background
    love.graphics.setColor({ 0, 0, 0, 0.5 })
    love.graphics.rectangle("fill", 0,
        0,
        config.screen_width,
        config.screen_height)
    love.graphics.setColor({ 0, 0, 0 })
    love.graphics.rectangle("fill", config.screen_width / 2 - config.pause_menu_width / 2,
        config.screen_height / 2 - config.pause_menu_height / 2,
        config.pause_menu_width,
        config.pause_menu_height)
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.rectangle("line", config.screen_width / 2 - config.pause_menu_width / 2,
        config.screen_height / 2 - config.pause_menu_height / 2,
        config.pause_menu_width,
        config.pause_menu_height)
    -- Title
    local title_y = config.screen_height / 2 - config.pause_menu_height / 2 + config.standard_margin +
        ui.game_gameover_text:getHeight() / 2
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.draw(ui.game_gameover_text,
        config.screen_width / 2,
        title_y, 0, 1,
        1,
        ui.game_gameover_text:getWidth() / 2,
        ui.game_gameover_text:getHeight() / 2)
    -- Score
    local bottom_title_y = title_y + ui.game_gameover_text:getFont():getHeight() / 2 + config.standard_margin
    love.graphics.setColor({ 1, 1, 1 })
    local score_text = love.graphics.newText(ui.game_normal_font,
        string.format("TOTAL SCORE: %s", tostring(game.total_score)))
    love.graphics.draw(score_text,
        config.screen_width / 2,
        bottom_title_y + config.standard_margin, 0, 1,
        1,
        score_text:getWidth() / 2,
        score_text:getHeight() / 2)

    -- Buttons
    local bottom_score_y = bottom_title_y + score_text:getFont():getHeight() + config.standard_margin
    local remaining_height = config.pause_menu_height -
        (bottom_score_y - (config.screen_height / 2 - config.pause_menu_height / 2)) -
        config.standard_margin
    for k, button in pairs(ui.game_over_button_list) do
        button:draw(config.screen_width / 2 - button:getWidth() / 2,
            bottom_score_y + remaining_height / (#ui.game_over_button_list) * (k - 1))
    end
end

return ui
