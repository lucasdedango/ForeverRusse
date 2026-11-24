local _, A = ...
function A:ListVoices()
    local voices=self:Voices(); if #voices==0 then self:Print("Aucune voix TTS exposée au client.") end
    for _,v in ipairs(voices) do self:Print(tostring(v.voiceID).." : "..tostring(v.name or v.voiceName or "?")) end
end
function A:Debug()
    local p=self:Provider(); self:Print("v"..self.version.." / FRS API "..(p and tostring(p.apiVersion) or "absente/incompatible"))
    if GetBuildInfo then local v,b,_,i=GetBuildInfo(); self:Print(tostring(v).." / "..tostring(b).." / TOC "..tostring(i)) end
    if GetLocale then self:Print("Locale : "..GetLocale()) end
    local n=0; for _ in pairs(self.db.missing) do n=n+1 end; self:Print("Identifiants sans traduction : "..n)
    for k,v in pairs(self.errors) do self:Print(k.." : "..v) end
end
local function native(kind,id,tip)
    local v
    if kind=="item" and C_Item then v=A:Safe("item:name",C_Item.GetItemNameByID,id)
    elseif kind=="spell" and C_Spell then v=A:Safe("spell:name",C_Spell.GetSpellName,id)
    elseif kind=="npc" and tip and tip.GetName then local n=tip:GetName(); local line=n and _G[n.."TextLeft1"]; if line then v=A:Safe("npc:name",line.GetText,line) end end
    return A:Plain(v)
end
local function npcID(guid)
    guid=A:Plain(guid); if not guid then return end
    local kind,_,_,_,_,id=guid:match("^(%a+)%-([^-]+)%-([^-]+)%-([^-]+)%-([^-]+)%-([^-]+)%-")
    if kind=="Creature" or kind=="Vehicle" then return A:ID(tonumber(id)) end
end
function A:Tooltip(kind,tip,data)
    if self:Combat() or not self.db or not tip or not data then return end
    local setting=({item="tooltips",spell="spells",npc="units"})[kind]; if not self:On(setting) then return end
    -- TooltipData fields can be secret on modern Forever. Refuse secret values.
    if issecretvalue and issecretvalue(data) then return end
    local id
    if kind=="npc" then id=npcID(data.guid) else id=self:ID(data.id) end
    if not id then return end
    local ru,src,ai=self:Lookup(kind,id); if not ru then return end
    local fr=native(kind,id,tip) or self:Lookup(kind,id,"frFR")
    local marker="RU • "..self:Color(ru)..(ai and " |cffaaaaaa[IA]|r" or "")
    -- Do not modify nonstandard tooltips or duplicate lines after reprocessing.
    if not tip.AddLine or not tip.NumLines then return end
    local name=tip.GetName and tip:GetName()
    if name then for i=1,tip:NumLines() do local fs=_G[name.."TextLeft"..i]; local line=fs and self:Plain(self:Safe("tooltip:line",fs.GetText,fs)); if line and line:find("RU • ",1,true)==1 then return end end end
    tip:AddLine(marker,1,.82,.42,true)
    if self:On("hints") then tip:AddLine(self:Translit(ru),.72,.72,.72,true) end
    self:SetContext(ru,fr,kind.." #"..id.." / "..src,ai)
end
function A:InstallTooltips()
    if not TooltipDataProcessor or not TooltipDataProcessor.AddTooltipPostCall or not Enum or not Enum.TooltipDataType then self.errors.tooltips="TooltipDataProcessor indisponible"; return end
    for _,v in ipairs({{"Item","item"},{"Spell","spell"},{"Unit","npc"}}) do local enum=Enum.TooltipDataType[v[1]]; local kind=v[2]; if enum~=nil then self:Safe("tooltip:register:"..kind,TooltipDataProcessor.AddTooltipPostCall,enum,function(t,d) A:Safe("tooltip:"..kind,A.Tooltip,A,kind,t,d) end) end end
end
local function questEvent()
    if A:Combat() or not A:On("quests") then return end
    local id=A:ID(A:Safe("quest:id",GetQuestID)); if not id then return end
    local parts={}; for _,fn in ipairs({GetTitleText or false,GetQuestText or false,GetObjectiveText or false}) do local v=A:Plain(A:Safe("quest:native",fn)); if v and v~="" then parts[#parts+1]=v end end
    if A:LoadQuest(id,#parts>0 and table.concat(parts,"\n\n") or nil) and A:On("autoQuest") then A:ShowTab("context") end
end
local function zoneEvent()
    if A:Combat() or not A:On("zones") then return end
    local ru,fr=A:Location(); if ru then A:SetContext(ru,fr,"zone") end
end
local function targetEvent()
    if A:Combat() or not A:On("units") then return end
    local id=npcID(A:Safe("target:guid",UnitGUID,"target")); if not id then return end
    local ru,s,ai=A:Lookup("npc",id); if ru then A:SetContext(ru,A:Plain(A:Safe("target:name",UnitName,"target")),"PNJ #"..id.." / "..s,ai) end
end
function A:Slash(msg)
    local cmd,arg=(msg or ""):match("^%s*(%S*)%s*(.-)%s*$"); cmd=cmd:lower()
    if cmd=="" then self:ShowTab("alphabet")
    elseif self.frame and cmd=="hide" then self.frame:Hide()
    elseif cmd=="alphabet" or cmd=="context" or cmd=="dictionary" or cmd=="grammar" or cmd=="settings" or cmd=="review" then self:ShowTab(cmd)
    elseif cmd=="voices" then self:ListVoices()
    elseif cmd=="voice" then if arg=="auto" then self.db.settings.voiceID=nil; self:Print("Détection automatique.") elseif tonumber(arg) then self.db.settings.voiceID=tonumber(arg); self:Print("Voix sélectionnée : "..arg) else self:Print("/fru voice ID ou auto") end
    elseif cmd=="say" then self:Speak(arg)
    elseif cmd=="debug" then self:Debug()
    elseif cmd=="quest" then local id=self:ID(tonumber(arg)); if id and self:LoadQuest(id) then self:ShowTab("context") else self:Print("Quête sans traduction disponible.") end
    elseif cmd=="add" then local ru,fr=arg:match("^(.-)%s*;%s*(.+)$"); if ru and self:Card(ru,fr,"manuel","manuel") then self:Print("Carte ajoutée."); self:RefreshStats() else self:Print("/fru add RUSSE ; FRANÇAIS") end
    elseif cmd=="seed" then self:Seed(arg~="" and arg or nil); self:Print("Lexique ajouté."); self:RefreshStats()
    else self:Print("/fru [alphabet|review|context|dictionary|grammar|settings|quest ID|add RU ; FR|seed|voices|voice ID|say TEXTE|debug|hide]") end
end
if A.eventFrame then
    A:Event("PLAYER_LOGIN",function()
        if not A.db then A:InitDB() end
        if not A.db.seeded then A:Seed(); A.db.seeded=true end
        A:InstallTooltips()
        SLASH_FOREVERRUSSE1="/fru"; SLASH_FOREVERRUSSE2="/foreverrusse"; SlashCmdList.FOREVERRUSSE=function(msg) A:Safe("slash",A.Slash,A,msg) end
        A:Print("Prêt. /fru pour ouvrir le panneau. "..(A:Provider() and "FRS v3 détecté." or "Mode autonome ; FRS v3 facultatif."))
    end)
    A:Event("QUEST_DETAIL",questEvent); A:Event("QUEST_PROGRESS",questEvent); A:Event("QUEST_COMPLETE",questEvent)
    A:Event("ZONE_CHANGED",zoneEvent); A:Event("ZONE_CHANGED_NEW_AREA",zoneEvent); A:Event("ZONE_CHANGED_INDOORS",zoneEvent); A:Event("PLAYER_ENTERING_WORLD",function() if A.db then zoneEvent() end end)
    A:Event("PLAYER_TARGET_CHANGED",targetEvent)
    -- Low-frequency, opt-in, no automation of gameplay. Never interrupt combat.
    if C_Timer and C_Timer.NewTicker then C_Timer.NewTicker(5,function()
        if not A.db or not A:On("autoReview") then A.wasTaxi=false; return end
        local onTaxi=A:Safe("taxi",UnitOnTaxi,"player")
        if onTaxi and not A.wasTaxi and not A:Combat() then A:ShowTab("review"); A:NewQuestion() end
        A.wasTaxi=not not onTaxi
    end) end
end
