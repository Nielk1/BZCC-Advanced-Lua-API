--- BZCC ScriptUtils Stub
--
-- Stubs for ScriptUtils LDoc
--
-- @module ScriptUtils

--- Default Matrix. North Facing with a position of 0, 0, 0.
-- 1 0 0
-- 0 1 0
-- 0 0 1
-- 0 0 0
-- @table IdentityMatrix
IdentityMatrix = {
    right_x = 1.000000, -- 1.000000
	right_y = 0.000000, -- 0.000000
	right_z = 0.000000, -- 0.000000
       up_x = 0.000000, -- 0.000000
	   up_y = 1.000000, -- 1.000000
	   up_z = 0.000000, -- 0.000000
    front_x = 0.000000, -- 0.000000
	front_y = 0.000000, -- 0.000000
	front_z = 1.000000, -- 1.000000
    posit_x = 0.000000, -- 0.000000
	posit_y = 0.000000, -- 0.000000
	posit_z = 0.000000  -- 0.000000
}

--- AiCommand
-- @table AiCommand
AiCommand = {
   [0] = "CMD_NONE"; -- CMD_NONE
   [1] = "CMD_SELECT"; -- CMD_SELECT
   [2] = "CMD_STOP"; -- CMD_STOP
   [3] = "CMD_GO"; -- CMD_GO
   [4] = "CMD_ATTACK"; -- CMD_ATTACK
   [5] = "CMD_FOLLOW"; -- CMD_FOLLOW
   [6] = "CMD_FORMATION"; -- CMD_FORMATION
   [7] = "CMD_PICKUP"; -- CMD_PICKUP
   [8] = "CMD_DROPOFF"; -- CMD_DROPOFF
   [9] = "CMD_UNDEPLOY"; -- CMD_UNDEPLOY
   [10] = "CMD_DEPLOY"; -- CMD_DEPLOY
   [11] = "CMD_NO_DEPLOY"; -- CMD_NO_DEPLOY
   [12] = "CMD_GET_REPAIR"; -- CMD_GET_REPAIR
   [13] = "CMD_GET_RELOAD"; -- CMD_GET_RELOAD
   [14] = "CMD_GET_WEAPON"; -- CMD_GET_WEAPON
   [15] = "CMD_GET_CAMERA"; -- CMD_GET_CAMERA
   [16] = "CMD_GET_BOMB"; -- CMD_GET_BOMB
   [17] = "CMD_DEFEND"; -- CMD_DEFEND
   [18] = "CMD_RESCUE"; -- CMD_RESCUE
   [19] = "CMD_RECYCLE"; -- CMD_RECYCLE
   [20] = "CMD_SCAVENGE"; -- CMD_SCAVENGE
   [21] = "CMD_HUNT"; -- CMD_HUNT
   [22] = "CMD_BUILD"; -- CMD_BUILD
   [23] = "CMD_PATROL"; -- CMD_PATROL
   [24] = "CMD_STAGE"; -- CMD_STAGE
   [25] = "CMD_SEND"; -- CMD_SEND
   [26] = "CMD_GET_IN"; -- CMD_GET_IN
   [27] = "CMD_LAY_MINES"; -- CMD_LAY_MINES
   [28] = "CMD_LOOK_AT"; -- CMD_LOOK_AT
   [29] = "CMD_SERVICE"; -- CMD_SERVICE
   [30] = "CMD_UPGRADE"; -- CMD_UPGRADE
   [31] = "CMD_DEMOLISH"; -- CMD_DEMOLISH
   [32] = "CMD_POWER"; -- CMD_POWER
   [33] = "CMD_BACK"; -- CMD_BACK
   [34] = "CMD_DONE"; -- CMD_DONE
   [35] = "CMD_CANCEL"; -- CMD_CANCEL
   [36] = "CMD_SET_GROUP"; -- CMD_SET_GROUP
   [37] = "CMD_SET_TEAM"; -- CMD_SET_TEAM
   [38] = "CMD_SEND_GROUP"; -- CMD_SEND_GROUP
   [39] = "CMD_TARGET"; -- CMD_TARGET
   [40] = "CMD_INSPECT"; -- CMD_INSPECT
   [41] = "CMD_SWITCHTEAM"; -- CMD_SWITCHTEAM
   [42] = "CMD_INTERFACE"; -- CMD_INTERFACE
   [43] = "CMD_LOGOFF"; -- CMD_LOGOFF
   [44] = "CMD_AUTOPILOT"; -- CMD_AUTOPILOT
   [45] = "CMD_MESSAGE"; -- CMD_MESSAGE
   [46] = "CMD_CLOSE"; -- CMD_CLOSE
   [47] = "CMD_MORPH_SETDEPLOYED"; -- CMD_MORPH_SETDEPLOYED
   [48] = "CMD_MORPH_SETUNDEPLOYED"; -- CMD_MORPH_SETUNDEPLOYED
   [49] = "CMD_MORPH_UNLOCK"; -- CMD_MORPH_UNLOCK
   [50] = "CMD_BAILOUT"; -- CMD_BAILOUT
   [51] = "CMD_BUILD_ROTATE"; -- CMD_BUILD_ROTATE
   [52] = "CMD_CMDPANEL_SELECT"; -- CMD_CMDPANEL_SELECT
   [53] = "CMD_CMDPANEL_DESELECT"; -- CMD_CMDPANEL_DESELECT
   ["CMD_NONE"] = 0; -- 0
   ["CMD_SELECT"] = 1; -- 1
   ["CMD_STOP"] = 2; -- 2
   ["CMD_GO"] = 3; -- 3
   ["CMD_ATTACK"] = 4; -- 4
   ["CMD_FOLLOW"] = 5; -- 5
   ["CMD_FORMATION"] = 6; -- 6
   ["CMD_PICKUP"] = 7; -- 7
   ["CMD_DROPOFF"] = 8; -- 8
   ["CMD_UNDEPLOY"] = 9; -- 9
   ["CMD_DEPLOY"] = 10; -- 10
   ["CMD_NO_DEPLOY"] = 11; -- 11
   ["CMD_GET_REPAIR"] = 12; -- 12
   ["CMD_GET_RELOAD"] = 13; -- 13
   ["CMD_GET_WEAPON"] = 14; -- 14
   ["CMD_GET_CAMERA"] = 15; -- 15
   ["CMD_GET_BOMB"] = 16; -- 16
   ["CMD_DEFEND"] = 17; -- 17
   ["CMD_RESCUE"] = 18; -- 18
   ["CMD_RECYCLE"] = 19; -- 19
   ["CMD_SCAVENGE"] = 20; -- 20
   ["CMD_HUNT"] = 21; -- 21
   ["CMD_BUILD"] = 22; -- 22
   ["CMD_PATROL"] = 23; -- 23
   ["CMD_STAGE"] = 24; -- 24
   ["CMD_SEND"] = 25; -- 25
   ["CMD_GET_IN"] = 26; -- 26
   ["CMD_LOOK_AT"] = 28; -- 28
   ["CMD_LAY_MINES"] = 27; -- 27
   ["CMD_SERVICE"] = 29; -- 29
   ["CMD_UPGRADE"] = 30; -- 30
   ["CMD_DEMOLISH"] = 31; -- 31
   ["CMD_POWER"] = 32; -- 32
   ["CMD_BACK"] = 33; -- 33
   ["CMD_DONE"] = 34; -- 34
   ["CMD_CANCEL"] = 35; -- 35
   ["CMD_SET_GROUP"] = 36; -- 36
   ["CMD_SET_TEAM"] = 37; -- 37
   ["CMD_SEND_GROUP"] = 38; -- 38
   ["CMD_TARGET"] = 39; -- 39
   ["CMD_INSPECT"] = 40; -- 40
   ["CMD_SWITCHTEAM"] = 41; -- 41
   ["CMD_INTERFACE"] = 42; -- 42
   ["CMD_LOGOFF"] = 43; -- 43
   ["CMD_AUTOPILOT"] = 44; -- 44
   ["CMD_MESSAGE"] = 45; -- 45
   ["CMD_CLOSE"] = 46; -- 46
   ["CMD_MORPH_SETDEPLOYED"] = 47; -- 47
   ["CMD_MORPH_SETUNDEPLOYED"] = 48; -- 48
   ["CMD_MORPH_UNLOCK"] = 49; -- 49
   ["CMD_BAILOUT"] = 50; -- 50
   ["CMD_BUILD_ROTATE"] = 51; -- 51
   ["CMD_CMDPANEL_SELECT"] = 52; -- 52
   ["CMD_CMDPANEL_DESELECT"] = 53; -- 53
};

--- Taunt Type Categories
-- @table TauntTypes
TauntTypes = {
   [0] = "TAUNTS_GameStart"; -- TAUNTS_GameStart
   [1] = "TAUNTS_NewHuman"; -- TAUNTS_NewHuman
   [2] = "TAUNTS_LeftHuman"; -- TAUNTS_LeftHuman
   [3] = "TAUNTS_HumanShipDestroyed"; -- TAUNTS_HumanShipDestroyed
   [4] = "TAUNTS_HumanRecyDestroyed"; -- TAUNTS_HumanRecyDestroyed
   [5] = "TAUNTS_CPURecyDestroyed"; -- TAUNTS_CPURecyDestroyed
   [6] = "TAUNTS_Random"; -- TAUNTS_Random
   [7] = "TAUNTS_Category7"; -- TAUNTS_Category7
   [8] = "TAUNTS_Category8"; -- TAUNTS_Category8
   [9] = "TAUNTS_Category9"; -- TAUNTS_Category9
   [10] = "TAUNTS_Category10"; -- TAUNTS_Category10
   [11] = "TAUNTS_Category11"; -- TAUNTS_Category11
   [12] = "TAUNTS_Category12"; -- TAUNTS_Category12
   [13] = "TAUNTS_Category13"; -- TAUNTS_Category13
   [14] = "TAUNTS_Category14"; -- TAUNTS_Category14
   [15] = "TAUNTS_Category15"; -- TAUNTS_Category15
   ["TAUNTS_GameStart"] = 0; -- 0
   ["TAUNTS_NewHuman"] = 1; -- 1
   ["TAUNTS_LeftHuman"] = 2; -- 2
   ["TAUNTS_HumanShipDestroyed"] = 3; -- 3
   ["TAUNTS_HumanRecyDestroyed"] = 4; -- 4
   ["TAUNTS_CPURecyDestroyed"] = 5; -- 5
   ["TAUNTS_Random"] = 6; -- 6
   ["TAUNTS_Category7"] = 7; -- 7
   ["TAUNTS_Category8"] = 8; -- 8
   ["TAUNTS_Category9"] = 9; -- 9
   ["TAUNTS_Category10"] = 10; -- 10
   ["TAUNTS_Category11"] = 11; -- 11
   ["TAUNTS_Category12"] = 12; -- 12
   ["TAUNTS_Category14"] = 14; -- 14
   ["TAUNTS_Category13"] = 13; -- 13
   ["TAUNTS_Category15"] = 15; -- 15
};

--- Deathmatch Sub Game Types. Values returned by ivar7.
-- @table DMSubGameTypes
DMSubGameTypes = {
   [0] = "DMSubtype_Normal"; -- DMSubtype_Normal
   [1] = "DMSubtype_KOH"; -- DMSubtype_KOH
   [2] = "DMSubtype_CTF"; -- DMSubtype_CTF
   [3] = "DMSubtype_Loot"; -- DMSubtype_Loot
   [4] = "DMSubtype_RESERVED1"; -- DMSubtype_RESERVED1
   [5] = "DMSubtype_Race1"; -- DMSubtype_Race1
   [6] = "DMSubtype_Race2"; -- DMSubtype_Race2
   [7] = "DMSubtype_Normal2"; -- DMSubtype_Normal2
   ["DMSubtype_Normal"] = 0; -- 0
   ["DMSubtype_KOH"] = 1; -- 1
   ["DMSubtype_CTF"] = 2; -- 2
   ["DMSubtype_Loot"] = 3; -- 3
   ["DMSubtype_RESERVED1"] = 4; -- 4
   ["DMSubtype_Race1"] = 5; -- 5
   ["DMSubtype_Race2"] = 6; -- 6
   ["DMSubtype_Normal2"] = 7; -- 7
};

--- Values returned by the PreSnipe function.
-- @table PreSnipeReturnValues
PreSnipeReturnValues = {
   [0] = "PRESNIPE_KILLPILOT"; -- PRESNIPE_KILLPILOT
   [1] = "PRESNIPE_ONLYBULLETHIT"; -- PRESNIPE_ONLYBULLETHIT
   ["PRESNIPE_KILLPILOT"] = 0; -- 0
   ["PRESNIPE_ONLYBULLETHIT"] = 1; -- 1
};

--- Values returned by the PreGetIn function.
-- @table PreGetInReturnValues
PreGetInReturnValues = {
   [0] = "PREGETIN_DENY"; -- PREGETIN_DENY
   [1] = "PREGETIN_ALLOW"; -- PREGETIN_ALLOW
   ["PREGETIN_DENY"] = 0; -- 0
   ["PREGETIN_ALLOW"] = 1; -- 1
};

--- Values returned by the PrePickupPowerup function.
-- @table PrePickupPowerupReturnValues
PrePickupPowerupReturnValues = {
   [0] = "PREPICKUPPOWERUP_DENY"; -- PREPICKUPPOWERUP_DENY
   [1] = "PREPICKUPPOWERUP_ALLOW"; -- PREPICKUPPOWERUP_ALLOW
   ["PREPICKUPPOWERUP_DENY"] = 0; -- 0
   ["PREPICKUPPOWERUP_ALLOW"] = 1; -- 1
};

--- Randomize Vehicle Types.
-- @table RandomizeTypes
RandomizeTypes = {
   [0] = "Randomize_None"; -- Randomize_None
   [1] = "Randomize_ByRace"; -- Randomize_ByRace
   [2] = "Randomize_Any"; -- Randomize_Any
   ["Randomize_None"] = 0; -- 0
   ["Randomize_ByRace"] = 1; -- 1
   ["Randomize_Any"] = 2; -- 2
};

--- Team Relationship Types. Comparable against the GetTeamRelationship function.
-- @table TeamRelationshipTypes
TeamRelationshipTypes = {
   [1] = "TEAMRELATIONSHIP_SAMETEAM"; -- TEAMRELATIONSHIP_SAMETEAM
   [2] = "TEAMRELATIONSHIP_ALLIEDTEAM"; -- TEAMRELATIONSHIP_ALLIEDTEAM
   [0] = "TEAMRELATIONSHIP_INVALIDHANDLE"; -- TEAMRELATIONSHIP_INVALIDHANDLE
   [3] = "TEAMRELATIONSHIP_ENEMYTEAM"; -- TEAMRELATIONSHIP_ENEMYTEAM
   ["TEAMRELATIONSHIP_ENEMYTEAM"] = 3; -- 3
   ["TEAMRELATIONSHIP_ALLIEDTEAM"] = 2; -- 2
   ["TEAMRELATIONSHIP_SAMETEAM"] = 1; -- 1
   ["TEAMRELATIONSHIP_INVALIDHANDLE"] = 0; -- 0
};