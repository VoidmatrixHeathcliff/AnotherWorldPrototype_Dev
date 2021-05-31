--[[

TextView：文本列表

Meta:
    + _New
        - rect / table
        - font / userdata-Graphic.Font 
        - onEnter / function
        - onLeave / function
        - enableSlider / boolean
        - colorText / table
        - colorBack / table
    + _HandleEvent
    + _DrawSelf
API:
    + AppendText
    + ClearText
    + SetEnterCallback
    + SetLeaveCallback
    + SetSliderEnable
    + Transform

--]]

local _Utils = UsingModule("NiceGUI._Utils")

local _Graphic = UsingModule("Graphic")
local _String = UsingModule("String")
local _Algorithm = UsingModule("Algorithm")
local _Interactivity = UsingModule("Interactivity")

-- 动态计算滚动条滑块定为矩形
local function _GetRCSlider(self)
    local _rect = {
        x = self._rcScrollBar.x,
        y = self._rcScrollBar.y + self._rcViewPort.y / (self._nTextHeight * #self._tbText)
            * self._rcScrollBar.h,
        w = self._rcScrollBar.w,
        h = self._rcViewPort.h / math.max(self._nTextHeight * #self._tbText, self._rcViewPort.h)
            * self._rcScrollBar.h
    }
    -- 当滑块被禁用时修正y坐标和高度
    if not self._bSliderEnable then
        _rect.y, _rect.h = self._rcScrollBar.y, self._rcScrollBar.h
    else
        -- 当文本列表中无文本时修正滑块y坐标
        if #self._tbText == 0 then _rect.y = self._rcScrollBar.y end
    end
    return _rect
end

-- 更新对象内各个定位矩形
local function _UpdateRects(self)
    self._rcContent = {
        x = self._rcSelf.x,
        y = self._rcSelf.y,
        w = self._rcSelf.w - self._nBorder - self._nWidthScrollBar,
        h = self._rcSelf.h
    }
    
    self._rcViewPort = {
        x = 0,
        y = 0,
        w = self._rcContent.w - self._nMargin * 2,
        h = self._rcContent.h - self._nMargin * 2
    }
    
    self._rcScrollBar = {
        x = self._rcSelf.x + self._rcSelf.w - self._nWidthScrollBar,
        y = self._rcSelf.y,
        w = self._nWidthScrollBar,
        h = self._rcSelf.h
    }
end

local function _UpdateText(self)
    self._tbText = {}
    for _, str in ipairs(self._tbRawText) do
        _Utils.AppendAdaptedTextToList(self._uFont, str, self._rcViewPort.w, self._tbText)
    end
    self._tbRenderedText = {}
end

return {
    
    _New = function(values)

        assert(type(values) == "table")

        obj = {}

        obj._uFont = values.font or _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 16)
        obj._fnEnterCallback = values.onEnter or function() end
        obj._fnLeaveCallback = values.onLeave or function() end
        obj._clrText = values.colorText or {r = 200, g = 200, b = 200, a = 255}
        obj._clrBack = values.colorBack or {r = 25, g = 25, b = 25, a = 255}
        obj._nTextHeight = obj._uFont:GetHeight()
        obj._tbText, obj._tbRawText = {}, {}
        obj._nMargin, obj._nBorder = 10, 5
        obj._nWidthScrollBar = 15
        obj._nPreviousY = 0
        obj._bSliderDown, obj._bSliderHover = false, false
        if values.enableSlider == nil then
            obj._bSliderEnable = true
        else
            obj._bSliderEnable = values.enableSlider
        end
        obj._bSelfHover = false
        obj._rcSelf = {
            x = 0, y = 0,
            w = 350, h = 250
        }
        if values.rect then
            obj._rcSelf = {
                x = values.rect.x or obj._rcSelf.x,
                y = values.rect.y or obj._rcSelf.y,
                w = values.rect.w or obj._rcSelf.w,
                h = values.rect.h or obj._rcSelf.h,
            }
        end
        obj._rcContent = {
            x = obj._rcSelf.x,
            y = obj._rcSelf.y,
            w = obj._rcSelf.w - obj._nBorder - obj._nWidthScrollBar,
            h = obj._rcSelf.h
        }
        obj._rcViewPort = {
            x = 0,
            y = 0,
            w = obj._rcContent.w - obj._nMargin * 2,
            h = obj._rcContent.h - obj._nMargin * 2
        }
        obj._rcScrollBar = {
            x = obj._rcSelf.x + obj._rcSelf.w - obj._nWidthScrollBar,
            y = obj._rcSelf.y,
            w = obj._nWidthScrollBar,
            h = obj._rcSelf.h
        }
        obj._tbRenderedText = {}

        function obj:_HandleEvent(event)
            if event == _Interactivity.EVENT_MOUSESCROLL then
                if self._bSelfHover then
                    local _horizontal, _vertical = _Interactivity.GetScrollValue()
                    if self._nTextHeight * #self._tbText > self._rcViewPort.h then
                        self._rcViewPort.y = _Algorithm.Clamp(
                            self._rcViewPort.y - _vertical * 15,
                            0, self._nTextHeight * #self._tbText - self._rcViewPort.h
                        )
                    end
                end
            elseif event == _Interactivity.EVENT_MOUSEMOTION then
                self._bSliderHover = _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), _GetRCSlider(self))
                local _bInArea = _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), self._rcSelf)
                local _bInArea = _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), self._rcSelf)
                if _bInArea then
                    if not self._bSelfHover then
                        self._fnEnterCallback()
                    end
                elseif self._bSelfHover then
                    self._fnLeaveCallback()
                end
                self._bSelfHover = _bInArea
                if self._bSliderDown then
                    local _tbCursorPos = _Interactivity.GetCursorPosition()
                    if self._nTextHeight * #self._tbText > self._rcViewPort.h then
                        self._rcViewPort.y = _Algorithm.Clamp(self._rcViewPort.y + (_tbCursorPos.y - self._nPreviousY) 
                            * math.max(self._nTextHeight * #self._tbText, self._rcViewPort.h) / self._rcViewPort.h,
                            0, self._nTextHeight * #self._tbText - self._rcViewPort.h
                        )
                        self._nPreviousY = _tbCursorPos.y
                    end
                end
            elseif event == _Interactivity.EVENT_MOUSEBTNDOWN_LEFT then
                local _tbCursorPos = _Interactivity.GetCursorPosition()
                if _Algorithm.CheckPointInRect(_tbCursorPos, _GetRCSlider(self)) then
                    self._bSliderDown = true
                    self._nPreviousY = _tbCursorPos.y
                end
            elseif event == _Interactivity.EVENT_MOUSEBTNUP_LEFT then
                self._bSliderDown = false
            end
            if not self._bSliderEnable then self._bSliderHover, self._bSliderDown = false, false end
        end

        function obj:_DrawSelf()
            -- 绘制文本区域底色
            _Graphic.SetDrawColor(self._clrBack)
            _Graphic.FillRectangle(self._rcContent)
            -- 绘制文本区域立体边框线
            _Utils.DrawRectSolidBorder(self._rcContent, 2)
            -- 绘制侧边滚动条底色
            _Graphic.SetDrawColor(self._clrBack)
            _Graphic.FillRectangle(self._rcScrollBar)
            -- 绘制侧边滚动条滑块部分
            if not self._bSliderEnable then 
                _Graphic.SetDrawColor({r = 135, g = 135, b = 135, a = 255})
            else
                if self._bSliderDown then
                    _Graphic.SetDrawColor({r = 165, g = 165, b = 165, a = 255})
                elseif self._bSliderHover then
                    _Graphic.SetDrawColor({r = 205, g = 205, b = 205, a = 255})
                else
                    _Graphic.SetDrawColor({r = 185, g = 185, b = 185, a = 255})
                end
            end
            
            _Graphic.FillRectangle(_GetRCSlider(self))
            -- 绘制侧边滚动条边框线
            _Utils.DrawRectSolidBorder(self._rcScrollBar, 2)
            -- 绘制文本内容
            local _rcCopyDst = {
                x = self._rcContent.x + self._nMargin,
                y = self._rcContent.y + self._nMargin,
                w = self._rcViewPort.w,
                h = self._rcViewPort.h
            }
            -- 记录当前所需要的渲染文本的在列表中的索引
            local _indexLastRender = #self._tbText
            -- 销毁当前视口上方不需要的渲染数据
            for index = 1, self._rcViewPort.y // self._nTextHeight do
                self._tbRenderedText[index] = nil
            end
            -- 渲染当前视口内文本数据
            for index = self._rcViewPort.y // self._nTextHeight + 1, #self._tbText do
                -- 如果已渲染列表中没有当前文本，则渲染此文本
                if not self._tbRenderedText[index] then
                    local _image = _Graphic.CreateUTF8TextImageBlended(
                        self._uFont, self._tbText[index],
                        self._clrText
                    )
                    local _width, _height = _image:GetSize()
                    self._tbRenderedText[index] = {
                        texture = _Graphic.CreateTexture(_image),
                        width = _width
                    }
                end
                -- 根据当前文本的位置选择性拷贝纹理（截取上部分、下部分或完全显示）
                if self._nTextHeight * (index - 1) < self._rcViewPort.y then
                    local _rectCut = {
                        x = 0,
                        y = self._rcViewPort.y - self._nTextHeight * (index - 1),
                        w = self._rcViewPort.w,
                        h = self._nTextHeight * index - self._rcViewPort.y
                    }
                    _Graphic.CopyReshapeTexture(self._tbRenderedText[index].texture, _rectCut, {
                        x = _rcCopyDst.x,
                        y = _rcCopyDst.y,
                        w = self._tbRenderedText[index].width,
                        h = _rectCut.h
                    })
                elseif self._nTextHeight * index > self._rcViewPort.y + self._rcViewPort.h then
                    local _rectCut = {
                        x = 0,
                        y = 0,
                        w = self._rcViewPort.w,
                        h = self._rcViewPort.y + self._rcViewPort.h - self._nTextHeight * (index - 1)
                    }
                    _Graphic.CopyReshapeTexture(self._tbRenderedText[index].texture, _rectCut, {
                        x = _rcCopyDst.x,
                        y = _rcCopyDst.y + _rcCopyDst.h - _rectCut.h,
                        w = self._tbRenderedText[index].width,
                        h = _rectCut.h
                    })
                    _indexLastRender = index
                    break
                else
                    _Graphic.CopyTexture(self._tbRenderedText[index].texture, {
                        x = _rcCopyDst.x,
                        y = _rcCopyDst.y + self._nTextHeight * (index - 1) - self._rcViewPort.y,
                        w = self._tbRenderedText[index].width,
                        h = self._nTextHeight
                    })
                end
            end
            -- 销毁当前视口下方不需要的渲染数据
            for index = _indexLastRender + 1, #self._tbText do
                self._tbRenderedText[index] = nil
            end
        end

        function obj:AppendText(str)
            -- 存储原始未换行裁剪的字符串
            table.insert(self._tbRawText, str)
            -- 通过视口位置判断当前滑块是否到达底部
            local _bReachBottom = self._rcViewPort.y + self._rcViewPort.h >= self._nTextHeight * #self._tbText
            -- 将的字符串换行分割添加至字符串列表
            _Utils.AppendAdaptedTextToList(self._uFont, str, self._rcViewPort.w, self._tbText)
            -- 如果滑块到达底部并且用户没有按下滑块，则移动视口到最底部（滑块滑动至最底）
            if _bReachBottom and (not self._bSliderDown) then
                self._rcViewPort.y = math.max(self._nTextHeight * #self._tbText, self._rcViewPort.h) - self._rcViewPort.h
            end
        end

        function obj:ClearText()
            self._tbText = {}
            self._tbRawText = {}
            _UpdateRects(self)
            _UpdateText(self)
        end

        function obj:SetEnterCallback(callback)
            self._fnEnterCallback = callback
        end

        function obj:SetLeaveCallback(callback)
            self._fnLeaveCallback = callback
        end

        function obj:SetSliderEnable(flag)
            self._bSliderEnable = flag
        end

        function obj:Transform(rect)
            self._rcSelf = {
                x = rect.x or self._rcSelf.x,
                y = rect.y or self._rcSelf.y,
                w = rect.w or self._rcSelf.w,
                h = rect.h or self._rcSelf.h,
            }
            _UpdateRects(self)
            _UpdateText(self)
        end

        return obj

    end

}