#include "script_component.hpp"

ADDON = false;

#include "XEH_PREP.hpp"

// The view of the ammunition tab picked in the sort list (fnc_arsenalViews): "fitting", "round", "pack", "belt" or "all".
GVAR(arsenalView) = "fitting";
GVAR(viewsBusy) = false;

// A tab of its own in ACE Arsenal, which takes these items out of its Misc list. Other mods' items join it with
// gmr_arsenal = 1 in their config (ammo cans, bandoliers and the like); ACE keeps only those that are misc items.
private _items = [
    #include "\z\gmr\addons\items\cfg\public_classes.hpp"
];

{
    _items append ((toString {getNumber (_x >> "gmr_arsenal") == 1 && {getNumber (_x >> "scope") == 2}} configClasses (configFile >> _x)) apply {configName _x});
} forEach ["CfgWeapons", "CfgMagazines"];

GVAR(arsenalSlot) = [
    _items arrayIntersect _items,
    LLSTRING(ArsenalTab),
    QPATHTOF(data\action_ammo.paa),
    -1,
    true
] call ace_arsenal_fnc_addRightPanelButton;

ADDON = true;
