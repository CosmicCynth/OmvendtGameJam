menu = {}

local suit = require "libaries/suit"

function menu.update(dt)
    if player.level == 0 then
        if suit.Button("Play!", 350,100).hit then
            player.level = 1
            levelLoader(1)
        end
        if suit.Button("Level select!", 305, 150).hit then
            player.level = -1
        end
    elseif player.level == -1 then
        if suit.Button("<-",0,0).hit then
            player.level = 0
        end

        if suit.Button("Level 1", 75,100).hit then
            player.level = 1
            levelLoader(1)
        end

        if suit.Button("Level 2", 350,100).hit then
            player.level = 2
        end

        if suit.Button("Level 3", 630,100).hit then
            player.level = 3
        end
    end


end

function menu.draw()
    if player.level == 0 then
        love.graphics.print("Bug Chungus 3", 290,50)
    elseif player.level == -1 then
        love.graphics.print("Level Selecter!",300,20)
    end
    suit:draw()
end

return menu