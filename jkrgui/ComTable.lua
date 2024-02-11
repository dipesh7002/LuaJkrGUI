Com = {}
ComTable = {}                    -- ComTable Draw ko laagi Jkr.Components.Abstract.Drawable can be buffered here
ComTable_Dispatch = {}           -- Comtable Dispatch ko laagi Jkr.Components.Abstract.Dispatchable can be buffered here
ComTable_SingleTimeDispatch = {} -- Comtable SingleTime Dispatch ko laagi yaa pani yei
ComTable_Event = {}              -- Comtable Events ko laagi Jkr.Components.Abstract.Eventable can be buffered here
ComTable_Update = {}             -- ComTable Updates ko laagi Jkr.Components.Abstract.Updatable can be buffered here
ComTable_SingleTimeUpdate = {}   -- Same here

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
    com_upd = com_upd + 1
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
        ComTable_SingleTimeDispatch[gDispatchesLoadedIndex]:Dispatch()
        gDispatchesLoadedIndex = gDispatchesLoadedIndex + 1
    else
        ComTable_SingleTimeDispatch = {}
        gDispatchesLoadedIndex = 1
        com_sdisi = 0
    end

    for _, com in ipairs(ComTable_Dispatch) do
        com:Dispatch()
    end
end

Com.Draws = function()
    for _, com in ipairs(ComTable) do
        com:Draw()
    end
end


local gUpdatesSingleTimeSimultaneous_Id = 1
local gUpdatesLoadedIndex               = 1
Com.Updates                             = function()
    if gUpdatesLoadedIndex <= #ComTable_SingleTimeUpdate then
        for i = 1, #ComTable_SingleTimeUpdate[gUpdatesLoadedIndex] , 1 do
            ComTable_SingleTimeUpdate[gUpdatesLoadedIndex][i]:Update()
        end
        gUpdatesLoadedIndex = gUpdatesLoadedIndex + 1
    else
        ComTable_SingleTimeUpdate = {}
        gUpdatesLoadedIndex = 1
        gUpdatesSingleTimeSimultaneous_Id = 1
        com_upds = 0
    end

    for _, com in ipairs(ComTable_Update) do
        com:Update()
    end
end

Com.NewSingleTimeDispatch               = function(inFunction)
    Com.NewComponent_SingleTimeDispatch()
    ComTable_SingleTimeDispatch[com_sdisi] = Jkr.Components.Abstract.Dispatchable:New(inFunction)
    return com_sdisi
end

Com.NewSingleTimeUpdate                 = function(inFunction)
    Com.NewComponent_SingleTimeUpdate()
    ComTable_SingleTimeUpdate[com_upds] = Jkr.Components.Abstract.Updatable:New(inFunction)
    return com_upds
end


Com.NewSimultaneousUpdate = function() gUpdatesSingleTimeSimultaneous_Id = gUpdatesLoadedIndex end
Com.NewSimultaneousSingleTimeUpdate = function(inFunction)
    local NewUpdatable = Jkr.Components.Abstract.Updatable:New(inFunction)
    if ComTable_SingleTimeUpdate[gUpdatesSingleTimeSimultaneous_Id] then
        table.insert(ComTable_SingleTimeUpdate[gUpdatesSingleTimeSimultaneous_Id], NewUpdatable)
    else
        ComTable_SingleTimeUpdate[gUpdatesSingleTimeSimultaneous_Id] = {}
        table.insert(ComTable_SingleTimeUpdate[gUpdatesSingleTimeSimultaneous_Id], NewUpdatable)
    end

    gUpdatesSingleTimeSimultaneous_Id                            = gUpdatesSingleTimeSimultaneous_Id + 1
end



Com.ClearSingleTimes = function()
    ComTable_SingleTimeUpdate = {}
    gUpdatesLoadedIndex = 1
    com_upds = 0
    ComTable_SingleTimeDispatch = {}
    gDispatchesLoadedIndex = 1
    com_sdisi = 0
end
