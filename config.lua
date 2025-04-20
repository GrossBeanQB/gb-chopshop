Config = {}

Config.ChopLocations = {
    vector4(1980.87, 5173.5, 47.02, 311.37),
    vector4(221.25, 2580.03, 45.85, 100.11),
    vector4(583.47, -2807.12, 6.06, 62.07)
}

-- NPC
Config.NPCLocation = vector4(-511.78, -1747.44, 19.24, 236.36)

-- Vehicle Locations
Config.VehicleSpawnLocations = {
    vector4(-1698.86, -915.86, 7.7, 139.19),
    vector4(-2316.24, 280.03, 169.47, 24.58),
    vector4(1328.57, -1511.29, 51.96, 171.61),
    vector4(1013.26, -2485.66, 28.29, 153.84),
    vector4(1275.31, -3114.97, 5.9, 267.15),
    vector4(-326.89, -1348.79, 31.35, 91.77)
}

-- Vehicles
Config.ChopVehicles = {
    "ninef", "ninef2", "banshee", "alpha", "baller", "bison",
    "huntley", "f620", "asea", "pigalle", "bullet", "turismor",
    "zentorno", "dominator", "blade", "chino", "sabregt", "bati",
    "carbonrs", "akuma", "thrust", "exemplar", "felon", "sentinel",
    "blista", "fusilade", "jackal", "blista2", "rocoto", "seminole",
    "landstalker", "picador", "prairie", "bobcatxl", "gauntlet",
    "virgo", "fq2", "jester", "rhapsody", "feltzer2", "buffalo",
    "buffalo2", "stretch", "ratloader2", "ruiner", "rebel",
    "slamvan", "zion", "zion2", "tampa", "sultan", "asbo",
    "panto", "oracle", "oracle2", "sentinel2", "baller2",
    "schafter2", "schwarzer", "cavalcade", "cavalcade2",
    "comet2", "serrano", "tailgater", "sandking", "sandking2",
    "cognoscenti", "stanier", "washington"
}

Config.ChopBones = {
    ["wheel_lf"] = {label = "Front Left Tire", reward = "rubber", min = 1, max = 3},
    ["wheel_rf"] = {label = "Front Right Tire", reward = "rubber", min = 1, max = 3},
    ["wheel_lr"] = {label = "Rear Left Tire", reward = "rubber", min = 1, max = 3},
    ["wheel_rr"] = {label = "Rear Right Tire", reward = "rubber", min = 1, max = 3},
    ["door_dside_f"] = {label = "Front Left Door", reward = {"electronic_parts", "metalscrap"}, min = {1, 2}, max = {3, 4}},
    ["door_dside_r"] = {label = "Rear Left Door", reward = {"electronic_parts", "metalscrap"}, min = {1, 2}, max = {3, 4}},
    ["door_pside_f"] = {label = "Front Right Door", reward = {"electronic_parts", "metalscrap"}, min = {1, 2}, max = {3, 4}},
    ["door_pside_r"] = {label = "Rear Right Door", reward = {"electronic_parts", "metalscrap"}, min = {1, 2}, max = {3, 4}},
    ["bonnet"] = {label = "Hood", reward = "metalscrap", min = 2, max = 4},
    ["boot"] = {label = "Trunk", reward = "metalscrap", min = 2, max = 4}
}

Config.FinalizeChopReward = {min = 350, max = 850, item = "cash"}
