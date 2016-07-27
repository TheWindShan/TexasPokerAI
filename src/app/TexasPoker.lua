--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/27
-- Time: 下午4:03
-- To change this template use File | Settings | File Templates.
--

local TexasPoker = {}

local CARD = {
    number = 2,
    color = "d",
}

local PLAYER = {
    name = "player1",
    moneyLeft = 10000,
    dealer = true,
    bet = 100, -- 此轮下注,0check或者还未轮到,-1已弃牌
    cards = { {}, {} }, -- 自己的2张牌
    moneyDelta = -100, -- 结束的时候筹码变化情况
}

local MATCH = {
    id = 1,
    smallBlind = 1, -- 小盲注
    bigBlind = 2, -- 大盲注
    maxPot = 3, -- 当前最大注
    playerInfos = { {}, {}, {}, }, -- PLAYER数组,固定的顺序,dealer每局过后会更新
    cards = { {}, {}, {} }, -- 桌面已翻开的CARD数组, 0-5张
    mainPot = 10000,
    sidePots = {
        { money = 100, players = { "player1", "player2" } },
        { money = 100, players = { "player3", "player4" } },
    },
}

local playTimes = 1
local initMoney = 10000
local match = {}
local dealer = require "app.Dealer"

function TexasPoker:play()
    print("=====================================================================")
    print("=====================================================================")
    print("TexasPoker:play")
    local Player1 = require "app.players.Player1"
    local Player2 = require "app.players.Player2"
    match = {
        smallBlind = 1,
        bigBlind = 2,
        playerInfos = {
            {
                player = Player1,
                name = Player1:getName(),
                moneyLeft = initMoney,
                bet = 0,
                cards = {},
                moneyDelta = 0,
            },
            {
                player = Player2,
                name = Player2:getName(),
                moneyLeft = initMoney,
                bet = 0,
                cards = {},
                moneyDelta = 0,
            }
        },
    }

    TexasPoker:sitDown()
end

function TexasPoker:sitDown()
    print("TexasPoker:sitDown")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onSitDown(match)
    end

    for i = 1, playTimes do
        TexasPoker:startNewRound(i)
    end
    print("=====================================================================")
    print("=====================================================================")
end

function TexasPoker:startNewRound(i)
    print("---------------------------------------------------------------------")
    print("TexasPoker:startNewRound --> " .. i)

    match.id = i
    -- set dealer
    for i = 1, #match.playerInfos do
        local dealer = i % #match.playerInfos == 1
        match.playerInfos[i].dealer = dealer
        if dealer then
        end
    end
    -- blind pot
    match.mainPot = match.smallBlind + match.bigBlind
    match.maxPot = match.bigBlind

    TexasPoker:prepare()
    TexasPoker:start()
    TexasPoker:preFlop()
    TexasPoker:flop()
    TexasPoker:turn()
    TexasPoker:river()
    TexasPoker:endRound(i)
end

function TexasPoker:prepare()
    -- prepare
    print("TexasPoker:prepare ------------------------------")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onNewRoundPrepare(match)
    end
    dealer:prepare()
end

function TexasPoker:start()
    -- start
    print("TexasPoker:start ------------------------------")
    -- shuffle
    dealer:shuffle()

    print(string.format("TexasPoker:dispatchCards:"))
    local ret = dealer:dispatchCardPreFlop(#match.playerInfos)
    for i = 1, #match.playerInfos do
        match.playerInfos[i].cards = ret[i]
        print(string.format("player(%s) --> [%d%s, %d%s]", match.playerInfos[i].name,
            ret[i][1].number, ret[i][1].color, ret[i][2].number, ret[i][2].color))
    end

    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onNewRoundStart(match)
    end
end

function TexasPoker:preFlop(i)
    -- pre flop
    print("TexasPoker:pre flop ------------------------------")
    for i = 1, #match.playerInfos do
        local ret = match.playerInfos[i].player:onPreflop(match)
        if ret == 0 then
            print(string.format("player(%s) --> Check", match.playerInfos[i].name))
        elseif ret < 0 then
            print(string.format("player(%s) --> Fold", match.playerInfos[i].name))
        elseif ret == match.maxPot then
            print(string.format("player(%s) --> Call", match.playerInfos[i].name))
        elseif ret > match.maxPot then
            print(string.format("player(%s) --> Raise", match.playerInfos[i].name))
        end
    end
end

function TexasPoker:flop(i)
    -- flop
    print("TexasPoker:flop ------------------------------")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onFlop(match)
    end
end

function TexasPoker:turn(i)
    -- turn
    print("TexasPoker:turn ------------------------------")
    for i = 1, #match.playerInfos do
        local ret = match.playerInfos[i].player:onTurn(match)
    end
end

function TexasPoker:river(i)
    -- river
    print("TexasPoker:river ------------------------------")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onRiver(match)
    end
end

function TexasPoker:endRound(i)
    -- end
    print("TexasPoker:end ------------------------------")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onNewRoundEnd(match)
    end

    print("TexasPoker:endRound --> " .. i)
    print("---------------------------------------------------------------------")
end

return TexasPoker
