--[[****************************************************************************
  * _NPCScan.Overlay by Saiket                                                 *
  * _NPCScan.Overlay.Minimap.lua - Canvas for the Minimap.                     *
  ****************************************************************************]]


if ( IsAddOnLoaded( "Carbonite" ) ) then
	local Success, MinimapDocked = pcall( function () return NxData.NXGOpts.MapMMOwn; end );
	if ( Success and MinimapDocked ) then -- Minimap docked into WorldMap
		return;
	end
end

local L = _NPCScanLocalization.OVERLAY;
local Overlay = _NPCScan.Overlay;
local Minimap = Minimap;
local me = CreateFrame( "Frame", nil, Minimap );
Overlay.Minimap = me;

me.Label = L.MODULE_MINIMAP;

me.UpdateRate = 0.04;
me.UpdateDistance = 0.5;

local UpdateForce, IsInside, RotateMinimap;

-- Lots of thanks to Routes (http://www.wowace.com/addons/routes/)




--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:Repaint                                 *
  ****************************************************************************]]
do
	local SplitPoints, Quadrants = {};
	local X, Y, Facing, Width, Height;
	local FacingSin, FacingCos;
	local MaxDataValue = 2 ^ 16 - 1;

	local RepaintPathData;
	do
		local function IsQuadrantRound ( X, Y ) -- Returns true if the quadrant is rounded
			return Quadrants[ Y <= 0 -- Y-axis is flipped
				and ( X >= 0 and 1 or 2 )
				 or ( X >= 0 and 4 or 3 ) ];
		end
		local Points, LastExitPoint, IsClockwise = {};

		local AddSplitPoints; -- Adds split points between the last exit intersection and the most recent entrance intersection
		do
			local StartX, StartY;
			local SplitX, SplitY, Side;
			local StartDistance2, StartPoint;
			local NearestDistance2, NearestPoint;
			local Distance2;
			local ForStart, ForEnd, ForStep;
			function AddSplitPoints ( EndX, EndY, WrapToStart )
				if ( #SplitPoints > 0 ) then
					StartX, StartY = Points[ LastExitPoint ], Points[ LastExitPoint + 1 ];

					-- Find first split point after start
					StartDistance2, StartPoint = math.huge;
					NearestDistance2, NearestPoint = math.huge;
					ForEnd, ForStep = #SplitPoints - 1, IsClockwise and -2 or 2;
					for Index = IsClockwise and ForEnd or 1, IsClockwise and 1 or ForEnd, ForStep do
						SplitX, SplitY = SplitPoints[ Index ], SplitPoints[ Index + 1 ];
						Side = IsClockwise
							and ( StartX - EndX ) * ( SplitY - EndY ) - ( StartY - EndY ) * ( SplitX - EndX )
							 or ( EndX - StartX ) * ( SplitY - StartY ) - ( EndY - StartY ) * ( SplitX - StartX );

						if ( Side > 0 ) then -- Valid split point
							Distance2 = ( StartX - SplitX ) ^ 2 + ( StartY - SplitY ) ^ 2;
							if ( Distance2 < NearestDistance2 ) then
								NearestPoint, NearestDistance2 = Index, Distance2;
							end
							if ( Distance2 < StartDistance2 and Distance2 < ( EndX - SplitX ) ^ 2 + ( EndY - SplitY ) ^ 2 ) then
								StartPoint, StartDistance2 = Index, Distance2;
							end
						end
					end
					if ( not StartPoint ) then
						StartPoint = NearestPoint;
					end

					-- Add all split points after start
					if ( StartPoint ) then
						Points[ #Points + 1 ] = SplitPoints[ StartPoint ];
						Points[ #Points + 1 ] = SplitPoints[ StartPoint + 1 ];

						ForStart, ForEnd = StartPoint + 2, StartPoint + #SplitPoints - 2;
						for Index = IsClockwise and ForEnd or ForStart, IsClockwise and ForStart or ForEnd, ForStep do
							SplitX, SplitY = SplitPoints[ ( Index - 1 ) % #SplitPoints + 1 ], SplitPoints[ Index % #SplitPoints + 1 ];
							Side = IsClockwise
								and ( StartX - EndX ) * ( SplitY - EndY ) - ( StartY - EndY ) * ( SplitX - EndX )
								 or ( EndX - StartX ) * ( SplitY - StartY ) - ( EndY - StartY ) * ( SplitX - StartX );

							if ( Side > 0 ) then -- Valid split point
								Points[ #Points + 1 ] = SplitX;
								Points[ #Points + 1 ] = SplitY;
							else
								break;
							end
						end
					end
				end
				LastExitPoint = nil;

				if ( not WrapToStart ) then
					-- Add re-entry point
					Points[ #Points + 1 ] = EndX;
					Points[ #Points + 1 ] = EndY;
				end
			end
		end

		local AddIntersection; -- Adds the intersection of a line with the minimap to the Points table
		do
			local ABx, ABy;
			local PointX, PointY;
			local IntersectPos, Intercept, Length, Temp;
			function AddIntersection ( Ax, Ay, Bx, By, PerpDist2, IsExiting )
				PointX, PointY = nil;
				ABx, ABy = Ax - Bx, Ay - By;

				-- Clip to square
				if ( Ax >= -0.5 and Ax <= 0.5 and Ay >= -0.5 and Ay <= 0.5 ) then
					PointX, PointY = Ax, Ay;
				else
					-- Test intersection with horizontal border
					Intercept = ABy < 0 and -0.5 or 0.5;
					IntersectPos = ( Ay - Intercept ) / ABy;
					if ( IntersectPos >= 0 and IntersectPos <= 1 ) then
						PointX = Ax - ABx * IntersectPos;
						if ( PointX >= -0.5 and PointX <= 0.5 ) then
							PointY = Intercept;
						end
					end

					-- Test vertical border intersection
					if ( not PointY ) then -- Was no horizontal intersect
						Intercept = ABx < 0 and -0.5 or 0.5;
						IntersectPos = ( Ax - Intercept ) / ABx;
						if ( IntersectPos >= 0 and IntersectPos <= 1 ) then
							PointY = Ay - ABy * IntersectPos;
							if ( PointY >= -0.5 and PointY <= 0.5 ) then
								PointX = Intercept;
							else
								return;
							end
						else
							return;
						end
					end
				end

				if ( IsQuadrantRound( PointX, PointY ) ) then
					-- Clip to circle
					if ( PerpDist2 < 0.25 ) then
						Length = ABx * ABx + ABy * ABy;
						Temp = ABx * Bx + ABy * By;

						IntersectPos = ( ( Temp * Temp - Length * ( Bx * Bx + By * By - 0.25 ) ) ^ 0.5 - Temp ) / Length;
						if ( IntersectPos >= 0 and IntersectPos <= 1 ) then
							PointX, PointY = Bx + ABx * IntersectPos, By + ABy * IntersectPos;
						else
							return;
						end
					else
						return;
					end
				end

				if ( LastExitPoint ) then
					AddSplitPoints( PointX, PointY );
				else
					if ( IsExiting ) then
						LastExitPoint = #Points + 1;
					end
					Points[ #Points + 1 ] = PointX;
					Points[ #Points + 1 ] = PointY;
				end
			end
		end

		local wipe = wipe;
		local Ax, Ax2, Ay, Ay2, Bx, Bx2, By, By2, Cx, Cx2, Cy, Cy2;
		local ABx, ABy, BCx, BCy, ACx, ACy;
		local AInside, BInside, CInside;
		local IntersectPos, PerpX, PerpY;
		local ABPerpDist2, BCPerpDist2, ACPerpDist2;
		local Dot00, Dot01, Dot02, Dot11, Dot12;
		local Denominator, U, V;
		local Texture, Left, Top;
		function RepaintPathData ( PathData, R, G, B )
			for Index = 1, #PathData, 12 do
				Ax, Ax2, Ay, Ay2, Bx, Bx2, By, By2, Cx, Cx2, Cy, Cy2 = PathData:byte( Index, Index + 11 );
				Ax, Ay = ( Ax * 256 + Ax2 ) * Width - X, ( Ay * 256 + Ay2 ) * Height - Y;
				Bx, By = ( Bx * 256 + Bx2 ) * Width - X, ( By * 256 + By2 ) * Height - Y;
				Cx, Cy = ( Cx * 256 + Cx2 ) * Width - X, ( Cy * 256 + Cy2 ) * Height - Y;

				
				if ( RotateMinimap ) then
					Ax, Ay = Ax * FacingCos - Ay * FacingSin, Ax * FacingSin + Ay * FacingCos;
					Bx, By = Bx * FacingCos - By * FacingSin, Bx * FacingSin + By * FacingCos;
					Cx, Cy = Cx * FacingCos - Cy * FacingSin, Cx * FacingSin + Cy * FacingCos;
				end

				if ( -- If all points are on one side, cannot possibly intersect
					not ( ( Ax > 0.5 and Bx > 0.5 and Cx > 0.5 )
					or ( Ax < -0.5 and Bx < -0.5 and Cx < -0.5 )
					or ( Ay > 0.5 and By > 0.5 and Cy > 0.5 )
					or ( Ay < -0.5 and By < -0.5 and Cy < -0.5 ) )
				) then
					if ( IsQuadrantRound( Ax, Ay ) ) then
						AInside = Ax * Ax + Ay * Ay <= 0.25;
					else
						AInside = Ax <= 0.5 and Ax >= -0.5 and Ay <= 0.5 and Ay >= -0.5;
					end
					if ( IsQuadrantRound( Bx, By ) ) then
						BInside = Bx * Bx + By * By <= 0.25;
					else
						BInside = Bx <= 0.5 and Bx >= -0.5 and By <= 0.5 and By >= -0.5;
					end
					if ( IsQuadrantRound( Cx, Cy ) ) then
						CInside = Cx * Cx + Cy * Cy <= 0.25;
					else
						CInside = Cx <= 0.5 and Cx >= -0.5 and Cy <= 0.5 and Cy >= -0.5;
					end

					if ( AInside and BInside and CInside ) then -- No possible intersections
						Overlay.TextureAdd( me, "ARTWORK", R, G, B, 0.55,
							Ax + 0.5, Ay + 0.5, Bx + 0.5, By + 0.5, Cx + 0.5, Cy + 0.5 );
					else
						ABx, ABy = Ax - Bx, Ay - By;
						BCx, BCy = Bx - Cx, By - Cy;
						ACx, ACy = Ax - Cx, Ay - Cy;

						-- Intersection between the side and a line perpendicular to it that passes through the center
						IntersectPos = ( Ax * ABx + Ay * ABy ) / ( ABx * ABx + ABy * ABy );
						PerpX, PerpY = Ax - IntersectPos * ABx, Ay - IntersectPos * ABy;
						ABPerpDist2 = PerpX * PerpX + PerpY * PerpY; -- From center to intersection squared

						IntersectPos = ( Bx * BCx + By * BCy ) / ( BCx * BCx + BCy * BCy );
						PerpX, PerpY = Bx - IntersectPos * BCx, By - IntersectPos * BCy;
						BCPerpDist2 = PerpX * PerpX + PerpY * PerpY;

						IntersectPos = ( Ax * ACx + Ay * ACy ) / ( ACx * ACx + ACy * ACy );
						PerpX, PerpY = Ax - IntersectPos * ACx, Ay - IntersectPos * ACy;
						ACPerpDist2 = PerpX * PerpX + PerpY * PerpY;


						if ( #Points > 0 ) then
							wipe( Points );
						end
						LastExitPoint = nil;

						-- Check intersection with circle with radius at minimap's corner
						if ( ABPerpDist2 < 0.5 or BCPerpDist2 < 0.5 or ACPerpDist2 < 0.5 ) then -- Inside radius ~= 0.71
							-- Find all polygon vertices
							IsClockwise = BCx * ( By + Cy ) + ABx * ( Ay + By ) + ( Cx - Ax ) * ( Cy + Ay ) > 0;
							if ( AInside ) then
								Points[ #Points + 1 ] = Ax;
								Points[ #Points + 1 ] = Ay;
							else
								AddIntersection( Ax, Ay, Cx, Cy, ACPerpDist2, true );
								AddIntersection( Ax, Ay, Bx, By, ABPerpDist2 );
							end
							if ( BInside ) then
								Points[ #Points + 1 ] = Bx;
								Points[ #Points + 1 ] = By;
							else
								AddIntersection( Bx, By, Ax, Ay, ABPerpDist2, true );
								AddIntersection( Bx, By, Cx, Cy, BCPerpDist2 );
							end
							if ( CInside ) then
								Points[ #Points + 1 ] = Cx;
								Points[ #Points + 1 ] = Cy;
							else
								AddIntersection( Cx, Cy, Bx, By, BCPerpDist2, true );
								AddIntersection( Cx, Cy, Ax, Ay, ACPerpDist2 );
							end
							if ( LastExitPoint ) then -- Final split points between C and A
								AddSplitPoints( Points[ 1 ], Points[ 2 ], true );
							end

							-- Draw tris between convex polygon vertices
							for Index = #Points, 6, -2 do
								Overlay.TextureAdd( me, "ARTWORK", R, G, B, 0.55,
									Points[ 1 ] + 0.5, Points[ 2 ] + 0.5, Points[ Index - 3 ] + 0.5, Points[ Index - 2 ] + 0.5, Points[ Index - 1 ] + 0.5, Points[ Index ] + 0.5 );
							end
						end

						if ( #Points == 0 ) then -- No intersections
							-- Check if the center is in the triangle
							Dot00, Dot01 = ACx * ACx + ACy * ACy, ACx * BCx + ACy * BCy;
							Dot02 = ACx * -Cx - ACy * Cy;
							Dot11, Dot12 = BCx * BCx + BCy * BCy, BCx * -Cx - BCy * Cy;

							Denominator = Dot00 * Dot11 - Dot01 * Dot01;
							U, V = ( Dot11 * Dot02 - Dot01 * Dot12 ) / Denominator,
								( Dot00 * Dot12 - Dot01 * Dot02 ) / Denominator;

							if ( U > 0 and V > 0 and U + V < 1 ) then -- Entire minimap is contained
								for Index = 1, 4 do
									Texture = Overlay.TextureCreate( me, "ARTWORK", R, G, B, 0.55 );
									Left, Top = Index == 2 or Index == 3, Index <= 2;
									Texture:SetPoint( "LEFT", me, Left and "LEFT" or "CENTER" );
									Texture:SetPoint( "RIGHT", me, Left and "CENTER" or "RIGHT" );
									Texture:SetPoint( "TOP", me, Top and "TOP" or "CENTER" );
									Texture:SetPoint( "BOTTOM", me, Top and "CENTER" or "BOTTOM" );
									if ( Quadrants[ Index ] ) then -- Rounded
										Texture:SetTexture( [[Interface\CHARACTERFRAME\TempPortraitAlphaMask]] );
										Texture:SetTexCoord( Left and 0 or 0.5, Left and 0.5 or 1, Top and 0 or 0.5, Top and 0.5 or 1 );
									else -- Square
										Texture:SetTexture( [[Interface\Buttons\WHITE8X8]] );
										Texture:SetTexCoord( 0, 1, 0, 1 );
									end
								end
							end
						end
					end
				end
			end
		end
	end

	local MinimapShapes = { -- Credit to MobileMinimapButtons as seen at <http://www.wowwiki.com/GetMinimapShape>
		-- [ Shape ] = { Q1, Q2, Q3, Q4 }; where true = rounded and false = squared
		[ "ROUND" ]                 = {  true,  true,  true,  true };
		[ "SQUARE" ]                = { false, false, false, false };
		[ "CORNER-TOPRIGHT" ]       = {  true, false, false, false };
		[ "CORNER-TOPLEFT" ]        = { false,  true, false, false };
		[ "CORNER-BOTTOMLEFT" ]     = { false, false,  true, false };
		[ "CORNER-BOTTOMRIGHT" ]    = { false, false, false,  true };
		[ "SIDE-TOP" ]              = {  true,  true, false, false };
		[ "SIDE-LEFT" ]             = { false,  true,  true, false };
		[ "SIDE-BOTTOM" ]           = { false, false,  true,  true };
		[ "SIDE-RIGHT" ]            = {  true, false, false,  true };
		[ "TRICORNER-BOTTOMLEFT" ]  = { false,  true,  true,  true };
		[ "TRICORNER-BOTTOMRIGHT" ] = {  true, false,  true,  true };
		[ "TRICORNER-TOPRIGHT" ]    = {  true,  true, false,  true };
		[ "TRICORNER-TOPLEFT" ]     = {  true,  true,  true, false };
	};
	local LastQuadrants;
	local RadiiInside = { 150, 120, 90, 60, 40, 25 };
	local RadiiOutside = { 233 + 1 / 3, 200, 166 + 2 / 3, 133 + 1 / 3, 100, 66 + 2 / 3 };
	local Cos, Sin = math.cos, math.sin;
	function me:Repaint ( Map, NewX, NewY, NewFacing )
		Overlay.TextureRemoveAll( self );

		Quadrants = MinimapShapes[ GetMinimapShape and GetMinimapShape() ] or MinimapShapes[ "ROUND" ];
		if ( Quadrants ~= LastQuadrants ) then -- Minimap shape changed
			LastQuadrants = Quadrants;

			-- Cache split points
			wipe( SplitPoints );
			for Index = 1, 4 do
				if ( Quadrants[ Index ] ) then -- Round
					if ( not Quadrants[ ( Index - 2 ) % 4 + 1 ] ) then -- Transition from previous
						local Angle = ( Index - 1 ) * math.pi / 2;
						SplitPoints[ #SplitPoints + 1 ] = Cos( Angle ) * 0.5;
						SplitPoints[ #SplitPoints + 1 ] = Sin( Angle ) * -0.5;
					end
					if ( not Quadrants[ Index % 4 + 1 ] ) then -- Transition to next
						local Angle = Index * math.pi / 2;
						SplitPoints[ #SplitPoints + 1 ] = Cos( Angle ) * 0.5;
						SplitPoints[ #SplitPoints + 1 ] = Sin( Angle ) * -0.5;
					end
				else -- Square
					local Left, Top = Index == 2 or Index == 3, Index <= 2;
					SplitPoints[ #SplitPoints + 1 ] = Left and -0.5 or 0.5;
					SplitPoints[ #SplitPoints + 1 ] = Top and -0.5 or 0.5;
				end
			end
		end

		local Side = ( IsInside and RadiiInside or RadiiOutside )[ Minimap:GetZoom() + 1 ] * 2;
		Width, Height = Overlay.GetZoneSize( Map );
		Width, Height = Width / MaxDataValue / Side, Height / MaxDataValue / Side; -- Simplifies data decompression
		X = NewX / Side;
		Y = NewY / Side;
		Facing = NewFacing;

		if ( RotateMinimap ) then
			FacingSin = Sin( Facing );
			FacingCos = Cos( Facing );
		end

		Overlay.ApplyZone( Map, RepaintPathData );
	end
end




--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:SetZoom                                 *
  ****************************************************************************]]
do
	local Backup = Minimap.SetZoom;
	function me:SetZoom ( Zoom, ... )
		if ( self:GetZoom() ~= Zoom ) then
			UpdateForce = true;
		end
		return Backup( Minimap, Zoom, ... );
	end
end

--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:MINIMAP_UPDATE_ZOOM                     *
  * Description: Fires when the minimap swaps between indoor and outdoor zoom. *
  ****************************************************************************]]
function me:MINIMAP_UPDATE_ZOOM ()
	local Zoom = Minimap:GetZoom();
	if ( GetCVar( "minimapZoom" ) == GetCVar( "minimapInsideZoom" ) ) then -- Indeterminate case
		Minimap:SetZoom( Zoom > 0 and Zoom - 1 or Zoom + 1 ); -- Any change to make the cvars unequal
	end
	IsInside = Minimap:GetZoom() == GetCVar( "minimapInsideZoom" ) + 0;
	Minimap:SetZoom( Zoom );
	UpdateForce = true;
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:ZONE_CHANGED_NEW_AREA                   *
  ****************************************************************************]]
function me:ZONE_CHANGED_NEW_AREA ()
	UpdateForce = true;
	if ( not WorldMapFrame:IsVisible() ) then
		SetMapToCurrentZone();
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:CVAR_UPDATE                             *
  ****************************************************************************]]
function me:CVAR_UPDATE ( _, CVar, Value )
	if ( CVar == "ROTATE_MINIMAP" ) then
		RotateMinimap = Value == "1";
		UpdateForce = true;
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:PLAYER_LOGIN                            *
  ****************************************************************************]]
function me:PLAYER_LOGIN ()
	RotateMinimap = GetCVarBool( "rotateMinimap" );
	SetMapToCurrentZone();
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:OnShow                                  *
  ****************************************************************************]]
function me:OnShow ()
	UpdateForce = true;
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:OnUpdate                                *
  ****************************************************************************]]
do
	local GetPlayerMapPosition = GetPlayerMapPosition;
	local GetRealZoneText = GetRealZoneText;
	local GetPlayerFacing = GetPlayerFacing;
	local GetMapInfo = GetMapInfo;
	local UpdateNext = 0;
	local LastX, LastY, LastFacing;
	function me:OnUpdate ( Elapsed )
		UpdateNext = UpdateNext - Elapsed;
		if ( UpdateForce or UpdateNext <= 0 ) then
			UpdateNext = self.UpdateRate;

			local Map = Overlay.ZoneMaps[ GetRealZoneText() ];
			local X, Y = GetPlayerMapPosition( "player" );
			if ( not Map or ( X == 0 and Y == 0 )
				or X < 0 or X > 1 or Y < 0 or Y > 1
				or Map ~= GetMapInfo() -- Coordinates will be for wrong map
			) then
				UpdateForce = nil;
				Overlay.TextureRemoveAll( self );
				return;
			end

			local Facing = RotateMinimap and GetPlayerFacing() or 0;
			local Width, Height = Overlay.GetZoneSize( Map );
			X = X * Width;
			Y = Y * Height;

			if ( UpdateForce or Facing ~= LastFacing or ( X - LastX ) ^ 2 + ( Y - LastY ) ^ 2 >= self.UpdateDistance ) then
				UpdateForce = nil;
				LastX = X;
				LastY = Y;
				LastFacing = Facing;

				self:Repaint( Map, X, Y, Facing );
			end
		end
	end
end


--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:Update                                  *
  ****************************************************************************]]
function me:Update ( Map )
	if ( not Map or Map == Overlay.ZoneMaps[ GetRealZoneText() ] ) then
		UpdateForce = true;
	end
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:Disable                                 *
  ****************************************************************************]]
function me:Disable ()
	self:Hide();
	Overlay.TextureRemoveAll( self );
end
--[[****************************************************************************
  * Function: _NPCScan.Overlay.Minimap:Enable                                  *
  ****************************************************************************]]
function me:Enable ()
	self:Show();
end




--------------------------------------------------------------------------------
-- Function Hooks / Execution
-----------------------------

do
	me:Hide();
	me:SetAllPoints();
	me:SetScript( "OnShow", me.OnShow );
	me:SetScript( "OnUpdate", me.OnUpdate );
	me:SetScript( "OnEvent", _NPCScan.OnEvent );
	me:RegisterEvent( "MINIMAP_UPDATE_ZOOM" );
	me:RegisterEvent( "ZONE_CHANGED_NEW_AREA" );
	me:RegisterEvent( "CVAR_UPDATE" );
	me:RegisterEvent( "PLAYER_LOGIN" );

	Minimap.SetZoom = me.SetZoom;
	WorldMapFrame:HookScript( "OnHide", SetMapToCurrentZone );

	Overlay.ModuleRegister( "Minimap", me );
end
