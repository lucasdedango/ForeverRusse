local _, A = ...
local DAY=86400
function A:Card(ru,fr,category,source,seen)
    ru,fr=self:Plain(ru),self:Plain(fr)
    if not ru or not fr or fr:match("^%s*$") or #ru>360 or #fr>360 or not ru:find("[\208\209]") then return end
    local key=self:Normalize(ru).."\031"..fr
    local c=self.db.cards[key]
    if not c then
        local n=0; for _ in pairs(self.db.cards) do n=n+1 end
        if n>=5000 then return end
        c={ru=ru,fr=fr,category=category or "jeu",source=source or "manuel",seen=0,due=0,streak=0}; self.db.cards[key]=c
    end
    if seen then local now=self:Now(); if not c.lastSeen or now-c.lastSeen>=30 then c.seen=c.seen+1; c.lastSeen=now end end
    return c
end
function A:Seed(category)
    for _,r in ipairs(self.vocabulary) do if not category or category==r[3] then self:Card(r[1],r[2],r[3],"lexique") end end
end
function A:Observe(ru,fr,source)
    if not self:On("collect") or not ru then return end
    if fr then self:Card(ru,fr,"jeu",source,true) end
    for _,w in ipairs(self:Words(ru)) do local r=self:Gloss(w); if r then self:Card(r[1],r[2],r[3],source,true) end end
end
function A:Grade(c,good,now)
    now=now or self:Now(); c.reviews=(c.reviews or 0)+1
    if good then c.streak=(c.streak or 0)+1; c.due=now+({DAY,3*DAY,7*DAY,14*DAY,30*DAY})[math.min(c.streak,5)]
    else c.streak=0; c.due=now+300; c.errors=(c.errors or 0)+1 end
    c.lastReview=now
    local stats=self.db.stats; local day=math.floor(now/DAY)
    if stats.day~=day then stats.day=day; stats.today=0 end
    stats.today=(stats.today or 0)+1; stats.total=(stats.total or 0)+1
end
function A:LetterCard(r)
    local c=self.db.letters[r[1]]; if not c then c={streak=0,due=0}; self.db.letters[r[1]]=c end
    c.ru=r[1].." "..r[2]; c.fr=r[3]; c.note=r[4]; return c
end
function A:Next(mode)
    local pool={}; local now=self:Now()
    if mode=="alphabet" then for _,r in ipairs(self.alphabet) do pool[#pool+1]=self:LetterCard(r) end
    else for _,c in pairs(self.db.cards) do if mode~="phrase" or c.category=="phrase" then pool[#pool+1]=c end end end
    local eligible={}; for _,c in ipairs(pool) do if (c.due or 0)<=now then eligible[#eligible+1]=c end end
    if #eligible==0 then return nil end
    table.sort(eligible,function(a,b) if (a.due or 0)==(b.due or 0) then return a.ru<b.ru end return (a.due or 0)<(b.due or 0) end)
    return eligible[1],pool
end
function A:Choices(c,pool,reverse)
    local key=reverse and "ru" or "fr"; local options={c[key]}; local used={[c[key]]=true}; local candidates={}
    for _,other in ipairs(pool) do if other[key] and not used[other[key]] then used[other[key]]=true; candidates[#candidates+1]=other[key] end end
    while #options<4 and #candidates>0 do options[#options+1]=table.remove(candidates,math.random(#candidates)) end
    for i=#options,2,-1 do local j=math.random(i); options[i],options[j]=options[j],options[i] end
    return options,c[key]
end
function A:Stats()
    local total,known,due,letters=0,0,0,0; local now=self:Now()
    for _,c in pairs(self.db.cards) do total=total+1; if (c.streak or 0)>=3 then known=known+1 end; if (c.due or 0)<=now then due=due+1 end end
    for _,c in pairs(self.db.letters) do if (c.streak or 0)>=3 then letters=letters+1 end end
    return total,known,due,letters,(self.db.stats.day==math.floor(now/DAY) and self.db.stats.today or 0)
end
