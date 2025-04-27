local love = require("love")
local Button = require("Button")
local config = require("config")
local game = require("game")

---@class ui
ui = {}

ui.ANIMATION_NONE = 1
ui.ANIMATION_FLASHING = 2

ui.game_title_font = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 40)
ui.game_normal_font = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 20)
ui.game_small_font = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 16)
ui.game_title_text = love.graphics.newText(ui.game_title_font, "FALLING BLOCKS")
ui.game_pause_text = love.graphics.newText(ui.game_title_font, "PAUSED")
ui.game_gameover_text = love.graphics.newText(ui.game_title_font, "GAME OVER")

ui.main_menu_button_list = {
    [1] = Button("PLAY", ui.game_normal_font, function()
        game.Reset()
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

function ui.DrawSquare(x, y, s, color, opacity)
    if (opacity == nil) then
        opacity = 1
    end
    local indent = s / 5
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, s, s)

    love.graphics.setColor({ 1, 1, 1, 0.4 * opacity })
    love.graphics.polygon("fill", x, y, x + s, y, x + s - indent, y + indent,
        x + indent, y + indent)
    love.graphics.setColor({ 0, 0, 0, 0.4 * opacity })
    love.graphics.polygon("fill", x, y + s, x + s, y + s, x + s - indent,
        y + s - indent,
        x + indent,
        y + s - indent)
    love.graphics.setColor({ 0, 0, 0, 0.2 * opacity })
    love.graphics.polygon("fill", x + s, y, x + s, y + s, x + s - indent,
        y + s - indent,
        x + s - indent,
        y + indent)
    love.graphics.setColor({ 1, 1, 1, 0.2 * opacity })
    love.graphics.polygon("fill", x, y, x, y + s, x + indent,
        y + s - indent,
        x + indent,
        y + indent)
end

ui.animation = ui.ANIMATION_NONE
ui.animation_time = 0
ui.animation_repeat = 0

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
    local top_left_x = config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2
    local top_left_y = config.screen_height / 2 - config.square_grid_sidelength * (config.grid_height) / 2 +
        config.square_grid_sidelength * config.grid_blind_height

    love.graphics.setColor({ 1, 1, 1 })

    love.graphics.rectangle("line", top_left_x - config.line_width,
        top_left_y - config.line_width / 2,
        config.square_grid_sidelength * config.grid_width + config.line_width * 2,
        config.square_grid_sidelength * (config.grid_height - config.grid_blind_height) + config.line_width * 2)


    -- Grid
    for i = 1, config.grid_height, 1 do
        for j = 1, config.grid_width, 1 do
            local is_falling = ui.CheckIfFalling(i, j)

            if game.grid[i][j] ~= config.NOTHING_SQUARE then
                -- Locking effect
                local opacity = 1
                if (is_falling) then
                    opacity = math.cos(game.stop_clock * math.pi * 2) / 2 + 0.7
                end
                local square_color
                local square_x = config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 +
                    (j - 1) * config.square_grid_sidelength
                local square_y = config.screen_height / 2 - config.square_grid_sidelength * config.grid_height / 2 +
                    (i - 1) * config.square_grid_sidelength

                square_color = { config.COLOR_SQUARE[game.grid[i][j]][1], config.COLOR_SQUARE[game.grid[i][j]]
                    [2],
                    config.COLOR_SQUARE[game.grid[i][j]][3], opacity }
                ui.DrawSquare(square_x, square_y, config.square_grid_sidelength, square_color, opacity)
                if (ui.animation == ui.ANIMATION_FLASHING) and game.CheckRowClear(i) then
                    local fade = math.cos(ui.animation_time * math.pi * 2)
                    square_color = { fade, fade, fade, 1 }
                    love.graphics.setColor(square_color)
                    love.graphics.rectangle("fill", square_x, square_y, config.square_grid_sidelength,
                        config.square_grid_sidelength)
                end
            else
            end
        end
    end
    if (math.cos(ui.animation_time * math.pi * 2) < 0) then
        ui.animation = ui.ANIMATION_NONE
        ui.animation_time = 0
    end

    -- Phantom Block
    for k = 1, #game.brick_shapes[game.falling_block.brick_shape], 1 do
        if not ui.CheckIfFalling(phantom_squares[k][1], phantom_squares[k][2]) then
            love.graphics.setColor({ 1, 1, 1, 0.2 })
            love.graphics.rectangle("line",
                config.screen_width / 2 -
                (config.square_grid_sidelength) * config.grid_width / 2 +
                (phantom_squares[k][2] - 1) * config.square_grid_sidelength + config.square_grid_sidelength * 0.08,
                config.screen_height / 2 -
                (config.square_grid_sidelength) * config.grid_height / 2 +
                (phantom_squares[k][1] - 1) * config.square_grid_sidelength + config.square_grid_sidelength * 0.08,
                config.square_grid_sidelength * 0.84,
                config.square_grid_sidelength * 0.84)
        end
    end


    -- Piece Queue Panel
    local piece_queue_panel_x = config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 +
        config.square_grid_sidelength * config.grid_width + config.standard_margin
    local piece_queue_panel_y = config.screen_height / 2 - config.square_grid_sidelength * (config.grid_height) / 2 +
        config.square_grid_sidelength * config.grid_blind_height

    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.rectangle("line", piece_queue_panel_x,
        piece_queue_panel_y,
        config.square_panel_sidelength * 5,
        config.square_panel_sidelength * 4 + (config.square_panel_sidelength * 3 + config.standard_margin / 2) * 5)
    for i = 1, 6, 1 do
        local this_piece = game.NextPieceFrom(game.piece_index + i - 1)
        local offset = { 1.5, 1.5 }
        if this_piece == game.BRICK_I then
            offset = { 0, 0 }
        else
            if this_piece == game.BRICK_O then
                offset = { 1, 1.5 }
            end
        end
        for k = 1, #game.brick_shapes[this_piece][1], 1 do
            local square_x = piece_queue_panel_x +
                (game.brick_shapes[this_piece][1][k][2] + offset[1]) * config.square_panel_sidelength -
                0.5 * config.square_panel_sidelength
            local square_y = piece_queue_panel_y +
                (game.brick_shapes[this_piece][1][k][1] + offset[2]) * config.square_panel_sidelength +
                (config.square_panel_sidelength * 3 + config.standard_margin / 2) * (i - 1) -
                0.5 * config.square_panel_sidelength
            ui.DrawSquare(square_x, square_y, config.square_panel_sidelength,
                config.COLOR_SQUARE[game.brick_color[this_piece]])
        end
    end

    -- Hold Piece Panel
    love.graphics.setColor({ 1, 1, 1 })

    local hold_piece_panel_x = config.screen_width / 2 - config.square_grid_sidelength * config.grid_width / 2 -
        config.standard_margin - config.square_panel_sidelength * 6
    local hold_piece_panel_y = config.screen_height / 2 - config.square_grid_sidelength * (config.grid_height) / 2 +
        config.square_grid_sidelength * config.grid_blind_height + config.standard_margin * 3

    love.graphics.rectangle("line", hold_piece_panel_x,
        hold_piece_panel_y,
        config.square_panel_sidelength * 6,
        config.square_panel_sidelength * 5)
    local hold_piece = game.hold_block

    if (hold_piece == nil) then
        love.graphics.setColor({ 0.5, 0.5, 0.5 })

        love.graphics.print("NONE", ui.game_normal_font, hold_piece_panel_x + config.square_panel_sidelength * 3 - 40,
            hold_piece_panel_y + config.square_panel_sidelength * 2.5 - 10)
    else
        local offset = { 1.5, 1.5 }
        if hold_piece == game.BRICK_I then
            offset = { 0, 0 }
        else
            if hold_piece == game.BRICK_O then
                offset = { 1, 1.5 }
            end
        end
        for k = 1, #game.brick_shapes[hold_piece][1], 1 do
            local square_x = hold_piece_panel_x + (game.brick_shapes[hold_piece][1][k][2] + offset[1]) * config
                .square_panel_sidelength
            local square_y = hold_piece_panel_y + (game.brick_shapes[hold_piece][1][k][1] + offset[2]) * config
                .square_panel_sidelength
            ui.DrawSquare(square_x, square_y, config.square_panel_sidelength,
                config.COLOR_SQUARE[game.brick_color[hold_piece]])
            if (not game.can_hold) then
                ui.DrawSquare(square_x, square_y, config.square_panel_sidelength, { 0, 0, 0, 0.69 })
            end
        end
    end
    -- Information UI
    love.graphics.setColor({ 1, 1, 1 })
    love.graphics.print(string.format("LEVEL %s", tostring(game.level)), ui.game_normal_font, 30, 50)
    love.graphics.print(string.format("LEVEL SCORE: %s", tostring(game.score)), ui.game_normal_font, 30, 80)
    love.graphics.print(string.format("TO BEAT: %s", tostring(game.level * 5)), ui.game_normal_font, 30, 110)
    love.graphics.print("NEXT", ui.game_normal_font, piece_queue_panel_x + 15, piece_queue_panel_y - 30)
    love.graphics.print("HOLD", ui.game_normal_font, hold_piece_panel_x + 22, hold_piece_panel_y - 30)
    love.graphics.print(
        "CONTROLS\n\n---\n\nLR - MOVE\n\nUP - ROTATE\nCLOCKWISE\n\nDOWN - SLOW\nDROP\n\nSPACE - HARD\nDROP\n\nC - HOLD PIECE",
        ui.game_small_font,
        15, hold_piece_panel_y + 200)
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
