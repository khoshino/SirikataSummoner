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

 /* SummonerInitEasy
  * This file is responsible for initializing the game. 
  * Simply import this file and the presence that imported this file will become the game host
  * Anybody who sends a touch message to the host will enter the game.
  */

 system.require("SummonerMain.em");


if (typeof(std) === 'undefined') std = {};
if (typeof(std.summoner) === 'undefined') std.summoner = {};
if (typeof(std.summoner.judge) === 'undefined') std.summoner.judge = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};

/* std.summoner.judge.msg
 * As the game host, this object is the script that is sent to all the players.
 */
std.summoner.judge.msg = {
	request:'script',
	script: std.summoner.msg.SummonerLibrary + std.summoner.msg.SummonerEffects + std.summoner.msg.SummonerBestiary + std.summoner.msg.SummonerNews + std.summoner.msg.SummonerUtil + std.summoner.msg.SummonerMonster + std.summoner.msg.Summoner + std.summoner.msg.SummonerMain
};


std.summoner.judge.judgeMasterCallback = function(msg) {
	if (typeof(std) === 'undefined') std = {};
	if (typeof(std.summoner) === 'undefined') std.summoner = {};
	if (typeof(std.summoner.judge) === 'undefined') std.summoner.judge = {};
	
	std.summoner.judge.players = [];
	
	std.summoner.judge.PrintPlayerArray = function() {
		system.print("\n");
		for (i in std.summoner.judge.players) {
			system.print(std.summoner.judge.players[i].getVisibleID());
			system.print("\n");
		}
	}
	
	std.summoner.judge.Invite = function(vis) {
		msg >> vis >> [];
	};
	
	std.summoner.judge.vis_playing = function(vis) {
		for (i in std.summoner.judge.players) {
			if (std.summoner.judge.players[i].getVisibleID() == vis.getVisibleID())
				return true;
		}
		return false;
	}
	
	std.summoner.judge.catchTouch = function(touchmsg, sender) {
		std.summoner.judge.PrintPlayerArray();
		if (!std.summoner.judge.vis_playing(sender)) {
			std.summoner.judge.Invite(sender);
			std.summoner.judge.players.push(sender);
		}
	};
	
	system.onPresenceConnected(function(pres) {
		//system.self.onProxAdded(std.summoner.judge.sendInvites, true);
		//std.summoner.judge.catchTouch << [{'action':'touch':}];
		system.require("examples/games/bank/bankConnect.em");
	});
};

var godmode = false;

var entPos = system.self.getPosition();
entPos.x = entPos.x - 30;

/* this bit of code initializes the game host
 */
if (godmode)
	std.summoner.judge.msg >> system.self >> [];	
else {
	std.summoner.judge.players = [];
	
	std.summoner.judge.PrintPlayerArray = function() {
		system.__debugPrint("\n");
		for (i in std.summoner.judge.players) {
			system.__debugPrint(std.summoner.judge.players[i].getVisibleID());
			system.__debugPrint("\n");
		}
	};
	
	std.summoner.judge.Invite = function(vis) {
		std.summoner.judge.msg >> vis >> [];
	};
	
	std.summoner.judge.vis_playing = function(vis) {
		for (i in std.summoner.judge.players) {
			if (std.summoner.judge.players[i].getVisibleID() == vis.getVisibleID())
				return true;
		}
		return false;
	};
	
	std.summoner.judge.catchTouch = function(touchmsg, sender) {
		std.summoner.judge.PrintPlayerArray();
		var sendervis = (typeof(sender) === "string") ? system.createVisible(sender) : sender;
		if (!std.summoner.judge.vis_playing(sendervis)) {
			std.summoner.judge.Invite(sendervis);
			std.summoner.judge.players.push(sendervis);
		}
	};
	std.summoner.judge.catchTouch << [{"action":"touch":}];
	//system.require("examples/games/bank/bankConnect.em");
}