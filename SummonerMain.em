/*  Sirikata
 *  default.em
 *
 *  Copyright (c) 2011, Kotaro Ishiguro
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *  * Neither the name of Sirikata nor the names of its contributors may
 *    be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* SummonerMain
 * Responsible for Initializing the Summoner Game in general.
 * Responsible for Generating the Summoner Main UI
 */
system.require("SummonerLibrary.em");
system.require("SummonerEffects.em");
system.require("SummonerBestiary.em");
system.require("SummonerNews.em");
system.require("SummonerUtil.em");
system.require("Summoner.em");

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerMain = @

system.require('std/core/repeatingTimer.em');

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.main) === "undefined") std.summoner.main = {};
if (typeof(std.summoner.summoner) === "undefined") std.summoner.summoner = {};
if (typeof(std.summoner._self) === "undefined") std.summoner._self = {};

/* Summoner Main UI */
(function () {
	var Sum = std.summoner.main;
	
	Sum.Init = function(parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("SummonerMain", \@
			sirikata.ui("SummonerMain", function() {
				$('<div id="Summoner-Main" title="Main Window">' + 
				  '  <div id="SummonerMainName">Enter Name: ' + 
				  '    <input id="SummonerMainNameQuery" type="text"></input>' +
				  '    <input id="SummonerMainNameDone" type="submit" value="Enter"></input>' +
				  '  </div>' +
				  '  <div id="SummonerMainOpen"> ' +
				  '    <input id="SummonerMainOpenSummon" type="button" value="Summon"></input>' + 
				  '    <input id="SummonerMainOpenBestiary" type="button" value="Bestiary"></input>' + 
				  '    <input id="SummonerMainOpenLibrary" type="button" value="Library"></input>' + 
				  '    <input id="SummonerMainOpenNews" type="button" value="News Feed"></input>' + 
				  '  </div> ' +
				  '  <div id="SummonerMainBody">' + 
				  '    <div id="SummonerMainExp"></div> ' +
				  '    Health: ' +
				  '    <div id="SummonerMainHealthMax" style="height:25px; background-color:rgb(255,200,200)"> '+
				  '      <div id="SummonerMainHealth" style="height:100%; background-color:red"></div> ' +
				  '    </div> ' +
				  '    Mana: ' +
				  '    <div id="SummonerMainManaMax" style="height:25px; background-color:rgb(200,200,255)"> ' +
				  '      <div id="SummonerMainMana" style="height:100%; background-color:blue"></div> ' + 
				  '    </div> ' +
				  '  </div> ' +
				  '</div>').appendTo('body');
				$("#Summoner-Main").dialog({
					width:430,
					height:'auto',
					modal:false,
					autoOpen:true
				});
				var SummonerSelf = {health_cur:-1, health_max:1000,mana_cur:-1, mana_max:-1, exp:-1};
				var SummonerHealthLength = 25;
				var SummonerManaLength = 25;
				SummonerMainHideAll();

				$("#SummonerMainNameDone").click(function() {SummonerMainEnterGame();});

				$("#SummonerMainOpenSummon").click(function() {SummonerMainToggleSummon();});
				$("#SummonerMainOpenBestiary").click(function () {SummonerMainToggleBestiary();});
				$("#SummonerMainOpenLibrary").click(function () {SummonerMainToggleLibrary();});
				$("#SummonerMainOpenNews").click(function() {SummonerMainToggleNews();});
				
				
				function SummonerMainEnterGame() {
					sirikata.event("SummonerStartGame", $("#SummonerMainNameQuery").val());
					SummonerMainShowAll();
				}
				
				function SummonerMainHideAll() {
					$("#SummonerMainOpen").hide();
					$("#SummonerMainBody").hide();
					$("#SummonerMainName").show();
				}
				
				function SummonerMainShowAll() {
					$("#SummonerMainOpen").show();
					$("#SummonerMainBody").show();
					$("#SummonerMainName").hide();
				}
				
				function SummonerMainToggleSummon() {
					SummonerMainToggle("#Summoner-Summon");
				}
				function SummonerMainToggleBestiary() {
					SummonerMainToggle("#Summoner-Bestiary");
				}
				function SummonerMainToggleLibrary() {
					SummonerMainToggle("#Summoner-Library");
				}
				function SummonerMainToggleNews() {
					SummonerMainToggle("#Summoner-Log");
				}
				function SummonerMainToggle(dialog_name) {
					if ($(dialog_name).dialog('isOpen')) $(dialog_name).dialog('close'); else $(dialog_name).dialog('open');
				}
				
				SummonerMainUpdate = function(obj) {
					if (SummonerSelf.health_cur != obj.health_cur)
						SummonerMainUpdateHealth(obj.health_cur);
					if (SummonerSelf.mana_cur != obj.mana_cur || SummonerSelf.mana_max != obj.mana_max)
						SummonerMainUpdateMana(obj.mana_cur, obj.mana_max);
					if (SummonerSelf.exp != obj.exp)
						SummonerMainUpdateExp(obj.exp);
					SummonerSelf = obj;
				};
				
				function SummonerMainUpdateHealth(health_cur) {
					var bars = 100 * (health_cur / SummonerSelf.health_max);
					$("#SummonerMainHealth").width(bars.toString() + "%");
					
				}
				function SummonerMainUpdateMana(mana_cur, mana_max) {
					var bars = 100 * (mana_cur / mana_max);
					$("#SummonerMainMana").width(bars.toString() + "%");
				}
				function SummonerMainUpdateExp(exp) {
					$("#SummonerMainExp").text("Experience: " + exp.toString());
				}
				
			});
		\@, std.core.bind(function(gui){
			this._SummonerMainModule = gui;
			SummonerEnterGame = function (player_name) {
				system.__debugPrint("Player is: " + player_name); 
				std.summoner.summoner.Init(player_name);
			};
			this._SummonerMainModule.bind("SummonerStartGame", SummonerEnterGame);
		}, this));
	};
})();

simulator._summoner = new std.summoner.main.Init(simulator);

// Set up Summoner Mechanics

var summoner_self;
var summoner_free;

/* std.summoner.summoner.Init
 * Initializes all the summoner variables
 * godmode is a boolean set to true for debugging purposes. It will set the user's parameters to be very high and unlock all traits and monsters.
 * All parameters are stored in std.summoner._self
 */
std.summoner.summoner.Init = function(name) {
	// Initialize Variables
	summoner_self = {};
	summoner_self.godmode = false; // ******************* GODMODE ***********************
	summoner_self.name = name;
	summoner_self.health_max = 1000;
	summoner_self.health_cur = summoner_self.health_max;
	summoner_self.health_regen = 50;
	summoner_self.exp = 10;
	if (summoner_self.godmode)
		summoner_self.exp = 10000;
	summoner_self.mana_max = std.summoner.util.CalcManaMax(summoner_self.exp);
	summoner_self.mana_cur = summoner_self.mana_max;
	summoner_self.mana_regen = std.summoner.util.CalcManaRegen(summoner_self.mana_max);
	summoner_self.traits = [];
	summoner_self.traits_left = [];
	summoner_self.monsters = [];
	summoner_self.monsters_left = [];
	summoner_self.alive = true;
	summoner_self.max_monsters = 3;
	summoner_self.hand = std.summoner.summoner.AllocateMonsters(summoner_self); // the player's hand (think card games)
	std.summoner.summoner.InitMonsters(summoner_self);
	
	summoner_free = {};
	summoner_free.bestiary = std.summoner.bestiary.Init();
	summoner_free.library = std.summoner.library.Init();
	summoner_free.graveyard = <999,999,999>;
	
	
	//std.summoner.summoner.AddButtons(summoner_free.library, summoner_free.bestiary);
	
	summoner_other = {};
	summoner_other.mana_regen_timer = new std.core.RepeatingTimer(4, std.summoner.util.Regen);
	summoner_other.learn_rate = 0.2;
	summoner_other.self_pres = system.self;
	
	summoner_share = {};
	summoner_share.targets = [];
	summoner_share.targets_priority = [];
	summoner_share.allies = [];
	summoner_share.dead = [];
	summoner_share.loggers = [];
	
	
	std.summoner._self.stats = summoner_self; /* stats has all the parameters unique to the player */
	std.summoner._self.fixed = summoner_free; /* fixed has the bestiary, library, and graveyard */
	std.summoner._self.other = summoner_other; /* other has the regeneration timer as well as other constants including the avatar presence*/
	std.summoner._self.share = summoner_share; /* share has all the target arrays. These are shared between all the player's monsters */
	
	simulator._summonerbestiary._SummonerBestiaryModule.call("SummonerBestiaryInit", summoner_free.bestiary);
	simulator._summonerlibrary._SummonerLibraryModule.call("SummonerLibraryInit", summoner_free.library);
	simulator._summonerlibrary._SummonerLibraryModule.call("SummonerLibraryUpdateUserTraitInfo", summoner_self.traits);
	simulator._summoner._SummonerMainModule.call("SummonerMainUpdate", summoner_self);
	
	
	
	std.summoner.summoner.InitLearned(std.summoner._self.stats, std.summoner._self.fixed.library, std.summoner._self.fixed.bestiary);
	std.summoner.util.Learn(std.summoner._self.stats, 0, {});
	std.summoner.log.Init();

	
	
	if (summoner_self.godmode) {
		var copy = [];
		for (i in summoner_self.traits_left)
			copy.push(summoner_self.traits_left[i]);
		std.summoner.summoner.UpdateLearnedTraits(std.summoner._self.stats, std.summoner._self.fixed.library, copy);
		std.summoner.summoner.UpdateLearnedBeasts(std.summoner._self.stats, std.summoner._self.fixed.bestiary);
	}
}

/* std.summoner.summoner.PrintStats
 * Debugging function that outputs the player's parameters
 */
std.summoner.summoner.PrintStats = function() {
	system.__debugPrint("\\nSUMMONER STATS: ");
	for (i in std.summoner._self.stats) {
		system.__debugPrint("\\n" + i + ": " + std.summoner._self.stats[i].toString());
	}	
}

/* std.summoner.summoner.AllocateMonsters
 * Initializes all the monster parameters for the player
 * i.e., generates std.summoner._self.stats.hand
 */
std.summoner.summoner.AllocateMonsters = function(summonerself) {
	var monsters = [];
	for (var i = 0; i < summonerself.max_monsters; i++) {
		monsters[i] = {
			num:i,
			owner: summonerself.name,
			name: "",
			traits: {},
			effects: {},
			presSelf: undefined,
			health_max: 0,
			health:0,
			power:0,
			speed:0,
			size:0,
			target: undefined,
			alive: false,
			banner_set: false,
			default_queryangle: 0.001,
			behaviorTimer: undefined,
			opa:undefined,
			summon_timestamp:0,
			effects_visual: undefined,
			MeshURL: ""
		};
	}
	return monsters;
}

/* std.summoner.summoner.InitMonsters
 * Initializes all the summoner presences for the player
 */
std.summoner.summoner.InitMonsters = function(summonerself) {
	for (var i = 0; i < summonerself.max_monsters; i++) {
		var pres = {
			mesh:"",
			scale:1,
			callback:std.summoner.monster.callbackwrapper(i),
			solidAngleQuery:0.0001
		};
		system.createPresence(pres);
	}
}

/* std.summoner.summoner.AddButtons
 * Fills the UI with summon-able monsters and append-able traits.
 * Should be called for each new monster/trait learned
 */
std.summoner.summoner.AddButtons = function(library, bestiary) {
	for (i in library)
		simulator._summoner_summon._SummonerModule.call("addTraitName", i, library[i].comp);
	for (i in bestiary)
		simulator._summoner_summon._SummonerModule.call("addMonsterOption", i, bestiary[i].Complexity);
}

/* std.summoner.summoner.InitLearned
 * Fills the parameters traits_left and monsters_left
 * The respective parameters are arrays for traits and monsters yet to be learned
 */
std.summoner.summoner.InitLearned = function(summoner, library, bestiary) {
	for (i in library)
		summoner.traits_left.push(i);
	for (i in bestiary)
		summoner.monsters_left.push(i);
}

/* std.summoner.summoner.UpdateLearnedBeasts
 * Transfer learned monsters from monsters_left to monsters if the player can learn them
 */
std.summoner.summoner.UpdateLearnedBeasts = function(summoner, bestiary) {
	for (var i = 0; i < summoner.monsters_left.length; i++)
		if (std.summoner.summoner.CanLearnBeast(summoner, bestiary[summoner.monsters_left[i]])) {
			summoner.monsters.push(summoner.monsters_left[i]);
			simulator._summoner_summon._SummonerModule.call("addMonsterOption", summoner.monsters_left[i], bestiary[summoner.monsters_left[i]].Complexity);
			std.summoner.log.Report("Learn_Monster", summoner.name, summoner.monsters_left[i], "", "");
			summoner.monsters_left.splice(i, 1);
			i--;
		}
}

/* std.summoner.summoner.UpdateLearnedTraits
 * Transfer learned traits from traits_left to traits if the player can learn them
 */
std.summoner.summoner.UpdateLearnedTraits = function(summoner, library, traits) {
	if (traits.length > 0) {
		var learning = "";
		for (i in traits)
			learning = learning + traits[i] + " ";
		//system.__debugPrint("\\nLEARNING TRAITS: " + learning);
	}
	for (var i = 0; i < traits.length; i++) {
		if (std.summoner.summoner.CanLearnTrait(summoner, traits[i])) {
			summoner.traits.push(traits[i]);
			var book = std.summoner.library.Lookup(traits[i]);
			simulator._summoner_summon._SummonerModule.call("addTraitName", traits[i], book.comp);
			std.summoner.log.Report("Learn_Trait", summoner.name, traits[i], "", "");
			for (j in summoner.traits_left)
				if (summoner.traits_left[j] == traits[i]) {
					summoner.traits_left.splice(j,1);
					break;
				}
			simulator._summonerlibrary._SummonerLibraryModule.call("SummonerLibraryUpdateUserTraitInfo", summoner_self.traits);
		}
	}
}

/* std.summoner.summoner.CanLearnBeast
 * Checks prerequisites of monster to see if player can learn them
 */
std.summoner.summoner.CanLearnBeast = function(summoner, beast) {
	if (summoner.exp < beast.Complexity) 
		return false;
	for (i in beast.PrereqTraits) {
		var hasTrait = false;
		for (j in summoner.traits) {
			if (summoner.traits[j] == beast.PrereqTraits[i]) {
				hasTrait = true;
				break;
			}
		}
		if (!hasTrait)
			return false;
	}
	return true;
}

/* std.summoner.summoner.CanLearnTrait
 * Checks prerequisites fo trait to see if player can learn them
 */
std.summoner.summoner.CanLearnTrait = function(summoner, trait) {
	for (i in summoner.traits_left) {
		if (summoner.traits_left[i] == trait)
			return true;
	}
	return false;
}

@;

