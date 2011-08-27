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
 
/* SummonerBestiary
 * This file is responsible for constructing the Bestiary UI
 * It is also responsible for generating and returning the bestiary map.
 */
 
if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerBestiary = @

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.bestiary) === "undefined") std.summoner.bestiary = {};

/* Bestiary UI */
(function () {
	var Sum = std.summoner;
	Sum.SummonerBestiaryInit = function(parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("SummonerBestiary", \@
			sirikata.ui("SummonerBestiary", function() {
				$('<div id="Summoner-Bestiary" title="Bestiary">' + 
				  '  <div id="SummonerBestiary_temptxt"></div>' + 
				  '  <div id="SummonerBestiaryList" style="width:20%;float:left"></div>' +
				  '  <div id="SummonerBestiaryDescBox" >' +
				  '    <div id="SummonerBestiaryNameDesc" style="width:39%;height:50%;float:left">' + 
				  '      <div id="SummonerBestiaryName" style="text-align:center;font-size:30px;font-weight:bold"></div>' +
				  '      <div id="SummonerBestiaryDesc" ></div>' +
				  '    </div>' +
				  '    <div id="SummonerBestiaryThumbnail" style="width:39%;height:50%;float:right"></div>' +
				  '    <div id="SummonerBestiaryBasestats">' + 
				  '      <div id="SummonerBestiaryBasestatsHealth" style="float:left;width:33%"></div>' +
				  '      <div id="SummonerBestiaryBasestatsPower" style="float:left;width:33%"></div>' +
				  '      <div id="SummonerBestiaryBasestatsSpeed"></div>' +
				  '      <div id="SummonerBestiaryBasestatsSize" style="float:left;width:33%"></div>' +
				  '      <div id="SummonerBestiaryBasestatsComplexity"></div>' +
				  '    </div>' +
				  '  </div>' +
				  '</div>').appendTo('body');
				$("#Summoner-Bestiary").dialog({
					width:600,
					height:'auto',
					modal:false,
					autoOpen:false
				});
				var _list = "SummonerBestiaryList";
				var _name = "SummonerBestiaryName";
				var _desc = "SummonerBestiaryDesc";
				var _thumb = "SummonerBestiaryThumbnail";
				var _base = "SummonerBestiaryBasestats";
				var _health = _base + "Health";
				var _power = _base + "Power";
				var _speed = _base + "Speed";
				var _size = _base + "Size";
				var _comp = _base + "Complexity";
				
				
				
				SummonerBestiaryInit = function(m) {
					for (i in m) {
						(function(name, stats) {
							SummonerBestiaryListEntry(name, stats);
						})(i, m[i]);
					}
				}
				
				function SummonerBestiaryDesc(name, stats) {
					var prereqs = "<br/>Prerequisites: ";
					var traits = "<br/>Traits: ";
					var complexity = "Complexity: " + stats.Complexity.toString();
					var health = "Health: " + stats.Health.toString();
					var power = "Power: " + stats.Power.toString();
					var speed = "Speed: " + stats.Speed.toString();
					var size = "Size: " + stats.Size.toString();
					var thumb = '<img src="' + stats.Thumbnail + '" style="width:100%;height:100%"/>';
					var desc;
					var base;
					$("#" + _name).text(name);
					if (stats.PrereqTraits.length > 0)
						prereqs = prereqs + stats.PrereqTraits.toString();
					else
						prereqs = prereqs + "None";
					if (stats.InnateTraits.length > 0) 
						traits = traits + stats.InnateTraits.toString();
					else
						traits = traits + "None";
					desc = stats.Desc + prereqs + traits;
					$("#" + _desc).text("");
					$("#" + _desc).append(desc);
					$("#" + _health).text(health);
					$("#" + _power).text(power);
					$("#" + _speed).text(speed);
					$("#" + _size).text(size);
					$("#" + _comp).text(complexity);
					$("#" + _thumb).text("");
					$("#" + _thumb).append(thumb);
				}
				
				function SummonerBestiaryListEntry(name, stats) {
					var listname = _list + name;
					var entryName = '<div id="' + listname + '" >' + name + '</div>';
					$("#" + _list).append(entryName);
					$("#" + listname).mouseover(function() {
						$("#" + listname).css("background-color", "rgb(200,191,231)");
					});
					$("#" + listname).mouseout(function() {
						$("#" + listname).css("background-color", "rgb(255,255,255)");
					});
					$("#" + listname).click(function() {
						SummonerBestiaryDesc(name, stats);
					});
					
				}
				
			});
		\@, std.core.bind(function(gui){this._SummonerBestiaryModule = gui;}, this));
	}
})();

simulator._summonerbestiary = new std.summoner.SummonerBestiaryInit(simulator);



/* std.summoner.bestiary.Init
 * Returns the whole bestiary as an object
 * returns an array of bestiary_obj
 * bestiary_obj is {Name:str, 
                    Size:num, 
					Power:num, 
					Health:num, 
					Speed:num, 
					InnateTraits:string[],
					LearnableTraits:string[],
					Complexity:num, 
					PrereqTraits:string[], 
					Desc:string, 
					Thumbnail:string,
					MeshURL:string}
 */
std.summoner.bestiary.Init = function() {
	return {
		Slime:std.summoner.bestiary.BestiaryValue("Slime", 10, 1, 1, 0.5, [], ["small", "fuzzy", "slow", "slimy", "big"], 3, [], "The most basic and most useless summon. Summon this blob a few times to increase your experience. Then, never summon this again.", "http://open3dhub.com/download/150497bdb451152b6b7299a2988b5e81de056c068a166bbee952d94f316b0e89", "meerkat:///jterrace/pokemon/jigglypuff.dae/optimized/0/jigglypuff.dae"),
		Jelly:std.summoner.bestiary.BestiaryValue("Jelly", 50,13, 1, 0.7, ["splitting"], ["small", "big"], 10, ["slimy"], "This Jelly is made of strawberries and natural flavoring. This Jelly also is known for its ability to disprove many theorems, such as convservation of mass, by splitting itself when it gets smashed. ", "http://open3dhub.com/download/63618eb50088dc1f4fb97ff7c26f47287ab22e558f3216d9d71fc9c80cca6894", "meerkat:///emily2e/pacmanBoo/models/boo.dae/optimized/1/boo.dae"),
		GelatinousCube:std.summoner.bestiary.BestiaryValue("GelatinousCube", 300,21, 1, 4, ["devouring"], ["huge"], 25, ["slimy","big"], "Gelatinous Cubes are really big blobs. Their prime method of attack doesn't exist. However, their sheer volume allows them to eat everything by simply moving through them. They like living in large, dark, underground places such as dungeons, sewers, and the basement of Meyer.", "http://open3dhub.com/download/a38e8371df9f2c827c4119b0ba86093343531ebd5700e22da79b1409dcd1c3b1", "meerkat:///jterrace/pokemon/010_caterpie.dae/optimized/0/010_caterpie.dae"),
		Vampire:std.summoner.bestiary.BestiaryValue("VampireBat", 200, 30, 2, 1.5, ["vampiric", "evil"], ["fast"], 18, ["small"], "desc","http://open3dhub.com/download/dcabeeb83a2db46cc397f1f8b4421a29e88b42863090e850b185fe4fee44abd3", "meerkat:///jterrace/pokemon/041_zubat.dae/optimized/0/041_zubat.dae"),
		Salamander:std.summoner.bestiary.BestiaryValue("Salamander", 100, 50, 2, 2.5, ["hot"], ["fire_breathing", "big"], 30, [], "", "http://open3dhub.com/download/dcaa69ded1d97a1d52a19aa1c3369c740508fde118c90655e92c236984559cf3", "meerkat:///jterrace/pokemon/004_charmander.dae/optimized/0/004_charmander.dae"),
		ChromeDragon:std.summoner.bestiary.BestiaryValue("ChromeDragon", 1500, 300, 4, 5, ["shiny", "draconic"],["divine"], 100, ["huge", "good", "loyal"], "desc", "http://open3dhub.com/download/bbb390a6f11bdf73100ef4f052358efdf2d7d11c7f9d7b5deaf6c31c7f7659ac", "meerkat:///hoshoshoshosh/models/silver_dragon.dae/optimized/0/silver_dragon.dae"),
		Avian:std.summoner.bestiary.BestiaryValue("Avian",160, 40, 4, 0.5, ["good", "nice"], ["teeny", "fast"], 15, ["small"], "desc", "http://open3dhub.com/download/12a8a4eb7072db0729cb165d103b4f26f431921bf0c93ae3aac2c0eed736a3db", "meerkat:///hoshoshoshosh/dove.dae/optimized/0/dove.dae"),
		SkeletalTriceratops:std.summoner.bestiary.BestiaryValue("SkeletalTriceratops",250, 80, 2, 3, ["undead", "evil"], ["scary", "horned"], 25, ["evil", "big"], "desc", "http://open3dhub.com/download/dfbacb35a0044478c5ae9e32c9a6844f242df21bfb52bd27fd6752ed9944fc66", "meerkat:///hoshoshoshosh/models/Dino_Puzzle.dae/optimized/0/Dino_Puzzle.dae"),
		Icecream:std.summoner.bestiary.BestiaryValue("Icecream", 80, 25, 1, 2, ["chilly"], ["edible", "melting", "slow"], 18, ["small"], "desc", "http://open3dhub.com/download/a07545d0639d3c6dc4a5aba21b55eac96f5ea94d75993c30a4a32a021ef0a206", "meerkat:///hoshoshoshosh/icecream.dae/optimized/0/icecream.dae"),
		Snowman:std.summoner.bestiary.BestiaryValue("Snowman", 250, 60, 1, 2.5, ["cold_blooded"], ["freezing", "scary"], 23, ["chilly"], "desc", "http://open3dhub.com/download/e8f16f3a95dda19c69061e73100b7679fdd3e6ab2ea94b084852caee6867c526", "meerkat:///hoshoshoshosh/snowman.dae/optimized/0/snowman.dae"),
		Hound:std.summoner.bestiary.BestiaryValue("Hound", 150, 60, 2.5, 2.5, ["loyal"], ["strong"], 35, [], "desc", "http://open3dhub.com/download/142b3bc1b54462dac0f4912e751fb5f3b97bfd08fdaa685b66cb0c6f7b03df0c", "meerkat:///hoshoshoshosh/models/dog.dae/optimized/0/dog.dae"),
		Cat:std.summoner.bestiary.BestiaryValue("Cat", 130, 40, 3, 1.5, ["whimsical"], ["fast", "cute"], 35, [], "desc", "http://open3dhub.com/download/8f4df9dc23f9099058548721f8b0bff368b099992bfa77f58fd47932470c275f", "meerkat:///hoshoshoshosh/models/cat.dae/optimized/0/cat.dae"),
		RedDragon:std.summoner.bestiary.BestiaryValue("RedDragon", 1200, 400, 4, 5, ["draconic", "infernal"], ["insane", "scary"], 100, ["huge", "hot", "evil"], "desc", "http://open3dhub.com/download/eb60400e7b61abf4c40cd17e59ca3e6803877a05f327cb00eb273d65138042ff", "meerkat:///hoshoshoshosh/models/red_dragon.dae/optimized/0/red_dragon.dae"),
		IceFairy:std.summoner.bestiary.BestiaryValue("IceFairy", 500, 100, 6, 0.5, ["charming", "ranged", "chilly"], ["shiny", "annoying"], 50, ["teeny", "freezing", "cute"], "desc", "http://open3dhub.com/download/94ca61f44a34afe7b98cd33b4222ad3c9567111dff354282ae4e4ed1cd0832c5", "meerkat:///hoshoshoshosh/models/navi.dae/optimized/0/navi.dae")
	};
}

/* std.summoner.bestiary.BestiaryValue
 * Helper to SummonerBestiary
 */
std.summoner.bestiary.BestiaryValue = function(	name,
												max_health,
												power,
												speed,
												size,
												innate_traits,
												learnable_traits,
												complexity,
												prereq_traits,
												desc,
												thumbnail,
												mesh) {
	return {Name:name,
			Size:size,
			Power:power,
			Health:max_health,
			Speed:speed,
			InnateTraits:innate_traits,
			LearnableTraits:learnable_traits,
			Complexity:complexity,
			PrereqTraits:prereq_traits,
			Desc:desc,
			Thumbnail:thumbnail,
			MeshURL:mesh};
}

@;