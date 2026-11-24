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
    elseif kind=="npc" and tip then local line=tip:GetLeftLine(1); if line then v=A:Safe("npc:name",line.GetText,line) end end
    return A:Plain(v)
end
local function npcID(guid)
    guid=A:Plain(guid); if not guid then return end
    local kind,_,_,_,_,id=guid:match("^(%a+)%-([^-]+)%-([^-]+)%-([^-]+)%-([^-]+)%-([^-]+)%-")
    if kind=="Creature" or kind=="Vehicle" then return A:ID(tonumber(id)) end
end
local tooltipFrames = setmetatable({}, {__mode="k"})
local pendingComparison = setmetatable({}, {__mode="k"})
local tooltipSettings = {item="tooltips", spell="spells", npc="units"}

local function isComparison(tip)
    return tip == ShoppingTooltip1 or tip == ShoppingTooltip2
end

local function comparisonTooltip(manager, primary)
    local tips = manager.tooltip and manager.tooltip.shoppingTooltips
    if tips then return tips[primary and 1 or 2] end
end

local function translationBlock(tip)
    local frame = tooltipFrames[tip]
    if not frame then
        frame = CreateFrame("Frame", nil, tip)
        frame:Hide()
        frame.text = frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
        A:ApplyFont(frame.text)
        frame.text:SetPoint("TOPLEFT")
        frame.text:SetJustifyH("LEFT")
        frame.text:SetWordWrap(true)
        tooltipFrames[tip] = frame
    end
    return frame
end

function A:Tooltip(kind, tip, data)
    if self:Combat() or not self:On(tooltipSettings[kind]) then return end
    if not data or (issecretvalue and issecretvalue(data)) then return end
    local frame = tooltipFrames[tip]
    if frame and frame:IsShown() then return end
    local title = tip:GetLeftLine(1)
    if not title or not self:Plain(title:GetText()) then return end

    local id
    if kind == "npc" then
        id = npcID(data.guid)
    else
        id = self:ID(data.id)
        if not id and kind == "item" then
            local link = self:Plain(data.hyperlink)
            id = link and self:ID(tonumber(link:match("|Hitem:(%d+)") or link:match("^item:(%d+)")))
        end
    end
    if not id then return end
    local ru, src, ai = self:Lookup(kind, id)
    if not ru then return end

    frame = translationBlock(tip)
    local text = frame.text
    local label = self:Color(ru)..(ai and " |cffaaaaaa[IA]|r" or "")
    if self:On("hints") then
        label = label.."\n|cffb8b8b8"..self:Translit(ru).."|r"
    end
    text:SetTextColor(1, .82, .42)
    text:SetWidth(0)
    text:SetText(label)
    local width = math.max(1, math.min(300, math.ceil(text:GetStringWidth())))
    text:SetWidth(width)
    frame:SetSize(width, math.max(1, math.ceil(text:GetStringHeight())))
    GameTooltip_InsertFrame(tip, frame, 1)

    if not isComparison(tip) then
        local fr = native(kind,id,tip) or self:Lookup(kind,id,"frFR")
        self:SetContext(ru,fr,kind.." #"..id.." / "..src,ai)
    end
end

local function primaryData(tip)
    if tip ~= GameTooltip and tip ~= ItemRefTooltip and not isComparison(tip) then return end
    local info = tip:GetProcessingTooltipInfo()
    if info and info == tip:GetPrimaryTooltipInfo() then return info.tooltipData end
end

function A:InstallTooltips()
    local processor = TooltipDataProcessor
    if not processor or not processor.AddTooltipPostCall or not GameTooltip_InsertFrame
        or not Enum or not Enum.TooltipDataType then
        self.errors.tooltips = "Insertion des infobulles indisponible"
        return
    end
    local kinds = {}
    local comparisonManager = TooltipComparisonManager
    local comparisonHook = comparisonManager and comparisonManager.SetItemTooltip and hooksecurefunc
    if comparisonHook then
        -- ShoppingTooltip adds stat deltas after its item post-call.
        hooksecurefunc(comparisonManager, "SetItemTooltip", function(manager, primary)
            A:Safe("tooltip:comparison", function()
                local tip = comparisonTooltip(manager, primary)
                local data = tip and pendingComparison[tip]
                if not data then return end
                pendingComparison[tip] = nil
                if data == tip:GetPrimaryTooltipData() then
                    A:Tooltip("item", tip, data)
                    if not A:Combat() then tip:Show() end
                end
            end)
        end)
    end

    for name, kind in pairs({Item="item", Spell="spell", Unit="npc"}) do
        local dataType = Enum.TooltipDataType[name]
        if dataType ~= nil then
            kinds[dataType] = kind
            processor.AddTooltipPostCall(dataType, function(tip, data)
                A:Safe("tooltip:"..kind, function()
                    if A:Combat() or (issecretvalue and issecretvalue(data)) then return end
                    if not data or primaryData(tip) ~= data then return end
                    local frame = tooltipFrames[tip]
                    if frame and frame:IsShown() then return end
                    if kind == "item" and comparisonHook and isComparison(tip)
                        and not A:On("tooltipBelowTitle") then
                        pendingComparison[tip] = data
                    else
                        A:Tooltip(kind, tip, data)
                    end
                end)
            end)
        end
    end

    if processor.AddLinePostCall and processor.AllTypes then
        processor.AddLinePostCall(processor.AllTypes, function(tip)
            if not A:On("tooltipBelowTitle") or A:Combat() then return end
            A:Safe("tooltip:title", function()
                local data = primaryData(tip)
                if not data or (issecretvalue and issecretvalue(data)) or tip:NumLines() ~= 1 then return end
                local dataType = data.type
                if issecretvalue and issecretvalue(dataType) then return end
                local kind = kinds[dataType]
                if kind then A:Tooltip(kind, tip, data) end
            end)
        end)
    end
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
    elseif cmd=="fonttest" then self:ShowTab("fonttest")
    elseif cmd=="quest" then local id=self:ID(tonumber(arg)); if id and self:LoadQuest(id) then self:ShowTab("context") else self:Print("Quête sans traduction disponible.") end
    elseif cmd=="add" then local ru,fr=arg:match("^(.-)%s*;%s*(.+)$"); if ru and self:Card(ru,fr,"manuel","manuel") then self:Print("Carte ajoutée."); self:RefreshStats() else self:Print("/fru add RUSSE ; FRANÇAIS") end
    elseif cmd=="seed" then self:Seed(arg~="" and arg or nil); self:Print("Lexique ajouté."); self:RefreshStats()
    else self:Print("/fru [alphabet|review|context|dictionary|grammar|settings|quest ID|add RU ; FR|seed|voices|voice ID|say TEXTE|fonttest|debug|hide]") end
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
