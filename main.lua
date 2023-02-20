denver = require 'denver'
rs = require 'resolution_solution'
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
enemy.speed = 50
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
lives = 5
score = 0
highscore = 0
gameOver = false
particleTimer = 1000

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

function love.load()
  map = love.graphics.newImage("assets/map.png")
  playerredImg = love.graphics.newImage("assets/spritered.png")
  playerblueImg = love.graphics.newImage("assets/spriteblue.png")
  enemyImg = love.graphics.newImage("assets/enemy.png")
  
  particlered = love.graphics.newImage("assets/particlered.png")
  particleblue = love.graphics.newImage("assets/particleblue.png")
  particleenemy = love.graphics.newImage("assets/particleenemy.png")
  redsystem = love.graphics.newParticleSystem(particlered, 10)
  bluesystem = love.graphics.newParticleSystem(particleblue, 10)
  enemysystem = love.graphics.newParticleSystem(particleenemy, 10)
  redsystem:setParticleLifetime(1, 5)
  bluesystem:setParticleLifetime(1, 5)
  enemysystem:setParticleLifetime(1, 5)
	redsystem:setEmissionRate(50)
	bluesystem:setEmissionRate(50)
	enemysystem:setEmissionRate(50)
	redsystem:setLinearAcceleration(-10, -10, 10, 10)
	bluesystem:setLinearAcceleration(-10, -10, 10, 10)
	enemysystem:setLinearAcceleration(-10, -10, 10, 10)
  
  love.graphics.setLineWidth(2)
  math.randomseed(os.time())
  smallfont = love.graphics.newFont("assets/font.ttf", 16)
  bigfont = love.graphics.newFont("assets/font.ttf", 32)
  
  rs.init({width = 512, height = 512, mode = 1})
  rs.setMode(512, 512, {resizable = true})
end




function love.update(dt)
	redsystem:update(dt)
	bluesystem:update(dt)
	enemysystem:update(dt)
  
  love.resize = function(w, h)
  rs.resize(w, h)
  end
  
  enemytimer = enemytimer - 1 * dt
if lives > 0 then
  if love.keyboard.isDown('w') and playerred.y > 16 then
     playerred.y = playerred.y - (playerred.speed * dt)
  end
  if love.keyboard.isDown('s') and playerred.y < 480 then
     playerred.y = playerred.y + (playerred.speed * dt)
  end
  if love.keyboard.isDown('a') and playerred.x > 16 then
     playerred.x = playerred.x - (playerred.speed * dt)
  end
  if love.keyboard.isDown('d') and playerred.x < 480 then
  playerred.x = playerred.x + (playerred.speed * dt)
end

  if love.keyboard.isDown('up') and playerblue.y > 16 then
     playerblue.y = playerblue.y - (playerblue.speed * dt)
  end
  if love.keyboard.isDown('down') and playerblue.y < 480 then
     playerblue.y = playerblue.y + (playerblue.speed * dt)
  end
  if love.keyboard.isDown('left') and playerblue.x > 16 then
     playerblue.x = playerblue.x - (playerblue.speed * dt)
  end
  if love.keyboard.isDown('right') and playerblue.x < 480 then
  playerblue.x = playerblue.x + (playerblue.speed * dt)
end
end

distance = math.dist(playerred.x,playerred.y, playerblue.x,playerblue.y)
darkness = (distance/256*-1)+1



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
  
    if LineCollision(playerred.x, playerred.y, playerblue.x, playerblue.y, newEnemy.x, newEnemy.y) == true then
      newParticle = {x = newEnemy.x, y = newEnemy.y, timer = particleTimer}
      table.insert(enemyparticles, newParticle)
      table.remove(enemy, i)
      score = score + 1
      if math.random(1,10) == 1 then
        lives = lives + 1
      end
      local sound = denver.get({waveform='sinus', frequency=660, length=0.2})
      local sound2 = denver.get({waveform='sinus', frequency=330, length=0.4})
      love.audio.play(sound, sound2)
    end
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

 if lives < 1 and love.keyboard.isDown('r') then
  enemy= {}
  enemy.speed = 50
  lives = 5
  playerred.x = 240
  playerred.y =240
  playerblue.x = 272
  playerblue.y =272
  enemytimer = enemytimerMax
  gameOver = false
  score = 0
end

if lives < 1 and gameOver == false then
  if score > highscore then
    highscore = score
  end
  local noise = denver.get({waveform='whitenoise', length=1})
  love.audio.play(noise)
  gameOver = true
end


end

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
  love.graphics.setFont(smallfont)
  love.graphics.print("Score: "..score, 32)
  love.graphics.print("Lives: "..lives, 384)
  if lives < 1 then
    love.graphics.setFont(bigfont)
    love.graphics.print("Press 'R' to restart", 24, 218)
    love.graphics.print("Score: "..score, 24, 256)
    love.graphics.print("Highscore: "..highscore, 24, 294)
  end
  rs.stop()
end