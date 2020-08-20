local console = LibStub("AceConsole-3.0")

-- dungeon list 
local dungeonIdNameList = {
    [244] = "阿塔达萨",
    [245] = "自由镇",
    [246] = "托儿达戈",
    [247] = "暴富矿区",
    [248] = "维克雷斯庄园",
    [249] = "诸王之眠",
    [250] = "塞塔利斯神庙",
    [251] = "地渊孢林",
    [252] = "风暴神殿",
    [353] = "围攻伯拉勒斯",
    [370] = "麦卡贡-车间",
    [369] = "麦卡贡-垃圾场",
}

local dungeonIdList = {
    244,
    245,
    246,
    247,
    248,
    249,
    250,
    251,
    252,
    353,
    370,
    369,
}
-- 词缀 循环
local affixScheduleText = {
    {"Fortified",   "Bolstering",   "Grievous"},
    {"Tyrannical",  "Raging",   "Explosive"},
    {"Fortified",   "Sanguine", "Grievous"},
    {"Tyrannical",  "Teeming",  "Volcanic"},
    {"Fortified",   "Bolstering",   "Skittish"},
    {"Tyrannical",  "Bursting", "Necrotic"},
    {"Fortified",   "Sanguine", "Quaking"},
    {"Tyrannical",  "Bolstering",   "Explosive"},
    {"Fortified",   "Bursting", "Volcanic"},
    {"Tyrannical",  "Raging",   "Necrotic"},
    {"Fortified",   "Teeming",  "Quaking"},
    {"Tyrannical",  "Bursting", "Skittish"}
}

local  affixLookUP = {
    ["10712"]   = {10, 7, 12},
    ["9613"]    = {9, 6, 13},
    ["10812"]   = {10, 8, 12},
    ["953"]     = {9, 5, 3},
    ["1072"]    = {10, 7, 2},
    ["9114"]    = {9, 11, 4},
    ["10814"]   = {10,  8, 14},
    ["9713"]    = {9, 7, 13},
    ["10113"]   = {10, 11, 3},
    ["964"]     = {9, 6, 4},
    ["10514"]   = {10, 5, 14},
    ["9112"]    = {9,11, 2},
}

local  affixIndex = {
    "10712",
    "9613",
    "10812",
    "953",
    "1072",
    "9114",
    "10814",
    "9713",
    "10113",
    "964",
    "10514",
    "9112",
}

-- 词缀 id
local affixScheduleKeys = {
    ["Overflowing"] = 1, 
    ["Skittish"]    = 2, 
    ["Volcanic"]    = 3,
    ["Necrotic"]    = 4, 
    ["Teeming"]     = 5,
    ["Raging"]      = 6, 
    ["Bolstering"]  = 7,
    ["Sanguine"]    = 8, 
    ["Tyrannical"]  = 9, 
    ["Fortified"]   = 10, 
    ["Bursting"]    = 11, 
    ["Grievous"]    = 12, 
    ["Explosive"]   = 13, 
    ["Quaking"]     = 14,
}

-- 中文
local affixCN = {
    ["Overflowing"] = "溢出", 
    ["Skittish"]    = "无常", 
    ["Volcanic"]    = "火山",
    ["Necrotic"]    = "死蛆", 
    ["Teeming"]     = "繁盛",
    ["Raging"]      = "暴怒", 
    ["Bolstering"]  = "激励",
    ["Sanguine"]    = "血池", 
    ["Tyrannical"]  = "残暴", 
    ["Fortified"]   = "强韧", 
    ["Bursting"]    = "崩裂", 
    ["Grievous"]    = "重伤", 
    ["Explosive"]   = "易爆", 
    ["Quaking"]     = "震荡",
}

api = { dungeonNums = 12, affixLookUP = affixLookUP, affixSeaon = 120}

function api:dungeonList() 
    return {
        "阿塔达萨",
        "自由镇",
        "托儿达戈",
        "暴富矿区",
        "维克雷斯庄园",
        "诸王之眠",
        "塞塔利斯神庙",
        "地渊孢林",
        "风暴神殿",
        "围攻伯拉勒斯",
        "车间",
        "垃圾场",
    }
end

function api:dungeonListShort() 
    return {
        "阿塔",
        "自由",
        "监狱",
        "暴富",
        "庄园",
        "诸王",
        "神庙",
        "地渊",
        "风暴",
        "围攻",
        "车间",
        "垃圾场",
    }
end
   
function api:getPlayerSeasonMythicPlus()

    local result = {}
    local index = 1

    for k,v in pairs(dungeonIdList) do
        local tempData = ""
        local dungeonList = self:dungeonList()

        -- use api
        intimeInfo, overtimeInfo = C_MythicPlus.GetSeasonBestForMap(v)
        if intimeInfo ~= nil then
            tempData = {}
            tempData.level = intimeInfo.level
            local duration = intimeInfo.durationSec
            local affixStr = intimeInfo.affixIDs[1]..intimeInfo.affixIDs[2].. intimeInfo.affixIDs[3]
            tempData.affixs = self:getIndexByAffix(affixStr)
            -- plus
            local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(v)
            timeLimit = timeLimit * 1000
            duration  = duration * 1000
            local timeLimit3 = timeLimit * 0.6
            local timeLimit2 = timeLimit * 0.8

            tempData.plus = 1
            if duration < timeLimit3 then
                tempData.plus = 3 
            elseif duration< timeLimit2 then
                tempData.plus = 2
            end
        end
        result[index] = tempData
        index = index + 1
    end
    
    return result 
end

-- durationSec, level, completionDate, affixIDs, members = C_MythicPlus.GetWeeklyBestForMap(mapChallengeModeID)
function api:getPlayerWeeklyMythicPlus()
    -- for
    local result = {}
    local index = 1

    for k,v in pairs(dungeonIdList) do
        local tempData = ""
        -- use api
        local durationSec, level, completionDate, affixIDs, members = C_MythicPlus.GetWeeklyBestForMap(v)

        if durationSec ~= nil then
            tempData = {}
            tempData.level = level
            local affixStr = affixIDs[1]..affixIDs[2]..affixIDs[3]
            tempData.affixs = self:getIndexByAffix(affixStr)
            -- plus
            local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(v)
            timeLimit = timeLimit * 1000
            duration  = durationSec * 1000
            local timeLimit3 = timeLimit * 0.6
            local timeLimit2 = timeLimit * 0.8

            tempData.plus = 0
            if duration < timeLimit3 then
                tempData.plus = 3 
            elseif duration< timeLimit2 then
                tempData.plus = 2
            elseif duration < timeLimit then
                tempData.plus = 1
            end
        end
        result[index] = tempData
        index = index + 1
    end
    
    return result 
    -- use api
    -- level, plus  
end

function api:getIndexByAffix(affix)
    for k,v in pairs(affixIndex) do
        if v == affix then
            return k
        end
    end
end

function api:getAffixByIndex(index)
    for k,v in pairs(affixIndex) do
        if k == index then
            return v
        end
    end
end

function api:confusion(season, weekly)
    local i = 1
    for k,v in ipairs(season) do
        if v == "" then
            v = { level = i * 3}
        end

        if k % 2 == 1 then
            i = i + bit.bor(v.level, i)
        else 
            i = i + bit.lshift(v.level, 1)
        end 
    end
  
    for k,v in ipairs(weekly) do
        if k % 3 == 1 then
            i = bit.rshift(i, 2)
        end 
    end
    return bit.band(i, 1000)
end


function api:seasonData(data)
    local result = ""
    for k,v in ipairs(data) do
        local str = "\\0\\0"
        if v ~= "" then 
            local plus = bit.lshift(v.plus, 6)
            local a = bit.bor(plus, v.level)
            str = "\\"..a.."\\"..v.affixs
        end
        result = result..str
    end
    
    return result
end

function api:weeklyData(data)
    local result = ""
    for k,v in ipairs(data) do
        local str = "\\0"
        if v ~= "" then 
            local plus = bit.lshift(v.plus, 6)
            local a = bit.band(plus, v.level)
            str = "\\"..a
        end
        result = result..str
    end
    return result 
end

local levelColor = {
    [5] =   "|cff32CD32",
    [10] =  "|cff228B22",
    [13] =  "|cff1E90FF",
    [15] =  "|cff0000CD",
    [17] =  "|cffCD661D",
    [20] =  "|cffFFA500",
    [22] =  "|cffCD950C",
    [23] =  "|cffFFD700",
    [24] =  "|cffFFFF00",
    [25] =  "|cffFF1493",
    [26] =  "|cff9A32CD",
    [35] =  "|cffFF00FF",
}

local levelNum = {5, 10, 13, 15, 17, 20, 22, 23, 24 ,25, 26, 35}
local plusColor = {
   
    [1] = "|cff7CFC00",
    [2] = "|cffEE7942",
    [3] = "|cffFF3030"
}

function api:getLevelColor(num)
    local color = "|cffEEEEE0"
    for k, v in ipairs(levelNum) do
        if num == v then 
            return levelColor[v]
        elseif num < v then
            return color
        end
        color = levelColor[v]
    end
end

function api:getPlusColor(num)
    local color = "|cff696969"
    for k, v in pairs(plusColor) do
        if num == k then 
            return v
        end
    end
    return color
end


