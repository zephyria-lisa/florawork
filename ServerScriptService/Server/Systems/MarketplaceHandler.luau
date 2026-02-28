--[[
 - @ Author: flora
 - @ Create Time: 2026-02-26 23:23:59
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:55
 - @ Description: MarketplaceService kullanımını kolaylaştıran modül. Oyun içi satın alma işlemlerini yönetmek, doğrulamak ve takip etmek için kullanılır. Bu modül, oyuncuların gerçekleştirdiği satın alma işlemlerini izler, veritabanına kaydeder ve gerektiğinde bu bilgilere erişim sağlar. Ayrıca, satın alma işlemlerinin doğruluğunu sağlamak ve olası sorunları tespit etmek için hata yönetimi ve raporlama mekanizmaları içerir.
]]

--// Types
export type receiptInfo = {
    PurchaseId: number,
    PlayerId: number,
    ProductId: number,
    CurrencySpent: number,
    CurrencyType: Enum.CurrencyType,
}

--// Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local Attributes = require(ReplicatedStorage.Framework.Shared.Config.Attributes)

--// Module
local MarketplaceHandler = {
    Name = "MarketplaceHandler",
    Dependencies = {
        DataService = "DataService",
        EasyAnalytics = "EasyAnalytics",
        ReceiptService = "ReceiptService",
    },
}

--// Reciept Functions
local function testCoinPurchase(player: Player)
    local status = MarketplaceHandler.DataService:AddValue(player, "Coins", 100)

    if not status then
        warn(`⚠️ | MarketplaceHandler: Failed to increase coins for player {player.Name} during test purchase.`)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

--// Main Functions
local function processReceipt(receiptInfo: receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

    if not player then
        warn(`⚠️ | MarketplaceHandler: Player with UserId {receiptInfo.PlayerId} not found for receipt processing.`)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if not player:GetAttribute(Attributes.Player.IS_LOADED) then
        warn(`  ⚠️ | MarketplaceHandler: Player {player.Name} is not fully loaded. Cannot process receipt.`)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local productId = receiptInfo.ProductId
    local handler = MarketplaceHandler._boundFunctions and MarketplaceHandler._boundFunctions[productId]

    if not handler then
        warn(`⚠️ | MarketplaceHandler: No bound handler for ProductId {productId}.`)
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local decision = nil
    local ok, err = pcall(function()
        decision = handler(player)
    end)

    if not ok then
        warn("⚠️ | MarketplaceHandler: Error while executing product handler for " .. tostring(productId) .. ": " .. tostring(err))
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    if decision == Enum.ProductPurchaseDecision.PurchaseGranted then
        local receiptId = tostring(receiptInfo.PurchaseId or os.time())
        local purchaseInfo = {
            PurchaseId = receiptInfo.PurchaseId,
            ProductId = receiptInfo.ProductId,
            CurrencySpent = receiptInfo.CurrencySpent,
            timestamp = os.time(),
        }

        local logged = false
        local success, err = pcall(function()
            logged = MarketplaceHandler.ReceiptService:LogReceipt(player, purchaseInfo)
        end)

        if not success or not logged then
            warn("⚠️ | MarketplaceHandler: Failed to log receipt for player " .. player.Name .. ": " .. tostring(err))
        end

        print(`✅ | MarketplaceHandler: Processed receipt for player {player.Name}, ProductId {productId}, PurchaseId {receiptId}. Logging success: {tostring(logged)}`)

        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    return decision or Enum.ProductPurchaseDecision.NotProcessedYet
end

function MarketplaceHandler:BindProductFunctions(functionTable: { [number]: (Player) -> (Enum.ProductPurchaseDecision) })
    if not self._boundFunctions then
        self._boundFunctions = {}
    end

    for productId, func in pairs(functionTable) do
        if typeof(productId) ~= "number" then
            warn(`⚠️ | MarketplaceHandler: Invalid productId {productId} in BindProductFunctions. Must be a number.`)
            continue
        end

        if typeof(func) ~= "function" then
            warn(`⚠️ | MarketplaceHandler: Invalid function for productId {productId} in BindProductFunctions. Must be a function.`)
            continue
        end

        self._boundFunctions[productId] = func
    end
end

function MarketplaceHandler:Init()
    self._boundFunctions = {}
    self:BindProductFunctions({
        [3545691712] = testCoinPurchase, -- example product ID for testing
    })
end

function MarketplaceHandler:Start()
    MarketplaceService.ProcessReceipt = processReceipt
end

--// Module Exporting
return MarketplaceHandler