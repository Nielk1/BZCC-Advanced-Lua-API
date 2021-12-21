--- BZCC LUA Extended API.
--
-- This API creates a full OOP wrapper and replacement the mission
-- functions with an event based system for easier expansion.
--
-- Dependencies: `_hook`
-- @module _api
-- @author John "Nielk1" Klein

local debugprint = debugprint or function() end;
local traceprint = traceprint or function() end;

debugprint("_api Loading");

local hook = require("_hook");

-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------
-- @section

--- Is this object a function?
-- @param object Object in question
-- @treturn bool
function isfunction(object)
  return (type(object) == "function");
end

--- Is this object a table?
-- @param object Object in question
-- @treturn bool
function istable(object)
  return (type(object) == 'table');
end

--- Is this object a string?
-- @param object Object in question
-- @treturn bool
function isstring(object)
  return (type(object) == "string");
end

--- Is this object a boolean?
-- @param object Object in question
-- @treturn bool
function isboolean(object)
  return (type(object) == "boolean");
end

--- Is this object a number?
-- @param object Object in question
-- @treturn bool
function isnumber(object)
  return (type(object) == "number");
end

--- Is this object an integer?
-- @param object Object in question
-- @treturn bool
function isinteger(object)
  if not isnumber(object) then return false end;
  return object == math.floor(object);
end

-------------------------------------------------------------------------------
-- Enums
-------------------------------------------------------------------------------
-- @section

-- Set of return codes from the PlayerEjected/PlayerKilled call to DLL
EjectKillRetCodes = {}
--- Do 'standard' eject
EjectKillRetCodes.DoEjectPilot = 0;
--- Respawn a 'PLAYER' at safest spawnpoint
EjectKillRetCodes.DoRespawnSafest = 1;
--- DLL handled actions. Do nothing ingame
EjectKillRetCodes.DLLHandled = 2;
--- Game over, man.
EjectKillRetCodes.DoGameOver = 3;

--- Return codes from the PreSnipe DLL callback
PreSnipeReturnCodes = {}
--- Kill the pilot (1.0-1.3.6.4 default). Does still pass this to bullet hit code, where damage might also be applied
PreSnipeReturnCodes.PRESNIPE_KILLPILOT = 0;
--- Do not kill the pilot. Does still pass this to bullet hit code, where damage might also be applied
PreSnipeReturnCodes.PRESNIPE_ONLYBULLETHIT = 1;

--- Return codes from the PreGetIn DLL callback
PreGetInReturnCodes = {}
--- Deny the pilot entry to the craft
PreGetInReturnCodes.PREGETIN_DENY = 0;
--- Allow the pilot entry
PreGetInReturnCodes.PREGETIN_ALLOW = 1;

--- Return codes from the PrePickupPowerup DLL callback
PrePickupPowerupReturnCodes = {}
--- Deny the powerup from being picked up
PrePickupPowerupReturnCodes.PREPICKUPPOWERUP_DENY = 0;
--- Allow the powerup to be picked up
PrePickupPowerupReturnCodes.PREPICKUPPOWERUP_ALLOW = 1;

-------------------------------------------------------------------------------
-- Custom Types
-------------------------------------------------------------------------------
-- @section

local CustomSavableTypes = {};
local CustomTypeMap = nil; -- maps name to ID number
local gameTurn = 0;

local _api = {};

function _api.RegisterCustomSavableType(obj)
    if obj == nil or obj.__type == nil then error("Custom type malformed, no __type"); end
    local typeT = {};
    if obj.Save ~= nil then
        typeT.Save = obj.Save;
    else
        typeT.Save = function() end
    end
    if obj.Load ~= nil then
        typeT.Load = obj.Load;
    else
        typeT.Load = function() end
    end
    if obj.PostLoad ~= nil then
        typeT.PostLoad = obj.PostLoad;
    else
        typeT.PostLoad = function() end
    end
    if obj.BulkSave ~= nil then
        typeT.BulkSave = obj.BulkSave;
    else
        typeT.BulkSave = function() end
    end
    if obj.BulkLoad ~= nil then
        typeT.BulkLoad = obj.BulkLoad;
    else
        typeT.BulkLoad = function() end
    end
    if obj.BulkPostLoad ~= nil then
        typeT.BulkPostLoad = obj.BulkPostLoad;
    else
        typeT.BulkPostLoad = function() end
    end
    typeT.TypeName = obj.__type;
    CustomSavableTypes[obj.__type] = typeT;
end

function SimplifyForSave(...)
    local output = {}; -- output array
    local count = select ("#", ...); -- get count of params
    for k = 1,count,1 do  -- loop params via count
        local v = select(k,...); -- get Kth paramater, store in v
        if istable(v) then -- it's a table, start special logic
            if CustomSavableTypes[v.__type] ~= nul then
                local specialTypeTable = {};
                local typeIndex = CustomTypeMap[v.__type];
                debugprint("Type index for " .. v.__type .. " is " .. tostring(typeIndex));
                specialTypeTable["*custom_type"] = typeIndex;
                specialTypeTable["*data"] = {CustomSavableTypes[v.__type].Save(v)};
                table.insert(output, specialTypeTable);
            else
                local newTable = {};
                for k2, v2 in pairs( v ) do 
                    newTable[k2] = SimplifyForSave(v2);
                end
                table.insert(output, newTable);
            end
        else -- it's not a table, really simple
            table.insert(output, v);
        end
    end
    return table.unpack(output);
end

function DeSimplifyForLoad(...)
    local output = {}; -- output array
    local count = select ("#", ...); -- get count of params
    for k = 1,count,1 do  -- loop params via count
        local v = select(k,...); -- get Kth paramater, store in v
        if istable(v) then -- it's a table, start special logic
            if v["*custom_type"] ~= nil then
                local typeName = CustomTypeMap[v["*custom_type"]];
                local typeObj = CustomSavableTypes[typeName];
                table.insert(output, typeObj.Load(table.unpack(v["*data"])));
            else
                local newTable = {};
                for k2, v2 in pairs( v ) do 
                    newTable[k2] = DeSimplifyForLoad(v2);
                end
                table.insert(output, newTable);
            end
        else -- it's not a table, really simple
            table.insert(output, v);
        end
    end
    return table.unpack(output);
end

-------------------------------------------------------------------------------
-- Hooks
-------------------------------------------------------------------------------
-- @section

--- Save is called when you save a game, or when a Resync is requested.
function Save()
    debugprint("_api::Save()");
    CustomTypeMap = {};

    debugprint("Beginning save code");

    local saveData = {};
    debugprint("Save Data Container ready");

    saveData.gameTurn = gameTurn;

    debugprint("Saving custom types map");
    local CustomSavableTypesCounter = 1;
    local CustomSavableTypeTmpTable = {};
    for k,v in pairs(CustomSavableTypes) do
        CustomSavableTypeTmpTable[CustomSavableTypesCounter] = k;
        CustomTypeMap[k] = CustomSavableTypesCounter;
        debugprint("[" .. CustomSavableTypesCounter .. "] = " .. k);
        CustomSavableTypesCounter = CustomSavableTypesCounter + 1;
    end
    saveData.CustomSavableTypes = CustomSavableTypeTmpTable; -- Write TmpID -> Name map
    debugprint("Saved custom types map");
    
    debugprint("Saving custom types");
    local CustomSavableTypeDataTmpTable = {};
    for idNum,name in ipairs(CustomSavableTypeTmpTable) do
        local entry = CustomSavableTypes[name];
        if entry.BulkSave ~= nil and isfunction(entry.BulkSave) then
            debugprint("Saved " .. entry.TypeName);
            CustomSavableTypeDataTmpTable[idNum] = {SimplifyForSave(entry.BulkSave())};
        else
            debugprint("Saved " .. entry.TypeName .. " (nothing to save)");
            CustomSavableTypeDataTmpTable[idNum] = {};
        end
    end
    saveData.CustomSavableTypeData = CustomSavableTypeDataTmpTable; -- Write TmpID -> Data map
    CustomSavableTypeDataTmpTable = nil;
    CustomSavableTypeTmpTable = nil;
    debugprint("Saved custom types");
    
    debugprint("Calling all hooked save functions");
    table.insert(saveData,saveData.Hooks)
    local hookResults = hook.CallSave();
    if hookResults ~= nil then
      saveData.HooksData = {SimplifyForSave(hookResults)};
    else
      saveData.HooksData = {};
    end
    
    debugprint(table.show(saveData));
    
    debugprint("_api::/Save");
    return saveData;
end

--- Load is called when you load a game, or when a Resync is loaded.
function Load(...)
    debugprint("_api::Load()");
    local args = ...;

--    str = table.show(args);
--    for s in str:gmatch("[^\r\n]+") do
--        debugprint(s);
--    end
    debugprint(table.show(args));

--    debugprint("Beginning load code");
    
    gameTurn = args.gameTurn;

    traceprint("Loading custom types map");
    CustomTypeMap = args.CustomSavableTypes
    traceprint("Loaded custom types map");
    
    traceprint("Loading custom types data");
    for idNum,data in ipairs(args.CustomSavableTypeData) do
        local entry = CustomSavableTypes[CustomTypeMap[idNum]];
        if entry.BulkLoad ~= nil and isfunction(entry.BulkLoad) then
            traceprint("Loaded " .. entry.TypeName);
            entry.BulkLoad(DeSimplifyForLoad(table.unpack(data)));
        end
    end
    traceprint("Loaded custom types data");

    traceprint("Calling all hooked load functions");
    hook.CallLoad(DeSimplifyForLoad(table.unpack(args.HooksData)));
    debugprint("_api::/Load");
    
    PostLoad(); -- not implemented by LuaMission, if we need to add it do a version check here so we don't run it twice
end

--- You probably don't need to implement this
function PostLoad()
    debugprint("_api::PostLoad()");
    traceprint("PostLoading custom types");
    for name,entry in pairs(CustomSavableTypes) do
        if entry.BulkPostLoad ~= nil and isfunction(entry.BulkPostLoad) then
            traceprint("PostLoaded " .. entry.TypeName);
            SimplifyForSave(entry.BulkPostLoad());
        else
            traceprint("PostLoaded " .. entry.TypeName .. " (nothing to PostLoad)");
        end
    end
    traceprint("PostLoaded custom types");
    
    hook.CallPostLoad();
    debugprint("_api::/PostLoad");
end

--- Called before the mission starts up. 
-- Preloading assets should be done here.
function InitialSetup()
    debugprint("_api::InitialSetup()");
    hook.CallAllNoReturn( "InitialSetup" );
    debugprint("_api::/InitialSetup");
end

--- Called when the mission starts for the first time.
-- Use this function to perform any one-time script initialization.
function Start()
    debugprint("_api::Start()");
    hook.CallAllNoReturn( "Start" );
    debugprint("_api::/Start");
end

--- Called after any game object is created.
-- Handle is the game object that was created.
-- This function will get a lot of traffic so it should not do too much work.
-- Note that many game object functions may not work properly here.
function AddObject(h)
    traceprint("_api::AddObject(" .. tostring(h) .. ")");
    hook.CallAllNoReturn( "AddObject", GameObject.FromHandle(h) );
    traceprint("_api::/AddObject");
end

--- Called before a game object is deleted.
-- Handle is the game object to be deleted.
-- This function will get a lot of traffic so it should not do too much work.
-- Note: This is called after the object is largely removed from the game, so most Get functions won't return a valid value.
function DeleteObject(h)
    traceprint("_api::DeleteObject(" .. tostring(h) .. ")");
    local object = GameObject.FromHandle(h);
    hook.CallAllNoReturn( "DeleteObject", object );
    traceprint("_api::/DeleteObject");
end

--- Called once per tick after updating the network system and before simulating game objects.
-- This function performs most of the mission script's game logic.
function Update()
    traceprint("_api::Update()");
    hook.CallAllNoReturn( "Update", gameTurn );
    gameTurn = gameTurn + 1;
    traceprint("_api::/Update");
end

--- Called when a player joins the game world.
-- @tparam int id DPID number for this player
-- @tparam int team Team number for this player
-- @tparam bool isNewPlayer Is new player?
function AddPlayer(id, team, isNewPlayer)
    debugprint("_api::AddPlayer(" .. tostring(id) .. ", " .. tostring(team) .. ", " .. tostring(isNewPlayer) .. ")");
    local retVal, stoppedEarly = hook.CallAllPassReturn("AddPlayer", id, team, isNewPlayer);
    if not isboolean(retVal) then retVal = true; end
    debugprint("_api::/AddPlayer");
    return retVal;
end

--- Called when a player leaves the game world.
-- @tparam int id DPID number for this player
function DeletePlayer(id)
    debugprint("_api::DeletePlayer(" .. tostring(id) .. ")");
    hook.CallAllNoReturn( "DeletePlayer", id );
    debugprint("_api::/DeletePlayer");
end

--- Called when the player Ejects.
-- @tparam handle deadObjectHandle Handle for the now Dead ship that was ejected out of
function PlayerEjected(deadObjectHandle)
    traceprint("_api::PlayerEjected(" .. tostring(deadObjectHandle) .. ")");
    local object = GameObject.FromHandle(deadObjectHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PlayerEjected", object);
    if retVal == nil then retVal = EjectKillRetCodes.DoEjectPilot; end
    traceprint("_api::/PlayerEjected");
    return retVal;
end

--- Called when an object is killed.
-- @tparam handle deadObjectHandle Handle for the now Dead object
-- @tparam handle killersHandle Handle for the object that killed this object, if present
function ObjectKilled(deadObjectHandle, killersHandle)
    traceprint("_api::DeadObjectHandle(" .. tostring(deadObjectHandle) .. ", " .. tostring(killersHandle) .. ")");
    local object1 = GameObject.FromHandle(deadObjectHandle);
    local object2 = GameObject.FromHandle(killersHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("ObjectKilled", object1, object2);
    if retVal == nil then retVal = (object1:IsPlayer() and EjectKillRetCodes.DoEjectPilot or EjectKillRetCodes.DLLHandled); end
    traceprint("_api::/DeadObjectHandle");
    return retVal;
end

--- Called when an object is sniped.
-- @tparam handle deadObjectHandle Handle for the now Dead ship that was ejected out of
-- @tparam handle killersHandle Handle for the object that killed this object, if present
function ObjectSniped(deadObjectHandle, killersHandle)
    traceprint("_api::ObjectSniped(" .. tostring(deadObjectHandle) .. ", " .. tostring(killersHandle) .. ")");
    local object1 = GameObject.FromHandle(deadObjectHandle);
    local object2 = GameObject.FromHandle(killersHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("ObjectSniped", object1, object2);
    if retVal == nil then retVal = (object1:IsPlayer() and EjectKillRetCodes.DoGameOver or EjectKillRetCodes.DLLHandled); end
    traceprint("_api::/ObjectSniped");
    return retVal;
end

--- Called when an ordnance hits an object. This technically happens just before any damage is applied.
-- @tparam handle shooterHandle Handle of the Shooter
-- @tparam handle victimHandle Handle of the object hit
-- @tparam int ordnanceTeam Team number of the Ordnance, if applicable
-- @tparam string ordnanceODF ODF file of the Ordnance that hit the VictimHandle
function PreOrdnanceHit(shooterHandle, victimHandle, ordnanceTeam, ordnanceODF)
    traceprint("_api::PreOrdnanceHit(" .. tostring(shooterHandle) .. ", " .. tostring(victimHandle) .. ", " .. tostring(ordnanceTeam) .. ", " .. tostring(ordnanceODF) .. ")");
    local object1 = GameObject.FromHandle(shooterHandle);
    local object2 = GameObject.FromHandle(victimHandle);
    hook.CallAllNoReturn( "PreOrdnanceHit", object1, object2, ordnanceTeam, ordnanceODF );
    traceprint("_api::/PreOrdnanceHit");
end

--- Called when an object is Sniped. Occurs just before the snipe, and can be used to prevent it from happening.
-- This function is called when a SniperShell Ordnance hits an Object and would successfully trigger a Snipe.
-- @tparam int curWorld Current MP World. If you do anything that effects the world, ensure curWorld is 0 to avoid MP Resyncs
-- @tparam handle shooterHandle Handle of the Shooter
-- @tparam handle victimHandle Handle of the object hit
-- @tparam int ordnanceTeam Team number of the Ordnance, if applicable
-- @tparam string ordnanceODF ODF file of the Ordnance that hit the VictimHandle
-- @treturn int PreSnipeReturnValues
-- see ScriptUtils.PreSnipeReturnValues
function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, ordnanceODF)
    traceprint("_api::PreSnipe(" .. tostring(curWorld) .. ", " .. tostring(shooterHandle) .. ", " .. tostring(victimHandle) .. ", " .. tostring(ordnanceTeam) .. ", " .. tostring(ordnanceODF) .. ")");
    local object1 = GameObject.FromHandle(shooterHandle);
    local object2 = GameObject.FromHandle(victimHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PreSnipe", curWorld, object1, object2, ordnanceTeam, ordnanceODF);
    if retVal == nil then retVal = PreSnipeReturnCodes.PRESNIPE_KILLPILOT; end
    traceprint("_api::/PreSnipe");
    return retVal;
end

--- Called when a pilot gets into a ship. Can be used to prevent it.
-- @tparam int curWorld The current MP World. If you do anything that effects the world, ensure curWorld is 0 to avoid MP Resyncs
-- @tparam handle pilotHandle Handle of the Pilot
-- @tparam handle emptyCraftHandle Handle of the Empty craft
-- @treturn int PreGetInReturnValues
-- see ScriptUtils.PreGetInReturnValues
function PreGetIn(curWorld, pilotHandle, emptyCraftHandle)
    traceprint("_api::PreGetIn(" .. tostring(curWorld) .. ", " .. tostring(pilotHandle) .. ", " .. tostring(emptyCraftHandle) .. ")");
    local object1 = GameObject.FromHandle(pilotHandle);
    local object2 = GameObject.FromHandle(emptyCraftHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PreGetIn", curWorld, object1, object2);
    if retVal == nil then retVal = PreGetInReturnCodes.PREGETIN_ALLOW; end
    traceprint("_api::/PreGetIn");
    return retVal;
end

--- Called when a powerup is picked up. Can be used to prevent it.
-- @tparam int curWorld The current MP World. If you do anything that effects the world, ensure curWorld is 0 to avoid MP Resyncs.
-- @tparam handle me Handle of the object picking up the Powerup
-- @tparam handle powerupHandle Handle of the powerup object
-- @treturn int PrePickupPowerupReturnValues
-- see ScriptUtils.PrePickupPowerupReturnValues
function PrePickupPowerup(curWorld, me, powerupHandle)
    traceprint("_api::PrePickupPowerup(" .. tostring(curWorld) .. ", " .. tostring(me) .. ", " .. tostring(powerupHandle) .. ")");
    local object1 = GameObject.FromHandle(me);
    local object2 = GameObject.FromHandle(powerupHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PrePickupPowerup", curWorld, object1, object2);
    if retVal == nil then retVal = PrePickupPowerupReturnCodes.PREPICKUPPOWERUP_ALLOW; end
    traceprint("_api::/PrePickupPowerup");
    return retVal;
end

--- Called when the user? changes targets? Can be used to trigger events on a target change?
-- @tparam handle craft Handle of the object that just changed Targets
-- @tparam handle previousTarget Handle of the previous Target
-- @tparam handle currentTarget Handle of the new Target
function PostTargetChangeCallback(craft, previousTarget, currentTarget)
    traceprint("_api::PostTargetChangeCallback(" .. tostring(craft) .. ", " .. tostring(previousTarget) .. ", " .. tostring(currentTarget) .. ")");
    local object1 = GameObject.FromHandle(craft);
    local object2 = GameObject.FromHandle(previousTarget);
    local object3 = GameObject.FromHandle(currentTarget);
    hook.CallAllNoReturn( "PostTargetChangeCallback", object1, object2, object3 );
    traceprint("_api::/PostTargetChangeCallback");
end


--- Called at the End of the mission, shortly before game returns to the Shell UI.
function PostRun()
    debugprint("_api::PostRun()");
    hook.CallAllNoReturn( "PostRun" );
    debugprint("_api::/PostRun");
end

--- Used to select the team's next respawn ODF.
-- Note: Mission scripts tend to handle respawn logic themselves, making this superfluous.
-- @tparam int team Team number specified for filtering
function GetNextRandomVehicleODF(team)
    debugprint("_api::GetNextRandomVehicleODF(" .. tostring(team) .. ")");
    hook.CallAllNoReturn( "GetNextRandomVehicleODF", team );
    debugprint("_api::/GetNextRandomVehicleODF");
end

--- Called when an IFace command is triggered. Use CalcCRC(string) to determine the command from the crc value.
-- @tparam int crc CRC of the Command to process
function ProcessCommand ( crc )
    traceprint("_api::ProcessCommand(" .. tostring(crc) .. ")");
    hook.CallAllNoReturn( "ProcessCommand", crc );
    traceprint("_api::/ProcessCommand");
end

--- Called every tick to set the Random seed used to sync GetRandomFloat across Multiworld.
-- @tparam int seed Random seed to use
function SetRandomSeed ( seed )
    traceprint("_api::SetRandomSeed(" .. tostring(seed) .. ")");
    hook.CallAllNoReturn( "SetRandomSeed", seed );
    traceprint("_api::/SetRandomSeed");
end

-- @section Script Run

debugprint("_api Loaded");

print("LuaMission v" .. (LuaMissionVersion or 185) .. " detected");
if LuaMissionFeatures ~= nil and next(LuaMissionFeatures) ~= nil then
    print("LuaMission Features:");
    for name,ver in pairs(LuaMissionFeatures) do
        print("  " .. name .. " v" .. ver);
    end
end

return _api;