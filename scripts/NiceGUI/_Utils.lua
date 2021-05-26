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
        string.gsub(str, '[^\n]+', function (strFragment)
            while true do
                local _rawStrWidth, _rawStrHeight = _Graphic.GetUTF8TextSize(font, strFragment)
                if _rawStrWidth <= width then
                    table.insert(list, strFragment)
                    break
                else
                    for index = _String.LenUTF8(strFragment), 1, -1 do
                        local _strTemp = _String.SubStrUTF8(strFragment, 1, index)
                        local _strWidth, _strHeight = _Graphic.GetUTF8TextSize(font, _strTemp)
                        if _strWidth <= width then
                            table.insert(list, _strTemp)
                            strFragment = _String.SubStrUTF8(strFragment, index + 1)
                            break
                        end
                    end
                end
            end
        end)
    end

}