--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/27
-- Time: 下午7:38
-- To change this template use File | Settings | File Templates.
--

local Dealer = {}

-- 52张牌预览
local CARDS = {
    { number = 2, color = "c" }, -- 草花2
    { number = 2, color = "d" }, -- 方块2
    { number = 2, color = "h" }, -- 红桃2
    { number = 2, color = "s" }, -- 黑桃2
    -- ...
    { number = 10, color = "c" }, -- 10
    { number = 10, color = "d" },
    { number = 10, color = "h" },
    { number = 10, color = "s" },
    -- ..
    { number = 11, color = "c" }, -- 草花J
    { number = 11, color = "d" },
    { number = 11, color = "h" },
    { number = 11, color = "s" },
    -- ..
    { number = 14, color = "c" }, -- 草花A
    { number = 14, color = "d" },
    { number = 14, color = "h" },
    { number = 14, color = "s" },
}

local cards = {}
local randSeed = 1
local dispatchIndex = 1
function Dealer:prepare()
    print("Dealer:prepare")
    cards = {}
    local colors = { "c", "d", "h", "s" }
    for i = 2, 14 do
        table.insert(cards, { number = i, color = colors[(i - 1) % 4 + 1] })
    end
    dispatchIndex = 1
end

function Dealer:shuffle()
    print("Dealer:shuffle")
    local size = #cards
    for i = size, 1, -1 do
        local index = math.random(1, i)
        if i ~= index then
            local tmp = cards[i]
            cards[i] = cards[index]
            cards[index] = tmp
        end
    end
end

-- 玩家人数,第一轮每人2张,
function Dealer:dispatchCardPreFlop(playerCount)
    print("Dealer:dispatchCardPreFlop")
    local ret = {}
    for i = 1, playerCount do
        table.insert(ret, { cards[dispatchIndex] })
        dispatchIndex = dispatchIndex + 1
    end
    for i = 1, playerCount do
        table.insert(ret[i], cards[dispatchIndex])
        dispatchIndex = dispatchIndex + 1
    end
    return ret
end

-- 发牌张数, flop:3, turn:1, river:1, 先弃一张
function Dealer:dispatchCard(cardCount)
    print("Dealer:dispatchCard")
    return {}
end

return Dealer