# Battlezone: Combat Commander - Advanced Lua API

## Documentation
[via htmlpreview.github.io](http://htmlpreview.github.io/?https://github.com/Nielk1/BZCC-Advanced-Lua-API/blob/master/doc/index.html)
or
[via rawgit.com](https://cdn.rawgit.com/Nielk1/BZCC-Advanced-Lua-API/03360977/doc/index.html)

## Examples

```lua
assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

IFace_SetInteger("console.log", 1);

require("_printfix");
debugprint = print;

require("_table_show");
require("_api");
require("_api_replaceondeath");
require("_api_editor_tunnelfix");

hook.AddSaveLoad("Test1", function() return 1; end, function(savedData) print("1: ".. savedData); end, nil);
hook.AddSaveLoad("Test2", function() return 2; end, function(savedData) print("2: ".. savedData); end, nil);
hook.AddSaveLoad("Test3", function() return 3; end, function(savedData) print("3: ".. savedData); end, nil);
hook.AddSaveLoad("Test4", function() return 4; end, function(savedData) print("4: ".. savedData); end, nil);
hook.AddSaveLoad("Test5", function() return 5; end, function(savedData) print("5: ".. savedData); end, nil);
hook.AddSaveLoad("Test6", function() return GetPlayerGameObject(1); end, function(savedData) print(table.show(savedData)); end, nil);

hook.Add("AddObject", "Test6", function(object)
    if math.floor(GetRandomFloat(5)) == 0 then
        -- for the sake of testing (don't do this normally)
        -- let's save the ODF name of random objects into their GameObject
        -- this proves our system to save arbitrary data in a GameObject works
        object.odf = object:GetOdf();
        print("Loading Object ".. object.odf);
    end
end);
```
