--[[

Label：文本标签

Meta:
    + _New:
        - rect / table
        - text / string
        - font / userdata-Graphic.Font
        - onClick / function
        - colorText / table
        - colorBack / table
    + _HandleEvent
    + _DrawSelf

API:
    + GetText
    + SetText
    + Transform

--]]

local _Utils = UsingModule("NiceGUI._Utils")

local _Graphic = UsingModule("Graphic")

local function _UpdateRenderedText(self)
    self._tbRenderedText = {}
    self._nMaxWidth = 0
    string.gsub(self._strText, '[^\n]+', function (strFragment)
            local _image = _Graphic.CreateUTF8TextImageBlended(
                self._uFont, strFragment, self._clrText)
            local _width, _height = _image:GetSize()
            self._nMaxWidth = math.max(self._nMaxWidth, _width)
            table.insert(self._tbRenderedText, {
                texture = _Graphic.CreateTexture(_image),
                width = _width
            })
        end)
end

local function _UpdateStretchRatio(self)
    self._nStretchRatioHorizontal = (self._rcSelf.w - self._nMargin * 2) / self._nMaxWidth
    self._nStretchRatioVertical = (self._rcSelf.h - self._nMargin * 2) 
        / (#self._tbRenderedText * self._nTextHeight)
end

return {

    _New = function(values)

        assert(type(values) == "table")

        obj = {}

        obj._uFont = values.font or _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 16)
        obj._nTextHeight = obj._uFont:GetHeight()
        obj._strText = values.text or "Label"
        if values.isShowBorder == nil then
            obj._bIsShowBorder = false
        else
            obj._bIsShowBorder = values.isShowBorder
        end
        if values.isShowBack == nil then
            obj._bIsShowBack = false
        else
            obj._bIsShowBack = values.isShowBack
        end
        obj._nMargin = 10
        obj._clrText = values.colorText or {r = 200, g = 200, b = 200, a = 255}
        obj._clrBack = values.colorBack or {r = 25, g = 25, b = 25, a = 255}
        _UpdateRenderedText(obj)
        local _rcAuto = {
            x = 0, y = 0,
            w = obj._nMaxWidth + obj._nMargin * 2,
            h = #obj._tbRenderedText * obj._nTextHeight + obj._nMargin * 2
        }
        if values.rect then
            obj._rcSelf = {
                x = values.rect.x or _rcAuto.x,
                y = values.rect.y or _rcAuto.y,
                w = values.rect.w or _rcAuto.w,
                h = values.rect.h or _rcAuto.h,
            }
        else
            obj._rcSelf = _rcAuto
        end
        obj._nStretchRatioHorizontal = (obj._rcSelf.w - obj._nMargin * 2) / obj._nMaxWidth
        obj._nStretchRatioVertical = (obj._rcSelf.h - obj._nMargin * 2) 
            / (#obj._tbRenderedText * obj._nTextHeight) 

        function obj:_HandleEvent(event) end

        function obj:_DrawSelf()
            -- 如果背景设置为显示则渲染背景
            if self._bIsShowBack then
                _Graphic.SetDrawColor(self._clrBack)
                _Graphic.FillRectangle(self._rcSelf)
            end
            -- 如果边框设置为显示则渲染边框
            if self._bIsShowBorder then
                _Graphic.SetDrawColor(self._clrBack)
                _Utils.DrawRectSolidBorder(self._rcSelf, 2)
            end
            -- 绘制文本内容
            for index, data in pairs(self._tbRenderedText) do
                _Graphic.CopyTexture(data.texture, {
                    x = self._rcSelf.x + self._nMargin,
                    y = self._rcSelf.y + self._nMargin + self._nTextHeight * (index - 1) * self._nStretchRatioVertical,
                    w = data.width * self._nStretchRatioHorizontal,
                    h = self._nTextHeight * self._nStretchRatioVertical
                })
            end
        end

        function obj:GetText()
            return obj._strText
        end

        function obj:SetText(text)
            self._strText = text
            _UpdateRenderedText(self)
            self._rcSelf.w = self._nMaxWidth + self._nMargin * 2
            self._rcSelf.h = #self._tbRenderedText * self._nTextHeight + self._nMargin * 2
            _UpdateStretchRatio(self)
        end

        function obj:Transform(rect)
            self._rcSelf = {
                x = rect.x or self._rcSelf.x,
                y = rect.y or self._rcSelf.y,
                w = rect.w or self._rcSelf.w,
                h = rect.h or self._rcSelf.h,
            }
            _UpdateStretchRatio(self)
        end

        return obj

    end

}