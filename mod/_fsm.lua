--- BZCC LUA Extended API FSM.
-- 
-- Finite-state machine tuned for BZCC's serialization.
-- 
-- @module _fsm
-- @author John "Nielk1" Klein

local debugprint = debugprint or function() end;

debugprint("_fsm Loading");

local _api = require("_api");

local _fsm = {};

_fsm.Machines = {};

--- Is this object an instance of FSM?
-- @param object Object in question
-- @return bool
function isfsm(object)
  return (type(object) == "table" and object.__type == "FSM");
end

--- FSM.
-- An object containing all functions and data related to an FSM.
local FSM = {}; -- the table representing the class, which will double as the metatable for the instances
--GameObject.__index = GameObject; -- failed table lookups on the instances should fallback to the class table, to get methods
FSM.__index = function(table, key)
  local retVal = rawget(table, key);
  if retVal ~= nil then return retVal; end
  if rawget(table, "addonData") ~= nil and rawget(rawget(table, "addonData"), key) ~= nil then return rawget(rawget(table, "addonData"), key); end
  return rawget(FSM, key); -- if you fail to get it from the subdata, move on to base (looking for functions)
end
FSM.__newindex = function(table, key, value)
  if key ~= "template" and key ~= "state_index" and key ~= "timer" and key ~= "addonData" then
    local addonData = rawget(table, "addonData");
    if addonData == nil then
      rawset(table, "addonData", {});
      addonData = rawget(table, "addonData");
    end
    rawset(addonData, key, value);
  else
    rawset(table, key, value);
  end
end
FSM.__type = "FSM";

--- Run FSM.
-- @param self GameObject instance
function FSM.run(self)
    if not isfsm(self) then error("Paramater self must be FSM instance."); end
    
    local machine = _fsm.Machines[self.template];
    if machine == nil then return false; end
    if #machine < self.state_index then return false; end
    
    if isfunction(machine[self.state_index]) then
        return true, machine[self.state_index](self);
    end
    if istable(machine[self.state_index]) then
        if isfunction(machine[self.state_index][1]) then
            return true, machine[self.state_index][1](self, table.unpack(machine[self.state_index][2]));
        end
    end
    return false;
end

--- Next FSM State.
-- @param self GameObject instance
function FSM.next(self)
    self.state_index = self.state_index + 1;
end

-- Creates an FSM Template with the given indentifier.
-- @param name Name of the FSM Template (string)
-- @param ... State functions
function _fsm.Create( name, ... )
    if not isstring(name) then error("Paramater name must be a string."); end
    
    if (_fsm.Machines[ name ] == nil) then
        _fsm.Machines[ name ] = {};
    end
    
    _fsm.Machines[ name ] = { ... };
end

-- Starts an FSM based on the FSM Template with the given indentifier.
-- @param event Name of the FSM Template (string)
-- @param init Initial data (table)
function _fsm.Start( name, init )
    if not isstring(name) then error("Paramater name must be a string."); end
    if init ~= nil and not istable(init) then error("Paramater init must be table or nil."); end
    if (_fsm.Machines[ name ] == nil) then error('FSM Template "' .. name .. '" not found.'); end

    local self = setmetatable({}, FSM);
    self.template = name;
    self.timer = -1;
    self.state_index = 1;
    return self;
    
    -- TODO: Copy init values into self
end

-- Wait a set period of time on this state.
-- @param state FSM data (FSM)
-- @param seconds How many seconds to wait (int)
function _fsm.SleepSeconds( seconds )
    if not isinteger(seconds) then error("Paramater seconds must be an integer."); end

    return {(function(state, ...)
        local seconds = ...;
        if state.timer == -1 then
            state.timer = seconds * GetTPS();
        elseif state.timer == 0 then
            state:next();
            state.timer = -1;
        else
            state.timer = state.timer - 1;
        end
    end), {seconds}};
end

--[[
function _fsm.SleepSeconds( seconds )
    if not isinteger(name) then error("Paramater name must be an integer."); end

    return (function(state)
        if state.timer == -1 then
            state.timer = seconds * GetTPS();
        elseif state.timer == 0 then
            state:next();
            state.timer = -1;
        else
            state.timer = state.timer - 1;
        end
    end);
end
--]]

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FSM - Core
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Save event function.
-- INTERNAL USE.
-- @param self FSM instance
-- @return ...
function FSM.Save(self)
    return self;
end

--- Load event function.
-- INTERNAL USE.
-- @param id Handle
function FSM.Load(data)
    local self = setmetatable({}, FSM);
    self.template = data.template;
    self.timer =  data.timer;
    self.state_index =  data.state_index;
    return self;
    
    -- TODO: Copy other values into self
end

--- BulkSave event function.
-- INTERNAL USE.
-- @return ...
function FSM.BulkSave()
    return;
end

--- BulkLoad event function.
-- INTERNAL USE.
-- @params data
function FSM.BulkLoad(data)

end

--- BulkPostLoad event function.
-- INTERNAL USE.
function FSM.BulkPostLoad()

end

_api.RegisterCustomSavableType(FSM);

debugprint("_fsm Loaded");

return _fsm;