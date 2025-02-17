--Windfield
local wf = require "libaries/windfield"
local gravityY = -1000

--Camera
local camera = require"libaries/camera" 
local cam = camera()

--Other scripts
local mainMenu = require"menu"

function love.load()
    --Font setting
    font = love.graphics.newFont("font/WorkSans.ttf",27)
    love.graphics.setFont(font)
    
    --Winfield
    world = wf.newWorld(0,gravityY,true)
    world:addCollisionClass("Ground")
    world:addCollisionClass("PlayerClass")
    world:addCollisionClass("Hazard",{ignores = {"PlayerClass"}})
    world:addCollisionClass("Orb",{ignores = {"PlayerClass"}})

    --Chungus sprites
    gangster = love.graphics.newImage("sprites/Bug_chungangstaOmvendt.png")

    --Other sprites
    tree = love.graphics.newImage("sprites/Tree.png")

    --Sound effects
    jumpSFX = love.audio.newSource("sfx/jump.wav","static")

    --Player variables 
    player = {}
    player.collider = world:newRectangleCollider(200, 200, 110*0.75, 160*0.75)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("PlayerClass")
    player.x = player.collider:getX()
    player.y = player.collider:getY()
    player.speed = 300
    player.jumpforce = 12000
    player.isGrounded = true

    player.level = 0
    player.deaths = 0
    player.checkpoint = 0

    OrbCooldown = 0
end

function love.update(dt)
    menu.update(dt)
    if player.level > 0 then

        --Player movement
        local vx,vy = player.collider:getLinearVelocity()

        if love.keyboard.isDown("a") then
            player.collider:setLinearVelocity(player.speed,vy)
        elseif love.keyboard.isDown("d") then
            player.collider:setLinearVelocity(-player.speed,vy)
        else
            player.collider:setLinearVelocity(0,vy)
        end

        if love.keyboard.isDown("space") and player.isGrounded == true then
            player.collider:applyLinearImpulse(0,player.jumpforce)
            jumpSFX:play()
            player.isGrounded = false
        end

        if player.collider:enter("Ground") then
            print("Player entered ground")
            player.isGrounded = true
        end

        if love.keyboard.isDown("escape") and player.level > 0 then
            player.level = 0
        end

        --Player position updating
        player.x = player.collider:getX()
        player.y = player.collider:getY()
        cam:lookAt(player.x,player.y-16)
        world:update(dt)

        --Orbs
        --Blue orbs
        OrbCooldown = OrbCooldown + 1
        if OrbCooldown >= 10 then
            OrbCooldown = 10
        end

        if player.collider:enter("Orb") and OrbCooldown >= 10 then
            print("Player entered Orb")
            OrbCooldown = 0
            player.isGrounded = true
        end

        --Spikes
        if player.collider:enter("Hazard") then
            print("Player died!")
            death(player.checkpoint)
        end
    end

end

function love.draw()
    if player.level == 1 then
        cam:attach()
            love.graphics.draw(gangster,player.x,player.y,nil,0.75,0.75,70,110)
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
    --g = ground, o = orbs, s = spikes
    g = {}
    o = {}
    s = {}

    for i, ground in ipairs(g) do
        if ground and ground.destroy then
            ground:destroy()
        end
    end

    if level == 1 then
        player.collider:setPosition(200,300)
        table.insert(g,world:newRectangleCollider(100,200,400,50))
        table.insert(o,world:newRectangleCollider(200,400,64,64))
        table.insert(s,world:newRectangleCollider(468,264,32,32))
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
end

function death(checkpoint)
    if checkpoint == 0 then
        levelLoader(player.level)
        player.deaths = player.deaths + 1
    end
end

