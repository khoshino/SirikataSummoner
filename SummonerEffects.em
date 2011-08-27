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
 
 /* SummonerEffects
  * This file is used to generate the visual effects on monsters in the game. 
  * Effects are generally presences that float around a monster to describe its state in some way.
  * Every monster has a set number of effect presences, and it recycles them as needed.
  */
 
if (typeof(std)              === "undefined") std              = {};
if (typeof(std.summoner)     === "undefined") std.summoner     = {};
if (typeof(std.summoner.msg) === "undefined") std.summoner.msg = {};
std.summoner.msg.SummonerEffects = @


if (typeof(std)                           === "undefined") std                           = {};
if (typeof(std.summoner)                  === "undefined") std.summoner                  = {};
if (typeof(std.summoner.effects)          === "undefined") std.summoner.effects          = {};
if (typeof(std.summoner.effects.behavior) === "undefined") std.summoner.effects.behavior = {};
system.require('std/core/repeatingTimer.em');
system.require('std/graphics/billboard.em');

/* std.summoner.effects.initEffects
 * Initializes the effects given the parent presence
 * The parent must keep the effects that are returned and use it as a parameter for std.summoner.effects functions
 */
std.summoner.effects.initEffects = function(parent) {
	var effects = {};
	var num_effects = 4;
	effects.effects = [];
	effects.is_ready = false;
	effects.num_effects = num_effects;
	effects.num_ready = 0;
	effects.parent = parent
	var banner = true;
	for (var i = 0; i < num_effects; i++) {
		std.summoner.effects.createEffect(parent, effects.effects, banner, effects, i);
		banner = false;
	}
	return effects;
};

/* std.summoner.effects.callbackwrapper
 * The callback for when effect presences get created.
 */
std.summoner.effects.callbackwrapper = function(effect, effects) {
	return function(pres) {
		// set up listeners to SummonerAskPlaying and SummonerAskOwner
		var self = effect;
		var selfPres = pres;
		self.id = selfPres.getPresenceID();
		self.pres = selfPres;
		selfPres.setScale(self.baseScale);
		
		function respPlaying (msg, sender) {
			var resp = {isPlayingSummoner:"true", id_no:selfPres.getPresenceID()};
			msg.makeReply(resp) >> [];
		}
		respPlaying << [{"action":"SummonerAskPlaying":},
						{"id_no":selfPres.getPresenceID():}];
						
		function respOwner (msg, sender) {
			var resp = {owner:"god", id_no:selfPres.getPresenceID(), traits: {}};
			msg.makeReply(resp) >> [];
		}
		respOwner << [{"action":"SummonerAskOwner":},
					  {"id_no":selfPres.getPresenceID():}];
		effects.num_ready++;
		if (effects.num_ready == effects.num_effects) 
			effects.is_ready = true;
	};
};


/* std.summoner.effects.createEffect
 * Generates a single effect given the parameters. 
 * parent is the monster presence associated with this effect
 * effects_array is the array of each effect object, and is a parameter of 'effects'.
 * banners are special effects and is set with the boolean is_banner
 * effect_id is the key for effects
 */
std.summoner.effects.createEffect = function(parent, effects_array, is_banner, effects, effect_id) {
	var effect = {};
	effect.parent = parent;
	effect.id_num = effect_id;
	effect.mesh = "";
	effect.baseScale = parent.getScale();
	effect.scale = effect.baseScale;
	effect.behavior = "";
	effect.behaviorRepeatingTimers = {};
	effect.behaviorStart = 0; // start time of effect
	effect.behaviorFinal = 0; // duration of effect
	effect.effect_name = "";
	effect.tempParam = {};
	effect.tempParam.ready = false;
	effect.is_banner = (typeof(is_banner) === "undefined") ? false : is_banner;
	effects_array.push(effect);
	system.createPresence("", std.summoner.effects.callbackwrapper(effect, effects));
};

/* std.summoner.effects.clearEffect
 * clears a single effect. A 'cleared' effect is a recycled effect and is ready to be used again. Its repeating timer is suspended.
 */
std.summoner.effects.clearEffect = function(effect) {
	effect.mesh = "";
	effect.scale = effect.baseScale;
	if (effect.pres) {
		effect.pres.setMesh("");
//		system.__debugPrint("\\n\\nBefore ClearEffect: " + effect.parent.getPosition().toString());
		effect.pres.setPosition(effect.parent.getPosition());
//		system.__debugPrint("\\n\\nAfter ClearEffect\\n");
		effect.pres.setVelocity(<0,0,0>);
	}
	effect.behavior = "";
	effect.behaviorStart = 0;
	effect.behaviorFinal = 0;
	effect.effect_name = "";
	effect.tempParam.ready = false;
	for (var i in effect.behaviorRepeatingTimers) {
		if (typeof(effect.behaviorRepeatingTimers[i]) !== "undefined")
			effect.behaviorRepeatingTimers[i].suspend();
	}
};

/* std.summoner.effects.clearAll
 * clears all effects. See above
 */
std.summoner.effects.clearAll = function(effects) {
	for (var i in effects.effects) {
		if (!effects.effects[i].is_banner)
			std.summoner.effects.clearEffect(effects.effects[i]);
	}
};

/* std.summoner.effects.updateVelocities
 * Updates the velocities of each effect. It integrates the newVelocity to the effect's own velocity.
 */
std.summoner.effects.updateVelocities = function(effects, newVelocity) {
	if (!effects.is_ready)
		return;
	for (var i in effects.effects) {
		std.summoner.effects.updateVelocity(effects.effects[i], newVelocity);
	}
}

/* std.summoner.effects.updateVelocity
 * helper to std.summoner.effects.updateVelocities. 
 */
std.summoner.effects.updateVelocity = function(effect, newVelocity) {
	if (effect.behavior == "still") {
		effect.pres.setVelocity(newVelocity.add(effect.tempParam.vel));
	}
}

/* std.summoner.effects.setBehavior
 * Gets a recycled effect and sets the effect to be one with said behaviorName with associated parameters.
 * behaviorParam is a different object depending on the behaviorName
 */
std.summoner.effects.setBehavior = function(behaviorName, behaviorParam, effects) {
	var effect = std.summoner.effects.getCleanEffect(effects, behaviorParam.banner);
	effect.behavior = behaviorName;
	switch(behaviorName) {
		case "rotate":
			std.summoner.effects.setBaseParams(effect, behaviorParam);
			std.summoner.effects.behavior.rotate(effect, behaviorParam);
			break;
		case "fire":
			std.summoner.effects.setBaseParams(effect, behaviorParam);
			std.summoner.effects.behavior.fire(effect, behaviorParam);
			break;
		case "still":
			std.summoner.effects.setBaseParams(effect, behaviorParam);
			std.summoner.effects.behavior.still(effect, behaviorParam);
			break;
		case "":
			break;
		default:
			;
	}
};

/* std.summoner.effects.getCleanEffect
 * Recycles the oldest effect if none are available. Then, returns a clean effect.
 */
std.summoner.effects.getCleanEffect = function(effects, is_banner) {
	var oldest = -1;
	var oldestEffect = null;
	is_banner = (typeof(is_banner) === "undefined") ? false : is_banner;
	for (var i in effects.effects) {
		if (is_banner && effects.effects[i].is_banner) {
			std.summoner.effects.clearEffect(effects.effects[i]);
			return effects.effects[i];
		}
		if (effects.effects[i].behaviorStart == 0 && !effects.effects[i].is_banner)
			return effects.effects[i];
		if ((oldest == -1 || oldest > effects.effects[i].behaviorStart) && !effects.effects[i].is_banner) {
			oldest = effects.effects[i].behaviorStart;
			oldestEffect = effects.effects[i]
		}
	}
	std.summoner.effects.clearEffect(oldestEffect);
	return oldestEffect;
};

/* std.summoner.effects.behavior.empty
 *  empty func. I don't know why this still exists.
 */
std.summoner.effects.behavior.empty = function(effect, param) {
	;
};

/* std.summoner.effects.frozen
 * The default function to call to replicate the 'frozen' effect. 
 * Parameters are:
 * effects object, duration number, scale number
 */
std.summoner.effects.frozen = function(effects, duration, scale) {
	if (!effects.is_ready)
		return false;
	std.summoner.effects.setBehavior("still", {
		mesh:"meerkat:///hoshoshoshosh/icecube/icecube.dae/original/0/icecube.dae",
		length: duration,
		scale: scale + 1,
		name: "frozen"
	}, effects);
	return true;
};


/* std.summoner.effects.banner
 * Initializes a banner effect. This should just be called once.
 */
std.summoner.effects.banner = function(effects, url/*, scale*/) {
	if (!effects.is_ready)
		return false;
	var bb = new std.graphics.Billboard(url);
	var banner_height = effects.parent.getScale() + 1;
	std.summoner.effects.setBehavior("still", {
		mesh: "",//bb.mesh(),
		length: -1,
		scale: 1,
		offset: <0, banner_height, 0>,
		banner: true,
		name: "banner"
	}, effects);
	return true;
};

/* std.summoner.effects.firebreathing
 * Starts a firebreathing effect
 */ 
std.summoner.effects.firebreathing = function(effects, scale, scale_modifier) {
	return std.summoner.effects.aoe(effects, scale, scale_modifier, "fire_breathing", "meerkat:///hoshoshoshosh/models/flame.dae/optimized/0/flame.dae", 2);
};

/* std.summoner.effects.charming
 * Starts a charming effect.
 */
std.summoner.effects.charming = function(effects, scale, scale_modifier) {
	return std.summoner.effects.aoe(effects, scale, scale_modifier, "charming", "meerkat:///hoshoshoshosh/music_note_test.dae/optimized/0/music_note_test.dae", 2, 10);
};

/* std.summoner.effects.aoe
 * Does an AoE effect. An AoE effect is one that shoots lots of presences circularly away from the monster at a random angle.
 */
std.summoner.effects.aoe = function(effects, scale, scale_modifier, behavior_name, mesh, num_effects, time_length) {
	if (!effects.is_ready)
		return false;
	var dist = scale * scale_modifier;
	var time = (typeof(time_length) !== "number") ? 5 : time_length;
	for (var i = 0; i < num_effects; i++) {
		std.summoner.effects.setBehavior("fire", {
			mesh: mesh, 
			length: time,
			v: scale * scale_modifier / time,
			name: behavior_name 
		}, effects);
	}
	return true;
};

/* std.summoner.effects.confused
 * Does a confused effect. Stars circle around the monster's head
 */
std.summoner.effects.confused = function(effects, scale, effect_length) {
	effect_length = (typeof(effect_length) === "number" && effect_length > 0) ? effect_length : 5;
	if (!effects.is_ready)
		return false;
	var scale_ratio = 1 / 7;
	std.summoner.effects.setBehavior("rotate", {
		mesh: "meerkat:///hoshoshoshosh/models/star.dae/optimized/0/star.dae",
		r: scale,
		y: scale,
		name: "confused",
		length: effect_length
	}, effects);
	return true;
};

/* std.summoner.effects.burning
 * Does a burning effect. The monster is covered in flames
 */
std.summoner.effects.burning = function(effects, scale) {
	if (!effects.is_ready)
		return false;
	std.summoner.effects.setBehavior("still", {
		mesh: "meerkat:///hoshoshoshosh/flame2.dae/original/0/flame2.dae",
		scale: 2,
		length: -1,
		name: "burning"
	}, effects);
	return true;
};

/* std.summoner.effects.clearEffectByName
 * Clears all effects with the name of effectName
 */
std.summoner.effects.clearEffectByName = function(effects, effectName) {
	for (var i in effects.effects)
		if (!effects.effects[i].is_banner && effects.effects[i].effect_name == effectName)
			std.summoner.effects.clearEffect(effects.effects[i]);
};

/* std.summoner.effects.hasEffectByName
 * returns a boolean for whether there exists an effect with name == effectName
 */
std.summoner.effects.hasEffectByName = function(effects, effectName) {
	system.__debugPrint("\\nIn hasEffectByName. effects.effects length: " + effects.effects.length.toString() + " and looking for: " + effectName);
	for (var i in effects.effects) {
		system.__debugPrint("\\n Effect(" + i.toString() + "): " + effects.effects[i].effect_name.toString());
		if (effects.effects[i].effect_name == effectName)
			return true;
	}
	return false;
};

/* std.summoner.effects.setBaseParams
 * This is called for every kind of effect. All effects use setBaseParams
 * param is the parameters object. The important properties of param are mesh, scale, length, and name
 * param.mesh is the meshURL to load
 * param.scale is the scale of the mesh.
 * param.length is how long the effect lasts.
 * param.name is an internally stored name of the effect.
 */
std.summoner.effects.setBaseParams = function(effect, param) {
	effect.mesh = (typeof(param.mesh) !== "string") ? effect.mesh : param.mesh;
	effect.scale = (typeof(param.scale) !== "number") ? effect.baseScale : effect.baseScale + param.scale;
	effect.behaviorFinal = (typeof(param.length) !== "number") ? 5000 : param.length * 1000;
	effect.behaviorStart = (new Date()).getTime();
	//effect.pres.setMesh(effect.mesh);
	effect.pres.setScale(effect.scale);
	effect.effect_name  = (typeof(param.name) !== "string") ? "" : param.name;
};

/* std.summoner.effects.repositionBanner
 * Used when the banner needs to be set to a new position (such as when a new monster is summoned in the same parent presence)
 */
std.summoner.effects.repositionBanner = function(effects) {
	var banner = effects.effects[0];
	banner.tempParam.offset = <0, banner.parent.getScale() + 1, 0>;
}

/*-------------- std.summoner.effects.behavior namespace here-----------------------*/
/* std.summoner.effects.behavior namespace are for the base effect behavior functions. They 
 * define the 'skeleton' of effect behaviors. The behaviors of effects range from:
 * rotate - the behavior for when the effect rotates around the monster
 * fire   - the behavior for when the effect fires an effect away from the monster
 * still  - the behavior for when the effect creates a mesh effect that is static on the monster
 */
/* std.summoner.effects.behavior.rotate
 * The skeleton for the rotation behavior.
 * Important parameters are:
 * r         - radius
 * y         - height
 * clockwise - boolean of the direction of rotation
 */
std.summoner.effects.behavior.rotate = function(effect, param) {
	effect.tempParam.r = (typeof(param.r) !== "number") ? 0 : param.r;
	effect.tempParam.y = (typeof(param.y) !== "number") ? 0 : param.y;
	effect.tempParam.clock = (typeof(param.clockwize) !== "boolean") ? true : param.clockwise;
	effect.tempParam.ready = false;
	effect.behaviorStart = (new Date()).getTime();
	effect.tempParam.curPos = 0;
	if (typeof(effect.behaviorRepeatingTimers.rotate) === "undefined") {
		effect.behaviorRepeatingTimers.rotate = new std.core.RepeatingTimer(1, function() {
			if (!effect.tempParam.ready)
				effect.pres.setMesh(effect.mesh);
			var parentPos = effect.parent.getPosition();
			parentPos.y = parentPos.y + effect.tempParam.y;
			var newVel = <0,0,0>;
			var timediff = (new Date()).getTime() - effect.behaviorStart;
			var timepos = effect.tempParam.curPos % 4;
			effect.tempParam.curPos++;
			timepos = (effect.tempParam.clock) ? timepos : 3 - timepos; // counterclockwise
			var defaultDist = effect.tempParam.r / Math.sqrt(2);
			var defaultVel = effect.tempParam.r * effect.tempParam.r * Math.sqrt(2);
			switch(timepos) {
				case 0:
					parentPos.x = parentPos.x + defaultDist;
					parentPos.z = parentPos.z + defaultDist;
					newVel.x = newVel.x - defaultVel;
					break;
				case 1:
					parentPos.x = parentPos.x - defaultDist;
					parentPos.z = parentPos.z + defaultDist;
					newVel.z = newVel.z - defaultVel;
					break;
				case 2:
					parentPos.x = parentPos.x - defaultDist;
					parentPos.z = parentPos.z - defaultDist;
					newVel.x = newVel.x + defaultVel;
					break;
				case 3:
					parentPos.x = parentPos.x + defaultDist;
					parentPos.z = parentPos.z - defaultDist;
					newVel.z = newVel.z + defaultVel;
					break;
			}
			effect.pres.setPosition(parentPos);
			newVel = newVel.div(4);
			effect.pres.setVelocity(newVel);
			if (timediff > effect.behaviorFinal && effect.behaviorFinal >= 0) {
				std.summoner.effects.clearEffect(effect);
			}
		});
	} else {
		effect.behaviorRepeatingTimers.rotate.reset();
	}
};

/* std.summoner.effects.behavior.fire
 * The skeleton for the fire behavior.
 * Important parameters are:
 * target  - visible / presence of the target to fire at. Default null, which means it fires an effect at a random direction
 * v       - velocity of missile
 * gravity - gravity value as a number. Automatically makes the fire path arched if gravity is non-0
 * homing  - if true, periodically re-aims missile to aim at target. Only meaningful if target is non-null
 */
std.summoner.effects.behavior.fire = function(effect, param) {
	effect.tempParam.target = (typeof(param.target) === "undefined") ? null : param.target;
	effect.tempParam.v = (typeof(param.v) !== "number") ? 5 : param.v;
	effect.tempParam.gravity = (typeof(param.gravity) !== "number") ? 0 : param.gravity;
	effect.tempParam.homing = (typeof(param.homing) !== "boolean") ? false : param.homing;
	effect.tempParam.ready = false;
	effect.behaviorStart = (new Date()).getTime();
	if (typeof(effect.behaviorRepeatingTimers.fire) === "undefined") {
		effect.behaviorRepeatingTimers.fire = new std.core.RepeatingTimer(1, function() {
			var timediff = (new Date()).getTime() - effect.behaviorStart;
			if (!effect.tempParam.ready) { // Init
				effect.pres.setPosition(effect.parent.getPosition());
				effect.pres.setMesh(effect.mesh);
				var velocity;
				if (!effect.tempParam.target) {
					velocity = <-0.5 + Math.random(), 0, -0.5 + Math.random()>;
					velocity = velocity.div(velocity.length());
					velocity = velocity.mul(effect.tempParam.v);
					velocity.y = velocity.y + (effect.behaviorFinal / 1000) * effect.tempParam.gravity;
					var pos = effect.pres.getPosition();
					effect.pres.setVelocity(velocity);
					var vel = effect.pres.getVelocity();
				} else {
					var dist = effect.tempParam.target.getPosition().sub(effect.parent.getPosition());
					velocity = dist.div(dist.length());
					velocity = velocity.mul(effect.tempParam.v);
					var time = dist.length() / velocity.length();
					time = time * 1000;
					effect.behaviorFinal = (time < effect.behaviorFinal) ? time : effect.behaviorFinal;
					velocity.y = velocity.y + (effect.behaviorFinal / 1000) * effect.tempParam.gravity;
					effect.pres.setVelocity(velocity);
				}
				effect.tempParam.ready = true;
			} else {
				var velocity = effect.pres.getVelocity();
				velocity.y = velocity.y - effect.tempParam.gravity;
				if (effect.tempParam.homing && effect.tempParam.target) {
					var dir = effect.tempParam.target.getPosition().sub(effect.pres.getPosition());
					dir = dir.div(dir.length());
					dir = dir.mul(effect.tempParam.v);
					velocity.x = dir.x;
					velocity.z = dir.z;
				}
				effect.pres.setVelocity(velocity);
			}
			if (timediff > effect.behaviorFinal)
				std.summoner.effects.clearEffect(effect);
		});
	} else {
		effect.behaviorRepeatingTimers.fire.reset();
	}
};

/* std.summoner.effects.behavior.still
 * The skeleton for the still behavior.
 * Important parameters are:
 * vel       - velocity vector, just in case the effect actually shouldn't be 'still'
 * offset    - offset vector to the parent.
 * scale_vel - set to a number if the scale should change over time
 */
std.summoner.effects.behavior.still = function(effect, param) {
	effect.tempParam.vel = (typeof(param.vel) !== "object") ? <0,0,0> : param.vel;
	effect.tempParam.offset = (typeof(param.offset) !== "object") ? <0,0,0> : param.offset;
	effect.tempParam.scale_vel = (typeof(param.scale_vel) !== "number") ? 0 : param.scale_vel;
	effect.tempParam.ready = false;
	effect.behaviorStart = (new Date()).getTime();
	if (typeof(effect.behaviorRepeatingTimers.still) === "undefined") {
		effect.behaviorRepeatingTimers.still = new std.core.RepeatingTimer(1, function() {
			var timediff = (new Date()).getTime() - effect.behaviorStart;
			var newpos = effect.parent.getPosition().add(effect.tempParam.offset);
//			system.__debugPrint("\\n\\nBefore being still: " + newpos.x.toString() + " " + newpos.y.toString() + " " + newpos.z.toString() + "\\n");
			effect.pres.setPosition(newpos);
			if (!effect.tempParam.ready) {
				effect.pres.setMesh(effect.mesh);
				effect.pres.setVelocity(effect.parent.getVelocity().add(effect.tempParam.vel));
				effect.tempParam.ready = true;
			}
			if (effect.tempParam.scale_vel != 0)
				effect.pres.setScale(effect.pres.getScale() + effect.tempParam.scale_vel);

			if (timediff > effect.behaviorFinal && effect.behaviorFinal >= 0)
				std.summoner.effects.clearEffect(effect);
		});
	} else {
		effect.behaviorRepeatingTimers.still.reset();
	}
};

@;
