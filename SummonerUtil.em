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

 /* SummonerUtil
  * This file defines general utility functions in the Summoner Game
  * SummonerUtil does nothing on its own, and any Summoner File can call
  * SummonerUtil functions.
  */
 
if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerUtil = @

if (typeof(std) === "undefined") std = {};
if (typeof(std.summoner) === "undefined") std.summoner = {};
if (typeof(std.summoner.util) === "undefined") std.summoner.util = {};

/* std.summoner.util.hasTrait
 * returns true if traitName exists in the trait_array
 */
std.summoner.util.hasTrait = function(traitName, trait_array) {
	trait_array = (typeof(trait_array) === 'undefined') ? [] : trait_array;
	if (typeof(trait_array) === 'undefined' || typeof(traitName) === 'undefined')
		return false;
	if (trait_array[traitName])
		return true;
	return false;
}

/* std.summoner.util.printTargets
 * debugging function that prints everything within the std.summoner._self.share.targets array.
 * This output is generally more meaningful than the targets_priority array, because the targets_priority array usually
 * contain nothing. (only edible monsters go there)
 */
std.summoner.util.printTargets = function() {
	system.__debugPrint("\\n num_targets: " + std.summoner._self.share.targets.length.toString());
	for (i in std.summoner._self.share.targets) {
		system.__debugPrint("\\n target " + i.toString() + ": " + std.summoner._self.share.targets[i].getVisibleID());
	}
}

/* std.summoner.util.isInGraveyard
 * Checks if the said location is inthe graveyard
 */
std.summoner.util.isInGraveyard = function(pos) {
	var graveyard = std.summoner._self.fixed.graveyard;
	if (typeof(pos) === "object" && typeof(pos.x) === "number" && typeof(pos.y) === "number" && typeof(pos.z) === "number" && pos.x == graveyard.x && pos.y == graveyard.y && pos.z == graveyard.z)
		return true;
	return false;
}


/* std.summoner.util.NameToObj
 * Gets the name string for an object, such as "edible huge firebreathing cat"
 * and returns the object equivalent, which is {name: "cat", traits:[edible, huge, firebreathing]}
 */
std.summoner.util.NameToObj = function (str) {
	var name;
	var trait_array = [];
	var array = str.toLowerCase().split(" ");
	var returnobj = {};
	for (var i = 0; i < array.length; i++) {
		if (i != array.length - 1) {
			var lookup = std.summoner.library.Lookup(array[i]);
			if (lookup)
				trait_array.push(lookup);
		}
		else
			name = array[i];
	}
	returnobj.name = name;
	returnobj.traits = trait_array;
	return returnobj;
}

/* std.summoner.util.ObjToName
 * Does the opposite of std.summoner.util.NameToObj
 */
std.summoner.util.ObjToName = function(bookarray, name) {
	var returnstr = "";
	for (i in bookarray) {
		returnstr = returnstr + bookarray[i].name + " ";
	}
	returnstr = returnstr + name;
	return returnstr;
}

/* std.summoner.util.ArrayName
 * I forgot what the difference between this and ObjToName
 */
std.summoner.util.ArrayName = function(titles, name) {
	var returnstr = "";
	for (i in titles) {
		returnstr = returnstr + titles[i] + " ";
	}
	returnstr = returnstr + name;
	return returnstr;
}

/* std.summoner.util.CalcComplexity
 * Calculates the complexity depending on the base complexity of the monster
 * and each complexity of traits involved
 * The formula is: base + (trait_base1 + trait_base2 + trait_base3 ... + trait_base_number_of_traits) + (1 + 2 + 3 + ... number_of_traits) * 2
 */
std.summoner.util.CalcComplexity = function(stats, custom_traits) {
	var base = stats.Complexity;
	var custom = 0;
	var friction = 0;
	var numTraits = 0;
	var friction_modifier = 2;
	var total;
	for (i in custom_traits) {
		custom = custom + custom_traits[i].comp;
		friction = friction + friction_modifier * numTraits;
		numTraits++;
	}
	total = base + custom + friction;
	if (total < 0)
		total = 1;
	//system.__debugPrint("Complexity is: " + base.toString() + "/" + custom.toString() + "/" + friction.toString() + " TOTAL: " + total);
	return total;
}

/* std.summoner.util.CheckComplexity
 * Checks whether the summoner has enough experience to summon said monster
 */
std.summoner.util.CheckComplexity = function(complexity, experience) {
	if (complexity <= experience)
		return true;
	return false;
}

/* std.summoner.util.CalcManaUse
 * Returns the amount of mana necessary to summon said monster, which is just 10 * complexity.
 * Complexity is computed in std.summoner.util.CalcComplexity
 */
std.summoner.util.CalcManaUse = function(complexity) {
	return 10 * complexity;
}

/* std.summoner.util.CheckMana
 * Checks if the player has enough mana to summon said monster
 */
std.summoner.util.CheckMana = function(mana, owner) {
	//system.__debugPrint("\\n" + owner.mana_cur.toString() + " mana left. Attempting to use " + mana.toString() + " mana.");
	if (owner.mana_cur >= mana)
		return true;
	return false;
}

/* std.summoner.util.PayMana
 * Removes mana from the summoner
 */
std.summoner.util.PayMana = function(owner, mana) {
	owner.mana_cur = owner.mana_cur - mana;
}

/* std.summoner.util.Learn
 * Sets the growth of the summoner. Generally called once after each successful summon.
 * The experience increases, as well as the max-mana and mana regenration rate.
 * Also, the summoner learns traits based on what kind of monster s/he summoned. 
 */
std.summoner.util.Learn = function(owner, mana, stats) {
	owner.exp = owner.exp + Math.ceil(mana / 10);
	owner.mana_max = std.summoner.util.CalcManaUse(owner.exp);
	owner.mana_regen = std.summoner.util.CalcManaRegen(owner.mana_max);
	var learn_traits = [];
	for (i in stats.InnateTraits)
		if (Math.random() < std.summoner._self.other.learn_rate)
			learn_traits.push(stats.InnateTraits[i]);
	for (i in stats.LearnableTraits)
		if (Math.random() < std.summoner._self.other.learn_rate)
			learn_traits.push(stats.LearnableTraits[i]);
	std.summoner.summoner.UpdateLearnedTraits(owner, std.summoner._self.fixed.library, learn_traits);
	std.summoner.summoner.UpdateLearnedBeasts(owner, std.summoner._self.fixed.bestiary);
	simulator._summoner._SummonerMainModule.call("SummonerMainUpdate", owner);
}

/* std.summoner.util.CalcManaMax
 * The maximum mana a player has, which is simply experience * 10
 */
std.summoner.util.CalcManaMax = function(exp) {
	return exp * 10;
}

/* std.summoner.util.CalcManaRegen
 * The mana regenration rate function
 */
std.summoner.util.CalcManaRegen = function(mana_max) {
	return Math.ceil(mana_max * 0.05);
}

/* std.summoner.util.Regen
 * The regeneration function, which is called every couple of seconds in the regeneration repeatingTimer
 */
std.summoner.util.Regen = function() {
	if (!std.summoner._self.stats.alive)
		return;
	//system.__debugPrint("\\nBEFORE: " + std.summoner._self.stats.mana_cur.toString() + ". Regen: " + std.summoner._self.stats.mana_regen.toString());
	std.summoner._self.stats.mana_cur = std.summoner._self.stats.mana_cur + std.summoner._self.stats.mana_regen;
	//system.__debugPrint("\\nAFTER: " + std.summoner._self.stats.mana_cur.toString());
	if (std.summoner._self.stats.mana_cur > std.summoner._self.stats.mana_max) {
		std.summoner._self.stats.mana_cur = std.summoner._self.stats.mana_max;
	}
	std.summoner._self.stats.health_cur = std.summoner._self.stats.health_cur + std.summoner._self.stats.health_regen;
	if (std.summoner._self.stats.health_cur > std.summoner._self.stats.health_max) {
		std.summoner._self.stats.health_cur = std.summoner._self.stats.health_max;
	}
	simulator._summoner._SummonerMainModule.call("SummonerMainUpdate", std.summoner._self.stats);
}

@;

