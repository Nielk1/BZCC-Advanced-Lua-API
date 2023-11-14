--- BZCC LUA Extended API Require Fix.
-- 
-- Repairs lua loader to look in game assets.
-- 
-- @module _requirefix
-- @author John "Nielk1" Klein
-- @usage assert(load(assert(LoadFile("_requirefix.lua")),"_requirefix.lua"))();

local debugprint = debugprint or function() end;

debugprint("_requirefix Loading");

if (type(LuaMissionFeatures) == 'table') and (LuaMissionFeatures.RequireFix or 0) > 0 then
    debugprint("_requirefix Skipped");
    return;
end

table.insert(package.searchers, 2, function(modulename)
    local errmsg = "";
    local filename = modulename .. ".lua";
    if DoesFileExist(filename) then
        return assert(load(assert(LoadFile(filename)),filename));
    else
        errmsg = errmsg.."\n\tno asset '"..filename .. "'";
    end
    return errmsg;
end);

debugprint("_requirefix Loaded");