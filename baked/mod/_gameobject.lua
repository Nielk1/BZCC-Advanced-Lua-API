--- BZCC LUA Extended API GameObject.
-- 
-- GameObject wrapper functions.
-- 
-- Dependencies: @{_api}, @{_hook}
-- @module _gameobject
-- @author John "Nielk1" Klein

local debugprint = debugprint or function() end;

debugprint("_gameobject Loading");

local _api = require("_api");
local hook = require("_hook");

--- Is this object an instance of GameObject?
-- @param object Object in question
-- @treturn bool
function isgameobject(object)
  return (type(object) == "table" and object.__type == "GameObject");
end

local GameObjectMetatable = {};
GameObjectMetatable.__mode = "k";
local GameObjectWeakList = setmetatable({}, GameObjectMetatable);
local GameObjectAltered = {};
local GameObjectDeadAlteredMetatable = {};
GameObjectDeadAlteredMetatable.__mode = "k";
local GameObjectDeadAltered = setmetatable({}, GameObjectDeadAlteredMetatable);

--- GameObject.
-- An object containing all functions and data related to a game object.
GameObject = {}; -- the table representing the class, which will double as the metatable for the instances
--GameObject.__index = GameObject; -- failed table lookups on the instances should fallback to the class table, to get methods
GameObject.__index = function(table, key)
  local retVal = rawget(table, key);
  if retVal ~= nil then return retVal; end
  if rawget(table, "addonData") ~= nil and rawget(rawget(table, "addonData"), key) ~= nil then return rawget(rawget(table, "addonData"), key); end
  return rawget(GameObject, key); -- if you fail to get it from the subdata, move on to base (looking for functions)
end
GameObject.__newindex = function(dtable, key, value)
  if key == "addonData" then
    rawset(dtable, "addonData", value);
    local objectId = dtable:GetHandle();--string.sub(tostring(table:GetHandle()),4);
    if isstring(objectId) then
        GameObjectDeadAltered[objectId] = dtable;
    else
        GameObjectAltered[objectId] = dtable;
    end
  elseif key ~= "id" and key ~= "addonData" then
    local addonData = rawget(dtable, "addonData");
    if addonData == nil then
      rawset(dtable, "addonData", {});
      addonData = rawget(dtable, "addonData");
    end
    rawset(addonData, key, value);
    local objectId = dtable:GetHandle();--string.sub(tostring(table:GetHandle()),4);
    if isstring(objectId) then
        GameObjectDeadAltered[objectId] = dtable;
    else
        GameObjectAltered[objectId] = dtable;
    end
  else
    rawset(dtable, key, value);
  end
end
GameObject.__type = "GameObject";

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Core
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Create new GameObject Intance.
-- @tparam handle handle Handle from BZCC
-- @treturn GameObject
function GameObject.FromHandle(handle)
    local objectId = handle;--string.sub(tostring(handle),4);
    if GameObjectWeakList[objectId] ~= nil then
        return GameObjectWeakList[objectId];
    end
    local self = setmetatable({}, GameObject);
    self.id = handle;
    GameObjectWeakList[objectId] = self;
    return self;
end

--- Get Handle used by BZCC.
-- @tparam GameObject self GameObject instance
-- @treturn Handle
function GameObject.GetHandle(self)
    return self.id;
end

--- Save event function.
-- INTERNAL USE.
-- @tparam GameObject self GameObject instance
-- @return ...
function GameObject.Save(self)
    return self.id;
end

--- Load event function.
-- INTERNAL USE.
-- @param id Handle
function GameObject.Load(id)
    return GameObject.FromHandle(id);
end

--- BulkSave event function.
-- INTERNAL USE.
-- @return ...
function GameObject.BulkSave()
    local returnData = {};
    for k,v in pairs(GameObjectAltered) do
        returnData[k] = v.addonData;
    end
    local returnDataDead = {};
    for k,v in pairs(GameObjectDeadAltered) do
        returnDataDead[k] = v.addonData;
    end
    return returnData,returnDataDead;
end

--- BulkLoad event function.
-- INTERNAL USE.
-- @param data Object data
-- @param dataDead Dead object data
function GameObject.BulkLoad(data,dataDead)
    for k,v in pairs(data) do
        local newGameObject = GameObject.FromHandle(k);
        newGameObject.addonData = v;
    end
    for k,v in pairs(dataDead) do
        local newGameObject = GameObject.FromHandle(k);
        newGameObject.addonData = v;
    end
end

--- BulkPostLoad event function.
-- INTERNAL USE.
function GameObject.BulkPostLoad()

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Object Creation / Destruction
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Build Object.
-- @tparam string odf Object Definition File (without ".odf")
-- @tparam int team Team number for the object, 0 to 15
-- @param pos Position as GameObject, Pathpoint Name, AiPath, Vector, or Matrix
-- @treturn GameObject Newly built GameObject
function BuildGameObject(odf, team, pos)
    local handle = BuildObject(odf, team, pos);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Remove GameObject from world.
-- @tparam GameObject self GameObject instance
function GameObject.RemoveObject(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    RemoveObject(self:GetHandle());
end

--- Get GameObject of Player.
-- @tparam[opt] int team Team number of player
-- @treturn GameObject GameObject of player or nil
function GetPlayerGameObject(team)
    if team ~= nil and not isnumber(team) then error("Paramater team must be a number if supplied") end;
    local handle = GetPlayerHandle(team);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Get GameObject by seqNo or Label.
-- @param key Label or seqNo
-- @treturn GameObject GameObject with Label or seqNo, or nil if none found
function GetGameObject(key)
    local handle = GetHandle(key);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Groups
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Set group of GameObject in interface.
-- @tparam GameObject self GameObject instance
-- @param group Group number
function GameObject.SetGroup(self, group)
    if not isnumber(team) then error("Paramater team must be a number") end;
    if not isgameobject(self) then error("Paramater self must be GameObject instance.") end;
    SetGroup(self:GetHandle(), group);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Orders
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Order GameObject to Attack target GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam GameObject target Target GameObject
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Attack(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Attack(self:GetHandle(), target:GetHandle(), priority);
    else
        Attack(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Service target GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam GameObject target Target GameObject
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Service(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Service(self:GetHandle(), target:GetHandle(), priority);
    else
        Service(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Goto target GameObject / Path.
-- @tparam GameObject self GameObject instance
-- @param target Target GameObject, Vector, or Path name
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Goto(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Goto(self:GetHandle(), target:GetHandle(), priority);
    else
        Goto(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Mine target Path.
-- @tparam GameObject self GameObject instance
-- @param target Target Vector or Path name
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Mine(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Mine(self:GetHandle(), target:GetHandle(), priority);
    else
        Mine(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Follow target GameObject.
-- @tparam GameObject self GameObject instance
-- @param target Target GameObject instance
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Follow(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Follow(self:GetHandle(), target:GetHandle(), priority);
    else
        Follow(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Defend area.
-- @tparam GameObject self GameObject instance
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Defend(self, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Defend(self:GetHandle(), priority);
end

--- Order GameObject to Defend2 target GameObject.
-- @tparam GameObject self GameObject instance
-- @param target Target GameObject instance
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Defend2(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Defend2(self:GetHandle(), target:GetHandle(), priority);
    else
        Defend2(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Stop.
-- @tparam GameObject self GameObject instance
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Stop(self, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Stop(self:GetHandle(), priority);
end

--- Order GameObject to Patrol target path.
-- @tparam GameObject self GameObject instance
-- @param target Target Path name
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Patrol(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Patrol(self:GetHandle(), target:GetHandle(), priority);
    else
        Patrol(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Retreat.
-- @tparam GameObject self GameObject instance
-- @param target Target GameObject or Path name
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Retreat(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Retreat(self:GetHandle(), target:GetHandle(), priority);
    else
        Retreat(self:GetHandle(), target, priority)
    end
end

--- Order GameObject to GetIn target GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam GameObject target Target GameObject
-- @tparam int priority Order priority, >0 removes user control
function GameObject.GetIn(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        GetIn(self:GetHandle(), target:GetHandle(), priority);
    else
        GetIn(self:GetHandle(), target, priority)
    end
end

--- Order GameObject to Pickup target GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam GameObject target Target GameObject
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Pickup(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Pickup(self:GetHandle(), target:GetHandle(), priority);
    else
        Pickup(self:GetHandle(), target, priority)
    end
end

--- Order GameObject to Pickup target path name.
-- @tparam GameObject self GameObject instance
-- @param target Target vector or path name
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Dropoff(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Dropoff(self:GetHandle(), target, priority)
end

--- Order GameObject to Build target config.
-- Oddly this function does not include a location for the action, might want to use the far more powerful orders system.
-- @tparam GameObject self GameObject instance
-- @tparam string odf Object Definition
-- @tparam int priority Order priority, >0 removes user control
function GameObject.Build(self, odf, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Build(self:GetHandle(), target, priority)
end

--- Order GameObject to LookAt target GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam GameObject target Target GameObject instance
-- @tparam int priority Order priority, >0 removes user control
function GameObject.LookAt(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        LookAt(self:GetHandle(), target:GetHandle(), priority);
    else
        LookAt(self:GetHandle(), target, priority)
    end
end

--- Order entire team to look at GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam int team Target team number
-- @tparam int priority Order priority, >0 removes user control
function GameObject.AllLookAtMe(self, team, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater target must be number."); end
    AllLookAt(team, self:GetHandle(), priority);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Position & Velocity
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Get object's position vector.
-- @tparam GameObject self GameObject instance
-- @treturn Vector
function GameObject.GetPosition(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetPosition(self:GetHandle());
end

--- Get object's position vector, even if killed.
-- @tparam GameObject self GameObject instance
-- @treturn Vector
function GameObject.GetPosition2(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetPosition2(self:GetHandle());
end

--- Get front vector.
-- @tparam GameObject self GameObject instance
-- @treturn Vector
function GameObject.GetFront(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetFront(self:GetHandle());
end

--- Get front look vector.
-- @tparam GameObject self GameObject instance
-- @treturn Vector
function GameObject.GetLookFront(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetLookFront(self:GetHandle());
end

--- Set the position of the GameObject.
-- @tparam GameObject self GameObject instance
-- @param position Vector position, Matrix position, or path name
-- @tparam[opt] int point Index of the path point in the path (optional)
function GameObject.SetPosition(self, position, point)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetPosition(self:GetHandle(), position, point);
end

--- Get object's tranform matrix.
-- @tparam GameObject self GameObject instance
-- @treturn Matrix
function GameObject.GetTransform(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetTransform(self:GetHandle());
end

--- Set the tranform matrix of the GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam Matrix transform transform matrix
function GameObject.SetTransform(self, transform)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetTransform(self:GetHandle(), transform);
end

--- Set a random angle for the GameObject.
-- Sets the specified craft to a random angle (in 2D-only). Normally,
-- craft are always built facing due north; this spices things up.
-- @tparam GameObject self GameObject instance
function GameObject.SetRandomHeadingAngle(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetRandomHeadingAngle(self:GetHandle());
end

--- Get object's velocity vector.
-- @tparam GameObject self GameObject instance
-- @treturn Vector Vector, (0,0,0) if the handle is invalid or isn't movable.
function GameObject.GetVelocity(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetVelocity(self:GetHandle());
end

--- Set the velocity of the GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam Vector vel Vector velocity
function GameObject.SetVelocity(self, vel)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetVelocity(self:GetHandle(), vel);
end

--- Get object's omega.
-- @tparam GameObject self GameObject instance
-- @treturn Vector Vector, (0,0,0) if the handle is invalid or isn't movable.
function GameObject.GetOmega(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetOmega(self:GetHandle());
end

--- Set the omega of the GameObject.
-- @tparam GameObject self GameObject instance
-- @param omega
function GameObject.SetOmega(self, omega)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetOmega(self:GetHandle(),omega);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Condition Checks
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Is the GameObject alive and is still pilot controlled?
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsAlive(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsAlive2(self:GetHandle());
end

--- Is the GameObject flying?
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsFlying(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsFlying2(self:GetHandle());
end

--- Is the GameObject alive and piloted?
-- Returns true if the handle passed in is a user's pilot, returns false if dead, no AI pilot, or pilotClass is NULL.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsAliveAndPilot(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsAliveAndPilot(self:GetHandle());
end

--- Is the GameObject not dead and piloted?
-- Like IsAliveAndPilot2, but differs subtly. The IsAlive* functions
-- will return false if the 'destroyed' flag is set on the object --
-- i.e. health < 0. But, there's sometimes a slight delay between when
-- destroyed = true, and the end of the death sequence (explosion,
-- etc), which is when DLL::ObjectKilled() is called. Thus,
-- IsNotDeadAndPilot2() will return true as long as the object hasn't
-- fully been killed yet.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsNotDeadAndPilot(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsNotDeadAndPilot2(self:GetHandle());
end

--- Does the GameObject exists?
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsAround(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local objectId = self:GetHandle();
    if isstring(objectId) then
        return false;
    end
    return IsAround(objectId);
end

--- Returns true if it's a Craft, but NOT a person.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsCraftButNotPerson(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsCraftButNotPerson(self:GetHandle());
end

--- Returns true if it's a Craft or person. (equivalent to `h:IsCraft() or h:IsPerson()`)
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsCraftOrPerson(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsCraftOrPerson(self:GetHandle());
end

--- Returns true if it's a Building.
-- Does not include guntowers.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsBuilding(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsBuilding(self:GetHandle());
end

--- Returns true if it's a Powerup.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsPowerup(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsPowerup(self:GetHandle());
end

--- Checks if the GameObject has a pilot.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.HasPilot(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return HasPilot(self:GetHandle());
end

--- Checks if the GameObject has cargo (tug).
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.HasCargo(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    HasCargo(self:GetHandle());
end

--- What tug GameObject is tugging this if any?
-- @tparam GameObject self GameObject instance
-- @treturn GameObject GameObject of the tug carrything the GameObject, or nil
function GameObject.GetTug(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local handle = GetTug(self:GetHandle());
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Has the GameObject hopped out of a vehicle? What vehicle?
-- @tparam GameObject self GameObject instance
-- @treturn GameObject GameObject of the vehicle that the pilot most recently hopped out of, or nil
function GameObject.HoppedOutOf(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local handle = HoppedOutOf(self:GetHandle());
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Is the GameObject in a building? What building?
-- @tparam GameObject self GameObject instance
-- @treturn GameObject GameObject of the building the GameObject is inside, or nil
function GameObject.InBuilding(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local handle = InBuilding(self:GetHandle());
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Is the GameObject using a terminal? What terminal?
-- @tparam GameObject self GameObject instance
-- @treturn GameObject GameObject of the terminal in use, or nil
function GameObject.AtTerminal(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local handle = AtTerminal(self:GetHandle());
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Gets whether the GameObject can be sniped.
-- Sets if a handle can be sniped, <0 == Auto-determine from ODF
-- (default, tracked/walkers/flying not snipe-able), 0 == Not
-- snipeable, >= 1 == snipeable. Note: turrettanks can and will change
-- this when deployed; do not expect this to remain set permanently.
-- @tparam GameObject self GameObject instance
-- @tparam[opt] int canSnipe
function GameObject.SetCanSnipe(self, canSnipe)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if canSnipe == nil then canSnipe = -1; end
    if not isinteger(canSnipe) then error("Paramater canSnipe must be integer."); end
    SetCanSnipe(self:GetHandle());
end

--- Gets whether the GameObject can be sniped.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.GetCanSnipe(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetCanSnipe(self:GetHandle());
end

--- Checks if the GameObject is a local or remotely-controlled player.
-- @tparam GameObject self GameObject instance
-- @treturn bool
function GameObject.IsPlayer(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsPlayer(self:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Taps
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Get the Tap gameobject at index
-- @tparam GameObject self GameObject instance
-- @tparam int index Tap index
-- @treturn GameObject
function GameObject.GetTap(self, index)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(index) then error("Paramater target must be number."); end
    local handle = GetTap(self:GetHandle(), index);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Set an object as a tap of a GameObject
-- @tparam GameObject self GameObject instance
-- @tparam int index Tap index
-- @param object GameObject instance to be attached
function GameObject.SetTap(self, index, object)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(index) then error("Paramater target must be number."); end
    if not isgameobject(object) then error("Paramater object must be GameObject instance."); end
    return SetTap(self:GetHandle(), index, object:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Animations
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- SetAnimation GameObject animation
-- @tparam GameObject self GameObject instance
-- @tparam string name Animation name
-- @tparam int animType Animation Type, 0 == loop, 1 == 2way
-- @return max frames
function GameObject.SetAnimation(self, name, animType)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isstring(name) then error("Paramater name must be string."); end
    if not isnumber(animType) then error("Paramater animType must be 0 or 1."); end
    if animType ~= 0 and animType ~= 1 then error("Paramater animType must be 0 or 1."); end
    return SetAnimation(self:GetHandle(), name, animType);
end

--- Get animation frame of a GameObject
-- @tparam GameObject self GameObject instance
-- @tparam string name Animation name
-- @return frame
function GameObject.GetAnimationFrame(self, name)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isstring(name) then error("Paramater name must be string."); end
    return GetAnimationFrame(self:GetHandle(), name);
end

--- Start the current animation of a GameObject
-- @tparam GameObject self GameObject instance
function GameObject.StartAnimation(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return StartAnimation(self:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Damage, Health, and Ammo
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Cause GameObject to take damage.
-- Note that if the damager is set the amt will be an integer.
-- @tparam GameObject self GameObject instance
-- @param amt damage ammount
-- @param damager GameObject credited with damage (optional)
function GameObject.Damage(self, amt, damager)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    if damager ~= nil and not isgameobject(damager) then error("Paramater damager must be GameObject instance."); end
    
    if damager ~= nil then
        Damage(self:GetHandle(), amt, damager);
    else
        Damage(self:GetHandle(), amt);
    end
end

--- Cause GameObject to take damage.
-- @tparam GameObject self GameObject instance
-- @param amt damage ammount
function GameObject.DamageF(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    DamageF(self:GetHandle(), amt);
end

--- Cause GameObject to take damage crediting itself.
-- Like Damage()/DamageF(), but sets the damage causer to him. This
-- prevents anyone else from taking credit for a kill on them, if this
-- damage does the job of killing them.
-- @tparam GameObject self GameObject instance
-- @param amt damage ammount
function GameObject.SelfDamage(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    SelfDamage(self:GetHandle(), amt);
end

--- Get health ratio of GameObject.
-- @usage if friend1:GetHealth() < 0.5 then friend1:Retreat("retreat_path"); end
-- @tparam GameObject self GameObject instance
-- @return number health ratio
function GameObject.GetHealth(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetHealth(self:GetHandle());
end

--- Get current health of GameObject.
-- @tparam GameObject self GameObject instance
-- @return number current health or nil
function GameObject.GetCurHealth(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetCurHealth(self:GetHandle());
end

--- Get max health of GameObject.
-- @tparam GameObject self GameObject instance
-- @return number max health or nil
function GameObject.GetMaxHealth(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetMaxHealth(self:GetHandle());
end

--- Sets the current health of the GameObject to the NewHealth value.
-- @tparam GameObject self GameObject instance
-- @param amt health ammount
function GameObject.SetCurHealth(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    SetCurHealth(self:GetHandle(), amt);
end

--- Sets the max health of the GameObject to the NewHealth value.
-- @tparam GameObject self GameObject instance
-- @param amt health ammount
function GameObject.SetMaxHealth(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    SetMaxHealth(self:GetHandle(), amt);
end

--	{ "AddHealth", AddHealth },
--// Adds the health to the specified handle.
--DLLEXPORT void DLLAPI AddHealth(Handle h, long health);

--- Adds the health to the GameObject.
-- @tparam GameObject self GameObject instance
-- @param amt health ammount
function GameObject.AddHealth(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    AddHealth(self:GetHandle(), amt);
end



--	{ "GetAmmo", GetAmmo },
--// Returns the ammo Ratio of the handle (1.0f - 0.0f). Returns 0.0f if handle is invalid.
--DLLEXPORT float DLLAPI GetAmmo(Handle h);

--	{ "GetCurAmmo", GetCurAmmo },
--// Returns the current Ammo of a handle. Returns -1234 if the handle is invalid.
--DLLEXPORT long DLLAPI GetCurAmmo(Handle h);

--	{ "GetMaxAmmo", GetMaxAmmo },
--// Returns the max Ammo of a handle. Returns -1234 if the handle is invalid.
--DLLEXPORT long DLLAPI GetMaxAmmo(Handle h);

--	{ "SetCurAmmo", SetCurAmmo },
--// Sets the current ammo of the handle to the NewAmmo value.
--DLLEXPORT void DLLAPI SetCurAmmo(Handle h, long NewAmmo);

--	{ "SetMaxAmmo", SetMaxAmmo },
--// Sets the max ammo of the handle to the NewAmmo value.
--DLLEXPORT void DLLAPI SetMaxAmmo(Handle h, long NewAmmo);

--	{ "AddAmmo", AddAmmo },
--// Adds the ammo to the specified handle.
--DLLEXPORT void DLLAPI AddAmmo(Handle h, long ammo);



----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Damage, Health, and Ammo
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Get team number of the GameObject.
-- @tparam GameObject self GameObject instance
-- @treturn int Team number
function GameObject.GetTeamNum(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetTeamNum(self:GetHandle());
end

--- Set team number of the GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam int team new team number
function GameObject.SetTeamNum(self, team)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater amt must be number."); end
    SetTeamNum(self:GetHandle(), team);
end

--- Get perceived team number of the GameObject.
-- @tparam GameObject self GameObject instance
-- @treturn int Team number
function GameObject.GetPerceivedTeam(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetPerceivedTeam(self:GetHandle());
end

--- Set perceived team number of the GameObject.
-- @tparam GameObject self GameObject instance
-- @tparam int team new team number
function GameObject.SetPerceivedTeam(self, team)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater amt must be number."); end
    SetPerceivedTeam(self:GetHandle(), team);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Other
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Is the GameObject this odf?
-- @tparam GameObject self GameObject instance
-- @tparam string odf ODF filename
-- @usage enemy1:IsOdf("svturr")
function GameObject.IsOdf(self, odf)
  if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
  if not isstring(odf) then error("Paramater odf must be a string."); end
  IsOdf(self:GetHandle(), odf);
end

--- Get odf of GameObject
-- @tparam GameObject self GameObject instance
function GameObject.GetOdf(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetOdf(self:GetHandle());
end

--- Get race of GameObject
-- @tparam GameObject self GameObject instance
-- @treturn string character identifier for race
function GameObject.GetRace(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetRace(self:GetHandle());
end

--- Get label of GameObject
-- @tparam GameObject self GameObject instance
-- @treturn string Label name string
function GameObject.GetLabel(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetLabel(self:GetHandle());
end

--- Is the GameObject this odf?
-- @tparam GameObject self GameObject instance
-- @tparam string label Label
-- @usage enemy1:SetLabel("special_object_7")
function GameObject.SetLabel(self, label)
  if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
  if not isstring(label) then error("Paramater label must be a string."); end
  SetLabel(self:GetHandle(),label);
end

--- Adds in a pilot if needed to a GameObject
-- @tparam GameObject self GameObject instance
-- @usage enemy1:AddPilot()
function GameObject.AddPilot(self)
  if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
  AddPilotByHandle(self:GetHandle());
end

--- Set GameObject as the local or remote user
-- This must be called after building a new craft on entry or respawn
-- @tparam GameObject self GameObject instance
-- @tparam int team new team number
function GameObject.SetAsUser(self, team)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater amt must be number."); end
    SetAsUser(self:GetHandle(), team);
end

hook.Add("DeleteObject", "GameObject_DeleteObject", function(object)
    local objectId = object:GetHandle();
    debugprint('Decaying object ' .. tostring(objectId));
    GameObjectDeadAltered[objectId] = GameObjectAltered[objectId]; -- move data tracking, if it exists, to a weak table so it can GC if not being held onto
    GameObjectAltered[objectId] = nil; -- clear hard reference for data we might have from strong table so the object can GC if nothing uses it
    --print(table.show(GameObjectWeakList,"GameObjectWeakList"));
    --print(table.show(GameObjectAltered,"GameObjectAltered"));
    --print(table.show(GameObjectDeadAltered,"GameObjectDeadAltered"));
end, -9999);

_api.RegisterCustomSavableType(GameObject);

debugprint("_gameobject Loaded");

--return _gameobject;