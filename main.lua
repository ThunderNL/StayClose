sti = require "sti"
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
randomSide = 1
playerTarget = playerred
lives = 5
score = 0

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
  map = sti("assets/map.lua")
  playerredImg = love.graphics.newImage("assets/spritered.png")
  playerblueImg = love.graphics.newImage("assets/spriteblue.png")
  enemyImg = love.graphics.newImage("assets/enemy.png")
  love.graphics.setLineWidth(2)
  math.randomseed(os.time())
  smallfont = love.graphics.newFont("assets/font.ttf", 16)
  bigfont = love.graphics.newFont("assets/font.ttf", 32)
end




function love.update(dt)
  map:update(dt)
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
  enemy.x = 256
  enemy.y = 16
elseif randomSide == 2 then
  enemy.x = 480
  enemy.y = 256
elseif randomSide == 3 then
  enemy.x = 256
  enemy.y = 480
elseif randomSide == 4 then
  enemy.x = 16
  enemy.y = 256
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
    table.remove(enemy, i)
    lives = lives - 1
  elseif checkCircularCollision(newEnemy.x+8, newEnemy.y+8, playerblue.x+8, playerblue.y+8, 8, 8) then
    table.remove(enemy, i)
    lives = lives - 1
  end
  
    if LineCollision(playerred.x, playerred.y, playerblue.x, playerblue.y, newEnemy.x, newEnemy.y) == true then
      table.remove(enemy, i)
      score = score + 1
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
end

end

function love.draw(dt)
  love.graphics.setColor(darkness,darkness,darkness)
  map:draw()
  love.graphics.setColor(0,0,0)
  love.graphics.line(playerred.x+8, playerred.y+8, playerblue.x+8, playerblue.y+8)
  love.graphics.setColor(darkness,darkness,darkness)
  
  love.graphics.draw(playerredImg, playerred.x, playerred.y)
  love.graphics.draw(playerblueImg, playerblue.x, playerblue.y)
  for i, newEnemy in ipairs(enemy) do
    love.graphics.draw(enemyImg, newEnemy.x, newEnemy.y)
  end
  
  love.graphics.setColor(1,1,1)
  love.graphics.setFont(smallfont)
  love.graphics.print("Score: "..score, 32)
  love.graphics.print("Lives: "..lives, 384)
  if lives < 1 then
    love.graphics.setFont(bigfont)
    love.graphics.print("Press 'R' to restart", 24, 218)
    love.graphics.print("Score: "..score, 24, 256)
  end
end