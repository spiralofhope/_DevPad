--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * Locales/Locale-ruRU.lua - Localized string constants (ru-RU).              *
  ****************************************************************************]]


if ( GetLocale() == "ruRU" ) then
	_NPCScanOverlayLocalization.NPCS = setmetatable( {
		[ 1140 ] = "Острозуб-матриарх";
		[ 5842 ] = "Такк Прыгун";
		[ 6581 ] = "Равазавр-матриарх";
		[ 14232 ] = "Дарт";

		-- Outlands
		[ 18684 ] = "Бро'Газ Без Клана";

		-- Northrend
		[ 32491 ] = "Затерянный во времени протодракон";
		[ 33776 ] = "Гондрия";
		[ 35189 ] = "Сколл";
		[ 38453 ] = "Арктур";
	}, { __index = _NPCScanOverlayLocalization.NPCS; } );
end
