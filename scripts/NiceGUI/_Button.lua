--[[

Button：按钮

Meta:
    + _HandleEvent
    + _DrawSelf
API:
    + SetText
    + SetClickCallback
    + SetHoverCallback
    + Transform

--]]

local _Utils = UsingModule("NiceGUI._Utils")

local _Graphic = UsingModule("Graphic")
local _Algorithm = UsingModule("Algorithm")
local _Interactivity = UsingModule("Interactivity")

return {

    New = function(rect, callback)
        
        obj = {}

        obj._uFont = _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 18)
        obj._strText = "按 钮"
        local _image = _Graphic.CreateUTF8TextImageBlended(
            obj._uFont, obj._strText,
            {r = 25, g = 25, b = 25, a = 255}
        )
        obj._uTextureText = _Graphic.CreateTexture(_image)
        obj._nTextWidth, obj._nTextHeight = _image:GetSize()
        obj._fnClickCallback = callback or function() end
        obj._fnHoverCallback = function() end
        obj._bSelfHover, obj._bSelfDown = false, false
        obj._nMarginHorizontal, obj._nMarginVertical = 15, 8
        obj._rcSelf = rect or {
            x = 0, y = 0,
            w = 150, h = 85
        }

        function obj:_HandleEvent(event)
            if event == _Interactivity.EVENT_MOUSEMOTION then
                local _bInArea = _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), self._rcSelf)
                if not self._bSelfHover and _bInArea then self._fnHoverCallback() end
                self._bSelfHover = _bInArea
            elseif event == _Interactivity.EVENT_MOUSEBTNDOWN_LEFT then
                self._bSelfDown= _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), self._rcSelf)
            elseif event == _Interactivity.EVENT_MOUSEBTNUP_LEFT then
                if _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), self._rcSelf) then
                    self._fnClickCallback()
                end
                self._bSelfDown= false
            end
        end

        function obj:_DrawSelf()
            -- 绘制按钮底色
            if self._bSelfDown then
                _Graphic.SetDrawColor({r = 165, g = 165, b = 165, a = 255})
            elseif self._bSelfHover then
                _Graphic.SetDrawColor({r = 205, g = 205, b = 205, a = 255})
            else
                _Graphic.SetDrawColor({r = 185, g = 185, b = 185, a = 255})
            end
            _Graphic.FillRectangle(self._rcSelf)
            -- 绘制立体边框线
            _Utils.DrawRectSolidBorder(self._rcSelf, 2)
            -- 绘制文本内容
            local _nMinWidth, _nMinHeight = 
                math.min(self._rcSelf.w - self._nMarginHorizontal * 2, self._nTextWidth),
                math.min(self._rcSelf.h - self._nMarginVertical * 2, self._nTextHeight)
            _Graphic.CopyTexture(self._uTextureText, {
                x = self._rcSelf.x + self._rcSelf.w / 2 - _nMinWidth / 2,
                y = self._rcSelf.y + self._rcSelf.h / 2 - _nMinHeight / 2,
                w = _nMinWidth, h = _nMinHeight
            })
        end

        function obj:SetText(text)
            self._strText = text
            local _image = _Graphic.CreateUTF8TextImageBlended(
                self._uFont, self._strText,
                {r = 25, g = 25, b = 25, a = 255}
            )
            self._uTextureText = _Graphic.CreateTexture(_image)
            self._nTextWidth, self._nTextHeight = _image:GetSize()
        end

        function obj:SetClickCallback(callback)
            self._fnClickCallback = callback
        end

        function obj:SetHoverCallback(callback)
            self._fnHoverCallback = callback
        end

        function obj:Transform(rect)
            self._rcSelf = rect
        end

        return obj

    end

}