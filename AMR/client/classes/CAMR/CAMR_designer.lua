--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 20.08.2015 - Time: 06:34
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CAMRDesigner = {}

function CAMRDesigner:constructor(tSettings)
    self.settings = tSettings
    self.renderFunc = bind(CAMRDesigner.onRender, self)
    self.clientRestoreEvent = bind(CAMRDesigner.onClientRestore, self)
    self.clientClickEvent = bind(CAMRDesigner.onClientClick, self)
    self.cursorMoveEvent = bind(CAMRDesigner.onCursorMove, self)

    self.activeMenu = "Home"

    self.images = {
        "circle_arrow_forward",
        "circle_arrow_previous",
        "circle_filled",
        "circle_unfilled",
        "circle_pause",
        "circle_play",
        "icon_menu",
        "icon_home",
        "icon_load",
        "icon_save",
        "icon_settings"
    }

    self:windowDefinitions()
    self:loadImages()

    self.subElements = {}
    self:createGUIElements()

    self.currentFrame = 0
    self.frameCount = 1

    self.currentStatePlaybackImage = self.circle_play

    self.renderTarget = DxRenderTarget(self.width, self.height, true)
    self:updateRenderTarget()

    addEventHandler("onClientRestore", root, self.clientRestoreEvent)
end

function CAMRDesigner:destructor()

end

function CAMRDesigner:createGUIElements()
    self.playbackSpeedScrollbar = new(CDXScrollbar, self.width - 30, 30, self.height - 34 - 45, false, self)
    self.playbackSpeedScrollbar:setDefaultValue(0.25, true)
    self.playbackSpeedScrollbar:setDisplayValues(0, 400)

    self.lineCheckbox = new(CDXCheckbox, "Show lines", 0, 0, self.settings.showLines, self)                                     --Position will set while updating render target
    self.crosshairCheckbox = new(CDXCheckbox, "Hide crosshair while GUI is open", 0, 0, self.settings.hideCrosshair, self)      --Position will set while updating render target
    self.vehicleInfoCheckbox = new(CDXCheckbox, "Vehicle informations", 0, 0, self.settings.showVehicleInfos, self)             --Position will set while updating render target
    self.velocityLineCheckbox = new(CDXCheckbox, "Vehicle speed line", 0, 0, self.settings.showVelocityLine, self)              --Position will set while updating render target

    self.lineCheckbox:setCallbackFunction(function(bState) Core:getManager("CAMRManager"):toggleLine(bState) end)
    self.crosshairCheckbox:setCallbackFunction(function(bState) Core:getManager("CAMRManager"):toggleCrosshair(bState) end)
    self.vehicleInfoCheckbox:setCallbackFunction(function(bState) Core:getManager("CAMRManager"):toggleVehicleInfo(bState) end)
    self.velocityLineCheckbox:setCallbackFunction(function(bState) Core:getManager("CAMRManager"):toggleVelocityLine(bState) end)
end

function CAMRDesigner:resetSubElements()
    for _, subElement in pairs(self.subElements) do
        subElement.active = false
    end
end

function CAMRDesigner:onClientClick(sButton, sState)
    if sButton ~= "left" or sState ~= "down" then self.timelinePressed = false return end

    if not self.showMenu and isHover(self.startX + 5, self.startY + 25, 24, 24) then
        self.showMenu = true
        return self:updateRenderTarget()
    elseif self.showMenu and not isHover(self.startX, self.startY + 20, 95, self.height - 20 - 34) then
        self.showMenu = false
        return self:updateRenderTarget()
    end

    if self.showMenu then
        local menuList = {"Home", "Save", "Load", "Settings"}
        local menuHeight = (self.height - 20 - 34)/4

        for i, menu in ipairs(menuList) do
            if isHover(self.startX, self.startY + 20 + menuHeight*(i-1), 95, menuHeight) then
                self.activeMenu = menu
                self.showMenu = false
                return self:updateRenderTarget()
            end
        end
    end

    --control: timeline
    local length = self.width - 10 - 100
    if isHover(self.startX + 100 + length/self.frameCount*self.currentFrame - 9, self.startY + self.height - 1 - 29/2-18/2, 18, 18) then
        Core:getManager("CAMRManager").AMR:stopPlayback()
        self.timelinePressed = true
        return
    end

    --control: previous frame
    if isHover(self.startX + 5, self.startY + self.height - 29, 24, 24) then
        Core:getManager("CAMRManager").AMR:previousFrame()
        return
    end

    --control: start/stop
    if isHover(self.startX + 34, self.startY + self.height - 29, 24, 24) then
        Core:getManager("CAMRManager").AMR:togglePlayback()
        return
    end

    --control: next frame
    if isHover(self.startX + 63, self.startY + self.height - 29, 24, 24) then
        Core:getManager("CAMRManager").AMR:nextFrame()
        return
    end
end

function CAMRDesigner:onCursorMove()
    if not isCursorShowing() then return end

    if self.showMenu then
        local menuList = {"Home", "Save", "Load", "Settings"}
        local menuHeight = (self.height - 20 - 34)/4


        if not isHover(self.startX, self.startY + 20, 95, (self.height - 20 - 34)) then
            self.menuHover = false
            return self:updateRenderTarget()
        end

        for i, menu in ipairs(menuList) do
            if isHover(self.startX, self.startY + 20 + menuHeight*(i-1), 95, menuHeight) then
                self.menuHover = menu
                return self:updateRenderTarget()
            end
        end
    end
end

function CAMRDesigner:show()
    self.rendered = true
    addEventHandler("onClientRender", root, self.renderFunc)
    addEventHandler("onClientClick", root, self.clientClickEvent)
    addEventHandler("onClientCursorMove", root, self.cursorMoveEvent)

    exports.editor_main:setMaxSelectDistance(0)         --To disable world clicks
    exports.editor_main:setWorldClickEnabled(false)     --disables world clicks too


    --exports.editor_main:enableMouseOver(false)
end

function CAMRDesigner:hide()
    self.rendered = false
    removeEventHandler("onClientRender", root, self.renderFunc)
    removeEventHandler("onClientClick", root, self.clientClickEvent)
    removeEventHandler("onClientCursorMove", root, self.cursorMoveEvent)

    exports.editor_main:setMaxSelectDistance(155) --155 is the default selection distance
    exports.editor_main:setWorldClickEnabled(true)
    --exports.editor_main:enableMouseOver(true)
end

function CAMRDesigner:onClientRestore(bRenderTargetsCleared)
    if bRenderTargetsCleared then
        self:updateRenderTarget()
    end
end

function CAMRDesigner:toggle()
    if self.rendered then
        --showCursor(false)--dev
        self:hide()
    else
        --showCursor(true)--dev
        self:show()
    end
end

function CAMRDesigner:windowDefinitions()
    self.width = 450
    self.height = 200

    self.startX = x-self.width
    self.startY = y-self.height
end

function CAMRDesigner:loadImages()
    for _, img in ipairs(self.images) do
       self[img] = DxTexture(("res/img/%s.png"):format(img))
    end
end

function CAMRDesigner:updatePlaybackImage(bPlaybackState)
    --If bPlaybackState is true, so the playback is rendered and the button have to be a pause button :P
    self.currentStatePlaybackImage = bPlaybackState and self.circle_pause or self.circle_play
    return self:updateRenderTarget()
end

function CAMRDesigner:updateLabels(indexTable, valueTable)
    for index in pairs(indexTable) do
       self[indexTable[index]] = valueTable[index]
    end

    self:updateRenderTarget()
end

function CAMRDesigner:updateRenderTarget()
    if not self.renderTarget then return end

    dxSetRenderTarget(self.renderTarget, true)
    dxDrawRectangle(0, 0, self.width, self.height, tocolor(80, 80, 80, 200))
    dxDrawRectangle(0, 0, self.width, 20, tocolor(40, 40, 40))
    dxDrawRectangle(0, self.height - 34, self.width, 34, tocolor(0, 180, 240, 180))
    dxDrawText("PewX Movement Recorder", 0, 0, self.width, 20, tocolor(230, 230, 230), 1, "default", "center", "center")

    dxDrawImage(5, self.height - 29, 24, 24, self.circle_arrow_previous)
    dxDrawImage(34, self.height - 29, 24, 24, self.currentStatePlaybackImage)
    dxDrawImage(63, self.height - 29, 24, 24, self.circle_arrow_forward)

    --Menus
    --Home
    --self.playbackSpeedScrollbar.active = false

    --Settings
    self:resetSubElements()

    if self.activeMenu == "Home" then
        dxDrawText("Press 'R' to start recording", 5, 50)
        dxDrawText("State", 5, 75)                                          dxDrawText(self.state or "-", 120, 75)
        dxDrawText("FPS", 5, 90)                                            dxDrawText(FPS or "-", 120, 90)
        dxDrawText("Recorded frames", 5, 105)                               dxDrawText(self.frameCount or "-", 120, 105)
        dxDrawText("Record duration", 5, 120)                               dxDrawText(self.recordDuration and msToTimeString(self.recordDuration) or "-", 120, 120)

        --dxDrawText("Current frame: " .. (self.currentFrame or "-"), 0, self.height - 34 - 15, self.width, 0, tocolor(255, 255, 255), 1, "default", "center")
        dxDrawText(self.elapsedTime and msToTimeString(self.elapsedTime) or "-", 100, self.height - 15, self.width - 10, 0, tocolor(255, 255, 255), 1, "default", "center")

        --playback speed
        dxDrawText("Duration multiplicator", self.width - 20, 20, self.width, self.height - 34, tocolor(255, 255, 255), 1, "default", "center", "center", false, false, false, false, false, 90)
        self.playbackSpeedScrollbar.active = true
        self.playbackSpeedScrollbar:render()
    elseif self.activeMenu == "Save" then

    elseif self.activeMenu == "Load" then

    elseif self.activeMenu == "Settings" then
        local checkboxHeight = self.crosshairCheckbox:getProperty("h") + 5
        local startY = self.height - 34 - checkboxHeight

        self.crosshairCheckbox:setProperty({"x", "y"}, {5, startY})

        startY = startY - checkboxHeight
        self.lineCheckbox:setProperty({"x", "y"}, {5, startY})

        startY = startY - checkboxHeight
        self.velocityLineCheckbox:setProperty({"x", "y"}, {5, startY})

        startY = startY - checkboxHeight
        self.vehicleInfoCheckbox:setProperty({"x", "y"}, {5, startY})

        --Set active and render dat shit
        self.lineCheckbox.active = true
        self.crosshairCheckbox.active = true
        self.velocityLineCheckbox.active = true
        self.vehicleInfoCheckbox.active = true

        self.lineCheckbox:render()
        self.crosshairCheckbox:render()
        self.velocityLineCheckbox:render()
        self.vehicleInfoCheckbox:render()
    end

    local length = self.width - 10 - 100
    dxDrawLine(100, self.height - 29/2 - 2, self.width - 10, self.height - 29/2 - 2, tocolor(100, 215, 255), 2)
    dxDrawImage(100 + length/self.frameCount*self.currentFrame - 9, self.height - 1 - 29/2-18/2, 18, 18, self.circle_filled, 0, 0, 0, tocolor(0, 180, 240))
    dxDrawImage(100 + length/self.frameCount*self.currentFrame - 9, self.height - 1 - 29/2-18/2, 18, 18, self.circle_unfilled, 0, 0, 0, tocolor(100, 215, 255))

    --Draw at last - so the menu is on first layer
    if not self.showMenu then
        dxDrawImage(5, 25, 24, 24, self.icon_menu)
    else
        self:resetSubElements()
        local menuList = {"Home", "Save", "Load", "Settings"}
        local menuHeight = (self.height - 20 - 34)/4

        for i, menu in ipairs(menuList) do
            dxDrawRectangle(0, 20 + menuHeight*(i-1), 95, menuHeight, self.menuHover == menu and tocolor(50, 50, 50, 250) or tocolor(80, 80, 80, 250))
            dxDrawImage(5, 20 + menuHeight*(i-1)+menuHeight/2-24/2, 24, 24, self[("icon_%s"):format(menu:lower())])
            dxDrawText(menu, 34, 20 + menuHeight*(i-1), 0, 20 + menuHeight*(i-1)+menuHeight, tocolor(180, 180, 180), 1, "default", "left", "center")
        end
    end

    dxSetRenderTarget()
end

function CAMRDesigner:onRender()
    if self.timelinePressed then
        local cursorPosX = getCursorPosition()

        local cursorTimelinePercent = 100/(self.width-10-100)*((cursorPosX*x)-self.startX-100)

        if cursorTimelinePercent < 0 then cursorTimelinePercent = 0.1 end
        if cursorTimelinePercent > 100 then cursorTimelinePercent = 100 end

        Core:getManager("CAMRManager").AMR.playRecordFrame =  math.ceil(self.frameCount/100*cursorTimelinePercent)
        Core:getManager("CAMRManager").AMR:updateFrame()

        self:updateRenderTarget()
    end

    dxDrawImage(self.startX, self.startY, self.width, self.height, self.renderTarget)
end

function CAMRDesigner:getPosition()
    return self.startX, self.startY
end