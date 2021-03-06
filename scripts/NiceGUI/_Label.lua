--[[

Label：文本标签

Meta:
    + _New:
        - rect / table
        - text / string
        - font / userdata-Graphic.Font
        - isShowBorder / boolean
        - isShowBack / boolean
        - isAutoSize / boolean
        - onEnter / function
        - onLeave / function
        - colorText / table
        - colorBack / table
    + _HandleEvent
    + _DrawSelf

API:
    + GetText
    + SetText
    + SetBackShow
    + SetBorderShow
    + SetBackColor
    + SetTextColor
    + SetAutoSize
    + Transform

--]]

local _Utils = UsingModule("NiceGUI._Utils")

local _Graphic = UsingModule("Graphic")
local _Algorithm = UsingModule("Algorithm")
local _Interactivity = UsingModule("Interactivity")

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

local function _ResizeAuto(self)
    self._rcSelf.w = self._nMaxWidth + self._nMargin * 2
    self._rcSelf.h = #self._tbRenderedText * self._nTextHeight + self._nMargin * 2
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
        if values.isAutoSize == nil then
            obj._bIsAutoSize = false
        else
            obj._bIsAutoSize = values.isAutoSize
        end
        obj._fnEnterCallback = values.onEnter or function() end
        obj._fnLeaveCallback = values.onLeave or function() end
        obj._bSelfHover = false
        obj._nMargin = 10
        obj._clrText = values.colorText or {r = 200, g = 200, b = 200, a = 255}
        obj._clrBack = values.colorBack or {r = 25, g = 25, b = 25, a = 255}
        _UpdateRenderedText(obj)
        obj._rcSelf = {x = 0, y = 0}
        _ResizeAuto(obj)
        if values.rect then
            obj._rcSelf = {
                x = values.rect.x or obj._rcSelf.x,
                y = values.rect.y or obj._rcSelf.y,
                w = values.rect.w or obj._rcSelf.w,
                h = values.rect.h or obj._rcSelf.h,
            }
        end
        if obj._bIsAutoSize then
            _ResizeAuto(obj)
        end
        _UpdateStretchRatio(obj)

        function obj:_HandleEvent(event)
            if event == _Interactivity.EVENT_MOUSEMOTION then
                local _bInArea = _Algorithm.CheckPointInRect(
                    _Interactivity.GetCursorPosition(), self._rcSelf)
                if _bInArea then
                    if not self._bSelfHover then
                        self._fnEnterCallback()
                    end
                elseif self._bSelfHover then
                    self._fnLeaveCallback()
                end
                self._bSelfHover = _bInArea
            end
        end

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
            if self._bIsAutoSize then
                _ResizeAuto(self)
            end
            _UpdateStretchRatio(self)
        end

        function obj:SetBackShow(flag)
            self._bIsShowBack = flag
        end

        function obj:SetBorderShow(flag)
            self._bIsShowBorder = flag
        end

        function obj:SetBackColor(color)
            self._clrBack = color
        end

        function obj:SetTextColor(color)
            self._clrText = color
            _UpdateRenderedText(self)
        end

        function obj:SetAutoSize(flag)
            self._bIsAutoSize = flag
            if self._bIsAutoSize then
                _ResizeAuto(self)
            end
            _UpdateStretchRatio(self)
        end

        function obj:Transform(rect)
            -- 如果修改了宽高属性则将自动大小关闭
            if rect.w or rect.h then
                self._bIsAutoSize = false
            end
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