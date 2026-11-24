local _, A = ...
A.letterMap={}
for _,r in ipairs(A.alphabet) do A.letterMap[r[1]]=r; A.letterMap[r[2]]=r end
function A:Chars(s) return string.gmatch(s or "", "[%z\1-\127\194-\244][\128-\191]*") end
function A:Normalize(s)
    local out={}
    for c in self:Chars(s) do
        local r=self.letterMap[c]
        if c~="́" then out[#out+1]=r and r[2] or string.lower(c) end
    end
    return (table.concat(out):gsub("^%s+",""):gsub("%s+$",""))
end
function A:Translit(s)
    local out={}
    for c in self:Chars(s) do local r=self.letterMap[c]; out[#out+1]=r and r[3] or c end
    return table.concat(out)
end
function A:Color(s)
    if not self:On("colorLetters") then return s end
    local out={}
    for c in self:Chars(s) do
        local r=self.letterMap[c]; local p=r and self.db.letters[r[1]]
        if r and (not p or (p.streak or 0)<3) then c="|cffffbf69"..c.."|r" end
        out[#out+1]=c
    end
    return table.concat(out)
end
function A:Words(s)
    local words, buf={},{}
    local function flush() if #buf>0 then words[#words+1]=table.concat(buf); buf={} end end
    for c in self:Chars(s) do if self.letterMap[c] or c=="́" then buf[#buf+1]=c else flush() end end
    flush(); return words
end
A.glossary={}
for _,r in ipairs(A.vocabulary) do A.glossary[A:Normalize(r[1])]=r end
-- Explicit inflections only. No guessed lemmatization.
A.forms={ ["волков"]="волк",["волка"]="волк",["книгу"]="книга",["книги"]="книга",["лесу"]="лес",["леса"]="лес",["деревню"]="деревня",["деревне"]="деревня",["воды"]="вода",["воде"]="вода",["огня"]="огонь",["рыбу"]="рыба",["траву"]="трава",["камня"]="камень",["камни"]="камень",["стрелы"]="стрела",["руды"]="руда",["друзья"]="друг",["врагов"]="враг",["города"]="город",["городе"]="город",["дороге"]="дорога",["помощи"]="помощь" }
function A:Gloss(s)
    local key=self:Normalize(s); local r=self.glossary[key] or self.glossary[self.forms[key]]
    return r
end
