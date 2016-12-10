--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 20.08.2015 - Time: 06:37
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CAMRManager = {}

function CAMRManager:constructor()
    self:loadSettings()

    --instantiate classes
    self.AMR = new(CAMR)
    self.gui = new(CAMRDesigner, self.settings)

    self:initBinds()

    --outputs
    outputChatBox("|AMR| #009DD1Toggle GUI with lctrl + m", 255, 255, 255, true)
end

function CAMRManager:destructor()

end

function CAMRManager:initBinds()
    if not self.bLoadedSettings then return end
    --self.toggleWindowFunc = bind(CAMRManager.toggleWindow, self)
    bindKey("m", "down",
        function()
            if getKeyState("lctrl") then
                self.gui:toggle()
            end
        end
    )

    self.recordingFunc = bind(CAMR.toggleRecording, self.AMR)
    bindKey(self.keybinds.key_record, "down", self.recordingFunc)

    self.previousFrameFunc = bind(CAMR.previousFrame, self.AMR)
    bindKey(self.keybinds.key_previous, "down", self.previousFrameFunc)

    self.nextFrameFunc = bind(CAMR.nextFrame, self.AMR)
    bindKey(self.keybinds.key_next, "down", self.nextFrameFunc)

    self.togglePlaybackFunc = bind(CAMR.togglePlayback, self.AMR)
    bindKey(self.keybinds.key_togglePlayback, "down", self.togglePlaybackFunc)
end

---
-- Settings
---

function CAMRManager:loadSettings()
    local xml = XML.load("res/config/config.xml")
    if not xml then return end

    self.keybinds = {}
    local keybinds = xml:findChild("keybinds", 0)
    for _, node in pairs(keybinds:getChildren()) do
        self.keybinds[node:getName()] = node:getValue()
    end

    self.settings = {}
    local settings = xml:findChild("settings", 0)
    for _, node in pairs(settings:getChildren()) do
        self.settings[node:getName()] = toboolean(node:getValue())
    end

    self.color_ground = xml:findChild("color_ground", 0):getAttributes()
    self.color_air = xml:findChild("color_air", 0):getAttributes()

    xml:unload()
    self.bLoadedSettings = true
end

function CAMRManager:saveSettings()
    --Todo: MACH HINNE!!
end

function CAMRManager:getSettings(settingIndex)
    --assert(self.setting[settingIndex], "Invalid argument @ getSetting: Index not exist")
    outputChatBox("Return: " .. tostring(self.setting[settingIndex]))
    return self.setting[settingIndex]
end

---
-- Callback functions
---

function CAMRManager:toggleLine(primaryState)
    self.settings["showLines"] = primaryState

    if primaryState then
        self.AMR:showLine()
    else
        self.AMR:hideLine()
    end
end

function CAMRManager:toggleCrosshair(primaryState)

end

function CAMRManager:toggleVehicleInfo(primaryState)

end

function CAMRManager:toggleVelocityLine(primaryLine)

end