local love = require("love")

---@class sound
sound = {}

sound.fall = love.audio.newSource("assets/fall7.wav", "static")
sound.move = love.audio.newSource("assets/move4.wav", "static")
sound.rotate = love.audio.newSource("assets/rotate4.wav", "static")
sound.clear = love.audio.newSource("assets/clear.wav", "static")
sound.hold = love.audio.newSource("assets/reserve.wav", "static")
sound.rankup = love.audio.newSource("assets/lvlup.wav", "static")
sound.game_over = love.audio.newSource("assets/gameover.wav", "static")


function sound.PlayMove()
    love.audio.stop(sound.move)
    love.audio.play(sound.move)
end

return sound
