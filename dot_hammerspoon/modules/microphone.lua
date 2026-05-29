local M = {}

local tap = nil

local KEYCODE = 176
local FN_FLAG = 8388608

local function hasRawFlag(rawFlags, flag)
  return rawFlags % (flag * 2) >= flag
end

local function toggleInputMute()
  local dev = hs.audiodevice.defaultInputDevice()

  if not dev then
    hs.alert.show("No input device")
    return
  end

  local currentlyMuted = dev:inputMuted()

  if currentlyMuted == nil then
    hs.alert.show("Input mute unsupported: " .. (dev:name() or "unknown device"))
    return
  end

  local desired = not currentlyMuted
  local ok = dev:setInputMuted(desired)

  if ok then
    hs.alert.show((desired and "Mic muted: " or "Mic unmuted: ") .. (dev:name() or "input"))
  else
    hs.alert.show("Could not change input mute")
  end
end

function M.start()
  if tap then
    tap:stop()
  end

  tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    if event:getKeyCode() == KEYCODE and hasRawFlag(event:rawFlags(), FN_FLAG) then
      toggleInputMute()
      return true
    end

    return false
  end)

  tap:start()
end

return M

