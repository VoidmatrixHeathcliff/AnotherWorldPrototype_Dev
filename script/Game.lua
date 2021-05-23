mConfig = require("Config")

mTime = UsingModule("Time")
mString = UsingModule("String")
mWindow = UsingModule("Window")
mGraphic = UsingModule("Graphic")
mAlgorithm = UsingModule("Algorithm")
mInteract = UsingModule("Interactivity")


mWindow.CreateWindow("Another World - 未登录", mConfig.RC_WINDOW, {})

g_bIsRunning = true

textList = {
    "【小明】使用了【虚空之剑】，造成了 1000 点伤害",
    "【巨大河蟹】被击飞 1 回合",
    "【小红】使用【光之庇护】，全队抗性增加了 45 点",
    "【巨大河蟹】使用了【冲撞】，击退了【小明】【小刚】，同时对全队造成了 150 点震慑伤害",
    "【小明】将【虚空之剑】进入到解放状态，下一回合攻击暴击概率大幅提升",
    "【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点",
    "【小明】使用了【虚空之剑】，造成了 1000 点伤害",
    "【巨大河蟹】被击飞 1 回合",
    "【小红】使用【光之庇护】，全队抗性增加了 45 点",
    "【巨大河蟹】使用了【冲撞】，击退了【小明】【小刚】，同时对全队造成了 150 点震慑伤害",
    "【小明】将【虚空之剑】进入到解放状态，下一回合攻击暴击概率大幅提升",
    "【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点",
    "【小明】使用了【虚空之剑】，造成了 1000 点伤害",
    "【巨大河蟹】被击飞 1 回合",
    "【小红】使用【光之庇护】，全队抗性增加了 45 点",
    "【巨大河蟹】使用了【冲撞】，击退了【小明】【小刚】，同时对全队造成了 150 点震慑伤害",
    "【小明】将【虚空之剑】进入到解放状态，下一回合攻击暴击概率大幅提升",
    "【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点",
    "【小明】使用了【虚空之剑】，造成了 1000 点伤害",
    "【巨大河蟹】被击飞 1 回合",
    "【小红】使用【光之庇护】，全队抗性增加了 45 点",
    "【巨大河蟹】使用了【冲撞】，击退了【小明】【小刚】，同时对全队造成了 150 点震慑伤害",
    "【小明】将【虚空之剑】进入到解放状态，下一回合攻击暴击概率大幅提升",
    "【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点",
    "【小明】使用了【虚空之剑】，造成了 1000 点伤害",
    "【巨大河蟹】被击飞 1 回合",
    "【小红】使用【光之庇护】，全队抗性增加了 45 点",
    "【巨大河蟹】使用了【冲撞】，击退了【小明】【小刚】，同时对全队造成了 150 点震慑伤害",
    "【小明】将【虚空之剑】进入到解放状态，下一回合攻击暴击概率大幅提升",
    "【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点",
}

resultList = {}

rectViewPort = {
    x = 100, y = 100,
    w = 375, h = 175
}

rectRenderPort = {
    x = 0,
    y = 0,
    w = rectViewPort.w,
    h = rectViewPort.h
}

os.execute("chcp 65001")

font = mGraphic.LoadFontFromFile("./res/font/SIMYOU.TTF", 15)
for _, str in ipairs(textList) do
    while true do
        local _rawStrWidth, _rawStrHeight = mGraphic.GetUTF8TextSize(font, str)
        if _rawStrWidth <= rectViewPort.w then
            table.insert(resultList, str)
            break
        else
            for index = mString.LenUTF8(str), 1, -1 do
                local _strTemp = mString.SubStrUTF8(str, 1, index)
                local _strWidth, _strHeight = mGraphic.GetUTF8TextSize(font, _strTemp)
                if _strWidth <= rectViewPort.w then
                    table.insert(resultList, _strTemp)
                    str = mString.SubStrUTF8(str, index + 1)
                    break
                end
            end
        end
    end
end

local _commonWidth, _commonheight = mGraphic.GetUTF8TextSize(font, resultList[1])

while g_bIsRunning do
    
    local _nStartTime = mTime.GetInitTime()
    
    mGraphic.SetDrawColor({r = 45, g = 45, b = 45, a = 255})
    mWindow.ClearWindow()
    
    while mInteract.UpdateEvent() do
        local _event = mInteract.GetEventType()
        if _event == mInteract.EVENT_QUIT then
            g_bIsRunning = false
        elseif _event == mInteract.EVENT_MOUSESCROLL then
            local _horizontal, _vertical = mInteract.GetScrollValue()
            if _commonheight * #resultList > rectRenderPort.h then
                rectRenderPort.y = mAlgorithm.Clamp(rectRenderPort.y - _vertical * 10, 0, _commonheight * #resultList - rectRenderPort.h)
            end
            print(rectRenderPort.y, rectViewPort.y)
        end
    end

    for index = rectRenderPort.y // _commonheight + 1, #resultList do
        local _image = mGraphic.CreateUTF8TextImageBlended(font, resultList[index], {r = 200, g = 200, b = 200, a = 255})
        local _texture = mGraphic.CreateTexture(_image)
        local _width, _height = _image:GetSize()
        if _commonheight * (index - 1) < rectRenderPort.y then
            local _rectCut = {
                x = 0,
                y = rectRenderPort.y - _commonheight * (index - 1),
                w = rectRenderPort.w,
                h = _commonheight * index - rectRenderPort.y
            }
            mGraphic.CopyReshapeTexture(_texture, _rectCut, {
                x = rectViewPort.x,
                y = rectViewPort.y,
                w = _width,
                h = _rectCut.h
            })
        elseif _commonheight * index > rectRenderPort.y + rectRenderPort.h then
            local _rectCut = {
                x = 0,
                y = 0,
                w = rectRenderPort.w,
                h = rectRenderPort.y + rectRenderPort.h - _commonheight * (index - 1)
            }
            mGraphic.CopyReshapeTexture(_texture, _rectCut, {
                x = rectViewPort.x,
                y = rectViewPort.y + rectViewPort.h - _rectCut.h,
                w = _width,
                h = _rectCut.h
            })
        else
            mGraphic.CopyTexture(_texture, {
                x = rectViewPort.x,
                y = rectViewPort.y + _commonheight * (index - 1) - rectRenderPort.y,
                w = _width,
                h = _commonheight
            })
        end

        -- local _rect = {x = rectViewPort.x, y = rectViewPort.y + _height * (index - 1) - rectRenderPort.y, w = _width, h = _height}
        -- if _rect.y < rectViewPort.y then
        --     mGraphic.CopyReshapeTexture(_texture, {x = 0, y = _rect.h, w = _rect.w, h = rectViewPort.y - _rect.y}, _rect)
        -- end
        -- if _rect.y + _rect.h > rectViewPort.y + rectViewPort.h then
        --     _rect.h = rectViewPort.y + rectViewPort.h - _rect.y
        --     mGraphic.CopyReshapeTexture(_texture, {x = 0, y = 0, w = _rect.w, h = _rect.h}, _rect)
        --     break
        -- else
        --     mGraphic.CopyTexture(_texture, _rect)
        -- end
    end

    mGraphic.SetDrawColor({r = 255, g = 255, b = 255, a = 255})
    mGraphic.RoundRectangle({x = rectViewPort.x - 10, y = rectViewPort.y - 10, w = rectViewPort.w + 20, h = rectViewPort.h + 20}, 10)

    mWindow.UpdateWindow()
    
    mTime.DynamicSleep(
        1000 / mConfig.N_FPS,
        mTime.GetInitTime() - _nStartTime
)
end
