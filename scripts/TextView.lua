local _Graphic = UsingModule("Graphic")
local _String = UsingModule("String")
local _Algorithm = UsingModule("Algorithm")
local _Interactivity = UsingModule("Interactivity")

local _uFont = _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 16)

local _nTextHeight = _uFont:GetHeight()

local _tbText = {}

local _nMargin, _nBorder = 10, 5

local _nWidthScrollBar = 15

local _nPreviousY = 0

local _bSliderDown, _bSliderHover = false, false

local _rcSelf = {
    x = 90, y = 90,
    w = 395, h = 300
}

local _rcContent = {
    x = _rcSelf.x,
    y = _rcSelf.y,
    w = _rcSelf.w - _nBorder - _nWidthScrollBar,
    h = _rcSelf.h
}

local _rcViewPort = {
    x = 0,
    y = 0,
    w = _rcContent.w - _nMargin * 2,
    h = _rcContent.h - _nMargin * 2
}

local _rcScrollBar = {
    x = _rcSelf.x + _rcSelf.w - _nWidthScrollBar,
    y = _rcSelf.y,
    w = _nWidthScrollBar,
    h = _rcSelf.h
}

local _tbRenderedText = {}

local function _GetRCSlider()
    return {
        x = _rcScrollBar.x,
        y = _rcScrollBar.y + _rcViewPort.y / (_nTextHeight * #_tbText)
            * _rcScrollBar.h,
        w = _rcScrollBar.w,
        h = _rcViewPort.h / math.max(_nTextHeight * #_tbText, _rcViewPort.h)
            * _rcScrollBar.h
    }
end

local function _AppendText(str)
    -- 通过视口位置判断当前滑块是否到达底部
    local _bReachBottom = _rcViewPort.y + _rcViewPort.h == _nTextHeight * #_tbText
    -- 将过长的字符串分割添加至字符串列表
    while true do
        local _rawStrWidth, _rawStrHeight = _Graphic.GetUTF8TextSize(_uFont, str)
        if _rawStrWidth <= _rcViewPort.w then
            table.insert(_tbText, str)
            break
        else
            for index = _String.LenUTF8(str), 1, -1 do
                local _strTemp = _String.SubStrUTF8(str, 1, index)
                local _strWidth, _strHeight = _Graphic.GetUTF8TextSize(_uFont, _strTemp)
                if _strWidth <= _rcViewPort.w then
                    table.insert(_tbText, _strTemp)
                    str = _String.SubStrUTF8(str, index + 1)
                    break
                end
            end
        end
    end
    -- 如果滑块到达底部并且用户没有按下滑块，则移动视口到最底部（滑块滑动至最底）
    if _bReachBottom and (not _bSliderDown) then
        _rcViewPort.y = math.max(_nTextHeight * #_tbText, _rcViewPort.h) - _rcViewPort.h
    end
end

local function _HandleEvent(event)
    if event == _Interactivity.EVENT_MOUSESCROLL then
        local _horizontal, _vertical = _Interactivity.GetScrollValue()
        if _nTextHeight * #_tbText > _rcViewPort.h then
            _rcViewPort.y = _Algorithm.Clamp(
                _rcViewPort.y - _vertical * 10,
                0, _nTextHeight * #_tbText - _rcViewPort.h
            )
        end
    elseif event == _Interactivity.EVENT_MOUSEMOTION then
        _bSliderHover = _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), _GetRCSlider())
        if _bSliderDown then
            local _tbCursorPos = _Interactivity.GetCursorPosition()
            if _nTextHeight * #_tbText > _rcViewPort.h then
                _rcViewPort.y = _Algorithm.Clamp(_rcViewPort.y + (_tbCursorPos.y - _nPreviousY) 
                    * math.max(_nTextHeight * #_tbText, _rcViewPort.h) / _rcViewPort.h,
                    0, _nTextHeight * #_tbText - _rcViewPort.h
                )
                _nPreviousY = _tbCursorPos.y
            end
        end
    elseif event == _Interactivity.EVENT_MOUSEBTNDOWN_LEFT then
        local _tbCursorPos = _Interactivity.GetCursorPosition()
        if _Algorithm.CheckPointInRect(_tbCursorPos, _GetRCSlider()) then
            _bSliderDown = true
            _nPreviousY = _tbCursorPos.y
        end
    elseif event == _Interactivity.EVENT_MOUSEBTNUP_LEFT then
        _bSliderDown = false
    end
end

local function _DrawSelf()
    -- 绘制文本区域底色
    _Graphic.SetDrawColor({r = 25, g = 25, b = 25, a = 255})
    _Graphic.FillRectangle(_rcContent)
    -- 绘制文本区域立体边框线
    _Graphic.SetDrawColor({r = 215, g = 215, b = 215, a = 255})
    _Graphic.ThickLine(
        {x = _rcContent.x, y = _rcContent.y},
        {x = _rcContent.x, y = _rcContent.y + _rcContent.h},
        2
    )
    _Graphic.ThickLine(
        {x = _rcContent.x, y = _rcContent.y},
        {x = _rcContent.x + _rcContent.w, y = _rcContent.y},
        2
    )
    _Graphic.SetDrawColor({r = 135, g = 135, b = 135, a = 255})
    _Graphic.ThickLine(
        {x = _rcContent.x, y = _rcContent.y + _rcContent.h},
        {x = _rcContent.x + _rcContent.w, y = _rcContent.y + _rcContent.h},
        2
    )
    _Graphic.ThickLine(
        {x = _rcContent.x + _rcContent.w, y = _rcContent.y},
        {x = _rcContent.x + _rcContent.w, y = _rcContent.y + _rcContent.h},
        2
    )
    -- 绘制侧边滚动条底色
    _Graphic.SetDrawColor({r = 25, g = 25, b = 25, a = 255})
    _Graphic.FillRectangle(_rcScrollBar)
    -- 绘制侧边滚动条滑块部分
    if _bSliderDown then
        _Graphic.SetDrawColor({r = 165, g = 165, b = 165, a = 255})
    elseif _bSliderHover then
        _Graphic.SetDrawColor({r = 205, g = 205, b = 205, a = 255})
    else
        _Graphic.SetDrawColor({r = 185, g = 185, b = 185, a = 255})
    end
    _Graphic.FillRectangle(_GetRCSlider(), 5)
    -- 绘制侧边滚动条边框线
    _Graphic.SetDrawColor({r = 215, g = 215, b = 215, a = 255})
    _Graphic.ThickLine(
        {x = _rcScrollBar.x, y = _rcScrollBar.y},
        {x = _rcScrollBar.x, y = _rcScrollBar.y + _rcScrollBar.h},
        2
    )
    _Graphic.ThickLine(
        {x = _rcScrollBar.x, y = _rcScrollBar.y},
        {x = _rcScrollBar.x + _rcScrollBar.w, y = _rcScrollBar.y},
        2
    )
    _Graphic.SetDrawColor({r = 135, g = 135, b = 135, a = 255})
    _Graphic.ThickLine(
        {x = _rcScrollBar.x, y = _rcScrollBar.y + _rcScrollBar.h},
        {x = _rcScrollBar.x + _rcScrollBar.w, y = _rcScrollBar.y + _rcScrollBar.h},
        2
    )
    _Graphic.ThickLine(
        {x = _rcScrollBar.x + _rcScrollBar.w, y = _rcScrollBar.y},
        {x = _rcScrollBar.x + _rcScrollBar.w, y = _rcScrollBar.y + _rcScrollBar.h},
        2
    )
    -- 绘制文本内容
    local _rcCopyDst = {
        x = _rcContent.x + _nMargin,
        y = _rcContent.y + _nMargin,
        w = _rcViewPort.w,
        h = _rcViewPort.h
    }
    for index = 1, _rcViewPort.y // _nTextHeight + 1 do
        _tbRenderedText[index] = nil
    end
    for index = _rcViewPort.y // _nTextHeight + 1, #_tbText do
        -- 如果已渲染列表中没有当前文本图片，则渲染此文本
        if not _tbRenderedText[index] then
            local _image = _Graphic.CreateUTF8TextImageBlended(
                _uFont, _tbText[index],
                {r = 200, g = 200, b = 200, a = 255}
            )
            local _width, _height = _image:GetSize()
            _tbRenderedText[index] = {
                texture = _Graphic.CreateTexture(_image),
                width = _width
            }
        end 
        if _nTextHeight * (index - 1) < _rcViewPort.y then
            local _rectCut = {
                x = 0,
                y = _rcViewPort.y - _nTextHeight * (index - 1),
                w = _rcViewPort.w,
                h = _nTextHeight * index - _rcViewPort.y
            }
            _Graphic.CopyReshapeTexture(_tbRenderedText[index].texture, _rectCut, {
                x = _rcCopyDst.x,
                y = _rcCopyDst.y,
                w = _tbRenderedText[index].width,
                h = _rectCut.h
            })
        elseif _nTextHeight * index > _rcViewPort.y + _rcViewPort.h then
            local _rectCut = {
                x = 0,
                y = 0,
                w = _rcViewPort.w,
                h = _rcViewPort.y + _rcViewPort.h - _nTextHeight * (index - 1)
            }
            _Graphic.CopyReshapeTexture(_tbRenderedText[index].texture, _rectCut, {
                x = _rcCopyDst.x,
                y = _rcCopyDst.y + _rcCopyDst.h - _rectCut.h,
                w = _tbRenderedText[index].width,
                h = _rectCut.h
            })
            break
        else
            _Graphic.CopyTexture(_tbRenderedText[index].texture, {
                x = _rcCopyDst.x,
                y = _rcCopyDst.y + _nTextHeight * (index - 1) - _rcViewPort.y,
                w = _tbRenderedText[index].width,
                h = _nTextHeight
            })
        end
    end
end

return {
    AppendText = _AppendText,
    HandleEvent = _HandleEvent,
    DrawSelf = _DrawSelf
}