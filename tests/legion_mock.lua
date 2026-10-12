-- Legion API and secure-click model. This is not a client, renderer or server.
local methods=getmetatable(UIParent).__index
MOCK.cvars={autoLootDefault='0'};MOCK.stateDrivers={}
function GetCVar(key)return MOCK.cvars[key]end
function SetCVar(key,value)MOCK.cvars[key]=tostring(value);MOCK:Fire('CVAR_UPDATE',key,tostring(value))end
function RegisterStateDriver(frame,key,value)assert(not MOCK.combat);MOCK.stateDrivers[frame]=value end
function UnregisterStateDriver(frame,key)assert(not MOCK.combat);MOCK.stateDrivers[frame]=nil end
function ToggleAllBags()MOCK.nativeBagsToggled=(MOCK.nativeBagsToggled or 0)+1 end
function methods:GetParent()return self.parent or self.owner end
MOCK.timers={};MOCK.clock=0;MOCK.known={};MOCK.skills={};MOCK.used={};MOCK.messages={}
MOCK.dungeon=1;MOCK.raid=14;MOCK.legacy=3;MOCK.target='TestGM';MOCK.targetIsPlayer=true
local function run(frame,event,...)
 if frame.scripts[event]then frame.scripts[event](frame,...)end
 for _,fn in ipairs(frame.hooks[event]or {})do fn(frame,...)end
end
function MOCK:Drain()
 local n=0
 while #self.timers>0 do
  table.sort(self.timers,function(a,b)return a.at<b.at end)
  local t=table.remove(self.timers,1);self.clock=t.at;t.fn();n=n+1;assert(n<20000,'timer loop')
 end
end
C_Timer={After=function(delay,fn)table.insert(MOCK.timers,{at=MOCK.clock+delay,fn=fn})end}
function MOCK.nativeClick(b,mouse)
 local suffix=mouse=='RightButton'and '2'or '1';local action=b:GetAttribute('type'..suffix)or b:GetAttribute('type')
 if action=='target'then
  local unit=b:GetAttribute('unit'..suffix)or b:GetAttribute('unit')
  if unit=='player'then MOCK.target='TestGM';MOCK.targetIsPlayer=true;MOCK.targetGUID=nil;MOCK.targetDead=false end
 elseif action=='item'then MOCK.used[#MOCK.used+1]=b:GetAttribute('item'..suffix)or b:GetAttribute('item')
 elseif action=='macro'then
  local macro=b:GetAttribute('macrotext'..suffix)or b:GetAttribute('macrotext')or ''
  if macro:find('/cleartarget',1,true)then MOCK.target=nil;MOCK.targetIsPlayer=false;MOCK.targetGUID=nil;MOCK.targetDead=false end
  if macro:find('/targetexact ',1,true)then MOCK.target=macro:match('/targetexact (.+)');MOCK.targetIsPlayer=true end
 end
end
local baseCreate=CreateFrame
function MOCK.nativeBagClick(b,mouse)
 local bag,slot=b:GetParent():GetID(),b:GetID();local link=GetContainerItemLink(bag,slot)
 if MOCK.shift or MOCK.chatOpen then
  if HandleModifiedItemClick(link)then return end
  if MOCK.shift then local _,count,locked=GetContainerItemInfo(bag,slot);if not locked and count and count>1 then OpenStackSplitFrame(count,b)end end
 elseif mouse=='RightButton'then MOCK.used[#MOCK.used+1]=bag..' '..slot
 else PickupContainerItem(bag,slot)end
end
function CreateFrame(kind,name,parent,template)
 local f=baseCreate(kind,name,parent,template)
 if template and template:find('SecureActionButtonTemplate',1,true)then f.secure=true;f:SetScript('OnClick',MOCK.nativeClick)end
 if template=='ContainerFrameItemButtonTemplate'then
  f.icon=f:CreateTexture(name..'IconTexture','ARTWORK');f.Count=f:CreateFontString(name..'Count','OVERLAY');baseCreate('Cooldown',name..'Cooldown',f)
  f:SetScript('OnClick',MOCK.nativeBagClick)
  f.SplitStack=function(b,n)SplitContainerItem(b:GetParent():GetID(),b:GetID(),n)end
  f:SetScript('OnDragStart',function(b)PickupContainerItem(b:GetParent():GetID(),b:GetID())end)
  f:SetScript('OnReceiveDrag',f:GetScript('OnDragStart'))
 end
 return f
end
function SetItemButtonTexture(b,texture)b.icon:SetTexture(texture)end
function SetItemButtonCount(b,count)b.Count:SetText(count>1 and count or '')end
function SetItemButtonDesaturated(b,on)b.icon:SetDesaturated(on)end
function GetRealmName()return 'TestRealm'end
function GetCursorInfo()if MOCK.cursor then return 'item',118 end end
function ClearCursor()MOCK.cursor=false end
function GetContainerItemQuestInfo()return false,nil end
function methods:Click(mouse)
 if not self.enabled then return end
 mouse=mouse or 'LeftButton';run(self,'PreClick',mouse);run(self,'OnClick',mouse);run(self,'PostClick',mouse)
end
local setAttr=methods.SetAttribute
function methods:SetAttribute(key,value)
 assert(not self.secure or not MOCK.combat,'protected attribute changed in combat: '..key);setAttr(self,key,value)
end
function methods:AddMessage(msg)MOCK.messages[#MOCK.messages+1]=msg end
function methods:SetMaxLines(value)self.maxLines=value end
function methods:ScrollUp()end
function methods:ScrollDown()end
function methods:SetDesaturated(value)self.desaturated=value end
function methods:SetSpellByID(id)self.spellID=id end
function methods:SetHyperlink(link)self.link=link end
function methods:SetBagItem(bag,slot)self.bag=bag;self.slot=slot end
function methods:SetInventoryItem(unit,slot)self.inv=slot end
function GetTime()return MOCK.clock end
function time()return 1791590000 end
function date()return '2026-10-10'end
function GetLocale()return MOCK.locale or 'koKR'end
function GetBuildInfo()return '7.3.5','26972','',70300 end
function UnitLevel()return 110 end
function UnitClass()return 'Mage','MAGE',8 end
function UnitGUID(unit)return UnitExists(unit)and (unit=='target'and MOCK.targetGUID or 'Player-'..UnitName(unit))end
function UnitIsDeadOrGhost(unit)return unit=='target'and MOCK.targetDead or false end
function UnitIsConnected(unit)return UnitExists(unit)end
function UnitPosition()return 100,200,300,0 end
function GetProfessions()return 1,nil,3,4,5,6 end
function GetProfessionInfo(index)
 local ids={[1]=164,[3]=794,[4]=356,[5]=185,[6]=129};local id=ids[index];local s=MOCK.skills[id]
 if s then return 'Skill '..id,134400,s[1],s[2],0,0,id end
end
function IsPlayerSpell(id)return MOCK.known[id]or false end
IsSpellKnown=IsPlayerSpell
function GetSpellInfo(id)return 'Spell '..id,'',134400,0,0,40,id end
function GetSpellTexture()return nil end
function GetItemInfo(id)return 'Item '..tostring(id)end
function GetItemClassInfo(id)return 'Class '..id end
function GetItemQualityColor()return 1,1,1,'ffffffff'end
function GetItemCount()return 5 end
function GetDungeonDifficultyID()return MOCK.dungeon end
function GetRaidDifficultyID()return MOCK.raid end
function GetLegacyRaidDifficultyID()return MOCK.legacy end
function SetDungeonDifficultyID(id)if not MOCK.rejectDifficulty then MOCK.dungeon=id end end
function SetRaidDifficultyID(id)if not MOCK.rejectDifficulty then MOCK.raid=id end end
function SetLegacyRaidDifficultyID(id)if not MOCK.rejectDifficulty then MOCK.legacy=id end end
function IsInGroup()return false end
function IsInRaid()return false end
function UnitIsGroupLeader()return true end
function GetContainerNumSlots(bag)return bag==0 and 16 or bag==1 and 20 or 0 end
function GetContainerNumFreeSlots(bag)return GetContainerNumSlots(bag)-1 end
function GetContainerItemLink(bag,slot)return slot==1 and 'item:118'or nil end
function GetContainerItemInfo(bag,slot)if slot==1 then return 134829,5,false,1 end end
function GetContainerItemCooldown()return 0,0,0 end
function CooldownFrame_Set()end
function PickupContainerItem(bag,slot)MOCK.picked={bag,slot}end
function SplitContainerItem(bag,slot,count)MOCK.split={bag,slot,count}end
function ContainerIDToInventoryID(id)return 19+id end
function GetInventorySlotInfo(name)return 20+tonumber(name:match('Bag(%d)Slot')),'Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag'end
function ToggleBag(bag)MOCK.openedBag=bag end
function CursorHasItem()return MOCK.cursor or false end
function PutItemInBag(id)MOCK.putBag=id end
function PickupBagFromSlot(id)MOCK.pickBag=id end
function GetInventoryItemTexture()return nil end
function GetCoinTextureString()return '100 Gold'end
function GetMoney()return 1000000 end
function SortBags()MOCK.sorted=true end
function IsModifiedClick()return false end
function HandleModifiedItemClick(link)if MOCK.chatOpen then MOCK.insertedLink=link;return true end;return false end
StackSplitFrame=CreateFrame('Frame','StackSplitFrame',UIParent);StackSplitFrame:Hide()
function OpenStackSplitFrame(count,owner)MOCK.splitPrompt={count=count,owner=owner};StackSplitFrame.owner=owner;StackSplitFrame:Show()end
function ChatEdit_InsertLink()end
function GetAddOnInfo()return 'GMminibar'end
function UpdateAddOnMemoryUsage()end
function GetAddOnMemoryUsage()return collectgarbage('count')end
function GetQuestLogTitle(i)local q=MOCK.quests[i];if q then return q.title,1,0,0,false,false,false,q.id end end
function GetQuestLogIndexByID(id)for i,q in ipairs(MOCK.quests)do if q.id==id then return i end end end
function GetNumQuestLeaderBoards()return #(MOCK.objectives or {{}})end
function GetQuestLogLeaderBoard(i)
 local row=(MOCK.objectives or {{text='Objective: 0/1',kind='monster',finished=false}})[i]
 if row then return row.text,row.kind,row.finished end
end
function IsUnitOnQuest()return false end
WorldMapFrame=CreateFrame('Frame','WorldMapFrame',UIParent);WorldMapFrame:SetSize(700,500);WorldMapFrame:Hide()
WorldMapDetailFrame=CreateFrame('Frame','WorldMapDetailFrame',WorldMapFrame)
function GetCurrentMapAreaID()return MOCK.mapArea or 81 end
function GetCurrentMapDungeonLevel()return MOCK.mapFloor or 0 end
function GetMapInfo()return MOCK.mapName or 'StonetalonMountains'end
function ToggleWorldMap()if WorldMapFrame:IsShown()then WorldMapFrame:Hide()else WorldMapFrame:Show()end end
QuestMapFrame={DetailsFrame={}}
function ToggleQuestLog()if WorldMapFrame:IsShown()then WorldMapFrame:Hide()else WorldMapFrame:Show()end end
function QuestMapFrame_ShowQuestDetails()end
function strsplit(delimiter,text)
 local fields={};local pos=1
 while true do local stop=text:find(delimiter,pos,true);if not stop then fields[#fields+1]=text:sub(pos);break end;fields[#fields+1]=text:sub(pos,stop-1);pos=stop+#delimiter end
 return unpack(fields)
end
bit={band=function(a,b)local out,p=0,1;while a>0 and b>0 do if a%2==1 and b%2==1 then out=out+p end;a=math.floor(a/2);b=math.floor(b/2);p=p*2 end;return out end}
