local A=GMMLegion735;local N=A.UI
function A:CurrentQuest()
 local id=QuestMapFrame and QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.questID
 if not id then local index=GetQuestLogSelection();if index and index>0 then id=select(8,GetQuestLogTitle(index))end end
 if not id or id<=0 then return end
 local index=GetQuestLogIndexByID(id);local title=index and index>0 and GetQuestLogTitle(index)or ''
 return id,index,title
end
function A:QuestParty()
 local members={};if IsInRaid()then return members end
 local id,index=self:CurrentQuest()
 for i=1,4 do
  local unit='party'..i
  local same=id and (IsUnitOnQuestByQuestID and IsUnitOnQuestByQuestID(id,unit)or not IsUnitOnQuestByQuestID and IsUnitOnQuest and index and IsUnitOnQuest(index,unit))
  if UnitExists(unit)and UnitIsConnected(unit)and same then
   members[#members+1]={unit=unit,name=UnitName(unit),guid=UnitGUID(unit)}
  end
 end
 return members
end
-- Resolve the giver against the running server instead of using a quest POI's
-- terrain height or the first arbitrary spawn of an NPC template.
function A:QuestGivers(id,side)
 local raw=self.data.questGivers and self.data.questGivers[id]
 local out={};if not raw then return out end
 local start,finish=raw:match('^(.-);(.-)$')
 for value in (side=='start'and start or finish or ''):gmatch('%-?%d+')do out[#out+1]=tonumber(value)end
 return out
end
-- Decode only the selected quest; the catalogue remains compact strings.
function A:QuestObjectiveDefinitions(id)
 if self.objectiveCache and self.objectiveCache.id==id then return self.objectiveCache.rows end
 local rows={};local raw=self.data.questObjectives and self.data.questObjectives[id]
 for value in (raw or ''):gmatch('[^;]+')do
  local oid,kind,object,amount,flags=value:match('^(%d+):(%d+):(%-?%d+):(%-?%d+):(%d+)$')
  if oid then
   flags=tonumber(flags)
   -- Hidden/progress-bar components do not have matching visible leaderboard rows.
   if bit.band(flags,72)==0 then rows[#rows+1]={id=tonumber(oid),kind=tonumber(kind),object=tonumber(object),amount=tonumber(amount),flags=flags}end
  end
 end
 self.objectiveCache={id=id,rows=rows};return rows
end
function A:QuestObjectiveState(id)
 local index=id and GetQuestLogIndexByID(id)
 local definitions=self:QuestObjectiveDefinitions(id);local rows={}
 if not index or index<=0 or #definitions==0 then return rows,'questObjectiveMissing' end
 local count=GetNumQuestLeaderBoards(index)
 -- Public SPP forks can differ. Never associate a different live objective by guesswork.
 if count~=#definitions then return rows,'questObjectiveMismatch' end
 for i,definition in ipairs(definitions)do
  local text,kind,finished=GetQuestLogLeaderBoard(i,index)
  if not text or text=='' or (definition.kind==1 and kind~='item')or (definition.kind==2 and kind~='object')then return {},'questObjectiveMismatch' end
  rows[#rows+1]={id=definition.id,kind=definition.kind,object=definition.object,amount=definition.amount,flags=definition.flags,text=text,finished=finished and true or false}
 end
 return rows
end
function A:QuestObjectiveEntries(row)
 local raw=self.data.questObjectiveOverrides and self.data.questObjectiveOverrides[row.id]
 if not raw then
  if row.kind==0 or row.kind==3 then raw=self.data.questKillCredits[row.object]or tostring(row.object)
  elseif row.kind==2 then raw=tostring(-row.object)
  elseif row.kind==1 then raw=self.data.questItemSources[row.object]end
 end
 local entries={};local seen={}
 for value in (raw or ''):gmatch('%-?%d+')do local entry=tonumber(value);if entry~=0 and not seen[entry]then entries[#entries+1]=entry;seen[entry]=true end end
 return entries
end
function A:ChooseQuestObjective(rows,isSource,callback)
 local f=self.frames.QuestObjectives
 if not f then
  f=N:Frame('QuestObjectives',self:L('questChooseObjective'),450,320);f:SetFrameStrata('DIALOG')
  f.list=N:List(f,12,-44,426,254,43)
  f.list.render=function(b,r)b.icon:Hide();b.title:ClearAllPoints();b.title:SetPoint('LEFT',8,0);b.title:SetWidth(393);b.title:SetText(r.text)end
  f.list.onSelect=function(row)
   if A:Combat()or A:CurrentQuest()~=f.quest then A:CancelQuestTravel('questTravelCancelled');return end
   local action=f.action;A.questChoice=nil;f:Hide();action(row)
  end
  f:HookScript('OnHide',function()if A.questChoice==f then A.questChoice=nil end end)
 end
 f.quest=self:CurrentQuest();f.action=callback;self.questChoice=f
 f.list:SetData(rows);f:Show();N:BringToFront(f)
 self:QuestTravelNote(isSource and 'questChooseSource'or 'questChooseObjective')
end
function A:StartObjectiveTravel(row,chosenEntry)
 local id=self:CurrentQuest();local live,reason=self:QuestObjectiveState(id);local current
 for _,r in ipairs(live)do if r.id==row.id and not r.finished then current=r end end
 if not current then self:QuestTravelNote(reason or 'questObjectivesDone');return end
 local entries=self:QuestObjectiveEntries(current)
 if chosenEntry then
  local valid=false;for _,entry in ipairs(entries)do if entry==chosenEntry then valid=true end end
  if not valid then return end;entries={chosenEntry}
 end
 if #entries==0 then self:QuestTravelNote('questObjectiveMissing',current.text);return end
 if #entries>8 then
  local sources={};for _,entry in ipairs(entries)do sources[#sources+1]={entry=entry,text=(self.data.questSourceNames[entry]or self:L(entry>0 and 'questCreature'or 'questObject'))..' · '..math.abs(entry)}end
  table.sort(sources,function(a,b)return a.text<b.text end)
  self:ChooseQuestObjective(sources,true,function(source)A:StartObjectiveTravel(current,source.entry)end);return
 end
 self:StartQuestTravel('objective',entries,current)
end
function A:FindQuestObjective()
 GameTooltip:Hide()
 if self:Combat()then self:Print(self:L('combat'),true);return end
 local id=self:CurrentQuest();if not id then self:Print(self:L('questMissing'),true);return end
 self:CancelQuestTravel();self.questArrival=nil
 local rows,reason=self:QuestObjectiveState(id);local pending={}
 GMMLegionDiagnostics.questObjectives={id=id,rows=rows,reason=reason,time=time()}
 if reason then self:QuestTravelNote(reason);return end
 for _,row in ipairs(rows)do if not row.finished then pending[#pending+1]=row end end
 if #pending==0 then self:QuestTravelNote('questObjectivesDone')
 elseif #pending==1 then self:StartObjectiveTravel(pending[1])
 else self:ChooseQuestObjective(pending,false,function(row)A:StartObjectiveTravel(row)end)end
end
function A:QuestTravelNote(key,name)
 local f=self.frames.Quests;if f then f.note:SetText(self:L(key)..(name and '\n'..name or ''))end
end
function A:CancelQuestTravel(key)
 self.questTravel=nil
 self.questChoice=nil;local choice=self.frames.QuestObjectives;if choice then choice:Hide()end
 local picker=self.frames.QuestDestinations;if picker then picker:Hide()end
 if key then self:QuestTravelNote(key)end
 local f=self.frames.Quests;if f and not self:Combat()then f:RefreshButtons()end
end
function A:QuestTravelValid(job)
 if self.questTravel~=job then return false end
 local x,y,z,map=UnitPosition('player')
 if self:Combat()or UnitIsDeadOrGhost('player')or self:CurrentQuest()~=job.id or not x or
  map~=job.before[4]or (x-job.before[1])^2+(y-job.before[2])^2>225 then
  self:CancelQuestTravel('questTravelCancelled');return false
 end
 if job.objective then
  local rows,reason=self:QuestObjectiveState(job.id);local pending=false
  for _,row in ipairs(rows)do if row.id==job.objective.id and not row.finished then pending=true end end
  if reason or not pending then self:CancelQuestTravel(reason or 'questObjectivesDone');return false end
 end
 return true
end
function A:ParseQuestSpawn(message,kind)
 if type(message)~='string'then return end
 local link=kind=='creature'and 'creature'or 'gameobject'
 local guid=message:match('|H'..link..':(%d+)')
 if not guid then return end
 -- A bare [Yy]: also matches the last two characters of "Entry:" in SPP's
 -- object rows, mistaking a template ID for Y. Require a label boundary.
 local x=tonumber(message:match('%f[%a][Xx]:%s*([%+%-%.%deE]+)'))
 local y=tonumber(message:match('%f[%a][Yy]:%s*([%+%-%.%deE]+)'))
 local z=tonumber(message:match('%f[%a][Zz]:%s*([%+%-%.%deE]+)'))
 -- Server-string language is independent of the addon/client UI language.
 -- Korean SPP translations use 지도 for MapId and 입장 for Entry.
 local map=tonumber(message:lower():match('%f[%a]mapid%s*:%s*(%d+)')or message:match('지도%s*:%s*(%d+)'))
 if not x or not y or not z or not map or math.abs(x)>17067 or math.abs(y)>17067 or math.abs(z)>20000 or tonumber(guid)==0 then return end
 local name=message:match('|h%[(.-)%s+[Xx]:')or message:match('|h%[(.-)%]')or (kind..' '..guid)
 local entry=tonumber(message:lower():match('%(entry%s*:%s*(%d+)%)')or message:match('%(입장%)?%s*:%s*(%d+)%)'))
 return {kind=kind,guid=guid,x=x,y=y,z=z,map=map,name=name,entry=entry}
end
function A:FinishQuestLookup(job)
 if not self:QuestTravelValid(job)then return end
 table.sort(job.rows,function(a,b)
  local am,bm=a.map==job.before[4],b.map==job.before[4]
  if am~=bm then return am end
  local da=(a.x-job.before[1])^2+(a.y-job.before[2])^2
  local db=(b.x-job.before[1])^2+(b.y-job.before[2])^2
  if da~=db then return da<db end
  return a.kind..a.guid<b.kind..b.guid
 end)
 local first=job.rows[1]
 if not first then self:CancelQuestTravel('questSpawnMissing');return end
 if first.map==job.before[4]or #job.rows==1 then self:GoQuestSpawn(job,first);return end
 -- Do not guess between several destinations on other maps.
 local f=self.frames.QuestDestinations
 if not f then
  f=N:Frame('QuestDestinations',self:L('questChooseDestination'),420,306);f:SetFrameStrata('DIALOG')
  f.list=N:List(f,12,-44,396,242,38)
  f.list.render=function(b,r)b.icon:Hide();b.title:ClearAllPoints();b.title:SetPoint('LEFT',8,0);b.title:SetWidth(363);b.title:SetText(r.name..' · Map '..r.map)end
  f.list.onSelect=function(r)if f.job then A:GoQuestSpawn(f.job,r)end end
  f:HookScript('OnHide',function()if A.questTravel and A.questTravel==f.job then A:CancelQuestTravel('questTravelCancelled')end end)
 end
 f.job=job;f.list:SetData(job.rows);f:Show();N:BringToFront(f);self:QuestTravelNote('questChooseDestination')
end
function A:GoQuestSpawn(job,row)
 if not self:QuestTravelValid(job)then return end
 self.questTravel=nil
 local picker=self.frames.QuestDestinations;if picker then picker:Hide()end
 local command='.go '..row.kind..' '..row.guid
 if not self:Send(command)then self:CancelQuestTravel('questSpawnMissing');return end
 self:QuestTravelNote('questTravelling',row.name)
 local f=self.frames.Quests;if f then f:RefreshButtons()end
 local check={id=job.id,side=job.side,objective=job.objective,spawn=row,before=job.before,command=command,status='sent',time=time()}
 self.questArrival=check;GMMLegionDiagnostics.questTravel=check
 local history=GMMLegionDiagnostics.questTravelHistory or {};GMMLegionDiagnostics.questTravelHistory=history
 history[#history+1]=check;if #history>12 then table.remove(history,1)end
 local attempts=0
 local function verify()
  if A.questArrival~=check then return end
  local x,y,z,map=UnitPosition('player');attempts=attempts+1
  check.observed={x,y,z,map}
  -- Legion 26972 reports zero for UnitPosition's Z component. Server spawn
  -- height is used by .go; the client can confirm the map and horizontal position.
  local distance=x and map==row.map and (x-row.x)^2+(y-row.y)^2
  local moved=x and (map~=job.before[4]or (x-job.before[1])^2+(y-job.before[2])^2>36)
  -- SPP can land beside a creature rather than exactly on its database spawn.
  -- Report that separately; a failed command with no movement cannot pass it.
  local nearby=distance and row.kind=='creature'and moved and distance<=225
  if distance and (distance<=36 or nearby)then
   check.status=distance<=36 and 'arrived'or 'nearby';check.after={x,y,z,map};check.distance=math.sqrt(distance)
   A.questArrival=nil;A:QuestTravelNote(check.status=='arrived'and 'questArrived'or 'questArrivedNearby',row.name)
   for _,m in ipairs(job.members)do
    if not A:Combat()and UnitGUID(m.unit)==m.guid and UnitIsConnected(m.unit)and A:ValidName(m.name)then A:Send('.summon '..m.name)end
   end
  elseif attempts<35 then A:After(.2,verify)
  else check.status='unconfirmed';A.questArrival=nil;A:QuestTravelNote('questArrivalUnknown')end
 end
 self:After(.2,verify)
end
function A:NextQuestLookup(job)
 if not self:QuestTravelValid(job)then return end
 job.index=job.index+1
 local entry=job.givers[job.index]
 if not entry then self:FinishQuestLookup(job);return end
 local query={entry=math.abs(entry),kind=entry>0 and 'creature'or 'object',rows=0}
 GMMLegionDiagnostics.questLookup={kind=query.kind,entry=query.entry,samples={}}
 job.query=query
 job.sending=true;local sent=self:Send('.list '..query.kind..' '..query.entry..' 50');job.sending=false
 if not sent then self:CancelQuestTravel('questSpawnMissing');return end
 -- A timeout is bounded and never invents a destination when no rows arrive.
 self:After(2.5,function()if A.questTravel==job and job.query==query then job.query=nil;A:NextQuestLookup(job)end end)
end
function A:StartQuestTravel(side,entries,objective)
 GameTooltip:Hide()
 if self:Combat()then self:Print(self:L('combat'),true);return end
 local id=self:CurrentQuest();if not id then self:Print(self:L('questMissing'),true);return end
 local givers=entries or self:QuestGivers(id,side);local before={UnitPosition('player')}
 if #givers==0 or not before[1]or UnitIsDeadOrGhost('player')then self:QuestTravelNote('locationUnknown');return end
 self:CancelQuestTravel();self.questArrival=nil
 local f=self.frames.Quests
 local job={id=id,side=side,objective=objective,before=before,givers=givers,index=0,rows={},seen={},members=f and f.party:GetChecked()and self:QuestParty()or {}}
 self.questTravel=job;self:QuestTravelNote('questFinding');if f then f:RefreshButtons()end
 self:NextQuestLookup(job)
end
A:On('CHAT_MSG_SYSTEM',function(message)
 local job=A.questTravel;local q=job and job.query
 if not q or not A:QuestTravelValid(job)then return end
 local sample=GMMLegionDiagnostics.questLookup
 if sample and #sample.samples<2 then sample.samples[#sample.samples+1]=message end
 local row=A:ParseQuestSpawn(message,q.kind)
 if row and (not row.entry or row.entry==q.entry)then
  local key=row.kind..row.guid
  if not job.seen[key]then job.seen[key]=true;row.entry=q.entry;job.rows[#job.rows+1]=row;q.rows=q.rows+1 end
 end
 -- SPP installations can translate server strings even on the same client.
 -- Match the query kind and entry; unrecognized terminators retain the timeout.
 local found
 if q.kind=='creature'then
  found=message:match('Found creatures%s+(%d+):')or message:match('발견된 생물%s+(%d+):')
 else
  found=message:match('Found gameobjects%s+(%d+):')or message:match('게임물들을 찾았다%s+(%d+):')
 end
 if tonumber(found)==q.entry then
  job.query=nil;A:After(.15,function()if A.questTravel==job then A:NextQuestLookup(job)end end)
 end
end)
A:On('GMM_COMMAND_SENT',function()
 A.questArrival=nil
 if A.questChoice then A:CancelQuestTravel('questTravelCancelled')end
 local job=A.questTravel;if job and not job.sending then A:CancelQuestTravel('questTravelCancelled')end
end)
A:On('PLAYER_REGEN_DISABLED',function()
 if A.questTravel or A.questChoice then A:CancelQuestTravel('questTravelCancelled')end
 A.questArrival=nil
end)
function A:CreateQuests()
 if not QuestMapFrame and ToggleQuestLog then ToggleQuestLog()end
 local f=N:Frame('Quests',self:L('quests'),334,195);f:SetFrameStrata('DIALOG');f.party=N:Check(f,self:L('party'),164,-42,function()f:Refresh()end)
 f.questTitle=N:Text(f,'',15,-35,145,true)
 f.find=N:Button(f,self:L('find'),15,-74,147,26,function()A:FindQuestObjective()end)
 N:Hint(f.find,self:L('find'),self:L('questObjectiveHint'))
 f.complete=N:Button(f,self:L('complete'),173,-74,146,26,nil,true);f.complete:RegisterForClicks('LeftButtonUp');f.complete:SetAttribute('type','macro')
 f.complete:SetScript('PostClick',function()if not A:Combat()then f.note:SetText(A:L('pending'))end end)
 f.start=N:Button(f,self:L('start'),15,-107,147,26,function()A:StartQuestTravel('start')end)
 f.finish=N:Button(f,self:L('finish'),173,-107,146,26,function()A:StartQuestTravel('finish')end)
 N:Hint(f.start,self:L('start'),self:L('questLocationHint'));N:Hint(f.finish,self:L('finish'),self:L('questLocationHint'))
 f.note=N:Text(f,'',15,-148,300,true);f.note:SetHeight(38)
 function f:RefreshButtons()
  if A:Combat()then return end
  local id=A:CurrentQuest()
  if id and not A.questTravel then self.find:Enable()else self.find:Disable()end
  if not A.questTravel and #A:QuestGivers(id,'start')>0 then self.start:Enable()else self.start:Disable()end
  if not A.questTravel and #A:QuestGivers(id,'finish')>0 then self.finish:Enable()else self.finish:Disable()end
 end
 function f:Refresh()
  if A:Combat()then return end
  local id,_,title=A:CurrentQuest();self.questTitle:SetText(id and (title..' · '..id)or A:L('questMissing'))
  if id then
   local macro={'/stopmacro [combat]','/target [@player]','/say .quest complete '..id}
   if self.party:GetChecked()then
    for _,member in ipairs(A:QuestParty())do macro[#macro+1]='/target [@'..member.unit..']';macro[#macro+1]='/say .quest complete '..id end
   end
   macro[#macro+1]='/target [@player]';self.complete:SetAttribute('macrotext',table.concat(macro,'\n'))
  else self.complete:SetAttribute('macrotext','')end
  A:SetSecureEnabled(self.complete,id~=nil)
  if A.questTravel and A.questTravel.id~=id then A:CancelQuestTravel('questTravelCancelled')end
  if A.questChoice and A.questChoice.quest~=id then A:CancelQuestTravel('questTravelCancelled')end
  self:RefreshButtons()
  if self.lastQuest~=id then self.lastQuest=id;self.note:SetText(#A:QuestGivers(id,'start')+#A:QuestGivers(id,'finish')>0 and A:L('questLocationHint')or A:L('locationUnknown'))end
  self:Dock()
 end
 function f:Dock()
  if A:Combat()or not WorldMapFrame or not WorldMapFrame:IsShown()then return end
  local left,bottom=WorldMapFrame:GetLeft(),WorldMapFrame:GetBottom();if not left or not bottom then return end
  local ratio=WorldMapFrame:GetEffectiveScale()/UIParent:GetEffectiveScale()
  local right=(left+WorldMapFrame:GetWidth())*ratio;local y=bottom*ratio
  N:FitFrame(self);self:ClearAllPoints()
  local width,height=self:GetWidth()*self:GetScale(),self:GetHeight()*self:GetScale()
  if right-4+width<=UIParent:GetWidth()then
   self:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',(right-4)/self:GetScale(),y/self:GetScale())
  elseif y>=height+8 then
   self:SetPoint('TOPRIGHT',UIParent,'BOTTOMLEFT',right/self:GetScale(),(y+4)/self:GetScale())
  else
   -- The small Legion map can occupy almost the whole screen. Keep the title,
   -- party checkbox and actions visible above its lower-right corner.
   self:SetPoint('BOTTOMRIGHT',UIParent,'BOTTOMLEFT',math.min(UIParent:GetWidth()-4,right-4)/self:GetScale(),math.max(4,y+4)/self:GetScale())
  end
 end
 f:EnableMouse(true);f:SetScript('OnEnter',function()f:Refresh()end)
 f:HookScript('OnHide',function()A:CancelQuestTravel()end)
 if QuestMapFrame_ShowQuestDetails then hooksecurefunc('QuestMapFrame_ShowQuestDetails',function()if f:IsShown()then f:Refresh()end end)end
 f:Refresh()
end
function A:UpdateQuestCompanion()
 if self:Combat()then return end
 local f=self.frames.Quests
 if GMMLegionDB.questCompanion and WorldMapFrame and WorldMapFrame:IsShown()then
  if not f then self:CreateQuests();f=self.frames.Quests end
  f:Show();f:Refresh()
 elseif f then f:Hide()end
end
function A:InstallQuestCompanion()
 if self.questCompanionHooked or not WorldMapFrame then return end
 self.questCompanionHooked=true
 WorldMapFrame:HookScript('OnShow',function()A:UpdateQuestCompanion()end)
 WorldMapFrame:HookScript('OnHide',function()A:UpdateQuestCompanion()end)
 self:UpdateQuestCompanion()
end
A:On('PLAYER_LOGIN',function()A:InstallQuestCompanion()end)
A:On('ADDON_LOADED',function()if A.ready then A:InstallQuestCompanion()end end)
A:On('PLAYER_REGEN_ENABLED',function()A:UpdateQuestCompanion()end)
for _,event in ipairs({'QUEST_LOG_UPDATE','QUEST_ACCEPTED','QUEST_REMOVED','PLAYER_REGEN_ENABLED'})do
 A:On(event,function()local f=A.frames.Quests;if f and f:IsShown()then f:Refresh()end end)
end
