Config = {}

Config.Debug = false -- Kun pil ved dette, hvis du ved hvad du laver!
Config.DebugPoly = false -- Kun pil ved dette, hvis du ved hvad du laver!
Config.DevMode = false -- Hvis true, kan folk IKKE tilgå genbrugsstationen.

Config.Enter = vec3(237.3116, -1855.0204, 26.8329) -- Hvor du går ind (Også hvor du kommer hen når du går ud)

Config.MinXP = 1
Config.MaxXP = 3

Config.SearchTime = math.random(3000, 9000) -- Tid det tager at søge.
Config.PunchInTime = 8000 -- Tid det tager at stemple ind.
Config.ComputerTime = 1000 -- Tid det tager at åbne computeren.
Config.DisposeTime = 4000 -- Tid det tager for man får sin reward.

Config.Rewards = { -- Alt det man kan få.
    { item = 'steel', min = 1, max = 3, percentage = 12 },
    { item = 'copper', min = 2, max = 5, percentage = 20 },
    { item = 'iron', min = 3, max = 7, percentage = 20 },
    { item = 'black_money', min = 414, max = 884, percentage = 10},
    { item = 'painting_2', min = 3, max = 2, percentage = 5, rare = true},
    { item = 'lockpick_advanced', min = 1, max = 1, percentage = 2, rare = true},
}
