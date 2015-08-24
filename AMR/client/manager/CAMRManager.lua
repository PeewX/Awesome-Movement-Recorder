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
    self.gui = new(CAMRDesigner)

    self:initBinds()

    --outputs
    outputChatBox("Toggle GUI with lctrl + m")
end

function CAMRManager:destructor()

end

function CAMRManager:loadSettings()
    local xml = XML.load("res/config/config.xml")
    if not xml then return end

    self.keybinds = {}
    local keybinds = xml:findChild("keybinds", 0)
    for _, node in pairs(keybinds:getChildren()) do
        self.keybinds[node:getName()] = node:getValue()
    end

    outputChatBox(self.keybinds.key_record)

    self.color_ground = xml:findChild("color_ground", 0):getAttributes()
    self.color_air = xml:findChild("color_air", 0):getAttributes()

    xml:unload()
    self.bLoadedSettings = true
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

--[[function CAMRManager:toggleWindow()
    if getKeyState("lctrl") then
        self.gui:toggle()
    end
end]]