-- Run from repository root: lua5.1 tests/run.lua
local A={}; local clock=1700000000
GetServerTime=function() return clock end
local count=0
local function eq(a,b) assert(a==b,tostring(a).." != "..tostring(b)); count=count+1 end
for line in io.lines("ForeverRusse/ForeverRusse.toc") do if line:match("%.lua$") then assert(loadfile("ForeverRusse/"..line))("ForeverRusse",A) end end
A:InitDB()
eq(#A.alphabet,33); eq(A:Normalize("ЛЁД"),"лёд"); eq(A:Normalize("  ВОДА́  "),"вода")
eq(A:Translit("лес"),"lïés"); eq(A:Gloss("волков")[2],"loup"); eq(#A:Words("В лесу, книга! 12"),3)
A:Seed(); local total=A:Stats(); assert(total>100); A:Seed(); eq(A:Stats(),total)
local c=A:Card("тест","test","manuel","test",true); eq(c.seen,1); A:Card("тест","test","manuel","test",true); eq(c.seen,1)
clock=clock+31; A:Card("тест","test","manuel","test",true); eq(c.seen,2); eq(A:Card("тест",""),nil)
A:Grade(c,true,clock); eq(c.streak,1); eq(c.due,clock+86400); A:Grade(c,false,clock); eq(c.streak,0); eq(c.due,clock+300)
local card,pool=A:Next("alphabet"); eq(#pool,33); local opts,answer=A:Choices(card,pool,false); eq(#opts,4); local seen={}; for _,v in ipairs(opts) do assert(not seen[v]); seen[v]=true end; assert(seen[answer])
local l=A:LetterCard(A.alphabet[1]); A:Grade(l,true); A:Grade(l,true); A:Grade(l,true); local _,_,_,letters=A:Stats(); eq(letters,1); eq(A:Color("А"),"А")
eq(A:Lookup("item",6948),"Камень возвращения"); eq(A:Lookup("item",999999),nil)
ForeverRosettaStoneDB={apiVersion=3,GetItemName=function(_,id,locale) eq(locale,"ruRU"); return "тест" end,GetQuest=function(_,id,locale) return {title=locale=="ruRU" and "Лес" or "Forêt",description=locale=="ruRU" and "Найти книгу" or "Trouver un livre",hasAITranslation=true} end,GetPlayerLocation=function() return {zone={status="resolved",name="Лес",nativeName="Forêt"}} end}
eq(A:Lookup("item",1),"тест"); eq(A:LoadQuest(1),true); assert(A.context.ru:find("Найти книгу",1,true)); eq(A.context.ai,true); eq(A:Location(),"Лес")
A.contextPinned=true; A:SetContext("вода","eau","test"); assert(A.context.ru:find("Найти книгу",1,true)); A.contextPinned=false
local spoke; C_VoiceChat={GetTtsVoices=function() return {{voiceID=2,name="Microsoft Irina"}} end,SpeakText=function(id,text,rate,volume,overlap) spoke={id,text,rate,volume,overlap} end}; eq(A:Speak("вода́"),true); eq(spoke[1],2); eq(spoke[2],"вода"); eq(spoke[5],false)
ForeverRosettaStoneDB.apiVersion=99; eq(A:Provider(),nil)
print("OK: "..count.." assertions + additional checks; "..total.." starter cards")
