local Dispatcher = require("dispatcher")  -- luacheck:ignore
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local Device = require("device")
local logger = require("logger")
local socket = require("socket")

local _ = require("gettext")


local CalibreAutoconnect = WidgetContainer:new{
    name = "calibre_usb_autoconnect",
    is_doc_only = false,
}

local charging = false
local initialized = false
local calibre = nil
local tryConnect = nil

function CalibreAutoconnect:init()
    if not initialized then
        calibre = self.loadCalibreModule()
        if calibre ~= nil then
            calibre.wireless:init()
        end

        tryConnect = function()
            self:checkConnectionAndTryConnect()
        end

        local powerd = Device:getPowerDevice()
        is_charging = powerd:isCharging()
        if is_charging then
            self:onCharging()
        end

        initialized = true
    end
end

function CalibreAutoconnect:loadCalibreModule()
    local calibreWirelessFilename = "plugins/calibre.koplugin/wireless.lua"
    local patchedLines = {}
    local patched = false

    -- Access wireless and local metadata variable
    local ok, wirelessModuleFile = pcall(io.lines, calibreWirelessFilename)
    if ok then
        for line in wirelessModuleFile do
            if line == "return CalibreWireless" then
                line = "return {wireless = CalibreWireless, metadata = CalibreMetadata}"
                patched = true
            end
            patchedLines[#patchedLines + 1] = line
        end
    else
        logger.warn("Calibre wireless module not found: ", calibreWirelessFilename)
        return nil
    end

    if not patched then
        logger.warn("Can't patch module: ", calibreWirelessFilename)
        return nil
    end

    local source = table.concat(patchedLines, "\n")
    local ok, module = pcall(loadstring, source)
    if not ok then
        logger.warn("Can't load patched module: ", calibreWirelessFilename)
        return nil
    end

    return module()
end

function CalibreAutoconnect:onCharging()
    if charging then
        return
    end
    charging = true
    UIManager:scheduleIn(1, tryConnect)
end

function CalibreAutoconnect:onNotCharging()
    if not charging then
        return
    end
    UIManager:unschedule(tryConnect)
    charging = false
    if calibre ~= nil and calibre.wireless.calibre_socket ~= nil then
        calibre.wireless:disconnect()
    end
end

function CalibreAutoconnect:onExit()
    if calibre ~= nil and calibre.wireless.calibre_socket ~= nil then
        calibre.wireless:disconnect()
    end
    if tryConnect ~= nil then
        UIManager:unschedule(tryConnect)
    end
end

function CalibreAutoconnect:checkConnectionAndTryConnect()
    if calibre == nil then
        return
    end
    if calibre.wireless.calibre_socket ~= nil or not charging then
        return
    end

    -- Required to configure inbox_dir and calibre_wireless_url first
    local inbox_dir = G_reader_settings:readSetting("inbox_dir")

    if G_reader_settings:has("calibre_wireless_url") and inbox_dir then
        local calibre_url = G_reader_settings:readSetting("calibre_wireless_url")
        host, port = calibre_url["address"], calibre_url["port"]

        local tcp = socket.tcp()
        tcp:settimeout(0.1)
        local client = tcp:connect(host, port)
        if client then
            tcp:close()
            calibre.metadata:init(inbox_dir)
            calibre.wireless:initCalibreMQ(host, port)
        else
            UIManager:scheduleIn(1, tryConnect)
        end
    end
end

return CalibreAutoconnect
