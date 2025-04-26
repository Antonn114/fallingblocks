local love = require("love")

UNHIGHLIGHTED_COLOR = { 0.7, 0.7, 0.7 }
HIGHLIGHTED_COLOR = { 1, 1, 1 }


---@overload fun(label: string, label_font : love.Font, func, func_param, width : number, height : number)
function Button(label, label_font, func, func_param, width, height)
    return {
        width = width or 100,
        height = height or 50,
        label = label or "PLACEHOLDER",
        label_font = label_font or love.graphics.newFont(),
        func = func or (function() print(string.format("Button %s has no function attached", label)) end),
        func_param = func_param or nil,
        draw_color = UNHIGHLIGHTED_COLOR,
        button_x = 0,
        button_y = 0,
        getWidth = function(self)
            return self.width
        end,
        getHeight = function(self)
            return self.height
        end,
        ---@overload fun(self, highlight : boolean)
        setHighlight = function(self, highlight)
            if highlight then
                self.draw_color = HIGHLIGHTED_COLOR
            else
                self.draw_color = UNHIGHLIGHTED_COLOR
            end
        end,
        draw = function(self, x, y)
            self.button_x = x
            self.button_y = y
            love.graphics.setColor(self.draw_color)
            local label_text = love.graphics.newText(self.label_font, self.label)
            love.graphics.rectangle("line", self.button_x, self.button_y, self.width, self.height)
            love.graphics.draw(label_text, self.button_x + self.width / 2, self.button_y + self.height / 2, 0, 1, 1,
                label_text:getWidth() / 2,
                label_text:getHeight() / 2)
        end,
        checkForMouse = function(self)
            local mouse_x, mouse_y = love.mouse.getPosition()
            return (self.button_x < mouse_x and mouse_x < self.button_x + self.width and self.button_y < mouse_y and mouse_y < self.button_y + self.height)
        end,
        doFunction = function(self)
            local res = self.func(func_param)
            return res
        end
    }
end

return Button
