local _TextView = UsingModule("NiceGUI._TextView")
local _Button = UsingModule("NiceGUI._Button")
local _PopTip = UsingModule("NiceGUI._PopTip")

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
        _PopTip._DrawSelf()
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

    TextView = function(values)
        return _TextView._New(values)
    end,

    Button = function(values)
        return _Button._New(values)
    end,

    ShowPopTip = function(values)
        _PopTip._Show(values)
    end,

    HidePopTip = function()
        _PopTip._Hide()
    end,

}