-- ============================================================================
-- 长城关隘 · 诊断脚本（只读，不改任何游戏状态）   GreatWallPass_Diag.lua  (v1.17)
--
-- 输出前缀：
--   [GWP-EVT]  事件心跳（每个事件被真正触发就打一行）
--   [GWP-DIAG] 数据/状态 dump
--
-- ★ v1.17 改掉枚举方式：
--   v1.16 用 pPlayer:GetCities() + pCity:GetDistricts() 枚举关隘，实测在**游戏脚本环境**里
--   直接报 "Diag.lua:48: function expected instead of nil"（collection:Members() 取不到），
--   整个 dump 从来没成功过。加上 Player:GetDistricts() 本身也只返回城市中心
--   （Lua.log: "sweep districts=5 pass=0"），所以改成**直接扫地图地块**：
--       Map.GetPlotCount() / Map.GetPlotByIndex(i) / Plot:GetOwner() / Plot:GetDistrictType()
--   这条路一定完整，也不依赖任何集合迭代语义。
--
-- ★ v1.15 的心跳结论（40 回合实测，已写进 Wall.lua 头注释）：
--   会响：GameEvents.PlayerTurnStarted(40)、Events.CityProductionChanged(26)、
--         Events.CityProductionCompleted(25)、Events.DistrictAddedToMap(18)、
--         Events.TurnBegin(13)、Events.LocalPlayerTurnBegin(13)、Events.TurnEnd(12)
--   假的：GameEvents.<除 PlayerTurnStarted 外的一切> —— GameEvents 会 auto-vivify，
--         取任何名字都给对象，挂上去永远不会被调用。
--   不存在：Events.PlayerTurnStarted、Events.CityProductionUpdate
--
-- 用完即删：从 modinfo 移除 <AddGameplayScripts id="GreatWallPass_Diag"> 即可。
-- ============================================================================

local PASS_DISTRICT    = "DISTRICT_GREAT_WALL_PASS"
local LINK_IMPROVEMENT = "IMPROVEMENT_GWP_LINK"
local LEGACY_IMPROV    = "IMPROVEMENT_GREAT_WALL"

local HEARTBEAT_CAP = 15
local g_BeatCount = {}

local function L(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
    print("[GWP-DIAG] " .. table.concat(parts, " "))
end

local function Safe(fn, ...)
    local ok, a, b = pcall(fn, ...)
    if ok then return a, b end
    return "ERR:" .. tostring(a), nil
end

-- ===========================================================================
-- 事件心跳
-- ===========================================================================
local function Beat(tag, iPlayerID)
    local n = (g_BeatCount[tag] or 0) + 1
    g_BeatCount[tag] = n
    if n > HEARTBEAT_CAP then
        if n == HEARTBEAT_CAP + 1 then print("[GWP-EVT] " .. tag .. " ... (further lines suppressed)") end
        return
    end
    print("[GWP-EVT] " .. tag .. " FIRED player=" .. tostring(iPlayerID)
          .. " turn=" .. tostring(Safe(function() return Game.GetCurrentGameTurn() end))
          .. " n=" .. n)
end

-- ===========================================================================
-- 一次性自检
-- ===========================================================================
local function SelfCheck()
    local dRow = GameInfo.Districts[PASS_DISTRICT]
    L("district " .. PASS_DISTRICT .. " : "
      .. (dRow and ("index=" .. tostring(dRow.Index) .. " cost=" .. tostring(dRow.Cost)) or "MISSING"))

    local iRow = GameInfo.Improvements[LINK_IMPROVEMENT]
    if iRow == nil then
        L("link improvement " .. LINK_IMPROVEMENT .. " MISSING  <-- 联动墙画不出来")
    else
        L("link improvement " .. LINK_IMPROVEMENT .. " : index=" .. tostring(iRow.Index)
          .. " Buildable=" .. tostring(iRow.Buildable)
          .. " Removable=" .. tostring(iRow.Removable))
    end

    local lRow = GameInfo.Improvements[LEGACY_IMPROV]
    L("legacy improvement " .. LEGACY_IMPROV .. " : "
      .. (lRow and ("index=" .. tostring(lRow.Index)) or "absent"))

    if Map ~= nil and Map.GetPlotCount ~= nil then
        L("map plotCount=" .. tostring(Safe(function() return Map.GetPlotCount() end)))
    else
        L("!! Map.GetPlotCount 不可用")
    end
end

-- ===========================================================================
-- 状态 dump：直接扫地图地块，找本地玩家的关隘
-- ===========================================================================
local function DumpPlayer(iPlayerID)
    L("-- dump start player=" .. tostring(iPlayerID))
    if Map == nil or Map.GetPlotCount == nil or Map.GetPlotByIndex == nil then
        L("!! Map API 不可用"); return
    end

    local dRow = GameInfo.Districts[PASS_DISTRICT]
    if dRow == nil then L("!! district row missing"); return end
    local linkIndex = nil
    pcall(function() linkIndex = GameInfo.Improvements[LINK_IMPROVEMENT].Index end)

    local n = Safe(function() return Map.GetPlotCount() end)
    if type(n) ~= "number" then L("!! GetPlotCount -> " .. tostring(n)); return end

    local owned, nPass, nLinked, nIncomplete, nOther = 0, 0, 0, 0, 0
    for i = 0, n - 1 do
        local plot = Safe(function() return Map.GetPlotByIndex(i) end)
        if type(plot) ~= "string" and plot ~= nil then
            local owner = Safe(function() return plot:GetOwner() end)
            if owner == iPlayerID then
                owned = owned + 1
                local dType = Safe(function() return plot:GetDistrictType() end)
                if dType == dRow.Index then
                    nPass = nPass + 1
                    local px = Safe(function() return plot:GetX() end)
                    local py = Safe(function() return plot:GetY() end)
                    local cur = Safe(function() return plot:GetImprovementType() end)
                    local imp = tostring(cur)
                    local ok, pDistrict = pcall(function() return CityManager.GetDistrictAt(plot) end)
                    local complete = "?"
                    if ok and pDistrict ~= nil then
                        complete = tostring(Safe(function() return pDistrict:IsComplete() end))
                    end
                    if linkIndex ~= nil and cur == linkIndex then
                        nLinked = nLinked + 1
                        imp = imp .. "(LINK)"
                    end
                    if complete ~= "true" then nIncomplete = nIncomplete + 1 end
                    L(string.format("   pass pos=%s,%s complete=%s improvement=%s",
                        tostring(px), tostring(py), complete, imp))
                elseif dType ~= nil and dType ~= -1 then
                    nOther = nOther + 1
                end
            end
        end
    end

    L(string.format("SUMMARY player=%d ownedPlots=%d otherDistricts=%d pass=%d incomplete=%d linked=%d   (linked 应等于 pass)",
        iPlayerID, owned, nOther, nPass, nIncomplete, nLinked))
end

local function SafeDump(iPlayerID)
    if iPlayerID == nil then return end
    if iPlayerID ~= Game.GetLocalPlayer() then return end
    local ok, err = pcall(DumpPlayer, iPlayerID)
    if not ok then print("[GWP-DIAG] !! DUMP ERROR: " .. tostring(err)) end
end

-- ===========================================================================
-- 挂事件
-- ===========================================================================
local function Hook(tbl, name, fn)
    if tbl == nil then return false end
    local ev = tbl[name]
    if ev == nil or ev.Add == nil then return false end
    pcall(function() ev.Add(fn) end)
    return true
end

local function Bind(tbl, tblName, evName, alsoDump)
    local ok = Hook(tbl, evName, function(p1, p2, p3, p4, p5, p6)
        Beat(tblName .. "." .. evName, p1)
        if alsoDump then SafeDump(Game.GetLocalPlayer()) end
    end)
    print("[GWP-EVT] bind " .. tblName .. "." .. evName .. " -> " .. tostring(ok))
    return ok
end

function GreatWallPass_DiagInit()
    pcall(SelfCheck)

    -- GameEvents 会 auto-vivify：绑定结果没有参考价值，只能靠心跳验证
    Bind(GameEvents, "GameEvents", "PlayerTurnStarted", false)

    -- Events 是真表（没有的键就是 nil）
    Bind(Events, "Events", "PlayerTurnStarted", false)
    Bind(Events, "Events", "TurnBegin", false)
    Bind(Events, "Events", "LocalPlayerTurnBegin", true)         -- 每回合 dump 一次
    Bind(Events, "Events", "DistrictAddedToMap", true)           -- 关隘放下时 dump
    Bind(Events, "Events", "CityProductionCompleted", true)      -- 完工那一刻 dump ★
    Bind(Events, "Events", "CityProductionChanged", false)

    print("[GWP-DIAG] diagnostic v1.17 loaded")
end

GreatWallPass_DiagInit()
