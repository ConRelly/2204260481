"use strict";

var TutorialPage = 0
var playerPanels = {};

function UpdateTimer( data )
{
}

function UpdatePresentTimer( data )
{
}

function FrostivusBegins()
{
	$("#FrostivusHUD_alt").style.visibility = "visible";
	$.Msg("Initialize HpBars2 stuff")
	//$("#FrostivusScore").style.visibility = "visible";
}

/* var toggle = true
function FrostivusAltar() {
	if (toggle == false) {
		$("#FrostivusAltarMenu").style.visibility = "visible";
		toggle = true
	}
	else {
		$("#FrostivusAltarMenu").style.visibility = "collapse";
		toggle = false
	}
}

function PrevTutorial() {
	if (TutorialPage > 0) {
		TutorialPage = TutorialPage -1
		$("#TutorialTitle").text = $.Localize("#frostivus_phase_" + TutorialPage) + ":";
		$("#TutorialTextLine").text = $.Localize("#frostivus_phase_" + TutorialPage + "_desc");
		$("#NextTutorial").style.visibility = "visible";
	}
}

function NextTutorial() {
	if (TutorialPage < 2) {
		TutorialPage = TutorialPage +1
		$("#TutorialTitle").text = $.Localize("#frostivus_phase_" + TutorialPage) + ":";
		$("#TutorialTextLine").text = $.Localize("#frostivus_phase_" + TutorialPage + "_desc");
		$("#PreviousTutorial").style.visibility = "visible";
	}
}

function OpenTutorial() {
	$("#TutorialPanel").style.visibility = "visible";
}

function CloseTutorial() {
	$("#TutorialPanel").style.visibility = "collapse";
}

function ChooseAltar(number) {
	var altar = $("#AltarButton" + number)
	var playerInfo = Game.GetPlayerInfo(Players.GetLocalPlayer())

	if (playerInfo.player_team_id == 2) {
		if (altar.BHasClass("radiant")) {
			var panel_table = $("#FrostivusAltarMenu").FindChildrenWithClassTraverse("selected");
			for (var i = 0; i < panel_table.length; i++) {
				panel_table[i].RemoveClass("selected")
			}
			altar.AddClass("selected");
			GameEvents.SendCustomGameEventToServer("spawn_point", {"player": Players.GetLocalPlayer(), "altar": number});
		}
	} else if (playerInfo.player_team_id == 3) {
		if (altar.BHasClass("dire")) {
			var panel_table = $("#FrostivusAltarMenu").FindChildrenWithClassTraverse("selected");
			for (var i = 0; i < panel_table.length; i++) {
				panel_table[i].RemoveClass("selected")
			}
			altar.AddClass("selected");
			GameEvents.SendCustomGameEventToServer("spawn_point", {"player": Players.GetLocalPlayer(), "altar": number});
		}
	}
} */

/* function OnPlayerReconnect( data ) {
	$.Msg("Frostivus: Player has reconnected!")
	$.Msg("Phase: " + data.Phase)
	$("#FrostivusHUD_alt").style.visibility = "visible";
}
 */
function UpdateBossBar(args) {

	var BossTable = CustomNetTables.GetTableValue("game_options", "boss");
	if (BossTable !== null)
	{
		var BossHP = BossTable.HP;
		var BossHP_percent = BossTable.HP_alt;
		var BossMaxHP = BossTable.maxHP;
		var BossLvl = BossTable.level;
		var BossLabel = BossTable.label;
		var BossShortLabel = BossTable.short_label;
		var TeamContest = BossTable.team_contest;
		var bar_color = 'gradient( linear, 0% 0%, 0% 100%, from( #660000 ), color-stop( 0.3, #cc0000 ), color-stop( .5, #cc0000 ), to( #660000 ) )';
		//var bar_color = "";
		
		$("#BossProgressBar" + TeamContest).value = BossHP_percent / 100;
		$("#BossHealth" + TeamContest).text = BossHP + "  /  " + BossMaxHP;

		if (BossShortLabel == "nevermore") {
			bar_color = 'gradient( linear, 0% 0%, 0% 100%, from( #660000 ), color-stop( 0.3, #cc0000 ), color-stop( .5, #cc0000 ), to( #660000 ) )';
		} else if (BossShortLabel == "venomancer") {
			bar_color = 'gradient( linear, 0% 0%, 0% 100%, from( #326114 ), color-stop( 0.3, #54BA07 ), color-stop( .5, #54BA07 ), to( #326114 ) )';
		} else if (BossShortLabel == "treant") {
			bar_color = 'gradient( linear, 0% 0%, 0% 100%, from( #808080 ), color-stop( 0.3, #808080 ), color-stop( .5, #595959 ), to( #595959 ) )';
		} else if (BossShortLabel == "zuus") {
			bar_color = 'gradient( linear, 0% 0%, 0% 100%, from( #1A75FF ), color-stop( 0.3, #66a3ff ), color-stop( .5, #66a3ff ), to( #1A75FF ) )';
		}

		$("#BossProgressBar" + TeamContest + "_Left").style.backgroundColor = bar_color;
		//$("#BossCastProgressBar" + TeamContest + "_Left").style.backgroundColor = bar_color;
		//$("#BossCastProgressBar" + TeamContest + "_2_Left").style.backgroundColor = bar_color;

		$("#BossLevel" + TeamContest).text = $.Localize("boss_level") + BossLvl
		$("#BossLabel" + TeamContest).text = $.Localize(BossLabel)
		//$("#BossIcon" + TeamContest).style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_'+ BossShortLabel +'.png")';
		//$("#BossIcon" + TeamContest).style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_nevermore.png")';
		//$.Msg("UpdateBossbar Complete")
	}
}

function ShowBossBar(args)
{
	//var playerInfo = Game.GetPlayerInfo(Players.GetLocalPlayer())
	$("#FrostivusHUD_alt").style.visibility = "visible";
	$("#BossHP2").style.visibility = "visible";
	//$.Msg("Show Boss Bar2")
}

function HideBossBar(args)
{
	//var playerInfo = Game.GetPlayerInfo(Players.GetLocalPlayer())
	$("#BossHP2").style.visibility = "collapse";
	$("#BossLevel2").text = "";
	//$.Msg("Hide Boss Bar2")
}

/* function UpdateAltar(args)
{
	if (args.team == 2) {
		if ($("#AltarButton" + args.altar).BHasClass("dire")) {
			$("#AltarButton" + args.altar).RemoveClass("dire")
		}
		$("#AltarButton" + args.altar).AddClass("radiant");
	} else {
		if ($("#AltarButton" + args.altar).BHasClass("radiant")) {
			$("#AltarButton" + args.altar).RemoveClass("radiant")
		}
		$("#AltarButton" + args.altar).AddClass("dire");
	}

//	$("#AltarState" + args.altar).style.backgroundImage = 'url("file://{images}/custom_game/altar_captured_' + args.team + '.png")';
//	$.Msg("Added a new altar: " + args.altar + " for team: " + args.team)

	var localTeam = Players.GetTeam(Players.GetLocalPlayer())
	if (localTeam == 2) {
		var radiantPlayers = Game.GetPlayerIDsOnTeam( DOTATeam_t.DOTA_TEAM_GOODGUYS );
		$.Each( radiantPlayers, function( player ) {
			if ($("#AltarButton" + args.altar).BHasClass("selected") && $("#AltarButton" + args.altar).BHasClass("dire")) {
				$("#AltarButton" + args.altar).RemoveClass("selected")
				$("#AltarButton1").AddClass("selected");
			}
			GameEvents.SendCustomGameEventToServer("spawn_point", {"player": Players.GetLocalPlayer(), "altar": 1});
		});
	} else if (localTeam == 3) {
		var direPlayers = Game.GetPlayerIDsOnTeam( DOTATeam_t.DOTA_TEAM_BADGUYS );
		$.Each( direPlayers, function( player ) {
			if ($("#AltarButton" + args.altar).BHasClass("selected") && $("#AltarButton" + args.altar).BHasClass("radiant")) {
				$("#AltarButton" + args.altar).RemoveClass("selected")
				$("#AltarButton7").AddClass("selected");
			}
			GameEvents.SendCustomGameEventToServer("spawn_point", {"player": Players.GetLocalPlayer(), "altar": 7});
		});
	}
}

function CastBar(args)
{
	var playerInfo = Game.GetPlayerInfo(Players.GetLocalPlayer())
	$("#BossCastAbility" + playerInfo.player_team_id).abilityname = args.ability_image;
	$("#BossCastAbilityName" + playerInfo.player_team_id).text = $.Localize(args.ability_name);
	$("#BossCastTimeLabel" + playerInfo.player_team_id).text = args.current_cast_time.toFixed(1) + "/" + args.cast_time.toFixed(1);
	$("#BossCastProgressBar" + playerInfo.player_team_id).value = args.current_cast_time / args.cast_time;

//	$.Msg(args.current_cast_time)
	if (args.current_cast_time != 0) {
		$("#BossCastBar" + playerInfo.player_team_id).style.visibility = "visible";
	} else {
		$("#BossCastBar" + playerInfo.player_team_id).style.visibility = "collapse";
	}
}

function CastBarAlt(args)
{
	var playerInfo = Game.GetPlayerInfo(Players.GetLocalPlayer())
	$("#BossCastAbility" + playerInfo.player_team_id + "_2").abilityname = args.ability_image;
	$("#BossCastAbilityName" + playerInfo.player_team_id + "_2").text = $.Localize(args.ability_name);
	$("#BossCastTimeLabel" + playerInfo.player_team_id + "_2").text = args.current_cast_time.toFixed(1) + "/" + args.cast_time.toFixed(1);
	$("#BossCastProgressBar" + playerInfo.player_team_id + "_2").value = args.current_cast_time / args.cast_time;

//	$.Msg(args.current_cast_time)
	if (args.current_cast_time != 0) {
		$("#BossCastBar" + playerInfo.player_team_id + "_2").style.visibility = "visible";
	} else {
		$("#BossCastBar" + playerInfo.player_team_id + "_2").style.visibility = "collapse";
	}
} */

(function()
{
/* 	$("#AltarButton1").AddClass("radiant");
	//$("#AltarState1").style.backgroundImage = 'url("file://{images}/custom_game/altar_captured_2.png")';
	$("#AltarState2").style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_zuus.png")';
	$("#AltarState3").style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_venomancer.png")';
//	$("#AltarState4").style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_lich.png")';
	$("#AltarState5").style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_treant.png")';
	$("#AltarState6").style.backgroundImage = 'url("file://{images}/heroes/icons/npc_dota_hero_nevermore.png")';
	$("#AltarButton7").AddClass("dire"); */
	//$("#AltarState7").style.backgroundImage = 'url("file://{images}/custom_game/altar_captured_3.png")';

//	var hudElements = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("HUDElements");
//	var minimap = hudElements.FindChildTraverse("minimap")

	/* For reasons it doesn't find the class for extra minimap option enabled */
//	if (minimap.BHasClass("MinimapExtraLarge")) {
//		$.Msg("Super minimap!")
//	}

	//GameEvents.Subscribe("countdown", UpdateTimer);
	//GameEvents.Subscribe("countdown_present", UpdatePresentTimer);
	CustomNetTables.SubscribeNetTableListener("game_options", UpdateBossBar);
	GameEvents.Subscribe("frostivus_begins", FrostivusBegins);
	//GameEvents.Subscribe("frostivus_player_reconnected", OnPlayerReconnect);
	GameEvents.Subscribe("show_boss_hp", ShowBossBar);
	GameEvents.Subscribe("hide_boss_hp", HideBossBar);
	$.Msg("GameEvents Subscribe complete")
	//GameEvents.Subscribe("update_altar", UpdateAltar);
	//GameEvents.Subscribe("BossStartedCast", CastBar);
	//GameEvents.Subscribe("BossStartedCastAlt", CastBarAlt);
	//GameEvents.Subscribe("open_tutorial", OpenTutorial)
})();
