-- 恶魔博弈 直接随意2个未获得的恶魔宝物(不是宝物书) modifier_gem_devil_demon_game

if modifier_gem_devil_demon_game == nil then
	modifier_gem_devil_demon_game = class({})
end

function modifier_gem_devil_demon_game:IsHidden()
    return true
end

function modifier_gem_devil_demon_game:OnCreated(params)
    if IsServer() then 
        local hParent = self:GetParent()
        local nPlayerID = hParent:GetOwner():GetPlayerID()
        --print("count>>>>>>>>>>>>>>>>>>>>>>=",#GlobalVarFunc.player_devil_treasure_list[nPlayerID])
        for i = 1, 2 do
            local radom_count = RandomInt(1, #GlobalVarFunc.player_devil_treasure_list[nPlayerID])
            local devil_name = GlobalVarFunc.player_devil_treasure_list[nPlayerID][radom_count]
            --print("radom_count", devil_name)
            table.remove(GlobalVarFunc.player_devil_treasure_list[nPlayerID], radom_count)
            --print("count_list", #GlobalVarFunc.player_devil_treasure_list[nPlayerID])
            if string.find(devil_name, "gem") then

                --添加宝物的modifier
                hParent:AddNewModifier( hParent, self:GetAbility(), "modifier_"..devil_name, {} )
            end
        end
        hParent:RemoveModifierByName("modifier_gem_devil_demon_game")
    end
end

function modifier_gem_devil_demon_game:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_demon_game:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_demon_game:GetTexture()
    return "emoboyi"
end