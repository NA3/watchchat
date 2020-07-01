 -------------------------------------
-- wc --------------
-- Emerald Dream/Grobbulus --------

-- 
local wc = LibStub( 'AceAddon-3.0' ):GetAddon( 'wc' )
local ui = wc:NewModule( 'ui', 'AceConsole-3.0' )
local utility = LibStub:GetLibrary( 'utility' )

-- setup addon
--
-- returns void
function ui:init( )

  self:RegisterChatCommand( 'wc', 'processInput' )
  self[ 'channels' ]    = self:getChannels( )
  self[ 'persistence' ] = wc:getNameSpace( )
  self[ 'watches' ]     = self[ 'persistence' ][ 'watch' ] or { }
  self[ 'events' ]      = {
    'CHAT_MSG_GUILD',
    'CHAT_MSG_CHANNEL',
    'CHAT_MSG_SAY',
    'CHAT_MSG_PARTY',
  }

end

-- process slash commands
--
-- returns void
function ui:processInput( input )
  
  local tokens = { }
  for token in string.gmatch( input, "[^%s]+" ) do
    tinsert( tokens, token )
  end

  if tokens[ 1 ] == 'add' then
  	self:add( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'remove' then
    self:remove( tokens[ 2 ] )
  elseif tokens[ 1 ] == 'list' then
    self:list( )
  else
  	self:help( )
  end

end

-- add to watch list
-- 
-- returns void
function ui:add( input )

  local iterator = 0
  local found = false
  for i, keyword in pairs( self[ 'watches' ] ) do
    if strlower( input ) == strlower( keyword ) then
      iterator = i
      found = true
    end
  end
  if not found then
    tinsert( self[ 'watches' ], input )
    wc:notify( 'watching ' .. input )
  else
    wc:warn( 'already watching ' .. input )
  end

end

-- remove from watch list
-- 
-- returns void
function ui:remove( input )

   for i, keyword in pairs( self[ 'watches' ] ) do
    if strlower( input ) == strlower( keyword ) then
      tremove( self[ 'watches' ], i )
      wc:warn( 'no longer watching ' .. input )
    end
   end

end

-- report watch list
-- 
-- returns void
function ui:list( )

  for i, keyword in pairs( self[ 'watches' ] ) do
    wc:notify( 'watching ' .. keyword )
  end

end

function ui:help( )

  wc:warn( 'try /wc add keyword' )
  wc:warn( 'try /wc remove keyword' )
  wc:warn( 'try /wc list' )

end

-- watch chat
-- 
-- returns void
function ui:listen( )

  local f = CreateFrame( 'Frame' )
  for _, event in ipairs( self[ 'events' ] ) do
    f:RegisterEvent( event )
  end
  for _, channel in pairs( self[ 'channels' ] ) do
    wc:notify( 'WATCHING ' .. channel[ 'name' ] )
  end
  local guild_name = GetGuildInfo( 'player' )
  if guild_name ~= nil then
    wc:notify( 'WATCHING ' .. guild_name )
  end

  f:SetScript( 'OnEvent', function( self, event, msg, sender, _, channel_string, _, _, _, channel_num, channel )

    if message == nil or sender == GetUnitName( 'player' ) .. '-' .. GetRealmName() then
      return
    end
    for _, watch in pairs( ui[ 'watches' ] ) do
      local i, j = strfind( strlower( msg ), strlower( watch ) )
      if i ~= nil then
        ChatThrottleLib:SendChatMessage( 'NORMAL', '>', channel .. '/' .. sender .. ': ' .. msg, 'WHISPER', nil, GetUnitName( 'player' ) )
      end
    end

  end )

end

-- get joined channels
-- 
-- returns object
function ui:getChannels( )

  local channels = { }
  local chanList = { GetChannelList( ) }
  for i=1, #chanList, 3 do
    tinsert( channels, {
      id = chanList[ i ],
      name = chanList[ i + 1 ],
      isDisabled = chanList[ i + 2 ],
    } )
  end
  return channels

end

-- register addon
--
-- returns void
function ui:OnInitialize( )
  self:Enable( )
end

-- activated addon handler
--
-- returns void
function ui:OnEnable( )
  self:init( )
  self:listen( )
end