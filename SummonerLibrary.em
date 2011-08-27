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

/* SummonerLibrary
 * This file is responsible for generating the Library UI as well as the map for traits.
 * The map for traits is initialized in SummonerMain and is stored in std.summoner._self.fixed.library
 * It also has some utility functions for using traits
 */
 
if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerLibrary = @

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.library) === "undefined") std.summoner.library = {};

/* Summoner Library UI */
(function () {
	var Sum = std.summoner;
	
	Sum.SummonerLibraryInit = function (parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("SummonerLibrary", \@
			sirikata.ui("SummonerLibrary", function() {
				$('<div id="Summoner-Library" title="Library">' + 
				  '  <div id="SummonerLibrary_temptxt"></div>' + 
				  '  <div id="SummonerLibraryBookTitle" style="float:left;width:30%"></div>' +
				  '  <div id="SummonerLibraryBook">qpwijfoiewjfoiqjewoifjq</div>' +
				  '</div>').appendTo('body');
				$("#Summoner-Library").dialog({
					width:600,
					height:'auto',
					modal:false,
					autoOpen:false
				});
				
				var traits;
				var user_traits = {};
				var title = "SummonerLibraryBookTitle";
				var book = "SummonerLibraryBook";
				
				
				SummonerLibraryInit = function(obj) {
					traits = obj;
					SummonerLibraryGenerateBooks(traits);
					SummonerLibraryUpdateUserTraitInfo(user_traits);
				}
				
				function SummonerLibraryGenerateBooks(traits) {
					for (i in traits) {
						var newbook = '<div id="' + title + i + '">' + i + '</div>';
						(function(i, newbook){
							var i_lower = i.toLowerCase();
							$("#" + title).append(newbook);
							$("#" + title + i_lower).mouseover(function() {
								$("#" + title + i_lower).css("background-color","rgb(200,191,231)");
							});
							$("#" + title + i_lower).mouseout(function() {
								$("#" + title + i_lower).css("background-color","rgb(255,255,255)");
							});
							$("#" + title + i_lower).click(function() {
								$("#" + book).text("");
								$("#" + book).append(traits[i].desc + "<br/>" + traits[i].eff);
							});
						})(i, newbook);
					}
				}
				SummonerLibraryUpdateUserTraitInfo = function (user_traits) {
					for (i in user_traits) {
						(function(i) {
							$("#" + title + i).css("font-weight", "bold");
							$("#" + title + i).css("color", "red");
						})(user_traits[i].toLowerCase());
					}
				}
				SummonerLibraryGetUserTraits = function(obj) {
					return obj;
				}
				
			});
		\@, std.core.bind(function(gui){this._SummonerLibraryModule = gui;}, this));
	}
})();

simulator._summonerlibrary = new std.summoner.SummonerLibraryInit(simulator);

/* std.summoner.library.Init
 * Generates and returns the library of monster traits
 * Key: trait_name
 * Value: {trait_name, trait_desc_long, trait_desc_short, complexity}
*/
std.summoner.library.Init = function() {
	return {
		fuzzy: std.summoner.library.InitTrait("fuzzy", "Fuzzy monsters are furry and cuddly and huggable and cute. All that fuzzy fur and fat also makes them very punchable and stabbable.", "+50% Health. +1 Complexity", 1),
		small: std.summoner.library.InitTrait("small", "Awww, this monster is so small and cute... Aww, this monster is so small and useless...", "50% size. -25% Power. -4 Complexity", -4),
		insane: std.summoner.library.InitTrait("insane", "This is an insane monster. It wreaks havoc without aim or purpose. Since it goes for anything close by, its first target is usually the summoner himself.","+500% Power. +10 Complexity. Targets everything", 10),
		slow: std.summoner.library.InitTrait("slow", "This monster is slow. Physically and mentally. They are pitiful creations made by summoners who were too lazy to give their monster a brain.","-50% Speed. -7 Complexity", -7),
		fast: std.summoner.library.InitTrait("fast", "Zoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooom", "+100% Speed. +4 Complexity", 4),
		big: std.summoner.library.InitTrait("big", "Oooh, this is a reeeeeeaaaally big monster. It must hurt to be stomped by this monster.", "200% Size. +200% Power. +200% Health. +7 Complexity", 7),
		splitting: std.summoner.library.InitTrait("splitting", "A monster with 'splitting' has mastered the arts of asexual reproduction, but only does so when stimulated by an external source", "+10 Complexity. Random chance to Duplicate upon getting attacked", 13),
		devouring: std.summoner.library.InitTrait("devouring", "This monster doesn't rely on weapons for fighting. Weapons are for losers. This monster just noms its enemies. Om nom nom.", "+150% Power. Must engulf enemies to attack", 4),
		huge: std.summoner.library.InitTrait("huge", "Waaaaaaaaah, this is a reaaaaaaaaaaaaaaaaaaaaaaaaaaaaally big monster. It's so big, I can't even see its head.", "400% Size. +400% Power. +400% Health. +10 Complexity", 10),
		vampiric: std.summoner.library.InitTrait("vampiric", "desc","+4 Complexity. Life Drain",4),
		slimy: std.summoner.library.InitTrait("slimy","desc","+20% Health",0),
		hot: std.summoner.library.InitTrait("hot", "desc","+1 Complexity. +50% Power", 1),
		draconic: std.summoner.library.InitTrait("draconic", "desc","+5 Complexity. +100% Power. +100% Health", 5),
		teeny: std.summoner.library.InitTrait("teeny", "desc", "+5 Complexity. 25% Size. -25% Power. 35% Evasion. +3 Speed", 5),
		nice: std.summoner.library.InitTrait("nice", "desc", "+4 Complexity. Heals nearby allies", 4),
		undead: std.summoner.library.InitTrait("undead", "desc", "+1 Complexity. Undead traits", 1),
		horned: std.summoner.library.InitTrait("horned", "desc", "+7 Complexity. +250% Power. +100% Range", 7),
		chilly: std.summoner.library.InitTrait("chilly", "desc", "+1 Complexity. +100% Health", 1),
		edible: std.summoner.library.InitTrait("edible", "desc", "+5 Complexity. +300% Health. Attracts enemies", 5),
		melting: std.summoner.library.InitTrait("melting", "desc", "+8 Complexity. +1000% Health. Health decreases over time", 8),
		strong: std.summoner.library.InitTrait("strong", "desc", "+7 Complexity. +300% Power", 7),
		evil: std.summoner.library.InitTrait("evil", "desc","+1 Complexity. +80% Power", 1),
		good: std.summoner.library.InitTrait("good", "desc", "+1 Complexity. +80% Health", 1),
		cold_blooded: std.summoner.library.InitTrait("cold_blooded", "desc", "+10 Complexity. +100% Damage. Additional +100% Damage against hot", 10),
		loyal: std.summoner.library.InitTrait("loyal", "desc", "+1 Complexity. Follows Summoner", 1),
		whimsical: std.summoner.library.InitTrait("whimsical", "desc", "-10 Complexity. Sometimes wanders", -10),
		freezing: std.summoner.library.InitTrait("freezing", "desc", "+10 Complexity. Freezes monsters that attack this monster", 10),
		cute: std.summoner.library.InitTrait("cute", "desc", "+7 Complexity. Attacking this monster damages attacker", 7),
		scary: std.summoner.library.InitTrait("scary", "desc", "+5 Complexity. Others may not target this monster", 5),
		shiny: std.summoner.library.InitTrait("shiny", "desc","+10 Complexity. Shuns weird effects",10),
		divine: std.summoner.library.InitTrait("divine", "desc", "+15 Complexity. Always take half damage. Do more damage against evil", 15),
		infernal: std.summoner.library.InitTrait("infernal", "desc", "+15 Complexity. Always do +150% damage on non-divine", 15),
		fire_breathing: std.summoner.library.InitTrait("fire_breathing","desc","+12 Complexity. Chance to breathe fire",12),
		charming: std.summoner.library.InitTrait("charming", "desc", "+11 Complexity. Chance to confuse enemies. 50% Evasion", 11),
		ranged: std.summoner.library.InitTrait("ranged", "desc", "+5 Complexity. Attack from range NOT IMPLEMENTED", 5),
		annoying: std.summoner.library.InitTrait("annoying", "desc", "+15 Complexity. Enemies target this monster. This monster annoys spellcasters NOT IMPLEMENTED", 15)
	};
}
/* std.summoner.library.InitTrait 
 * Helper for Init
*/
std.summoner.library.InitTrait = function(name, desc, eff, complexity) {
	return {name: name, desc: desc, eff: eff, comp: complexity};
}

/* std.summoner.library.Lookup
 * parameter: trait_name
 * returns: trait_obj //{trait_name, trait_desc_long, trait_desc_short, complexity}
 */
std.summoner.library.Lookup = function(word) {
	for (i in std.summoner._self.fixed.library)
		if (i.toLowerCase() == word.toLowerCase()) 
			return std.summoner._self.fixed.library[i];
	return null;
}

/* std.summoner.library.BooksToTitles
 * parameter: trait_obj[]
 * returns: trait_name[]
 */
std.summoner.library.BooksToTitles = function(books) {
	var titles = [];
	for (i in books)
		titles.push(books[i].name);
	return titles;
}

@;