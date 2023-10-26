--- BZCC LUA Extended API FuncArrayIter.
-- 
-- Function Array and Function Array Iterator for serial event sequences across game turns.
-- 
-- Dependencies: @{_api}, @{_hook}
-- @module _funcarray
-- @author John "Nielk1" Klein
-- @usage local funcarray = require("_funcarray");
-- 
-- funcarray.Create("TestMachine",
--     function(state)
--         print("test " .. state.test1);
--         state:next();
--     end,
--     funcarray.SleepSeconds(10),
--     function(state)
--         print("test " .. state.test2);
--         state:next();
--     end,
--     funcarray.SleepSeconds(15),
--     function(state)
--         print("test " .. state.test3);
--         state:next();
--     end);
-- 
-- hook.Add("InitialSetup", "Custom_InitialSetup", function(turn)
--     MissionData.TestFAI = funcarray.Start("TestMachine",{test1='a',test2="b",test3="c"});
-- end);
-- 
-- hook.Add("Update", "Custom_Update", function(turn)
--     MissionData.TestFAI:run();
-- end);

local debugprint = debugprint or function() end;

debugprint("_funcarray Loading");

local _api = require("_api");
local hook = require("_hook");

local _funcarray = {};
_funcarray.game_turn = 0;

_funcarray.Machines = {};

--- Is this object an instance of FuncArrayIter?
-- @param object Object in question
-- @treturn bool
function isfuncarrayiter(object)
  return (type(object) == "table" and object.__type == "FuncArrayIter");
end

--- FuncArrayIter.
-- An object containing all functions and data related to an FuncArrayIter.
local FuncArrayIter = {}; -- the table representing the class, which will double as the metatable for the instances
--GameObject.__index = GameObject; -- failed table lookups on the instances should fallback to the class table, to get methods
FuncArrayIter.__index = function(table, key)
  local retVal = rawget(table, key);
  if retVal ~= nil then return retVal; end
  if rawget(table, "addonData") ~= nil and rawget(rawget(table, "addonData"), key) ~= nil then return rawget(rawget(table, "addonData"), key); end
  return rawget(FuncArrayIter, key); -- if you fail to get it from the subdata, move on to base (looking for functions)
end
FuncArrayIter.__newindex = function(table, key, value)
  if key ~= "template" and key ~= "state_index" and key ~= "timer" and key ~= "target_turn" and key ~= "addonData" then
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
FuncArrayIter.__type = "FuncArrayIter";

--- Create FuncArrayIter
-- @tparam string name FuncArrayIter template
-- @tparam int timer Timer's value, -1 for not set
-- @tparam int target_turn TargetTurn's value, -1 for not set
-- @tparam int state_index Current state
-- @tparam table values Table of values embeded in the FuncArrayIter
local CreateFuncArrayIter = function(name, timer, target_turn, state_index, values)
  local self = setmetatable({}, FuncArrayIter);
  self.template = name;
  self.timer = timer;
  self.target_turn = target_turn;
  self.state_index = state_index;
  
  if istable(values) then
    for k, v in pairs( values ) do 
      self[k] = v;
    end
  end
  
  return self;
end

--- Run FuncArrayIter.
-- @tparam FuncArrayIter self FuncArrayIter instance
function FuncArrayIter.run(self)
    if not isfuncarrayiter(self) then error("Paramater self must be FuncArrayIter instance."); end
    
    local machine = _funcarray.Machines[self.template];
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

--- Next FuncArrayIter State.
-- @tparam FuncArrayIter self FuncArrayIter instance
function FuncArrayIter.next(self)
    self.state_index = self.state_index + 1;
end

-- Creates an FuncArrayIter Template with the given indentifier.
-- @tparam string name Name of the FuncArrayIter Template
-- @tparam function ... State functions
function _funcarray.Create( name, ... )
    if not isstring(name) then error("Paramater name must be a string."); end
    
    if (_funcarray.Machines[ name ] == nil) then
        _funcarray.Machines[ name ] = {};
    end
    
    _funcarray.Machines[ name ] = { ... };
end

-- Starts an FuncArrayIter based on the FuncArrayIter Template with the given indentifier.
-- @tparam string event Name of the FuncArrayIter Template
-- @tparam table init Initial data
function _funcarray.Start( name, init )
    if not isstring(name) then error("Paramater name must be a string."); end
    if init ~= nil and not istable(init) then error("Paramater init must be table or nil."); end
    if (_funcarray.Machines[ name ] == nil) then error('FuncArrayIter Template "' .. name .. '" not found.'); end

    return CreateFuncArrayIter(name, -1, -1, 1, init);
end

-- Wait a set period of time on this state.
-- @tparam FuncArrayIter state FuncArrayIter data
-- @tparam int calls How many calls to wait
function _funcarray.SleepCalls( calls )
    if not isinteger(seconds) then error("Paramater seconds must be an integer."); end

    return {(function(state, ...)
        local seconds = ...;
        if state.timer == -1 then
            state.timer = calls;
        elseif state.timer == 0 then
            state:next();
            state.timer = -1;
        else
            state.timer = state.timer - 1;
        end
    end), {seconds}};
end

-- Wait a set period of time on this state.
-- @tparam FuncArrayIter state FuncArrayIter data
-- @tparam number seconds How many seconds to wait
function _funcarray.SleepSeconds( seconds )
    if not isnumber(seconds) then error("Paramater seconds must be a number."); end

    return {(function(state, ...)
        local seconds = ...;
        if state.target_turn == -1 then
            state.target_turn = _funcarray.game_turn + math.ceil(seconds * GetTPS());
        elseif state.target_turn <= _funcarray.game_turn  then
            state:next();
            state.target_turn = -1;
        end
    end), {seconds}};
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FuncArrayIter - Core
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Save event function.
--
-- INTERNAL USE.
-- @param self FuncArrayIter instance
-- @return ...
function FuncArrayIter.Save(self)
    return self;
end

--- Load event function.
--
-- INTERNAL USE.
-- @param data
function FuncArrayIter.Load(data)
    return CreateFuncArrayIter(data.template, data.timer, data.target_turn, data.state_index, data.addonData);
end

--- BulkSave event function.
--
-- INTERNAL USE.
-- @return data to save in bulk
function FuncArrayIter.BulkSave()
    return _funcarray.game_turn;
end

--- BulkLoad event function.
--
-- INTERNAL USE.
-- @param data
function FuncArrayIter.BulkLoad(data)
    _funcarray.game_turn = data;
end

--- BulkPostLoad event function.
--
-- INTERNAL USE.
function FuncArrayIter.BulkPostLoad()

end

hook.Add("Update", "_funcarray_Update", function(turn)
    _funcarray.game_turn = turn;
end, 9999);

_api.RegisterCustomSavableType(FuncArrayIter);

debugprint("_funcarray Loaded");

return _funcarray;