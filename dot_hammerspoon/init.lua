local log = hs.logger.new("config", "info")

if hs.ipc then
  pcall(hs.ipc.cliInstall)
end

hs.allowAppleScript(true)

local modules = {
  "modules.microphone",
  "modules.ghostty",
}

for _, moduleName in ipairs(modules) do
  local ok, result = pcall(require, moduleName)

  if not ok then
    log.e("Failed to load " .. moduleName .. ": " .. tostring(result))
    hs.alert.show("Hammerspoon load failed: " .. moduleName)
  elseif type(result) == "table" and type(result.start) == "function" then
    result.start()
  end
end

local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon", function(files)
  for _, file in ipairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end)

configWatcher:start()

hs.alert.show("Hammerspoon config loaded")
log.i("Hammerspoon config loaded")
