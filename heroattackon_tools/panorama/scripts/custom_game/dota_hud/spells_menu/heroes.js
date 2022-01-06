var customSpellsMenuPanel = $("#SpellsMenuContents");
var openSpellsMenu = $("#SpellsMenuOpen");
var spellsMenuCardPoints = customSpellsMenuPanel.FindChildTraverse("SpellsMenuCardIdPoints");

var spellSwapFirstSelected = null;
var spellSwapSecondSelected = null;

var heroes = [

];

var specials = [

];

var spells = {

};


function CreateHeroesListingForAll() {
    var heroesContainer;

    // Divide them into categories of Strength, Agility and Intelligence
    var heroPanel;
    for (var category = 0; category < heroes.length; category++) {
        if (category === 0) {
            // Strength
            heroesContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuHeroesStrengthBlock");
        } else if (category === 1) {
            // Agility
            heroesContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuHeroesAgilityBlock");
        } else if (category === 2) {
            // Intelligence
            heroesContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuHeroesIntelligenceBlock");
        }

        for (var i = 0; i < heroes[category].length; i++) {
            heroPanel = $.CreatePanel("Panel", heroesContainer, "heroPanel" + i);
            CreateHeroesListing(heroPanel, heroes[category][i]);
        }
    }

    var specialsContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuSpecialsBlock");
    for (var specialCategory = 0; specialCategory < specials.length; specialCategory++) {
        var specialPanel = $.CreatePanel("Panel", specialsContainer, "specialPanel" + specialCategory);
        CreateSpecialsListing(specialPanel, specials[specialCategory]);
    }
}

function CreateHeroesListing(heroPanel, hero) {
    heroPanel.BLoadLayoutSnippet("hero");

    // Set the picture to display
    var heroData = hero.name_id;
    var image = heroPanel.FindChildInLayoutFile("HeroPictureImage");
    image.heroname = heroData;
    // Set the onactivate
    var heroButton = heroPanel.FindChildInLayoutFile("HeroPanelButton");
    heroButton.SetPanelEvent("onactivate", Function("OpenSpellsListForHero(\"" + heroData + "\")"));
}

function CreateSpecialsListing(specialsPanel, special) {
    specialsPanel.BLoadLayoutSnippet("special");

    // Set the picture to display
    var image = specialsPanel.FindChildInLayoutFile("SpecialPictureImage");
    image.SetImage("file://{images}/spells_menu/" + special.image);
    // Set the onactivate
    var specialButton = specialsPanel.FindChildInLayoutFile("SpecialPanelButton");
    specialButton.SetPanelEvent("onactivate", Function("OpenSpellsListForHero(\"" + special.name_id + "\")"));
}

function CreateSpellsListingForHero(heroID) {
    var spellsContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuSpellsBlock");
    // Clear children
    CloseSpellsListingForHero();

    var heroSpells = spells[heroID];
    var spellPanel;
    for (var i = 0; i < heroSpells.length; i++) {
        var individualHeroSpell = heroSpells[i];
        spellPanel = $.CreatePanel("Panel", spellsContainer, "spellPanel" + i);
        spellPanel.BLoadLayoutSnippet("spell");

        var image = spellPanel.FindChildInLayoutFile("SingleSpellPictureImage");
        image.abilityname = individualHeroSpell.spell_id;
        var spellCost = spellPanel.FindChildInLayoutFile("SpellCost");
        spellCost.text = individualHeroSpell.cost;
        var spellButton = spellPanel.FindChildInLayoutFile("SingleSpellPanelButton");
        var spellStringified = JSON.stringify(individualHeroSpell);
        spellButton.SetPanelEvent("onactivate", Function("BuySpell(\'" + spellStringified + "\')"));
        // Hover events
        spellButton.SetPanelEvent("onmouseover", Function("$.DispatchEvent( \"DOTAShowAbilityTooltip\", \"" + individualHeroSpell.spell_id + "\")"));
        spellButton.SetPanelEvent("onmouseout", function () {
            $.DispatchEvent("DOTAHideAbilityTooltip");
        });
    }
}

function OpenSpellsMenu() {
    customSpellsMenuPanel.SetHasClass("Visible", true);
    openSpellsMenu.SetHasClass("Visible", false);
}

function CloseSpellsMenu() {
    customSpellsMenuPanel.SetHasClass("Visible", false);
    openSpellsMenu.SetHasClass("Visible", true);

    CloseSpellsListingForHero();
}

function OpenSpellsListForHero(heroID) {
    CreateSpellsListingForHero(heroID);
}

function CloseSpellsListingForHero() {
    var spellsContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuSpellsBlock");
    // Clear children
    spellsContainer.RemoveAndDeleteChildren();
}

function BuySpell(spellJson) {
    var spellObj = JSON.parse(spellJson);
    spellObj.player_id = Game.GetLocalPlayerID();
    GameEvents.SendCustomGameEventToServer("spells_menu_buy_spell", spellObj);
}

function BuySpellFeedback(event_data) {
    CloseSpellsMenu();

    // Update amount of CP
    var nNewValue = event_data.new_card_points;
    spellsMenuCardPoints.text = nNewValue;
    spellsMenuCardPoints.SetAttributeInt("value", nNewValue);
}

function OpenSpellsListingForPlayerHero() {
    var event_data = {
        player_id: Game.GetLocalPlayerID()
    }
    GameEvents.SendCustomGameEventToServer("spells_menu_get_player_spells", event_data);
}

function GetPlayerSpellsFeedback(event_data) {
    // show spells
    var playerHeroSpellsContainer = customSpellsMenuPanel.FindChildTraverse("SpellsMenuSpellsBlock");
    // Clear children
    CloseSpellsListingForHero();

    var heroSpells = event_data.player_abilities;
    var spellPanel;
    for (var key in heroSpells) {
        if (heroSpells.hasOwnProperty(key)) {
            var individualHeroSpellName = heroSpells[key];
            spellPanel = $.CreatePanel("Panel", playerHeroSpellsContainer, "spellPanel" + key);
            spellPanel.BLoadLayoutSnippet("spell");

            var image = spellPanel.FindChildInLayoutFile("SingleSpellPictureImage");
            image.abilityname = individualHeroSpellName;
            var spellCost = spellPanel.FindChildInLayoutFile("SpellCost");
            spellCost.text = "0";
            var spellButton = spellPanel.FindChildInLayoutFile("SingleSpellPanelButton");
            spellButton.SetPanelEvent("onactivate", Function("SpellSwapSelect(\'" + individualHeroSpellName + "\')"));
            // Hover events
            spellButton.SetPanelEvent("onmouseover", Function("$.DispatchEvent( \"DOTAShowAbilityTooltip\", \"" + individualHeroSpellName + "\")"));
            spellButton.SetPanelEvent("onmouseout", function () {
                $.DispatchEvent("DOTAHideAbilityTooltip");
            });
        }
    }
}

function SpellSwapSelect(spellName) {
    if (spellSwapFirstSelected != null) {
        spellSwapSecondSelected = spellName;

        var playerID = Game.GetLocalPlayerID();
        var event_data = {
            player_id: playerID,
            first_ability_name: spellSwapFirstSelected,
            second_ability_name: spellSwapSecondSelected
        };
        GameEvents.SendCustomGameEventToServer("spells_menu_swap_player_spells", event_data);
        // Clear selections
        spellSwapFirstSelected = null;
        spellSwapSecondSelected = null;
    } else {
        spellSwapFirstSelected = spellName;
    }

}

function SwapPlayerSpellsFeedback() {
    CloseSpellsMenu();
}

(function () {
    CreateHeroesListingForAll();

    GameEvents.Subscribe("spells_menu_buy_spell_feedback", BuySpellFeedback);
    GameEvents.Subscribe("spells_menu_get_player_spells_feedback", GetPlayerSpellsFeedback);
    GameEvents.Subscribe("spells_menu_swap_player_spells_feedback", SwapPlayerSpellsFeedback);
})();