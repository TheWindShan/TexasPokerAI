--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/27
-- Time: 下午5:12
-- To change this template use File | Settings | File Templates.
--


local Player2 = {}

function Player2:getName()
    return "Player2"
end

-- MATCH里面的数据只能读取,不能做任何修改
-- 坐下
function Player2:onSitDown(MATCH)
end

-- 准备新开一局
function Player2:onNewRoundPrepare(MATCH)
end

-- 开始新一局
function Player2:onNewRoundStart(MATCH)
end

-- 第一次翻牌前下注(仅手里2张): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player2:onPreflop(MATCH)
    return math.random(-1, 10)
end

-- 翻牌下注(已翻3张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player2:onFlop(MATCH)
    return math.random(-1, 10)
end

-- 转下注(已翻4张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player2:onTurn(MATCH)
    return math.random(-1, 10)
end

-- 河牌圈下注(已翻5张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player2:onRiver(MATCH)
    return math.random(-1, 10)
end

-- 一轮结束
function Player2:onNewRoundEnd(MATCH)
end

return Player2