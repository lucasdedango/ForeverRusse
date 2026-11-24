local name, A = ...
A.name, A.version = name, "0.1.0"
A.defaults = {tooltips=true, spells=true, units=true, quests=true, zones=true, autoQuest=false, autoReview=false, collect=true, hints=true, colorLetters=true, audio=true, hideFrench=false}
A.errors = {}
function A:Print(msg) print("|cffd9b66aForeverRusse:|r "..tostring(msg)) end
function A:Safe(label, fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a,b,c = pcall(fn, ...)
    if ok then return a,b,c end
    self.errors[label] = tostring(a)
    return nil
end
function A:Plain(v)
    if issecretvalue and issecretvalue(v) then return nil end
    if type(v)=="string" then return v end
end
function A:ID(v)
    if issecretvalue and issecretvalue(v) then return nil end
    if type(v)=="number" and v>0 and v==math.floor(v) then return v end
end
function A:Now() return (GetServerTime and GetServerTime()) or time() end
function A:InitDB()
    if type(ForeverRusseDB)~="table" then ForeverRusseDB={} end
    local db=ForeverRusseDB
    for _, k in ipairs({"settings","cards","letters","stats","missing"}) do if type(db[k])~="table" then db[k]={} end end
    for k,v in pairs(self.defaults) do if db.settings[k]==nil then db.settings[k]=v end end
    db.schema=1; self.db=db
end
function A:On(k) return self.db and self.db.settings[k] end
function A:Combat() return InCombatLockdown and InCombatLockdown() end
function A:Event(event, fn)
    self.events=self.events or {}
    if not self.events[event] then
        self.events[event]={}
        self:Safe("register:"..event,self.eventFrame.RegisterEvent,self.eventFrame,event)
    end
    table.insert(self.events[event],fn)
end
if CreateFrame then
    A.eventFrame=CreateFrame("Frame")
    A.eventFrame:SetScript("OnEvent",function(_,event,...)
        for _,fn in ipairs(A.events[event] or {}) do A:Safe(event,fn,...) end
    end)
    A:Event("ADDON_LOADED",function(addon) if addon==name then A:InitDB() end end)
end
