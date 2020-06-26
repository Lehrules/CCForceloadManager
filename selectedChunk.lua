os.loadAPI("API/json")
local tArgs = {...}
print(table.concat(tArgs))
local menu_options = { --This is our menu table. It contains basic data about the menu
  [1] = {text= tArgs[1], color = colors.magenta},
  [2] = {text="Generate Waypoint", color=colors.blue},
  [3] = {text="Remove Chunk from Forceload", color = colors.red}
}
local termX, termY = term.getSize() --The x/y size of the terminal
local function menuDraw(selected) --Our main draw function
  local yPos = termY/2 - #menu_options/2 --The initial y position
  for index, data in pairs(menu_options) do
    menu_options[index].bounds = { --Create a new table in each option with the boundary data
      x1 = termX/2 - (#data.text+4)/2;
      x2 = termX/2 + (#data.text+4)/2;
      y = yPos;
    }
    term.setTextColor(data.color)
    term.setCursorPos(data.bounds.x1, data.bounds.y)

    local text =
      index==selected and "[ "..data.text.." ]" or
      "  "..data.text.."  " --Essentially an if statement, but in a contracted form
    term.write(text)
    yPos = yPos+1 --Increment the initial y pos so we can move on the next line
  end
end

local function checkClick(x,y) --Check the mouse click to see if there's a menu option
  for index, data in pairs(menu_options) do
    if x>= data.bounds.x1 and x<= data.bounds.x2 and y==data.bounds.y then
      return index --Returns the index of the clicked option
    end
  end
  return false --If it went through the entire for loop without success, return false
end
local function reset()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
end


reset()

local selector = 1 --Our selector
while true do --The main loop. I would generally put this inside of a function for a program.
  menuDraw(selector) --Draw the menu first
  local e = {os.pullEvent()} --Pull an event and put the returned values into a table
  if e[1] == "key" then --If it's a key...
    if e[2] == keys.down then -- ... and it's the down arrow
      selector = selector < #menu_options and selector+1 or 1 --Increment the selector if the selector < #menu_options. Otherwise reset it to 1
    elseif e[2] == keys.up then
      selector = selector > 1 and selector-1 or #menu_options --Decrement the selector if the selector > 1. Otherwise, reset it to #menu_options
    elseif e[2] == keys.enter then
      break --Break out of the loop
    end
  elseif e[1] == "mouse_click" then
    local value = checkClick(e[3], e[4]) --Check the mouse click
    if value then --If checkClick returns a value and not false
      selector = value --Set the selector to that value and break out of the loop
      break
    end
  end
end

local jsonWaypoint = json.decodeFromFile("waypoints/"..tArgs[1])
--print(json.encodePretty(jsonWaypoint))

if (selector == 2) then
    local tmplt ='[name:"'..jsonWaypoint.name..'", x:'..jsonWaypoint.x..", z:"..jsonWaypoint.z.."]"
    commands.say(tmplt)
    shell.run('chunkMenu')
end

if (selector == 3) then
    commands.forceload.remove(jsonWaypoint.x,jsonWaypoint.z)
    reset()
    print("Removed "..jsonWaypoint.name.." from force loading.")
    print("Don't forget to remove your waypoints.")
    sleep(2)
    shell.run('menu')
end