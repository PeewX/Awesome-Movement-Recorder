--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 21.08.2015 - Time: 11:51
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CAMR = {}

function CAMR:constructor()
    self.eVehicleDummy = Vehicle(411, 1337, 1337, 1337)
    self.eVehicleDummy:setPlateText("AMR Dummy")
    self.eVehicleDummy:setFrozen(true)
    self.eVehicleDummy:setCollisionsEnabled(false)
    setVehicleOverrideLights(self.eVehicleDummy, 2) --no methode is available lel :D

    exports.editor_main:registerEditorElements(self.eVehicleDummy)

    self.record = {line = {}, vehicle = {}}
    self.recording = false
    self.renderPlayback = false
    self.playRecordFrame = 1

    self.renderRecordEvent = bind(CAMR.record, self)
    self.renderLineEvent = bind(CAMR.renderLine, self)
    self.renderPlaybackEvent = bind(CAMR.renderPlayback, self)

    self.renderLine = addEventHandler("onClientRender", root, self.renderLineEvent)
end

function CAMR:destructor()

end

function CAMR:toggleRecording()
    if self.renderPlayback then outputChatBox("cant let you do this while playing record!") return end

    if not self.recording then
        self:startRecording()
    else
        self:stopRecording()
    end
end

function CAMR:startRecording()
    if self.recording then return end
    if not localPlayer:isInVehicle() then outputChatBox("You are not in a vehicle!") return end

    --Show the lines on record
    self:showLine()

    --Reset table if there is already an record
    if self.record.frames ~= 0 then
        outputChatBox("Last record was cleared!")
        self.record = {line = {}, vehicle = {}}
    end

    self.eClientVehicle = localPlayer:getOccupiedVehicle()

    addEventHandler("onClientRender", root, self.renderRecordEvent)
    self.recordStart = getTickCount()
    self.recording = true
    Core:getManager("CAMRManager").gui:updateLabels({"state"}, {"Recording"})
end

function CAMR:stopRecording()
    if not self.recording then return end
    self.recording = false
    removeEventHandler("onClientRender", root, self.renderRecordEvent)

    self.record.duration = getTickCount() - self.recordStart
    Core:getManager("CAMRManager").gui:updateLabels({"recordDuration", "state"}, { self.record.duration, "-"})
end

function CAMR:record()
    if not localPlayer:isInVehicle() then
        outputChatBox("You are not in a vehicle!")
        self:stopRecording()
        return
    end

    --[[local vehVel = (Vector3.create(getElementVelocity(self.eClientVehicle))*180).length
    if vehVel > maxV then
        maxV = vehVel
    end
    outputChatBox(vehVel)]]

    --Fetching datas
    local nVehicleModel = self.eClientVehicle:getModel()
    local vector_VehPos = Vector3(self.eClientVehicle:getPosition())
    local vector_VehRot = Vector3(self.eClientVehicle:getRotation())
    local tVehicleColor = {self.eClientVehicle:getColor()}
    local elapsedTime = getTickCount() - self.recordStart

    --Save line datas
    if #self.record.line == 0 then
        table.insert(self.record.line, {pos = vector_VehPos, isOnGround = self.eClientVehicle:isOnGround()})
    end

    local distance = getDistanceBetweenPoints3D(vector_VehPos, self.record.line[#self.record.line].pos)
    if distance > 0.5 then
        table.insert(self.record.line, {pos = vector_VehPos, isOnGround = self.eClientVehicle:isOnGround()})
    end

    --Save vehicle datas
    table.insert(self.record.vehicle, {nVehicleModel = nVehicleModel, pos = vector_VehPos, rot = vector_VehRot, color = tVehicleColor, elapsedTime = elapsedTime})
    Core:getManager("CAMRManager").gui:updateLabels({"frameCount"}, {#self.record.vehicle})
end

function CAMR:updateFrame()
    local frame = self.record.vehicle[self.playRecordFrame]
    if not frame then return end

    self.eVehicleDummy:setPosition(frame.pos)
    self.eVehicleDummy:setRotation(frame.rot)
    self.eVehicleDummy:setDimension(localPlayer.dimension)

    if frame.nVehicleModel ~= self.eVehicleDummy:getModel() then
        self.eVehicleDummy:setModel(frame.nVehicleModel)
    end

    setVehicleColor(self.eVehicleDummy, unpack(frame.color))

    --Core:getManager("CAMRManager").gui:updateLabels(self.playRecordFrame, self.record.frames)
    --Core:getManager("CAMRManager").gui:updateLabels({"currentFrame", "frameCount"}, {self.playRecordFrame, #self.record.vehicle})
    Core:getManager("CAMRManager").gui:updateLabels({"currentFrame", "elapsedTime"}, {self.playRecordFrame, frame.elapsedTime})
end

function CAMR:renderPlayback()
    if not self.eVehicleDummy then return end

    local playbackProgress = (getTickCount() - self.playbackStart) / ((self.playbackStart + self.playbackDuration) - self.playbackStart)
    self.playRecordFrame = math.floor(interpolateBetween(self.playbackStartFrame, 0, 0, #self.record.vehicle, 0, 0, playbackProgress, "Linear"))

    self:updateFrame()

    if playbackProgress >= 1 then
        self:stopPlayback()
    end
end

function CAMR:renderLine()
    for i, line in ipairs(self.record.line) do
        if self.record.line[i+1] then
           dxDrawLine3D(line.pos, self.record.line[i+1].pos, line.isOnGround and tocolor(0, 100, 255, 200) or tocolor(170, 170, 255, 200), 5)

           -- Just 4 fun :P
           -- dxDrawLine3D(line.pos, self.record.line[i+1].pos, tocolor(255/maxV*line.velocity, 255 - (255/maxV*line.velocity), 0, 255), 10)
        end
    end
end

---
-- Methodes to control the lines
---
function CAMR:toggleLine()
    if self.renderLine then
        self:hideLine()
    else
        self:showLine()
    end
end

function CAMR:showLine()
    if not self.renderLine then
        self.renderLine = true
        addEventHandler("onClientRender", root, self.renderLineEvent)
    end
end

function CAMR:hideLine()
    if self.renderLine then
        self.renderLine = false
        removeEventHandler("onClientRender", root, self.renderLineEvent)
    end
end

---
-- Controls to toggle playback or render next/previous recorded frame
---
function CAMR:previousFrame()
    if self.renderPlayback then return end
    self.playRecordFrame = self.playRecordFrame - 1

    if self.playRecordFrame < 1 then
        self.playRecordFrame = #self.record.vehicle
    end

    self:updateFrame()
end

function CAMR:nextFrame()
    if self.renderPlayback then return end
    self.playRecordFrame = self.playRecordFrame + 1

    if self.playRecordFrame > #self.record.vehicle then
        self.playRecordFrame = 1
    end

    self:updateFrame()
end

function CAMR:togglePlayback()
    if self.recording then outputChatBox("cant let you do this while recording!") return end

    if not self.renderPlayback then
        self:startPlayback()
        return
    end

    if self.renderPlayback then
        self:stopPlayback()
        return
    end
end

function CAMR:startPlayback()
    if not self.eVehicleDummy then return end

    if self.playRecordFrame >= #self.record.vehicle then
        self.playRecordFrame = 1
    end

    self.playbackStart = getTickCount()
    self.playbackStartFrame = self.playRecordFrame or 1

    if not (self.record.duration and self.record.vehicle[self.playbackStartFrame]) then return end

    self.playbackDuration = self.record.duration - self.record.vehicle[self.playbackStartFrame].elapsedTime

    self.renderPlayback = true
    addEventHandler("onClientRender", root, self.renderPlaybackEvent)
    Core:getManager("CAMRManager").gui:updatePlaybackImage(self.renderPlayback)
    Core:getManager("CAMRManager").gui:updateLabels({"state"}, {"Playing"})
end

function CAMR:stopPlayback()
    self.renderPlayback = false
    removeEventHandler("onClientRender", root, self.renderPlaybackEvent)
    Core:getManager("CAMRManager").gui:updatePlaybackImage(self.renderPlayback)
    Core:getManager("CAMRManager").gui:updateLabels({"state"}, {"-"})
end
