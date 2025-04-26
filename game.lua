local config = require("config")


--- TODO
-- grace period fix check collision bottom
-- ceiling check collision with outside
-- grace period move + rotate limit


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
        [1] = { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 1, 2 } },
        [2] = { { 0, 1 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
        [3] = { { 1, 0 }, { 1, 1 }, { 1, 2 }, { 2, 1 } },
        [4] = { { 0, 1 }, { 1, 0 }, { 1, 1 }, { 2, 1 } },
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

game.is_landing = false
game.game_stage = game.MAIN_MENU
game.phase = game.PHASE_NOTHING
game.stop_clock = 0
game.last_update = 0

game.hold_block = nil
game.can_hold = false

game.hold_interval = 0
game.hold_delay = 0

game.counter_bag = {
    [game.BRICK_I] = 0,
    [game.BRICK_Z] = 0,
    [game.BRICK_S] = 0,
    [game.BRICK_T] = 0,
    [game.BRICK_L] = 0,
    [game.BRICK_J] = 0,
    [game.BRICK_O] = 0
}
game.current_bag = 0
game.current_bag_numbers = 0

game.piece_queue = { 0, 0, 0, 0, 0, 0, 0 }
game.piece_index = 1

game.falling_block = {
    x = 1,
    y = 1,
    brick_shape = 1,
    color = config.NOTHING_SQUARE,
    orientation = 1
}

function game.RandomBag()
    local choose = math.random(1, 7)
    while (game.counter_bag[choose] ~= game.current_bag) do
        choose = math.random(1, 7)
    end
    game.counter_bag[choose] = game.counter_bag[choose] + 1
    game.current_bag_numbers = game.current_bag_numbers + 1
    if (game.current_bag_numbers >= 7) then
        game.current_bag_numbers = 0
        game.current_bag = game.current_bag + 1
    end
    return choose
end

function game.NextPieceFrom(index)
    local new_index = index + 1
    while new_index > 7 do
        new_index = new_index - 7
    end
    if game.piece_queue[new_index] == 0 then
        game.piece_queue[new_index] = game.RandomBag()
    end
    return game.piece_queue[new_index]
end

function game.SoftReset()
    game.can_hold = true
    game.phase = game.PHASE_NOTHING
    game.is_landing = false
    game.stop_clock = 0
end

function game.Reset()
    game.SoftReset()
    game.level = 1
    game.hold_block = nil
    game.piece_index = 0
    game.current_bag_numbers = 0
    game.current_bag = 0
    game.counter_bag = {
        [game.BRICK_I] = 0,
        [game.BRICK_Z] = 0,
        [game.BRICK_S] = 0,
        [game.BRICK_T] = 0,
        [game.BRICK_L] = 0,
        [game.BRICK_J] = 0,
        [game.BRICK_O] = 0
    }
    for i = 1, 7, 1 do
        game.piece_queue[i] = game.RandomBag()
    end
    game.phase = game.PHASE_NOTHING
    game.is_landing = false
    for i = 1, config.grid_height, 1 do
        game.grid[i] = {}
        for j = 1, config.grid_width, 1 do
            game.grid[i][j] = config.NOTHING_SQUARE
        end
    end
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
    local cleared = 0
    local is_clear = true
    for j = 1, config.grid_width, 1 do
        if game.grid[row][j] == config.NOTHING_SQUARE then
            is_clear = false
        end
    end
    if is_clear then
        for j = 1, config.grid_width, 1 do
            game.grid[row][j] = 0
        end
        game.MoveAllAboveDownToRow(row)
        cleared = cleared + game.CheckRowClear(row) + 1
    end
    return cleared
end

function game.CheckRowClears()
    local cleared = 0
    for i = config.grid_height, 1, -1 do
        cleared = cleared + game.CheckRowClear(i)
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
    return x > config.grid_height or x < 1 or y > config.grid_width or y < 1
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
                game.stop_clock = 0
            end
        end)
    end
end

function game.update(dt)
    if (game.phase == game.PHASE_NOTHING) then
        game.CheckRowClears()
        if (game.CheckWinLevel()) then
            game.level = game.level + 1
            game.total_score = game.total_score + game.score
            game.score = 0
        end
        game.piece_index = game.piece_index + 1
        while (game.piece_index > 7) do
            game.piece_index = game.piece_index - 7
        end
        game.falling_block.brick_shape = game.piece_queue[game.piece_index]

        game.falling_block.x = 5
        if game.falling_block.brick_shape == game.BRICK_I then
            game.falling_block.x = 3
        end
        game.falling_block.orientation = 1
        game.falling_block.y = math.floor((config.grid_width - game.brick_width[game.falling_block.brick_shape]) / 2.0 +
            1)
        while (game.falling_block.x >= 2 and game.CheckCollisionHere()) do
            game.falling_block.x = game.falling_block.x - 1
        end
        if (game.falling_block.x < 2) then
            game.game_stage = game.GAME_OVER
        else
            game.falling_block.color = game.brick_color[game.falling_block.brick_shape]
            game.CreateBrick(game.falling_block.brick_shape, game.falling_block.x, game.falling_block.y,
                game.falling_block.color,
                game.falling_block.orientation)
            game.phase = game.PHASE_DROP
        end
    end

    if (game.phase == game.PHASE_DROP) then
        while (game.last_update >= game.TimePerRow()) do
            game.RedrawFalling(function()
                if (game.CheckCollisionBottom()) then
                    game.is_landing = true
                else
                    game.falling_block.x = game.falling_block.x + 1
                    game.stop_clock = 0
                end
            end)
            game.last_update = game.last_update - game.TimePerRow()
        end

        game.hold_delay = game.hold_delay + dt * 15
        game.hold_interval = game.hold_interval + dt * 18

        if love.keyboard.isDown("left") and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP and game.hold_interval >= 1 then
            if (game.hold_delay >= 3) then
                game.RedrawFalling(function()
                    if (not game.CheckCollisionLeft()) then
                        game.falling_block.y = game.falling_block.y - 1
                        game.stop_clock = 0
                    end
                end)
            end
            game.hold_interval = game.hold_interval - 1
        end
        if love.keyboard.isDown("right") and game.game_stage == game.PLAY and game.phase == game.PHASE_DROP and game.hold_interval >= 1 then
            if (game.hold_delay >= 3) then
                game.RedrawFalling(function()
                    if (not game.CheckCollisionRight()) then
                        game.falling_block.y = game.falling_block.y + 1
                        game.stop_clock = 0
                    end
                end)
            end
            game.hold_interval = game.hold_interval - 1
        end
    end
    if (love.keyboard.isDown("down")) then
        game.last_update = game.last_update + dt * 15
    else
        game.last_update = game.last_update + dt
    end
    if (game.is_landing) then
        game.stop_clock = game.stop_clock + dt
    end

    if (game.stop_clock >= 0.5) then
        game.SoftReset()
    end
end

return game
