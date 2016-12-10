--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 19.12.2014 - Time: 18:19
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CDXManager = {}

function CDXManager:constructor()
    self.windows = {}
end

function CDXManager:destructor()

end

function CDXManager:show()
    addEventHandler("onClientRender", root, self.onRenderFunc)
    if self.onCloseButtonClickFunc then addEventHandler("onClientClick", root, self.onCloseButtonClickFunc) end
    if self.subElements then
        for _, subElement in ipairs(self.subElements) do
            subElement:addClickHandler()
        end
    end
    self.isVisible = true
end

function CDXManager:hide()
    removeEventHandler("onClientRender", root, self.onRenderFunc)
    removeEventHandler("onClientClick", root, self.onCloseButtonClickFunc)
    for _, subElement in ipairs(self.subElements) do
        subElement:removeClickHandler()
    end
    self.isVisible = false
end

function CDXManager:onClick(btn, st)
    if btn == "left" and st == "down" then
        if not self.parent.isActive then return end
        if isHover(self.x, self.y, self.w, self.h) then
            for _, aFunc in ipairs(self.clickExecute) do
                aFunc(self)
            end
        end
    end
end

function CDXManager:addClickFunction(fCallFunc)
    if not self.clickExecute then self.clickExecute = {} end
    table.insert(self.clickExecute, bind(fCallFunc, self))
    if not self.onClickFunc then self.onClickFunc = bind(self.onClick, self) end
end

function CDXManager:removeClickFunction(fCallFunc)
    if self.clickExecute then
        for i, callFunc in ipairs(self.clickExecute) do
            if callFunc == fCallFunc then
                table.remove(self.clickExecute, i)
            end
        end
    end
end

function CDXManager:getProperty(sKey)
    return self[sKey]
end

function CDXManager:setProperty(key, value)
    local keyType, valueType = type(key), type(value)
    if keyType == "table" or valueType == "table" then
        assert(keyType == "table", "Invalid argument @setProperty: First argument is not a table")
        assert(valueType == "table", "Invalid argument @setProperty: Seccond argument is not a table")

        for index in pairs(key) do
           self[key[index]] = value[index]
        end
        return
    end

    self[key] = value
end

function CDXManager:setCallbackFunction(aFunction)
    self.callbackFunction = aFunction
end

function CDXManager:addClickHandler()
    addEventHandler("onClientClick", root, self.onClickFunc)
end

function CDXManager:removeClickHandler()
    removeEventHandler("onClientClick", root, self.onClickFunc)
end

function CDXManager:registerWindow(eWindow)
    table.insert(self.windows, eWindow)
end

function CDXManager:unregisterWindow(eWindow)
    for i, window in ipairs(self.windows) do
        if window == eWindow then
            table.remove(self.windows, i)
        end
    end
end

new(CDXManager)