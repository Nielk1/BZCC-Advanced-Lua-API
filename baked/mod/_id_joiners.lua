--- BZCC LUA Extended API Log Joiner IDs Extension.
--
-- Log the Steam and GOG IDs of game joiners.
--
-- Dependencies: `_hook`, `_api`
-- @module _id_joiners
-- @author John "Nielk1" Klein

debugprint = debugprint or function() end;

debugprint("_id_joiners Loading");

local hook = require("_hook");

hook.Add("Start", "ID_Joiners_Start", function()
    print("GetDPIDOfTeam(1) = " .. GetDPIDOfTeam(1));
    print("GetTeamForDPID(GetLocalPlayerDPID()) = " .. GetTeamForDPID(GetLocalPlayerDPID()));
    print("GetPlayerPlatformID(GetLocalPlayerDPID()) = " .. GetPlayerPlatformID(GetLocalPlayerDPID()));
end);

hook.Add("AddPlayer", "ID_Joiners_AddPlayer", function(id, team, isNewPlayer)
    print("GetDPIDOfTeam(" .. team .. ") = " .. GetDPIDOfTeam(team));
    print("id = " .. id);
    print("GetTeamForDPID(GetDPIDOfTeam(" .. team .. ")) = " .. GetTeamForDPID(GetDPIDOfTeam(team)));
    print("team = " .. team);
    print("GetPlayerPlatformID(GetDPIDOfTeam(" .. team .. ")) = " .. GetPlayerPlatformID(GetDPIDOfTeam(team)))
end);

hook.Add("DeletePlayer", "ID_Joiners_DeletePlayer", function(id)
    print("id = " .. id);
    print("GetTeamForDPID(" .. id .. ") = " .. GetTeamForDPID(id));
    print("GetPlayerPlatformID(" .. id .. ") = " .. GetPlayerPlatformID(id));
end);

debugprint("_id_joiners Loaded");