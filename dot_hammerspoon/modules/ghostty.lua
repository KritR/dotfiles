local M = {}

local log = hs.logger.new("ghostty", "info")

local APP_NAME = "Ghostty"
local NEW_WINDOW_MODS = { "cmd", "ctrl" }
local NEW_WINDOW_KEY = "t"
local SMART_PASTE_KEY = hs.keycodes.map.v

local USE_SHELL_HELPER = true
local SHELL_HELPER = os.getenv("HOME") .. "/.local/bin/new-centered-ghostty"

local WINDOW_WIDTH = 1000
local WINDOW_HEIGHT = 700

local smartPasteTap = nil

local function frontmostAppName()
  local app = hs.application.frontmostApplication()
  return app and app:name() or nil
end

local function isGhosttyFrontmost()
  return frontmostAppName() == APP_NAME
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

local function openCenteredGhosttyPureHammerspoon()
  local app = hs.application.get(APP_NAME)
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

  hs.timer.doAfter(0.20, function()
    local ghostty = hs.application.get(APP_NAME)

    if not ghostty then
      return
    end

    local newWin = nil

    for _, win in ipairs(ghostty:allWindows()) do
      if win:isStandard() and not before[win:id()] then
        newWin = win
        break
      end
    end

    newWin = newWin or ghostty:mainWindow() or ghostty:focusedWindow()

    if newWin then
      centerWindowOnMouseScreen(newWin, WINDOW_WIDTH, WINDOW_HEIGHT)
    else
      log.w("Could not find new Ghostty window to center")
    end
  end)
end

local function openCenteredGhostty()
  if USE_SHELL_HELPER then
    hs.task.new("/bin/bash", function(exitCode, _, stdErr)
      if exitCode ~= 0 then
        log.e("new-centered-ghostty failed: " .. (stdErr or ""))
        hs.alert.show("new-centered-ghostty failed")
      end
    end, { "-lc", string.format("%q", SHELL_HELPER) }):start()
  else
    openCenteredGhosttyPureHammerspoon()
  end
end

function M.start()
  startSmartPaste()
  hs.hotkey.bind(NEW_WINDOW_MODS, NEW_WINDOW_KEY, openCenteredGhostty)
end

return M

