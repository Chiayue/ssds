if item_gift_debris == nil then 
    item_gift_debris = class({})
end

function item_gift_debris:IsHidden( ... )
	return true
end

function item_gift_debris:OnSpellStart( ... )
    if not IsServer() then return end

	local hCaster = self:GetCaster()
    local nNowCharges = self:GetCurrentCharges()

    if nNowCharges < 3 then
        self:SpendCharge()
        --神之恩赐碎片
        GlobalVarFunc.baoWuShuSuiPian = GlobalVarFunc.baoWuShuSuiPian + 1
        for i = 0 , MAX_PLAYER - 1 do
            local steam_id = PlayerResource:GetSteamAccountID(i)
            if steam_id ~= 0 then
                local nPlayer = PlayerResource:GetPlayer(i)
                if nPlayer ~= nil then
                    local hHero = PlayerResource:GetSelectedHeroEntity(i)                  
                    if not hHero:HasModifier("modifier_caidan_boss_2")  then
                        hHero:AddNewModifier(hHero, nil, "modifier_caidan_boss_2", {})
                    end
                end
            end
        end
    else
		for i=0,2 do self:SpendCharge() end
		hCaster:AddItemByName("item_baoWu_book")
	end
end