require("service/archive")
require("service/store")
require("service/account")
require("service/player_store_reward")
local json = require("utils/dkjson")
local bLoadingOver = false

if Service == nil then
	Service = class({})
end


KEY = "LLFZBS"
Address = "http://47.108.61.165/service"
ServerKey = GetDedicatedServerKeyV2(KEY)
-- 服务列表
MAP_CODE = "archers_survive"									-- 地图编码

-- 其他常量
REQUEST_TIME_OUT = 30

function Service:init()
	print("Service:Init...")
	Account:Init()
	Store:Init()
	Archive:Init()
	CustomNetTables:SetTableValue("service", "map_code", {MAP_CODE = MAP_CODE})
end

function Service:HTTPRequest(sMethod, sAction, hParams, hFunc, fTimeout)
	local szURL = Address .."/" ..sAction .. "?"
	local handle = CreateHTTPRequestScriptVM(sMethod, szURL)
	handle:SetHTTPRequestHeaderValue("Content-Type", "application/json;charset=uft-8")
	if hParams == nil then hParams = {} end
	hParams.server_key = ServerKey
	hParams.map_code = MAP_CODE
	handle:SetHTTPRequestRawPostBody("application/json", json.encode(hParams))
	handle:SetHTTPRequestAbsoluteTimeoutMS((fTimeout or REQUEST_TIME_OUT) * 1000)
	handle:Send(function(response)
		print(szURL)
		--DeepPrintTable(hParams)
		--print(response.Body)
		hFunc(response.StatusCode, response.Body, response)
	end)
end

function Service:HTTPRequestSync(sMethod, sAction, hParams, fTimeout)
	local co = coroutine.running()
	self:HTTPRequest(sMethod, sAction, hParams, function(iStatusCode, sBody, hResponse)
		print("HTTPRequestSync")
		coroutine.resume(co, iStatusCode, sBody, hResponse)
	end, fTimeout)
	return coroutine.yield()
end