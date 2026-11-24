local _, A = ...
function A:Voices()
    if not C_VoiceChat then return {} end
    local v=self:Safe("TTS:voices",C_VoiceChat.GetTtsVoices); return type(v)=="table" and v or {}
end
function A:Speak(text)
    if not self:On("audio") or not text or text=="" then return false end
    if self:Combat() then self:Print("Audio indisponible pendant le combat."); return false end
    if not C_VoiceChat or not C_VoiceChat.SpeakText then self:Print("API TTS indisponible."); return false end
    local id=self.db.settings.voiceID
    local voices=self:Voices(); local found
    for _,v in ipairs(voices) do
        local n=string.lower(tostring(v.name or v.voiceName or "")); local lang=tostring(v.language or v.locale or ""):lower()
        if id~=nil and v.voiceID==id then found=id; break end
        if id==nil and (n:find("russian",1,true) or n:find("russe",1,true) or n:find("irina",1,true) or n:find("pavel",1,true) or lang:match("^ru") or n:find("рус",1,true)) then found=v.voiceID; break end
    end
    if found==nil then self:Print("Aucune voix russe détectée. /fru voices puis /fru voice ID."); return false end
    -- Local modern TTS only; never uses remote voices or voice chat.
    local safe=text:gsub("́",""):gsub("<"," "):gsub(">"," "):gsub("|"," ")
    local ok,err=pcall(C_VoiceChat.SpeakText,found,safe,-1,80,false)
    if not ok then self.errors["TTS"]=tostring(err); self:Print("Échec TTS ; voir /fru debug.") end
    return ok
end
