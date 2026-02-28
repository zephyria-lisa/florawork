--[[
 - @ Author: flora
 - @ Create Time: 2026-02-28 18:22:42
 - @ Modified by: flora
 - @ Modified time: 2026-02-28 18:25:01
 - @ Description: Bu modül, oyun içi mesajlaşma sisteminin yapılandırmasını içerir. Farklı mesajlaşma konuları (topics) tanımlayarak, sunucular arasında belirli olaylar veya veriler hakkında iletişim kurulmasını sağlar. Bu yapılandırma, mesajlaşma sisteminin hangi konuları destekleyeceğini ve hangi sunucuların bu konulara abone olacağını belirler. Böylece, oyun içi olaylar, oyuncu hareketleri veya diğer önemli bilgiler sunucular arasında etkili bir şekilde paylaşılabilir.
]]

local MessagingConfig = {}

--// Topic Names
MessagingConfig.Topics = {
	-- Example topics - customize as needed
	PLAYER_DATA_SYNC = "PlayerDataSync",
	PLAYER_JOINED = "PlayerJoined",
	PLAYER_LEFT = "PlayerLeft",
	SERVER_ANNOUNCEMENT = "ServerAnnouncement",
	GAME_EVENT = "GameEvent",
}

--// Topic Subscriptions
-- Define which servers should subscribe to topics (optional)
MessagingConfig.Subscriptions = {
	[MessagingConfig.Topics.PLAYER_DATA_SYNC] = true,
	[MessagingConfig.Topics.PLAYER_JOINED] = true,
	[MessagingConfig.Topics.PLAYER_LEFT] = true,
	[MessagingConfig.Topics.SERVER_ANNOUNCEMENT] = true,
	[MessagingConfig.Topics.GAME_EVENT] = true,
}

return MessagingConfig
