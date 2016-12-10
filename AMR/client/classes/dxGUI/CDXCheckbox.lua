--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 15 Ultimate
-- Date: 26.01.2016 - Time: 04:22
-- pewx.de // pewbox.org // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CDXCheckbox = inherit(CDXManager)

--Warning: Only works with a parent that use a render target, otherwise it won't work correctly!
function CDXCheckbox:constructor(sText, nDiffX, nDiffY, bChecked, parent)
    self.title = sText or ""
    self.x = nDiffX
    self.y = nDiffY
    self.w = 16
    self.h = 16
    self.checked = bChecked or false

    if parent then
        self.parent = parent

        if self.parent.subElements then
            table.insert(self.parent.subElements, self)
        end
    end

    self.clickFunc = bind(CDXCheckbox.onCheckboxClick, self)
    addEventHandler("onClientClick", root, self.clickFunc)
end

function CDXCheckbox:destructor()

end

---
-- Events
---

function CDXCheckbox:onCheckboxClick(sButton, sState)
    if not self.active then return end
    if sButton ~= "left" or sState ~= "down" then return end

    local pX, pY = self.parent:getPosition()

    if isHover(pX + self.x, pY + self.y, self.w + self.titleWidth, self.h) then
        self.checked = not self.checked
        if self.callbackFunction then
            self.callbackFunction(self.checked)
        end

        Core:getManager("CAMRManager").gui:updateRenderTarget()
    end
end

function CDXCheckbox:render()
    self.titleSpace = 4
    self.titleWidth = dxGetTextWidth(self.title, 1, "default") + self.titleSpace
    self.titleStartX = self.x + self.w + self.titleSpace

    dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0, 0, 0))
    dxDrawRectangle(self.x + 1, self.y + 1, self.w - 2, self.h - 2, tocolor(255, 255, 255))

    if self.checked then
        dxDrawRectangle(self.x + 3, self.y + 3, self.w - 6, self.h - 6, tocolor(50, 120, 255))
    end

    dxDrawText(self.title, self.titleStartX, self.y, self.titleStartX + self.titleWidth, self.y + self.h, tocolor(255, 255, 255), 1, "default", "left", "center")
end