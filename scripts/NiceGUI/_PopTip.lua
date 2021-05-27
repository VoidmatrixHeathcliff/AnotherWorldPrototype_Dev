--[[

PopTip：弹出式提示框

Meta:
    + _Show
        - font
        - text
        - color
    + _Hide
    + _DrawSelf
API:

--]]

local _Window = UsingModule("Window")
local _Graphic = UsingModule("Graphic")
local _Interactivity = UsingModule("Interactivity")

local _tbActiveObjList = {}

local _uFont = _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 15)
local _nTextHeight = _uFont:GetHeight()
local _nMargin, _nOffset = 10, 10
local _bSelfEnable = false
local _strText = "提示信息"
local _clrText = {r = 246, g = 173, b = 73, a = 255}
local _tbRenderedText = {}
local _rcSelf = {x = 0, y = 0, w = 0, h = 0}

return {

    _Show = function(values)

        assert(values)
        
        _bSelfEnable = true
        values.text = values.text or _strText
        _clrText = values.color or _clrText
        _uFont = values.font or _uFont
        _nTextHeight = _uFont:GetHeight()
        if values.text ~= _strText then
            _strText = values.text
            _tbRenderedText = {}
            -- 根据换行符裁剪字符串并将其渲染数据保存到表中
            local _nMaxWidth = 0
            string.gsub(_strText, '[^\n]+', function (strFragment)
                local _image = _Graphic.CreateUTF8TextImageBlended(
                    _uFont, strFragment, _clrText)
                local _width, _height = _image:GetSize()
                _nMaxWidth = math.max(_nMaxWidth, _width)
                table.insert(_tbRenderedText, {
                    texture = _Graphic.CreateTexture(_image),
                    width = _width
                })
            end)
            _rcSelf = {
                x = 0, y = 0,
                w = _nMaxWidth + _nMargin * 2,
                h = #_tbRenderedText * _nTextHeight + _nMargin * 2
            }
        end
    end,

    _Hide = function()
        _bSelfEnable = false
    end,

    _DrawSelf = function()
        if _bSelfEnable then
            local _widthWindow, _heightWindow = _Window.GetWindowSize()
            local _tbCursorPos = _Interactivity.GetCursorPosition()
            
            if _tbCursorPos.x + _nOffset + _rcSelf.w <= _widthWindow 
                and _tbCursorPos.y + _nOffset + _rcSelf.h <= _heightWindow then
                _rcSelf.x, _rcSelf.y = _tbCursorPos.x + _nOffset, _tbCursorPos.y + _nOffset
            elseif _tbCursorPos.x - _nOffset - _rcSelf.w >= 0
                and _tbCursorPos.y + _nOffset + _rcSelf.h <= _heightWindow then
                _rcSelf.x, _rcSelf.y = _tbCursorPos.x - _rcSelf.w - _nOffset, _tbCursorPos.y + _nOffset
            elseif _tbCursorPos.x + _nOffset + _rcSelf.w <= _widthWindow
                and _tbCursorPos.y - _nOffset - _rcSelf.h >= 0 then
                _rcSelf.x, _rcSelf.y = _tbCursorPos.x + _nOffset, _tbCursorPos.y - _rcSelf.h - _nOffset
            elseif _tbCursorPos.x - _nOffset - _rcSelf.w >= 0
                and _tbCursorPos.y - _nOffset - _rcSelf.h >= 0 then
                _rcSelf.x, _rcSelf.y = _tbCursorPos.x - _rcSelf.w - _nOffset, _tbCursorPos.y - _rcSelf.h - _nOffset
            else
                _rcSelf.x, _rcSelf.y = _tbCursorPos.x + _nOffset, _tbCursorPos.y + _nOffset
            end

            -- 绘制气泡边框和底色
            _Graphic.SetDrawColor({r = 215, g = 215, b = 215, a = 255})
            _Graphic.FillRoundRectangle(_rcSelf, 8)
            _Graphic.SetDrawColor({r = 25, g = 25, b = 25, a = 255})
            _Graphic.FillRoundRectangle({
                x = _rcSelf.x + 2,
                y = _rcSelf.y + 2,
                w = _rcSelf.w - 4,
                h = _rcSelf.h - 4
            }, 8)
            -- 绘制文本
            for index, data in pairs(_tbRenderedText) do
                _Graphic.CopyTexture(data.texture, {
                    x = _rcSelf.x + _nMargin,
                    y = _rcSelf.y + _nMargin + _nTextHeight * (index - 1),
                    w = data.width, h = _nTextHeight
                })
            end
        end
    end,

}