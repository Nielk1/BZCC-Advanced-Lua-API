--- BZCC ScriptUtils Stub
--
-- Stubs for ScriptUtils LDoc
--
-- @module ScriptUtils

-- Default Matrix. North Facing with a position of 0, 0, 0.
-- @table IdentityMatrix
IdentityMatrix = {
    right_x=1.000000, right_y=0.000000, right_z=0.000000,
       up_x=0.000000,    up_y=1.000000,    up_z=0.000000,
    front_x=0.000000, front_y=0.000000, front_z=1.000000,
    posit_x=0.000000, posit_y=0.000000, posit_z=0.000000
}

--- AiCommand
-- @table AiCommand
AiCommand = {
   [0] = "CMD_NONE";
   [1] = "CMD_SELECT";
   [2] = "CMD_STOP";
   [3] = "CMD_GO";
   [4] = "CMD_ATTACK";
   [5] = "CMD_FOLLOW";
   [6] = "CMD_FORMATION";
   [7] = "CMD_PICKUP";
   [8] = "CMD_DROPOFF";
   [9] = "CMD_UNDEPLOY";
   [10] = "CMD_DEPLOY";
   [11] = "CMD_NO_DEPLOY";
   [12] = "CMD_GET_REPAIR";
   [13] = "CMD_GET_RELOAD";
   [14] = "CMD_GET_WEAPON";
   [15] = "CMD_GET_CAMERA";
   [16] = "CMD_GET_BOMB";
   [17] = "CMD_DEFEND";
   [18] = "CMD_RESCUE";
   [19] = "CMD_RECYCLE";
   [20] = "CMD_SCAVENGE";
   [21] = "CMD_HUNT";
   [22] = "CMD_BUILD";
   [23] = "CMD_PATROL";
   [24] = "CMD_STAGE";
   [25] = "CMD_SEND";
   [26] = "CMD_GET_IN";
   [27] = "CMD_LAY_MINES";
   [28] = "CMD_LOOK_AT";
   [29] = "CMD_SERVICE";
   [30] = "CMD_UPGRADE";
   [31] = "CMD_DEMOLISH";
   [32] = "CMD_POWER";
   [33] = "CMD_BACK";
   [34] = "CMD_DONE";
   [35] = "CMD_CANCEL";
   [36] = "CMD_SET_GROUP";
   [37] = "CMD_SET_TEAM";
   [38] = "CMD_SEND_GROUP";
   [39] = "CMD_TARGET";
   [40] = "CMD_INSPECT";
   [41] = "CMD_SWITCHTEAM";
   [42] = "CMD_INTERFACE";
   [43] = "CMD_LOGOFF";
   [44] = "CMD_AUTOPILOT";
   [45] = "CMD_MESSAGE";
   [46] = "CMD_CLOSE";
   [47] = "CMD_MORPH_SETDEPLOYED";
   [48] = "CMD_MORPH_SETUNDEPLOYED";
   [49] = "CMD_MORPH_UNLOCK";
   [50] = "CMD_BAILOUT";
   [51] = "CMD_BUILD_ROTATE";
   [52] = "CMD_CMDPANEL_SELECT";
   [53] = "CMD_CMDPANEL_DESELECT";
   ["CMD_NONE"] = 0;
   ["CMD_SELECT"] = 1;
   ["CMD_STOP"] = 2;
   ["CMD_GO"] = 3;
   ["CMD_ATTACK"] = 4;
   ["CMD_FOLLOW"] = 5;
   ["CMD_FORMATION"] = 6;
   ["CMD_PICKUP"] = 7;
   ["CMD_DROPOFF"] = 8;
   ["CMD_UNDEPLOY"] = 9;
   ["CMD_DEPLOY"] = 10;
   ["CMD_NO_DEPLOY"] = 11;
   ["CMD_GET_REPAIR"] = 12;
   ["CMD_GET_RELOAD"] = 13;
   ["CMD_GET_WEAPON"] = 14;
   ["CMD_GET_CAMERA"] = 15;
   ["CMD_GET_BOMB"] = 16;
   ["CMD_DEFEND"] = 17;
   ["CMD_RESCUE"] = 18;
   ["CMD_RECYCLE"] = 19;
   ["CMD_SCAVENGE"] = 20;
   ["CMD_HUNT"] = 21;
   ["CMD_BUILD"] = 22;
   ["CMD_PATROL"] = 23;
   ["CMD_STAGE"] = 24;
   ["CMD_SEND"] = 25;
   ["CMD_GET_IN"] = 26;
   ["CMD_LOOK_AT"] = 28;
   ["CMD_LAY_MINES"] = 27;
   ["CMD_SERVICE"] = 29;
   ["CMD_UPGRADE"] = 30;
   ["CMD_DEMOLISH"] = 31;
   ["CMD_POWER"] = 32;
   ["CMD_BACK"] = 33;
   ["CMD_DONE"] = 34;
   ["CMD_CANCEL"] = 35;
   ["CMD_SET_GROUP"] = 36;
   ["CMD_SET_TEAM"] = 37;
   ["CMD_SEND_GROUP"] = 38;
   ["CMD_TARGET"] = 39;
   ["CMD_INSPECT"] = 40;
   ["CMD_SWITCHTEAM"] = 41;
   ["CMD_INTERFACE"] = 42;
   ["CMD_LOGOFF"] = 43;
   ["CMD_AUTOPILOT"] = 44;
   ["CMD_MESSAGE"] = 45;
   ["CMD_CLOSE"] = 46;
   ["CMD_MORPH_SETDEPLOYED"] = 47;
   ["CMD_MORPH_SETUNDEPLOYED"] = 48;
   ["CMD_MORPH_UNLOCK"] = 49;
   ["CMD_BAILOUT"] = 50;
   ["CMD_BUILD_ROTATE"] = 51;
   ["CMD_CMDPANEL_SELECT"] = 52;
   ["CMD_CMDPANEL_DESELECT"] = 53;
};

-- Taunt Type Categories
-- @table TauntTypes
TauntTypes = {
   [0] = "TAUNTS_GameStart";
   [1] = "TAUNTS_NewHuman";
   [2] = "TAUNTS_LeftHuman";
   [3] = "TAUNTS_HumanShipDestroyed";
   [4] = "TAUNTS_HumanRecyDestroyed";
   [5] = "TAUNTS_CPURecyDestroyed";
   [6] = "TAUNTS_Random";
   [7] = "TAUNTS_Category7";
   [8] = "TAUNTS_Category8";
   [9] = "TAUNTS_Category9";
   [10] = "TAUNTS_Category10";
   [11] = "TAUNTS_Category11";
   [12] = "TAUNTS_Category12";
   [13] = "TAUNTS_Category13";
   [14] = "TAUNTS_Category14";
   [15] = "TAUNTS_Category15";
   ["TAUNTS_GameStart"] = 0;
   ["TAUNTS_NewHuman"] = 1;
   ["TAUNTS_LeftHuman"] = 2;
   ["TAUNTS_HumanShipDestroyed"] = 3;
   ["TAUNTS_HumanRecyDestroyed"] = 4;
   ["TAUNTS_CPURecyDestroyed"] = 5;
   ["TAUNTS_Random"] = 6;
   ["TAUNTS_Category7"] = 7;
   ["TAUNTS_Category8"] = 8;
   ["TAUNTS_Category9"] = 9;
   ["TAUNTS_Category10"] = 10;
   ["TAUNTS_Category11"] = 11;
   ["TAUNTS_Category12"] = 12;
   ["TAUNTS_Category14"] = 14;
   ["TAUNTS_Category13"] = 13;
   ["TAUNTS_Category15"] = 15;
};

-- Deathmatch Sub Game Types. Values returned by ivar7.
-- @table DMSubGameTypes
DMSubGameTypes = {
   [0] = "DMSubtype_Normal";
   [1] = "DMSubtype_KOH";
   [2] = "DMSubtype_CTF";
   [3] = "DMSubtype_Loot";
   [4] = "DMSubtype_RESERVED1";
   [5] = "DMSubtype_Race1";
   [6] = "DMSubtype_Race2";
   [7] = "DMSubtype_Normal2";
   ["DMSubtype_Normal"] = 0;
   ["DMSubtype_KOH"] = 1;
   ["DMSubtype_CTF"] = 2;
   ["DMSubtype_Loot"] = 3;
   ["DMSubtype_RESERVED1"] = 4;
   ["DMSubtype_Race1"] = 5;
   ["DMSubtype_Race2"] = 6;
   ["DMSubtype_Normal2"] = 7;
};

-- Values returned by the PreSnipe function.
-- @table PreSnipeReturnValues
PreSnipeReturnValues = {
   [0] = "PRESNIPE_KILLPILOT";
   [1] = "PRESNIPE_ONLYBULLETHIT";
   ["PRESNIPE_KILLPILOT"] = 0;
   ["PRESNIPE_ONLYBULLETHIT"] = 1;
};

-- Values returned by the PreGetIn function.
-- @table PreGetInReturnValues
PreGetInReturnValues = {
   [0] = "PREGETIN_DENY";
   [1] = "PREGETIN_ALLOW";
   ["PREGETIN_DENY"] = 0;
   ["PREGETIN_ALLOW"] = 1;
};

-- Values returned by the PrePickupPowerup function.
-- @table PrePickupPowerupReturnValues
PrePickupPowerupReturnValues = {
   [0] = "PREPICKUPPOWERUP_DENY";
   [1] = "PREPICKUPPOWERUP_ALLOW";
   ["PREPICKUPPOWERUP_DENY"] = 0;
   ["PREPICKUPPOWERUP_ALLOW"] = 1;
};

-- Randomize Vehicle Types.
-- @table RandomizeTypes
RandomizeTypes = {
   [0] = "Randomize_None";
   [1] = "Randomize_ByRace";
   [2] = "Randomize_Any";
   ["Randomize_None"] = 0;
   ["Randomize_ByRace"] = 1;
   ["Randomize_Any"] = 2;
};

-- Team Relationship Types. Comparable against the GetTeamRelationship function.
-- @table TeamRelationshipTypes
TeamRelationshipTypes = {
   [1] = "TEAMRELATIONSHIP_SAMETEAM";
   [2] = "TEAMRELATIONSHIP_ALLIEDTEAM";
   [0] = "TEAMRELATIONSHIP_INVALIDHANDLE";
   [3] = "TEAMRELATIONSHIP_ENEMYTEAM";
   ["TEAMRELATIONSHIP_ENEMYTEAM"] = 3;
   ["TEAMRELATIONSHIP_ALLIEDTEAM"] = 2;
   ["TEAMRELATIONSHIP_SAMETEAM"] = 1;
   ["TEAMRELATIONSHIP_INVALIDHANDLE"] = 0;
};