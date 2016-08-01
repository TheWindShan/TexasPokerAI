--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/27
-- Time: 下午4:07
-- To change this template use File | Settings | File Templates.
--

local Player = {}
Player.name = "Player2"

-- MATCH里面的数据只能读取,不能做任何修改
-- 坐下
function Player:onSitDown(MATCH)
end

-- 准备新开一局
function Player:onNewRoundPrepare(MATCH)
end

-- 开始新一局
function Player:onNewRoundStart(MATCH)
end

-- 第一次翻牌前下注(仅手里2张): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onPreflop(MATCH)
    local me = GET_PLAYER(Player.name)
    local ret = math.random(1, 50)
    if ret == 1 then
        -- flod
        return -1
    elseif ret < 30 then
        if MATCH.maxPot == me.bet then
            -- check
            return 0
        else
            -- call
            return MATCH.maxPot - me.bet
        end
    elseif ret < 50 then
        -- raise
        return math.random(MATCH.maxPot - me.bet + 1, MATCH.maxPot - me.bet + 200)
    else
        -- all in
        return me.moneyLeft
    end
end

-- 翻牌下注(已翻3张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onFlop(MATCH)
    local me = GET_PLAYER(Player.name)
    local ret = math.random(1, 50)
    if ret == 1 then
        -- flod
        return -1
    elseif ret < 30 then
        if MATCH.maxPot == me.bet then
            -- check
            return 0
        else
            -- call
            return MATCH.maxPot - me.bet
        end
    elseif ret < 50 then
        -- raise
        return math.random(MATCH.maxPot - me.bet + 1, MATCH.maxPot - me.bet + 200)
    else
        -- all in
        return me.moneyLeft
    end
end

-- 转下注(已翻4张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onTurn(MATCH)
    local me = GET_PLAYER(Player.name)
    local ret = math.random(1, 50)
    if ret == 1 then
        -- flod
        return -1
    elseif ret < 30 then
        if MATCH.maxPot == me.bet then
            -- check
            return 0
        else
            -- call
            return MATCH.maxPot - me.bet
        end
    elseif ret < 50 then
        -- raise
        return math.random(MATCH.maxPot - me.bet + 1, MATCH.maxPot - me.bet + 200)
    else
        -- all in
        return me.moneyLeft
    end
end

-- 河牌圈下注(已翻5张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onRiver(MATCH)
    local me = GET_PLAYER(Player.name)
    local ret = math.random(1, 50)
    if ret == 1 then
        -- flod
        return -1
    elseif ret < 30 then
        if MATCH.maxPot == me.bet then
            -- check
            return 0
        else
            -- call
            return MATCH.maxPot - me.bet
        end
    elseif ret < 50 then
        -- raise
        return math.random(MATCH.maxPot - me.bet + 1, MATCH.maxPot - me.bet + 200)
    else
        -- all in
        return me.moneyLeft
    end
end

-- 一轮结束
function Player:onNewRoundEnd(MATCH)
end

return Player