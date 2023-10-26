--- BZCC ScriptExtender Stub
--
-- Stubs for ScriptExtender LDoc
--
-- This module is only active if the ScriptExtender is part of LuaMission
--
-- **There is currently no released version of the ScriptExtender!**
--
-- @module ScriptExtender
-- @author John "Nielk1" Klein


-------------------------------------------------------------------------------
-- Radar
-------------------------------------------------------------------------------
-- @section

--- RadarType
-- @table RadarType
RadarType = {
   [0] = "RADARTYPE_COCKPIT"; -- RADARTYPE_COCKPIT
   [1] = "RADARTYPE_MAP"; -- RADARTYPE_MAP
   [2] = "RADARTYPE_COCKPIT_CUSTOM_1"; -- RADARTYPE_COCKPIT_CUSTOM_1
   ["RADARTYPE_COCKPIT"] = 0; -- 0
   ["RADARTYPE_MAP"] = 1; -- 1
   ["RADARTYPE_COCKPIT_CUSTOM_1"] = 2; -- 2
};


--- Disable radar type.
-- If this radar type is active, it will automatically switch to the next active type or none
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function RadarDisable
-- @tparam RadarType type Radar Type to disable
-- @usage RadarDisable(RadarType.RADARTYPE_MAP);


--- Enable radar type.
-- If no radar types are active or activation is forced this radar will activate as well as enable
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function RadarEnable
-- @tparam RadarType type Radar Type to disable
-- @tparam[opt] bool activate Force activate this radar
-- @usage RadarEnable(RadarType.RADARTYPE_MAP);
-- @usage RadarEnable(RadarType.RADARTYPE_MAP, true);

--- Is radar type enabled?
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function RadarEnabled
-- @tparam RadarType type Radar Type to check
-- @treturn bool if the radar type is enabled
-- @usage local enabled = RadarEnabled(RadarType.RADARTYPE_MAP);

--- Is radar type active?
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function RadarActive
-- @tparam RadarType type Radar Type to check
-- @treturn bool if the radar type is active
-- @usage local active = RadarActive(RadarType.RADARTYPE_MAP);

-------------------------------------------------------------------------------
-- GameObject
-------------------------------------------------------------------------------
-- @section

--- Change the status image of an object.
-- This image, conventionally called the "wireframe" in BZ2, is the image above the
-- weapon panel. This code exploits the logic used to change it for pilot pack weapons.
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function SetStatusImage
-- @tparam Handle handle GameObject handle
-- @tparam string texture Texture filename
-- @usage SetStatusImage(playerHandle, 'wire_iggren3.dds');

--- Set the lockdown state on an object.
-- Apply the EMP Stream affect to an object.
--
-- [Untested, Test MP Sync]
-- @function SetLockdown
-- @tparam Handle handle GameObject handle
-- @tparam number turns game turns to apply affect
-- @usage SetLockdown(objectHandle, GetTPS() * 10);

--- Get the lockdown state on an object.
-- Get the EMP Stream affect turns remaining.
--
-- [Untested, Test MP Sync]
-- @function GetLockdown
-- @tparam Handle handle GameObject handle
-- @treturn int number turns game turns left of affect
-- @usage local turns = GetLockdown(objectHandle);

--- Get the world position of the weapon's TLI.
--
-- [Untested, Test MP Sync]
-- @function GetWeaponLeadPosition
-- @tparam Handle shooter shooter's GameObject handle
-- @tparam int index weapon index
-- @tparam Handle target target's GameObject handle
-- @treturn Vector world position of TLI
-- @usage local pos = GetWeaponLeadPosition(shooter, 0, target);

--- Get the world center of mass.
--
-- [Untested, Test MP Sync]
-- @function GetCenterOfMass
-- @tparam Handle handle GameObject handle
-- @treturn Vector world position of center of mass
-- @usage local pos = GetCenterOfMass(objectHandle);

--- Get percent charge of weapon.
-- This applies only to ChargeGun and MulitLauncher.
--
-- [Untested, Test MP Sync]
-- @function GetWeaponCharge
-- @tparam Handle handle GameObject handle
-- @tparam int slot Weapon slot
-- @treturn number charge %
-- @usage local charge = GetWeaponCharge(objectHandle, 0);

--- Get if weapon is locked.
-- This applies only to Launcher.
--
-- [Untested, Test MP Sync]
-- @function IsWeaponLocked
-- @tparam Handle handle GameObject handle
-- @tparam int slot Weapon slot
-- @treturn bool is weapon locked
-- @usage local locked = IsWeaponLocked(objectHandle, 0);

--- Set base radar color of object.
-- This sets the radar color on stock radars for an object and auto-generates the 2nd color.
-- The game will override this when a color change event occurs, such as hopping out.
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function SetRadarColor
-- @tparam Handle handle GameObject handle
-- @tparam ColorInt color Color value
-- @usage SetRadarColor(objectHandle, 0xff0000);

--- Get base radar color of object.
-- This gets the radar color on stock radars for an object.
--
-- [Local Only, Untested, Assumed MP Safe, Beware of Sync]
-- @function GetRadarColor
-- @tparam Handle handle GameObject handle
-- @treturn ColorInt Color value
-- @usage local color = GetRadarColor(objectHandle);

--- Reset radar color of object.
-- This restores the game default radar color to an object.
--
-- [Local Only, Untested, Assumed MP Safe]
-- @function ResetRadarColor
-- @tparam Handle handle GameObject handle
-- @treturn ColorInt Color value
-- @usage local color = GetRadarColor(objectHandle);

--- Get radar color of object considers its alive state.
-- Objects that are dead have a darker color, though this appears broken
-- in BZCC it is still in the code and may be used in other cases.
--
-- [Local Only, Untested, Assumed MP Safe, Beware of Sync]
-- @function GetRadarColorWithState
-- @tparam Handle handle GameObject handle
-- @treturn ColorInt Color value
-- @usage local color = GetRadarColorWithState(objectHandle);

-------------------------------------------------------------------------------
-- Team/Player
-------------------------------------------------------------------------------
-- @section

--- Get DPID of player on team.
-- This gets the DPID number of a player on a given team.
--
-- [Untested, Test MP Sync, edge case testing needed]
-- @function GetDPIDOfTeam
-- @tparam int team Player team number
-- @treturn int DPID
-- @usage local DPID = GetDPIDOfTeam(1);

--- Get DPID of player on team.
-- This gets the DPID number of a player on a given team.
--
-- [Untested, Test MP Sync, edge case testing needed]
-- @function GetTeamForDPID
-- @tparam int DPID of player
-- @treturn int team
-- @usage local team = GetTeamForDPID(DPID);

--- Get player's platform ID from DPID.
-- This gets the platform ID of the player, such as their SteamID, GOG ID, or I0.
-- Note that GOG returns I0 when galaxy is offline and the return value may be nil if not ready.
--
-- [RESTRICTED, Untested, Test MP Sync, edge case testing needed]
-- @function GetPlayerPlatformID
-- @tparam int DPID of player
-- @treturn string platform ID
-- @usage local platformid = GetPlayerPlatformID(GetDPIDOfTeam(1));

--- Get player's session unique ID.
-- This gets a unique ID for the player on a team.
-- For non-network games this is based on team number.
-- For network games this is a randomly salted hash of the player's platform ID.
-- Note the return value may be nil if not ready.
--
-- [Untested, Test MP Sync, edge case testing needed]
-- @function GetSessionUniquePlayerID
-- @tparam int team Player team number
-- @treturn string unique id for player in session
-- @usage local playerid = GetSessionUniquePlayerID(1);






-- Additional Ideas:
-- Get who is locked on to me, instead of if you are locked on, and get who the lock on target is too