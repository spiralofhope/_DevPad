--[[****************************************************************************
  * _Corpse by Saiket                                                          *
  * Locales/Locale-zhCN.lua - Localized string constants (zhCN) by Sparanoid.  *
  ****************************************************************************]]


if ( GetLocale() ~= "zhCN" ) then
	return;
end


-- See http://wow.curseforge.com/addons/corpse/localization/zhCN/
local _Corpse = select( 2, ... );
_Corpse.L = setmetatable( {
	CORPSE_PATTERN = "^([^ ]+)的尸体$",
	ENEMY_OFFLINE_PATTERN = "^无法找到玩家'([^%s%p%d%c]+)'。$",
	FRIEND_ADDED_PATTERN = "^([^%s%p%d%c]+)已被加入好友名单$",
	FRIEND_REMOVED_PATTERN = "^([^%s%p%d%c]+)已被从好友名单中删除$",
}, { __index = _Corpse.L; } );