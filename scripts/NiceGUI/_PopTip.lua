--[[

TextView：文本域

Meta:
    + _HandleEvent
    + _DrawSelf
API:
    + SetText
    + SetEnable
    + SetTextColor

--]]

return {

    New = function(text, color)

        obj = {}

        obj._uFont = _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 18)
        obj._nTextHeight = obj._uFont:GetHeight()
        obj._nMargin = 10
        obj._strText = text or "提示信息"
        obj._clrText = color or {r = 66, g = 101, b = 121, a = 255}
        obj._tbRenderedText = {}
        -- 根据换行符裁剪字符串并将其渲染数据保存到表中
        string.gsub(str, '[^\n]+', function (strFragment)
            local _image = _Graphic.CreateUTF8TextImageBlended(
                obj._uFont, strFragment,obj._clrText)
            local _width, _height = _image:GetSize()
            table.insert(obj._tbRenderedText, {
                texture = _Graphic.CreateTexture(_image),
                width = _width
            })
        end)
        -- 遍历求得长度最长的纹理
        local _nMaxWidth = obj._tbRenderedText[1].width
        for _, data in pairs(obj._tbRenderedText) do
            _nMaxWidth = math.max(_nMaxWidth, data.width)
        end
        obj._rcSelf = {
            x = 0, y = 0,
            w = _nMaxWidth + obj._nMargin * 2,
            h = #obj._tbRenderedText * obj._nTextHeight + obj._nMargin * 2
        }

        function obj:_DrawSelf()
            
        end

    end

}