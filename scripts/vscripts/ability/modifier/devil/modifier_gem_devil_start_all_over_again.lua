-- 从头再来 清空所有已获得宝物，然后一次性给予清空宝物的不计入使用上限的个人宝物书 modifier_gem_devil_start_all_over_again
local hResetBaowuList = {
    "gem_pinbenshishadewo",
    "gem_yezhendebuyaole",
    "gem_chainmail",
    "gem_platemail",
    "gem_huiguang_fu",
    "gem_shuangren_fu",
    "gem_budao_fu",
    "gem_zuizhongzhijian_lua",
    "gem_xunjizhijian_lua",
    "gem_shixue_lua",
    "gem_god_left_hand",
    "gem_god_right_hand",
    "gem_bow_of_aeolus",
    "gem_arrow_of_aeolus",
    "gem_blacksmith_left_wristbands",
    "gem_blacksmith_right_wristbands",
    "gem_bubaizhidun",
    "gem_yuanshemoshi",
    "gem_liliangcuncu_huang",
    "gem_liliangcuncu_zi",
    "gem_xiaozhiliao",
    "gem_zhongzhiliao",
    "gem_dazhiliao",
    "gem_busishengbei",
    "gem_yinxuejian",
    --"gem_yongmengmoshi",
    "gem_tanlanmianju",
    "gem_emoqiyue",
    "gem_budengzhiduihuan",
    "gem_yongmengzhiren_xiao",
    "gem_yongmengzhiren_zhong",
    "gem_yongmengzhiren_da",
    "gem_canbaizhiren",
    "gem_shihunshengbei",
    "gem_shufuzhiren",
    "gem_duohunfazhang",
    "gem_devil_head",
    "gem_devil_left_hand",
    "gem_devil_right_hand",
    "gem_devil_left_foot",
    "gem_devil_right_foot",
    "gem_gangtieheji",
    "gem_tiangoubudehaosi",
    "gem_fuhuoshijian",
    "gem_shanghaizengfu_1",
    "gem_shanghaizengfu_2",
    "gem_shanghaizengfu_3",
    "gem_shanghaizengfu_4",
    "gem_tanlan",

    "gem_void_lock",
    "gem_die_venom",
    "gem_Ice_storm",
    --"gem_raging_fire_interrogate",
    "gem_earth_burst",
    --"gem_shadow_quiet",

    "mucai_xiaojiejin",
    "mucai_dajiejin",
    "gold_jinkuai",
    "gold_jinbidai",

    "huihedashang",
    "tanyuzhihu",
    "zuanshi_touzi",
}

if modifier_gem_devil_start_all_over_again == nil then
	modifier_gem_devil_start_all_over_again = class({})
end

function modifier_gem_devil_start_all_over_again:IsHidden()
    return true
end

function modifier_gem_devil_start_all_over_again:OnCreated(params)
    if not IsServer() then return end 
    local hParent = self:GetParent()
    local nPlayer = hParent:GetOwner():GetPlayerID()
    self.gem_count = 0
    self:RemoveallModifierCount(hParent)
    local baowu2 = hParent:AddItemByName("item_baowu_book_personage_use_limit")
    baowu2:SetCurrentCharges(self.gem_count)
    self:RemoveallModifierCount(hParent)
    self:ResetTreasureList(nPlayer, hParent)
    hParent:RemoveModifierByName("modifier_gem_devil_start_all_over_again")
end

function modifier_gem_devil_start_all_over_again:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_devil_start_all_over_again:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_devil_start_all_over_again:GetTexture()
    return "chongtouzailai"
end

function modifier_gem_devil_start_all_over_again:RemoveallModifierCount(hParent)
    
    local modifier_count = hParent:FindAllModifiers()
    for i, modifier in pairs(modifier_count) do 
        if string.find(modifier:GetName(), "gem") then
            if modifier:IsHidden() == false then
                self.gem_count = self.gem_count + 1
                hParent:RemoveModifierByName(modifier:GetName())
            end
        end
    end
end

function modifier_gem_devil_start_all_over_again:ResetTreasureList(nPlayer, hParent)
    GlobalVarFunc.player_treasure_list[nPlayer] = {}
    for key, value in ipairs(hResetBaowuList) do
        GlobalVarFunc.player_treasure_list[nPlayer][key] = value
    end
    local modifer_name = hParent:FindAllModifiers()
    for i, modifier in pairs(modifer_name) do 
        if string.find(modifier:GetName(), "gem") then
            for _, treasure_ablity in ipairs(hResetBaowuList) do
                if "modifier_"..treasure_ablity == modifier:GetName() and modifier:IsHidden() == false then 
                    hParent:RemoveModifierByName(modifier:GetName())
                end
            end
        end
    end
end