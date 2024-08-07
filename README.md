# Battlezone: Combat Commander - Advanced Lua API

## Documentation
[via github.io](https://nielk1.github.io/BZCC-Advanced-Lua-API/)

## Examples

```lua
debugprint = print; -- several modules will call debugprint if it exists
--traceprint = print; -- modules may have an even more intensive print called traceprint
IFace_SetInteger("console.log", 1); -- this will log a lot more stuff to our log file

-- patch BZCC's loader so we can properly require lua files from the asset system
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

require("_printfix"); -- make newlines work when logging to console
require("_table_show"); -- this module can convert tables to strings

-- This is our API wrapper.
-- It will supply implementations for all the functions BZCC calls. These implementations will wrap handles in GameObjects for us.
-- These implementations will fire hooks via an observer pattern so we can implement multiple scripts ontop of this one.
-- You normally don't need to store the module return in a variable unless you want to use functions like RegisterCustomSavableType.
local api = require("_api");

local hook = require("_hook"); -- contains functions for the central event bus, was already loaded by _api but we need the function table
require("_gameobject"); -- puts functions like isgameobject into global, though they're probably already there from loading _api

require("_api_replaceondeath"); -- example extension module, self contained logic that works off ODF values
require("_api_editor_tunnelfix"); -- example extension module, attempts to fix tunnel alignment

-- hooks to the save/load/postload system to demonstrate multiple hooks
hook.AddSaveLoad("Test1", function() return 1; end, function(savedData) print("1: ".. savedData); end, nil);
hook.AddSaveLoad("Test2", function() return 2; end, function(savedData) print("2: ".. savedData); end, nil);
hook.AddSaveLoad("Test3", function() return 3; end, function(savedData) print("3: ".. savedData); end, nil);
hook.AddSaveLoad("Test4", function() return 4; end, function(savedData) print("4: ".. savedData); end, nil);
hook.AddSaveLoad("Test5", function() return 5; end, function(savedData) print("5: ".. savedData); end, nil);
hook.AddSaveLoad("Test6", function() return GetPlayerGameObject(1); end, function(savedData) print(table.show(savedData)); end, nil);

-- hook to demonstrate storing data inside GameObjects
hook.Add("AddObject", "Test7", function(object)
    if math.floor(GetRandomFloat(5)) == 0 then
        -- for the sake of testing (don't do this normally)
        -- let's save the ODF name of random objects into their GameObject
        -- this proves our system to save arbitrary data in a GameObject works
        object.odf = object:GetOdf();
        print("Loading Object ".. object.odf);
    end
end);
```
