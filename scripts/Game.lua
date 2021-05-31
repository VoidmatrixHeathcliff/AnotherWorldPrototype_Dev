mConfig = require("Config")

mTime = UsingModule("Time")
mString = UsingModule("String")
mWindow = UsingModule("Window")
mGraphic = UsingModule("Graphic")
mAlgorithm = UsingModule("Algorithm")
mInteract = UsingModule("Interactivity")

mWindow.CreateWindow("Another World - 未登录", mConfig.RC_WINDOW, {})

-- 引入 NiceGUI 模块
mGUI = UsingModule("NiceGUI.NiceGUI")

-- -- 创建文本域组件
-- textView = mGUI.TextView()

-- -- 调整文本域组件的位置和尺寸
-- textView:Transform({
--     x = 200, y = 90,
--     w = 500, h = 600
-- })

-- -- 向文本域中添加字符串
-- textView:AppendText("【小刚】装备【守护者之盾】")

-- -- 将创建的文本域组件添加到界面中
-- mGUI.Place(textView)

-- -- 主循环
-- while true do
--     -- 更新获取事件
--     while mInteract.UpdateEvent() do
--         local _event = mInteract.GetEventType()
--         -- 更新 GUI 组件事件
--         mGUI.UpdateEvent(_event)
--     end
--     -- 更新 GUI 组件渲染
--     mGUI.UpdateRender()
-- end

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

os.execute("chcp 65001")

textView = mGUI.TextView({})

textIndex = 0

bIsEnable = false

label = mGUI.Label({
    text = "这是第一行文本标签\n这是第二行？逗我呢？这行超长的我说！\n这是第三行……",
    rect = {x = 850, y = 100}
})

width_label = 350

mGUI.Place(label)

button = mGUI.Button({rect = {x = 800, y = 500, w = 180, h = 40}, text = "显示提示信息", 
    onClick = function()
        bIsEnable = not bIsEnable
        label:SetText("这是一小行\n第二小行参上！芜湖~")
        -- label:Transform({w = width_label})
        width_label = width_label - 50
        textView:SetSliderEnable(bIsEnable)
        if bIsEnable then
            button:SetText("隐藏提示信息")
            mGUI.ShowPopTip({text = "这是一句提示信息\n这可能是第二行提示信息吧？"}) 
        else
            button:SetText("显示提示信息")
            mGUI.HidePopTip()
        end
    end,
    colorBack = {r = 200, g = 100, b = 75, a = 255},
    colorText = {r = 50, g = 75, b = 150, a = 255}
})

-- button:SetEnterCallback(function() mGUI.ShowPopTip() end)
-- button:SetLeaveCallback(function() mGUI.HidePopTip() end)

-- textView:SetEnterCallback(function() mGUI.ShowPopTip("这里是一个不可编辑的文本列表") end)
-- textView:SetLeaveCallback(function() mGUI.HidePopTip() end)

for _, text in ipairs(textList) do
    textView:AppendText(text)
    break
end

textView:Transform({
    x = 200, y = 90,
    w = 500, h = 600
})

mGUI.Place(textView)
mGUI.Place(button)

while g_bIsRunning do
    
    local _nStartTime = mTime.GetInitTime()
    
    mGraphic.SetDrawColor({r = 45, g = 45, b = 45, a = 255})
    mWindow.ClearWindow()
    
    while mInteract.UpdateEvent() do
        local _event = mInteract.GetEventType()
        if _event == mInteract.EVENT_QUIT then
            g_bIsRunning = false
        elseif _event == mInteract.EVENT_KEYDOWN_M then
            textView:AppendText("【小刚】\n装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点")
        elseif _event == mInteract.EVENT_KEYDOWN_C then
            textView:Transform({
                x = 200, y = 90,
                w = 750, h = 600
            })
        elseif _event == mInteract.EVENT_KEYDOWN_L then
            textView:ClearText()
        elseif _event == mInteract.EVENT_KEYDOWN_N then
            textView_1:AppendText("【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点")
        end

        mGUI.UpdateEvent(_event)
    end

    mGUI.UpdateRender()

    mWindow.UpdateWindow()
    
    mTime.DynamicSleep(
        1000 / mConfig.N_FPS,
        mTime.GetInitTime() - _nStartTime
    )
end
