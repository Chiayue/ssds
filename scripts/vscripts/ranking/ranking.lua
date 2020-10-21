if Ranking == nil then Ranking = class({}) end

function Ranking:Init()
    CustomGameEventManager:RegisterListener("ranking_get",Ranking.LoadData)


    local sGameType = "normal"
    Archive:GetRanking(sGameType)
end

function Ranking:LoadData(args)
    DeepPrintTable(args)
end

