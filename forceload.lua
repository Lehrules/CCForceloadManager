os.loadAPI("API/json")
jsonTemplate = json.decodeFromFile("waypoints/template.json")
local function query()
    local matchstr = '%[(.-%]*)%]'
    local pass, resp, numLoaded = commands.exec("forceload query")
    local respString = textutils.serialise(resp)
    local chunkCoords = {} 
    local coords = {}
    for i in string.gmatch(respString, matchstr) do
        local x = {}
        local xCenter = {}
        for word in string.gmatch(i, '([^,]+)') do
            table.insert(x, tonumber(word))
            table.insert(xCenter, (tonumber(word)*16)+7)
        end
        table.insert(coords, xCenter)        
        table.insert(chunkCoords, x) 
    end
    return chunkCoords, coords
end

local function waypointSay(XZ,name)
    local tmplt ='[name:"'..name..'", x:'..XZ[1]..", z:"..XZ[2].."]"
    commands.say(tmplt)
end
local function makeJson(XZ,name)
    local tempJson = jsonTemplate
    tempJson.x = XZ[1]
    tempJson.z = XZ[2]
    tempJson.name = name
    tempJson.id = name.."_"..XZ[1]..","..tempJson.y..","..XZ[2]
    return tempJson
end
local function saveJson(jsonObj, path)
    local encodedJson = json.encode(jsonObj)
    local fileName = jsonObj.id..".json"
    local file = fs.open(path.."/"..fileName, "w")
    file.write(encodedJson)
    file.close()
end


chunks, regCoords = query()
chunksString = textutils.serialize(chunks)
coordsString = textutils.serialize(regCoords)

existPoints = fs.list("waypoints/")
for _, i in ipairs(existPoints) do
    --print(i)
    if not (i == "template.json") then
        fs.delete("/waypoints/"..i)
    end
end

for i=1, #regCoords do
    local currPoint = makeJson(regCoords[i], "Forceload"..i)
    saveJson(currPoint, "waypoints/") 
end

print("Saved "..#regCoords.." waypoints to /waypoints/")

