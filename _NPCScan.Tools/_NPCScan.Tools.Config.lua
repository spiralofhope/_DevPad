--[[****************************************************************************
  * _NPCScan.Tools by Saiket                                                   *
  * _NPCScan.Tools.Config.lua - Adds a configuration pane to manage the        *
  *   Overlay module.                                                          *
  ****************************************************************************]]


local Overlay = _NPCScan.Overlay;
local Tools = _NPCScan.Tools;
local L = _NPCScanLocalization.TOOLS;
local me = CreateFrame( "Frame" );
Tools.Config = me;

me.TableContainer = CreateFrame( "Frame", nil, me );




--[[****************************************************************************
  * Function: _NPCScan.Tools.Config:TableRowOnClick                            *
  * Description: Clear the selection if it gets clicked again.                 *
  ****************************************************************************]]
function me:TableRowOnClick ()
	local Table = self:GetParent().Table;
	if ( not Table:SetSelection( self ) ) then
		Table:SetSelection();
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Config:TableAddRow                              *
  ****************************************************************************]]
do
	local function AddHooks( Row, ... )
		Row:SetScript( "OnClick", me.TableRowOnClick );
		return Row, ...;
	end

	local CreateRowBackup;
	function me:TableCreateRow ( ... )
		return AddHooks( CreateRowBackup( self, ... ) );
	end
--[[****************************************************************************
  * Function: _NPCScan.Tools.Config:OnShow                                     *
  ****************************************************************************]]
	local function OnSelect ( self, ID )
		Tools.Overlay.Select( ID );
	end
	local OverlayNPCs = _NPCScanOverlayLocalization.NPCS;
	function me:OnShow ()
		self:SetScript( "OnShow", nil );
		me.OnShow = nil;

		me.Table = LibStub( "LibTextTable-1.0" ).New( nil, me.TableContainer );
		me.Table:SetAllPoints();
		me.Table.OnSelect = OnSelect;

		me.Table:SetHeader( L.CONFIG_MAPID, L.CONFIG_ID, L.CONFIG_NAME, L.CONFIG_MODEL );
		me.Table:SetSortHandlers( true, true, true, false );
		me.Table:SetSortColumn( 1 ); -- Default to MapID
		CreateRowBackup = me.Table.CreateRow;
		me.Table.CreateRow = me.TableCreateRow;

		-- Cache custom mob names
		local NPCNames = {};
		for Name, NpcID in pairs( _NPCScan.OptionsCharacter.NPCs ) do
			NPCNames[ NpcID ] = Name;
		end
		local AchievementNPCNames = Overlay.WorldMap.AchievementNPCNames;

		for NpcID, MapID in pairs( Tools.LocationData.NpcMapIDs ) do
			me.Table:AddRow( NpcID,
				Overlay.GetZoneName( MapID ) or MapID,
				NpcID,
				AchievementNPCNames[ NpcID ] or OverlayNPCs[ NpcID ] or NPCNames[ NpcID ] or nil,
				Tools.ModelData[ NpcID ] or nil );
		end
	end
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	me.name = L.CONFIG_TITLE;
	me.parent = _NPCScanLocalization.CONFIG_TITLE;
	me:Hide();
	me:SetScript( "OnShow", me.OnShow );

	-- Pane title
	me.Title = me:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" );
	me.Title:SetPoint( "TOPLEFT", 16, -16 );
	me.Title:SetText( L.CONFIG_TITLE );
	local SubText = me:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" );
	me.SubText = SubText;
	SubText:SetPoint( "TOPLEFT", me.Title, "BOTTOMLEFT", 0, -8 );
	SubText:SetPoint( "RIGHT", -32, 0 );
	SubText:SetHeight( 32 );
	SubText:SetJustifyH( "LEFT" );
	SubText:SetJustifyV( "TOP" );
	SubText:SetText( L.CONFIG_DESC );


	-- Place table
	me.TableContainer:SetPoint( "TOPLEFT", SubText, -2, -28 );
	me.TableContainer:SetPoint( "BOTTOMRIGHT", -16, 16 );
	me.TableContainer:SetBackdrop( { bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]]; } );


	InterfaceOptions_AddCategory( me );
end
