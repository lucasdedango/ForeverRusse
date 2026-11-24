local _, A = ...
local function label(parent, x,y,w,text,template)
    local f=parent:CreateFontString(nil,"OVERLAY",template or "GameFontHighlight")
    A:ApplyFont(f)
    f:SetPoint("TOPLEFT",x,y); f:SetWidth(w); f:SetJustifyH("LEFT"); f:SetJustifyV("TOP"); f:SetText(text or ""); return f
end
local function button(parent,x,y,w,h,text,fn)
    local b=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate"); b:SetSize(w,h); b:SetPoint("TOPLEFT",x,y); A:ApplyButtonFonts(b); b:SetText(text); b:SetScript("OnClick",fn); return b
end
local function scroll(parent,x,y,w,h)
    local s=CreateFrame("ScrollFrame",nil,parent,"UIPanelScrollFrameTemplate"); s:SetPoint("TOPLEFT",x,y); s:SetSize(w,h)
    local child=CreateFrame("Frame",nil,s); child:SetSize(w-8,h); s:SetScrollChild(child); return s,child
end
local function textBlock(parent,text,w)
    local f=label(parent,0,0,w,text); f:SetSpacing(4); return f
end
local function setBlock(child,f,text,minHeight)
    f:SetText(text); child:SetHeight(math.max(minHeight or 1,f:GetStringHeight()+20))
end
local function checkbox(parent,x,y,name,key)
    local b=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate"); b:SetPoint("TOPLEFT",x,y); b:SetChecked(A:On(key)); label(parent,x+32,y-7,270,name)
    b:SetScript("OnClick",function(self) A.db.settings[key]=not not self:GetChecked(); A:RefreshContext() end); return b
end
function A:ShowTab(tab)
    if not self.frame then self:BuildUI() end
    for k,p in pairs(self.pages) do p:SetShown(k==tab) end
    self.tab=tab; self.frame:Show(); self:RefreshStats()
    if tab=="fonttest" then
        setBlock(self.fontTestChild,self.fontTestText,self:FontSamples(),375)
    end
    if tab=="alphabet" then self:RefreshAlphabet() elseif tab=="context" then self:RefreshContext() elseif tab=="dictionary" then self:RefreshDictionary() elseif tab=="review" and not self.question then self:NewQuestion() end
end
function A:RefreshStats()
    if not self.statsLabel then return end
    local n,k,d,l,t=self:Stats(); self.statsLabel:SetText(string.format("%d / 33 lettres  |  %d / %d cartes acquises  |  %d à réviser  |  %d aujourd’hui",l,k,n,d,t))
end
function A:RefreshAlphabet()
    if not self.letterButtons then return end
    for i,r in ipairs(self.alphabet) do local c=self.db.letters[r[1]]; local b=self.letterButtons[i]; b:SetText((c and (c.streak or 0)>=3 and "|cff75d69a" or "|cffffc477")..r[1].." "..r[2].."|r") end
end
function A:RefreshContext()
    if not self.contextText or not self.context or self.tab~="context" then return end
    local c=self.context; local parts={c.source..(c.ai and " • traduction IA signalée" or ""),"",self:Color(c.ru)}
    if self:On("hints") and #c.ru<400 then parts[#parts+1]="\nTranslittération : "..self:Translit(c.ru) end
    if not self:On("hideFrench") and c.fr~="" then parts[#parts+1]="\nFR : "..c.fr end
    local gloss=self:ContextGlossary(); if #gloss>0 then parts[#parts+1]="\nVOCABULAIRE RECONNU"; for _,r in ipairs(gloss) do parts[#parts+1]=r[1].." → "..r[2].." — "..r[3] end end
    setBlock(self.contextChild,self.contextText,table.concat(parts,"\n"),310); self.contextScroll:SetVerticalScroll(0)
    self:RefreshStats()
end
function A:RefreshDictionary()
    if not self.dictText then return end
    local query=self:Normalize(self.search:GetText() or ""); local rows={}
    for _,c in pairs(self.db.cards) do if query=="" or self:Normalize(c.ru):find(query,1,true) or self:Normalize(c.fr):find(query,1,true) or self:Normalize(c.category):find(query,1,true) then rows[#rows+1]=c end end
    table.sort(rows,function(a,b) return a.ru<b.ru end)
    local pageSize=35; local maxPage=math.max(1,math.ceil(#rows/pageSize)); self.dictPage=math.max(1,math.min(self.dictPage or 1,maxPage))
    local out={string.format("%d résultat(s) • page %d/%d",#rows,self.dictPage,maxPage),""}
    for i=(self.dictPage-1)*pageSize+1,math.min(#rows,self.dictPage*pageSize) do local c=rows[i]; out[#out+1]=string.format("%s — %s  [%s, %d vues]",c.ru,c.fr,c.category,c.seen or 0) end
    setBlock(self.dictChild,self.dictText,table.concat(out,"\n"),280); self.dictScroll:SetVerticalScroll(0); self:RefreshStats()
end
function A:NewQuestion()
    if not self.questionLabel then return end
    self.question=nil; self.feedback:SetText(""); for _,b in ipairs(self.answers) do b:Hide() end
    local mode=self.reviewMode or "alphabet"; local c,pool=self:Next(mode)
    if not c then self.questionLabel:SetText("Rien à réviser dans ce mode pour le moment."); return end
    local reverse=mode=="fr-ru"; local opts,correct=self:Choices(c,pool,reverse)
    self.question={card=c,correct=correct,answered=false}; self.questionLabel:SetText((reverse and "Quel mot russe ?\n" or "Que signifie / comment se lit ?\n")..(reverse and c.fr or c.ru))
    for i,opt in ipairs(opts) do local b=self.answers[i]; b.option=opt; b:SetText(opt); b:Enable(); b:Show() end
end
function A:Answer(value)
    local q=self.question; if not q or q.answered then return end; q.answered=true
    local good=value==q.correct; self:Grade(q.card,good)
    self.feedback:SetText((good and "|cff75d69aCorrect !|r" or "|cffff8b80Réponse : "..q.correct.."|r").."\n"..q.card.ru.." — "..q.card.fr..(q.card.note and "\n"..q.card.note or ""))
    for _,b in ipairs(self.answers) do b:Disable() end; self:RefreshStats()
end
function A:BuildUI()
    if self.frame then return end
    local f=CreateFrame("Frame","ForeverRussePanel",UIParent,"BackdropTemplate"); f:SetSize(720,530); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true); f:EnableMouse(true); f:SetMovable(true); f:RegisterForDrag("LeftButton"); f:SetScript("OnDragStart",f.StartMoving); f:SetScript("OnDragStop",f.StopMovingOrSizing)
    f:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=5,right=5,top=5,bottom=5}}); f:SetBackdropColor(.06,.08,.12,.97)
    label(f,24,-19,600,"ForeverRusse  •  Русский в Азероте","GameFontNormalLarge"); self.statsLabel=label(f,24,-48,670,"")
    local close=CreateFrame("Button",nil,f,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",-3,-3)
    self.frame=f; self.pages={}; if UISpecialFrames then table.insert(UISpecialFrames,"ForeverRussePanel") end
    local tabs={{"alphabet","Alphabet"},{"review","Révisions"},{"context","Contexte"},{"dictionary","Lexique"},{"grammar","Grammaire"},{"settings","Options"}}
    for i,t in ipairs(tabs) do local key=t[1]; button(f,20+(i-1)*113,-74,110,25,t[2],function() A:ShowTab(key) end); local p=CreateFrame("Frame",nil,f); p:SetPoint("TOPLEFT",24,-113); p:SetSize(670,395); p:Hide(); self.pages[key]=p end
    local p=self.pages.alphabet; label(p,0,0,665,"Clique sur une lettre pour voir son son. Vert = trois bonnes réponses consécutives.")
    self.letterButtons={}; self.letterDetail=label(p,0,-179,660,"Choisis une lettre.","GameFontNormalLarge")
    for i,r in ipairs(self.alphabet) do local rr=r; local b=button(p,((i-1)%11)*60,-30-math.floor((i-1)/11)*43,56,36,r[1],function() A.selectedLetter=rr; A.letterDetail:SetText(rr[1].." / "..rr[2].." — "..rr[3].."\n"..rr[4]) end); self.letterButtons[i]=b end
    button(p,0,-270,180,28,"Écouter la lettre",function() if A.selectedLetter then A:Speak(A.selectedLetter[1]) end end)
    button(p,190,-270,180,28,"Tester mon alphabet",function() A.reviewMode="alphabet"; A:ShowTab("review"); A:NewQuestion() end)
    label(p,0,-320,650,"La translittération est un repère de lecture, pas une transcription phonétique exacte. Les signes Ъ et Ь n’ont pas de son propre.")
    p=self.pages.review
    for i,m in ipairs({{"alphabet","Lettres"},{"ru-fr","RU → FR"},{"fr-ru","FR → RU"},{"phrase","Phrases"}}) do local mode=m[1]; button(p,(i-1)*145,0,140,26,m[2],function() A.reviewMode=mode; A:NewQuestion() end) end
    self.questionLabel=label(p,0,-45,655,"","GameFontNormalLarge"); self.answers={}
    for i=1,4 do local b=button(p,0,-100-(i-1)*36,650,31,"",function(self) A:Answer(self.option) end); self.answers[i]=b end
    self.feedback=label(p,0,-250,655,""); button(p,0,-330,160,28,"Question suivante",function() A:NewQuestion() end)
    button(p,170,-330,130,28,"Écouter",function() if A.question then A:Speak(A.question.card.ru) end end)
    p=self.pages.context; self.contextScroll,self.contextChild=scroll(p,0,0,638,310); self.contextText=textBlock(self.contextChild,"Survole un objet ou un sort, cible un PNJ, change de zone ou ouvre une quête. /fru quest ID pour une quête précise.",630)
    button(p,0,-326,135,27,"Écouter le russe",function() if A.context then A:Speak(A.context.ru) end end)
    button(p,145,-326,150,27,"Afficher / cacher FR",function() A.db.settings.hideFrench=not A:On("hideFrench"); A:RefreshContext() end)
    button(p,305,-326,150,27,"Ajouter au lexique",function() local c=A.context; if c and A:Card(c.ru,c.fr,"jeu",c.source) then A:Print("Ajouté."); A:RefreshStats() else A:Print("Texte trop long ou traduction indisponible.") end end)
    local pin=button(p,465,-326,150,27,"Épingler le texte",function(b) A.contextPinned=not A.contextPinned; b:SetText(A.contextPinned and "Désépingler" or "Épingler le texte") end)
    p=self.pages.dictionary; label(p,0,0,120,"Recherche :"); self.search=CreateFrame("EditBox",nil,p,"InputBoxTemplate"); self.search:SetSize(300,25); self.search:SetPoint("TOPLEFT",95,5); self.search:SetAutoFocus(false); self:ApplyFont(self.search); self.search:SetScript("OnTextChanged",function() A.dictPage=1; A:RefreshDictionary() end); self.search:SetScript("OnEscapePressed",function(s) s:ClearFocus() end)
    self.dictScroll,self.dictChild=scroll(p,0,-35,638,285); self.dictText=textBlock(self.dictChild,"",630)
    button(p,0,-335,100,27,"Précédent",function() A.dictPage=(A.dictPage or 1)-1; A:RefreshDictionary() end); button(p,110,-335,100,27,"Suivant",function() A.dictPage=(A.dictPage or 1)+1; A:RefreshDictionary() end)
    button(p,220,-335,210,27,"Ajouter lexique de base",function() A:Seed(); A:RefreshDictionary() end)
    p=self.pages.grammar; local _,child=scroll(p,0,0,638,375); local content={"Fiches de grammaire • exemples pédagogiques indépendants du jeu\n"}; for _,r in ipairs(self.grammar) do content[#content+1]="|cffffc477"..r[1].."|r\n"..r[2].."\n" end; local g=textBlock(child,table.concat(content,"\n"),630); setBlock(child,g,375)
    p=self.pages.settings; local settings={{"Objets : infobulles","tooltips"},{"Sorts : infobulles","spells"},{"PNJ : cible / infobulle","units"},{"Quêtes : contexte","quests"},{"Zones : contexte","zones"},{"Ouvrir le panneau de quête","autoQuest"},{"Proposer une révision en taxi","autoReview"},{"Collecte automatique","collect"},{"Translittération","hints"},{"Colorer les lettres non acquises","colorLetters"},{"Prononciation TTS","audio"},{"Masquer le français (contexte)","hideFrench"}}
    for i,s in ipairs(settings) do checkbox(p,((i-1)%2)*330,-math.floor((i-1)/2)*35,s[1],s[2]) end
    button(p,0,-235,150,28,"Lister les voix",function() A:ListVoices() end); button(p,160,-235,150,28,"Diagnostics",function() A:Debug() end); button(p,320,-235,180,28,"Test audio russe",function() A:Speak("Привет! Я учу русский язык.") end)
    label(p,0,-280,660,"/fru voice ID : choisir une voix locale. /fru add RUSSE ; FRANÇAIS : carte manuelle. /fru quest ID : ouvrir une quête. Les données FRS sont facultatives. Les préférences sont communes au compte.")
    checkbox(p,0,-327,"Russe sous le titre (sinon en bas)","tooltipBelowTitle")
    button(p,340,-330,180,28,"Tester la police",function() A:ShowTab("fonttest") end)
    p=CreateFrame("Frame",nil,f); p:SetPoint("TOPLEFT",24,-113); p:SetSize(670,395)
    self.pages.fonttest=p
    local _,fontTestChild=scroll(p,0,0,638,375)
    self.fontTestChild=fontTestChild
    self.fontTestText=textBlock(fontTestChild,"",630)
    self:RefreshStats(); f:Hide()
end
