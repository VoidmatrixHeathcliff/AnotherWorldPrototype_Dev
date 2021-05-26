local _Graphic = UsingModule("Graphic")
local _String = UsingModule("String")

return {

    DrawRectSolidBorder = function(rect, width)
        _Graphic.SetDrawColor({r = 215, g = 215, b = 215, a = 255})
        _Graphic.ThickLine(
            {x = rect.x, y = rect.y},
            {x = rect.x, y = rect.y + rect.h},
            width
        )
        _Graphic.ThickLine(
            {x = rect.x, y = rect.y},
            {x = rect.x + rect.w, y = rect.y},
            width
        )
        _Graphic.SetDrawColor({r = 135, g = 135, b = 135, a = 255})
        _Graphic.ThickLine(
            {x = rect.x, y = rect.y + rect.h},
            {x = rect.x + rect.w, y = rect.y + rect.h},
            width
        )
        _Graphic.ThickLine(
            {x = rect.x + rect.w, y = rect.y},
            {x = rect.x + rect.w, y = rect.y + rect.h},
            width
        )
    end,

    AppendAdaptedTextToList = function(font, str, width, list)
        while true do
            local _rawStrWidth, _rawStrHeight = _Graphic.GetUTF8TextSize(font, str)
            if _rawStrWidth <= width then
                table.insert(list, str)
                break
            else
                for index = _String.LenUTF8(str), 1, -1 do
                    local _strTemp = _String.SubStrUTF8(str, 1, index)
                    local _strWidth, _strHeight = _Graphic.GetUTF8TextSize(font, _strTemp)
                    if _strWidth <= width then
                        table.insert(list, _strTemp)
                        str = _String.SubStrUTF8(str, index + 1)
                        break
                    end
                end
            end
        end
    end

}