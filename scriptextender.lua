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
   ["RADARTYPE_COCKPIT"] = 0; -- 0
   ["RADARTYPE_MAP"] = 1; -- 1
};


--- Disable radar type.
-- If this radar type is active, it will automatically switch to the next active type or none
-- @tparam RadarType type Radar Type to disable
function RadarDisable(type) 
end


--- Enable radar type.
-- If no radar types are active or activation is forced this radar will activate as well as enable
-- @tparam RadarType type Radar Type to disable
-- @tparam[opt] bool activate Force activate this radar
function RadarEnable(type, activate) end

--- Is radar type enabled?
-- @tparam RadarType type Radar Type to check
-- @treturn bool if the radar type is enabled
function RadarEnabled(type) end

--- Is radar type active?
-- @tparam RadarType type Radar Type to check
-- @treturn bool if the radar type is active
function RadarActive(type) end