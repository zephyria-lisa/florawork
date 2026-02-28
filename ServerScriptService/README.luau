--[[
    📖 Service Directory Overview (English)
    ---------------------------------------
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 21:12:14
    is to make it easy for developers to see what utilities are
    implemented and how to call them. ✨

    🛠️ Services:
      • DataService
      • EasyAnalytics
      • MarketplaceHandler
      • SafeTeleportService
      • ReceiptService
      • ServerCooldownService
      • Client Services / MutualChats
      • Shared Utils / TimeUtils

    Each section below lists every exported function together with
    parameter names and a brief description.


    💾 DataService
    --------------
    *Init()* ⚙️
      Initializes internal datastore references and cache tables.

    *SavePlayer(player: Player) -> boolean* 📥
      Persists a loaded player's data back to the persistent store.
      Returns true on success; warns and returns false on failure.

    *LoadPlayer(player: Player) -> boolean* 📂
      Loads data for the given player, applies default values, and
      mirrors certain keys into value objects parented under the
      player's instance. Marks the player as loaded when finished.

    *GetValue(player: Player, key: string) -> any* 🔍
      Retrieves a value from the in-memory cache for the specified
      data key. Warns if the player has no cached data.

    *SetValue(player: Player, key: string, value: any) -> boolean* ✏️
      Updates the cache (and optionally the player's value object)
      for the given key. Always returns true but warns on missing
      player data.

    *AddValue(player: Player, key: string, amount: number) -> boolean* ➕
      Convenience helper that increments a numeric value. Fails if the
      current value is not a number.


    📊 EasyAnalytics
    ----------------
    *ChangeDataValueUsingEconomy(player, key, changeAmount, transactionType,
        flowType, customFields?, sku?)* 💰
      Reads and updates a numerical data value via DataService, then logs
      an AnalyticsService:LogEconomyEvent using the supplied parameters.
      Returns false and warns if validation fails, otherwise updates and
      logs the event before returning true.

    *ForceCustomEvent(player, eventName, value, customFields?)* 🎯
      Wraps AnalyticsService:LogCustomEvent with error handling and prints
      a success message. Returns true on success.


    🛒 MarketplaceHandler
    ---------------------
    *Init()* ⚙️
      Initializes internal product bindings used to process receipts.

    *BindProductFunctions(functionTable)* 🔧
      Registers handlers for product IDs. Each handler should accept a
      `Player` and return an `Enum.ProductPurchaseDecision`.

    *processReceipt(receiptInfo)* 🧾
      Internal callback assigned to `MarketplaceService.ProcessReceipt`.
      Validates the player and delegates to the bound product handler,
      grants purchases where appropriate and logs receipts using
      `ReceiptService`.


    🚀 SafeTeleportService
    ----------------------
    *ForceReserveServer(placeId: number) -> string?* 🎟️
      Attempts up to five times to reserve a teleport server for the
      given PlaceId, returning the reservation code or nil if all
      attempts fail.

        🧾 ReceiptService
        ----------------
        *Init()* ⚙️
        Prepares a dedicated receipts datastore and an in-memory cache.

        *LogReceipt(player: Player, receiptId: string, purchaseInfo: table) -> boolean* 🗃️
        Records a marketplace receipt both in cache and in the separate
        DataStore. Intended to be called from MarketplaceService callbacks.
        Returns true on successful persistence.

        *GetReceipts(player: Player) -> {table}?* 🔍
        Retrieves any receipts held in the in-memory cache for the given
        player (nil if none).

        *SafeTeleportPlayers(players: {Player}, placeId: number,
            reservedServerCode?: string) -> boolean* 🌌
        Saves each player via DataService, marks them as teleporting,
        then uses TeleportService:TeleportAsync. Resets the `IS_BEING_TELEPORTED`
        attribute if the teleport call errors. Always returns true (errors
        are logged internally).

    ⏱️ ServerCooldownService
    ------------------------
    *InitCooldowns(cooldownsTable: { [string]: number })* ⚙️
      Initializes cooldown trackers based on the provided table of
      names and durations.

    *StartCooldown(cooldownName: string)* ⏳
      Starts or restarts the timer for the specified cooldown.

    *IsOnCooldown(cooldownName: string) -> boolean* 🛡️
      Checks if the specific cooldown is currently active. Returns true
      if time remains.

    *GetRemainingTime(cooldownName: string) -> number* 🔢
      Returns the exact seconds remaining on a cooldown. Returns 0 if
      it has expired or doesn't exist.

    💻 Client Services
    ------------------
    The following client-side service modules are stored under:
      ReplicatedStorage/Framework/Client/Services/

    💬 MutualChats
      - LocalPlayerCanChatWith(player) 🤝
          Returns true if the local player shares any chat group with the
          given player.
      - AttachBillboardToCharacter(character) 🚫💬
          Clones and attaches a "no-chat" billboard to the character's head.
      - StartPlayersEvents() 🎧
          Sets up listeners for existing and new players to enforce mutual
          chat visibility rules.
      - Start() 🏁
          Entry point; waits for the local player's groups and then begins
          processing.


    🛠️ Shared Utilities
    -------------------
    The following shared utility modules are stored under:
      ReplicatedStorage/Framework/Shared/Util/
      
    ⏱️ TimeUtils
      - FormatToMMSS(seconds: number) 🕒
          Converts total seconds into a MM:SS format (e.g., "05:30").
      - FormatToHHMMSS(seconds: number) ⏱️
          Converts total seconds into a HH:MM:SS format (e.g., "01:05:30").
      - FormatToShortDHMS(seconds: number, useTurkish: boolean?) 📅
          Converts seconds into a short readable string (e.g., "1d 2h 5m").
      - GetTimeSince(unixTimestamp: number, useTurkish: boolean?) 🕰️
          Returns a formatted string of how long ago a specific os.time() 
          timestamp was (e.g., "5 minutes ago").
      - GetElapsedSeconds(startTick: number) ⌛
          Returns the elapsed time in seconds with decimal precision 
          since the provided startTick.

    ========================================================================

    📖 Servis Dizini Özeti (Türkçe Çeviri)
    --------------------------------------
    Bu bölüm, yukarıdaki İngilizce açıklamaların Türkçe karşılıklarını 
    içerir. Amacımız, ekip üyelerinin modüllerin işlevlerini kendi 
    dillerinde hızlıca ve kolayca anlamalarına yardımcı olmaktır. ✨

    🛠️ Servisler:
      • DataService (Veri Servisi)
      • EasyAnalytics (Analitik Servisi)
      • SafeTeleportService (Güvenli Işınlanma)
      • ReceiptService (Makbuz Servisi)
      • ServerCooldownService (Sunucu Bekleme Süresi Servisi)
      • Client Services / MutualChats (İstemci Servisleri)
      • Shared Utils / TimeUtils (Ortak Zaman Araçları)

    Her bölüm, dışa aktarılan her fonksiyonu, parametrelerini ve ne işe 
    yaradığını kısa bir açıklamayla listeler.


    💾 DataService (Veri Servisi)
    -----------------------------
    *Init()* ⚙️
      İç veri deposu (datastore) referanslarını ve önbellek (cache) 
      tablolarını başlatır.

    *SavePlayer(player: Player) -> boolean* 📥
      Yüklenmiş bir oyuncunun verilerini kalıcı depoya kaydeder. Başarılı 
      olursa true döner; hata durumunda uyarı verir ve false döner.

    *LoadPlayer(player: Player) -> boolean* 📂
      Verilen oyuncunun verilerini yükler, varsayılan değerleri uygular ve
      belirli anahtarları oyuncu örneğinin (instance) altındaki değer 
      objelerine yansıtır. Tamamlandığında oyuncuyu "yüklendi" olarak işaretler.

    *GetValue(player: Player, key: string) -> any* 🔍
      Belirtilen anahtar için bellekteki önbellekten (cache) değer alır. 
      Oyuncunun önbellek verisi yoksa uyarı verir.

    *SetValue(player: Player, key: string, value: any) -> boolean* ✏️
      Verilen anahtar için önbelleği (ve varsa oyuncunun değer objesini) 
      günceller. Her zaman true döner ancak oyuncu verisi eksikse uyarı verir.

    *AddValue(player: Player, key: string, amount: number) -> boolean* ➕
      Sayısal bir değeri artıran pratik bir yardımcı fonksiyondur. Mevcut 
      değer bir sayı değilse işlem başarısız olur.


    📊 EasyAnalytics (Kolay Analitik)
    ---------------------------------
    *ChangeDataValueUsingEconomy(player, key, changeAmount, transactionType,
        flowType, customFields?, sku?)* 💰
      DataService kullanarak sayısal bir veriyi okur ve günceller, ardından
      verilen parametrelerle bir AnalyticsService:LogEconomyEvent kaydı 
      oluşturur. Doğrulama başarısız olursa false döner ve uyarı verir; aksi 
      takdirde değeri güncelleyip olayı kaydederek true döner.

    *ForceCustomEvent(player, eventName, value, customFields?)* 🎯
      AnalyticsService:LogCustomEvent işlemini hata ayıklama (error handling) 
      ile sarar ve beş kez yeniden deneme yapar. Başarılı olursa true döner.


    🛒 MarketplaceHandler (Pazaryeri İşleyici)
    ----------------------------------------
    *Init()* ⚙️
      Ürün kimlikleri için kullanılan dahili bağlama (binding) yapısını başlatır.

    *BindProductFunctions(functionTable)* 🔧
      Ürün kimlikleri için handler (işleyici) kaydeder. Her bir handler `Player`
      parametresi almalı ve `Enum.ProductPurchaseDecision` döndürmelidir.

    *processReceipt(receiptInfo)* 🧾
      `MarketplaceService.ProcessReceipt`'e atanan dahili geri çağrı.
      Oyuncuyu doğrular, kayıtlı handler'a delege eder, uygun durumlarda
      satın alımı onaylar ve `ReceiptService` kullanarak makbuz kaydeder.


    🚀 SafeTeleportService (Güvenli Işınlanma)
    ------------------------------------------
    *ForceReserveServer(placeId: number) -> string?* 🎟️
      Belirtilen PlaceId için en fazla beş kez ışınlanma sunucusu ayırmayı 
      dener. Başarılı olursa rezervasyon kodunu, tüm denemeler başarısız 
      olursa nil döner.

    🧾 ReceiptService (Makbuz Servisi)
    ----------------------------------
    *Init()* ⚙️
      Ayrı bir makbuz veri deposu ve bellekte önbellek hazırlayarak başlatır.

    *LogReceipt(player: Player, receiptId: string, purchaseInfo: table) -> boolean* 🗃️
      Bir pazaryeri makbuzunu hem önbelleğe hem de ayrı veri deposuna kaydeder.
      MarketplaceService geri çağrılarından (callbacks) hemen sonra çağrılmalıdır.
      Kalıcılık başarılıysa true döner.

    *GetReceipts(player: Player) -> {table}?* 🔍
      Verilen oyuncu için bellekteki önbellekte tutulan makbuzları getirir
      (yoksa nil).

    *SafeTeleportPlayers(players: {Player}, placeId: number,
        reservedServerCode?: string) -> boolean* 🌌
      Her oyuncuyu DataService üzerinden kaydeder, onları "ışınlanıyor" 
      (teleporting) olarak işaretler ve ardından TeleportService:TeleportAsync 
      kullanır. Işınlanma çağrısı hata verirse `IS_BEING_TELEPORTED` niteliğini 
      (attribute) sıfırlar. Her zaman true döner (hatalar arka planda kaydedilir).

    ⏱️ ServerCooldownService (Sunucu Bekleme Süresi Servisi)
    --------------------------------------------------------
    *InitCooldowns(cooldownsTable: { [string]: number })* ⚙️
      Sağlanan isim ve süre tablosuna (saniye cinsinden) göre 
      bekleme süresi sayaçlarını (cooldowns) başlatır.

    *StartCooldown(cooldownName: string)* ⏳
      Belirtilen soğuma (cooldown) süresi için zamanlayıcıyı başlatır 
      veya yeniden başlatır.

    *IsOnCooldown(cooldownName: string) -> boolean* 🛡️
      Belirtilen bekleme süresinin şu anda aktif olup olmadığını kontrol 
      eder. Süre devam ediyorsa true döner.     

    *GetRemainingTime(cooldownName: string) -> number* 🔢
      Bekleme süresinin bitmesine kalan tam saniyeyi döner. Sona ermişse
      veya mevcut değilse 0 döner.

    💻 Client Services (İstemci Servisleri)
    ---------------------------------------
    Aşağıdaki istemci tarafı servis modülleri şu dizinde bulunur:
      ReplicatedStorage/Framework/Client/Services/

    💬 MutualChats (Ortak Sohbetler)
      - LocalPlayerCanChatWith(player) 🤝
          Yerel (local) oyuncu, belirtilen oyuncuyla herhangi bir sohbet 
          grubunu paylaşıyorsa true döner.
      - AttachBillboardToCharacter(character) 🚫💬
          Karakterin kafasına "sohbet edilemez" (no-chat) belirteci 
          (billboard) kopyalar ve ekler.
      - StartPlayersEvents() 🎧
          Ortak sohbet görünürlük kurallarını uygulamak için mevcut ve 
          yeni katılan oyuncuları dinlemeye (listener) başlar.
      - Start() 🏁
          Başlangıç noktasıdır; yerel oyuncunun gruplarının yüklenmesini 
          bekler ve ardından işlemleri başlatır.


    🛠️ Shared Utilities (Ortak Araçlar)
    -----------------------------------
    Aşağıdaki ortak araç modülleri şu dizinde bulunur:
      ReplicatedStorage/Framework/Shared/Util/
      
    ⏱️ TimeUtils (Zaman Araçları)
      - FormatToMMSS(seconds: number) 🕒
          Toplam saniyeyi MM:SS formatına dönüştürür (örn. "05:30").
      - FormatToHHMMSS(seconds: number) ⏱️
          Toplam saniyeyi HH:MM:SS formatına dönüştürür (örn. "01:05:30").
      - FormatToShortDHMS(seconds: number, useTurkish: boolean?) 📅
          Saniyeyi okunabilir kısa bir dizeye dönüştürür (örn. "1g 2sa 5dk").
      - GetTimeSince(unixTimestamp: number, useTurkish: boolean?) 🕰️
          Belirli bir os.time() zaman damgasının üzerinden ne kadar zaman 
          geçtiğini formatlı döndürür (örn. "5 dakika önce").
      - GetElapsedSeconds(startTick: number) ⌛
          Verilen startTick'ten bu yana geçen süreyi ondalık hassasiyetle 
          saniye cinsinden döndürür.

    🎉 End of services README. / Servisler README'sinin Sonu.
]]