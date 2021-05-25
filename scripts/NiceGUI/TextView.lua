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
    -- 当文本列表中无文本时修正滑块y坐标
    if #self._tbText == 0 then _rect.y = self._rcScrollBar.y end
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

return {
    
    New = function(rect)

        obj = {}

        obj._uFont = _Graphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 16)
        obj._nTextHeight = obj._uFont:GetHeight()
        obj._tbText = {}
        obj._nMargin, obj._nBorder = 10, 5
        obj._nWidthScrollBar = 15
        obj._nPreviousY = 0
        obj._bSliderDown, obj._bSliderHover = false, false
        obj._rcSelf = rect or {
            x = 0, y = 0,
            w = 350, h = 250
        }
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

        function obj:AppendText(str)
            -- 通过视口位置判断当前滑块是否到达底部
            local _bReachBottom = self._rcViewPort.y + self._rcViewPort.h == self._nTextHeight * #self._tbText
            -- 将过长的字符串分割添加至字符串列表
            while true do
                local _rawStrWidth, _rawStrHeight = _Graphic.GetUTF8TextSize(self._uFont, str)
                if _rawStrWidth <= self._rcViewPort.w then
                    table.insert(self._tbText, str)
                    break
                else
                    for index = _String.LenUTF8(str), 1, -1 do
                        local _strTemp = _String.SubStrUTF8(str, 1, index)
                        local _strWidth, _strHeight = _Graphic.GetUTF8TextSize(self._uFont, _strTemp)
                        if _strWidth <= self._rcViewPort.w then
                            table.insert(self._tbText, _strTemp)
                            str = _String.SubStrUTF8(str, index + 1)
                            break
                        end
                    end
                end
            end
            -- 如果滑块到达底部并且用户没有按下滑块，则移动视口到最底部（滑块滑动至最底）
            if _bReachBottom and (not self._bSliderDown) then
                self._rcViewPort.y = math.max(self._nTextHeight * #self._tbText, self._rcViewPort.h) - self._rcViewPort.h
            end
        end

        function obj:HandleEvent(event)
            if event == _Interactivity.EVENT_MOUSESCROLL then
                local _horizontal, _vertical = _Interactivity.GetScrollValue()
                if self._nTextHeight * #self._tbText > self._rcViewPort.h then
                    self._rcViewPort.y = _Algorithm.Clamp(
                        self._rcViewPort.y - _vertical * 15,
                        0, self._nTextHeight * #self._tbText - self._rcViewPort.h
                    )
                end
            elseif event == _Interactivity.EVENT_MOUSEMOTION then
                self._bSliderHover = _Algorithm.CheckPointInRect(_Interactivity.GetCursorPosition(), _GetRCSlider(self))
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
        end

        function obj:DrawSelf()
            -- 绘制文本区域底色
            _Graphic.SetDrawColor({r = 25, g = 25, b = 25, a = 255})
            _Graphic.FillRectangle(self._rcContent)
            -- 绘制文本区域立体边框线
            _Graphic.SetDrawColor({r = 215, g = 215, b = 215, a = 255})
            _Graphic.ThickLine(
                {x = self._rcContent.x, y = self._rcContent.y},
                {x = self._rcContent.x, y = self._rcContent.y + self._rcContent.h},
                2
            )
            _Graphic.ThickLine(
                {x = self._rcContent.x, y = self._rcContent.y},
                {x = self._rcContent.x + self._rcContent.w, y = self._rcContent.y},
                2
            )
            _Graphic.SetDrawColor({r = 135, g = 135, b = 135, a = 255})
            _Graphic.ThickLine(
                {x = self._rcContent.x, y = self._rcContent.y + self._rcContent.h},
                {x = self._rcContent.x + self._rcContent.w, y = self._rcContent.y + self._rcContent.h},
                2
            )
            _Graphic.ThickLine(
                {x = self._rcContent.x + self._rcContent.w, y = self._rcContent.y},
                {x = self._rcContent.x + self._rcContent.w, y = self._rcContent.y + self._rcContent.h},
                2
            )
            -- 绘制侧边滚动条底色
            _Graphic.SetDrawColor({r = 25, g = 25, b = 25, a = 255})
            _Graphic.FillRectangle(self._rcScrollBar)
            -- 绘制侧边滚动条滑块部分
            if self._bSliderDown then
                _Graphic.SetDrawColor({r = 165, g = 165, b = 165, a = 255})
            elseif self._bSliderHover then
                _Graphic.SetDrawColor({r = 205, g = 205, b = 205, a = 255})
            else
                _Graphic.SetDrawColor({r = 185, g = 185, b = 185, a = 255})
            end
            _Graphic.FillRectangle(_GetRCSlider(self), 5)
            -- 绘制侧边滚动条边框线
            _Graphic.SetDrawColor({r = 215, g = 215, b = 215, a = 255})
            _Graphic.ThickLine(
                {x = self._rcScrollBar.x, y = self._rcScrollBar.y},
                {x = self._rcScrollBar.x, y = self._rcScrollBar.y + self._rcScrollBar.h},
                2
            )
            _Graphic.ThickLine(
                {x = self._rcScrollBar.x, y = self._rcScrollBar.y},
                {x = self._rcScrollBar.x + self._rcScrollBar.w, y = self._rcScrollBar.y},
                2
            )
            _Graphic.SetDrawColor({r = 135, g = 135, b = 135, a = 255})
            _Graphic.ThickLine(
                {x = self._rcScrollBar.x, y = self._rcScrollBar.y + self._rcScrollBar.h},
                {x = self._rcScrollBar.x + self._rcScrollBar.w, y = self._rcScrollBar.y + self._rcScrollBar.h},
                2
            )
            _Graphic.ThickLine(
                {x = self._rcScrollBar.x + self._rcScrollBar.w, y = self._rcScrollBar.y},
                {x = self._rcScrollBar.x + self._rcScrollBar.w, y = self._rcScrollBar.y + self._rcScrollBar.h},
                2
            )
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
                        {r = 200, g = 200, b = 200, a = 255}
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

        function obj:Transform(tb)
            self._rcSelf = {
                x = tb.x or self._rcSelf.x,
                y = tb.y or self._rcSelf.y,
                w = tb.w or self._rcSelf.w,
                h = tb.h or self._rcSelf.h
            }
            _UpdateRects(self)
        end

        return obj

    end

}