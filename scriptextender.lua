--- BZCC ScriptExtender Stub
--
-- Stubs for ScriptExtender LDoc
--
-- This module is only active if the ScriptExtender is part of LuaMission
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
-- @tparam RadarType type Radar Type to disable
-- @usage RadarDisable(RadarType.RADARTYPE_MAP);
function RadarDisable(type) end


--- Enable radar type.
-- If no radar types are active or activation is forced this radar will activate as well as enable
-- @tparam RadarType type Radar Type to disable
-- @tparam[opt] bool activate Force activate this radar
-- @usage RadarEnable(RadarType.RADARTYPE_MAP);
-- @usage RadarEnable(RadarType.RADARTYPE_MAP, true);
function RadarEnable(type, activate) end

--- Is radar type enabled?
-- @tparam RadarType type Radar Type to check
-- @treturn bool if the radar type is enabled
-- @usage local enabled = RadarEnabled(RadarType.RADARTYPE_MAP);
function RadarEnabled(type) end

--- Is radar type active?
-- @tparam RadarType type Radar Type to check
-- @treturn bool if the radar type is active
-- @usage local active = RadarActive(RadarType.RADARTYPE_MAP);
function RadarActive(type) end

-------------------------------------------------------------------------------
-- GameObject
-------------------------------------------------------------------------------
-- @section

--- Change the status image of an object.
-- This image, conventionally called the "wireframe" in BZ2, is the image above the
-- weapon panel. This code exploits the logic used to change it for pilot pack weapons.
-- @tparam Handle handle GameObject handle
-- @tparam string texture Texture filename
-- @usage SetStatusImage(playerHandle, 'wire_iggren3.dds');
function SetStatusImage(handle, texture) end

--- Set the lockdown state on an object.
-- Apply the EMP Stream affect to an object.
-- @tparam Handle handle GameObject handle
-- @tparam number turns game turns to apply affect
-- @usage SetLockdown(objectHandle, GetTPS() * 10);
function SetLockdown(handle, turns) end

--- Get the lockdown state on an object.
-- Get the EMP Stream affect turns remaining.
-- @tparam Handle handle GameObject handle
-- @treturn int number turns game turns left of affect
-- @usage local turns = GetLockdown(objectHandle);
function GetLockdown(handle) end

--- Get the world position of the weapon's TLI.
-- @tparam Handle shooter shooter's GameObject handle
-- @tparam int index weapon index
-- @tparam Handle target target's GameObject handle
-- @treturn Vector world position of TLI
-- @usage local pos = GetWeaponLeadPosition(shooter, 0, target);
function GetWeaponLeadPosition(shooter, index, target) end

--- Get the world center of mass.
-- @tparam Handle handle GameObject handle
-- @treturn Vector world position of center of mass
-- @usage local pos = GetCenterOfMass(objectHandle);
function GetCenterOfMass(handle) end

--- Get percent charge of weapon.
-- This applies only to ChargeGun and MulitLauncher.
-- @tparam Handle handle GameObject handle
-- @tparam int slot Weapon slot
-- @treturn number charge %
-- @usage local charge = GetWeaponCharge(objectHandle, 0);
function GetWeaponCharge(handle, slot) end

--- Get if weapon is locked.
-- This applies only to Launcher.
-- @tparam Handle handle GameObject handle
-- @tparam int slot Weapon slot
-- @treturn bool is weapon locked
-- @usage local locked = IsWeaponLocked(objectHandle, 0);
function IsWeaponLocked(handle, slot) end

--- Set base radar color of object.
-- This sets the radar color on stock radars for an object and auto-generates the 2nd color.
-- The game will override this when a color change event occurs, such as hopping out.
-- @tparam Handle handle GameObject handle
-- @tparam ColorInt color Color value
-- @usage SetRadarColor(objectHandle, 0xff0000);
function SetRadarColor(handle, color) end

--- Get base radar color of object.
-- This gets the radar color on stock radars for an object.
-- @tparam Handle handle GameObject handle
-- @treturn ColorInt Color value
-- @usage local color = GetRadarColor(objectHandle);
function GetRadarColor(handle) end

--- Reset radar color of object.
-- This restores the game default radar color to an object.
-- @tparam Handle handle GameObject handle
-- @treturn ColorInt Color value
-- @usage local color = GetRadarColor(objectHandle);
function ResetRadarColor(handle) end

--- Get radar color of object considers its alive state.
-- Objects that are dead have a darker color, though this appears broken
-- in BZCC it is still in the code and may be used in other cases.
-- @tparam Handle handle GameObject handle
-- @treturn ColorInt Color value
-- @usage local color = GetRadarColorWithState(objectHandle);
function GetRadarColorWithState(handle) end


