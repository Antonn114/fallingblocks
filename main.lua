local love = require("love")
local config = require("config")
local game = require("game")
local ui = require("ui")

local function switch(x, cases)
    local match = cases[x] or cases.default or function() end

    return match()
end


function love.load()
    math.randomseed(os.time())
    game.Reset()

    love.window.setMode(config.screen_width, config.screen_height)
    love.window.setTitle("Falling Blocks")
    love.graphics.setLineWidth(2)
end

function love.update(dt)
    switch(game.game_stage, {
        [game.PLAY] = function()
            game.update(dt)
        end,
        [game.PAUSE] = function()
            for k, button in pairs(ui.pause_menu_button_list) do
                button:setHighlight(button:checkForMouse())
            end
        end,
        [game.MAIN_MENU] = function()
            for k, button in pairs(ui.main_menu_button_list) do
                button:setHighlight(button:checkForMouse())
            end
        end,
        [game.GAME_OVER] = function()
            for k, button in pairs(ui.game_over_button_list) do
                button:setHighlight(button:checkForMouse())
            end
        end


    })
end

function love.mousepressed()
    if (game.game_stage == game.MAIN_MENU) then
        for k, button in pairs(ui.main_menu_button_list) do
            if (button:checkForMouse()) then
                button:doFunction()
            end
        end
    end

    if (game.game_stage == game.PAUSE) then
        for k, button in pairs(ui.pause_menu_button_list) do
            if (button:checkForMouse()) then
                button:doFunction()
            end
        end
    end
    if (game.game_stage == game.GAME_OVER) then
        for k, button in pairs(ui.game_over_button_list) do
            if (button:checkForMouse()) then
                button:doFunction()
            end
        end
    end
end

function love.draw()
    local game_stage_cases = {
        [game.PLAY] = function()
            ui.DrawPlay()
        end,
        [game.PAUSE] = function()
            ui.DrawPlay()
            ui.DrawPauseMenu()
        end,
        [game.MAIN_MENU] = function()
            ui.DrawMainMenu()
        end,
        [game.GAME_OVER] = function()
            ui.DrawPlay()
            ui.DrawGameOver()
        end,
        default = function()
            print("game stage invalid")
        end
    }
    switch(game.game_stage, game_stage_cases)
end

function love.quit()
    return false
end
