-- ============================================================================
-- 长城关隘 · 动态墙联动      GreatWallPass_Wall.lua   (mod v1.17)
--
-- 原理：长城的墙是 DynamicGeometry 按「地块上有长城改良」连成 spline 画出来的。
--       关隘是「区域」，本身不在这个网络里，所以墙到关隘格边上就断了。
--       本脚本在关隘地块补一段改良（IMPROVEMENT_GWP_LINK，显示名「关隘墙体」——
--       自建的纯视觉改良：Buildable=false / Removable=false / 无收益，
--       所以玩家无法用建造者移除它，关隘格也不会白吃长城改良的数值），
--       于是动态墙系统会把关隘格当成长城节点，把墙真正连过去。
--
-- 【完工守门 —— 必须留着】
--   施工中的地块上不能同时有"区域 + 改良"：那会让该地块无法再被 CanProduce 选中，
--   表现就是"修到一半切走生产，再点关隘没法继续"（v1.06 修的就是这个）。
--   代价：施工途中墙先不连，完工后才连。这个取舍是故意的。
--
-- ============================ 历代 bug 坟场 ============================
-- v1.06~v1.11  全量扫描 for x in coll:Members() 少写一个变量 → 拿到数字 →
--              pDistrict:GetType() 报 "attempt to index a number value"。
-- v1.12        修好上面那个，但……
-- v1.17        ★ 真正的根因：**之前用错了枚举源**
--              · Player:GetDistricts() 实测只返回 5 个对象、其中 0 个是关隘
--                （Lua.log: "sweep p=0 districts=5 pass=0" 连着几十回合）。
--              · City:GetDistricts() 在**游戏脚本环境**里连 Members 都取不到
--                （Lua.log: "Diag.lua:48: function expected instead of nil"）。
--              · 而 DistrictAddedToMap 那条路被"完工守门"挡着（放下时还没完工）。
--              => 三条路全断，所以 v1.06 之后**没有任何一座新关隘能连上墙**。
--              现在改成**直接扫地图地块**（Map.GetPlotByIndex + Plot:GetDistrictType），
--              这条路一定完整，也不依赖任何集合迭代语义。
--
-- v1.16 事件大检查结论（Lua.log 心跳实测）：
--   会响：GameEvents.PlayerTurnStarted / Events.CityProductionChanged /
--         Events.CityProductionCompleted / Events.DistrictAddedToMap /
--         Events.TurnBegin / LocalPlayerTurnBegin / TurnEnd
--   假的：**GameEvents 是个"取任何名字都给你一个对象"的表（auto-vivify）**，
--         除了 PlayerTurnStarted，挂在 GameEvents 上的事件永远不会被调用。
--         所以「Hook() 返回 true」什么都不能证明。Events 才是真表。
--
-- 【调试开关】GWP_DEBUG = true 时，每回合给本地玩家打一行扫描小结：
--   [GreatWallPass] sweep p=0 why=turn plots=3404 owned=37 pass=2 linked=1 fixed=1 ...
-- ============================================================================

local GWP_DEBUG = false

local PASS_DISTRICT      = "DISTRICT_GREAT_WALL_PASS"
local LINK_IMPROVEMENT   = "IMPROVEMENT_GWP_LINK"     -- 纯视觉（显示名「关隘墙体」）
local LEGACY_IMPROVEMENT = "IMPROVEMENT_GREAT_WALL"   -- v1.01 旧做法，需替换

local g_PassIndex   = nil
local g_LinkIndex   = nil
local g_LegacyIndex = nil

local g_Stat = { plots = 0, owned = 0, pass = 0, linked = 0, fixed = 0, skipped = 0, incomplete = 0 }

local function P(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
    print("[GreatWallPass] " .. table.concat(parts, " "))
end

local function ResetStat()
    g_Stat.plots, g_Stat.owned, g_Stat.pass = 0, 0, 0
    g_Stat.linked, g_Stat.fixed, g_Stat.skipped, g_Stat.incomplete = 0, 0, 0, 0
end

local function CacheIndices()
    if g_PassIndex == nil then
        local row = GameInfo.Districts[PASS_DISTRICT]
        if row ~= nil then g_PassIndex = row.Index end
    end
    if g_LinkIndex == nil then
        local row = GameInfo.Improvements[LINK_IMPROVEMENT]
        if row ~= nil then g_LinkIndex = row.Index end
    end
    if g_LegacyIndex == nil then
        local row = GameInfo.Improvements[LEGACY_IMPROVEMENT]
        if row ~= nil then g_LegacyIndex = row.Index end
    end
end

local function SetImprovement(plot, idx, playerID)
    local ok = false
    if ImprovementBuilder ~= nil and ImprovementBuilder.SetImprovementType ~= nil then
        ok = pcall(function() ImprovementBuilder.SetImprovementType(plot, idx, playerID) end)
    end
    if not ok then
        ok = pcall(function() plot:SetImprovementType(idx) end)
    end
    return ok
end

-- 只依据**格子当前实际状态**决定，不依赖任何内存记忆 —— 所以重载存档也能正确恢复。
local function ProcessPassPlot(plot, playerID)
    if plot == nil then return end
    if playerID == nil or playerID < 0 then playerID = plot:GetOwner() end
    if playerID == nil or playerID < 0 then return end

    g_Stat.pass = g_Stat.pass + 1

    local okCur, cur = pcall(function() return plot:GetImprovementType() end)
    if not okCur then return end

    -- 已经是纯视觉版：完成
    if cur == g_LinkIndex then
        g_Stat.linked = g_Stat.linked + 1
        return
    end

    -- 完工守门：只在关隘**建完之后**才写
    local okD, pDistrict = pcall(function() return CityManager.GetDistrictAt(plot) end)
    if not okD or pDistrict == nil then return end
    local okC, complete = pcall(function() return pDistrict:IsComplete() end)
    if not okC or not complete then
        g_Stat.incomplete = g_Stat.incomplete + 1
        if GWP_DEBUG then
            P("pass tile " .. plot:GetX() .. "," .. plot:GetY()
              .. " still under construction -> wait")
        end
        return
    end

    -- 空着，或还留着旧版的原版长城改良 -> 都校正为纯视觉版
    if cur == -1 or (g_LegacyIndex ~= nil and cur == g_LegacyIndex) then
        local wrote = SetImprovement(plot, g_LinkIndex, playerID)
        g_Stat.fixed = g_Stat.fixed + 1
        P("link wall set on pass tile " .. plot:GetX() .. "," .. plot:GetY()
          .. " (was " .. tostring(cur) .. ", writeOk=" .. tostring(wrote) .. ")")
    else
        g_Stat.skipped = g_Stat.skipped + 1
        P("pass tile " .. plot:GetX() .. "," .. plot:GetY()
          .. " already has improvement " .. tostring(cur) .. " -> skipped")
    end
end

local function OnDistrictAddedToMap(iPlayerID, iDistrictID, iCityID, iX, iY, iDistrictType)
    CacheIndices()
    if g_PassIndex == nil then return end
    if iDistrictType ~= g_PassIndex then return end
    ResetStat()
    ProcessPassPlot(Map.GetPlot(iX, iY), iPlayerID)
end

-- ★ v1.17：直接扫地图地块。
-- 这是唯一"一定完整"的枚举方式，也不依赖任何集合迭代语义
-- （Player:GetDistricts() 不含关隘；City:GetDistricts() 在游戏脚本环境里取不到 Members）。
local function SweepPlots(iPlayerID, why)
    CacheIndices()
    if g_PassIndex == nil or g_LinkIndex == nil then
        P("sweep skipped: passIndex=" .. tostring(g_PassIndex)
          .. " linkIndex=" .. tostring(g_LinkIndex) .. " (数据库行缺失?)")
        return
    end
    if Map == nil or Map.GetPlotCount == nil or Map.GetPlotByIndex == nil then
        P("sweep skipped: Map.GetPlotCount/GetPlotByIndex 不可用")
        return
    end

    local n = Map.GetPlotCount()
    if n == nil or n <= 0 then
        P("sweep skipped: Map.GetPlotCount() = " .. tostring(n))
        return
    end

    ResetStat()
    g_Stat.plots = n
    for i = 0, n - 1 do
        local plot = Map.GetPlotByIndex(i)
        if plot ~= nil then
            local okO, owner = pcall(function() return plot:GetOwner() end)
            if okO and owner == iPlayerID then
                g_Stat.owned = g_Stat.owned + 1
                local okT, dType = pcall(function() return plot:GetDistrictType() end)
                if okT and dType == g_PassIndex then
                    ProcessPassPlot(plot, iPlayerID)
                end
            end
        end
    end

    if GWP_DEBUG and iPlayerID == Game.GetLocalPlayer() then
        P("sweep p=" .. tostring(iPlayerID)
          .. " why=" .. tostring(why)
          .. " plots=" .. g_Stat.plots
          .. " owned=" .. g_Stat.owned
          .. " pass=" .. g_Stat.pass
          .. " linked=" .. g_Stat.linked
          .. " incomplete=" .. g_Stat.incomplete
          .. " fixed=" .. g_Stat.fixed
          .. " skipped=" .. g_Stat.skipped)
    end
end

local function OnPlayerTurnStarted(iPlayerID)
    SweepPlots(iPlayerID, "turn")
end

-- 生产事件：关隘完工那一刻就补墙。
-- 引擎把"生产"拆成三个事件（DLC/Expansion2/UI/CityBanners/CityBannerManager.lua:3061/3068/3075），
-- 其中 CityProductionUpdate 在游戏脚本环境里**不存在**（实测），所以只挂两个。
local function OnProductionEvent(ePlayer)
    if ePlayer == nil or ePlayer < 0 then ePlayer = Game.GetLocalPlayer() end
    SweepPlots(ePlayer, "production")
end

-- 注册一个事件；返回 false 表示这个键不存在（Events 是真表，判断可信）
local function Hook(tbl, name, fn)
    if tbl == nil then return false end
    local ev = tbl[name]
    if ev == nil or ev.Add == nil then return false end
    pcall(function() ev.Add(fn) end)
    return true
end

function GreatWallPass_Initialize()
    CacheIndices()

    if g_PassIndex == nil then P("!! GameInfo.Districts[" .. PASS_DISTRICT .. "] is nil") end
    if g_LinkIndex == nil then P("!! GameInfo.Improvements[" .. LINK_IMPROVEMENT .. "] is nil") end

    local a = Hook(Events, "DistrictAddedToMap", OnDistrictAddedToMap)
    local b = Hook(GameEvents, "PlayerTurnStarted", OnPlayerTurnStarted)
    local c = Hook(Events, "CityProductionCompleted", OnProductionEvent)
    local d = Hook(Events, "CityProductionChanged",   OnProductionEvent)

    P("wall linker v1.18 loaded (pass=" .. tostring(g_PassIndex)
      .. ", link=" .. tostring(g_LinkIndex)
      .. ", legacy=" .. tostring(g_LegacyIndex)
      .. ", debug=" .. tostring(GWP_DEBUG)
      .. ", plotCount=" .. tostring(Map ~= nil and Map.GetPlotCount ~= nil and Map.GetPlotCount() or "?")
      .. ") hooks: DistrictAddedToMap=" .. tostring(a)
      .. " PlayerTurnStarted=" .. tostring(b)
      .. " ProdCompleted=" .. tostring(c)
      .. " ProdChanged=" .. tostring(d))
end

GreatWallPass_Initialize()
