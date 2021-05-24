_M_NICEGUI_ = {}

local _TextView = require("NiceGUI.TextView")

local _tbElements = {}

local function _NewTextView(rect)
    return _TextView.New(rect)
end

local function _UpdateEvent(event)
    for _, ele in pairs(_tbElements) do
        if ele then ele:HandleEvent(event) end
    end
end

local function _UpdateRender()
    for _, ele in pairs(_tbElements) do
        if ele then ele:DrawSelf() end
    end
end

local function _Place(obj)
    local _index = 1
    while _tbElements[_index] do _index = _index + 1 end
    _tbElements[_index] = obj
    return _index
end

local function _Remove(index)
    _tbElements[index] = nil
end

local function _Clear(index)
    _tbElements = {}
end

return {
    UpdateEvent = _UpdateEvent,
    UpdateRender = _UpdateRender,
    Place = _Place,
    Remove = _Remove,
    Clear = _Clear,

    TextView = _NewTextView,
}

-- return _M_NICEGUI_