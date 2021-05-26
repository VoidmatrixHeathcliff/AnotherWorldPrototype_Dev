local _Graphic = UsingModule("Graphic")

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
    end

}