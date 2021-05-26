local _TextView = require("NiceGUI.TextView")
local _Button = require("NiceGUI.Button")

local _tbElements = {}

return {

    UpdateEvent = function(event)
        for _, ele in pairs(_tbElements) do
            if ele then ele:_HandleEvent(event) end
        end
    end,

    UpdateRender = function()
        for _, ele in pairs(_tbElements) do
            if ele then ele:_DrawSelf() end
        end
    end,

    Place = function(obj)
        local _index = 1
        while _tbElements[_index] do _index = _index + 1 end
        _tbElements[_index] = obj
        return _index
    end,

    Remove = function(index)
        _tbElements[index] = nil
    end,
    
    Clear = function(index)
        _tbElements = {}
    end,

    TextView = function(rect)
        return _TextView.New(rect)
    end,

    Button = function(rect, callback)
        return _Button.New(rect, callback)
    end,

}