--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/28
-- Time: 下午10:59
-- To change this template use File | Settings | File Templates.
--


local Player3 = {}

function Player3:getName()
    return "Player3"
end

-- MATCH里面的数据只能读取,不能做任何修改
-- 坐下
function Player3:onSitDown(MATCH)
end

-- 准备新开一局
function Player3:onNewRoundPrepare(MATCH)
end

-- 开始新一局
function Player3:onNewRoundStart(MATCH)
end

-- 第一次翻牌前下注(仅手里2张): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player3:onPreflop(MATCH)
    return math.random(-1, 10)
end

-- 翻牌下注(已翻3张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player3:onFlop(MATCH)
    return math.random(-1, 10)
end

-- 转下注(已翻4张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player3:onTurn(MATCH)
    return math.random(-1, 10)
end

-- 河牌圈下注(已翻5张牌): 返回下注的钱, 0check, -1弃牌, [非法:如果比人家少直接弃牌,比自己多则算all-in]
function Player3:onRiver(MATCH)
    return math.random(-1, 10)
end

-- 一轮结束
function Player3:onNewRoundEnd(MATCH)
end

return Player3