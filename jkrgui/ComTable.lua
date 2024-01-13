Com = {}
ComTable = {} -- ComTable Draw ko laagi Jkr.Components.Abstract.Drawable can be buffered here
ComTable_Dispatch = {} -- Comtable Dispatch ko laagi Jkr.Components.Abstract.Dispatchable can be buffered here
ComTable_SingleTimeDispatch = {} -- Comtable SingleTime Dispatch ko laagi yaa pani yei 
ComTable_Event =  {} -- Comtable Events ko laagi Jkr.Components.Abstract.Eventable can be buffered here
ComTable_Update = {} -- ComTable Updates ko laagi Jkr.Components.Abstract.Updatable can be buffered here
ComTable_SingleTimeUpdate = {} -- Same here

com_i = 0
Com.NewComponent = function()
    com_i = com_i + 1
end

com_disi = 0
Com.NewComponent_Dispatch = function()
    com_disi = com_disi + 1
end

com_sdisi = 0
Com.NewComponent_SingleTimeDispatch = function()
    com_sdisi = com_sdisi + 1
end

com_evi = 0
Com.NewComponent_Event = function()
    com_evi = com_evi + 1 
end

com_upd = 0
Com.NewComponent_Update = function()
    com_upds = com_upd + 1 
end

com_upds = 0
Com.NewComponent_SingleTimeUpdate = function()
    com_upds = com_upds + 1 
end

Com.Events = function()
    for _, com in ipairs(ComTable_Event) do
        com:Event()
    end
end

local gDispatchesLoadedIndex = 1
Com.Dispatches = function()
    if gDispatchesLoadedIndex <= #ComTable_SingleTimeDispatch then
        print(gDispatchesLoadedIndex)
        ComTable_SingleTimeDispatch[gDispatchesLoadedIndex]:Dispatch()
        gDispatchesLoadedIndex = gDispatchesLoadedIndex + 1
    end
end

Com.Draws = function()
    for _, com in ipairs(ComTable) do
        if com.SetScissor then com:SetScissor() end
        com:Draw()
        if com.SetScissor then Jkr.reset_scissor() end
    end
end


Com.Update = function()
    
end