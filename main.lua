--================================LIBRARIES================================--
local denver = require 'libraries.denver'
local rs = require 'libraries.resolution_solution'
local baton = require 'libraries.baton'
local binser = require 'libraries.binser'
local urutora = require 'libraries.urutora'

--================================VARIABLES================================--
playerred = {}
playerred.speed = 100
playerred.x = 240
playerred.y =240
playerblue = {}
playerblue.speed = 100
playerblue.x = 272
playerblue.y =272
distance = 0
darkness = 1
enemy = {}
enemystartspeed = 75
enemy.speed = enemystartspeed
enemy.x = 16
enemy.y = 16
enemytimerMax = 2
enemytimer = enemytimerMax
enemy.spawn = true
redparticles = {}
blueparticles = {}
enemyparticles = {}
randomSide = 1
playerTarget = playerred
lives = 3
score = 0
highscore = 0
gameOver = false
particleTimer = 1000
mute = false
paused = true



--================================BATON INPUTS================================--
local input = baton.new {
  controls = {
    redleft = {'key:a', 'button:dpleft', 'axis:leftx-'},
    redright = {'key:d', 'button:dpright', 'axis:leftx+'},
    redup = {'key:w', 'button:dpup', 'axis:lefty-'},
    reddown = {'key:s', 'button:dpdown', 'axis:lefty+'},
    blueleft = {'key:left', 'button:x', 'axis:rightx-'},
    blueright = {'key:right', 'button:b', 'axis:rightx+'},
    blueup = {'key:up', 'button:y', 'axis:righty-'},
    bluedown = {'key:down', 'button:a', 'axis:righty+'},
    mute = {'key:m', 'button:back'},
    restart = {'key:r', 'button:start'},
  },
  joystick = love.joystick.getJoysticks()[1],
}

--================================URUTORA================================--

local u = urutora:new()

function love.mousepressed(x, y, button) u:pressed(x, y, button) end
function love.mousemoved(x, y, dx, dy) u:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) u:released(x, y, button) end
function love.textinput(text) u:textinput(text) end
function love.keypressed(k, scancode, isrepeat) u:keypressed(k, scancode, isrepeat) end
function love.wheelmoved(x, y) u:wheelmoved(x, y) end

function urutoraInit()
    u.setDefaultFont(bigfont)
    local bgColor = {0.2, 0.2, 0.7, 1}
  
  clickMe = u.button({
    text = "PAUSE/RESUME",
    x = 50, y = 50,
    w = 150, h = 50,
  }):action(function()
    paused = not paused
  end
  )
  
  startLabel = u.label({
      text = "aabbcc",
      w = 150, h = 50,
    })
  
  StayCloseImage = u.image({
      image = StayCloseIcon,
      w = 50, h = 50
    })

  
  startPanel = u.panel({
      x = 50, y = 50,
      w = 402, h = 402,
      rows = 3, cols = 3,
      bgColor = bgColor
    }):addAt(1, 1, StayCloseImage)
      :setStyle({ font = bigfont })
      :addAt(1, 2, startLabel)
      :colspanAt(3, 1, 3)
      :addAt(3, 1, clickMe)
  
  u:add(startPanel)
  
end


--================================MATH FUNCTIONS================================--
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

function checkCircularCollision(ax, ay, bx, by, ar, br)
	local dx = bx - ax
	local dy = by - ay
	return dx^2 + dy^2 < (ar + br)^2
end

function LineCollision(lx1,ly1, lx2,ly2, x,y)
  local lineLength = math.dist(lx1,ly1, lx2,ly2)
  local length1 = math.dist(lx1,ly1, x,y)
  local length2 = math.dist(lx2,ly2, x,y)
  local totalLength = length1 + length2
  if lineLength > totalLength - 1 then
    return true
  end
end

--================================MUSIC MUTE FUNCTION================================--
function musicmute()
  if input:pressed 'mute' and mute == false then
    mute = true
    love.audio.stop(bgm)
    savegame()
  elseif input:pressed 'mute' and mute == true then
    mute = false
    savegame()
  end
end

--================================SAVE FUNCTION================================--
function savegame()
    local savedata = binser.serialize({["hs"] = highscore,["m"] = mute})
    love.filesystem.write("savedata.txt",savedata)
    print("Saved data: "..savedata)
end

--================================LOVE LOAD================================--
function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  smallfont = love.graphics.newFont("assets/font.ttf", 16)
  bigfont = love.graphics.newFont("assets/font.ttf", 32)
  nofont = love.graphics.newFont("assets/font.ttf", 1)

  if love.filesystem.getInfo("savedata.txt") then
    local data = binser.deserializeN(love.filesystem.read("savedata.txt"))
    highscore,mute = data["hs"],data["m"]
    
    print(highscore)
    if mute == true then
      print("muted")
    elseif mute == false then
      print("unmuted")
    else
      print(mute)
    end
  end
  
  savegame()

  StayCloseIcon = love.graphics.newImage("assets/icon.png")
  map = love.graphics.newImage("assets/map.png")
  playerredImg = love.graphics.newImage("assets/spritered.png")
  playerblueImg = love.graphics.newImage("assets/spriteblue.png")
  enemyImg = love.graphics.newImage("assets/enemy.png")
  
  fullHeart = love.graphics.newImage("assets/fullheart.png")
  emptyHeart = love.graphics.newImage("assets/emptyheart.png")
  enemyspeed = love.graphics.newImage("assets/enemyspeed.png")
  emptyspeed = love.graphics.newImage("assets/emptyspeed.png")
  
  particlered = love.graphics.newImage("assets/particlered.png")
  particleblue = love.graphics.newImage("assets/particleblue.png")
  particleenemy = love.graphics.newImage("assets/particleenemy.png")
  local buffer = 1000
  redsystem = love.graphics.newParticleSystem(particlered, buffer)
  bluesystem = love.graphics.newParticleSystem(particleblue, buffer)
  enemysystem = love.graphics.newParticleSystem(particleenemy, buffer)
  local min, max = 1, 3
  redsystem:setParticleLifetime(min, max)
  bluesystem:setParticleLifetime(min, max)
  enemysystem:setParticleLifetime(min, max)
  local rate = 5
	redsystem:setEmissionRate(rate)
	bluesystem:setEmissionRate(rate)
	enemysystem:setEmissionRate(rate)
  local accel = 20
	redsystem:setLinearAcceleration(-accel, -accel, accel, accel)
	bluesystem:setLinearAcceleration(-accel, -accel, accel, accel)
	enemysystem:setLinearAcceleration(-accel, -accel, accel, accel)
  
  love.graphics.setLineWidth(2)
  math.randomseed(os.time())
  
  rs.init({width = 512, height = 512, mode = 1})
  rs.setMode(512, 512, {resizable = true})
  
  bgm = love.audio.newSource("assets/bgm.wav", "stream")--https://musiclab.chromeexperiments.com/Song-Maker/song/4658393156681728

  urutoraInit()

end


--================================LOVE UPDATE================================--
function love.update(dt)

  u:update(dt)
  musicmute()
  input:update()
  
  if mute == false then
    love.audio.play(bgm)
  end
  
  distance = math.dist(playerred.x,playerred.y, playerblue.x,playerblue.y)
  darkness = (distance/256*-1)+1
  love.resize = function(w, h)
  rs.resize(w, h)
  end
  if not paused then
	redsystem:update(dt)
	bluesystem:update(dt)
	enemysystem:update(dt)

  
  enemytimer = enemytimer - 1 * dt
if lives > 0 then
  if input:down 'redup' and playerred.y > 16 then
     playerred.y = playerred.y - (playerred.speed * dt)
  end
  if input:down 'reddown' and playerred.y < 480 then
     playerred.y = playerred.y + (playerred.speed * dt)
  end
  if input:down 'redleft' and playerred.x > 16 then
     playerred.x = playerred.x - (playerred.speed * dt)
  end
  if input:down 'redright' and playerred.x < 480 then
  playerred.x = playerred.x + (playerred.speed * dt)
end

  if input:down 'blueup' and playerblue.y > 16 then
     playerblue.y = playerblue.y - (playerblue.speed * dt)
  end
  if input:down 'bluedown' and playerblue.y < 480 then
     playerblue.y = playerblue.y + (playerblue.speed * dt)
  end
  if input:down 'blueleft' and playerblue.x > 16 then
     playerblue.x = playerblue.x - (playerblue.speed * dt)
  end
  if input:down 'blueright' and playerblue.x < 480 then
  playerblue.x = playerblue.x + (playerblue.speed * dt)
end
end


if enemytimer < 0 and lives > 0 then
  enemytimer = enemytimerMax
  enemy.spawn = true
end


if enemy.spawn == true then
  
randomSide = math.random(1,4)
if randomSide == 1 then
  enemy.x = 232
  enemy.y = 8
elseif randomSide == 2 then
  enemy.x = 488
  enemy.y = 232
elseif randomSide == 3 then
  enemy.x = 232
  enemy.y = 488
elseif randomSide == 4 then
  enemy.x = 8
  enemy.y = 232
end

if math.random(1,2) == 1 then
  playerTarget = playerred
else
  playerTarget = playerblue
  end

  newEnemy = {x = enemy.x, y = enemy.y, speed = enemy.speed, target = playerTarget}
  table.insert(enemy, newEnemy)

  enemy.spawn = false
end

for i, newEnemy in ipairs(enemy) do
if lives > 0 then
  if newEnemy.x < newEnemy.target.x then
    newEnemy.x = newEnemy.x + newEnemy.speed * dt
  end
  if newEnemy.x > newEnemy.target.x then
    newEnemy.x = newEnemy.x - newEnemy.speed * dt
  end
  if newEnemy.y < newEnemy.target.y then
    newEnemy.y = newEnemy.y + newEnemy.speed * dt
  end
  if newEnemy.y > newEnemy.target.y then
    newEnemy.y = newEnemy.y - newEnemy.speed * dt
  end
end


if checkCircularCollision(newEnemy.x+8, newEnemy.y+8, playerred.x+8, playerred.y+8, 8, 8) then
    newParticle = {x = newEnemy.x, y = newEnemy.y, timer = particleTimer}
    table.insert(redparticles, newParticle)
    table.remove(enemy, i)
    lives = lives - 1
    local sound = denver.get({waveform='square', frequency=440, length=0.2})
    local sound2 = denver.get({waveform='square', frequency=330, length=0.4})
    love.audio.play(sound, sound2)
  elseif checkCircularCollision(newEnemy.x+8, newEnemy.y+8, playerblue.x+8, playerblue.y+8, 8, 8) then
    newParticle = {x = newEnemy.x, y = newEnemy.y, timer = particleTimer}
    table.insert(blueparticles, newParticle)
    table.remove(enemy, i)
    lives = lives - 1
      local sound = denver.get({waveform='square', frequency=660, length=0.2})
      local sound2 = denver.get({waveform='square', frequency=330, length=0.4})
      love.audio.play(sound, sound2)
  end
  
    if LineCollision(playerred.x, playerred.y, playerblue.x, playerblue.y, newEnemy.x, newEnemy.y) then
      newParticle = {x = newEnemy.x, y = newEnemy.y, timer = particleTimer}
      table.insert(enemyparticles, newParticle)
      table.remove(enemy, i)
      score = score + 1
      local randomPower = math.random(1,100)
      if randomPower < 11 then
        lives = lives + 1
      elseif randomPower < 21 and randomPower > 10 then
        enemy.speed = enemy.speed + 5
      elseif randomPower < 31 and randomPower > 20 then
        enemy.speed = enemy.speed - 5
      elseif randomPower == 100 then
        lives = 5
      end
      local sound = denver.get({waveform='sinus', frequency=660, length=0.2})
      local sound2 = denver.get({waveform='sinus', frequency=330, length=0.4})
      love.audio.play(sound, sound2)
    end
end

if enemy.speed < 50 then
  enemy.speed = 50
elseif enemy.speed > 100 then
  enemy.speed = 100
end

for i, newParticle in ipairs(redparticles) do
  newParticle.timer = newParticle.timer - 1
  if newParticle.timer < 0 then
  table.remove(redparticles,i)
  end
end

for i, newParticle in ipairs(blueparticles) do
  newParticle.timer = newParticle.timer - 1
  if newParticle.timer < 0 then
  table.remove(blueparticles,i)
  end
end

for i, newParticle in ipairs(enemyparticles) do
  newParticle.timer = newParticle.timer - 1
  if newParticle.timer < 0 then
  table.remove(enemyparticles,i)
  end
end

 if lives < 1 and input:pressed 'restart' then
  enemy= {}
  enemy.speed = 50
  lives = 3
  playerred.x = 240
  playerred.y =240
  playerblue.x = 272
  playerblue.y =272
  enemytimer = enemytimerMax
  gameOver = false
  score = 0
  enemy.speed = enemystartspeed
end

if score > highscore then
  highscore = score
  savegame()
end

if lives < 1 and gameOver == false then
  local noise = denver.get({waveform='whitenoise', length=1})
  love.audio.play(noise)
  gameOver = true
end
if lives > 5 then
  lives = 5
end
end
end

----================================LOVE DRAW================================--
function love.draw(dt)
  rs.start()
  
  love.graphics.setColor(darkness,darkness,darkness)
  love.graphics.draw(map)
  love.graphics.setColor(0,0,0)
  love.graphics.line(playerred.x+8, playerred.y+8, playerblue.x+8, playerblue.y+8)
  love.graphics.setColor(darkness,darkness,darkness)
  
  love.graphics.draw(playerredImg, playerred.x, playerred.y)
  love.graphics.draw(playerblueImg, playerblue.x, playerblue.y)
  for i, newEnemy in ipairs(enemy) do
    love.graphics.draw(enemyImg, newEnemy.x, newEnemy.y)
  end
  
 for i, newParticle in ipairs(redparticles) do
    love.graphics.draw(redsystem, newParticle.x, newParticle.y)
 end
 
 for i, newParticle in ipairs(blueparticles) do
    love.graphics.draw(bluesystem, newParticle.x, newParticle.y)
 end
  
 for i, newParticle in ipairs(enemyparticles) do
    love.graphics.draw(enemysystem, newParticle.x, newParticle.y)
 end
  
  love.graphics.setColor(1,1,1)
  for i = 0, 4 do
    love.graphics.draw(emptyHeart, i * 18 +16)
  end
  for i = 0, lives-1 do
    love.graphics.draw(fullHeart, i * 18 + 16)
  end
  for i = 0, 19 do
    love.graphics.draw(emptyspeed, i * 9 + 256 + 16, 2)
  end
  for i = 0, enemy.speed/5-1 do
    love.graphics.draw(enemyspeed, i * 9 + 256 + 16, 2)
  end
  love.graphics.setFont(smallfont)
  love.graphics.print("Score: "..score, 128)
  
  love.graphics.setFont(bigfont)
  if lives < 1 then
    love.graphics.print("Press 'R' to restart", 24, 512 * 1/3)
    love.graphics.print("Score: "..score, 24, 512 * 1/2)
    love.graphics.print("Highscore: "..highscore, 24, 512 * 2/3)
  end
  --[[if paused then
    love.graphics.print("WASD for red", 24, 512 * 1/3)
    love.graphics.print("Arrow keys for blue", 24, 512 * 1/2)
    love.graphics.print("'M' to mute music", 24, 512 * 2/3)
  end]]
  
  rs.stop()

  if paused then
    u:draw()
  end

end