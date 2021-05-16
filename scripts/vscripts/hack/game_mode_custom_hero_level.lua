
-- 设置英雄的最大等级，以及每级的经验
-- InitGameMode 函数中调用
-- 参考：http://www.dota2rpg.com/forum.php?mod=viewthread&tid=4320


function CustomHeroLevel()
	CustomHeroLevel_Formula()
end

function CustomHeroLevel_Formula( )
	local MAX_LEVEL = 99
	local xpTable = {}
	for i=1, MAX_LEVEL do
		xpTable[i] = 50 * (i - 1) * (i + 2)
		-- print(tostring(i) .. ": " .. tostring(xpTable[i]))
	end

	-- CDOTABaseGameMode
	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetUseCustomHeroLevels(true)
	GameMode:SetCustomHeroMaxLevel(MAX_LEVEL)
	GameMode:SetCustomXPRequiredToReachNextLevel(xpTable)
end

function CustomHeroLevel_Constant()		
	local MAX_LEVEL = 99
	local xpTable = {
		0,-- 1
		200,-- 2
		500,-- 3
		900,-- 4
		1400,-- 5
		2000,-- 6
		2640,-- 7
		3300,-- 8
		3980,-- 9
		4680,-- 10
		5400,-- 11
		6140,-- 12
		7340,-- 13
		8565,-- 14
		9815,-- 15
		11090,-- 16
		12390,-- 17
		13715,-- 18
		15115,-- 19
		16605,-- 20
		18205,-- 21
		20105,-- 22
		22305,-- 23
		24805,-- 24
		27500,-- 25
		29000,--26
		31000,--27
		32000,--28
		33000, 	--29
		33500, 	--30
		34000, 	--31
		34500, 	--32
		35000, 	--33
		35500, 	--34
		36000, 	--35
		36500, 	--36
		37000, 	--37
		37500, 	--38
		38000, 	--39
		38500, 	--40
		39000, 	--41
		39500, 	--42
		40000, 	--43
		40500, 	--44
		41000, 	--45
		41500, 	--46
		42000, 	--47
		42500, 	--48
		43000, 	--49
		43500, 	--50
		44000, 	--50
		44500, 	--51
		45000, 	--52
		45500, 	--53
		46000, 	--54
		46500, 	--55
		47000, 	--56
		47500, 	--57
		48000, 	--58
		48500, 	--59
		49000, 	--60
		49500, 	--61
		50000, 	--62
		50500, 	--63
		51000, 	--64
		51500, 	--65
		52000, 	--66
		52500, 	--67
		53000, 	--68
		53500, 	--69
		54000, 	--70
		54500, 	--71
		55000, 	--72
		55500, 	--73
		56000, 	--74
		56500, 	--75
		57000, 	--76
		57500, 	--77
		58000, 	--78
		58500, 	--79
		59000, 	--80
		59500, 	--81
		60000, 	--82
		60500, 	--83
		61000, 	--84
		61500, 	--85
		62000, 	--86
		62500, 	--87
		63000, 	--88
		63500, 	--89
		64000, 	--90
		64500, 	--91
		65000, 	--92
		65500, 	--93
		66000, 	--94
		66500, 	--95
		67000, 	--96
		67500, 	--97
		68000, 	--98
	}
	-- CDOTABaseGameMode
	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetUseCustomHeroLevels(true)
	GameMode:SetCustomHeroMaxLevel(MAX_LEVEL)
	GameMode:SetCustomXPRequiredToReachNextLevel(xpTable)
end