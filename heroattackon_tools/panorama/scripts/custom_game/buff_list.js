"use strict";

var m_BuffPanels = [];
var m_DeBuffPanels = []; 

function UpdateBuff( buffPanel, queryUnit, buffSerial, debuff )
{
	
	buffPanel.Data().m_QueryUnit = queryUnit;
	buffPanel.Data().m_BuffSerial = buffSerial;
	
	var buffTexture = Buffs.GetTexture( queryUnit, buffSerial );

	var buffImage = buffPanel.FindChildInLayoutFile( "BuffImg" );
	
	var isItem = ( buffTexture.indexOf( "item" ) != -1 );
	
	buffPanel.FindChildInLayoutFile( "BuffImgAlt" ).SetImage( "s2r://panorama/images/spellicons/" + buffTexture + ".png" );
	buffPanel.FindChildInLayoutFile( "BuffImgOther" ).SetImage( "raw://resource/flash3/images/spellicons/" + buffTexture + ".png" );
	
	if ( isItem ) {
		var itemImg = buffPanel.FindChildInLayoutFile( "ItemImg" );
		buffImage.SetImage( "raw://resource/flash3/images/items/" + buffTexture.substring(5) + ".png" );
		itemImg.itemname = buffTexture;
		buffPanel.SetHasClass( "item_buff", true );
		buffPanel.SetHasClass( "ability_buff", false );
	}
	else {
		var abilityImg = buffPanel.FindChildInLayoutFile( "AbilityImg" );
		buffImage.SetImage( "raw://resource/flash3/images/spellicons/" + buffTexture + ".png" );
		abilityImg.abilityname = buffTexture;
		buffPanel.SetHasClass( "item_buff", false );
		buffPanel.SetHasClass( "ability_buff", true );
	}
	
	
	var cooldownLength = Buffs.GetDuration( queryUnit, buffSerial );
	let durationPanel = buffPanel.FindChildInLayoutFile( "CircularDuration" );
	if ( debuff && cooldownLength == 1 ) { durationPanel.style.clip = "radial( 50.0% 50.0%, 0.0deg, -360deg)";return; }
	if ( !debuff && cooldownLength == 0.5 ) { durationPanel.style.clip = "radial( 50.0% 50.0%, 0.0deg, -360deg)";return; }
	
	if (cooldownLength > 0) {
		let cooldownRemaining = Buffs.GetRemainingTime( queryUnit, buffSerial );
		let cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		let deg = -360 * cooldownPercent * 0.01;
		durationPanel.style.clip = "radial( 50.0% 50.0%, 0.0deg, "+deg+"deg)";
	} else {
		durationPanel.style.clip = "radial( 50.0% 50.0%, 0.0deg, -360deg)";
	}	
}

function UpdateBuffs()
{
	var buffsListPanel = $( "#buffs_list" );
	if ( !buffsListPanel )
		return;
	var debuffsListPanel = $( "#debuffs_list" );
	if ( !debuffsListPanel )
		return;
	
	var queryUnit = Players.GetLocalPlayerPortraitUnit();
	
	var nBuffs = Entities.GetNumBuffs( queryUnit );
	
	var nUsedPanelsbuff = 0;
	var nUsedPanelsdebuff = 0;

	for ( var i = 0; i < nBuffs; ++i )
	{
		var buffSerial = Entities.GetBuff( queryUnit, i );
		if ( buffSerial == -1 )
			continue;

		if ( Buffs.IsHidden( queryUnit, buffSerial ) )
			continue;
		
		var nNumStacks = Buffs.GetStackCount( queryUnit, buffSerial );
		
		if ( Buffs.IsDebuff( queryUnit, buffSerial ) ) 
		{
			if ( nUsedPanelsbuff > 15 ) continue;
			if ( nUsedPanelsdebuff >= m_DeBuffPanels.length )
			{
				var buffPanel = $.CreatePanel( "Panel", debuffsListPanel, "" );
				buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/buff_list_buff.xml", false, false );
				m_DeBuffPanels.push( buffPanel );
			}
			var buffPanel = m_DeBuffPanels[ nUsedPanelsdebuff ];
			UpdateBuff( buffPanel, queryUnit, buffSerial, true );
			buffPanel.SetHasClass( "is_debuff", true );
			nUsedPanelsdebuff++;
		}
		else
		{
			if ( nUsedPanelsbuff > 31 ) continue;
			if ( nUsedPanelsbuff >= m_BuffPanels.length )
			{
				var buffPanel = $.CreatePanel( "Panel", buffsListPanel, "" );
				buffPanel.BLoadLayout( "file://{resources}/layout/custom_game/buff_list_buff.xml", false, false );
				m_BuffPanels.push( buffPanel );
			}
			var buffPanel = m_BuffPanels[ nUsedPanelsbuff ];
			UpdateBuff( buffPanel, queryUnit, buffSerial, false );
			buffPanel.SetHasClass( "is_debuff", false );
			nUsedPanelsbuff++;
		}
		buffPanel.SetHasClass( "has_stacks", nNumStacks > 0 ); 
		buffPanel.FindChildInLayoutFile( "StackCount" ).text = nNumStacks;
		buffPanel.SetHasClass( "no_buff", false );
	}
	
	for ( var i = nUsedPanelsbuff; i < m_BuffPanels.length; ++i )
	{
		var buffPanel = m_BuffPanels[ i ];
		buffPanel.SetHasClass( "no_buff", true );
	}
	
	for ( var i = nUsedPanelsdebuff; i < m_DeBuffPanels.length; ++i )
	{
		var buffPanel = m_DeBuffPanels[ i ];
		buffPanel.SetHasClass( "no_buff", true );
	}
	
	$( "#BuffBlock" ).SetHasClass( "bShrink", nUsedPanelsbuff > 13 );
}

function AutoUpdateBuffs()
{
	UpdateBuffs();
	$.Schedule( 0.06, AutoUpdateBuffs );
}

function HiddenBuffPanel(){
	let base = $.GetContextPanel().GetParent().GetParent().GetParent();
	base.FindChildTraverse("BuffContainer").visible = false;
}

(function()
{
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateBuffs );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateBuffs );
	GameEvents.Subscribe( "dota_player_update_killcam_unit", UpdateBuffs );
	AutoUpdateBuffs();
	HiddenBuffPanel();
})();

