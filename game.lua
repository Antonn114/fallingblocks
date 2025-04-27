local config = require("config")
local sound = require("sound")

---@class game
game = {}

game.MAIN_MENU = 1
game.PLAY = 2
game.PAUSE = 3
game.GAME_OVER = 4

game.PHASE_NOTHING = 1
game.PHASE_DROP = 2
game.PHASE_SWITCH_HOLD = 3

game.BRICK_I = 1
game.BRICK_Z = 2
game.BRICK_S = 3
game.BRICK_T = 4
game.BRICK_L = 5
game.BRICK_J = 6
game.BRICK_O = 7

game.brick_shapes = {
    [game.BRICK_I] = {
        [1] = { { 2, 1 }, { 2, 2 }, { 2, 3 }, { 2, 4 } },
        [2] = { { 1, 2 }, { 2, 2 }, { 3, 2 }, { 4, 2 } },
        [3] = { { 2, 0 }, { 2, 1 }, { 2, 2 }, { 2, 3 } },
        [4] = { { 0, 2 }, { 1, 2 }, { 2, 2 }, { 3, 2 } },
    }
    ,
    [game.BRICK_Z] = {
        [1] = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 1, 2 } },
        [2] = { { 0, 2 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
        [3] = { { 1, 0 }, { 1, 1 }, { 2, 1 }, { 2, 2 } },
        [4] = { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 0 } },
    },
    [game.BRICK_S] = {
        [1] = { { 0, 1 }, { 0, 2 }, { 1, 0 }, { 1, 1 } },
        [2] = { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 2 } },
        [3] = { { 1, 1 }, { 1, 2 }, { 2, 0 }, { 2, 1 } },
        [4] = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 2, 1 } }
    },
    [game.BRICK_T] = {
        [1] = { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 1, 2 } }, -- up
        [2] = { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 1 } }, -- right
        [3] = { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 1 } }, -- down
        [4] = { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 1 } }, -- left
    },
    [game.BRICK_L] = {
        [1] = { { 0, 2 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
        [2] = { { 0, 1 }, { 1, 1 }, { 2, 1 }, { 2, 2 } },
        [3] = { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 0 } },
        [4] = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } },
    },
    [game.BRICK_J] = {
        [1] = { { 0, 0 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
        [2] = { { 0, 1 }, { 0, 2 }, { 1, 1 }, { 2, 1 } },
        [3] = { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 2 } },
        [4] = { { 0, 1 }, { 1, 1 }, { 2, 0 }, { 2, 1 } },
    },
    [game.BRICK_O] = {
        [1] = { { 0, 1 }, { 0, 2 }, { 1, 1 }, { 1, 2 } },
        [2] = { { 1, 1 }, { 1, 2 }, { 2, 1 }, { 2, 2 } },
        [3] = { { 1, 0 }, { 1, 1 }, { 2, 0 }, { 2, 1 } },
        [4] = { { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } },
    }
}

game.brick_width = {
    [game.BRICK_I] = 5,
    [game.BRICK_Z] = 3,
    [game.BRICK_S] = 3,
    [game.BRICK_T] = 3,
    [game.BRICK_L] = 3,
    [game.BRICK_J] = 3,
    [game.BRICK_O] = 3,
}

game.brick_color = {
    [game.BRICK_I] = config.CYAN_SQUARE,
    [game.BRICK_J] = config.BLUE_SQUARE,
    [game.BRICK_L] = config.ORANGE_SQUARE,
    [game.BRICK_O] = config.YELLOW_SQUARE,
    [game.BRICK_S] = config.GREEN_SQUARE,
    [game.BRICK_T] = config.PURPLE_SQUARE,
    [game.BRICK_Z] = config.RED_SQUARE
}

game.offset_JLSTZ = {
    [1] = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
    [2] = { { 0, 0 }, { 0, 1 }, { 1, 1 }, { -2, 0 }, { -2, 1 } },
    [3] = { { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 }, { 0, 0 } },
    [4] = { { 0, 0 }, { 0, -1 }, { 1, -1 }, { -2, 0 }, { -2, -1 } },
}
game.offset_I = {
    [1] = { { 0, 0 }, { 0, -1 }, { 0, 2 }, { 0, -1 }, { 0, 2 } },
    [2] = { { 0, -1 }, { 0, 0 }, { 0, 0 }, { -1, 0 }, { 2, 0 } },
    [3] = { { -1, -1 }, { -1, 1 }, { -1, -2 }, { 0, 1 }, { 0, -2 } },
    [4] = { { -1, 0 }, { -1, 0 }, { -1, 0 }, { 1, 0 }, { -2, 0 } },
}
game.offset_O = {
    [1] = { { 0, 0 } },
    [2] = { { 1, 0 } },
    [3] = { { 1, -1 } },
    [4] = { { 0, -1 } },
}

game.grid = {}
game.level = 1
game.score = 0
game.total_score = 0
game.last_cleared = 0

game.game_stage = game.MAIN_MENU
game.phase = game.PHASE_NOTHING
game.stop_clock = 0
game.last_update = 0
game.lock_move_rotate_count = 0
game.lock_move_rotate_limit = 15

game.hold_block = nil
game.can_hold = false

game.hold_interval = 0
game.hold_delay = 0

game.piece_queue = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
game.piece_index = 1
game.is_locking = false

game.falling_block = {
    x = 1,
    y = 1,
    brick_shape = 1,
    color = config.NOTHING_SQUARE,
    orientation = 1
}

function game.GenerateRandom(idx)
    local counter = {
        [game.BRICK_I] = 0,
        [game.BRICK_Z] = 0,
        [game.BRICK_S] = 0,
        [game.BRICK_T] = 0,
        [game.BRICK_L] = 0,
        [game.BRICK_J] = 0,
        [game.BRICK_O] = 0
    }
    for i = 1, 7, 1 do
        while idx > #game.piece_queue do
            idx = idx - #game.piece_queue
        end
        local choose = math.random(1, 7)
        while counter[choose] > 0 do
            choose = math.random(1, 7)
        end
        counter[choose] = counter[choose] + 1
        game.piece_queue[idx] = choose
        idx = idx + 1
    end
end

function game.NextPieceFrom(index)
    local new_index = index + 1
    while new_index > #game.piece_queue do
        new_index = new_index - #game.piece_queue
    end
    if game.piece_queue[new_index] == 0 then
        game.GenerateRandom(new_index)
    end
    return game.piece_queue[new_index]
end

function game.SoftReset()
    game.can_hold = true
    game.phase = game.PHASE_NOTHING
    game.stop_clock = 0
    game.is_locking = false
    game.lock_move_rotate_count = 0
    ui.animation_time = 0
    ui.animation_repeat = 0
    for i = 1, config.grid_height, 1 do
        if game.CheckRowClear(i) then
            ui.animation = ui.ANIMATION_FLASHING
        end
    end
end

function game.Reset()
    math.randomseed(os.time())
    for i = 1, config.grid_height, 1 do
        game.grid[i] = {}
        for j = 1, config.grid_width, 1 do
            game.grid[i][j] = config.NOTHING_SQUARE
        end
    end
    game.SoftReset()
    game.level = 1
    game.hold_block = nil
    game.piece_index = 0
    game.falling_block = {
        x = 1,
        y = 1,
        brick_shape = 1,
        color = config.NOTHING_SQUARE,
        orientation = 1
    }
    ui.animation = ui.ANIMATION_NONE
    game.GenerateRandom(1)
    game.phase = game.PHASE_NOTHING
end

function game.TimePerRow()
    return math.pow(0.8 - (game.level - 1) * 0.007, game.level - 1)
end

function game.MoveAllAboveDownToRow(row)
    for i = row, 2, -1 do
        for j = 1, config.grid_width, 1 do
            game.grid[i][j] = game.grid[i - 1][j]
        end
    end
end

function game.CheckRowClear(row)
    local is_clear = true
    for j = 1, config.grid_width, 1 do
        if game.grid[row][j] == config.NOTHING_SQUARE then
            is_clear = false
        end
    end
    return is_clear
end

function game.ClearRow(row)
    local cleared = 0
    if game.CheckRowClear(row) then
        for j = 1, config.grid_width, 1 do
            game.grid[row][j] = 0
        end
        game.MoveAllAboveDownToRow(row)
        cleared = cleared + game.ClearRow(row) + 1
    end
    return cleared
end

function game.CheckTSpin()
end

function game.CheckRowClears()
    local cleared = 0
    for i = config.grid_height, 1, -1 do
        cleared = cleared + game.ClearRow(i)
    end
    if cleared >= 4 and game.last_cleared >= 4 then
        game.score = game.score + 12
    else
        if cleared >= 4 then
            game.score = game.score + 8
        end
    end

    if cleared == 3 then
        game.score = game.score + 5
    end
    if cleared == 2 then
        game.score = game.score + 3
    end
    if cleared == 1 then
        game.score = game.score + 1
    end
    game.last_cleared = cleared
end

function game.CheckWinLevel()
    return game.score >= game.level * 5
end

function game.CreateBrick(brick_index, x, y, brick_color, brick_orientation)
    for k, square in pairs(game.brick_shapes[brick_index][brick_orientation]) do
        game.grid[x + square[1]][y + square[2]] = brick_color
    end
end

function game.OutsideGrid(x, y)
    return x > config.grid_height or x < config.grid_blind_height - 1 or y > config.grid_width or y < 1
end

function game.RedrawFalling(changing_function)
    game.CreateBrick(game.falling_block.brick_shape, game.falling_block.x, game.falling_block.y, config.NOTHING_SQUARE,
        game.falling_block.orientation)
    changing_function()
    game.CreateBrick(game.falling_block.brick_shape, game.falling_block.x, game.falling_block.y, game.falling_block
        .color,
        game.falling_block.orientation)
end

function game.CheckCollisionHere()
    local has_collision = false
    for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
        if (game.grid[game.falling_block.x + square[1]][game.falling_block.y + square[2]] ~= config.NOTHING_SQUARE) then
            has_collision = true
        end
    end
    return has_collision
end

function game.CheckCollisionOutside()
    local has_collision = false
    for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
        if (game.OutsideGrid(game.falling_block.x + square[1], game.falling_block.y + square[2])) then
            has_collision = true
        end
    end
    return has_collision
end

function game.CheckCollisionBottom()
    local has_collision = false
    for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
        if (game.falling_block.x + square[1] + 1 > config.grid_height) then
            has_collision = true
        else
            if (game.grid[game.falling_block.x + square[1] + 1][game.falling_block.y + square[2]] ~= config.NOTHING_SQUARE) then
                has_collision = true
            end
        end
    end
    return has_collision
end

function game.PhantomThumper()
    local reach = 0
    game.RedrawFalling(
        function()
            local has_collision = false
            while not has_collision do
                reach = reach + 1
                for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
                    if (game.falling_block.x + square[1] + reach > config.grid_height) then
                        has_collision = true
                    else
                        if (game.grid[game.falling_block.x + square[1] + reach][game.falling_block.y + square[2]] ~= config.NOTHING_SQUARE) then
                            has_collision = true
                        end
                    end
                end
            end
        end
    )
    return reach - 1
end

function game.CheckCollisionLeft()
    local has_collision = false
    for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
        if (game.falling_block.y + square[2] - 1 < 1) then
            has_collision = true
        else
            if (game.grid[game.falling_block.x + square[1]][game.falling_block.y + square[2] - 1] ~= config.NOTHING_SQUARE) then
                has_collision = true
            end
        end
    end
    return has_collision
end

function game.CheckCollisionRight()
    local has_collision = false
    for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
        if (game.falling_block.y + square[2] + 1 > config.grid_width) then
            has_collision = true
        else
            if (game.grid[game.falling_block.x + square[1]][game.falling_block.y + square[2] + 1] ~= config.NOTHING_SQUARE) then
                has_collision = true
            end
        end
    end
    return has_collision
end

function game.FindGoodWallKick(old_rot, new_rot)
    local my_wall_kick_test
    if game.falling_block.brick_shape == game.BRICK_I then
        my_wall_kick_test = game.offset_I
    else
        if game.falling_block.brick_shape == game.BRICK_O then
            my_wall_kick_test = game.offset_O
        else
            my_wall_kick_test = game.offset_JLSTZ
        end
    end
    for kk, new_offset in pairs(my_wall_kick_test[new_rot]) do
        local wall_kick_test = { my_wall_kick_test[old_rot][kk][1] - new_offset[1], my_wall_kick_test[old_rot][kk][2] -
        new_offset[2] }
        local has_collision = false
        for k, square in pairs(game.brick_shapes[game.falling_block.brick_shape][game.falling_block.orientation]) do
            if (game.OutsideGrid(game.falling_block.x + square[1] + wall_kick_test[1], game.falling_block.y + square[2] + wall_kick_test[2])) then
                has_collision = true
            else
                if (game.grid[game.falling_block.x + square[1] + wall_kick_test[1]][game.falling_block.y + square[2] + wall_kick_test[2]] ~= config.NOTHING_SQUARE) then
                    has_collision = true
                end
            end
        end
        if not has_collision then
            return wall_kick_test
        end
    end

    return nil
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" and game.game_stage == game.PLAY then
        game.game_stage = game.PAUSE
    end

    if key == "space" and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP then
        game.RedrawFalling(function()
            while (not game.CheckCollisionBottom()) do
                game.falling_block.x = game.falling_block.x + 1
            end
            love.audio.play(sound.fall)
        end)

        game.SoftReset()
    end
    if key == "c" and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP and game.can_hold then
        local old_brick = game.falling_block.brick_shape
        if game.hold_block == nil then
            game.piece_queue[game.piece_index] = 0
            game.hold_block = game.falling_block.brick_shape
        else
            game.piece_queue[game.piece_index] = game.hold_block
            game.piece_index = game.piece_index - 1
            game.hold_block = game.falling_block.brick_shape
        end
        game.SoftReset()
        game.can_hold = false
        love.audio.play(sound.hold)
        game.CreateBrick(old_brick, game.falling_block.x, game.falling_block.y, config.NOTHING_SQUARE,
            game.falling_block.orientation)
    end
    if key == "left" and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP then
        game.hold_delay = 0
        game.hold_interval = 0
        game.RedrawFalling(function()
            if (not game.CheckCollisionLeft()) then
                game.falling_block.y = game.falling_block.y - 1
                game.stop_clock = 0
                sound.PlayMove()
                if (game.is_locking) then
                    game.lock_move_rotate_count = game.lock_move_rotate_count + 1
                end
            end
        end)
    end
    if key == "right" and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP then
        game.hold_delay = 0
        game.hold_interval = 0
        game.RedrawFalling(function()
            if (not game.CheckCollisionRight()) then
                game.falling_block.y = game.falling_block.y + 1
                game.stop_clock = 0
                sound.PlayMove()
                if (game.is_locking) then
                    game.lock_move_rotate_count = game.lock_move_rotate_count + 1
                end
            end
        end)
    end
    if key == "up" and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP then
        game.RedrawFalling(function()
            local old_orientation = game.falling_block.orientation
            local new_orientation = game.falling_block.orientation + 1
            if new_orientation > #game.brick_shapes[game.falling_block.brick_shape] then
                new_orientation = 1
            end
            game.falling_block.orientation = new_orientation
            local good_wall_kick = game.FindGoodWallKick(old_orientation, new_orientation)
            if good_wall_kick == nil then
                game.falling_block.orientation = old_orientation
            else
                game.falling_block.x = game.falling_block.x + good_wall_kick[1]
                game.falling_block.y = game.falling_block.y + good_wall_kick[2]
                love.audio.play(sound.rotate)
                game.stop_clock = 0
                if (game.is_locking) then
                    game.lock_move_rotate_count = game.lock_move_rotate_count + 1
                end
            end
        end)
    end
end

local played_clear = false

function game.update(dt)
    if (game.phase == game.PHASE_NOTHING) then
        if (ui.animation ~= ui.ANIMATION_NONE) then
            ui.animation_time = ui.animation_time + dt
            if (not played_clear) then
                love.audio.play(sound.clear)
            end
            played_clear = true
            return
        end
        game.CheckRowClears()
        played_clear = false
        if (game.CheckWinLevel()) then
            game.level = game.level + 1
            love.audio.play(sound.rankup)
            game.total_score = game.total_score + game.score
            game.score = 0
        end
        game.piece_queue[game.piece_index] = 0
        game.piece_index = game.piece_index + 1
        while (game.piece_index > #game.piece_queue) do
            game.piece_index = game.piece_index - #game.piece_queue
        end
        game.falling_block.brick_shape = game.piece_queue[game.piece_index]

        game.falling_block.x = 3
        if game.falling_block.brick_shape == game.BRICK_I then
            game.falling_block.x = 2
        end
        game.falling_block.orientation = 1
        game.falling_block.y = math.floor((config.grid_width - game.brick_width[game.falling_block.brick_shape]) / 2.0 +
            1)
        game.falling_block.color = game.brick_color[game.falling_block.brick_shape]
        while (game.CheckCollisionHere()) do
            game.falling_block.x = game.falling_block.x - 1
        end
        if (game.CheckCollisionOutside()) then
            game.game_stage = game.GAME_OVER
            love.audio.play(sound.game_over)
        else
            game.CreateBrick(game.falling_block.brick_shape, game.falling_block.x, game.falling_block.y,
                game.falling_block.color,
                game.falling_block.orientation)
            game.phase = game.PHASE_DROP
        end
    end

    if (game.phase == game.PHASE_DROP) then
        local moved = false
        while (game.last_update >= game.TimePerRow()) do
            game.RedrawFalling(function()
                if (not game.CheckCollisionBottom()) then
                    game.falling_block.x = game.falling_block.x + 1

                    game.lock_move_rotate_count = 0
                    moved = true
                else
                    game.is_locking = true
                end
            end)
            game.last_update = game.last_update - game.TimePerRow()
        end
        if (moved and love.keyboard.isDown("down")) then
            sound.PlayMove()
        end

        game.hold_delay = game.hold_delay + dt * 15
        game.hold_interval = game.hold_interval + dt * 18

        if love.keyboard.isDown("left") and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP and game.hold_interval >= 1 then
            if (game.hold_delay >= 3) then
                game.RedrawFalling(function()
                    if (not game.CheckCollisionLeft()) then
                        sound.PlayMove()
                        game.falling_block.y = game.falling_block.y - 1
                        game.stop_clock = 0
                        if (game.is_locking) then
                            game.lock_move_rotate_count = game.lock_move_rotate_count + 1
                        end
                    end
                end)
            end
            game.hold_interval = game.hold_interval - 1
        end
        if love.keyboard.isDown("right") and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP and game.hold_interval >= 1 then
            if (game.hold_delay >= 3) then
                game.RedrawFalling(function()
                    if (not game.CheckCollisionRight()) then
                        sound.PlayMove()
                        game.falling_block.y = game.falling_block.y + 1
                        game.stop_clock = 0
                        if (game.is_locking) then
                            game.lock_move_rotate_count = game.lock_move_rotate_count + 1
                        end
                    end
                end)
            end
            game.hold_interval = game.hold_interval - 1
        end

        if (love.keyboard.isDown("down")) then
            game.last_update = game.last_update + dt * 15
        else
            game.last_update = game.last_update + dt
        end
        game.RedrawFalling(function()
            if (game.CheckCollisionBottom() and game.is_locking) then
                game.stop_clock = game.stop_clock + dt
            else
                game.stop_clock = 0
            end
        end)

        if (game.stop_clock >= 0.5 or (game.lock_move_rotate_count > game.lock_move_rotate_limit and game.CheckCollisionBottom())) then
            game.RedrawFalling(function()
                while (not game.CheckCollisionBottom()) do
                    game.falling_block.x = game.falling_block.x + 1
                end
            end)
            game.SoftReset()
        end
    end
end

return game
