--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/27
-- Time: 下午4:04
-- To change this template use File | Settings | File Templates.
--

local Player = {}

-- 名字
function Player:getName()
    return "Player"
end

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
end

-- 翻牌下注(已翻3张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onFlop(MATCH)
end

-- 转下注(已翻4张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onTurn(MATCH)
end

-- 河牌圈下注(已翻5张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player:onRiver(MATCH)
end

-- 一轮结束
function Player:onNewRoundEnd(MATCH)
end

return Player