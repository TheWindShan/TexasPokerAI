--
-- Created by IntelliJ IDEA.
-- User: huangkun
-- Date: 16/7/27
-- Time: 下午4:03
-- To change this template use File | Settings | File Templates.
--

local TexasPoker = {}

-- 扑克牌数据格式
local CARD = {
    number = 2,
    color = "♠",
}

-- 用户信息数据格式
local PLAYER = {
    name = "player1",
    moneyLeft = 10000,
    dealer = true,
    bet = 100, -- 此轮下注,0check或者还未轮到,-1已弃牌
    cards = { {}, {} }, -- 自己的2张牌
    moneyDelta = -100, -- 结束的时候筹码变化情况
    out = false, -- 盖牌出局
}

-- 比赛信息数据格式
local MATCH = {
    id = 1,
    smallBlind = 1, -- 小盲注
    bigBlind = 2, -- 大盲注
    maxPot = 3, -- 当前牌圈最大注,所有玩家必须跟注,否则弃牌
    playerInfos = { {}, {}, {}, }, -- PLAYER数组,固定的顺序,dealer每局过后会更新
    livePlayers = 1, -- 场上剩余选手
    cards = { {}, {}, {} }, -- 桌面已翻开的CARD数组, 0-5张
    mainPot = 10000,
    sidePots = {
        { money = 100, players = { "player1", "player2" } },
        { money = 100, players = { "player3", "player4" } },
    },
}

-- 下注轮
local BET_ROUND = {
    round_preflop = 1,
    round_flop = 2,
    round_turn = 3,
    round_river = 4,
}
local playTimes = 3
local initMoney = 10000
local maxRound = 4 -- 每一轮最多加注4次
local match = {}
local dealer = require "app.Dealer"

function TexasPoker:play()
    print("=====================================================================")
    print("=====================================================================")
    print("TexasPoker:play")
    local Player1 = require "app.players.Player1"
    local Player2 = require "app.players.Player2"
    local Player3 = require "app.players.Player3"
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
            },
            {
                player = Player3,
                name = Player3:getName(),
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
    print("")
    print("---------------------------------------------------------------------")
    print("TexasPoker:startNewRound --> " .. i)
    for i = 1, #match.playerInfos do
        print(string.format("%s: moneyLeft ==> $%d", match.playerInfos[i].name, match.playerInfos[i].moneyLeft))
    end

    match.id = i
    -- set dealer
    local dealerIndex = 1
    for i = 1, #match.playerInfos do
        local dealer = (match.id % #match.playerInfos) == i
        local pi = match.playerInfos[i]
        pi.dealer = dealer
        pi.out = false
        pi.moneyDelta = 0
        pi.bet = 0
        if dealer then
            print(string.format("TexasPoker:dealer --> %s", match.playerInfos[i].name))
            dealerIndex = i
        end
    end
    -- blind pot
    local player1 = match.playerInfos[(dealerIndex) % #match.playerInfos + 1]
    player1.bet = match.smallBlind
    player1.moneyLeft = player1.moneyLeft - match.smallBlind
    local player2 = match.playerInfos[(dealerIndex + 1) % #match.playerInfos + 1]
    player2.bet = match.bigBlind
    player2.moneyLeft = player2.moneyLeft - match.bigBlind
    self:printBet()

    -- reset datas
    match.cards = {}
    match.mainPot = match.smallBlind + match.bigBlind
    match.maxPot = match.bigBlind
    match.sidePots = {}
    match.livePlayers = #match.playerInfos

    TexasPoker:prepare()
    TexasPoker:start()
    repeat
        if TexasPoker:preFlop() then
            break
        end
        if TexasPoker:flop() then
            break
        end
        if TexasPoker:turn() then
            break
        end
        if TexasPoker:river() then
            break
        end
    until false
    TexasPoker:endRound()
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
    print("")
    print("TexasPoker:start ------------------------------")
    for i = 1, #match.playerInfos do
        print(string.format("%s:bet ==> $%d", match.playerInfos[i].name, match.playerInfos[i].bet))
    end
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))

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

function TexasPoker:preFlop()
    -- pre flop
    print("")
    print("TexasPoker:pre flop ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_preflop)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:flop()
    -- flop
    print("")
    print("TexasPoker:flop ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_flop)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:turn()
    -- turn
    print("")
    print("TexasPoker:turn ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_turn)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:river()
    -- river
    print("")
    print("TexasPoker:river ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_river)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:endRound()
    -- end
    print("")
    print("TexasPoker:end ------------------------------")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onNewRoundEnd(match)
    end

    local winner
    for i = 1, #match.playerInfos do
        local pi = match.playerInfos[i]
        if not pi.out then
            winner = pi
            break
        end
    end
    print(string.format("TexasPoker:mainPot ==> $%d, winner is %s", match.mainPot, winner.name))
    winner.moneyLeft = winner.moneyLeft + match.mainPot
    for i = 1, #match.playerInfos do
        print(string.format("%s: moneyLeft ==> $%d", match.playerInfos[i].name, match.playerInfos[i].moneyLeft))
    end
    print("TexasPoker:endRound --> " .. match.id)
    print("---------------------------------------------------------------------")
    print("")
end

function TexasPoker:bet(type)
    local balance = 0
    for i = 1, #match.playerInfos * maxRound do
        local pi = match.playerInfos[i % #match.playerInfos + 1]
        if pi.moneyLeft > 0 then
            local ret = 0
            if type == BET_ROUND.round_preflop then
                ret = pi.player:onPreflop(match)
            elseif type == BET_ROUND.round_flop then
                ret = pi.player:onFlop(match)
            elseif type == BET_ROUND.round_turn then
                ret = pi.player:onTurn(match)
            elseif type == BET_ROUND.round_river then
                ret = pi.player:onRiver(match)
            end
            if ret < 0 or ret > pi.moneyLeft or (pi.bet + ret < match.maxPot) then
                print(string.format("player(%s) --> Fold", pi.name))
                if ret > pi.moneyLeft then
                    print(string.format("player(%s) --> not enough money, 2b!", pi.name))
                end
                pi.out = true
                match.livePlayers = match.livePlayers - 1
                self:printBet()
                if match.livePlayers == 1 then
                    return true
                end
            elseif ret == 0 and match.maxPot == pi.bet then
                print(string.format("player(%s) --> Check", pi.name))
                balance = balance + 1
                self:printBet()
            elseif pi.bet + ret < match.maxPot and pi.moneyLeft == ret then
                match.mainPot = match.mainPot + ret
                print(string.format("player(%s) --> Allin $%d, mainPot ==> $%d", pi.name, ret, match.mainPot))
                pi.moneyLeft = 0
                balance = balance + 1
                self:printBet()
            elseif ret + pi.bet == match.maxPot then
                match.mainPot = match.mainPot + ret
                print(string.format("player(%s) --> Call, mainPot ==> $%d", pi.name, ret, match.mainPot))
                pi.moneyLeft = pi.moneyLeft - ret
                pi.bet = match.maxPot
                balance = balance + 1
                self:printBet()
            elseif ret + pi.bet > match.maxPot then
                match.mainPot = match.mainPot + ret
                pi.moneyLeft = pi.moneyLeft - ret
                match.maxPot = ret + pi.bet
                print(string.format("player(%s) --> Raise $%d, mainPot ==> $%d, maxPot ==> $%d", pi.name, ret, match.mainPot, match.maxPot))
                pi.bet = match.maxPot
                balance = 1
                self:printBet()
            end
        else
            print(string.format("player(%s) --> Pass", pi.name))
            balance = balance + 1
        end

        if balance == match.livePlayers then
            break
        end
    end
    return false
end

function TexasPoker:printBet()
    local ret = ""
    for i = 1, #match.playerInfos do
        if match.playerInfos[i].out then
            ret = ret .. string.format("(%s: $%d) ", match.playerInfos[i].name, match.playerInfos[i].bet)
        else
            ret = ret .. string.format("[%s: $%d] ", match.playerInfos[i].name, match.playerInfos[i].bet)
        end
    end
    print(ret)
end

return TexasPoker
