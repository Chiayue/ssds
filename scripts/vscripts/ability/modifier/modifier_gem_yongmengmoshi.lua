if modifier_gem_yongmengmoshi == nil then
	modifier_gem_yongmengmoshi = class({})
end

function modifier_gem_yongmengmoshi:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_RESPAWN ,
    }
    return funcs
end

function modifier_gem_yongmengmoshi:IsHidden()
	return false
end

function modifier_gem_yongmengmoshi:OnCreated(params)
    
end

function modifier_gem_yongmengmoshi:OnRespawn(params)
    local nCaster = self:GetParent()
    --判断重生对象是不是modifier拥有者
    if params.unit == nCaster then                  
        nCaster:AddNewModifier(nil, nil, "modifier_invulnerable", {duration = 6})
    end
end

function modifier_gem_yongmengmoshi:IsPurgable()
    return false -- 无法驱散
end
 
function modifier_gem_yongmengmoshi:RemoveOnDeath()
    return false -- 死亡不移除
end

function modifier_gem_yongmengmoshi:GetTexture()
    return "baowu/yongmengmoshi"
end