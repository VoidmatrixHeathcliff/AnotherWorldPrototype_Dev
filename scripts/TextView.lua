local _Graphic = UsingModule("Graphic")
local _String = UsingModule("String")
local Algorithm = UsingModule("Algorithm")
local _Interactivity = UsingModule("Interactivity")

local _tbText = {}

local _tbMultilineText = {}

local _nMargin, _nBorder = 10, 5

local _nWidthScrollBar = 15

local _rcSelf = {
    x = 90, y = 90,
    w = 395, h = 195
}

local function _GetRCScrollBar()
    return {
        x = _rcSelf.x + _rcSelf.w - _nWidthScrollBar,
        y = _rcSelf.y,
        w = _nWidthScrollBar,
        h = _rcSelf.h
    }
end

local function _GetRCContent()
    return {
        x = _rcSelf.x,
        y = _rcSelf.y,
        w = _rcSelf.w - _nBorder - _nWidthScrollBar,
        h = _rcSelf.h
    }
end

local _rcViewPort = {
    x = 0,
    y = 0,
    w = _GetRCContent().w - _nMargin * 2,
    h = _GetRCContent().h - _nMargin * 2
}

local _uFont = _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 15)

local function _GetTextHeight()
    return _uFont:GetHeight()
end

local function _AppendText(str)
    table.insert(_tbText, str)
    local _rcViewPort = _rcViewPort
    while true do
        local _rawStrWidth, _rawStrHeight = _Graphic.GetUTF8TextSize(_uFont, str)
        if _rawStrWidth <= _rcViewPort.w then
            table.insert(_tbMultilineText, str)
            break
        else
            for index = _String.LenUTF8(str), 1, -1 do
                local _strTemp = _String.SubStrUTF8(str, 1, index)
                local _strWidth, _strHeight = _Graphic.GetUTF8TextSize(_uFont, _strTemp)
                if _strWidth <= _rcViewPort.w then
                    table.insert(_tbMultilineText, _strTemp)
                    str = _String.SubStrUTF8(str, index + 1)
                    break
                end
            end
        end
    end
end

local function _HandleEvent(event)
    if event == _Interactivity.EVENT_MOUSESCROLL then
        local _horizontal, _vertical = _Interactivity.GetScrollValue()
        if _GetTextHeight() * #_tbMultilineText > _rcViewPort.h then
            _rcViewPort.y = Algorithm.Clamp(_rcViewPort.y - _vertical * 10, 0, _GetTextHeight() * #_tbMultilineText - _rcViewPort.h)
        end
    end
end

local function _DrawSelf()
    local _rcViewPort = _rcViewPort
    local _rcContent = _GetRCContent()
    local _rcCopyDst = {
        x = _rcContent.x + _nMargin,
        y = _rcContent.y + _nMargin,
        w = _rcContent.w - _nMargin * 2,
        h = _rcContent.h - _nMargin * 2
    }
    local _nTextHeight = _GetTextHeight()
    for index = _rcViewPort.y // _nTextHeight + 1, #_tbMultilineText do
        local _image = _Graphic.CreateUTF8TextImageBlended(_uFont, _tbMultilineText[index], {r = 200, g = 200, b = 200, a = 255})
        local _texture = _Graphic.CreateTexture(_image)
        local _width, _height = _image:GetSize()
        if _nTextHeight * (index - 1) < _rcViewPort.y then
            local _rectCut = {
                x = 0,
                y = _rcViewPort.y - _nTextHeight * (index - 1),
                w = _rcViewPort.w,
                h = _nTextHeight * index - _rcViewPort.y
            }
            _Graphic.CopyReshapeTexture(_texture, _rectCut, {
                x = _rcCopyDst.x,
                y = _rcCopyDst.y,
                w = _width,
                h = _rectCut.h
            })
        elseif _nTextHeight * index > _rcViewPort.y + _rcViewPort.h then
            local _rectCut = {
                x = 0,
                y = 0,
                w = _rcViewPort.w,
                h = _rcViewPort.y + _rcViewPort.h - _nTextHeight * (index - 1)
            }
            _Graphic.CopyReshapeTexture(_texture, _rectCut, {
                x = _rcCopyDst.x,
                y = _rcCopyDst.y + _rcCopyDst.h - _rectCut.h,
                w = _width,
                h = _rectCut.h
            })
            break
        else
            _Graphic.CopyTexture(_texture, {
                x = _rcCopyDst.x,
                y = _rcCopyDst.y + _nTextHeight * (index - 1) - _rcViewPort.y,
                w = _width,
                h = _nTextHeight
            })
        end
    end

    _Graphic.SetDrawColor({r = 255, g = 255, b = 255, a = 255})
    _Graphic.RoundRectangle(_GetRCContent(), 5)

    local _rcScrollBar = _GetRCScrollBar()
    _Graphic.RoundRectangle(_rcScrollBar, 5)
    _Graphic.FillRoundRectangle({
        x = _rcScrollBar.x,
        y = _rcScrollBar.y + _rcViewPort.y / (_nTextHeight * #_tbMultilineText) * _rcScrollBar.h,
        w = _rcScrollBar.w,
        h = _rcViewPort.h / (_nTextHeight * #_tbMultilineText) * _rcScrollBar.h
    }, 5)
end

return {
    AppendText = _AppendText,
    HandleEvent = _HandleEvent,
    DrawSelf = _DrawSelf
}