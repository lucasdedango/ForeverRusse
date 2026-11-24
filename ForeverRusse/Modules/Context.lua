local _, A = ...
function A:SetContext(ru,fr,source,ai,force)
    if not self:Plain(ru) or ru=="" then return end
    self:Observe(ru,fr,source)
    if self.contextPinned and not force then return end
    if self.context and self.context.ru==ru and self.context.fr==(fr or "") and self.context.source==source then return end
    self.context={ru=ru,fr=self:Plain(fr) or "",source=source or "jeu",ai=ai}
    if self.RefreshContext then self:RefreshContext() end
end
function A:LoadQuest(id,fr)
    local q,source,ai=self:Lookup("quest",id); local ru=self:QuestText(q)
    if not ru then return false end
    local title=self:Plain(q.title); local fq=self:Lookup("quest",id,"frFR")
    if title then self:Observe(title,type(fq)=="table" and self:Plain(fq.title) or nil,"quête") end
    if ru then self:SetContext(ru,fr or self:QuestText(fq),"quête #"..id.." / "..source,ai,true) end
    return true
end
function A:ContextGlossary()
    local out, seen={},{}
    if not self.context then return out end
    for _,w in ipairs(self:Words(self.context.ru)) do local r=self:Gloss(w); if r and not seen[r[1]] then seen[r[1]]=true; out[#out+1]={w,r[1],r[2]} end end
    return out
end
