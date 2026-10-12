local A=GMMLegion735;local N=A.UI
-- Commands were checked against the running SPP server's .commands / .help.
-- Local selectors replace unsupported bulk-learning commands on this build.
A.actions={
 {key='repair',icon='Interface\\Icons\\Trade_BlackSmithing',command='.repairitems'},
 {key='cooldown',icon='Interface\\Icons\\Spell_Nature_TimeStop',command='.cooldown'},
 {key='combatStop',icon='Interface\\Icons\\Ability_Rogue_Feint',command='.combatstop',named=true},
 {key='unstuck',icon='Interface\\Icons\\INV_Misc_Rune_01',command='.start',self=true},
 {key='dismount',icon='Interface\\Icons\\Ability_Mount_RidingHorse',command='.dismount',self=true},
 {key='demorph',icon='Interface\\Icons\\Spell_Shadow_Twilight',command='.demorph'},
 {key='waterwalk',icon='Interface\\Icons\\Spell_Frost_WindWalkOn',command='.cheat waterwalk',toggle=true},
 {key='save',icon='Interface\\Icons\\INV_Misc_Book_09',command='.save',self=true},
 {key='revive',icon='Interface\\Icons\\Spell_Holy_Resurrection',command='.revive',named=true},
 {key='gm',icon='Interface\\Icons\\INV_Misc_Food_54',command='.gm',toggle=true,self=true},
 {key='god',icon='Interface\\Icons\\Spell_Holy_PowerWordShield',command='.cheat god',toggle=true,self=true},
 {key='fly',icon='Interface\\Icons\\Spell_Magic_FeatherFall',command='.gm fly',toggle=true},
 {key='up1',icon='Interface\\Icons\\Spell_Holy_InnerFire',command='.levelup 1',named=true,delta=1},
 {key='down1',icon='Interface\\Icons\\Spell_Shadow_EnslaveDemon',command='.levelup -1',named=true,delta=-1},
 {key='up10',icon='Interface\\Icons\\Spell_Holy_InnerFire',command='.levelup 10',named=true,delta=10},
 {key='down10',icon='Interface\\Icons\\Spell_Shadow_EnslaveDemon',command='.levelup -10',named=true,delta=-10},
 {key='explore',icon=134269,command='',localMap=true},
 {key='taxi',icon=132241,command='.cheat taxi',toggle=true},
 {key='gold',icon=133785,command='.modify money 10000000'},
 {key='maxskill',icon=136241,command='',maxSkills=true,self=true},
 {key='cast',icon=136011,command='.cheat casttime',toggle=true,self=true},
 {key='power',icon=136048,command='.cheat power',toggle=true,self=true},
 {key='gmskills',icon=136243,command='',picker='gm',self=true},
 {key='crafts',icon=136240,command='',picker='professions',self=true},
 {key='myclass',icon=133739,command='',picker='class',self=true},
 {key='talents',icon=136116,command='',picker='talents',self=true},
 {key='summon',icon=136039,command='.summon',playerRequired=true,named=true},
 {key='appear',icon=135736,command='.appear',playerRequired=true,named=true},
 {key='respawn',icon=136080,command='.respawn',creature=true},
 {key='cheatHelp',icon=134414,command='.help cheat',self=true},
}
-- Instance requirement overrides vary by SPP build. Offer the server help entry,
-- rather than sending an unrelated cheat command as if it removed requirements.
A.byAction={};for _,r in ipairs(A.actions)do A.byAction[r.key]=r end
function A:ExecuteAction(entry,mouse,name)
 if not entry then return end
 if entry.localMap then self:SetMapReveal(mouse~='RightButton');return end
 if mouse=='RightButton' and entry.self then self:Print(self:L('selfOnly'),true);return end
 if entry.picker then self:OpenUtilityPicker(entry.picker);return end
 if entry.maxSkills then self:MaximizeLearnedSkills(entry);return end
 if entry.creature then
  if mouse=='RightButton' then
   local guid=UnitGUID('target')or ''
   if not guid:match('^Creature%-')or not UnitIsDeadOrGhost('target')then self:Print(self:L('respawnSelect'),true);return end
  elseif UnitExists('target')then self:Print(self:L('respawnClearFailed'),true);return end
  self:SendUtility(entry,entry.command,mouse);return
 end
 local other=mouse=='RightButton' and not entry.self
 if entry.playerRequired or other then
  name=name or (UnitIsPlayer('target') and not UnitIsUnit('target','player') and UnitName('target'))
  if not name then self:NamePrompt(entry);return end
 end
 local cmd=entry.command
 if entry.toggle then
  local unit=other and (UnitGUID('target') or name) or UnitGUID('player')
  local key=tostring(unit)..':'..entry.key
  local nextValue=not self.toggles[key];self.toggles[key]=nextValue
  cmd=cmd..' '..(nextValue and 'on' or 'off')
 end
 if entry.delta and name then cmd='.levelup '..name..' '..entry.delta
 elseif entry.named and name then cmd=cmd..' '..name end
 self:SendUtility(entry,cmd,mouse)
end
function A:MaximizeLearnedSkills(entry)
 if self:Combat()then self:Print(self:L('combat'),true);return end
 if not UnitIsUnit('target','player')then self:Print(self:L('selfTargetFail'),true);return end
 local count=0
 for _,p in ipairs(self.data.professions)do
  local rank,cap=self:ProfessionState(p.id)
  if cap>0 and rank<cap then self:SendUtility(entry,'.setskill '..p.id..' '..cap..' '..cap,'LeftButton');count=count+1 end
 end
 if count==0 then self:Print(self:L('skillsAlreadyMax'));if self.frames.Utilities then self.frames.Utilities.note:SetText(self:L('skillsAlreadyMax'))end end
end
function A:SendUtility(entry,command,mouse)
 local record={key=entry.key,command=command,mouse=mouse,time=time(),version=self.version,replies={},status='sent'}
 if entry.creature then record.creatureGUID=UnitGUID('target');record.deadBefore=UnitIsDeadOrGhost('target')or false end
 self.utilityRequest={record=record,expires=GetTime()+3}
 GMMLegionDiagnostics.utilityHistory=GMMLegionDiagnostics.utilityHistory or {}
 local history=GMMLegionDiagnostics.utilityHistory;history[#history+1]=record;if #history>20 then table.remove(history,1)end
 self.sendingUtility=true;local sent=self:Send(command);self.sendingUtility=nil
 if not sent then record.status='notSent';self.utilityRequest=nil;return false end
 if self.frames.Utilities then self.frames.Utilities.note:SetText(self:L(entry.creature and 'respawnSent'or 'pending'))end
 if entry.creature and record.creatureGUID then self:After(.8,function()
  if UnitGUID('target')==record.creatureGUID then
   record.deadAfter=UnitIsDeadOrGhost('target')or false
   if record.deadBefore and not record.deadAfter then record.status='confirmed';if A.frames.Utilities then A.frames.Utilities.note:SetText(A:L('respawnConfirmed'))end end
  end
 end)end
 return true
end
A:On('GMM_SERVER_REPLY',function(message)
 local request=A.utilityRequest;if not request or GetTime()>request.expires then return end
 local record=request.record;if #record.replies>=8 then return end
 local text=tostring(message):gsub('[\r\n]+',' '):sub(1,600);record.replies[#record.replies+1]=text;record.status='reply'
 if A.frames.Utilities then A.frames.Utilities.note:SetText(A:L('serverReply')..': '..text)end
end)
function A:NamePrompt(entry)
 if self:Combat() then return end
 local f=self.frames.NamePrompt
 if not f then
  f=N:Frame('NamePrompt',self:L('enterName'),360,150);f:SetFrameStrata('DIALOG')
  f.edit=N:Edit(f,18,-45,324);f.hint=N:Text(f,'',18,-113,324,true)
  f.ok=N:Button(f,self:L('apply'),18,-80,155,25,nil,true)
  N:Button(f,self:L('cancel'),187,-80,155,25,function()f:Hide()end)
  f.ok:SetScript('PostClick',function()
   if A:Combat() then return end
   local name=A:Trim(f.edit:GetText());if not A:ValidName(name)then A:Print(A:L('invalid'),true);return end
   if not f.entry.named and (not UnitIsPlayer('target') or UnitName('target')~=name)then A:Print(A:L('notFound'),true);return end
   A:ExecuteAction(f.entry,'RightButton',name);f:Hide()
  end)
  f.edit:SetScript('OnTextChanged',function(e)
   if A:Combat() then return end
   local name=A:Trim(e:GetText())
   if A:ValidName(name) and f.entry and not f.entry.named then
    f.ok:SetAttribute('type','macro');f.ok:SetAttribute('macrotext','/targetexact '..name)
   else f.ok:SetAttribute('type',nil)end
  end)
 end
 f.entry=entry;f.edit:SetText('');f.hint:SetText(entry.named and '' or self:L('notFound'));f:Show();f.edit:SetFocus()
end
function A:CreateUtilities()
 local f=N:Frame('Utilities',self:L('utilities'),1080,700);N:Menu(f)
 f.note=N:Text(f,self:L('selfOther'),22,-644,1030,true)
 f.page=1;f.cards={}
 for i=1,16 do
  local x=22+((i-1)%2)*522;local y=-55-math.floor((i-1)/2)*70
  local b=N:Card(f,'',134400,x,y,514,62,true);f.cards[i]=b
  A:SecureAction(b,function(button,mouse)A:ExecuteAction(button.entry,mouse)end,true)
 end
 function f:Refresh()
  for i,b in ipairs(self.cards)do
   b.entry=A.actions[(self.page-1)*16+i]
   if b.entry then
    b.requirePlayer=b.entry.playerRequired or b.entry.creature or b.entry.localMap
    b:SetAttribute('macrotext1',nil)
    if b.entry.creature then b:SetAttribute('type1','macro');b:SetAttribute('macrotext1','/cleartarget')
    elseif b.requirePlayer then b:SetAttribute('type1',nil)else b:SetAttribute('type1','target')end
    b:Show();local r=b.entry;b.icon:SetTexture(r.icon);b.label:SetText(A:L(r.key)..(r.toggle and ' ON/OFF' or ''))
    N:Hint(b,A:L(r.key),r.localMap and A:L('mapRevealHint')or r.picker and A:L(r.picker=='talents'and 'talentPickerHint'or 'utilityPickerHint')or r.maxSkills and A:L('maxSkillsHint')or r.command..'\n'..(r.creature and A:L('respawnHint')or r.self and A:L('selfOnly')or A:L('selfOther')))
   else b:Hide()end
  end
  self.pageText:SetText(self.page..' / '..math.ceil(#A.actions/16))
 end
 N:Button(f,'<',22,-669,70,22,function()if not A:Combat()then f.page=math.max(1,f.page-1);f:Refresh()end end)
 N:Button(f,'>',988,-669,70,22,function()if not A:Combat()then f.page=math.min(math.ceil(#A.actions/16),f.page+1);f:Refresh()end end)
 f.pageText=N:Text(f,'',470,-675,140,true);f.pageText:SetJustifyH('CENTER');f:Refresh()
 local d=N:Button(f,self:L('difficulty'),828,-22,150,23,function()A:Show('Difficulty')end)
end
function A:CreateDifficulty()
 local f=N:Frame('Difficulty',self:L('difficulty'),480,290)
 local specs={{'dungeon',1,'normal'},{'dungeon',2,'heroic'},{'dungeon',23,'mythic'},{'raid',14,'normal'},{'raid',15,'heroic'},{'raid',16,'mythic'}, {'legacy',3,'10 normal'},{'legacy',4,'25 normal'},{'legacy',5,'10 heroic'},{'legacy',6,'25 heroic'}}
 for i,r in ipairs(specs)do
  N:Button(f,self:L(r[1])..' · '..self:L(r[3]),18+((i-1)%2)*232,-50-math.floor((i-1)/2)*39,220,29,function()
   if A:Combat() then return end
   if r[1]=='dungeon' then SetDungeonDifficultyID(r[2]) elseif r[1]=='legacy' then SetLegacyRaidDifficultyID(r[2])else SetRaidDifficultyID(r[2])end
  end)
 end
end
function A:GoIsland()
 if self:Combat() then self:Print(self:L('combat'),true);return end
 self:Send('.go xyz 16222.1 16252.1 13.1872 1')
end
function A:CreateCommands()
 local f=N:Frame('Commands',self:L('commands'),1080,700);N:Menu(f)
 f.edit=N:Edit(f,20,-47,925,'.help')
 N:Button(f,self:L('run'),954,-47,104,25,function()A:Send(f.edit:GetText());f.edit:ClearFocus()end)
 f.edit:SetScript('OnEnterPressed',function(e)A:Send(e:GetText());e:ClearFocus()end)
 f.list=N:List(f,20,-90,510,560,39)
 local rows={};for _,r in ipairs(self.actions)do if r.command~=''then rows[#rows+1]=r end end
 for _,r in ipairs({{'questID','.lookup quest '},{'items','.lookup item '},{'spells','.lookup spell '},{'travel','.lookup tele '},{'professions','.lookup skill '},{'bank','.bank'},{'maxskill','.setskill '},{'learn','.learn '},{'expansion','.account set addon '},{'serverLookup','.help '}})do rows[#rows+1]={key=r[1],command=r[2],icon=134400}end
 f.list.render=function(b,r)b.title:SetText(A:L(r.key)..'  '..r.command);b.icon:SetTexture(r.icon)end
 f.list.onSelect=function(r)f.edit:SetText(r.command);f.edit:SetFocus()end;f.list:SetData(rows)
 f.reply=N:Text(f,self:L('serverReply'),550,-97,505,true)
 f.output=CreateFrame('ScrollingMessageFrame',nil,f);f.output:SetPoint('TOPLEFT',550,-127);f.output:SetSize(505,515);f.output:SetFontObject(ChatFontNormal);f.output:SetJustifyH('LEFT');f.output:SetFading(false);f.output:SetMaxLines(100)
 f.output:EnableMouseWheel(true);f.output:SetScript('OnMouseWheel',function(s,d)if d>0 then s:ScrollUp()else s:ScrollDown()end end)
 N:Text(f,self:L('unsupported'),20,-665,1010,true)
end
A:On('CHAT_MSG_SYSTEM',function(message)
 if A.frames.Commands and A.frames.Commands:IsShown()then
  for line in tostring(message):gmatch('[^\r\n]+')do A.frames.Commands.output:AddMessage(line)end
 end
 local audit=A.utilityAudit
 if audit and audit.current and #audit.current.responses<200 then audit.current.responses[#audit.current.responses+1]=tostring(message):sub(1,8192)end
 A:Emit('GMM_SERVER_REPLY',message)
end)
-- Read-only audit of this server's own command help. No gameplay commands run.
function A:AuditUtilityCommands()
 if self:Combat()then self:Print(self:L('combat'),true);return end
 local queries={'','cheat','character','modify','showarea','hidearea','explore','explorecheat','map','npc','npc map_activate','learn','learn all','learn all_myclass','maxskills','start'};local seen={}
 for _,query in ipairs(queries)do seen[query]=true end
 for _,entry in ipairs(self.actions)do
  local query=entry.command:gsub('^%.',''):gsub(' %-?%d+$','')
  if not seen[query]then queries[#queries+1]=query;seen[query]=true end
 end
 local audit={version=self.version,time=time(),queries={},index=0}
 self.utilityAudit=audit;GMMLegionDiagnostics.utilityAudit=audit
 local function nextQuery()
  if A.utilityAudit~=audit then return end
  if A:Combat()then A.utilityAudit=nil;audit.cancelled=true;return end
  audit.index=audit.index+1;local query=queries[audit.index]
  if not query then audit.complete=true;A.utilityAudit=nil;A:Print('Command help audit: '..#audit.queries);return end
  audit.current={query=query,responses={}};audit.queries[#audit.queries+1]=audit.current
  audit.sending=true;A:Send(query=='' and '.commands'or '.help '..query);audit.sending=false
  A:After(.8,nextQuery)
 end
 nextQuery()
end
A:On('GMM_COMMAND_SENT',function()
 local audit=A.utilityAudit;if audit and not audit.sending then audit.cancelled=true;A.utilityAudit=nil end
 if not A.sendingUtility then A.utilityRequest=nil end
end)

-- Optional map artwork overlay. Native exploration APIs and server flags stay
-- untouched. Reuse one texture pool and decode only the currently viewed map.
function A:UpdateMapReveal()
 local pool=self.mapRevealTextures or {};self.mapRevealTextures=pool
 for _,texture in ipairs(pool)do texture:Hide()end
 if not GMMLegionDB.mapReveal or not WorldMapDetailFrame or not WorldMapFrame or not WorldMapFrame:IsShown()then return end
 if GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel()>0 then return end
 local id=GetCurrentMapAreaID();local packed=self.data.mapFog and self.data.mapFog[id]
 if not packed then return end
 local mapName,rows=packed:match('^([^|]+)|(.+)$')
 if not mapName or not rows or GetMapInfo()~=mapName then return end
 local n=0;local visible=0
 for row in rows:gmatch('[^;]+')do
  local name,w,h,x,y=row:match('^([^,]+),(%d+),(%d+),(%-?%d+),(%-?%d+)$')
  w,h,x,y=tonumber(w),tonumber(h),tonumber(x),tonumber(y)
  if name and w and h and x and y then
   local columns=math.ceil(w/256);local height=math.ceil(h/256)
   for iy=0,height-1 do for ix=0,columns-1 do
    n=n+1;if n>512 then return end
    local texture=pool[n]
    if not texture then texture=WorldMapDetailFrame:CreateTexture(nil,'ARTWORK',nil,-1);pool[n]=texture end
    local widthPixels=math.min(256,w-ix*256);local heightPixels=math.min(256,h-iy*256)
    local fileWidth,fileHeight=16,16
    while fileWidth<widthPixels do fileWidth=fileWidth*2 end
    while fileHeight<heightPixels do fileHeight=fileHeight*2 end
    texture:ClearAllPoints();texture:SetPoint('TOPLEFT',WorldMapDetailFrame,'TOPLEFT',x+ix*256,-y-iy*256)
    texture:SetSize(widthPixels,heightPixels);texture:SetTexCoord(0,widthPixels/fileWidth,0,heightPixels/fileHeight)
    local loaded=texture:SetTexture('Interface\\WorldMap\\'..mapName..'\\'..name..(iy*columns+ix+1))
    if loaded~=false then texture:Show();visible=visible+1 end
   end end
  end
 end
 GMMLegionDiagnostics.mapReveal={mapID=id,tiles=visible,enabled=true,version=self.version,time=time(),serverExplorationChanged=false}
end
function A:SetMapReveal(enabled)
 if self:Combat()then self:Print(self:L('combat'),true);return end
 if not WorldMapDetailFrame or not GetCurrentMapAreaID or not GetMapInfo then self:Print(self:L('unavailable'),true);return end
 GMMLegionDB.mapReveal=enabled and true or false
 if enabled then
  if self.frames.Utilities then self.frames.Utilities:Hide()end
  if not WorldMapFrame:IsShown()then ToggleWorldMap()end
 end
 self:UpdateMapReveal()
 if not enabled then GMMLegionDiagnostics.mapReveal={enabled=false,time=time(),version=self.version,serverExplorationChanged=false}end
 self:Print(self:L(enabled and 'mapRevealOn'or 'mapRevealOff'))
end
local function queueMapReveal()
 if A.mapRevealQueued then return end
 A.mapRevealQueued=true;A:After(0,function()A.mapRevealQueued=nil;A:UpdateMapReveal()end)
end
A:On('WORLD_MAP_UPDATE',queueMapReveal)
A:On('PLAYER_LOGIN',function()
 if WorldMapFrame then WorldMapFrame:HookScript('OnShow',queueMapReveal)end
end)
