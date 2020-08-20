local MyAddon = LibStub("AceAddon-3.0"):NewAddon("LateComer", "AceConsole-3.0")
local MyConsole = LibStub("AceConsole-3.0")
local icon = LibStub("LibDBIcon-1.0")

local db = {players = {}, realm = {}, lookup = {}, lookupConfig = {}}
local cache = {data = {}, length = 0}
local player = {}
local level120 = 120
_G.LateComer = {
	db = db,
	cache = cache,
	player = player
}

-- GUID
_G.LateComer.player.guid = UnitGUID("player")
_G.LateComer.player.name = UnitFullName('player')
_G.LateComer.player.realmid = GetRealmID()
_G.LateComer.player.realmName = GetRealmName()
_G.LateComer.player.class = UnitClass("player")
_G.LateComer.player.race = UnitRace("player")
_G.LateComer.player.factionGroup, _G.LateComer.player.factionGroupName = UnitFactionGroup("player")
_G.LateComer.player.level = UnitLevel("player")
-- MyAddon:Print(test, UnitFullName('player'), GetRealmID(), GetRealmName(), UnitFactionGroup("player"))

function db:addPlayers(data)
	if _G.LateComer.player.factionGroup == data.type then
		db.players = data.data
		db.realm = data.realm
	end
end

function db:addLookup(data) 
	if _G.LateComer.player.factionGroup == data.type then
		db.lookup[1]= data.data[1]
	end
end

-- return  nil or {}
function db:getMythticsByName(realm, name)
	if realm == nil or name == nil then
		return
	end
	--getFromCache
	local playersData =  nil 

	playersData = _G.LateComer.cache:getByName(realm.."-"..name)

	if playersData ~= nil then
		return playersData
	end

	--getNums by negion and name
	local realmNums = self:getRegionNums(realm)

	if realmNums == nil then
		return nil
	end

	local realmIndex = self:getIndexByNanme(realm, name)
	if realmIndex == nil then
		return nil
	end

	--unpackData()
	playersData = self:unpackData(realmNums, realmIndex)
	-- cache
	_G.LateComer.cache:add(realm.."-"..name, playersData)
	return playersData
end

function  db:unpackData(realmNums, realmIndex) 
	-- get chunk
	local chunk = 36
	local index = (realmNums +  realmIndex - 1) * chunk + 1

	local bytes = {strbyte(_G.LateComer.db.lookup[1], index, index + chunk -1)}
	local testBytes = {strbyte(_G.LateComer.db.lookup[1], 1, 32)}
	-- parse chunk
	local data = {season = {}, weekly = {}}
	
	local i = 1
	local key = 1

	while (i <= 36) do

		local mythics = ""
		if bytes[i] ~= 0 and bytes[i+1] ~= 0  then 	
			mythics = {}
			mythics.plus = bit.rshift(bytes[i], 6) 
			mythics.level = bit.band(bytes[i], 63)
			if(i < 24)  then
				mythics.affixs = bytes[i+1] 
			end
		end

		if i <= 24 then 
			data.season[key] = mythics
			i = i + 2
		else
			data.weekly[key-12] = mythics
			i = i + 1
		end
		
		key = key + 1
	end

	return data	
end

function db:getRegionNums(realm)

	if _G.LateComer.db.realm == nil then
		return nil
	end
	local counter = 0
	for i,v in pairs(_G.LateComer.db.realm) do

		if i == realm then
			return counter
		end
		counter = counter + v
	end

	return nil
end

function db:getIndexByNanme(realm, name)
	local min = 1
	local max = self.realm[realm]
	local players= self.players[realm]

	while min <= max do
		local mid = floor((max + min) / 2)
		local current = players[mid]
		if current == name then
			return mid
		elseif current < name then
			min = mid + 1
		else 
			max = mid - 1
		end
	end
	return  nil
end

function cache:add(name, data)
	--justcache 1000
	if _G.LateComer.cache.length < 1000 then
		_G.LateComer.cache.data[name] = data
		_G.LateComer.cache.length = _G.LateComer.cache.length + 1
	end
end

function cache:getByName(name)
	if _G.LateComer.cache.length > 0 then
		for k,v in pairs(_G.LateComer.cache.data) do
			if k == name then
				return v
			end
		end
	end
end

function cache:clean()
	_G.cache.data = {}
end

function player:selfData()

	local data = {}
	-- playerMythics
	data['name'] 	= _G.LateComer.player.name
	data['realm'] 	= _G.LateComer.player.realmName
	data['guid'] 	= _G.LateComer.player.guid
	data['type'] 	= _G.LateComer.player.factionGroup
	data['race'] 	= _G.LateComer.player.race
	data['class'] 	= _G.LateComer.player.class
	-- season 
	
	local season 	= api:getPlayerSeasonMythicPlus()
	data['season'] 	= api:seasonData(season)
	-- week
	local weekly 	= api:getPlayerWeeklyMythicPlus()
	data['weekly'] 	= api:weeklyData(weekly)
	data['code'] 	= api:confusion(season,weekly) 
	return data
end

function player:draw()

	local data = { season = {}, weekly = {}}
	data.season = api:getPlayerSeasonMythicPlus()
	data.weekly = api:getPlayerWeeklyMythicPlus()
	-- local data = cache:getByName(_G.LateComer.player.realmName.."-".._G.LateComer.player.name)
	LateComerUI:drawPerson(
		_G.LateComer.player.realmName, 
		_G.LateComer.player.name, 
		data, 
		LateComerUI.infoList["info1"])
end

local double = false
local function doubleClick()
	double = not(double)
	if not(double) == true then 
		LateComerUI.mainFrame:Hide()
		return 
	end
	LateComerUI.mainFrame:Show()
	LateComerUI:drawParty()
end 

local miniMapButton = LibStub("LibDataBroker-1.1"):NewDataObject("LC", {
    type = "data source",
    text = "LateComer",
    icon = "Interface\\Icons\\70_inscription_vantus_rune_light",
    OnClick = doubleClick,
    OnTooltipShow = function(tooltip)
		tooltip:AddLine("小队面板")
		tooltip:Show()
	end
})
local db = { hide = false}
icon:Register("LateComerMiniMapButton", miniMapButton, db)


LateComerUI:mainFrame()
LateComerUI:createLGFUI()

function MyAddon:newEvent(frame, func, event)
	for k,v in pairs(event) do
		frame:RegisterEvent(v)
	end
	frame:SetScript("OnEvent", func)
end

--main loade
local loadLisetener = CreateFrame('Frame', 'Listener')
local function mainLoad(self, event, ...)

end

MyAddon:newEvent(loadLisetener, mainLoad, {"ADDON_LOADED"})

-- queer  firstStep(?>初始化数据是错误的) --- saveValue   
local firstStep= CreateFrame("Frame")
local function eventMoving(self, event, ...)
	-- local activityInfo = C_LFGList.GetActiveEntryInfo()
	firstStep:UnregisterEvent("PLAYER_STARTED_MOVING")
	LateComer.player:draw()
	if( UnitLevel("player") == level120) then
		LateComerSaveData = LateComer.player:selfData()
	end
end
MyAddon:newEvent(firstStep, eventMoving, {"PLAYER_STARTED_MOVING"})

-- Group change
local groupframe= CreateFrame("Frame")
local function groupChange(self, event, ...)
	LateComerUI:drawParty()
end
MyAddon:newEvent(groupframe, groupChange, {"GROUP_ROSTER_UPDATE"})


--hook
hooksecurefunc(GameTooltip,"SetText",function(self,name)
	local owner, owner_name = self:GetOwner()
	if owner then
		owner_name = owner:GetName()
		if not owner_name then
			owner_name = owner:GetDebugName()
		end
	end
	
	-- GroupFinder > ApplicantViewer > Tooltip
	if owner_name then
		if owner_name:find("^LFGListApplicationViewerScrollFrameButton") then
			playerName, playerRealm = strsplit("-", name)
			LateComerUI:refreshLGFUI(playerRealm, playerName)
		end
	end
end)

hooksecurefunc(GameTooltip,"AddLine",function(self,text) -- GameTooltip_AddColoredLine
	local owner, owner_name = self:GetOwner()

	local _LFG_LIST_TOOLTIP_LEADER = gsub(LFG_LIST_TOOLTIP_LEADER,"%%s","(.+)")
	if owner then
		owner_name = owner:GetName()
		if not owner_name then
			owner_name = owner:GetDebugName()
		end
	end
	local hide = true
	if owner_name then
		if owner_name:find("^LFGListSearchPanelScrollFrameButton") then -- GroupFinder > SearchResult > Tooltip
			local leaderName = text:match(_LFG_LIST_TOOLTIP_LEADER)
			if leaderName then

				playerName, playerRealm = strsplit("-", leaderName)
				if playerName and playerRealm then
					LateComerUI:refreshLGFUI(playerRealm, playerName)
					hide = false
				end
			end
		elseif owner_name:find("^QuickJoinScrollFrameButton") and owner.entry and owner.entry.guid then
			local leader = text:match(LFG_LIST_TOOLTIP_LEADER:gsub("%%s","(.*)"));
			if leader then
				playerName, playerRealm = strsplit("-", leader)
				LateComerUI:refreshLGFUI(playerRealm, playerName)
				hide = false
			end
		end
	end
end)

