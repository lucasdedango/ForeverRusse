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
-- Latin spelling for Russian text. The alphabet cards keep their
-- French-oriented hints for individual letters.
local romanization = {
    ["е"]="e", ["ё"]="yo", ["ж"]="zh", ["у"]="u", ["ч"]="ch",
    ["ш"]="sh", ["щ"]="shch", ["э"]="e", ["ю"]="yu", ["я"]="ya",
}
function A:Translit(s)
    local out = {}
    for c in self:Chars(s) do
        local letter = self.letterMap[c]
        if c ~= "́" then
            out[#out+1] = letter and (romanization[letter[2]] or letter[3]) or c
        end
    end
    return table.concat(out)
end
function A:Color(s)
    if not self:On("colorLetters") then return s end
    local out, glyph, highlight = {}, nil, false
    local function flush()
        if glyph then
            out[#out+1] = highlight and ("|cffffbf69"..glyph.."|r") or glyph
        end
    end
    for c in self:Chars(s) do
        if c == "́" and glyph then
            glyph = glyph..c
        else
            flush()
            local r = self.letterMap[c]
            local progress = r and self.db.letters[r[1]]
            glyph = c
            highlight = r and (not progress or (progress.streak or 0)<3)
        end
    end
    flush()
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
