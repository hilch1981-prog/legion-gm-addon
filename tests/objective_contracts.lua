-- Behavioral regression checks: incomplete selection, actual kinds, loot sources,
-- delayed completion, catalogue disagreement and server-confirmed routing.
local A=GMMLegion735;local f=A.frames.Quests
local function check(ok,label)assert(ok,label);MOCK.passed=MOCK.passed+1 end
local escaped=false;for _,name in ipairs(UISpecialFrames)do if name==f:GetName()then escaped=true end end
check(not escaped,'secure quest helper is closed by guarded map hooks, not generic combat-unsafe Escape hiding')
MOCK:Drain();MOCK.combat=false;MOCK.dead=false
local oldPosition=UnitPosition
function UnitPosition()return 100,200,0,654 end
local function selectQuest(id,rows)
 MOCK.quests={{title='Quest',id=id}};MOCK.selection=1;MOCK.objectives=rows
 QuestMapFrame.DetailsFrame.questID=id;WorldMapFrame:Show();f:Show();f:Refresh();MOCK:ResetSent()
end
local function reply(guid,kind)
 MOCK:Fire('CHAT_MSG_SYSTEM',guid..' - |cffffffff|H'..kind..':'..guid..'|h[Destination X:102 Y:202 Z:35.556 MapId:654]|h|r')
end
local function count(pattern)local n=0;for _,r in ipairs(MOCK.sent)do if r[1]:match(pattern)then n=n+1 end end;return n end
local liveObject='47115 (Entry: 201775) - |cffffffff|Hgameobject:47115|h[Ball and Chain X:-1187.410034 Y:1057.869995 Z:36.531300 MapId:654]|h|r '
local parsed=A:ParseQuestSpawn(liveObject,'object')
check(parsed and parsed.y==1057.869995 and parsed.entry==201775 and parsed.guid=='47115','actual SPP Entry label cannot be misread as the Y coordinate')
selectQuest(24575,{{text='Prisoners freed: 0/5',kind='object',finished=false}})
f.find:Click();check(MOCK.sent[1][1]=='.list object 201775 50','Liberation Day resolves the shackles object, not an NPC/item ID')
check(not f.find:IsEnabled(),'lookup cannot be duplicated by repeat clicks')
MOCK:Fire('CHAT_MSG_SYSTEM',liveObject:gsub('Entry: 201775','Entry: 999999'))
check(#A.questTravel.rows==0,'unrelated object template reply is rejected')
reply('901','gameobject');MOCK:Drain()
check(count('^%.go object 901$')==1 and GMMLegionDiagnostics.questTravel.status=='arrived','object find uses returned spawn GUID and confirms XY arrival')
check(GMMLegionDiagnostics.questTravel.objective.id==266403,'travel evidence retains the selected objective ID')
selectQuest(14093,{{text='Worgen slain: 0/6',kind='monster',finished=false}})
f.find:Click();check(MOCK.sent[1][1]=='.list creature 34884 50','kill objective resolves the actual monster template')
reply('902','creature');MOCK:Drain();check(count('^%.go creature 902$')==1,'kill objective location routed to actual server spawn')
selectQuest(14098,{{text='Homes evacuated: 0/3',kind='monster',finished=false}})
f.find:Click();check(MOCK.sent[1][1]=='.list object 195327 50','scripted evacuation maps credit marker to the interactive door')
reply('903','gameobject');MOCK:Drain();check(count('^%.go object 903$')==1,'scripted interactable uses object route')
selectQuest(24575,{{text='Prisoners freed: 5/5',kind='object',finished=true}})
f.find:Click();check(#MOCK.sent==0 and f.note:GetText()==A:L('questObjectivesDone'),'completed objective gives feedback and sends no command')
selectQuest(24575,{{text='Unexpected item: 0/5',kind='item',finished=false}})
f.find:Click();check(#MOCK.sent==0 and f.note:GetText()==A:L('questObjectiveMismatch'),'mismatched server objective type is never guessed')
selectQuest(24575,{{text='First',kind='object'},{text='Second',kind='object'}})
f.find:Click();check(#MOCK.sent==0 and f.note:GetText()==A:L('questObjectiveMismatch'),'mismatched objective count blocks wrong ordinal mapping')
A.data.questObjectives[999996]='8001:0:34884:6:0;8002:2:201775:5:0'
selectQuest(999996,{{text='Done',kind='monster',finished=true},{text='Unfinished',kind='object',finished=false}})
f.find:Click();check(MOCK.sent[1][1]=='.list object 201775 50','completed condition is skipped automatically')
MOCK.objectives[2].finished=true;reply('904','gameobject');MOCK:Drain()
check(count('^%.go ')==0,'condition completed during lookup cancels stale teleport')
selectQuest(999996,{{text='Worgen',kind='monster',finished=false},{text='Prisoners',kind='object',finished=false}})
f.find:Click();check(#MOCK.sent==0 and A.frames.QuestObjectives:IsShown()and #A.frames.QuestObjectives.list.data==2,'multiple unfinished objectives require explicit selection')
A.frames.QuestObjectives.list.onSelect(A.frames.QuestObjectives.list.data[2])
check(MOCK.sent[1][1]=='.list object 201775 50','chosen second objective drives lookup')
A:CancelQuestTravel();MOCK:Drain()
local sources=A:QuestObjectiveEntries({id=0,kind=1,object=723})
check(#sources==6 and sources[1]==157,'quest item resolves its loot sources, not item ID as a creature')
for _,entry in ipairs(sources)do check(entry~=723,'item ID is not used as a creature ID')end
A.data.questObjectives[999995]='8003:1:723:1:0'
selectQuest(999995,{{text='Liver: 0/1',kind='item',finished=false}});f.find:Click()
check(MOCK.sent[1][1]=='.list creature 157 50','item source query uses creature_template loot mapping')
reply('905','creature');MOCK:Drain();check(count('^%.go creature 905$')==1,'missing alternate item sources do not discard a verified source')
A.data.questObjectives[999994]='8004:8:0:100:0'
selectQuest(999994,{{text='Money',kind='money',finished=false}});f.find:Click()
check(#MOCK.sent==0 and f.note:GetText():find(A:L('questObjectiveMissing'),1,true),'nonspatial objective has an explicit no-location explanation')
A.data.questObjectives[999993]='8005:1:999999:1:0';A.data.questItemSources[999999]='1,2,3,4,5,6,7,8,9'
selectQuest(999993,{{text='Item',kind='item',finished=false}});f.find:Click()
check(#MOCK.sent==0 and #A.frames.QuestObjectives.list.data==9,'many sources use a paged selection instead of flooding GM commands')
QuestMapFrame.DetailsFrame.questID=24575;A.frames.QuestObjectives.list.onSelect(A.frames.QuestObjectives.list.data[1])
check(#MOCK.sent==0 and not A.frames.QuestObjectives:IsShown(),'quest change invalidates source picker')
selectQuest(24575,{{text='Prisoners',kind='object',finished=false}});f.find:Click();MOCK:Drain()
check(count('^%.go ')==0 and not A.questTravel,'missing spawn never falls back to unsafe go quest/POI coordinates')
check(count('^%.quest complete')==0,'finding objectives never completes quests')
selectQuest(14093,{{text='Worgen',kind='monster',finished=false}});f.find:Click()
MOCK:Fire('CHAT_MSG_SYSTEM','902 - |cffffffff|Hcreature:902|h[Worgen X:150 Y:250 Z:35.5 MapId:654]|h|r')
A:FinishQuestLookup(A.questTravel);UnitPosition=function()return 160,260,0,654 end;MOCK:Drain()
check(GMMLegionDiagnostics.questTravel.status=='nearby','moved landing near an NPC is distinguished from exact spawn arrival')
function UnitPosition()return 160,260,0,654 end
selectQuest(14093,{{text='Worgen',kind='monster',finished=false}});f.find:Click()
MOCK:Fire('CHAT_MSG_SYSTEM','902 - |cffffffff|Hcreature:902|h[Worgen X:150 Y:250 Z:35.5 MapId:654]|h|r');A:FinishQuestLookup(A.questTravel);MOCK:Drain()
check(GMMLegionDiagnostics.questTravel.status=='unconfirmed','unchanged position near a spawn does not confirm a failed teleport')
f.note:SetText(A:L('questArrived'));MOCK:Fire('PLAYER_REGEN_DISABLED')
check(f.note:GetText()==A:L('questArrived'),'later combat does not overwrite a completed trip with a false cancellation')
WorldMapFrame:Hide();MOCK.objectives=nil;UnitPosition=oldPosition;MOCK:Drain()
check(#GMMLegionDiagnostics.errors==0,table.concat(GMMLegionDiagnostics.errors,'\n'))
