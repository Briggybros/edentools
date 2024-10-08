#include "script_component.hpp"

params [
	["_logic", objNull, [objNull]]		// Argument 0 is module logic
];

[_logic] spawn {
	params ["_logic"];

	if (!hasInterface) exitWith {};
	if (isNull _logic) exitWith {};

	waitUntil {sleep 1; !isNull player};

	_side = (_logic getVariable "Side") call BIS_fnc_sideType;

	_faction = _logic getVariable ["Faction", "BLU_F"] splitString " ,";

	([_side, _faction] call FUNCMAIN(getFactionItems)) params ["_weapons", "_magazines", "_items", "_backpacks"];

	if (!isnull (configfile >> "CfgPatches" >> "task_force_radio")) then {
		([_side, _faction, _weapons, _magazines, _items, _backpacks] call FUNCMAIN(getTFARItems)) params ["_n_weapons", "_n_magazines", "_n_items", "_n_backpacks"];
		_weapons = _n_weapons;
		_magazines = _n_magazines;
		_items = _n_items;
		_backpacks = _n_backpacks;
	};

	if (!isnull (configFile >> "CfgPatches" >> "ace_main")) then {
		([_side, _faction, _weapons, _magazines, _items, _backpacks] call FUNCMAIN(getAceItems)) params ["_n_weapons", "_n_magazines", "_n_items", "_n_backpacks"];
		_weapons = _n_weapons;
		_magazines = _n_magazines;
		_items = _n_items;
		_backpacks = _n_backpacks;
	};

	if (!isnull (configFile >> "CfgPatches" >> "kat_main")) then {
		([_side, _faction, _weapons, _magazines, _items, _backpacks] call FUNCMAIN(getKATItems)) params ["_n_weapons", "_n_magazines", "_n_items", "_n_backpacks"];
		_weapons = _n_weapons;
		_magazines = _n_magazines;
		_items = _n_items;
		_backpacks = _n_backpacks;
	};

	if (!isnull (configFile >> "CfgPatches" >> "ALiVE_c_tablet")) then {
		([_side, _faction, _weapons, _magazines, _items, _backpacks] call FUNCMAIN(getALIVEItems)) params ["_n_weapons", "_n_magazines", "_n_items", "_n_backpacks"];
		_weapons = _n_weapons;
		_magazines = _n_magazines;
		_items = _n_items;
		_backpacks = _n_backpacks;
	};

	// Dedupe lists
	_finalWeapons = [];
	{_finalWeapons pushBackUnique _x} forEach _weapons;
	_finalMagazines = [];
	{_finalMagazines pushBackUnique _x} forEach _magazines;
	_finalItems = [];
	{_finalItems pushBackUnique _x} forEach _items;
	_finalBackpacks = [];
	{_finalBackpacks pushBackUnique _x} forEach _backpacks;

	{
		_x setVariable ['access_side', _side];
		_x setVariable ['weapons', _finalWeapons];
		_x setVariable ['magazines', _finalMagazines];
		_x setVariable ['items', _finalItems];
		_x setVariable ['backpacks', _finalBackpacks];
		[_x, _finalWeapons,   false, false] call BIS_fnc_addVirtualWeaponCargo;
		[_x, _finalMagazines, false, false] call BIS_fnc_addVirtualMagazineCargo; 
		[_x, _finalItems,     false, false] call BIS_fnc_addVirtualItemCargo;
		[_x, _finalBackpacks, false, false] call BIS_fnc_addVirtualBackpackCargo;
		["AmmoboxInit", [_x, false, {(_target distance _this) < 3 && side _this == _target getVariable "access_side"}]] spawn BIS_fnc_arsenal;
		_x lockInventory true;
	} forEach synchronizedObjects _logic;

	true;
};

