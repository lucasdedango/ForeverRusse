-- Run from repository root: lua5.1 tests/run.lua
local A={}; local clock=1700000000
GetServerTime=function() return clock end
local count=0
local function eq(a,b) assert(a==b,tostring(a).." != "..tostring(b)); count=count+1 end
for line in io.lines("ForeverRusse/ForeverRusse.toc") do if line:match("%.lua$") then assert(loadfile("ForeverRusse/"..line))("ForeverRusse",A) end end
A:InitDB()
eq(#A.alphabet,33); eq(A:Normalize("ЛЁД"),"лёд"); eq(A:Normalize("  ВОДА́  "),"вода")
eq(A:Translit("лес"),"les"); eq(A:Gloss("волков")[2],"loup"); eq(#A:Words("В лесу, книга! 12"),3)
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

eq(A:Translit("съе́шь"), "s\"esh'")
eq(A:Translit("Хороший отдых"), "khoroshiy otdykh")
eq(A:Translit("хоро́ший о́тдых"), "khoroshiy otdykh")
eq(A:Translit("Ёж, щука, чай и Юлия."), "yozh, shchuka, chay i yuliya.")
eq(A:Color("о́"), "|cffffbf69о́|r")
eq(A:Color("А́"), "А́")
assert(A:FontSamples():find("Щ Ъ Ы Ь Э Ю Я",1,true))
eq(A.db.settings.tooltipBelowTitle,true)

-- Simulate Forever's line callback, item post-call, and comparison deltas.
local linePost, itemPost, comparisonPost
TooltipDataProcessor = {
    AllTypes="ALL",
    AddLinePostCall=function(_, callback) linePost=callback end,
    AddTooltipPostCall=function(_, callback) itemPost=callback end,
}
Enum = {TooltipDataType={Item=0}}
TooltipComparisonManager = { SetItemTooltip=function() end }
hooksecurefunc = function(_, method, callback)
    eq(method,"SetItemTooltip")
    comparisonPost=callback
end
local function newTip()
    local tip = { lines={"Titre français"}, titleColor={.64,.21,.93} }
    function tip:NumLines() return #self.lines end
    function tip:GetLeftLine(i)
        if not self.lines[i] then return end
        return { GetText=function() return self.lines[i] end }
    end
    function tip:GetProcessingTooltipInfo() return self.info end
    function tip:GetPrimaryTooltipInfo() return self.info end
    function tip:GetPrimaryTooltipData() return self.info.tooltipData end
    function tip:Show() end
    function tip:Clear()
        self.lines={"Titre français"}
        if self.inserted then self.inserted:Hide() end
    end
    tip.info={tooltipData={type=0,id=6948}}
    return tip
end
CreateFrame = function()
    local frame = {}
    function frame:Hide() self.shown=false end
    function frame:IsShown() return self.shown end
    function frame:SetSize() end
    function frame:CreateFontString()
        return {
            GetFont=function() return "Original.ttf",12,"" end,
            SetFont=function(_, path)
                assert(path:find("DejaVuSans.ttf",1,true))
                return true
            end,
            SetPoint=function() end, SetJustifyH=function() end,
            SetWordWrap=function() end, SetWidth=function() end,
            GetStringWidth=function() return 120 end, GetStringHeight=function() return 28 end,
            SetTextColor=function(_, ...) frame.color={...} end,
            SetText=function(_, text) frame.label=text end,
        }
    end
    return frame
end
GameTooltip_InsertFrame = function(tip, frame)
    tip.lines[#tip.lines+1]="RU"
    tip.inserted=frame
    frame.shown=true
end
GameTooltip, ShoppingTooltip1, ShoppingTooltip2 = newTip(), newTip(), newTip()
TooltipComparisonManager.tooltip={shoppingTooltips={ShoppingTooltip1,ShoppingTooltip2}}
A:InstallTooltips()
local function processItem(tip)
    linePost(tip)
    tip.lines[#tip.lines+1]="Statistiques"
    itemPost(tip,tip.info.tooltipData)
end
for _,tip in ipairs({GameTooltip,ShoppingTooltip1,ShoppingTooltip2}) do
    local color=tip.titleColor
    processItem(tip)
    eq(table.concat(tip.lines,"/"),"Titre français/RU/Statistiques")
    eq(tip.titleColor,color)
    eq(tip.inserted.color[2],.82)
    assert(tip.inserted.label:find("\n|cffb8b8b8",1,true))
    itemPost(tip,tip.info.tooltipData)
    eq(#tip.lines,3)
    tip:Clear()
end
A.db.settings.tooltipBelowTitle=false
A.db.settings.hints=false
processItem(GameTooltip)
eq(table.concat(GameTooltip.lines,"/"),"Titre français/Statistiques/RU")
assert(not GameTooltip.inserted.label:find("\n",1,true))
processItem(ShoppingTooltip1)
ShoppingTooltip1.lines[3]="Écart"
comparisonPost(TooltipComparisonManager,true)
eq(table.concat(ShoppingTooltip1.lines,"/"),"Titre français/Statistiques/Écart/RU")
processItem(ShoppingTooltip2)
ShoppingTooltip2.lines[3]="Écart"
comparisonPost(TooltipComparisonManager,false)
eq(table.concat(ShoppingTooltip2.lines,"/"),"Titre français/Statistiques/Écart/RU")
GameTooltip:Clear()
InCombatLockdown=function() return true end
processItem(GameTooltip)
eq(#GameTooltip.lines,2)
InCombatLockdown=nil
issecretvalue=function(value) return value == GameTooltip.info.tooltipData end
GameTooltip:Clear()
processItem(GameTooltip)
eq(#GameTooltip.lines,2)
issecretvalue=nil
assert(not next(A.errors), next(A.errors))
print("OK: "..count.." assertions + additional checks; "..total.." starter cards")
