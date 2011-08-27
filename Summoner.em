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
 
/* Summoner
 * This file is responsible for constructing the Summoning UI
 */
 
system.require('SummonerMonster.em');

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.Summoner = @

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner._self) === "undefined") std.summoner._self = {};

/* Summoning UI */
(function () {
	var Sum = std.summoner;
	
	Sum.SummonerSummonInit = function(parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("SummonerSummon", \@
			sirikata.ui("SummonerSummon", function() {
				$('<div id="Summoner-Summon" title="Summon">' + 
				  '  <div id="Summoner_temptxt"></div>' + 
				  '  <div id="Summoner_Traitname" style="float:left"></div>' +
				  '  <div id="Summoner_Monstername" ></div>' +
				  '  <div id="Summoner_Complexity">Complexity is: ?</div>' +
				  '  <div id="Summoner_Monster">Will summon: Slime</div>' +
				  '  <input id="Summoner_Summon_Now" type="button" value="Summon!!!"></input>' + 
				  '</div>').appendTo('body');
				$("#Summoner-Summon").dialog({
					width:430,
					height:'auto',
					modal:false,
					autoOpen:false
				});
				var traittxt = "Summoner_Traitname_";
				var monstertxt = "Summoner_Monstername_";
				var monsterToSummon = "Slime";
				var will_summon_txt = "Will summon: ";
				var complexitytxt = "Complexity is: ";
				var traits = [];
				var alltraits = {};
				var allmonsters = {};
				$("#Summoner_Summon_Now").click(function () {Summoner_Summon_Now();});
				
				addTraitName = function(name, complexity) {
					var fixedname = fixName(name);
					$("#Summoner_Traitname").append('<input type="checkbox" name="Traitname" value="' + fixedname +'" id="' + traittxt + fixedname + '">' + name + '</input><br/>');
					$("#" + traittxt + fixedname).click(function() {calculateComplexity(true, fixedname, $("#" + traittxt + fixedname + ":checked").val());});
					alltraits[name] = complexity;
				};
				
				addMonsterOption = function(name, complexity) {
					var fixedname = fixName(name);
					$("#Summoner_Monstername").append('<input type="Radio" name="Monstername" value="' + fixedname + '" id="' + monstertxt + fixedname+ '">' + name + '</input><br/>');
					$("#" + monstertxt + fixedname).click(function() {calculateComplexity(false, fixedname, $("#" + monstertxt + fixedname + ":checked").val());});
					allmonsters[name] = complexity;
				};
				
				function fixName(name) {
					return name.replace(/ /g, "");
				}
				
				function calculateComplexity(isTrait, name, value) {
					if (isTrait) {
						if (value) {
							traits.push(name);
						} else {
							for (i in traits) {
								if (traits[i] == name)
									traits.splice(i,1);
							}
						}
					} else { // monster value changed
						if (value)
							monsterToSummon = value;
					}
					
					$("#Summoner_Complexity").text(complexitytxt + Summoner_Summon_Complexity());
					$("#Summoner_Monster").text(will_summon_txt + Summoner_Summon_TraitMonster());
				}
				
				function Summoner_Summon_Now() {
					if ($(":checked").val())
						$("#Summoner_temptxt").text("Summon " + $("#Summoner_Monster").text());
					else 
						$("#Summoner_temptxt").text("");
					sirikata.event("summon", Summoner_Summon_TraitMonster());
				}
				
				function Summoner_Summon_TraitMonster () {
					var returntxt = "";
					traits.sort();
					for (i in traits)
						returntxt = returntxt + traits[i] + " ";
					return returntxt + monsterToSummon;
				}
				function Summoner_Summon_Complexity() {
					var base = -1;
					var trait_comp = {};
					var num_traits = 0;
					var returnstr = "";
					var total_comp = 0;
					for (i in allmonsters)
						if (i == monsterToSummon) {
							base = allmonsters[i];
							break;
						}
					if (base == -1)
						return "BASE CALCULATION FAILED";
					traits.sort();
					for (i in traits)
						for (j in alltraits)
							if (traits[i] == j) {
								trait_comp[traits[i]] = alltraits[j];
								break;
							}
					returnstr = returnstr + base.toString() + "[base]"
					total_comp = base;
					for (i in trait_comp) {
						total_comp = total_comp + trait_comp[i];
						returnstr = returnstr + " + " + trait_comp[i].toString() + "[" + i + "]";
						if (num_traits > 0) {
							total_comp = total_comp + num_traits * 2;
							returnstr = returnstr + " + " + (num_traits * 2).toString() + "[friction]";
						}
						num_traits++;
					}
					if (total_comp <= 0)
						total_comp = 1;
					returnstr = total_comp.toString() + " = " + returnstr;
					return returnstr;
				}
			});

		\@, std.core.bind(function(gui) {
			this._SummonerModule = gui;
			handleSummon = function (summon_name) {
				std.summoner.monster.SummonMonster(summon_name, std.summoner._self.stats);
			};
			this._SummonerModule.bind("summon", handleSummon);
		}, this));
	}
})();

simulator._summoner_summon = new std.summoner.SummonerSummonInit(simulator);

@;