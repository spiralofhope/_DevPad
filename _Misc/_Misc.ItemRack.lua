--[[****************************************************************************
  * _Misc by Saiket                                                            *
  * _Misc.ItemRack.lua - Modifies the ItemRack addon.                          *
  *                                                                            *
  * + Changes your character's title based on the set you wear.                *
  ****************************************************************************]]


local _Misc = _Misc;
local me = {
	SetTitles = {
		[ "1.Heal" ]  = 36; -- Champion of the Naaru
		[ "2.Shock" ] = 39; -- Hand of A'dal
		[ "3.Tank" ]  =  6; -- Knight
	};
};
_Misc.ItemRack = me;




--[[****************************************************************************
  * Function: _Misc.ItemRack.EquipSet                                          *
  * Description: Changes the player's title when swapping sets.  Unspecified   *
  *   sets will clear the title.                                               *
  ****************************************************************************]]
function me.EquipSet ( SetName )
	SetCurrentTitle( me.SetTitles[ SetName ] or -1 );
end


--[[****************************************************************************
  * Function: _Misc.ItemRack.OnLoad                                            *
  * Description: Makes modifications just after the addon is loaded.           *
  ****************************************************************************]]
function me.OnLoad ()
	hooksecurefunc( ItemRack, "EquipSet", me.EquipSet );
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	_Misc.RegisterAddOnInitializer( "ItemRack", me.OnLoad );
end