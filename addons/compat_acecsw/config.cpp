#include "script_component.hpp"

// ACE Crew-Served Weapons: its ammo boxes are the belts a static weapon or a vehicle's turret (Humvee M2) is loaded
// with through ACE. Marked as belts of their caliber, they are refilled from loose rounds and belt items, unloaded and
// split like any other belt. Loads only when ACE CSW is there.
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"gmr_main", "ace_csw"};
        skipWhenMissingDependencies = 1;
        author = "Miss Heda";
        VERSION_CONFIG;
    };
};

#include "CfgMagazines.hpp"
