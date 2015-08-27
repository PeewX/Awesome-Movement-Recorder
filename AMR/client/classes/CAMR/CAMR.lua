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
    self.eVehicleDummy:setDimension(200) --Todo: Get dimension of player while recording

    self.record = {line = {}, vehicle = {}, frames = 0}
    self.recording = false
    self.renderPlayback = false
    self.playRecordFrame = 1

    self.renderRecordEvent = bind(CAMR.record, self)
    self.renderDrawEvent = bind(CAMR.renderLine, self)
    self.renderPlaybackEvent = bind(CAMR.renderPlayback, self)

    addEventHandler("onClientRender", root, self.renderDrawEvent)
end

function CAMR:destructor()

end

function CAMR:toggleRecording()
    if not self.recording then
        self:startRecording()
    else
        self:stopRecording()
    end
end

function CAMR:startRecording()
    if self.recording then return end
    if not localPlayer:isInVehicle() then outputChatBox("You are not in a vehicle!") return end

    --Reset table if there is already an record
    if self.record.frames ~= 0 then
        outputChatBox("Last record was cleared!")
        self.record = {line = {}, vehicle = {}, frames = 0}
    end

    self.eClientVehicle = localPlayer:getOccupiedVehicle()

    addEventHandler("onClientRender", root, self.renderRecordEvent)
    self.recording = true
end

function CAMR:stopRecording()
    if not self.recording then return end
    self.recording = false

    removeEventHandler("onClientRender", root, self.renderRecordEvent)
end

--maxV = 0
function CAMR:record()
    if not localPlayer:isInVehicle() then
        outputChatBox("You are not in a vehicle!")
        self:stopRecording()
        return
    end

    --Count frames; currently.. well idk why.. not rly needed
    self.record.frames = self.record.frames + 1


    --[[local vehVel = (Vector3.create(getElementVelocity(self.eClientVehicle))*180).length
    if vehVel > maxV then
        maxV = vehVel
    end
    outputChatBox(vehVel)]]

    --Fetching datas
    local nVehicleModel = self.eClientVehicle:getModel()
    local vector_VehPos = Vector3(self.eClientVehicle:getPosition())
    local vector_VehRot = Vector3(self.eClientVehicle:getRotation())

    --Save line datas
    if #self.record.line == 0 then
        table.insert(self.record.line, {pos = vector_VehPos, isOnGround = self.eClientVehicle:isOnGround()})
    end

    local distance = getDistanceBetweenPoints3D(vector_VehPos, self.record.line[#self.record.line].pos)
    if distance > 0.5 then
        table.insert(self.record.line, {pos = vector_VehPos, isOnGround = self.eClientVehicle:isOnGround()})
    end

    --Save vehicle datas
    table.insert(self.record.vehicle, {nVehicleModel = nVehicleModel, pos = vector_VehPos, rot = vector_VehRot})
end

function CAMR:updateFrame()
    local frame = self.record.vehicle[self.playRecordFrame]

    self.eVehicleDummy:setPosition(self.record.vehicle[self.playRecordFrame].pos)
    self.eVehicleDummy:setRotation(self.record.vehicle[self.playRecordFrame].rot)
    if frame.nVehicleModel ~= self.eVehicleDummy:getModel() then
        self.eVehicleDummy:setModel(frame.nVehicleModel)
    end
    Core:getManager("CAMRManager").gui:updateLabels(self.playRecordFrame, self.record.frames)
end

function CAMR:renderPlayback()
    if not self.eVehicleDummy then return end

    if self.playRecordFrame > #self.record.vehicle then
        self:stopPlayback()
        return
    end

    self:updateFrame()

    self.playRecordFrame = self.playRecordFrame + 1
end

function CAMR:renderLine()
    local st = getTickCount()
    for i, line in ipairs(self.record.line) do
        if self.record.line[i+1] then
           dxDrawLine3D(line.pos, self.record.line[i+1].pos, line.isOnGround and tocolor(0, 100, 255, 200) or tocolor(170, 170, 255, 200), 10)

           -- Just 4 fun :P
           -- dxDrawLine3D(line.pos, self.record.line[i+1].pos, tocolor(255/maxV*line.velocity, 255 - (255/maxV*line.velocity), 0, 255), 10)
        end
    end
   -- outputChatBox(("Rendered '%s' lines in %sms"):format(#self.record.line, getTickCount()-st))
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

    if self.playRecordFrame > #self.record.vehicle then
        self.playRecordFrame = 1
    end

    self.renderPlayback = true
    addEventHandler("onClientRender", root, self.renderPlaybackEvent)
    Core:getManager("CAMRManager").gui:updatePlaybackImage(self.renderPlayback)
end

function CAMR:stopPlayback()
    self.renderPlayback = false
    removeEventHandler("onClientRender", root, self.renderPlaybackEvent)
    Core:getManager("CAMRManager").gui:updatePlaybackImage(self.renderPlayback)
end
