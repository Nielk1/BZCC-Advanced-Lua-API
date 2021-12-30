--- BZCC LUA Extended API MapData.
-- 
-- Functions for accessing map file data.
-- Note this data is lazy-loaded, call the module function to force load.
-- 
-- @module _mapdata
-- @author John "Nielk1" Klein
-- @alias mapdata
-- @usage local mapdata = require("_mapdata");
-- 
-- print("Map BZN: " .. mapdata.BznFile);
-- print("Map TRN: " .. mapdata.TrnFile);
-- print("Map TER: " .. mapdata.TerFile);
-- print("Map Version: " .. mapdata.Version);
-- print("Map Meters per Quarter: " .. mapdata.MetersPerQuarter);
-- print("Map Meters per Grid: " .. mapdata.MetersPerGrid);
-- print("Map Meters per Cluster: " .. mapdata.MetersPerCluster);
-- print("Map Width: " .. (mapdata.MaxX - mapdata.MinX));
-- print("Map Depth: " .. (mapdata.MaxZ - mapdata.MinZ));

local debugprint = debugprint or function() end;

debugprint("_mapdata Loading");

local _api = require("_api");
local hook = require("_hook");

--- BZN filename with extension.
-- @string BznFile

--- TRN filename with extension.
-- @string TrnFile

--- TER filename with extension.
-- @string TerFile

--- Version of TER file.
--
-- Version 3 is a BZ2 TER upgraded on load.
--
-- Version 4 is a BZCC TER without compression.
--
--- version 5 is a BZCC TER with compression.
-- @int Version

--- Meters per quarter of a terrain cluster.
--
-- This is [Size]:MetersPerGrid from the TRN
-- @number MetersPerQuarter

--- Meters per terrain grid vertex.
-- @number MetersPerGrid

--- Meters per terrain cluster.
-- @number MetersPerCluster

--- Force immediate loading of all fields and return table of fields.
--
-- Calling the module as a function forces all field values to load immediately rather than lazily.
-- The module's table is returned with all fields decorated for ease use of this function.
-- @function __call
-- @treturn table
local mapdata = {};

--- Get play area polygon.
-- Triggers "MapData:GetPlayArea" event.
-- treturn table
function mapdata.GetPlayArea()
    local edge_path = GetPathPoints("edge_path");
    local retVal = nil;
    if edge_path ~= nil then
        local MinX = 99999;
        local MaxX = -99999;
        local MinZ = 99999;
        local MaxZ = -99999;
        for _, point in ipairs(edge_path) do
            if point.x < MinX then MinX = point.x end
            if point.x > MaxX then MaxX = point.x end
            if point.z < MinX then MinZ = point.z end
            if point.z > MaxX then MaxZ = point.z end
        end
        
        -- this is the same padding the game uses
        MinX = MinX + 10;
        MaxX = MaxX - 10;
        MinZ = MinZ + 10;
        MaxZ = MaxZ - 10;
        
        retVal = { SetVector(MinX, 0, MinZ),
                   SetVector(MinX, 0, MaxZ),
                   SetVector(MaxX, 0, MaxZ),
                   SetVector(MaxX, 0, MinZ) };
    end
    if retVal == nil then
        -- this is the same padding the game uses
        local MinX = mapdata.MinX + 5;
        local MaxX = mapdata.MaxX - 5;
        local MinZ = mapdata.MinZ + 5;
        local MaxZ = mapdata.MaxZ - 5;
        
        retVal = { SetVector(MinX, 0, MinZ),
                   SetVector(MinX, 0, MaxZ),
                   SetVector(MaxX, 0, MaxZ),
                   SetVector(MaxX, 0, MinZ) };
    end
    -- implementers of this function need to have 2 paramaters, where the first is the
    -- path we provided, and the 2nd is an overriding path from another hook implementer
    local hookResult = hook.CallAllPassReturn("MapData:GetPlayArea", retVal);
    if hookResult ~= nil then
        return hookResult;
    end
    return retVal;
end

function read_i16(b1, b2)
    assert(0 <= b1 and b1 <= 0xff);
    assert(0 <= b2 and b2 <= 0xff);
    local mask = bit32.lshift(1, 15);
    local res  = bit32.bor(bit32.lshift(b1, 8), bit32.lshift(b2, 0));
    return bit32.bxor(res, mask) - mask;
end

local mapLoaded = false;
local mapLoadFailed = false;

function LoadBznFile(table)
    if rawget(table, "BznFile") == nil then
        rawset(table, "BznFile", GetMissionFilename());
    end
    return rawget(table, "BznFile");
end
function LoadTrnFile(table)
    if rawget(table, "TrnFile") == nil then
        rawset(table, "TrnFile", GetMapTRNFilename());
    end
    return rawget(table, "TrnFile");
end
function LoadTerFile(table)
    if rawget(table, "TerFile") == nil then
        rawset(table, "TerFile", table.TrnFile:gsub("%.[Tt][Rr][Nn]$",".ter"));
    end
    return rawget(table, "TerFile");
end
function LoadMetersPerQuarter(table)
    if rawget(table, "MetersPerQuarter") == nil then
        rawset(table, "MetersPerQuarter", GetODFFloat(table.TrnFile, "Size", "MetersPerGrid", 8));
    end
    return rawget(table, "MetersPerQuarter");
end
function LoadMetersPerGrid(table)
    if rawget(table, "MetersPerGrid") == nil then
        rawset(table, "MetersPerGrid", table.MetersPerQuarter / 4);
    end
    return rawget(table, "MetersPerGrid");
end
function LoadMetersPerCluster(table)
    if rawget(table, "MetersPerCluster") == nil then
        rawset(table, "MetersPerCluster", table.MetersPerQuarter * 4);
    end
    return rawget(table, "MetersPerCluster");
end
function LoadBinaryMapData(table)
    assert(not mapLoadFailed, "Map data failed to load");
    if not mapLoaded then
        local ter_content = LoadFile(table.TerFile);
        if ter_content:sub(1,4) == "TERR" then
            local bytes = {string.byte(ter_content,1,16)};
            rawset(table,"Version",(((((bytes[8] * 256) + bytes[7]) * 256) + bytes[6]) * 256) + (bytes[5]));
            rawset(table,"MinX",read_i16(bytes[10], bytes[ 9]) * table.MetersPerQuarter);
            rawset(table,"MinZ",read_i16(bytes[12], bytes[11]) * table.MetersPerQuarter);
            rawset(table,"MaxX",read_i16(bytes[14], bytes[13]) * table.MetersPerQuarter);
            rawset(table,"MaxZ",read_i16(bytes[16], bytes[15]) * table.MetersPerQuarter);
        else
            mapLoadFailed = true; -- the map data failed to load, make sure we don't keep trying
        end
    end
    assert(not mapLoadFailed, "Map data failed to load");
end

mapdata_meta = {};

mapdata_meta.__index = function(table, key)
    if key == "BznFile" then return LoadBznFile(table); end
    if key == "TrnFile" then return LoadTrnFile(table); end
    if key == "TerFile" then return LoadTerFile(table); end
    if key == "MetersPerQuarter" then return LoadMetersPerQuarter(table); end
    if key == "MetersPerGrid" then return LoadMetersPerGrid(table); end
    if key == "MetersPerCluster" then return MetersPerCluster(table); end
    if not mapLoaded and (key == "Version" or key == "MinX" or key == "MinZ" or key == "MaxX" or key == "MaxZ") then
        LoadBinaryMapData(table);
        return rawget(table, key); -- now exists
    end
    return rawget(mapdata_meta, key); -- move on to base (looking for functions)
end
mapdata_meta.__newindex = function(dtable, key, value)
    error("Attempt to update a read-only table.", 2)
end
mapdata_meta.__call = function(table) 
    LoadBznFile(table);
    LoadTrnFile(table);
    LoadTerFile(table);
    LoadMetersPerQuarter(table);
    LoadMetersPerGrid(table);
    LoadMetersPerCluster(table);
    LoadBinaryMapData(table);
    return table;
end

mapdata_meta.__type = "MapData";

mapdata = setmetatable(mapdata, mapdata_meta);

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MapData - Core
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- @section

--- Load event function.
-- INTERNAL USE.
-- We only saved a marker of our type and nothing else, so on load we just restore ourself to our global self, via module self-requiring
-- @param data
function mapdata_meta.Load(data)
    local mapdata = require("_mapdata");
    return mapdata;
end

_api.RegisterCustomSavableType(mapdata_meta);

debugprint("_mapdata Loaded");

return mapdata;