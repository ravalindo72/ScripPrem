        VyperUI:CreateToggle(PlayerTab, {
            Title = "Performance Panel",
            Subtitle = "Show FPS, Ping & Device CPU Load",
            AutoSave = true,
            Default = false,
            Callback = function(state)
                if state then
                    Monitor:Start()
                else
                    Monitor:Stop()
                end
            end
        })
    end
