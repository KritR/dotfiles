local M = {}

local log = hs.logger.new("ghostty", "info")

local APP_NAME = "Ghostty"
local APP_BUNDLE_ID = "com.mitchellh.ghostty"
local NEW_WINDOW_MODS = { "cmd", "ctrl" }
local NEW_WINDOW_KEY = "t"
local SMART_PASTE_KEY = hs.keycodes.map.v

local WINDOW_WIDTH = 1000
local WINDOW_HEIGHT = 700
local WINDOW_FIND_ATTEMPTS = 10
local WINDOW_FIND_INTERVAL = 0.10

local smartPasteTap = nil

local function ghosttyApp()
  return hs.application.get(APP_BUNDLE_ID) or hs.application.get(APP_NAME) or hs.application.get(APP_NAME:lower())
end

local function frontmostAppName()
  local app = hs.application.frontmostApplication()
  return app and app:name() or nil
end

local function isGhosttyFrontmost()
  local app = hs.application.frontmostApplication()

  if not app then
    return false
  end

  if app:bundleID() == APP_BUNDLE_ID then
    return true
  end

  local name = app:name()
  return name and name:lower() == APP_NAME:lower()
end

local function tableContains(t, value)
  if not t then
    return false
  end

  for _, v in ipairs(t) do
    if v == value then
      return true
    end
  end

  return false
end

local function clipboardHasExplicitImageType()
  local types = hs.pasteboard.contentTypes() or {}
  local imageTypes = {
    "public.png",
    "public.jpeg",
    "public.jpg",
    "public.tiff",
    "com.apple.tiff",
    "com.compuserve.gif",
    "com.microsoft.bmp",
    "public.heic",
  }

  for _, imageType in ipairs(imageTypes) do
    if tableContains(types, imageType) then
      return true
    end
  end

  return false
end

local function timestampMillis()
  local epoch = hs.timer.secondsSinceEpoch()
  local millis = math.floor((epoch % 1) * 1000)
  return os.date("%Y%m%d-%H%M%S", math.floor(epoch)) .. string.format("-%03d", millis)
end

local function saveClipboardImageToTmp()
  if not clipboardHasExplicitImageType() then
    return nil
  end

  local img = hs.pasteboard.readImage()

  if not img then
    return nil
  end

  local path = "/tmp/ghostty-paste-" .. timestampMillis() .. ".png"
  local ok = img:saveToFile(path, true, "PNG")

  if not ok then
    log.e("Failed to save clipboard image to " .. path)
    return nil
  end

  return path
end

local function startSmartPaste()
  if smartPasteTap then
    smartPasteTap:stop()
  end

  smartPasteTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    if not isGhosttyFrontmost() or event:getKeyCode() ~= SMART_PASTE_KEY then
      return false
    end

    local flags = event:getFlags()

    if not flags.cmd or flags.shift or flags.alt or flags.ctrl or flags.fn then
      return false
    end

    local imagePath = saveClipboardImageToTmp()

    if imagePath then
      hs.eventtap.keyStrokes(imagePath)
      return true
    end

    return false
  end)

  smartPasteTap:start()
end

local function centerWindowOnMouseScreen(win, width, height)
  if not win then
    return
  end

  local screen = hs.mouse.getCurrentScreen() or win:screen() or hs.screen.mainScreen()
  local frame = screen:frame()

  win:setFrame({
    x = frame.x + ((frame.w - width) / 2),
    y = frame.y + ((frame.h - height) / 2),
    w = width,
    h = height,
  }, 0)
end

local function findNewGhosttyWindow(before)
  local ghostty = ghosttyApp()

  if not ghostty then
    return nil
  end

  for _, win in ipairs(ghostty:allWindows()) do
    if win:isStandard() and not before[win:id()] then
      return win
    end
  end

  return ghostty:mainWindow() or ghostty:focusedWindow()
end

local function openCenteredGhostty()
  local app = ghosttyApp()
  local before = {}

  if app then
    for _, win in ipairs(app:allWindows()) do
      before[win:id()] = true
    end
  end

  local ok, result, raw = hs.osascript.applescript([[
tell application "Ghostty"
    set cfg to new surface configuration
    set win to new window with configuration cfg
end tell
]])

  if not ok then
    log.e("Ghostty AppleScript failed: " .. hs.inspect(raw or result))
    hs.alert.show("Ghostty AppleScript failed")
    return
  end

  log.i("Ghostty AppleScript result: " .. hs.inspect(result))

  local attempts = 0
  local function centerWhenAvailable()
    attempts = attempts + 1
    local newWin = findNewGhosttyWindow(before)

    if newWin then
      centerWindowOnMouseScreen(newWin, WINDOW_WIDTH, WINDOW_HEIGHT)
      log.i("Centered Ghostty window " .. tostring(newWin:id()))
    elseif attempts < WINDOW_FIND_ATTEMPTS then
      hs.timer.doAfter(WINDOW_FIND_INTERVAL, centerWhenAvailable)
    else
      log.w("Could not find new Ghostty window to center")
      hs.alert.show("Could not find Ghostty window")
    end
  end

  hs.timer.doAfter(WINDOW_FIND_INTERVAL, centerWhenAvailable)
end

function M.start()
  startSmartPaste()
  hs.hotkey.bind(NEW_WINDOW_MODS, NEW_WINDOW_KEY, openCenteredGhostty)
end

M.openCenteredGhostty = openCenteredGhostty

return M
