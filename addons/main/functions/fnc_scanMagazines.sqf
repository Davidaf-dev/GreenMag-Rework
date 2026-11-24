#include "..\script_component.hpp"
/*
 * Author: Miss Heda
 * Looks through every magazine of the loaded mods and lists the ones that fire bullets but have no caliber this mod
 * recognises. Where another, recognised magazine fires the same ammo, its caliber is suggested. The result is a ready
 * "Ammo rules" line: written to the RPT, and in singleplayer or on the host also copied to the clipboard, to paste into
 * the server setting.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * [ammo rules with a suggestion <STRING>, magazines without one <ARRAY of STRING>] <ARRAY>
 *
 * Example:
 * call gmr_main_fnc_scanMagazines;
 *
 * Public: Yes
 */

private _bullets = [];

{
    private _class = configName _x;
    private _ammoConfig = configFile >> "CfgAmmo" >> getText (_x >> "ammo");

    if (
        getNumber (_x >> "scope") >= 1
        && {getNumber (_x >> "count") > 0}
        && {(toLowerANSI _class select [0, 4]) != "gmr_"}
        && {getNumber (_x >> "gmr_disabled") != 1}
        && {private _key = toLowerANSI _class; (GVAR(excludedList) findIf {_x in _key}) < 0}
        && {(toLowerANSI getText (_ammoConfig >> "simulation")) in ["shotbullet", "shotspread"]}
    ) then {
        _bullets pushBack [_class, toLowerANSI getText (_x >> "ammo"), (_class call FUNC(magazineInfo)) select MAG_CALIBER];
    };
} forEach ("true" configClasses (configFile >> "CfgMagazines"));

// The caliber recognised magazines give each ammo class.
private _byAmmo = createHashMap;

{
    _x params ["", "_ammo", "_caliber"];

    if (_caliber isNotEqualTo "" && {_caliber != "universal"}) then {
        _byAmmo set [_ammo, _caliber, true];
    };
} forEach _bullets;

private _rules = [];
private _unknown = [];
private _lines = [];

{
    _x params ["_class", "_ammo", "_caliber"];

    if (_caliber isEqualTo "") then {
        private _guess = _byAmmo getOrDefault [_ammo, ""];
        private _source = configSourceMod (configFile >> "CfgMagazines" >> _class);

        if (_guess isEqualTo "") then {
            _unknown pushBack _class;
            _lines pushBack format ["    %1: ?   (ammo %2, mod %3)", _class, _ammo, _source];
        } else {
            _rules pushBack format ["%1: %2", _class, _guess];
            _lines pushBack format ["    %1: %2   (same ammo as a known magazine, mod %3)", _class, _guess, _source];
        };
    };
} forEach _bullets;

private _ruleText = _rules joinString ", ";

INFO_3("Magazine scan: %1 magazines fire bullets, %2 without a caliber, %3 of them with a suggestion.",count _bullets,count _rules + count _unknown,count _rules);
{diag_log text _x} forEach _lines;
diag_log text "Ammo rules line:";
diag_log text _ruleText;

private _copied = false;

if (isServer) then {
    private _clip = _ruleText;

    if (_unknown isNotEqualTo []) then {
        _clip = _clip + endl + endl + "// No suggestion, set a caliber from addons/items/cfg/calibers.hpp:" + endl
            + ((_unknown apply {format ["%1: ?", _x]}) joinString endl);
    };

    copyToClipboard _clip;
    _copied = true;
};

if (hasInterface) then {
    hint format [
        LLSTRING(Scan_Result),
        count _bullets,
        count _rules + count _unknown,
        count _rules,
        [LLSTRING(Scan_ToRpt), LLSTRING(Scan_ToClipboard)] select _copied
    ];
};

[_ruleText, _unknown]
