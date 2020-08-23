local AceGUI = LibStub("AceGUI-3.0")
local console = LibStub("AceConsole-3.0")

LateComerUI = {}
local dropStyle = { 
	  bgFile = "bgFile", 
	  edgeFile = "edgeFile",
	  tile = false, 
	  tileEdge = true, 
	  tileSize = 0, 
	  edgeSize = 4, 
	  insets = { left = 1, right = 1, top = 1, bottom = 1 }}

local f25 = 25
local f20 = 20
local f18 = 18
local f17 = 17
local f16 = 16
local f15 = 15
local f14 = 14
local f13 = 13
local f12 = 12
local f11 = 11
local f10 = 10
local f9 = 9

local UI_head = 30
local UI_name = 23
local UI_title = 20
local MES_overlimit = "|cff696969无限时"
local MES_week 		= "|cff66CD00本周"
local MES_season 	= "|cffFFB90F赛季"
local MES_dev 		= "|cff00BFFF开发者"

function LateComerUI.mainFrame()

    local mainFrame = CreateFrame("Frame", "LateComer", UIParent)
    LateComerUI.mainFrame = mainFrame

	mainFrame:SetMovable(true)
	mainFrame:EnableMouse(true)

	mainFrame:SetFrameLevel(5)
    mainFrame:SetSize(1410, 560)
    mainFrame:SetFrameStrata("BACKGROUND")
    mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	mainFrame:SetBackdrop(dropStyle);
	LateComerUI:setFrameBackStyle(mainFrame)

    -- Title
    local title = CreateFrame("Frame", "L_Title", mainFrame)
    title:SetPoint("TOP", mainFrame, "TOP", 0, 40)
    title:SetSize(100, 40)
    title:SetBackdrop(dropStyle)
	LateComerUI:setFrameBackStyle(title)
    title.text = LateComerUI:setFrameText("赛季 - 本周",f18, title, "CENTER", "CENTER", 0, 0)
	title.text:SetTextColor( 255, 97, 0, 1)
    mainFrame.title = title
    -- --------------------
    -- Close Btn
    local btn = CreateFrame("Frame", "L_btnClose", mainFrame)
    btn:SetSize(120, 35)
    btn:SetPoint("BOTTOM", mainFrame, "BOTTOM", 200, 20)
    btn:SetBackdrop(dropStyle)
	LateComerUI:setFrameBackStyle(btn)
    btn.text = LateComerUI:setFrameText( "关闭",19, btn, "CENTER", "CENTER", 0, 0)
    btn.text:SetTextColor(0.8, 0.8, 0.8, 1)
    -- btnClose:EnableMouse(true)
    btn:SetScript("OnMouseUp", function(self) self:GetParent():Hide() end)
    mainFrame.btnClose = btn

    local btn = CreateFrame("Frame", "L_btnRefresh", mainFrame)
    btn:SetSize(120, 35)
    btn:SetPoint("BOTTOM", mainFrame, "BOTTOM", -200, 20)
    btn:SetBackdrop(dropStyle)
	LateComerUI:setFrameBackStyle(btn)
    btn.text = LateComerUI:setFrameText( "刷新",19, btn, "CENTER", "CENTER", 0, 0)
    btn.text:SetTextColor(0.8, 0.8, 0.8, 1)
    -- btnClose:EnableMouse(true)
    btn:SetScript("OnMouseUp", function() LateComerUI:drawParty() end)
    mainFrame.btnRefresh = btn

	LateComerUI.infoList = {}
  	for i = 1, 5, 1 do
	    LateComerUI.infoList["info"..i] = LateComerUI:createPersonFrame(mainFrame,  10 + (i-1) * 280, -10 )	
  	end

  	mainFrame:Hide()
end

function LateComerUI:createPersonFrame(frame, x, y)
	local mainFrame = CreateFrame("Frame", "L_Info", frame)
    mainFrame:SetSize(270, 490)
  	mainFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
  	mainFrame:SetBackdrop(dropStyle)
	LateComerUI:setFrameBackStyle(mainFrame)
-- 	name
	mainFrame.realmName = LateComerUI:createFrameText(f18, mainFrame, "TOP", "TOP", 0, -10)
	mainFrame.sign = LateComerUI:createFrameText(f18, mainFrame, "TOP", "TOP", -100, -10)

-- 	--season
	LateComerUI:setFrameText(MES_season, f18, mainFrame, "TOPLEFT", "TOPLEFT", 15,  -27 )
	local season = {}
	local dungeonList = api:dungeonList()
	
	for i=1, 12, 1 do
		local tempObj = {}
		local ofy = 200 - f16 * i
		LateComerUI:setFrameText(dungeonList[i],f14, mainFrame, "LEFT", "LEFT", 5, ofy )
		tempObj.limit = LateComerUI:createFrameText(f14, mainFrame, "LEFT", "LEFT", 110, ofy )
		tempObj.affixs =  LateComerUI:createAffixFrame(mainFrame, 145, ofy, 18, 18) 
		tempObj.overLimit = LateComerUI:createFrameText(f14, mainFrame, "RIGHT", "RIGHT", 0, ofy )
		season[i] = tempObj		
	end
	mainFrame.season = season

	--weekly
	LateComerUI:setFrameText(MES_week, f18, mainFrame, "LEFT", "LEFT", 15,  -20)
	local weekly = {}
	for i=1, 12, 1 do
		local tempObj = {}
		local ofy =  -30 - f16 * i
		LateComerUI:setFrameText(dungeonList[i],f14, mainFrame, "LEFT", "LEFT", 5, ofy )
		tempObj.limit = LateComerUI:createFrameText(f14, mainFrame, "LEFT", "LEFT", 110,  ofy )
		tempObj.overLimit = LateComerUI:createFrameText(f14, mainFrame, "RIGHT", "RIGHT", 0,  ofy )
		weekly[i] = tempObj		
	end
	mainFrame.weekly = weekly
	mainFrame:Hide()

	return mainFrame
end

-- party
function LateComerUI:drawParty()
	local party = {"player","party1", "party2", "party3", "party4" }
	for k,v in pairs(party) do
		repeat
		if UnitExists(v) then
				if k == 1 then
					LateComer.player:draw()
					break
				end

				local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(UnitGUID(v))
				if (realm == "") then
					break
				else
					local data = LateComer.db:getMythticsByName(realm, name)
					if( data ~= nil) then
						LateComerUI:drawPerson(realm, name, data, LateComerUI.infoList["info"..k])
					else 
						LateComerUI.infoList["info"..k]:Hide()
					end
				end 
		end
		until true
	end
end

--person
function LateComerUI:drawPerson(realm, name, data, frame)
	--name
    frame.realmName:SetText(name..'    '..realm )

    if LateComerUI:checkDev(name..realm) then
    	frame.sign:SetText(MES_dev)
    end
	-- season
	for k,v in ipairs(data.season) do
		if v == "" then 
			frame.season[k].overLimit:SetText(MES_overlimit)
			for i =1, 4, 1 do 
				frame.season[k].affixs[i]:Hide()
			end
		else
			--limit
			local levelColor = api:getLevelColor(v.level)

			local plusColor = api:getPlusColor(v.plus)
			local str = levelColor..v.level .." |r"..plusColor.." +".. v.plus
			frame.season[k].limit:SetText(str)

			--affix
			local affixs = api.affixLookUP[api:getAffixByIndex(v.affixs)]
			for i =1, 3, 1 do 
				frame.season[k].affixs[i]:SetUp(affixs[i])
			end

			if v.level >= 10 then
				frame.season[k].affixs[4]:SetUp(api.affixSeaon)
			else
				frame.season[k].affixs[4]:Hide()
			end
		end
	end

    -- weekly
	for k,v in ipairs(data.weekly) do
		if v == "" then 
			frame.weekly[k].overLimit:SetText(MES_overlimit)
		else
			--limit
			local levelColor = api:getLevelColor(v.level)
			local plusColor = api:getPlusColor(v.plus)
			local str = levelColor..v.level .." |r"..plusColor.." +".. v.plus
			frame.weekly[k].limit:SetText(str)
		end
	end
	frame:Show()
end

function LateComerUI:createLGFUI()
	
	local mainFrame = CreateFrame("Frame", nil, UIParent)
    LateComerUI.lgfFrame = mainFrame

	mainFrame:SetFrameLevel(10)
	mainFrame:SetSize(280, 400)
    mainFrame:SetFrameStrata("BACKGROUND")
    mainFrame:SetPoint("right", "PVEFrame", "right", 290, 0)
	mainFrame:SetBackdrop(dropStyle);
	LateComerUI:setFrameBackStyle(mainFrame)

	-- Close Btn
    local btn = CreateFrame("Frame", "LGF_btnClose", mainFrame)
    btn:SetSize(80, 18)
    btn:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 10)
    btn:SetBackdrop(dropStyle)
	LateComerUI:setFrameBackStyle(btn)
    btn.text = LateComerUI:setFrameText( "关闭",f11, btn, "CENTER", "CENTER", 0, 0)
    btn.text:SetTextColor(0.8, 0.8, 0.8, 1)
    -- btnClose:EnableMouse(true)
    btn:SetScript("OnMouseUp", function(self) self:GetParent():Hide() end)
    mainFrame.btnClose = btn

	mainFrame.realmName = LateComerUI:createFrameText(f14, mainFrame, "CENTER", "TOP", 0, -20)
	mainFrame.sign = LateComerUI:createFrameText(f14, mainFrame, "CENTER", "TOP", -80, -20)

	LateComerUI:setFrameText(MES_season, f12, mainFrame, "TOPLEFT", "TOPLEFT", 15,  -30)
	local season = {}
	local dungeonList = api:dungeonListShort()
	
	for i=1, 12, 1 do
		local tempObj = {}
		local ofy = 160 - f12 * i
		LateComerUI:setFrameText(dungeonList[i],f13, mainFrame, "LEFT", "LEFT", 15, ofy )
		tempObj.limit = LateComerUI:createFrameText(f13, mainFrame, "LEFT", "LEFT", 110, ofy )
		tempObj.affixs =  LateComerUI:createAffixFrame(mainFrame, 145, ofy, 13, 13) 
		tempObj.overLimit = LateComerUI:createFrameText(f13, mainFrame, "RIGHT", "RIGHT", 0, ofy )
		season[i] = tempObj		
	end
	mainFrame.season = season


	LateComerUI:setFrameText(MES_week, f12, mainFrame, "LEFT", "LEFT", 15,  -10)
	local weekly = {}
	for i=1, 12, 1 do
		local tempObj = {}
		local ofy =  -10 - f12* i
		LateComerUI:setFrameText(dungeonList[i],f13, mainFrame, "LEFT", "LEFT", 15, ofy )
		tempObj.limit = LateComerUI:createFrameText(f13, mainFrame, "LEFT", "LEFT", 110,  ofy )
		tempObj.overLimit = LateComerUI:createFrameText(f13, mainFrame, "RIGHT", "RIGHT", 0,  ofy )
		weekly[i] = tempObj		
	end
	mainFrame.weekly = weekly

	mainFrame:EnableMouse(true)
	mainFrame:SetMovable(true)
	mainFrame:RegisterForDrag("LeftButton")
	mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end )
	mainFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end )
	mainFrame:SetScript("OnMouseDown", function(self) self:SetClampedToScreen(true) end)
	mainFrame:Hide()
end

function LateComerUI:refreshLGFUI(realm, name)
	local data = LateComer.db:getMythticsByName(realm, name)
	local lgfFrame = LateComerUI.lgfFrame
	if( data == nil) then
		lgfFrame:Hide()
	else
		--name
	    lgfFrame.realmName:SetText(name..'  '..realm )

	    if LateComerUI:checkDev(name..realm) then
	    	lgfFrame.sign:SetText(MES_dev)
	    end

		-- season
		for k,v in ipairs(data.season) do
			if v == "" then 
				lgfFrame.season[k].overLimit:SetText(MES_overlimit)
				for i =1, 4, 1 do 
					lgfFrame.season[k].affixs[i]:Hide()
				end
			else
				--limit

				local levelColor = api:getLevelColor(v.level)

				local plusColor = api:getPlusColor(v.plus)
				local str = levelColor..v.level .." |r"..plusColor.." +".. v.plus
				lgfFrame.season[k].limit:SetText(str)

				--affix
				local affixs = api.affixLookUP[api:getAffixByIndex(v.affixs)]
				for i =1, 3, 1 do 
					lgfFrame.season[k].affixs[i]:SetUp(affixs[i])
				end

				if v.level >= 10 then
					lgfFrame.season[k].affixs[4]:SetUp(api.affixSeaon)
				else
					lgfFrame.season[k].affixs[4]:Hide()
				end
			end
		end

	    -- weekly
		for k,v in ipairs(data.weekly) do
			if v == "" then 
				lgfFrame.weekly[k].overLimit:SetText(MES_overlimit)
			else
				--limit
				local levelColor = api:getLevelColor(v.level)
				local plusColor = api:getPlusColor(v.plus)
				local str = levelColor..v.level .." |r"..plusColor.." +".. v.plus
				lgfFrame.weekly[k].limit:SetText(str)
			end
		end
		-- lgfFrame:StartMoving()
		lgfFrame:Show()
	end
end

function LateComerUI:checkDev(str)
	if str == '迟到布兰卡德' or str == "一休宗純海克泰尔" then 
		return true
	end
end
function LateComerUI:hideLGUFUI() 
	LateComerUI.lgfFrame:Hide()
end

-- affix
function LateComerUI:createAffixFrame(frame, ofx, ofy, width, hight) 
	local affixObj = {}
	for i = 1, 4, 1 do 
		local affix = CreateFrame("Frame", nil, frame)
		affix:SetSize(width, hight)
		local border = affix:CreateTexture(nil, "OVERLAY")
		border:SetAllPoints()
		border:SetAtlas("ChallengeMode-AffixRing-Sm")
		affix.Border = border

		local portrait = affix:CreateTexture(nil, "ARTWORK")
		portrait:SetSize(width, hight)
		portrait:SetPoint("CENTER", border)
		affix.Portrait = portrait
		affix.SetUp = ScenarioChallengeModeAffixMixin.SetUp
		affix:SetPoint("LEFT",frame,"LEFT", ofx + width * i, ofy)
		-- affix:Hide()
		affixObj[i] = affix
	end

	return affixObj
end


function LateComerUI:setFrameText(text, size, frame, point, relativePoint, ofsx, ofsy)
	local fText = frame:CreateFontString(nil, "OVERLAY")
	fText:SetFont("Interface\\Addons\\LateComer\\resource\\font.TTF", size, "THINOUTLINE") 
    fText:SetText(text)
    fText:SetPoint(point, frame, relativePoint, ofsx, ofsy)
    return fText
end

function LateComerUI:createFrameText(size, frame, point, relativePoint, ofsx, ofsy)
	local fText = frame:CreateFontString(nil, "OVERLAY")
	fText:SetFont("Interface\\Addons\\LateComer\\resource\\font.TTF", size, "THINOUTLINE") 
    fText:SetPoint(point, frame, relativePoint, ofsx, ofsy)
    return fText
end
function LateComerUI:createFrameTextSign(size, frame, point, relativePoint, ofsx, ofsy)
	local fText = frame:CreateFontString(nil, "OVERLAY")
	fText:SetFont("Interface\\Addons\\LateComer\\resource\\font.TTF", size, "THINOUTLINE") 
    fText:SetPoint(point, frame, relativePoint, ofsx, ofsy)
    return fText
end

function LateComerUI:setFrameBackStyle(frame)
	frame:SetBackdropColor(0, 0, 0, 0.7)
    frame:SetBackdropBorderColor( 0, 0, 0, 1)
end

function LateComerUI:setFrameInfoStyle(frame)
	frame:SetBackdropColor(25, 26, 20, 0.7)
    frame:SetBackdropBorderColor( 0, 0, 0, 1)
end


