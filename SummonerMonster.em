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
 
 /* SummonerMonster
  * This file is responsible for defining how monsters act in the game, as well as their AI and 
  * functions that are called when monsters need to be summoned
  */
 
system.require('SummonerUtil.em');

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerMonster = @

system.require('std/core/repeatingTimer.em');

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.monster) === "undefined") std.summoner.monster = {};
if (typeof(std.summoner.combat) === "undefined") std.summoner.combat = {};

/* std.summoner.combat.initSelf
 * The function that's called when a monster is summoned. Initializes the monster's data
 * as well as repositions them and re-activates their behavior timer
 */
std.summoner.combat.initSelf = function(monster_stats, monster_data, monster_name) {
	var stats = monster_stats;
	var data = monster_data;
	data.name = monster_name;
	for (var i in data.traits)
		data.traits[i] = false;
	for (var i in data.effects)
		data.effects[i] = 0;
	for (var i in stats.InnateTraits)
		data.traits[stats.InnateTraits[i]] = true;
	for (var i in stats.CustomTraits)
		data.traits[stats.CustomTraits[i]] = true;
	data.size = stats.Size;
	if (std.summoner.util.hasTrait("huge", data.traits))
		data.size *= 4;
	else if (std.summoner.util.hasTrait("big", data.traits))
		data.size *= 2;
	else if (std.summoner.util.hasTrait("teeny", data.traits))
		data.size /= 4;
	else if (std.summoner.util.hasTrait("small", data.traits))
		data.size /= 2;
	data.presSelf.setScale(data.size);
	data.presSelf.setMesh(data.MeshURL);
	
	var health_tmp = stats.Health;
	var health_mod = 0;
	if (std.summoner.util.hasTrait("fuzzy", data.traits))
		health_mod += Math.ceil(health_tmp * 0.5);
	if (std.summoner.util.hasTrait("huge", data.traits))
		health_mod += Math.ceil(health_tmp * 4);
	else if (std.summoner.util.hasTrait("big", data.traits))
		health_mod += Math.ceil(health_tmp * 2);
	if (std.summoner.util.hasTrait("slimy", data.traits))
		health_mod += Math.ceil(health_tmp * 0.2);
	if (std.summoner.util.hasTrait("draconic", data.traits))
		health_mod += Math.ceil(health_tmp);
	if (std.summoner.util.hasTrait("chilly", data.traits))
		health_mod += Math.ceil(health_tmp);
	if (std.summoner.util.hasTrait("melting", data.traits))
		health_mod += Math.ceil(health_tmp * 10);
	if (std.summoner.util.hasTrait("edible", data.traits))
		health_mod += Math.ceil(health_tmp * 3);
	if (std.summoner.util.hasTrait("good", data.traits))
		health_mod += Math.ceil(health_tmp * 0.8);
	data.health = health_tmp + health_mod;
	data.health_max = data.health;
	if (stats.damage)
		data.health -= stats.damage;
	
	
	var power_tmp = stats.Power;
	var power_mod = 0;
	if (std.summoner.util.hasTrait("huge", data.traits))
		power_mod += Math.ceil(power_tmp * 4);
	else if (std.summoner.util.hasTrait("big", data.traits))
		power_mod += Math.ceil(power_tmp * 2);
	else if (std.summoner.util.hasTrait("teeny", data.traits))
		power_mod -= Math.ceil(power_tmp * 0.75);
	else if (std.summoner.util.hasTrait("small", data.traits))
		power_mod -= Math.ceil(power_tmp * 0.75);
	if (std.summoner.util.hasTrait("insane", data.traits))
		power_mod += Math.ceil(power_tmp * 5);
	if (std.summoner.util.hasTrait("devouring", data.traits))
		power_mod += Math.ceil(power_tmp * 1.5);
	if (std.summoner.util.hasTrait("hot", data.traits))
		power_mod += Math.ceil(power_tmp / 2);
	if (std.summoner.util.hasTrait("draconic", data.traits))
		power_mod += Math.ceil(power_tmp);
	if (std.summoner.util.hasTrait("horned", data.traits))
		power_mod += Math.ceil(power_tmp * 2.5);
	if (std.summoner.util.hasTrait("evil", data.traits))
		power_mod += Math.ceil(power_tmp * 0.8);
	if (std.summoner.util.hasTrait("strong", data.traits))
		power_mod += Math.ceil(power_tmp * 3);
	data.power = power_tmp + power_mod;
	
	var speed_tmp = stats.Speed;
	var speed_mod = 0;
	if (std.summoner.util.hasTrait("fast", data.traits))
		speed_mod += speed_tmp;
	else if (std.summoner.util.hasTrait("slow", data.traits))
		speed_mod -= Math.floor(speed_tmp / 2);
	if (std.summoner.util.hasTrait("teeny", data.traits))
		speed_mod += 3;
	data.speed = speed_tmp + speed_mod;
	
	std.summoner.combat.setInitPosition(data);
	std.summoner.combat.stopMovement(data);
	data.alive = true;
	std.summoner.combat.prodAllTargets(data);
	if (typeof(data.behaviorTimer) === "undefined")
		system.timeout(2,std.summoner.combat.startTimers(data));
	else
		data.behaviorTimer.reset();
	if (data.banner_set)
		std.summoner.effects.repositionBanner(data.effects_visual);
	data.summon_timestamp = (new Date()).getTime();
}


/* std.summoner.combat.prodAllTargets
 * The monster sends an attack-message to every presence in-game in sight. 
 * This lets others register the monster as a valid target
 */
std.summoner.combat.prodAllTargets = function(monster_data) {
	for (var i in std.summoner._self.share.targets)
		std.summoner.combat.prod (std.summoner._self.share.targets[i], monster_data);
	for (var i in std.summoner._self.share.targets_priority)
		std.summoner.combat.prod (std.summoner._self.share.targets_priority[i], monster_data);
	for (var i in std.summoner._self.share.dead)
		std.summoner.combat.prod (std.summoner._self.share.dead[i], monster_data);
}

/* std.summoner.combat.setInitPosition
 * Sets the monster's position to be in front of the avatar.
 * The distance from the avatar is determined by the monster and avatar's scale
 */
std.summoner.combat.setInitPosition = function(monster_data) {
	var data = monster_data; /*
	if (stats.initPos) {
		var selfPosition = <stats.initPos.x, stats.initPos.y, stats.initPos.z>;
		var shift_x = Math.random() * 2 - 1;
		var shift_z = Math.sqrt(1 - (shift_x * shift_x));
		if (Math.random() < 0.5)
			shift_z = shift_z * -1;
		var shift = <data.size * shift_x * 2, 0, data.size * shift_z * 2>;
		data.presSelf.setPosition(selfPosition.add(shift));
	} else {*/
		var selfPosition = std.summoner._self.other.self_pres.getPosition();
		var selfOrientation = std.summoner._self.other.self_pres.getOrientation();
		var scalePos = <0, 0, -1 * (data.size + std.summoner._self.other.self_pres.getScale())>;
		var summonPos = selfPosition.add(selfOrientation.mul(scalePos));
		data.presSelf.setPosition(summonPos);
		data.presSelf.setOrientation(selfOrientation);
//	}
}

// Construct combat-related utility functions
/* std.summoner.combat.cleanTargets
 * Checks all targets to see if any are dead. If dead, they are put into the array named std.summoner._self.share.dead[]
 */
std.summoner.combat.cleanTargets = function() {
	for (var i = 0; i < std.summoner._self.share.targets.length; i++)
		if (std.summoner.util.isInGraveyard(std.summoner._self.share.targets[i].getPosition())) {
			std.summoner.combat.loseTargets(std.summoner._self.share.targets[i]);
			i--;
		}
	for (var i = 0; i < std.summoner._self.share.targets_priority.length; i++)
		if (std.summoner.util.isInGraveyard(std.summoner._self.share.targets_priority[i].getPosition())) {
			std.summoner.combat.loseTargets(std.summoner._self.share.targets_priority[i]);
			i--;
		}
}

/* std.summoner.combat.loseTargets
 * Loses visible pres by removing it from all non-dead shared arrays and tehn adding it to 'dead'
 */
std.summoner.combat.loseTargets = function(pres) {
	pres = (typeof(pres) === "undefined") ? undefined : pres;
	if (typeof(pres) === "undefined")
		return;
	std.summoner.combat.loseTargetArray(pres, std.summoner._self.share.targets);
	std.summoner.combat.loseTargetArray(pres, std.summoner._self.share.targets_priority);
	std.summoner.combat.loseTargetArray(pres, std.summoner._self.share.loggers);
	std.summoner.combat.loseTargetArray(pres, std.summoner._self.share.allies);
	std.summoner.combat.addTargetArray(pres, std.summoner._self.share.dead);
}

/* std.summoner.combat.loseTargetArray
 * Helper for loseTargets. Removes visible vis from array once if found. 
 */
std.summoner.combat.loseTargetArray = function(vis, array) {
	for (var i in array) {
		if (array[i].getVisibleID() == vis.getVisibleID()) {
			array.splice(i);
			break;
		}
	}
}

/* std.summoner.combat.addTargetArray
 * adds visible vis into array if array doesn't already contain visible vis.
 * used mainly in conjunction with shared arrays (std.summoner._self.shared.targets, etc)
 */
std.summoner.combat.addTargetArray = function(vis, array) {
	for (var i in array) {
		if (array[i].getVisibleID() == vis.getVisibleID())
			return;
	}
	array.push(vis);
}

/* std.summoner.combat.getEffectLength
 * Given the string effectName and the victim monster_data, returns the number of turns the said effect lasts
 */
std.summoner.combat.getEffectLength = function(effectName, monster_data) { // TODO change to limited-monster mode
	if (effectName == "burning") {
		var duration = Math.ceil(2 + Math.random() * 3);
		if (std.summoner.util.hasTrait("shiny", monster_data.traits) || std.summoner.util.hasTrait("infernal", monster_data.traits))
			return 0;
		if (std.summoner.util.hasTrait("hot", monster_data.traits) || std.summoner.util.hasTrait("freezing", monster_data.traits) || std.summoner.util.hasTrait("divine", monster_data.traits))
			duration = duration / 2;
		if (std.summoner.util.hasTrait("undead", monster_data.traits))
			duration = duration * 2;
		return Math.ceil(duration);
	} else if (effectName == "confused", monster_data.traits) {
		var duration = Math.ceil(2 + Math.random() * 3);
		if (std.summoner.util.hasTrait("shiny", monster_data.traits) || std.summoner.util.hasTrait("undead", monster_data.traits))
			return 0;
		if (std.summoner.util.hasTrait("divine", monster_data.traits))
			duration = duration / 2;
		if (std.summoner.util.hasTrait("insane", monster_data.traits))
			duration = duration * 2;
		return Math.ceil(duration);
	}
	return 0;
}

/* std.summoner.combat.findClosestTarget
 * given the current monster, finds the closest priority-target (if any). Otherwise, finds the closest target (if any)
 */
std.summoner.combat.findClosestTarget = function(monster_data) {
	if (std.summoner._self.share.targets_priority.length > 0)
		monster_data.target = std.summoner.combat.getClosest(std.summoner._self.share.targets_priority, monster_data);
	else 
		monster_data.target = std.summoner.combat.getClosest(std.summoner._self.share.targets, monster_data);
	std.summoner.combat.askAlive(monster_data);
}

/* std.summoner.combat.getClosest
 * given an array of possible targets, finds the closest one to the given monster.
 */
std.summoner.combat.getClosest = function(target_array, monster_data) {
	var closest = undefined;
	var closestDist = undefined;
	var newDist = 9999999;
	for (var i in target_array) {
		newDist = target_array[i].getPosition().sub(monster_data.presSelf.getPosition()).length();
		if ((typeof(closest) == 'undefined' || newDist < closestDist) && !std.summoner.util.isInGraveyard(target_array[i].getPosition())) {
			closestDist = newDist;
			closest = target_array[i];
		}
	}
	return closest;
}

/* std.summoner.combat.askAlive
 * asks the target if they are still alive by sending an emerson message
 */
std.summoner.combat.askAlive = function(monster_data) {
	if (monster_data.target && std.summoner.util.isInGraveyard(monster_data.target.getPosition())) {
		std.summoner.combat.loseTargets(monster_data.target);
		return;
	}
	var msg = {action: "askAlive", id_no:monster_data.target.getVisibleID()};
	msg >> monster_data.target >> [std.summoner.combat.catchAlive(monster_data)];
}

/* std.summoner.combat.catchAlive
 * catcher for std.summoner.combat.askAlive
 * if the target is dead, removes them from the target list
 */
std.summoner.combat.catchAlive = function(monster_data) {
	return function(msg, sender) {
		if (msg.dead && msg.id_no == monster_data.presSelf.getPresenceID() && typeof(monster_data.target) !== "undefined" && msg.id_victim == monster_data.target.getVisibleID()) {
			std.summoner.combat.loseTargets(monster_data.target);
		}
	};
}

/* std.summoner.combat.turnInit
 * Determines what a monster does AT THE START OF every turn.
 * A monster sets the banner if the banner is unset. Then computes all effects on the monster.
 * Then, if the monster has area-effects, then it activates them.
 * returns false if the monster is unable to act for the given turn. (frozen or dead or confused)
 */
std.summoner.combat.turnInit = function(monster_data) {
	if (!monster_data.alive)
		return false;
	if (!monster_data.banner_set)
		monster_data.banner_set = std.summoner.effects.banner(monster_data.effects_visual, 'http://shmbr.com/pic/upfiles/vD2U4aPT7keJ/default.jpg', monster_data.size);
	if (std.summoner.util.hasTrait("melting", monster_data.traits)) {
		std.summoner.combat.healthDrain(0.01, monster_data);
	}
	if (typeof(monster_data.effects.burning) !== "undefined" && monster_data.effects.burning > 0) { ;
		if (!std.summoner.effects.hasEffectByName(monster_data.effects_visual, "burning") && monster_data.effects.burning > 1)
			std.summoner.effects.burning(monster_data.effects_visual, monster_data.size);
		std.summoner.combat.healthDrain(monster_data.effects.burning / 20, monster_data);
		monster_data.effects.burning--;
		if (monster_data.effects.burning <= 0)
			std.summoner.effects.clearEffectByName(monster_data.effects_visual, "burning");
	}
	if (typeof(monster_data.effects.confused) !== "undefined" && monster_data.effects.confused > 0) {
		if (!std.summoner.effects.hasEffectByName(monster_data.effects_visual, "confused") && monster_data.effects.confused > 1) {
			std.summoner.effects.confused(monster_data.effects_visual, monster_data.size, monster_data.effects.confused);
		}
		monster_data.effects.confused--;
		var chance = Math.random();
		if (chance < 0.25) {
			std.summoner.combat.stopMovement(monster_data);
			return false;
		}
		chance = chance - 0.25;
		if (chance < 0.25) {
			var tempTarget = monster_data.target;
			monster_data.target = monster_data.presSelf;
			std.summoner.combat.attackTarget (0.5, false, [], true, true, monster_data);
			monster_data.target = tempTarget;
			std.summoner.combat.stopMovement(monster_data);
			return false;
		}
	}
	if (monster_data.effects.frozen != undefined && monster_data.effects.frozen > 0) {
		monster_data.effects.frozen--;
		if (monster_data.effects.frozen <= 0)
			std.summoner.effects.clearEffectByName(monster_data.effects_visual, "frozen");
		std.summoner.combat.stopMovement(monster_data);
		return false;
	}
	var doAoE = false;
	var default_range = 20;
	var visual_range = default_range;
	if (std.summoner.util.hasTrait("horned", monster_data.traits))
		visual_range = visual_range * 2;
	var damage_mod = 0;
	var curses = []
	if (std.summoner.util.hasTrait("fire_breathing", monster_data.traits) && Math.random() < 0.2) {
		doAoE = true;
		damage_mod = damage_mod + 0.3;
		curses.push("burning", monster_data.traits);
		if (std.summoner.effects.firebreathing(monster_data.effects_visual, monster_data.size, visual_range))
			system.__debugPrint("\\nBreathing Fire");
		else
			system.__debugPrint("\\nNot ready to Breathe Fire");
	}
	if (std.summoner.util.hasTrait("charming", monster_data.traits) && Math.random() < 0.3) {
		doAoE = true;
		damage_mod = damage_mod + 0.01;
		curses.push("confused", monster_data.traits);
		if (std.summoner.effects.charming(monster_data.effects_visual, monster_data.size, visual_range))
			system.__debugPrint("\\nCharming Effect");
		else
			system.__debugPrint("\\nNot ready to Charm");
		
	}
	if (doAoE)
		std.summoner.combat.aoeAttack(default_range, damage_mod, curses, monster_data);
	return true;
}

/* std.summoner.combat.stopMovement
 * stops the movement of the given monster. Call this instead of setVelocity(<0,0,0>), because this also handles
 * stopping the visible effects on the monster.
 */
std.summoner.combat.stopMovement = function(monster_data) {
	monster_data.presSelf.setVelocity(<0,0,0>);
	std.summoner.effects.updateVelocities(monster_data.effects_visual, <0,0,0>);
}

/* std.summoner.combat.attackTarget
 * The attack message of monsters.
 * mod is a multiplicative modifier on the monster's attack (usually 1)
 * face_target is if the monster should face the target when attacking.
 * give_effects is an array of the effects that the monster gives to its victim
 * is_melee is true if the monster is doing a melee attack
 * target_is_pres is true in the case that the monster is attacking a presence and not a visible. Usually, this means the
 *  monster is confused and is attacking itself.
 * monster_data is the attacking monster's data.
 */
std.summoner.combat.attackTarget = function(mod, face_target, give_effects, is_melee, target_is_pres, monster_data) {
	face_target = (typeof(face_target) == 'undefined') ? true : face_target;
	target_is_pres = (typeof(target_is_pres) !== "boolean") ? false : target_is_pres;
	if (face_target)
		std.summoner.combat.faceTarget(monster_data);
	mod = (typeof(mod) == 'undefined') ? 1 : mod;
	give_effects = (typeof(give_effects) == 'undefined') ? [] : give_effects;
	is_melee = (typeof(is_melee) == 'undefined') ? true : is_melee;
	if (std.summoner.util.hasTrait("vampiric", monster_data.traits) && is_melee) {
		monster_data.health = monster_data.health + Math.ceil(Math.abs(power) / 10);
		if (monster_data.health > monster_data.health_max)
			monster_data.health = monster_data.health_max;
	}
	if (std.summoner.util.hasTrait("infernal", monster_data.traits) && is_melee) {
		give_effects.push("burning");
	}
	var targetid = (!target_is_pres) ? monster_data.target.getVisibleID() : monster_data.target.getPresenceID();
	var atk = {action:"Attack", name:monster_data.name, stats:monster_data, owner:monster_data.owner, id_no:targetid, power:Math.ceil(monster_data.power * mod), traits:monster_data.traits, give_effects:give_effects, is_melee:is_melee, self_id_no:monster_data.presSelf.getPresenceID()};
	atk >> monster_data.target >> [std.summoner.combat.attackCatcher(monster_data)];
}

/* std.summoner.combat.attackCatcher
 * the associated catcher to std.summoner.combat.attackTarget
 * checks if target died. Otherwise, checks combat-reflecting effects (freezing, cute)
 */
std.summoner.combat.attackCatcher = function(monster_data) {
	return function (msg, sender) {
		if (msg.id_no != monster_data.presSelf.getPresenceID() || (typeof(monster_data.target) != 'undefined' && msg.id_victim != monster_data.target.getVisibleID()))
			return;
		if (msg.died) {
			std.summoner.combat.loseTargets(sender);
			monster_data.target = undefined;
		}
		
		if (msg.damage > 0) {
			if (std.summoner.util.hasTrait("freezing", msg.traits) && !(std.summoner.util.hasTrait("chilly", monster_data.traits) || std.summoner.util.hasTrait("cold_blooded", monster_data.traits) || std.summoner.util.hasTrait("infernal", monster_data.traits) || std.summoner.util.hasTrait("shiny", monster_data.traits)) && Math.random() < 0.5) {
				monster_data.effects.frozen = Math.ceil(Math.random() * 3 + 2);
				if (std.summoner.util.hasTrait("hot", monster_data.traits))
					monster_data.effects.frozen = Math.floor(monster_data.effects.frozen / 2);
				std.summoner.effects.frozen(monster_data.effects_visual, monster_data.effects.frozen, monster_data.size);
			}
			if (std.summoner.util.hasTrait("cute", msg.traits) && !(std.summoner.util.hasTrait("shiny", monster_data.traits))) {
				monster_data.health = Math.ceil(monster_data.health * 0.75);
			}
		}
	}
}

/* std.summoner.combat.faceTarget
 * sets the orientation of the given monster to face the target of the given monster
 */
std.summoner.combat.faceTarget = function(monster_data) {
	if (monster_data.target && !std.summoner.util.isInGraveyard(monster_data.target.getPosition())) {
		monster_data.presSelf.setOrientation(util.Quaternion.fromLookAt(monster_data.target.getPosition().sub(monster_data.presSelf.getPosition()).mul(-1), <0,1,0>));
	}
}

/* std.summoner.combat.aoeAttack
 * Does an AoE attack. Hits every possible target within the monster's natural range * range_modifier
 * and does the monster's natural damate * damage_modifier
 * and gives effects based on give_effects
 */
std.summoner.combat.aoeAttack = function(range_modifier, damage_modifier, give_effects, monster_data) {
	var original_target = monster_data.target;
	for (var i in std.summoner._self.share.targets_priority) {
		if (std.summoner.combat.targetWithinReach(std.summoner._self.share.targets_priority[i], range_modifier, false, monster_data)) {
			monster_data.target = std.summoner._self.share.targets_priority[i];
			std.summoner.combat.attackTarget (damage_modifier, false, give_effects, false, false, monster_data);
		}
	}
	for (var i in std.summoner._self.share.targets) {
		if (std.summoner.combat.targetWithinReach(std.summoner._self.share.targets[i], range_modifier, false, monster_data)) {
			monster_data.target = std.summoner._self.share.targets[i];
			std.summoner.combat.attackTarget (damage_modifier, false, give_effects, false, false, monster_data);
		}
	}
	monster_data.target = original_target;
}

/* std.summoner.combat.targetWithinReach
 * returns true if the given target is alive and within reach of the given monster
 */
std.summoner.combat.targetWithinReach = function(target, mod, debug, monster_data) {
	if (!target || std.summoner.util.isInGraveyard(target.getPosition()))
		return false;
	var modifier = mod;
	if (!modifier)
		modifier = 1;
	var dist = target.getPosition().sub(monster_data.presSelf.getPosition()).length();
	if (std.summoner.util.hasTrait("horned", monster_data.traits))
		modifier = modifier * 2;
	if (std.summoner.util.hasTrait("devouring", monster_data.traits))
		modifier = modifier / 2;
	if (debug)
		system.__debugPrint("\\ndist: " + dist + " | range: " + (target.getScale() + (monster_data.presSelf.getScale() * modifier)).toString());
	if (dist > target.getScale() + (monster_data.presSelf.getScale() * modifier))
		return false;
	return true;
}

/* std.summoner.combat.healthDrain
 * Lowers current health by a percentage. Doesn't reduce health below 1.
 * Used for the trait 'melting'. I think.
 */
std.summoner.combat.healthDrain = function(percentage, monster_data) {
	monster_data.health = monster_data.health - Math.ceil(monster_data.health * percentage);
	if (monster_data.health <= 0)
		monster_data.health = 1;
}

/* std.summoner.combat.healAllies
 * Heals nearby allies, which are other monsters in the player's "hand" that are within range. 
 */
std.summoner.combat.healAllies = function(monster_data) {
	var heal = {action:"Attack", name:monster_data.name, stats:monster_data, owner:monster_data.owner, power:-1 * Math.ceil(monster_data.power / 10), traits:monster_data.traits};
	for (var i in std.summoner._self.share.allies) {
		if (std.summoner.combat.targetWithinReach(std.summoner._self.share.allies[i], 1, false, monster_data)) {
			heal.id_no = std.summoner._self.share.allies[i].getVisibleID();
			heal >> std.summoner._self.share.allies[i] >> [];
		}
	}
}

/* std.summoner.prod
 * sends an attack of 0 dmg with no effects. This attack doesn't get parsed by the opponent, but it does help the opponent 'see' the current monster
 */
std.summoner.combat.prod = function(vis, monster_data) {
	var prod = {action:"Attack", name:monster_data.name, stats:monster_data, owner:monster_data.owner, id_no:vis.getVisibleID(), power:0, traits:monster_data.traits, self_id_no:monster_data.presSelf.getPresenceID()};
	prod >> vis >> [];
}

/* std.summoner.combat.moveToTarget
 * moves to the target of given monster.
 */
std.summoner.combat.moveToTarget = function(monster_data) {
	var distVector = monster_data.presSelf.getPosition().sub(monster_data.target.getPosition()).mul(-1);
	var distLength = distVector.length();
	std.summoner.combat.faceTarget(monster_data);
	var distVector = distVector.normal().mul(monster_data.speed);
	if (distVector.length() > distLength)
		distVector = distVector.scale(distLength / distVector.length()); // scaling value should change depending on behavior interval
	monster_data.presSelf.setVelocity(distVector);
	std.summoner.effects.updateVelocities(monster_data.effects_visual, distVector);
}

/* std.summoner.combat.death
 * This function is called when monster dies. Ceases monster activity by suspending the timers
 * also notifies all players in std.summoner._self.share.loggers that a death occurred.
 */
std.summoner.combat.death = function (killerName, killerStats, killerOwner, monster_data) {
	system.__debugPrint("\\nEntered Death Function\\n");
	var sendDeathData = {
		action:"SummonerReportDeath",
		victim_owner: monster_data.owner,
		victim: monster_data.name,
		victim_stats: monster_data,
		killer_owner: killerOwner,
		killer: killerName,
		killer_stats: killerStats
	};
	for (var i in std.summoner._self.share.loggers) {
		sendDeathData.id_no = std.summoner._self.share.loggers[i].getVisibleID();
		sendDeathData >> std.summoner._self.share.loggers[i] >> [];
	}
	std.summoner.effects.clearAll(monster_data.effects_visual);
	// kill all sensors and visuals on monster. And then bury it. 
	monster_data.alive = false;
	if (monster_data.behaviorTimer)
		monster_data.behaviorTimer.suspend();
	if (monster_data.queryTimer)
		monster_data.queryTimer.suspend();
	if (monster_data.opa)
		monster_data.opa.clear();
	if (monster_data.opr)
		monster_data.opr.clear();
	monster_data.presSelf.setMesh(""); // invisible
	std.summoner.combat.stopMovement(monster_data);
	monster_data.presSelf.setPosition(std.summoner._self.fixed.graveyard); // graveyard
	monster_data.presSelf.setScale(0); // nonexistant
	monster_data.presSelf.setQueryAngle(11); // blind
	monster_data.target = undefined;
}

// Set target detection
/* std.summoner.combat.detectTargetsWrapper
 * The main function for detecting enemy monsters and players.used in conjunction with onProxAdded
 */
std.summoner.combat.detectTargetsWrapper = function(monster_data) {
	return function(pres) {
		//system.__debugPrint("\\n" + presSelf.getPresenceID() + " sees " + pres.getVisibleID());
		system.timeout(2, detectTargets);
		function detectTargets() {
			//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + pres.getVisibleID() + " within DetectTargets");
			std.summoner.combat.prod(pres, monster_data);
			// Ask if they are playing the game
			var ask = {action:"SummonerAskPlaying", id_no:pres.getVisibleID()};
			function isPlayingCatcher (resp, sender) {
				//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + pres.getVisibleID() + " within isPlayingCatcher");
				if (resp.isPlayingSummoner && resp.id_no == pres.getVisibleID()) {
					// Ask their owner
					var ask2 = {action:"SummonerAskOwner", id_no:pres.getVisibleID()};
					function isOwnerCatcher (r2,s2) {
						//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + pres.getVisibleID() + " within isOwnerCatcher");
						if (r2.id_no != monster_data.presSelf.getPresenceID()) 
							std.summoner.combat.queueTarget(pres, r2.owner, r2.traits, r2.is_summoner, monster_data);
					}
					ask2 >> sender >> [isOwnerCatcher];
					
					// Ask if they want logging
					var ask3 = {action:"SummonerAskLog", id_no:pres.getVisibleID()};
					function isLogCatcher (r3,s3) {
						if (r3.SummonerLog) {
							var alreadyLogging = false;
							for (var i in std.summoner._self.share.loggers) {
								if (std.summoner._self.share.loggers[i].getVisibleID() == pres.getVisibleID()) {
									alreadyLogging = true;
									break;
								}
							}
							if (!alreadyLogging) std.summoner._self.share.loggers.push(pres);
						}
					}
					ask3 >> sender >> [isLogCatcher];
				}
			};
			ask >> pres >> [isPlayingCatcher];
		}
	}
}

/* std.summoner.combat.addTargets
 * adds visible into target array if they aren't already in the array
 */
std.summoner.combat.addTargets = function(pres, array) {
	//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + pres.getVisibleID() + " within addTargets");
	for (var i in array) {
		if (array[i].getVisibleID() == pres.getVisibleID()) {
			//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + pres.getVisibleID() + " Failure - already in array");
			return;
		}
	}
	//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + pres.getVisibleID() + " Success - now should be in array.");
	array.push(pres);
}

/* std.summoner.combat.queueTarget
 * queues the target into the right array between std.summoner._self.shared.targets, targets_priority, or allies
 */
std.summoner.combat.queueTarget = function(vis, vis_owner, vis_traits, is_summoner, monster_data) {
	//system.__debugPrint("\\n" + presSelf.getPresenceID() + " - " + vis.getVisibleID() + " within queueTarget");
	if (vis.getVisibleID() == monster_data.presSelf.getPresenceID())
		return;
	std.summoner.combat.loseTargetArray (vis, std.summoner._self.share.dead);
	if ((vis_owner != monster_data.owner /*|| std.summoner.util.hasTrait("insane", monster_data.traits)*/) && vis_owner != "god" && std.summoner.util.hasTrait("edible", vis_traits))  {// different condition for different traits
		if (std.summoner.util.hasTrait("scary", vis_traits) && !(std.summoner.util.hasTrait("shiny", monster_data.traits) || std.summoner.util.hasTrait("strong", monster_data.traits) || std.summoner.util.hasTrait("infernal", monster_data.traits) || std.summoner.util.hasTrait("divine", monster_data.traits) || std.summoner.util.hasTrait("cold_blooded", monster_data.traits)) && Math.random() < 0.5) {
			;
		} else {
			std.summoner.combat.addTargets(vis, std.summoner._self.share.targets_priority);
		}
	} else if ((vis_owner != monster_data.owner /*|| std.summoner.util.hasTrait("insane", monster_data.traits)*/) && vis_owner != "god" && !std.summoner.util.hasTrait("edible", vis_traits))  {// different condition for different traits
		if (std.summoner.util.hasTrait("scary", vis_traits) && !(std.summoner.util.hasTrait("shiny", monster_data.traits) || std.summoner.util.hasTrait("strong", monster_data.traits) || std.summoner.util.hasTrait("infernal", monster_data.traits) || std.summoner.util.hasTrait("divine", monster_data.traits) || std.summoner.util.hasTrait("cold_blooded", monster_data.traits)) && Math.random() < 0.5) {
			;
		} else {
			//printTargets();
			//system.print("adding target" + vis.getVisibleID() + " to targets array.");
			std.summoner.combat.addTargets(vis, std.summoner._self.share.targets);
		}
	}
	if (vis_owner == monster_data.owner && std.summoner.util.hasTrait("nice", monster_data.traits)) {
		std.summoner.combat.addTargets(vis, std.summoner._self.share.allies);
	}
	if (vis_owner == monster_data.owner && std.summoner.util.hasTrait("loyal", monster_data.traits) && (typeof(is_summoner) === "boolean") && is_summoner)
		summoner = std.summoner._self.other.self_pres;
}

/* std.summoner.combat.behavior
 * given the monster presence and the data associated with the monster,
 * returns the function to use in the repeatingTimer for the monster
 * this determines what the monster does each turn.
 */
std.summoner.combat.behavior = function(pres, monster_data) {
	return function () {
		//printTargets();
		var dir;
		if (!std.summoner.combat.turnInit(monster_data)) // also takes care of effect-related things
			return;
		std.summoner.combat.cleanTargets();
		if (std.summoner.util.hasTrait("nice", monster_data.traits))
			std.summoner.combat.healAllies(monster_data);
		if (std.summoner._self.share.targets.length == 0 || (std.summoner.util.hasTrait("whimsical", monster_data.traits) && Math.random() < 0.2)) {
			dir = Math.random() * Math.PI * 2;
			var newVelocity = <Math.cos(dir) * monster_data.speed, 0 ,Math.sin(dir) * monster_data.speed>;
			pres.setVelocity(newVelocity);
			std.summoner.effects.updateVelocities(monster_data.effects_visual, newVelocity);
			pres.setOrientation(util.Quaternion.fromLookAt(pres.getVelocity().mul(-1), <0,1,0>));
			//system.__debugPrint("\\n" + monster_data.presSelf.getPresenceID() + " WANDERING");
			return;
		}
		std.summoner.combat.findClosestTarget(monster_data);
		if (std.summoner.combat.targetWithinReach(monster_data.target, 1, false, monster_data)) {
			//system.__debugPrint("\\n" + monster_data.presSelf.getPresenceID() + " STOPPING TO ATTACK");
			std.summoner.combat.attackTarget(1, true, [], true, false, monster_data);
			std.summoner.combat.stopMovement(monster_data);
		} else {
			if (std.summoner.util.hasTrait("loyal", monster_data.traits))
				monster_data.target = std.summoner._self.other.self_pres;
			std.summoner.combat.moveToTarget(monster_data);
			//system.__debugPrint("\\n" + monster_data.presSelf.getPresenceID() + " GOING TO TARGET");
		}
	};
}

/* std.summoner.combat.setBehavior
 * sets the repeating timer to start after a bit of time elapses. 
 * This is necessary because the behavior timer may be initialized before the presence is initialized.
 */
std.summoner.combat.setBehavior = function (monster_data) {
	monster_data.behaviorTimer = (typeof(monster_data.behaviorTimer) === "undefined") ? new std.core.RepeatingTimer(1,std.summoner.combat.behavior(monster_data.presSelf, monster_data)) : monster_data.behaviorTimer;
}

/* std.summoner.combat.reQuery, setQueryTimer, unQuery
 * Unused as of now. They used to be used for jittering the queryAngle to 'help' with visible detection, but it didn't help anyway.
 */
std.summoner.combat.reQuery = function () {
	presSelf.setQueryAngle(11);
	queryLag.resetTimer(1);
}
std.summoner.combat.setQueryTimer = function() {
	queryLag = system.timeout(1,unQuery);
	queryTimer = new std.core.RepeatingTimer(4, reQuery);
}
std.summoner.combat.unQuery = function() {
	presSelf.setQueryAngle(default_queryangle);
}

/* std.summoner.combat.startTimers
 * call to start timers
 */
std.summoner.combat.startTimers = function(monster_data) {
	return function() {
		std.summoner.combat.setBehavior(monster_data);
		//setQueryTimer();
	};
}

/*--------- std.summoner.monster namespace starts here ---------*/
/* std.summoner.monster is the public namespace that other Summoner files call. std.summoner.combat is generally only used within this file. */
/* std.summoner.monster.callbackwrapper
 * The function to call whenever you make a monster presence.
 * This sets the monster's response functions to actions such as
 * SummonerAskPlaying, SummonerAskOwner, SummonerAskLog, Attack, askAlive
 * as well as setting onProxAdded.
 */
std.summoner.monster.callbackwrapper = function(monsterNum) {
	return function(presSelf) {
		// Set base stats and variables
		var monster_data = std.summoner._self.stats.hand[monsterNum];
		monster_data.presSelf = presSelf;
		//system.__debugPrint("\\nSet Presself");
		//std.summoner.combat.initSelf(stats, monster_data);
		monster_data.effects_visual = std.summoner.effects.initEffects(presSelf);
		
		
		/* Duplication no longer works due to fixed monster-limit for security
		function Duplicate() {
			var newstats = {};
			var curPos = presSelf.getPosition();
			for (i in stats)
				newstats[i] = stats[i];
			newstats.damage = health_max - Math.ceil(health / 2);
			newstats.initPos = {};
			newstats.initPos.x = curPos.x;
			newstats.initPos.y = curPos.y;
			newstats.initPos.z = curPos.z;
			system.createPresence(newstats.MeshURL, std.summoner.monster.callbackwrapper(newstats.Name, newstats, owner));
		}
		*/
		monster_data.opa = monster_data.presSelf.onProxAdded(std.summoner.combat.detectTargetsWrapper(monster_data), true);
		
		// Set target loss
		
		opr = undefined; //presSelf.onProxRemoved(loseTargets);
		
		// Set answering detect calls
		function respPlaying (monster_data) {
			return function(msg, sender) {
				//if (!monster_data.alive)
				//	return;
				var resp = {isPlayingSummoner:"true", id_no:monster_data.presSelf.getPresenceID()};
				msg.makeReply(resp) >> [];
			};
		}
		respPlaying(monster_data) << [{"action":"SummonerAskPlaying":},
									  {"id_no":monster_data.presSelf.getPresenceID():}];
		
		function respOwner (monster_data) {
			return function (msg, sender) {
				//if (!monster_data.alive)
				//	return;
				var resp = {owner:monster_data.owner, id_no:monster_data.presSelf.getPresenceID(), traits:monster_data.traits};
				msg.makeReply(resp) >> [];
			}
		}
		respOwner(monster_data) << [{"action":"SummonerAskOwner":},
									{"id_no":monster_data.presSelf.getPresenceID():}];
		
		function respLog (msg, sender) {
			var resp = {};
			msg.makeReply(resp) >> []; // a way to say that monsters don't need logging
		}
		respLog << [{"action":"SummonerAskLog":},
					{"id_no":monster_data.presSelf.getPresenceID():}];
		
		function respAttack (monster_data) {
			return function(msg, sender) {
				if (!monster_data.alive && msg.power > 0)
					return;
				if (sender.getVisibleID() == monster_data.presSelf.getPresenceID() && msg.power > 0)
					system.__debugPrint("\\nATTACKING SELF");
				//if (msg.power <= 0)
				//	system.__debugPrint("\\nreceived PROD from: " + sender.getVisibleID());
				var response = {id_no:sender.getVisibleID(), traits:monster_data.traits, id_victim:monster_data.presSelf.getPresenceID(), damage: 0};
				var hit = true;
				var modifier = 0;
				if ((std.summoner.util.hasTrait("teeny", monster_data.traits) && Math.random() < 0.35 && !std.summoner.util.hasTrait("divine", msg.traits)) || msg.power <= 0)
					hit = false;
				if (std.summoner.util.hasTrait("charming", monster_data.traits) && Math.random() < 0.5)
					hit = false;
				if (msg.power < 0)
					hit = true;
				if (hit && monster_data.alive) { // Damage modifiers here.
					if ((std.summoner.util.hasTrait("hot", msg.traits) && std.summoner.util.hasTrait("chilly", monster_data.traits)) || (std.summoner.util.hasTrait("chilly", msg.traits) && std.summoner.util.hasTrait("hot", monster_data.traits)))
						modifier = modifier + 0.5;
					if ((std.summoner.util.hasTrait("evil", msg.traits) && std.summoner.util.hasTrait("good", monster_data.traits)) || (std.summoner.util.hasTrait("good", msg.traits) && std.summoner.util.hasTrait("evil", monster_data.traits)))
						modifier = modifier + 0.5;
					if (std.summoner.util.hasTrait("cold_blooded", msg.traits) && !(std.summoner.util.hasTrait("chilly", monster_data.traits) || std.summoner.util.hasTrait("divine", monster_data.traits))) {
						modifier = modifier + 1;
						if (std.summoner.util.hasTrait("hot", monster_data.traits))
							modifier = modifier + 1;
					}
					if (std.summoner.util.hasTrait("divine", monster_data.traits))
						modifier = modifier - 0.5;
					if ((std.summoner.util.hasTrait("evil", monster_data.traits) || std.summoner.util.hasTrait("undead", monster_data.traits)) && std.summoner.util.hasTrait("divine", msg.traits))
						modifier = modifier + 1;
					if (std.summoner.util.hasTrait("infernal", msg.traits) && !(std.summoner.util.hasTrait("divine", monster_data.traits)))
						modifier = modifier + 1.5;
					if (msg.power < 0)
						modifier = 0;
					monster_data.health = monster_data.health - Math.ceil(msg.power * (1 + modifier));
					response.damage = Math.ceil(msg.power * (1 + modifier));
					if (typeof(msg.give_effects) == 'object' && msg.give_effects.length > 0 && msg.power > 0)
						for (var i in msg.give_effects) {
							if (typeof(monster_data.effects[msg.give_effects[i]]) == 'undefined')
								monster_data.effects[msg.give_effects[i]] = 0;
							monster_data.effects[msg.give_effects[i]] = monster_data.effects[msg.give_effects[i]] + std.summoner.combat.getEffectLength(msg.give_effects[i], monster_data);
						}
					if (monster_data.health > monster_data.health_max)
						monster_data.health = monster_data.health_max;
					if (monster_data.health < 0)
						monster_data.health = 0;
					if (monster_data.health == 0) {
						response.died = "true";
						std.summoner.combat.death(msg.name, msg.stats, msg.owner, monster_data);
					}
					system.__debugPrint("\\nHealth: " + monster_data.health.toString());
				}
				msg.makeReply(response) >> [];
				
				std.summoner.combat.queueTarget(sender, msg.owner, msg.traits, msg.is_summoner, monster_data);
			}
		}
		respAttack(monster_data) << [{"action":"Attack":},
									 {"id_no":monster_data.presSelf.getPresenceID():}];
		
		function respAlive (monster_data) {
			return function (msg, sender) {
				var resp = {id_no: sender.getVisibleID(), id_victim: monster_data.presSelf.getPresenceID()};
				if (!monster_data.alive)
					resp.dead = "true";
				msg.makeReply(resp) >> [];
			}
		}
		respAlive(monster_data) << [{"action":"askAlive":},
									{"id_no":monster_data.presSelf.getPresenceID():}];
		
	};
}

/* std.summoner.monster.SummonMonster
 * Function that is called ot summon a monster
 * name is the full name of the monster. i.e. "small shiny melting hound"
 */
std.summoner.monster.SummonMonster = function(name, owner) {
	if (!std.summoner._self.stats.alive)
		return;
	var monster = std.summoner.util.NameToObj(name);
	for (var i in std.summoner._self.fixed.bestiary) {
		if (i.toLowerCase() == monster.name.toLowerCase()) {
			std.summoner.monster.SummonMonsterWithStats(std.summoner._self.fixed.bestiary[i], owner, monster.traits);
			break;
		}
	}
}

/* std.summoner.monster.SummonMonsterWithStats
 * summons the given monster. Helper to std.summoner.monster.SummonMonster
 */
std.summoner.monster.SummonMonsterWithStats = function(stats, owner, custom_traits) {
	var manacost = std.summoner.monster.CheckSummonable(stats, owner, custom_traits);
	var ownername = owner.name;
	var monsterObj = std.summoner._self.stats.hand[std.summoner.monster.getMonsterFromHand()];
	if (std.summoner._self.stats.godmode)
		ownername = Math.random().toString();
	if (manacost == -1)
		return false;
	std.summoner.util.PayMana(owner, manacost);
	std.summoner.util.Learn(owner, manacost, stats);
	std.summoner.log.Report("Summon", owner.name, std.summoner.util.ObjToName(custom_traits, stats.Name), "", "");
	stats.CustomTraits = std.summoner.library.BooksToTitles(custom_traits);
	monsterObj.MeshURL = stats.MeshURL;
	/*
	var pres = {
		mesh:stats.MeshURL,
		scale:1,
		callback:std.summoner.monster.callbackwrapper(stats.Name, stats, ownername),
		solidAngleQuery:0.0001
	};
	system.createPresence(pres);
	*/
	std.summoner.combat.initSelf (stats, monsterObj, stats.Name);
}

/* std.summoner.monster.getMonsterFromHand
 * returns the best key in the hand. If anything in the hand is unused or dead, returns that first.
 * If all hand slots are used, then returns the key associated with the oldest monster alive.
 */
std.summoner.monster.getMonsterFromHand = function() {
	var latestTime = 9999999999999;
	var bestHand = 0;
	for (var i in std.summoner._self.stats.hand) {
		if (!std.summoner._self.stats.hand[i].alive)
			return i;
		else if (std.summoner._self.stats.hand[i].summon_timestamp < latestTime) {
			latestTime = std.summoner._self.stats.hand[i].summon_timestamp;
			bestHand = i;
		}
	}
	return bestHand;
}

/* std.summoner.monster.CheckSummonable
 * Checks if it is possible to summon the monster. Returns the manacost if possible. 
 * Returns -1 if impossible. Impossible usually means the player doesn't have enough mana.
 */
std.summoner.monster.CheckSummonable = function(stats, owner, custom_traits) {
	var complexity = std.summoner.util.CalcComplexity(stats, custom_traits);
	if (!std.summoner.util.CheckComplexity(complexity, owner.exp)) {
		system.__debugPrint("\\nSUMMONING FAIL: too complex");
		return -1;
	}
	var manacost = std.summoner.util.CalcManaUse(complexity);
	if (!std.summoner.util.CheckMana(manacost, owner)) {
		system.__debugPrint("\\nSUMMONING FAIL: not enough mana");
		return -1;
	}
	return manacost;
}

@;
