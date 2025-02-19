--Windfield
local wf = require "libaries/windfield"
local gravityY = -1000

--Camera
local camera = require"libaries/camera" 
local cam = camera()

--Tiled
sti = require"libaries/sti"
level1 = sti("levels/Level1.lua")
level2 = sti("levels/Level2.lua")
level3 = sti("levels/Level3.lua")
level4 = sti("levels/Level4.lua")
level5 = sti("levels/Level5.lua")

--Other scripts
local mainMenu = require"menu"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    --Music
    streetMusic = love.audio.newSource("songs/StreetMusic.wav","stream")
    streetMusic:setLooping(true)

    spaceMusic = love.audio.newSource("songs/spaceMusic.wav","stream")
    spaceMusic:setLooping(true)

    planetMusic = love.audio.newSource("songs/MysteryMp3.mp3","stream")

    --Font setting
    font = love.graphics.newFont("font/WorkSans.ttf",27)
    love.graphics.setFont(font)
    
    --Winfield
    world = wf.newWorld(0,gravityY,true)
    world:addCollisionClass("Ground")
    world:addCollisionClass("PlayerClass")
    world:addCollisionClass("Hazard",{ignores = {"PlayerClass"}})
    world:addCollisionClass("Orb",{ignores = {"PlayerClass"}})
    world:addCollisionClass("Goal",{ignores = {"PlayerClass"}})

    --Chungus sprites
    gangster = love.graphics.newImage("sprites/Bug_chungangstaOmvendt.png")
    norgangster = love.graphics.newImage("sprites/Bug_chungangsta.png")

    --Other sprites
    mainMenuBG = love.graphics.newImage("sprites/MainMenuBG.png")
    streetBG = love.graphics.newImage("sprites/StreetBackground.png")
    spaceBG = love.graphics.newImage("sprites/BackgroundSpaceBugy.png")
    planetBG = love.graphics.newImage("sprites/BackgroundBugyPlane3t.png")
    tree = love.graphics.newImage("sprites/Tree.png")

    --Sound effects
    jumpSFX = love.audio.newSource("sfx/jump.wav","static")
    deathSFX = love.audio.newSource("sfx/deathsfx.mp3","static")
    flipSFX = love.audio.newSource("sfx/flip.wav","static")
    victorySFX = love.audio.newSource("sfx/victory.wav","static")

    --Player variables 
    player = {}
    player.collider = world:newRectangleCollider(200, 200, 100*0.5, 160*0.5)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("PlayerClass")
    player.x = player.collider:getX()
    player.y = player.collider:getY()
    player.speed = 300
    player.jumpforce = 4750
    player.isGrounded = true

    player.level = 0
    player.deaths = 0

    OrbCooldown = 0
    flipCD = 110
end

function love.update(dt)
    menu.update(dt)
    if player.level > 0 then

        --Player movement
        local vx,vy = player.collider:getLinearVelocity()

        if love.keyboard.isDown("a") then
            if gravityY < 0 then
                player.collider:setLinearVelocity(player.speed,vy)
            else
                player.collider:setLinearVelocity(-player.speed,vy)
            end
        elseif love.keyboard.isDown("d") then
            if gravityY < 0 then
                player.collider:setLinearVelocity(-player.speed,vy)
            else
                player.collider:setLinearVelocity(player.speed,vy)
            end
        else
            player.collider:setLinearVelocity(0,vy)
        end

        if love.keyboard.isDown("space") then
            if player.isGrounded == true and touchedOrb == false then
                player.collider:applyLinearImpulse(0,player.jumpforce)
                jumpSFX:play()
                player.isGrounded = false
            elseif player.isGrounded == false and touchedOrb == true then
                player.collider:applyLinearImpulse(0,player.jumpforce*1.75)
                jumpSFX:play()
                touchedOrb = false
            end
        end

        if player.collider:enter("Ground") then
            print("Player entered ground")
            player.isGrounded = true
        end

        if player.collider:exit("Ground") then
            print("Player left ground")
            player.isGrounded = false
        end

        if love.keyboard.isDown("escape") and player.level > 0 then
            player.level = 0
        end

         --Flips
        flipCD = flipCD + 1
        if flipCD >= 110 then
            flipCD = 110
        end
        if player.level >= 3 and love.keyboard.isDown("w") and flipCD >= 110 then
            gravityY = -gravityY
            player.jumpforce = -player.jumpforce
            world:setGravity(0,gravityY)
            flipCD = 0
            print("Player flipped")
            flipSFX:play()
        end

        --Player position updating
        player.x = player.collider:getX()
        player.y = player.collider:getY()
        
        cam:lookAt(player.x,player.y-16)        
        world:update(dt)

        --Music


        --Collision checks

        --Blue orbs
        touchedOrb = false

        OrbCooldown = OrbCooldown + 1
        if OrbCooldown >= 10 then
            OrbCooldown = 10
        end

        if player.collider:enter("Orb") and OrbCooldown >= 10  then
            print("Player entered Orb")
            touchedOrb = true
        end

        if player.collider:exit("Orb") then
            print("Player exited Orb")
            touchedOrb = false
        end

        --Spikes
        if player.collider:enter("Hazard") then
            print("Player died!")
            death()
        end

        --Goal
        if player.collider:enter("Goal") then
            print("Player won!")
            completedLevel()
        end
        --Out of bounds
        if player.y < -600 then
            print("Out of bounds!")
            death()
        elseif player.y > 1900 then
            print("Out of bounds!")
            death()
        end
    end

end

function love.draw()
    if player.level == 0 or player.level == -1 then
        love.graphics.draw(mainMenuBG)
    elseif player.level == 1 then
        love.graphics.draw(streetBG)
        cam:attach()
            love.graphics.draw(gangster,player.x,player.y,nil,0.5,0.5,70,110)
            level1:drawLayer(level1.layers["Probs"])
            level1:drawLayer(level1.layers["Trees"])
            level1:drawLayer(level1.layers["HazardTiles"])
            level1:drawLayer(level1.layers["Ground"])
            --world:draw()
        cam:detach()
    elseif player.level == 2 then
        love.graphics.draw(streetBG)
        cam:attach()
            love.graphics.draw(gangster,player.x,player.y,nil,0.5,0.5,70,110)
            level2:drawLayer(level2.layers["Ground"])
            level2:drawLayer(level2.layers["Probs"])
            --world:draw()
        cam:detach()
    elseif player.level == 3 then
        love.graphics.draw(spaceBG)
        cam:attach()
            if gravityY < 0 then
                love.graphics.draw(gangster,player.x,player.y,nil,0.5,0.5,70,110)
            else
                love.graphics.draw(norgangster,player.x,player.y,nil,0.5,0.5,70,170)
            end
            level3:drawLayer(level3.layers["Probs"])
            level3:drawLayer(level3.layers["Ground"])
            --world:draw()
        cam:detach()
    elseif player.level == 4 then
        love.graphics.draw(spaceBG)
        cam:attach()
            if gravityY < 0 then
                love.graphics.draw(gangster,player.x,player.y,nil,0.5,0.5,70,110)
            else
                love.graphics.draw(norgangster,player.x,player.y,nil,0.5,0.5,70,170)
            end
            level4:drawLayer(level4.layers["Ground"])
            level4:drawLayer(level4.layers["Probs"])
            
            --world:draw()
        cam:detach()
    elseif player.level == 5 then
        love.graphics.draw(planetBG)
        cam:attach()
            if gravityY < 0 then
                love.graphics.draw(gangster,player.x,player.y,nil,0.5,0.5,70,110)
            else
                love.graphics.draw(norgangster,player.x,player.y,nil,0.5,0.5,70,170)
            end
            level5:drawLayer(level5.layers["Ground"])

            world:draw()
        cam:detach()
    end
    if player.level > 0 then
        love.graphics.print("Level: "..player.level.."\nDeaths: "..player.deaths)
    end
    menu.draw()
end

--Draws the hitboxes & set player spawns
function levelLoader(level)
    if g then
        for i, ground in ipairs(g) do
            if ground and ground.destroy then
                ground:destroy()
            end
        end
    end

    if o then
        for i, orb in ipairs(o) do
            if orb and orb.destroy then
                orb:destroy()
            end
        end
    end

    if s then
        for i, spike in ipairs(s) do
            if spike and spike.destroy then
                spike:destroy()
            end
        end
    end

    if f then
        for i, goal in ipairs(f) do
            if goal and goal.destroy then
                goal:destroy()
            end
        end
    end
    --g = ground, o = orbs, s = spikes, f = goal
    g = {}
    o = {}
    s = {}
    f = {}

    if level == 1 then
        --Player position
        player.collider:setPosition(200,300)
        gravityY = -1000
        world:setGravity(0,gravityY)
        player.jumpforce = 4750
        --Music
        love.audio.stop()
        streetMusic:play()
        --Platforms
        table.insert(g,world:newRectangleCollider(32,0,256+160+96,96))
        table.insert(g,world:newRectangleCollider(576,0,96,144))
        table.insert(g,world:newRectangleCollider(672,0,320,32))
        table.insert(g,world:newRectangleCollider(992,0,96,64))
        table.insert(g,world:newRectangleCollider(1088,0,96,112))
        table.insert(g,world:newRectangleCollider(1184,0,96,144))
        table.insert(g,world:newRectangleCollider(1360,64,96,16))
        table.insert(g,world:newRectangleCollider(1520,112,96,16))
        table.insert(g,world:newRectangleCollider(1680,144,96,16))
        table.insert(g,world:newRectangleCollider(1840,0,96,208))
        table.insert(g,world:newRectangleCollider(1936,0,288,64))
        --Hazards
        table.insert(s,world:newRectangleCollider(1584,128,32,32))
        table.insert(s,world:newRectangleCollider(1744,160,32,32))
        table.insert(s,world:newRectangleCollider(1904,208,32,32))
        --Finish line
        table.insert(f,world:newRectangleCollider(1936,64,288,48))
    elseif level == 2 then
        player.jumpforce = 4750
        gravityY = -1000
        player.collider:setPosition(80,200)
        world:setGravity(0,gravityY)
        love.audio.stop()
        streetMusic:play()
        --Platforms
        table.insert(g,world:newRectangleCollider(64,0,96,96))
        table.insert(g,world:newRectangleCollider(192,0,128,160))
        table.insert(g,world:newRectangleCollider(640,128,160,32))
        table.insert(g,world:newRectangleCollider(848,0,320,208))
        table.insert(g,world:newRectangleCollider(1600,0,96,256))
        table.insert(g,world:newRectangleCollider(1600,400,96,64))
        table.insert(g,world:newRectangleCollider(1600,400,96,64))
        table.insert(g,world:newRectangleCollider(1888,0,736,192))
        table.insert(g,world:newRectangleCollider(2704,0,64,400))
        

        --Orbs
        table.insert(o,world:newRectangleCollider(480-8,120,48,12))
        table.insert(o,world:newRectangleCollider(480-8,120+36,48,12))

        table.insert(o,world:newRectangleCollider(1280-8,288,48,12))
        table.insert(o,world:newRectangleCollider(1280-8,288+36,48,12))

        table.insert(o,world:newRectangleCollider(1440-8,320,48,12))
        table.insert(o,world:newRectangleCollider(1440-8,320+36,48,12))

        --Spikes
        table.insert(s,world:newRectangleCollider(1968,192,192,32))
        table.insert(s,world:newRectangleCollider(2272,192,160,32))
        table.insert(s,world:newRectangleCollider(2528,192,96,32))

        --Goal
        table.insert(f,world:newRectangleCollider(2640,240,64,96))

    elseif level == 3 then
        player.collider:setPosition(80,200)
        world:setGravity(0,gravityY)

        love.audio.stop()
        spaceMusic:play()

        --Platforms
        table.insert(g,world:newRectangleCollider(16,0,96,96))
        table.insert(g,world:newRectangleCollider(16,480,96,96))
        table.insert(g,world:newRectangleCollider(176,96,96,96))
        table.insert(g,world:newRectangleCollider(336,176,96,96))
        table.insert(g,world:newRectangleCollider(640,176,96+96,96))
        table.insert(g,world:newRectangleCollider(736,480,96,96))
        table.insert(g,world:newRectangleCollider(1120,560,64,64))
        table.insert(g,world:newRectangleCollider(1600,208,96,192))
        table.insert(g,world:newRectangleCollider(1824,112,96,96))
        table.insert(g,world:newRectangleCollider(2048,336,96,192))
        table.insert(g,world:newRectangleCollider(2432,352,96,176))
        table.insert(g,world:newRectangleCollider(2784,160,96,192))
        table.insert(g,world:newRectangleCollider(2848,400,32,128))
        table.insert(g,world:newRectangleCollider(2880,496,320,32))
        table.insert(g,world:newRectangleCollider(3200,400,128,128))
        table.insert(g,world:newRectangleCollider(3328,256,32,272))
        table.insert(g,world:newRectangleCollider(3072,0,288,256))
        table.insert(g,world:newRectangleCollider(3040,0,32,368))

        --Hazards
        table.insert(s,world:newRectangleCollider(704,480,32,32))
        table.insert(s,world:newRectangleCollider(704,544,32,32))
        table.insert(s,world:newRectangleCollider(768,576,32,32))
        table.insert(s,world:newRectangleCollider(832,480,32,32))
        table.insert(s,world:newRectangleCollider(832,544,32,32))
        table.insert(s,world:newRectangleCollider(1568,336,32,32))
        table.insert(s,world:newRectangleCollider(1696,240,32,32))
        table.insert(s,world:newRectangleCollider(1888,208,32,32))
        table.insert(s,world:newRectangleCollider(2048,528,96,32))
        table.insert(s,world:newRectangleCollider(2432,320,96,32))
        table.insert(s,world:newRectangleCollider(2784,352,96,32))

        --Orbs
        table.insert(o,world:newRectangleCollider(1440,480,48,12))
        table.insert(o,world:newRectangleCollider(1440,480+36,48,12))

        --Goal
        table.insert(f,world:newRectangleCollider(3264,256,64,144))
    elseif level == 4 then
        player.jumpforce = -4750
        gravityY = 1000 
        player.collider:setPosition(400,200)
        world:setGravity(0,gravityY)

        love.audio.stop()
        spaceMusic:play()

        --Platforms
        table.insert(g,world:newRectangleCollider(96,480,1520,32))
        table.insert(g,world:newRectangleCollider(128,32,1932,32))
        table.insert(g,world:newRectangleCollider(656,320,32,128))
        table.insert(g,world:newRectangleCollider(624,448,96,32))
        table.insert(g,world:newRectangleCollider(1520,32,400,32))
        table.insert(g,world:newRectangleCollider(1888,64,192,256))
        table.insert(g,world:newRectangleCollider(1184,160,32,32))
        table.insert(g,world:newRectangleCollider(1504,256,32,32))
        table.insert(g,world:newRectangleCollider(2032,592,96,96))
        table.insert(g,world:newRectangleCollider(2176,432,96,208))
        table.insert(g,world:newRectangleCollider(2496,608,128,32))
        table.insert(g,world:newRectangleCollider(2672,432,128,32))
        table.insert(g,world:newRectangleCollider(2944,320,128,32))
        table.insert(g,world:newRectangleCollider(3248,384,96,128))
        table.insert(g,world:newRectangleCollider(3584,336,96,16))
        table.insert(g,world:newRectangleCollider(3920,272,96,16))
        
        

        --Hazards
        table.insert(s,world:newRectangleCollider(160,64,64,416))
        table.insert(s,world:newRectangleCollider(656,288,32,32))
        table.insert(s,world:newRectangleCollider(624,416,32,32))
        table.insert(s,world:newRectangleCollider(592,448,32,32))
        table.insert(s,world:newRectangleCollider(688,416,32,32))
        table.insert(s,world:newRectangleCollider(720,448,32,32))
        table.insert(s,world:newRectangleCollider(800,352,32,32))
        table.insert(s,world:newRectangleCollider(768,384,96,32))
        table.insert(s,world:newRectangleCollider(800,416,32,32))
        table.insert(s,world:newRectangleCollider(1444,224,32,96))
        table.insert(s,world:newRectangleCollider(1408,256,32,32))
        table.insert(s,world:newRectangleCollider(1088,448,272,32))
        table.insert(s,world:newRectangleCollider(1072,64,800,32))
        table.insert(s,world:newRectangleCollider(1584,448,32,32))
        table.insert(s,world:newRectangleCollider(1616,448,32,32))
        table.insert(s,world:newRectangleCollider(1648,480,32,32))
        table.insert(s,world:newRectangleCollider(1680,512,32,32))
        table.insert(s,world:newRectangleCollider(1584,448,32,32))
        table.insert(s,world:newRectangleCollider(1712,544,32,32))
        table.insert(s,world:newRectangleCollider(1744,576,32,32))
        table.insert(s,world:newRectangleCollider(1584,448,32,32))
        table.insert(s,world:newRectangleCollider(1776,608,256,32))
        table.insert(s,world:newRectangleCollider(2048,320,32,128))
        table.insert(s,world:newRectangleCollider(2128,608,48,32))
        table.insert(s,world:newRectangleCollider(2272,448,32,192))
        table.insert(s,world:newRectangleCollider(2080,192,496,32))
        table.insert(s,world:newRectangleCollider(2672,464,128,32))
        table.insert(s,world:newRectangleCollider(2576,160,32,32))
        table.insert(s,world:newRectangleCollider(2608,128,32,32))
        table.insert(s,world:newRectangleCollider(2640,96,32,32))
        table.insert(s,world:newRectangleCollider(2672,64,352,32))
        table.insert(s,world:newRectangleCollider(2944,352,128,32))
        table.insert(s,world:newRectangleCollider(3616,304,32,32))

        --Orbs
        table.insert(o,world:newRectangleCollider(1744,480,32,16))
        table.insert(o,world:newRectangleCollider(1744,480+36,32,16))

        --Goal
        table.insert(f,world:newRectangleCollider(3952,144,64,112))
    elseif level == 5 then
        player.jumpforce = -4750
        gravityY = 1000 
        player.collider:setPosition(130,500)
        world:setGravity(0,gravityY)

        love.audio.stop()
        planetMusic:play()

        table.insert(g,world:newRectangleCollider(112,560,96,192))
        table.insert(g,world:newRectangleCollider(112,48,96,192))




    end

    for i, grounds in ipairs(g) do 
        grounds:setType("static")
        grounds:setCollisionClass("Ground")
    end
    for i, orbs in ipairs(o) do
        orbs:setType("static")
        orbs:setCollisionClass("Orb")
    end
    for i, spikes in ipairs(s) do
        spikes:setType("static")
        spikes:setCollisionClass("Hazard")
    end
    for i, goals in ipairs(f) do 
        goals:setType("static")
        goals:setCollisionClass("Goal")
    end
end

function death()
    levelLoader(player.level)
    player.deaths = player.deaths + 1
    deathSFX:play()
end

function completedLevel()
    player.level = player.level + 1
    levelLoader(player.level)
    victorySFX:play()
end
