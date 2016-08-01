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
    moneyDelta = -100, -- 每轮结束的时候筹码变化情况
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
    dealerIndex = 1,
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

local function GET_PLAYER(name)
    for i = 1, #match.playerInfos do
        if match.playerInfos[i].name == name then
            return match.playerInfos[i]
        end
    end
    return nil
end

cc.exports.GET_PLAYER = GET_PLAYER

function TexasPoker:play()
    print("=====================================================================")
    print("=====================================================================")
    print("TexasPoker:play")
    match = {
        smallBlind = 1,
        bigBlind = 2,
        playerInfos = {},
    }
    local Players = {
        require "app.players.Player1",
        require "app.players.Player2",
        require "app.players.Player3"
    }
    for i = 1, #Players do
        table.insert(match.playerInfos, {
            player = Players[i],
            name = Players[i].name,
            moneyLeft = initMoney,
            bet = 0,
            cards = {},
            moneyDelta = 0,
        })
    end

    TexasPoker:sitDown()
end

function TexasPoker:sitDown()
    print("TexasPoker:sitDown")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onSitDown(match)
    end

    local id = 1
    repeat
        TexasPoker:startNewRound(id)
        id = id + 1
    until TexasPoker:isEnd()

    print("=====================================================================")
    print("=====================================================================")
end

function TexasPoker:isEnd()
    local left = 0
    for i = 1, #match.playerInfos do
        left = left + (match.playerInfos[i].moneyLeft ~= 0 and 1 or 0)
    end
    return left == 1
end

function TexasPoker:startNewRound(i)
    print("")
    print("---------------------------------------------------------------------")
    print("TexasPoker:startNewRound --> " .. i)
    for i = 1, #match.playerInfos do
        print(string.format("%s: moneyLeft ==> $%d", match.playerInfos[i].name, match.playerInfos[i].moneyLeft))
    end

    -- remove out players
    local count = #match.playerInfos
    for i = count, 1, -1 do
        if match.playerInfos[i].moneyLeft < match.bigBlind then
            print(string.format("TexasPoker:Player(%s) is Out!", match.playerInfos[i].name))
            table.remove(match.playerInfos, i)
            i = i + 1
        end
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
    match.dealerIndex = dealerIndex

    -- blind pot
    local player1 = match.playerInfos[(dealerIndex) % #match.playerInfos + 1]
    player1.bet = match.smallBlind
    player1.moneyLeft = player1.moneyLeft - match.smallBlind
    local player2 = match.playerInfos[(dealerIndex + 1) % #match.playerInfos + 1]
    player2.bet = match.bigBlind
    player2.moneyLeft = player2.moneyLeft - match.bigBlind

    -- reset datas
    match.cards = {}
    match.mainPot = match.smallBlind + match.bigBlind
    match.maxPot = match.bigBlind
    match.sidePots = {}
    match.livePlayers = #match.playerInfos
    self:printBet()

    TexasPoker:prepare()
    TexasPoker:start()
    repeat
        local ret = TexasPoker:preFlop()
        if ret == 2 then
            break
        end
        print(string.format("*******************************TexasPoker:dispatchCards:*******************************"))
        local cards = dealer:dispatchCard(3)
        table.insert(match.cards, cards[1])
        table.insert(match.cards, cards[2])
        table.insert(match.cards, cards[3])
        print(string.format("Cards --> [%d%s, %d%s, %d%s]",
            match.cards[1].number, match.cards[1].color,
            match.cards[2].number, match.cards[2].color,
            match.cards[3].number, match.cards[3].color))

        if ret ~= 3 then
            ret = TexasPoker:flop()
            if ret == 2 then
                break
            end
        end
        local cards = dealer:dispatchCard(1)
        table.insert(match.cards, cards[1])
        print(string.format("Cards --> [%d%s, %d%s, %d%s, %d%s]",
            match.cards[1].number, match.cards[1].color,
            match.cards[2].number, match.cards[2].color,
            match.cards[3].number, match.cards[3].color,
            match.cards[4].number, match.cards[4].color))

        if ret ~= 3 then
            ret = TexasPoker:turn()
            if ret == 2 then
                break
            end
        end
        local cards = dealer:dispatchCard(1)
        table.insert(match.cards, cards[1])
        print(string.format("Cards --> [%d%s, %d%s, %d%s, %d%s, %d%s]",
            match.cards[1].number, match.cards[1].color,
            match.cards[2].number, match.cards[2].color,
            match.cards[3].number, match.cards[3].color,
            match.cards[4].number, match.cards[4].color,
            match.cards[5].number, match.cards[5].color))

        if ret ~= 3 then
            ret = TexasPoker:river()
        end
    until true
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
    print(string.format("*******************************TexasPoker:dispatchCards:*******************************"))
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
    local ret = TexasPoker:bet(BET_ROUND.round_preflop, match.dealerIndex - 1 + 2)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:flop()
    -- flop
    print("")
    print("TexasPoker:flop ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_flop, match.dealerIndex - 1)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:turn()
    -- turn
    print("")
    print("TexasPoker:turn ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_turn, match.dealerIndex - 1)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return ret
end

function TexasPoker:river()
    -- river
    print("")
    print("TexasPoker:river ------------------------------")
    local ret = TexasPoker:bet(BET_ROUND.round_river, match.dealerIndex - 1)
    print(string.format("TexasPoker:mainPot ==> $%d", match.mainPot))
    return true
end

function TexasPoker:endRound()
    -- end
    print("")
    print("TexasPoker:end ------------------------------")
    for i = 1, #match.playerInfos do
        match.playerInfos[i].player:onNewRoundEnd(match)
    end

    local winners = {}
    for i = 1, #match.playerInfos do
        local pi = match.playerInfos[i]
        if not pi.out then
            table.insert(winners, pi)
        end
    end
    local winner = winners[math.random(1, #winners)]
    print(string.format("TexasPoker:mainPot ==> $%d, winner is %s", match.mainPot, winner.name))
    winner.moneyLeft = winner.moneyLeft + match.mainPot
    local total = 0
    for i = 1, #match.playerInfos do
        print(string.format("%s: moneyLeft ==> $%d", match.playerInfos[i].name, match.playerInfos[i].moneyLeft))
        total = total + match.playerInfos[i].moneyLeft
    end
    print("TexasPoker:endRound --> " .. match.id)
    print("TotalMoney = $" .. total)
    print("---------------------------------------------------------------------")
    print("")
end

-- reutrn 1 加注结束,继续发牌
-- reutrn 2 全部盖牌,结束只剩一家
-- reutrn 3 只有一家还有剩余筹码或者没有,其他人都allin,直接发全部牌
function TexasPoker:bet(type, offset)
    local off = offset and offset or 0
    local balance = 0
    for i = 1 + off, #match.playerInfos * (maxRound + 1) + off do
        local canRaise = i < #match.playerInfos * maxRound + off
        local pi = match.playerInfos[i % #match.playerInfos + 1]
        if not pi.out and pi.moneyLeft > 0 then
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
            if ret > pi.moneyLeft then
                ret = pi.moneyLeft
            end
            if ret < 0 or (pi.bet + ret < match.maxPot) then
                print(string.format("player(%s) --> Fold", pi.name))
                --                if ret > pi.moneyLeft then
                --                    print(string.format("player(%s) --> not enough money, 2b!", pi.name))
                --                end
                pi.out = true
                match.livePlayers = match.livePlayers - 1
                self:printBet(balance)
            elseif ret == 0 and match.maxPot == pi.bet then
                print(string.format("player(%s) --> Check", pi.name))
                balance = balance + 1
                self:printBet(balance)
            elseif pi.moneyLeft == ret then
                if ret + pi.bet > match.maxPot then
                    -- Raise
                    balance = 1
                    match.maxPot = ret + pi.bet
                elseif ret + pi.bet == match.maxPot then
                    -- Call
                    balance = balance + 1
                else
                    -- Not enough
                    balance = balance + 1
                end
                match.mainPot = match.mainPot + ret
                print(string.format("player(%s) --> Allin $%d, mainPot ==> $%d", pi.name, ret, match.mainPot))
                pi.bet = pi.bet + ret
                pi.moneyLeft = 0
                --                balance = balance + 1
                self:printBet(balance)

                if match.livePlayers == 1 then
                    return 3
                end
            elseif ret + pi.bet == match.maxPot then
                match.mainPot = match.mainPot + ret
                print(string.format("player(%s) --> Call $%d, mainPot ==> $%d", pi.name, ret, match.mainPot))
                pi.moneyLeft = pi.moneyLeft - ret
                pi.bet = match.maxPot
                balance = balance + 1
                self:printBet(balance)
            elseif ret + pi.bet > match.maxPot then
                if not canRaise then
                    -- 不能在raise了, Call
                    ret = match.maxPot - pi.bet
                    match.mainPot = match.mainPot + ret
                    print(string.format("player(%s) --> Call $%d, mainPot ==> $%d", pi.name, ret, match.mainPot))
                    pi.moneyLeft = pi.moneyLeft - ret
                    pi.bet = match.maxPot
                    balance = balance + 1
                    self:printBet(balance)
                else
                    match.mainPot = match.mainPot + ret
                    pi.moneyLeft = pi.moneyLeft - ret
                    match.maxPot = ret + pi.bet
                    print(string.format("player(%s) --> Raise $%d, mainPot ==> $%d, maxPot ==> $%d", pi.name, ret, match.mainPot, match.maxPot))
                    pi.bet = match.maxPot
                    balance = 1
                    self:printBet(balance)
                end
            end
        else
            if not pi.out then
                print(string.format("player(%s) --> Pass", pi.name))
                balance = balance + 1
                self:printBet(balance)
            end
        end

        if balance == match.livePlayers or match.livePlayers == 1 then
            local out = 0
            local moneyLeft = 0
            for i = 1, #match.playerInfos do
                local pi = match.playerInfos[i]
                out = out + (pi.out and 1 or 0)
                if not pi.out then
                    moneyLeft = moneyLeft + (pi.moneyLeft > 0 and 1 or 0)
                end
            end
            if out == #match.playerInfos - 1 then
                return 2
            else
                if moneyLeft <= 1 then
                    return 3
                else
                    return 1
                end
            end
        end
    end
    return 1
end

function TexasPoker:printBet(balance)
    local b = balance and balance or 0
    local ret = ""
    for i = 1, #match.playerInfos do
        if match.playerInfos[i].out then
            ret = ret .. string.format("(%s: $%d/%d) ", match.playerInfos[i].name, match.playerInfos[i].bet, match.playerInfos[i].moneyLeft)
        else
            ret = ret .. string.format("[%s: $%d/%d] ", match.playerInfos[i].name, match.playerInfos[i].bet, match.playerInfos[i].moneyLeft)
        end
    end
    print(ret .. " balance " .. b .. " livePlayers " .. match.livePlayers)
end

return TexasPoker
