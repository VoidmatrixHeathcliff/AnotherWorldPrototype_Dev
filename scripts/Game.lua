mConfig = require("Config")
TextView = require("TextView")

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

for _, text in ipairs(textList) do
    TextView.AppendText(text)
    break
end

os.execute("chcp 65001")

while g_bIsRunning do
    
    local _nStartTime = mTime.GetInitTime()
    
    mGraphic.SetDrawColor({r = 45, g = 45, b = 45, a = 255})
    mWindow.ClearWindow()
    
    while mInteract.UpdateEvent() do
        local _event = mInteract.GetEventType()
        if _event == mInteract.EVENT_QUIT then
            g_bIsRunning = false
        elseif _event == mInteract.EVENT_KEYDOWN_M then
            TextView.AppendText("【小刚】装备【守护者之盾】，自身物理防御提升 30 点，每回合生命值回复提升 75 点")
        end
        TextView.HandleEvent(_event)
    end

    TextView.DrawSelf()

    mWindow.UpdateWindow()
    
    mTime.DynamicSleep(
        1000 / mConfig.N_FPS,
        mTime.GetInitTime() - _nStartTime
    )
end
