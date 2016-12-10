--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 22.01.2016 - Time: 13:59
-- pewx.de // pewbox.org // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CDXScrollbar = inherit(CDXManager)

--Warning: Only works with a parent that use a render target, otherwise it won't work correctly!
function CDXScrollbar:constructor(nDiffX, nDiffY, nWidth, bHorizontal, parent)
    self.x = nDiffX
    self.y = nDiffY
    self.w = bHorizontal and nWidth or 20
    self.h = bHorizontal and 20 or nWidth
    self.horizontal = bHorizontal
    self.defaultValue = 0
    self.value = 0

    self.displayMinValue = 0
    self.displayMaxValue = 100

    if parent then
        self.parent = parent

        if self.parent.subElements then
            table.insert(self.parent.subElements, self)
        end
    end

    self.clickFunc = bind(CDXScrollbar.onScrollbarClick, self)
    self.moveFunc = bind(CDXScrollbar.onScrollbarMove, self)

    addEventHandler("onClientClick", root, self.clickFunc)
end

function CDXScrollbar:destructor()

end

---
-- Events
---

function CDXScrollbar:onScrollbarClick(sButton, sState)
    if not self.active then return end

    if sState ~= "down" then
        self.clicked = false
        removeEventHandler("onClientCursorMove", root, self.moveFunc)
        Core:getManager("CAMRManager").gui:updateRenderTarget()
        return
    end

    local pX, pY = self.parent:getPosition()

    if self.horizontal then
        if isHover(pX + self.x, pY + self.y  - self.h/2, self.w, self.h) then

            if sButton == "left" then
                self.clicked = true
            elseif sButton == "middle" then
                self.value = self.defaultValue
                Core:getManager("CAMRManager").gui:updateRenderTarget()
                return
            end
        else
            self.clicked = false
        end
    else
        if isHover(pX + self.x - self.w/2, pY + self.y, self.w, self.h) then
            if sButton == "left" then
                self.clicked = true
            elseif sButton == "middle" then
                self.value = self.defaultValue
                Core:getManager("CAMRManager").gui:updateRenderTarget()
                return
            end
        else
            self.clicked = false
        end
    end

    if self.clicked then
        self:onScrollbarMove() -- handle click as move to set the value to the click position
        addEventHandler("onClientCursorMove", root, self.moveFunc)
    end
end

function CDXScrollbar:onScrollbarMove()
    if not isCursorShowing() then return end

    if not self.clicked then
        removeEventHandler("onClientCursorMove", root, self.moveFunc)
        return
    end

    local cursorPosX, cursorPosY = getCursorPosition()
    local pX, pY = self.parent:getPosition()

    if self.horizontal then
        self.rawScrollbarPercent = 100/self.w*((cursorPosX*x)-(pX+self.x))
    else
        self.rawScrollbarPercent = 100/self.h*((cursorPosY*y)-(pY+self.y))

    end

    if self.rawScrollbarPercent < 0 then self.rawScrollbarPercent = 0 end
    if self.rawScrollbarPercent > 100 then self.rawScrollbarPercent = 100 end

    self.value = self.rawScrollbarPercent/100
    Core:getManager("CAMRManager").gui:updateRenderTarget()
end

---
-- Set/Get functions
---

function CDXScrollbar:setDefaultValue(nValue, bApply)
    self.defaultValue = nValue
    if bApply then
        self.value = self.defaultValue
    end
end

function CDXScrollbar:setValue(nValue)
    self.value = nValue
end

function CDXScrollbar:getValue()
    return self.value
end

function CDXScrollbar:setDisplayValues(minValue, maxValue)
    self.displayMinValue = minValue or 0
    self.displayMaxValue = maxValue or 100
end

---
-- Render - Called from CDX_Manager or otherwise
---

function CDXScrollbar:render()
    if self.horizontal then
        --dxDrawRectangle(self.x, self.y  - self.h/2, self.w, self.h, tocolor(255, 0, 0, 100))--shows where the scrollbar is clickable

        dxDrawLine(self.x, self.y, self.x + self.w, self.y, tocolor(255, 255, 255), 2)
        dxDrawRectangle(self.x + (self.w*self.value) - 6, self.y - 6, 12, 12, self.clicked and tocolor(255, 100, 0) or tocolor(255, 0, 0))       --Todo: Color or new icon

        dxDrawRectangle(self.x + ((self.w*self.value) - 6) - 30, self.y - 6, 25, 12, tocolor(50, 50,50, 255))
    else
        --dxDrawRectangle(self.x - self.w/2, self.y, self.w, self.h, tocolor(255, 0, 0, 100))--shows where the scrollbar is clickable

        dxDrawLine(self.x, self.y, self.x, self.y + self.h, tocolor(255, 255, 255), 2)
        dxDrawRectangle(self.x - 6, self.y + (self.h*self.value) - 6, 12, 12, self.clicked and tocolor(255, 100, 0) or tocolor(255, 0, 0))          --Todo: Color or new icon

        if self.clicked then
            local rectSX, rectSY = self.x - 6 - 40, self.y + (self.h*self.value) - 8
            dxDrawRectangle(rectSX, rectSY, 35, 16, tocolor(100, 100, 100, 200))

            local interpolatedPlaybackSpeed = interpolateBetween(self.displayMinValue, 0, 0, self.displayMaxValue, 0, 0, self.value, "Linear")
            dxDrawText(("%s%%"):format(math.floor(interpolatedPlaybackSpeed)), rectSX, rectSY, rectSX + 35, rectSY + 16, tocolor(255, 255, 255), 1, "default", "center", "center")
        end
    end
end