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

 /* SummonerNews
  * The file which defines the news UI for the Summoner game
  * Also takes care of message responses that are aimed at player avatar
  */
 
if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerNews = @

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.log) === "undefined") std.summoner.log = {};

/* News UI */
(function () {
	var Sum = std.summoner;
	
	Sum.SummonerLogInit = function(parent) {
		this._parent = parent;
		this._parent._simulator.addGUITextModule("SummonerLog", \@
			sirikata.ui("SummonerLog", function() {
				$('<div id="Summoner-Log" title="History" >' + 
				  '  <div id="SummonerLogInner" style="width:400;height:300;overflow:scroll"></div>' +
				  '</div>').appendTo('body');
				$("#Summoner-Log").dialog({
					width:400,
					height:'auto',
					modal:false,
					autoOpen:false
				});
				var log_count = 1;
				var row_back_1 = "rgb(255,220,220)";
				var row_back_2 = "rgb(220,255,255)";
				
				SummonerLogMessageReceived = function(log_from_master, log_from_monster, log_to_master, log_to_monster, action) {
					if (action == "Summon") {
						SummonerLogMessage(SummonerLogSummonMessage(log_from_master, log_from_monster));
					} else if (action == "Learn_Trait") {
						SummonerLogMessage(SummonerLogLearnTraitMessage(log_from_master, log_from_monster));
					} else if (action == "Learn_Monster") {
						SummonerLogMessage(SummonerLogLearnMonsterMessage(log_from_master, log_from_monster));
					} else if (action == "Kill") {
						SummonerLogMessage(SummonerLogKillMessage(log_from_master, log_from_monster, log_to_master, log_to_monster));
					}
				};
				
				function SummonerLogMessage (msg_str) {
					var style = row_back_2;
					if (log_count % 2 == 0)
						style = row_back_1;
					var str = '<div style="background-color:' + style + '">' + log_count.toString() + ') ' + msg_str + '</div>';
					$("#SummonerLogInner").append(str);
					log_count++;
				}
				
				function SummonerLogSummonMessage(master, monster) {
					return master + " summonned " + monster + ".";
				}
				
				function SummonerLogLearnTraitMessage(master, trait) {
					return master + " learned the trait " + trait + ".";
				}
				
				function SummonerLogLearnMonsterMessage(master, monster) {
					return master + " learned how to summon a " + monster + ".";
				}
				
				function SummonerLogKillMessage(from_master, from_monster, to_master, to_monster) {
					if (to_monster != "") {
						return from_master + "'s " + from_monster +" killed " + to_master + "'s " + to_monster + ".";
					} else {
						return to_master + " got PK'd by " + from_master + "'s " + from_monster + ".";
					}
				}
				
			});

		\@, std.core.bind(function(gui){this._SummonerLogModule = gui;}, this));
	}
})();

simulator._summonerlog = new std.summoner.SummonerLogInit(simulator);

/* std.summoner.log.Init
 * The initialization function that sets up the replies to messages sent to the user avatar presence.
 */
std.summoner.log.Init = function() {
	std.summoner.log.RespPlaying = function (msg, sender) {
		var resp = {isPlayingSummoner:true, id_no: std.summoner._self.other.self_pres.getPresenceID()};
		msg.makeReply(resp) >> [];
	};
	std.summoner.log.RespPlaying << [{"action":"SummonerAskPlaying":},
									 {"id_no":std.summoner._self.other.self_pres.getPresenceID():}];
	
	std.summoner.log.RespOwner = function (msg, sender) {
		var resp = {owner:std.summoner._self.stats.name, id_no: std.summoner._self.other.self_pres.getPresenceID(), is_summoner:true};
		if (std.summoner._self.stats.godmode)
			resp.owner = "god";
		msg.makeReply(resp) >> [];
	};
	std.summoner.log.RespOwner << [{"action":"SummonerAskOwner":},
									 {"id_no":std.summoner._self.other.self_pres.getPresenceID():}];
	std.summoner.log.RespLog = function (msg, sender) {
		var resp = {SummonerLog:true, id_no: std.summoner._self.other.self_pres.getPresenceID()};
		msg.makeReply(resp) >> []; 
	};
	std.summoner.log.RespLog << [{"action":"SummonerAskLog":},
								 {"id_no":std.summoner._self.other.self_pres.getPresenceID():}];
	
	std.summoner.log.CatchDeath = function (msg, sender) {
		std.summoner.log.Report("Kill", 
								 msg.killer_owner, 
								 std.summoner.util.ArrayName(msg.killer_stats.CustomTraits, msg.killer),
								 msg.victim_owner,
								 std.summoner.util.ArrayName(msg.victim_stats.CustomTraits, msg.victim));
	};
	std.summoner.log.CatchDeath << [{"action":"SummonerReportDeath":},
									{"id_no":std.summoner._self.other.self_pres.getPresenceID():}];
	std.summoner.log.RespAttack = function (msg, sender) {
		var resp = {id_no:sender.getVisibleID(), id_victim:std.summoner._self.other.self_pres.getPresenceID()};
		std.summoner._self.stats.health_cur = std.summoner._self.stats.health_cur - msg.power;
		if (std.summoner._self.stats.health_cur > std.summoner._self.stats.health_max)
			std.summoner._self.stats.health_cur = std.summoner._self.stats.health_max;
		if (std.summoner._self.stats.health_cur <= 0) {
			resp.died = "true";
			if (std.summoner._self.stats.alive) {
				std.summoner._self.stats.health_cur = 0;
				std.summoner._self.stats.health_regen = 0;
				std.summoner._self.stats.alive = false;
				std.summoner.log.Report("Kill", msg.owner, std.summoner.util.ArrayName(msg.stats.CustomTraits, msg.name), std.summoner._self.stats.name, "");
			}
		}
		
		msg.makeReply(resp) >> [];
		simulator._summoner._SummonerMainModule.call("SummonerMainUpdate", std.summoner._self.stats);
	};
	std.summoner.log.RespAttack << [{"action":"Attack":},
									{"id_no":std.summoner._self.other.self_pres.getPresenceID():}];
	std.summoner.log.RespAlive = function (msg, sender) {
		var resp = {id_no:sender.getVisibleID(), id_victim: std.summoner._self.other.self_pres.getPresenceID()};
		if (!std.summoner._self.stats.alive)
			resp.dead = "true";
		msg.makeReply(resp) >> [];
	};
	std.summoner.log.RespAlive << [{"action":"askAlive":},
								   {"id_no":std.summoner._self.other.self_pres.getPresenceID():}];
}

/* std.summoner.log.Report
 * Call this function to add a row to the News UI
 */
std.summoner.log.Report = function(action, owner_from, monster_from, owner_to, monster_to) {
	simulator._summonerlog._SummonerLogModule.call("SummonerLogMessageReceived", owner_from, monster_from, owner_to, monster_to, action);
}

@;