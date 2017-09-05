-- TODO - implement the width meter

do  --  Default options
  _DevPad_options = 
  _DevPad_options or {}

  _DevPad_options.auto_indent_lua_scripts = 
  _DevPad_options.auto_indent_lua_scripts or true

  _DevPad_options.tab_width = 
  _DevPad_options.tab_width or 2

  _DevPad_options.debug = 
  _DevPad_options.debug or false

--[[
  _DevPad_options.colored_list = 
  _DevPad_options.colored_list or false
]]
end




function _DevPad_setup_options_pane()

_DevPad_options.panel = CreateFrame( 'Frame', '_DevPadPanel', UIParent )
_DevPad_options.panel.name = '_DevPad'
InterfaceOptions_AddCategory( _DevPad_options.panel )

local position = 0

local function space()
  position = position + 1
  Text = _DevPad_options.panel:CreateFontString( nil, UIParent, 'GameFontNormalSmall' )
  Text:SetPoint( 'TopLeft', 20, -25  )
  Text:SetText( '' )
end



position = position + 1
Text = _DevPad_options.panel:CreateFontString( nil, UIParent, 'GameFontNormal' )
Text:SetPoint( 'TopLeft', 20, -25 * position )
Text:SetText( '_DevPad' )



position = position + 1
Text = _DevPad_options.panel:CreateFontString( nil, UIParent, 'GameFontNormalSmall' )
Text:SetPoint( 'TopLeft', 20, -25 * position )
Text:SetText( 'Version ' .. tostring( GetAddOnMetadata( '_DevPad', 'Version' ) ) )



position = position + 1
Text = _DevPad_options.panel:CreateFontString( nil, UIParent, 'GameFontNormal' )
Text:SetPoint( 'TopLeft', 20, -25 * position )
Text:SetText( tostring( GetAddOnMetadata( '_DevPad', 'Notes' ) ) )



space()



position = position + 1
Text = _DevPad_options.panel:CreateFontString( nil, UIParent, 'GameFontNormalSmall' )
Text:SetPoint( 'TopLeft', 20, -25 * position )
Text:SetText( 'With great thanks to Saiket for the original _DevPad' )



space()



space()



do  --  _DevPad_options.auto_indent_lua_scripts
  position = position + 1
  local CheckButton
  CheckButton = CreateFrame( 'CheckButton', '_DevPad_options.auto_indent_lua_scripts', _DevPadPanel, 'OptionsCheckButtonTemplate' )
  CheckButton:SetPoint( 'TopLeft', 20, -20 * position )
  getglobal( CheckButton:GetName() .. 'Text' ):SetText( 'Auto-Indent Lua Scripts' )
  --CheckButton.tooltipText = ''
  CheckButton:SetChecked( _DevPad_options.auto_indent_lua_scripts )
  CheckButton:SetScript( 'OnClick', function( self )
    if self:GetChecked()then
      _DevPad_options.auto_indent_lua_scripts = true
      -- TODO - enable/disable the slider
        -- I could remove 'local slider_tab_width' and 'local slider_tab_width2' below, but then I have to figure out how to grey it out.
      --slider_tab_width:Enable()
      --slider_tab_width2:Enable()
    else
      _DevPad_options.auto_indent_lua_scripts = false
      --slider_tab_width:Disable()
      --slider_tab_width2:Disable()
    end
  end)
end


space()


do  --  _DevPad_options.tab_width
  position = position + 1
  local slider_tab_width
  slider_tab_width = CreateFrame( 'Slider', '_DevPad_options.tab_width', _DevPadPanel, 'OptionsSliderTemplate' )
  slider_tab_width:SetPoint( 'TopLeft', 20, -20 * position )
  getglobal( slider_tab_width:GetName() .. 'Text' ):SetText( 'Tab Width: ' .. _DevPad_options.tab_width )
  slider_tab_width.tooltipText = 'The width of the automatic indentation.  Default 2'
  slider_tab_width:SetMinMaxValues( 1, 8 )
  slider_tab_width:SetValueStep( 1 )
  slider_tab_width:SetObeyStepOnDrag( true )
  slider_tab_width:SetValue( _DevPad_options.tab_width )
  slider_tab_width:SetScript( 'OnValueChanged', function()
    _DevPad_options.tab_width = slider_tab_width:GetValue()
    -- update its title
    getglobal( slider_tab_width:GetName() .. 'Text' ):SetText( 'Tab Width: ' .. _DevPad_options.tab_width )
  end)


  position = position + 1
  local Button
  Button = CreateFrame( 'Button', '_DevPad_options.tab_width2', _DevPadPanel, 'OptionsButtonTemplate' )
  Button:SetPoint( 'TopLeft', 20, -20 * position )
  getglobal( Button:GetName() .. 'Text' ):SetText( 'Reset' )
  Button.tooltipText = 'Reset the tab width to 2'
  Button:SetScript( 'OnClick', function( self )
    _DevPad_options.tab_width = 2
    slider_tab_width:SetValue( 2 )
  end)
end



--[[
space()



do  --  _DevPad_options.colored_list
  position = position + 1
  local CheckButton
  CheckButton = CreateFrame( 'CheckButton', '_DevPad_options.colored_list', _DevPadPanel, 'OptionsCheckButtonTemplate' )
  CheckButton:SetPoint( 'TopLeft', 20, -20 * position )
  getglobal( CheckButton:GetName() .. 'Text' ):SetText( 'Color list items' )
  --CheckButton.tooltipText = ''
  CheckButton:SetChecked( _DevPad_options.colored_list )
  CheckButton:SetScript( 'OnClick', function( self )
    if self:GetChecked()then
      _DevPad_options.colored_list = true
    else
      _DevPad_options.colored_list = false
    end
  end)
end
]]


space()



space()



do  --  _DevPad_options.debug
  position = position + 1
  local CheckButton
  CheckButton = CreateFrame( 'CheckButton', '_DevPad_options.debug', _DevPadPanel, 'OptionsCheckButtonTemplate' )
  CheckButton:SetPoint( 'TopLeft', 20, -20 * position )
  getglobal( CheckButton:GetName() .. 'Text' ):SetText( 'Show debug messages' )
  CheckButton.tooltipText = ''
  CheckButton:SetChecked( _DevPad_options.debug )
  CheckButton:SetScript( 'OnClick', function( self )
    if self:GetChecked()then
      print( '_DevPad:  Debugging enabled' )
      _DevPad_options.debug = true
    else
      print( '_DevPad:  Debugging disabled' )
      _DevPad_options.debug = false
    end
  end)
end


end
