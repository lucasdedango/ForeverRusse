local _, A = ...
local methods={item="GetItemName",spell="GetSpellName",npc="GetNpcName",quest="GetQuest",map="GetMapName"}
function A:Provider()
    local db=ForeverRosettaStoneDB
    if type(db)=="table" and db.apiVersion==3 then return db end
end
function A:Lookup(kind,id,locale)
    id=self:ID(id); if not id then return end; locale=locale or "ruRU"
    local db=self:Provider(); local method=methods[kind]
    if db and method then
        local v=self:Safe("FRS:"..method,db[method],db,id,locale)
        if kind=="quest" and type(v)=="table" then return v,"FRS",v.hasAITranslation end
        v=self:Plain(v)
        if v and v~="" then return v,"FRS",self:Safe("FRS:AI",db.IsAITranslated,db,kind,id,locale) end
    end
    local fallback=locale=="ruRU" and self.fallback[kind] and self.fallback[kind][id]
    if fallback then return fallback,"lexique local" end
    if self.db then
        local k=kind..":"..id; local m=self.db.missing
        if not m[k] then local n=0; for _ in pairs(m) do n=n+1 end; if n<500 then m[k]=true end end
    end
end
function A:QuestText(q)
    if type(q)~="table" then return nil end
    local chunks={}; local seen={}
    -- Explicit known semantic candidates; never mutate the shared provider record.
    for _,k in ipairs({"title","summary","description","objectives","objectiveText","completionText","progressText","rewardText","details"}) do
        local v=self:Plain(q[k]); if v and v~="" and not seen[v] then chunks[#chunks+1]=v; seen[v]=true end
    end
    return #chunks>0 and table.concat(chunks,"\n\n") or nil
end
function A:Location()
    local db=self:Provider(); if not db then return end
    local loc=self:Safe("FRS:location",db.GetPlayerLocation,db,"ruRU")
    if type(loc)~="table" then return end
    local ru,fr={},{}
    for _,k in ipairs({"zone","subzone"}) do local r=loc[k]; if type(r)=="table" and r.status=="resolved" and self:Plain(r.name) then ru[#ru+1]=r.name; fr[#fr+1]=self:Plain(r.nativeName) or ""; self:Observe(r.name,r.nativeName,"zone") end end
    if #ru>0 then return table.concat(ru," / "),table.concat(fr," / ") end
end
