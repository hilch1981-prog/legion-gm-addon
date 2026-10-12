-- Server-reply simulation checks routing, cancellation and party safeguards.
local A=GMMLegion735;local f=A.frames.Quests
local function check(ok,label)assert(ok,label);MOCK.passed=MOCK.passed+1 end
MOCK:Drain();MOCK.combat=false;MOCK.dead=false
local oldPosition=UnitPosition;local pos={100,200,300,654}
function UnitPosition()return unpack(pos)end
local function selectQuest(id)
 MOCK.quests={{title='Quest',id=id}};MOCK.selection=1;QuestMapFrame.DetailsFrame.questID=id
 WorldMapFrame:Show();f:Show();f:Refresh();MOCK:ResetSent()
end
local function row(guid,x,y,z,map,kind,name)
 return string.format('%s - |cffffffff|H%s:%s|h[%s X:%f Y:%f Z:%f MapId:%d]|h|r',guid,kind or 'creature',guid,name or 'NPC',x,y,z,map)
end
local function countCommand(pattern)
 local n=0;for _,r in ipairs(MOCK.sent)do if r[1]:match(pattern)then n=n+1 end end;return n
end
local g=A:QuestGivers(14098,'start');check(g[1]==34913 and g[2]==35830,'Legion source links both valid starter entries')
check(A:QuestGivers(14078,'start')[1]==34850 and A:QuestGivers(14078,'finish')[2]==34863,'start and end relations remain distinct')
selectQuest(14098);check(f.start:IsEnabled()and f.finish:IsEnabled(),'real quest enables both location buttons')
check(f.find:IsEnabled(),'objective finder is available for selected quests')
local parsed=A:ParseQuestSpawn(row('149782',-1437,1401.339966,35.556,654),'creature')
check(parsed and parsed.guid=='149782'and parsed.z==35.556 and parsed.map==654,'SPP hyperlink and signed XYZ parser')
check(not A:ParseQuestSpawn('NPC X:1 Y:2 Z:3 MapId:0','creature'),'plain chat cannot supply a teleport GUID')
check(not A:ParseQuestSpawn(row('1',50000,0,0,0),'creature'),'invalid coordinate bounds rejected')
check(not A:ParseQuestSpawn(row('1',1,2,3,0,'gameobject'),'creature'),'unrelated object reply cannot satisfy creature query')
f.finish:Click();check(MOCK.sent[1][1]=='.list creature 34913 50'and not f.finish:IsEnabled(),'click queries live spawns before teleport and blocks duplicate clicks')
MOCK:Fire('CHAT_MSG_SYSTEM',row('900',101,201,300,1))
MOCK:Fire('CHAT_MSG_SYSTEM',row('149782',102,202,300,654))
MOCK:Fire('CHAT_MSG_SYSTEM','Found creatures 34913: 2');MOCK:Drain()
check(countCommand('^%.go creature 149782$')==1 and countCommand('^%.go ')==1,'same-map spawn wins over numerically closer foreign-map coordinates')
check(GMMLegionDiagnostics.questTravel.status=='arrived','arrival validated against destination coordinates')
check(f.finish:IsEnabled(),'location buttons recover after arrival')
pos={100,200,0,654};selectQuest(14098);f.finish:Click()
MOCK:Fire('CHAT_MSG_SYSTEM',row('149782',102,202,35.556,654));MOCK:Fire('CHAT_MSG_SYSTEM','Found creatures 34913: 1');MOCK:Drain()
check(GMMLegionDiagnostics.questTravel.status=='arrived','Legion zero placeholder Z does not reject actual arrival')
pos={100,200,300,654}
selectQuest(14098);f.start:Click();local first=A.questTravel
MOCK:Fire('CHAT_MSG_SYSTEM',row('100',800,800,300,654));MOCK:Fire('CHAT_MSG_SYSTEM','Found creatures 34913: 1')
MOCK:Drain()
check(countCommand('^%.list creature 35830 50$')==1 and countCommand('^%.go creature 100$')==1,'all starter entries queried; missing alternate spawn does not block valid result')
selectQuest(14098);f.finish:Click();MOCK:Drain()
check(countCommand('^%.go ')==0 and not A.questTravel,'missing/denied server rows never fall back to guessed coordinates')
selectQuest(14098);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('11',102,202,300,654));QuestMapFrame.DetailsFrame.questID=14078;MOCK:Drain()
check(countCommand('^%.go ')==0,'changing quests cancels delayed teleport')
selectQuest(14098);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('11',102,202,300,654));A:Send('.save');MOCK:Drain()
check(countCommand('^%.go ')==0,'another GM command cancels pending travel')
selectQuest(14098);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('11',102,202,300,654));WorldMapFrame:Hide();MOCK:Drain()
check(countCommand('^%.go ')==0,'closing map cancels pending lookup')
selectQuest(14098);f.finish:Click();MOCK.combat=true;MOCK:Fire('PLAYER_REGEN_DISABLED');MOCK:Drain()
check(countCommand('^%.go ')==0,'combat cancels pending lookup');MOCK.combat=false
selectQuest(14098);f.finish:Click();pos={500,200,300,654};MOCK:Drain()
check(countCommand('^%.go ')==0,'manual movement invalidates stale lookup origin');pos={100,200,300,654}
selectQuest(14098);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('1',100,200,300,0));MOCK:Fire('CHAT_MSG_SYSTEM',row('2',100,200,300,1));MOCK:Fire('CHAT_MSG_SYSTEM','Found creatures 34913: 2');MOCK:Drain()
check(countCommand('^%.go ')==0 and A.frames.QuestDestinations:IsShown(),'ambiguous destinations on other maps require a destination selection')
A.frames.QuestDestinations:Hide();check(not A.questTravel,'dismissing destination picker cancels lookup')
A.data.questGivers[999998]='-12345;-12345';selectQuest(999998);f.start:Click()
check(MOCK.sent[1][1]=='.list object 12345 50','gameobject relation uses object lookup')
MOCK:Fire('CHAT_MSG_SYSTEM',row('300',102,202,300,654,'gameobject','Notice board'));MOCK:Drain()
check(countCommand('^%.go object 300$')==1,'gameobject uses server spawn GUID, never creature entry or guessed Z')
local oldParty=A.QuestParty;local oldGuid=UnitGUID;local oldConnected=UnitIsConnected
A.QuestParty=function()return {{unit='party1',name='Friend',guid='Player-friend'}}end
UnitGUID=function(unit)if unit=='party1'then return 'Player-friend'end;return oldGuid(unit)end
UnitIsConnected=function(unit)if unit=='party1'then return true end;return oldConnected(unit)end
selectQuest(14098);f.party:SetChecked(true);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('100',102,202,300,654));MOCK:Drain()
check(countCommand('^%.summon Friend$')==1,'party receives end-location summon only after confirmed arrival')
selectQuest(14098);f.start:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('100',102,202,300,654));MOCK:Drain()
check(countCommand('^%.summon Friend$')==1,'party checkbox also applies to start-location travel')
selectQuest(14098);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('100',800,800,300,654));MOCK:Drain()
check(countCommand('^%.summon ')==0 and GMMLegionDiagnostics.questTravel.status=='unconfirmed','failed arrival never summons the party')
selectQuest(14098);f.finish:Click();MOCK:Fire('CHAT_MSG_SYSTEM',row('100',102,202,300,654));UnitGUID=function()return 'Player-replacement'end;MOCK:Drain()
check(countCommand('^%.summon ')==0,'replaced party member never receives stale summon')
A.QuestParty=oldParty;UnitGUID=oldGuid;UnitIsConnected=oldConnected;UnitPosition=oldPosition
f.party:SetChecked(false);WorldMapFrame:Hide();MOCK:Drain()
check(#GMMLegionDiagnostics.errors==0,table.concat(GMMLegionDiagnostics.errors,'\n'))
