--- BZCC LUA Extended API.
--
-- This API creates a full OOP wrapper and replacement the mission
-- functions with an event based system for easier expansion.
--
-- Dependencies: `_hook`
-- @module _api
-- @author John "Nielk1" Klein

debugprint = debugprint or function() end;

debugprint("_api Loading");

--==============================================================================================================================================================
-- Utility Functions
--==============================================================================================================================================================

--- Is this object a function?
-- @param object Object in question
-- @return bool
function isfunction(object)
  return (type(object) == "function");
end

--- Is this object a table?
-- @param object Object in question
-- @return bool
function istable(object)
  return (type(object) == 'table');
end

--- Is this object an instance of GameObject?
-- @param object Object in question
-- @return bool
function isgameobject(object)
  return (type(object) == "table" and object.__type == "GameObject");
end

--- Is this object a string?
-- @param object Object in question
-- @return bool
function isstring(object)
  return (type(object) == "string");
end

--- Is this object a boolean?
-- @param object Object in question
-- @return bool
function isboolean(object)
  return (type(object) == "boolean");
end

--- Is this object a number?
-- @param object Object in question
-- @return bool
function isnumber(object)
  return (type(object) == "number");
end

--- Is this object an integer?
-- @param object Object in question
-- @return bool
function isinteger(object)
  if not isfunction(object) then return false end;
  return object == math.floor(object);
end

--==============================================================================================================================================================
-- GameObject
--==============================================================================================================================================================

local GameObjectMetatable = {};
GameObjectMetatable.__mode = "k";
local GameObjectWeakList = setmetatable({}, GameObjectMetatable);
local GameObjectAltered = {};

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
GameObject.__newindex = function(table, key, value)
  if key ~= "id" and key ~= "addonData" then
    local addonData = rawget(table, "addonData");
    if addonData == nil then
      rawset(table, "addonData", {});
      addonData = rawget(table, "addonData");
    end
    rawset(addonData, key, value);
    GameObjectAltered[table:GetHandle()] = table;
  else
    rawset(table, key, value);
  end
end
GameObject.__type = "GameObject";

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Core
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Create new GameObject Intance.
-- @param handle Handle from BZCC
-- @return GameObject
function GameObject.FromHandle(handle)
    local stringId = tostring(handle);
    if GameObjectWeakList[stringId] ~= nil then return GameObjectWeakList[stringId]; end
    local self = setmetatable({}, GameObject);
    self.id = handle;
    GameObjectWeakList[stringId] = self;
    return self;
end

--- Get Handle used by BZCC.
-- @param self GameObject instance
-- @return Handle
function GameObject.GetHandle(self)
    return self.id;
end

--- Save event function.
-- INTERNAL USE.
-- @param self GameObject instance
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
        returnData[v.id] = v.addonData;
    end
    return returnData;
end

--- BulkLoad event function.
-- INTERNAL USE.
-- @params data
function GameObject.BulkLoad(data)
  for k,v in pairs(data) do
    local newGameObject = GameObject.FromHandle(k);
    newGameObject.addonData = v;
  end
end

--- BulkPostLoad event function.
-- INTERNAL USE.
function GameObject.BulkPostLoad()

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Object Creation / Destruction
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Build Object.
-- @param odf Object Definition File (without ".odf")
-- @param team Team number for the object, 0 to 15
-- @param pos Position as GameObject, Pathpoint Name, AiPath, Vector, or Matrix
-- @return Newly built GameObject
function BuildGameObject(odf, team, pos)
    local handle = BuildObject(odf, team, pos);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Remove GameObject from world.
-- @param self GameObject instance
function GameObject.RemoveObject(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    RemoveObject(self:GetHandle());
end

--- Get GameObject of Player.
-- @param team Team number of player (optional)
-- @return GameObject of player or nil
function GetPlayerGameObject(team)
    if team ~= nil and not isnumber(team) then error("Paramater team must be a number if supplied") end;
    local handle = GetPlayerHandle(team);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Get GameObject by seqNo or Label.
-- @param key Label or seqNo
-- @return GameObject with Label or seqNo, or nil if none found
function GetGameObject(key)
    local handle = GetHandle(key);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Groups
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Set group of GameObject in interface.
-- @param self GameObject instance
-- @param group Group number
function GameObject.SetGroup(self, group)
    if not isnumber(team) then error("Paramater team must be a number") end;
    if not isgameobject(self) then error("Paramater self must be GameObject instance.") end;
    SetGroup(self:GetHandle(), group);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Orders
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Order GameObject to Attack target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject
-- @param priority Order priority, >0 removes user control
function GameObject.Attack(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Attack(self:GetHandle(), target:GetHandle(), priority);
    else
        Attack(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Service target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject
-- @param priority Order priority, >0 removes user control
function GameObject.Service(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Service(self:GetHandle(), target:GetHandle(), priority);
    else
        Service(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Goto target GameObject / Path.
-- @param self GameObject instance
-- @param target Target GameObject, Vector, or Path name
-- @param priority Order priority, >0 removes user control
function GameObject.Goto(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Goto(self:GetHandle(), target:GetHandle(), priority);
    else
        Goto(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Mine target Path.
-- @param self GameObject instance
-- @param target Target Vector or Path name
-- @param priority Order priority, >0 removes user control
function GameObject.Mine(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Mine(self:GetHandle(), target:GetHandle(), priority);
    else
        Mine(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Follow target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject instance
-- @param priority Order priority, >0 removes user control
function GameObject.Follow(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Follow(self:GetHandle(), target:GetHandle(), priority);
    else
        Follow(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Defend area.
-- @param self GameObject instance
-- @param priority Order priority, >0 removes user control
function GameObject.Defend(self, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Defend(self:GetHandle(), priority);
end

--- Order GameObject to Defend2 target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject instance
-- @param priority Order priority, >0 removes user control
function GameObject.Defend2(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Defend2(self:GetHandle(), target:GetHandle(), priority);
    else
        Defend2(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Stop.
-- @param self GameObject instance
-- @param priority Order priority, >0 removes user control
function GameObject.Stop(self, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Stop(self:GetHandle(), priority);
end

--- Order GameObject to Patrol target path.
-- @param self GameObject instance
-- @param target Target Path name
-- @param priority Order priority, >0 removes user control
function GameObject.Patrol(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Patrol(self:GetHandle(), target:GetHandle(), priority);
    else
        Patrol(self:GetHandle(), target, priority);
    end
end

--- Order GameObject to Retreat.
-- @param self GameObject instance
-- @param target Target GameObject or Path name
-- @param priority Order priority, >0 removes user control
function GameObject.Retreat(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Retreat(self:GetHandle(), target:GetHandle(), priority);
    else
        Retreat(self:GetHandle(), target, priority)
    end
end

--- Order GameObject to GetIn target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject
-- @param priority Order priority, >0 removes user control
function GameObject.GetIn(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        GetIn(self:GetHandle(), target:GetHandle(), priority);
    else
        GetIn(self:GetHandle(), target, priority)
    end
end

--- Order GameObject to Pickup target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject
-- @param priority Order priority, >0 removes user control
function GameObject.Pickup(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        Pickup(self:GetHandle(), target:GetHandle(), priority);
    else
        Pickup(self:GetHandle(), target, priority)
    end
end

--- Order GameObject to Pickup target path name.
-- @param self GameObject instance
-- @param target Target vector or path name
-- @param priority Order priority, >0 removes user control
function GameObject.Dropoff(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Dropoff(self:GetHandle(), target, priority)
end

--- Order GameObject to Build target config.
-- Oddly this function does not include a location for the action, might want to use the far more powerful orders system.
-- @param self GameObject instance
-- @param odf Object Definition
-- @param priority Order priority, >0 removes user control
function GameObject.Build(self, odf, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    Build(self:GetHandle(), target, priority)
end

--- Order GameObject to LookAt target GameObject.
-- @param self GameObject instance
-- @param target Target GameObject instance
-- @param priority Order priority, >0 removes user control
function GameObject.LookAt(self, target, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if isgameobject(target) then
        LookAt(self:GetHandle(), target:GetHandle(), priority);
    else
        LookAt(self:GetHandle(), target, priority)
    end
end

--- Order entire team to look at GameObject.
-- @param self GameObject instance
-- @param team Target team number
-- @param priority Order priority, >0 removes user control
function GameObject.AllLookAtMe(self, team, priority)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater target must be number."); end
    AllLookAt(team, self:GetHandle(), priority);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Position
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Get object's position vector.
-- @param self GameObject instance
-- @return Vector
function GameObject.GetPosition(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetPosition(self:GetHandle());
end

--- Get object's position vector, even if killed.
-- @param self GameObject instance
-- @return Vector
function GameObject.GetPosition2(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetPosition(self:GetHandle());
end

--- Get front vector.
-- @param self GameObject instance
-- @return Vector
function GameObject.GetFront(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetFront(self:GetHandle());
end

--- Set the position of the GameObject.
-- @param self GameObject instance
-- @param position Vector position, Matrix position, or path name
-- @param point Index of the path point in the path (optional)
function GameObject.SetPosition(self, position, point)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetPosition(self:GetHandle(), position, point);
end

--- Get object's tranform matrix.
-- @param self GameObject instance
-- @return Matrix
function GameObject.GetTransform(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetTransform(self:GetHandle());
end

--- Set the tranform matrix of the GameObject.
-- @param self GameObject instance
-- @param transform transform matrix
function GameObject.SetTransform(self, transform)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetTransform(self:GetHandle(), transform);
end

--- Set a random angle for the GameObject.
-- Sets the specified craft to a random angle (in 2D-only). Normally,
-- craft are always built facing due north; this spices things up.
-- @param self GameObject instance
function GameObject.SetRandomHeadingAngle(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    SetRandomHeadingAngle(self:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Condition Checks
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Is the GameObject alive and is still pilot controlled?
-- @param self GameObject instance
-- @return bool
function GameObject.IsAlive(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsAlive2(self:GetHandle());
end

--- Is the GameObject flying?
-- @param self GameObject instance
-- @return bool
function GameObject.IsFlying(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsFlying2(self:GetHandle());
end

--- Is the GameObject alive and piloted?
-- Returns true if the handle passed in is a user's pilot, returns false if dead, no AI pilot, or pilotClass is NULL.
-- @param self GameObject instance
-- @return bool
function GameObject.IsAliveAndPilot(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsAliveAndPilot2(self:GetHandle());
end

--- Is the GameObject not dead and piloted?
-- Like IsAliveAndPilot2, but differs subtly. The IsAlive* functions
-- will return false if the 'destroyed' flag is set on the object --
-- i.e. health < 0. But, there's sometimes a slight delay between when
-- destroyed = true, and the end of the death sequence (explosion,
-- etc), which is when DLL::ObjectKilled() is called. Thus,
-- IsNotDeadAndPilot2() will return true as long as the object hasn't
-- fully been killed yet.
-- @param self GameObject instance
-- @return bool
function GameObject.IsNotDeadAndPilot(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsNotDeadAndPilot2(self:GetHandle());
end

--- Does the GameObject exists?
-- @param self GameObject instance
-- @return bool
function GameObject.IsAround(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsAround(self:GetHandle());
end

--- Returns true if it's a Craft, but NOT a person.
-- @param self GameObject instance
-- @return bool
function GameObject.IsCraftButNotPerson(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsCraftButNotPerson(self:GetHandle());
end

--- Returns true if it's a Craft or person. (equivalent to `h:IsCraft() or h:IsPerson()`)
-- @param self GameObject instance
-- @return bool
function GameObject.IsCraftOrPerson(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsCraftOrPerson(self:GetHandle());
end

--- Returns true if it's a Building.
-- Does not include guntowers.
-- @param self GameObject instance
-- @return bool
function GameObject.IsBuilding(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsBuilding(self:GetHandle());
end

--- Returns true if it's a Powerup.
-- @param self GameObject instance
-- @return bool
function GameObject.IsPowerup(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsPowerup(self:GetHandle());
end

--- Checks if the GameObject has a pilot.
-- @param self GameObject instance
-- @return bool
function GameObject.HasPilot(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return HasPilot(self:GetHandle());
end

--- Checks if the GameObject has cargo (tug).
-- @param self GameObject instance
-- @return bool
function GameObject.HasCargo(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    HasCargo(self:GetHandle());
end

--- What tug GameObject is tugging this if any?
-- @param self GameObject instance
-- @return GameObject of the tug carrything the GameObject, or nil
function GameObject.GetTug(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local handle = GetTug(self:GetHandle());
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Is the GameObject in a building? What building?
-- @param self GameObject instance
-- @return GameObject of the building the GameObject is inside, or nil
function GameObject.InBuilding(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    local handle = InBuilding(self:GetHandle());
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Is the GameObject using a terminal? What terminal?
-- @param self GameObject instance
-- @return GameObject of the terminal in use, or nil
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
-- @param self GameObject instance
-- @param canSnipe optional
function GameObject.SetCanSnipe(self, canSnipe)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if canSnipe == nil then canSnipe = -1; end
    if not isinteger(canSnipe) then error("Paramater canSnipe must be integer."); end
    SetCanSnipe(self:GetHandle());
end

--- Gets whether the GameObject can be sniped.
-- @param self GameObject instance
-- @return bool
function GameObject.GetCanSnipe(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetCanSnipe(self:GetHandle());
end

--- Checks if the GameObject is a local or remotely-controlled player.
-- @param self GameObject instance
-- @return bool
function GameObject.IsPlayer(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return IsPlayer(self:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Taps
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Get the Tap gameobject at index
-- @param self GameObject instance
-- @param index Tap index
-- @return GameObject
function GameObject.GetTap(self, index)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(index) then error("Paramater target must be number."); end
    local handle = GetTap(self:GetHandle(), index);
    if handle == nil then return nil end;
    return GameObject.FromHandle(handle);
end

--- Set an object as a tap of a GameObject
-- @param self GameObject instance
-- @param index Tap index
-- @param object GameObject instance to be attached
function GameObject.SetTap(self, index, object)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(index) then error("Paramater target must be number."); end
    if not isgameobject(object) then error("Paramater object must be GameObject instance."); end
    return SetTap(self:GetHandle(), index, object:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Animations
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- SetAnimation GameObject animation
-- @param self GameObject instance
-- @param name Animation name
-- @param animType Animation Type, 0 == loop, 1 == 2way
-- @return max frames
function GameObject.SetAnimation(self, name, animType)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isstring(name) then error("Paramater name must be string."); end
    if not isnumber(animType) then error("Paramater animType must be 0 or 1."); end
    if animType ~= 0 and animType ~= 1 then error("Paramater animType must be 0 or 1."); end
    return SetAnimation(self:GetHandle(), name, animType);
end

--- Get animation frame of a GameObject
-- @param self GameObject instance
-- @param name Animation name
-- @return frame
function GameObject.GetAnimationFrame(self, name)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isstring(name) then error("Paramater name must be string."); end
    return GetAnimationFrame(self:GetHandle(), name);
end

--- Start the current animation of a GameObject
-- @param self GameObject instance
-- @param name Animation name
function GameObject.StartAnimation(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return StartAnimation(self:GetHandle());
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Damage, Health, and Ammo
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Cause GameObject to take damage.
-- Note that if the damager is set the amt will be an integer.
-- @param self GameObject instance
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
-- @param self GameObject instance
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
-- @param self GameObject instance
-- @param amt damage ammount
function GameObject.SelfDamage(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    SelfDamage(self:GetHandle(), amt);
end

--- Get health ratio of GameObject.
-- @usage if friend1:GetHealth() < 0.5 then friend1:Retreat("retreat_path"); end
-- @param self GameObject instance
-- @return number health ratio
function GameObject.GetHealth(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetHealth(self:GetHandle());
end

--- Get current health of GameObject.
-- @param self GameObject instance
-- @return number current health or nil
function GameObject.GetCurHealth(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetCurHealth(self:GetHandle());
end

--- Get max health of GameObject.
-- @param self GameObject instance
-- @return number max health or nil
function GameObject.GetMaxHealth(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetMaxHealth(self:GetHandle());
end

--- Sets the current health of the GameObject to the NewHealth value.
-- @param self GameObject instance
-- @param amt health ammount
function GameObject.SetCurHealth(self, amt)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(amt) then error("Paramater amt must be number."); end
    SetCurHealth(self:GetHandle(), amt);
end

--- Sets the max health of the GameObject to the NewHealth value.
-- @param self GameObject instance
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
-- @param self GameObject instance
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
-- GameObject - Damage, Health, and Ammo
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Get team number of the GameObject.
-- @param self GameObject instance
-- @return integer Team number
function GameObject.GetTeamNum(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetTeamNum(self:GetHandle());
end

--- Set team number of the GameObject.
-- @param self GameObject instance
-- @param team new team number
function GameObject.SetTeamNum(self, team)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater amt must be number."); end
    SetTeamNum(self:GetHandle(), team);
end

--- Get perceived team number of the GameObject.
-- @param self GameObject instance
-- @return integer Team number
function GameObject.GetPerceivedTeam(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetPerceivedTeam(self:GetHandle());
end

--- Set perceived team number of the GameObject.
-- @param self GameObject instance
-- @param team new team number
function GameObject.SetPerceivedTeam(self, team)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater amt must be number."); end
    SetPerceivedTeam(self:GetHandle(), team);
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GameObject - Other
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Is the GameObject this odf?
-- @param self GameObject instance
-- @param odf ODF filename
-- @usage enemy1:IsOdf("svturr")
function GameObject.IsOdf(self, odf)
  if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
  if not isstring(odf) then error("Paramater odf must be a string."); end
  IsOdf(self:GetHandle(), odf);
end

--- Get odf of GameObject
-- @param self GameObject instance
function GameObject.GetOdf(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetOdf(self:GetHandle());
end

--- Get race of GameObject
-- @param self GameObject instance
-- @return character identifier for race
function GameObject.GetRace(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetRace(self:GetHandle());
end

--- Get label of GameObject
-- @param self GameObject instance
-- @return Label name string
function GameObject.GetLabel(self)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    return GetLabel(self:GetHandle());
end

--- Is the GameObject this odf?
-- @param self GameObject instance
-- @param label Label
-- @usage enemy1:SetLabel("special_object_7")
function GameObject.SetLabel(self, label)
  if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
  if not isstring(label) then error("Paramater label must be a string."); end
  SetLabel(self:GetHandle(),label);
end

--- Adds in a pilot if needed to a GameObject
-- @param self GameObject instance
-- @usage enemy1:AddPilot()
function GameObject.AddPilot(self)
  if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
  AddPilotByHandle(self:GetHandle());
end

--- Set GameObject as the local or remote user
-- This must be called after building a new craft on entry or respawn
-- @param self GameObject instance
-- @param team new team number
function GameObject.SetAsUser(self, team)
    if not isgameobject(self) then error("Paramater self must be GameObject instance."); end
    if not isnumber(team) then error("Paramater amt must be number."); end
    SetAsUser(self:GetHandle(), team);
end

--==============================================================================================================================================================
-- Enums
--==============================================================================================================================================================

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

--==============================================================================================================================================================
-- Mission Core
--==============================================================================================================================================================

local CustomSavableTypes = {};
local CustomTypeMap = nil; -- maps name to ID number

function RegisterCustomSavableType(obj)
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

function Save()
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
    
    debugprint("Unpacking and returning Save Data Container");
    
    str = table.show(saveData);
    for s in str:gmatch("[^\r\n]+") do
        debugprint(s);
    end
    
    return saveData;
end

function Load(...)
    local args = ...;

    str = table.show(args);
    for s in str:gmatch("[^\r\n]+") do
        debugprint(s);
    end

    debugprint("Beginning load code");
    
    gameTurn = args.gameTurn;

    debugprint("Loading custom types map");
    CustomTypeMap = args.CustomSavableTypes
    debugprint("Loaded custom types map");
    
    debugprint("Loading custom types data");
    for idNum,data in ipairs(args.CustomSavableTypeData) do
        local entry = CustomSavableTypes[CustomTypeMap[idNum]];
        if entry.BulkLoad ~= nil and isfunction(entry.BulkLoad) then
            debugprint("Loaded " .. entry.TypeName);
            entry.BulkLoad(DeSimplifyForLoad(table.unpack(data)));
        end
    end
    debugprint("Loaded custom types data");
    
    debugprint("Game Object Data Start");
    for k,y in pairs(GameObjectAltered) do
      debugprint(tostring(k) .. " = " .. tostring(y));
    end
    debugprint("Game Object Data End");
    
    debugprint("Calling all hooked load functions");
    hook.CallLoad(DeSimplifyForLoad(table.unpack(args.HooksData)));
end

function PostLoad()
    debugprint("PostLoading custom types");
    for idNum,name in ipairs(CustomSavableTypeTmpTable) do
        local entry = CustomSavableTypes[name];
        if entry.BulkPostLoad ~= nil and isfunction(entry.BulkPostLoad) then
            debugprint("PostLoaded " .. entry.TypeName);
            SimplifyForSave(entry.BulkPostLoad());
        else
            debugprint("PostLoaded " .. entry.TypeName .. " (nothing to PostLoad)");
        end
    end
    debugprint("PostLoaded custom types");
    
    hook.CallPostLoad();
end

--- Called before the mission starts up. 
-- Preloading assets should be done here.
function InitialSetup()
    hook.CallAllNoReturn( "InitialSetup" );
end

--- Called when the mission starts for the first time.
-- Use this function to perform any one-time script initialization.
function Start()
    hook.CallAllNoReturn( "Start" );
end

--- Called after any game object is created.
-- Handle is the game object that was created.
-- This function will get a lot of traffic so it should not do too much work.
function AddObject(h)
    hook.CallAllNoReturn( "AddObject", GameObject.FromHandle(h) );
end

--- Called before a game object is deleted.
-- Handle is the game object to be deleted.
-- This function will get a lot of traffic so it should not do too much work.
function DeleteObject(h)
    local object = GameObject.FromHandle(h);
    hook.CallAllNoReturn( "DeleteObject", object );
    if GameObjectAltered[object:GetHandle()] ~= nil then GameObjectAltered[object:GetHandle()] = nil; end
end

local gameTurn = 0;
--- Called once per tick after updating the network system and before simulating game objects.
-- This function performs most of the mission script's game logic.
function Update()
    hook.CallAllNoReturn( "Update", gameTurn );
    gameTurn = gameTurn + 1;
end

--- Called when a player joins the game world.
function AddPlayer(id, team, isNewPlayer)
    --debugprint("AddPlayer");
    local retVal, stoppedEarly = hook.CallAllPassReturn("AddPlayer", id, team, isNewPlayer);
    if not isboolean(retVal) then retVal = true; end
    return retVal;
end

--- Called when a player leaves the game world.
function DeletePlayer(id)
    --debugprint("DeletePlayer");
    hook.CallAllNoReturn( "DeletePlayer", id );
end

--- Called when the player Ejects.
function PlayerEjected(DeadObjectHandle)
    --debugprint("PlayerEjected");
    local object = GameObject.FromHandle(DeadObjectHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PlayerEjected", object);
    if retVal == nil then retVal = EjectKillRetCodes.DoEjectPilot; end
    return retVal;
end

--- Called when an object is killed.
function ObjectKilled(DeadObjectHandle, KillersHandle)
    --debugprint("ObjectKilled");
    local object1 = GameObject.FromHandle(DeadObjectHandle);
    local object2 = GameObject.FromHandle(KillersHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("ObjectKilled", object1, object2);
    if retVal == nil then retVal = (object1:IsPlayer() and EjectKillRetCodes.DoEjectPilot or EjectKillRetCodes.DLLHandled); end
    return retVal;
end

--- Called when an object is sniped.
function ObjectSniped(DeadObjectHandle, KillersHandle)
    --debugprint("ObjectSniped");
    local object1 = GameObject.FromHandle(DeadObjectHandle);
    local object2 = GameObject.FromHandle(KillersHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("ObjectSniped", object1, object2);
    if retVal == nil then retVal = (object1:IsPlayer() and EjectKillRetCodes.DoGameOver or EjectKillRetCodes.DLLHandled); end
    return retVal;
end

--- Called when an ordnance hits an object. This technically happens just before any damage is applied. Also it only happens when the ordnance hits a vehicle or box/sphere collidable object. Objects that use collision mesh's are technically part of the terrain? sortof...
function PreOrdnanceHit(shooterHandle, victimHandle, ordnanceTeam, pOrdnanceODF)
    --debugprint("PreOrdnanceHit");
    local object1 = GameObject.FromHandle(shooterHandle);
    local object2 = GameObject.FromHandle(victimHandle);
    hook.CallAllNoReturn( "PreOrdnanceHit", object1, object2, ordnanceTeam, pOrdnanceODF );
end

--- Called when an object is Sniped. Occurs just before the snipe, and can be used to prevent it from happening.
function PreSnipe(curWorld, shooterHandle, victimHandle, ordnanceTeam, pOrdnanceODF)
    --debugprint("PreSnipe");
    local object1 = GameObject.FromHandle(shooterHandle);
    local object2 = GameObject.FromHandle(victimHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PreSnipe", curWorld, object1, object2, ordnanceTeam, pOrdnanceODF);
    if retVal == nil then retVal = PreSnipeReturnCodes.PRESNIPE_KILLPILOT; end
    return retVal;
end

--- Called when a pilot gets into a ship. Can be used to prevent it.
function PreGetIn(curWorld, pilotHandle, emptyCraftHandle)
    debugprint("PreGetIn");
    local object1 = GameObject.FromHandle(pilotHandle);
    local object2 = GameObject.FromHandle(emptyCraftHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PreGetIn", curWorld, object1, object2);
    if retVal == nil then retVal = PreGetInReturnCodes.PREGETIN_ALLOW; end
    return retVal;
end

--- Called when a powerup is picked up. Can be used to prevent it.
function PrePickupPowerup(curWorld, me, powerupHandle)
    --debugprint("PrePickupPowerup");
    local object1 = GameObject.FromHandle(me);
    local object2 = GameObject.FromHandle(powerupHandle);
    local retVal, stoppedEarly = hook.CallAllPassReturn("PrePickupPowerup", curWorld, object1, object2);
    if retVal == nil then retVal = PrePickupPowerupReturnCodes.PREPICKUPPOWERUP_ALLOW; end
    return retVal;
end

--- Called when the user? changes targets? Can be used to trigger events on a target change?
function PostTargetChangeCallback(craft, previousTarget, currentTarget)
    --debugprint("PostTargetChangeCallback");
    local object1 = GameObject.FromHandle(craft);
    local object2 = GameObject.FromHandle(previousTarget);
    local object3 = GameObject.FromHandle(currentTarget);
    hook.CallAllNoReturn( "PostTargetChangeCallback", object1, object2, object3 );
end

--- Called when an IFace command is triggered. Use CalcCRC(string) to determine the command from the crc value.
function ProcessCommand ( crc )
    hook.CallAllNoReturn( "ProcessCommand", crc );
end

--- Called every tick to set the Random seed used to sync GetRandomFloat across Multiworld.
function SetRandomSeed ( seed )
    hook.CallAllNoReturn( "SetRandomSeed", seed );
end

RegisterCustomSavableType(GameObject);

hook = require("_hook");

debugprint("_api Loaded");