--[[
 - @ Author: flora
 - @ Create Time: 2026-02-26 23:14:55
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:34
 - @ Description: Oyun içi satın alma işlemlerinin kayıt altına alınması ve yönetilmesi için sunucu tarafı modülü. Bu modül, oyuncuların gerçekleştirdiği satın alma işlemlerini takip eder, veritabanına kaydeder ve gerektiğinde bu bilgilere erişim sağlar. Ayrıca, satın alma işlemlerinin doğruluğunu sağlamak ve olası sorunları tespit etmek için hata yönetimi ve raporlama mekanizmaları içerir.
]]

--// Services
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

--// Module
local ReceiptService = {
    Name = "ReceiptService",
    Dependencies = {
        DataService = "DataService",
    },
}

--// Functions
function ReceiptService:Init()
    self._receiptStore = DataStoreService:GetDataStore("ReceiptStore")
    self._receipts = {}
end

function ReceiptService:LogReceipt(player: Player, purchaseInfo: { [any]: any })
    if not player or not player:IsA("Player") then
        warn("⚠️ | Invalid player passed to ReceiptService:LogReceipt")
        return false
    end

    local receiptId = HttpService:GenerateGUID(false)

    if typeof(receiptId) ~= "string" or receiptId == "" then
        warn("⚠️ | ReceiptService:LogReceipt called with invalid receiptId")
        return false
    end

    local userId = player.UserId
    self._receipts[userId] = self._receipts[userId] or {}

    for _, r in ipairs(self._receipts[userId]) do
        if r.id == receiptId then
            warn("⚠️ | ReceiptService: receipt " .. receiptId .. " already logged for " .. player.Name)
            return false
        end
    end

    table.insert(self._receipts[userId], {id = receiptId, info = purchaseInfo})

    for i = 1, 5 do
        local success, err = pcall(function()
            self._receiptStore:UpdateAsync(userId, function(old)
                old = if typeof(old) == "table" then old else {}
                table.insert(old, {id = receiptId, info = purchaseInfo})
                return old
            end)
        end)

        if success then
            print("✅ | ReceiptService: Successfully logged receipt " .. receiptId .. " for " .. player.Name)
            return true
        else
            warn("⚠️ | Attempt " .. i .. " failed to persist receipt for " .. player.Name .. ": " .. tostring(err))
            task.wait(1 + 0.5 * i)
        end
    end

    return false
end

function ReceiptService:GetReceipts(player: Player)
    if not player or not player:IsA("Player") then
        warn("⚠️ | Invalid player passed to ReceiptService:GetReceipts")
        return nil
    end

    local userId = player.UserId
    if self._receipts[userId] then
        return self._receipts[userId]
    end

    local success, data = pcall(function()
        return self._receiptStore:GetAsync(userId)
    end)

    if not success then
        warn("⚠️ | ReceiptService failed to retrieve receipts for " .. player.Name .. ": " .. tostring(data))
        return nil
    end

    if typeof(data) ~= "table" then
        data = {}
    end

    self._receipts[userId] = data
    return data
end

--// Module Exporting
return ReceiptService