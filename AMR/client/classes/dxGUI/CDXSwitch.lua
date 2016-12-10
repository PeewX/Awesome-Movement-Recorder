--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 25.01.2016 - Time: 06:48
-- pewx.de // pewbox.org // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CDXSwitch = inherit(CDXManager)

--Warning: Only works with a parent that use a render target, otherwise it won't work correctly!
function CDXSwitch:constructor(nDiffX, nDiffY, nWidth, nHeight, bState, parent)
    self.x = nDiffX
    self.y = nDiffY
    self.w = nWidth    --Default: 115
    self.h = nHeight   --Default: 35
    self.state = bState
    self.font = dxCreateFont("res/font/NewRepublic.ttf", 11, true, "cleartype_natural")

    if parent then
        self.parent = parent

        if self.parent.subElements then
            table.insert(self.parent.subElements)
        end
    end

    self.clickFunc = bind(CDXSwitch.onSwitchClick, self)

    addEventHandler("onClientClick", root, self.clickFunc)
end

function CDXSwitch:destructor()

end

---
-- Events
---

function CDXSwitch:onSwitchClick(sButton, sState)
    if not self.active then return end

    if sButton ~= "left" or sState ~= "down" then
        return
    end

    local pX, pY = self.parent:getPosition()

    if isHover(pX + self.x, pY + self.y, self.w, self.h) then
        self.state = not self.state
        if self.callbackFunction then
            self.callbackFunction(self.state)
        end
        Core:getManager("CAMRManager").gui:updateRenderTarget()
    end
end

---
-- Render - Called from CDX_Manager or otherwise
---

function CDXSwitch:render()
    dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(255, 255, 255))
    dxDrawRectangle(self.x + 2, self.y + 2, self.w - 4, self.h - 4, tocolor(200, 200, 200))

    if self.state then
        dxDrawRectangle(self.x + 2, self.y + 2, (self.w-4)/2, self.h - 4, tocolor(80, 170, 255))
    else
        --dxDrawRectangle(self.x + 2 + (self.w-4)/2, self.y + 2, (self.w-4)/2, self.h - 4, tocolor(0, 150, 255))
        dxDrawRectangle(self.x + 2 + (self.w-4)/2, self.y + 2, (self.w-4)/2, self.h - 4, tocolor(255, 80, 80))
    end

    dxDrawText("ON", self.x, self.y, self.x + self.w/2, self.y + self.h, self.state and tocolor(255, 255, 255) or tocolor(150, 150, 150), 1, self.font, "center", "center")
    dxDrawText("OFF", self.x + self.w/2, self.y, self.x + self.w, self.y + self.h, self.state and tocolor(150, 150, 150) or tocolor(255, 255, 255), 1, self.font, "center", "center")
end