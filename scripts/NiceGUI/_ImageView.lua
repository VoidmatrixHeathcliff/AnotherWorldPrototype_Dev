--[[

ImageView：图片

Meta:
    + _New:
        - rect
        - image
        - isShowBorder / boolean
        - isShowBack / boolean
        - isAutoSize / boolean
        - onEnter / function
        - onLeave / function
        - colorBack / table
        - margin
    + _HandleEvent
    + _DrawSelf

API:
    + SetImage
    + SetAplha
    + SetBackShow
    + SetBorderShow
    + SetBackColor
    + SetAutoSize
    + SetMargin
    + Transform

--]]

local _Utils = UsingModule("NiceGUI._Utils")

local _Graphic = UsingModule("Graphic")
local _Algorithm = UsingModule("Algorithm")
local _Interactivity = UsingModule("Interactivity")

local function _ResizeAuto(self)
    self._rcSelf.w = self._nwidthImage + self._nMargin * 2
    self._rcSelf.h = self._nHeightImage + self._nMargin * 2
end


return {

    _New = function(values)

        assert(type(values) == "table")

        obj = {}

        local _image = values.image or _Graphic.LoadImageFromFile("Creeper.png")
        obj._uTexture = _Graphic.CreateTexture(_image)
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
        obj._nMargin = values.margin or 10
        obj._clrBack = values.colorBack or {r = 25, g = 25, b = 25, a = 255}
        obj._nwidthImage, obj._nHeightImage = _image:GetSize()
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
            -- 绘制图片内容
            _Graphic.CopyTexture(self._uTexture, {
                x = self._rcSelf.x + self._nMargin,
                y = self._rcSelf.y + self._nMargin,
                w = self._rcSelf.w - self._nMargin * 2,
                h = self._rcSelf.h - self._nMargin * 2
            })
        end

        function obj:SetImage(image)
            self._uTexture = _Graphic.CreateTexture(image)
            self._nwidthImage, self._nHeightImage = image:GetSize()
            if self._bIsAutoSize then
                _ResizeAuto(self)
            end
        end

        function obj:SetAplha(alpha)
            self._uTexture:SetAlpha(alpha)
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

        function obj:SetAutoSize(flag)
            self._bIsAutoSize = flag
            if self._bIsAutoSize then
                _ResizeAuto(self)
            end
        end

        function obj:SetMargin(margin)
            self._nMargin = margin
            if self._bIsAutoSize then
                _ResizeAuto(self)
            end 
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
        end

        return obj

    end

}