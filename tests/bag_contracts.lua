-- Stateful inventory fixture: tests effects and refusal paths, not rendering.
local A=GMMLegion735;local f=A.frames.Bags
local function check(ok,label)assert(ok,label);MOCK.passed=MOCK.passed+1 end
MOCK:Drain();GMMLegionDB.autoSortBags=false
local slots,items,held,origin,sold,deleted,families={},{},nil,nil,{},{},{}
local function put(b,s,id,name,quality,class,count,price)
 slots[b..':'..s]={id=id,count=count or 1};items[id]={name=name,quality=quality or 0,class=class or 15,price=price or 1}
end
function GetContainerNumSlots(b)return b==0 and 8 or b==1 and 4 or 0 end
function GetContainerNumFreeSlots(b)local n=GetContainerNumSlots(b);for s=1,n do if slots[b..':'..s]then n=n-1 end end;return n,families[b]or 0 end
function GetContainerItemLink(b,s)local v=slots[b..':'..s];return v and 'item:'..v.id end
function GetContainerItemInfo(b,s)local v=slots[b..':'..s];if v then return 134400,v.count,v.locked,items[v.id].quality,false,false,'item:'..v.id,false,false,v.id end end
function GetItemInfo(link)
 local id=tonumber(link)or tonumber(tostring(link):match('item:(%d+)'));local v=items[id];if not v or v.uncached then return end
 return v.name,'item:'..id,v.quality,1,1,'Class '..v.class,'Subclass',20,'',134400,v.price,v.class,0
end
function GetContainerItemQuestInfo(b,s)local v=slots[b..':'..s];return v and items[v.id].quest or false end
function GetCursorInfo()return held and 'item',held and held.id end
function CursorHasItem()return held~=nil end
function ClearCursor()if held and origin and not slots[origin]then slots[origin]=held end;held=nil;origin=nil end
function PickupContainerItem(b,s)
 local key=b..':'..s;local v=slots[key];if v and v.locked then return end
 if not held then origin=key end
 slots[key],held=held,v
 if not held then origin=nil end
end
function PickupMerchantItem(index)assert(index==0 and MerchantFrame:IsShown());sold[#sold+1]=held;held=nil;origin=nil end
function DeleteCursorItem()deleted[#deleted+1]=held;held=nil;origin=nil end
MerchantFrame=CreateFrame('Frame','MerchantFrame',UIParent);MerchantFrame.selectedTab=1;MerchantFrame:Hide()
put(0,1,10,'Z junk',0);put(0,2,11,'A junk',0);put(0,3,12,'Quest',1,12);put(0,4,13,'Potion',1,0,5);put(0,5,14,'Locked',0);slots['0:5'].locked=true
put(0,6,15,'Uncached',0);items[15].uncached=true;put(0,7,16,'No vendor value',0);items[16].price=0
f.mode=nil;f.selected={};f.search:SetText('');f.offset=0;f:Show();f:Refresh()
check(f.select and f.pin and f.sell and f.destroy and f.sort,'legacy bag toolbar is complete')
f.pin:Click();f.slots[1].guard:Click();f.pin:Click()
check(f:IsPinned(0,1)and f.slots[1].guard:IsShown()and f.slots[1].glow:IsShown(),'pin persists and blocks item click and drag via guard')
local oldGUID=UnitGUID;UnitGUID=function()return 'OtherCharacter'end
check(not f:IsPinned(0,1),'pins are scoped per character');UnitGUID=oldGUID
f.select:Click();f.slots[1].guard:Click();f.slots[2].guard:Click()
check(not f.selected['0:1']and f.selected['0:2'],'selection excludes pinned slots')
slots['0:2'].count=2;f:Refresh();check(not f.selected['0:2'],'selection invalidates if a stack changed')
f.select:Click();local all={q0=true,q1=true,quest=true,consumable=true}
check(not f:Matches(0,1,'destroy',all)and not f:Matches(0,5,'destroy',all)and not f:Matches(0,6,'destroy',all),'bulk excludes pins, locked slots and uncached item metadata')
check(not f:Matches(0,3,'sell',all)and not f:Matches(0,7,'sell',all),'quest items and zero vendor value never sell')
check(not f:Matches(0,3,'destroy',{q1=true})and f:Matches(0,3,'destroy',{quest=true})=='item:12','quest destruction requires explicit quest condition')
check(f:Matches(0,4,'destroy',{consumable=true})=='item:13','consumable condition includes recovery items independent of quality')
f:BulkPanel('sell');check(not f.bulkPanel.checks.quest:IsEnabled(),'sale conditions disable quest option')
check(f.bulkPanel.checks.quest.label:GetText()==A:L('bagquest')and f.bulkPanel.checks.q0.label:GetText()==A:L('quality0'),'quest label is not parsed as a quality key')
f:QueueBulk('sell');check(not f.preview and #sold==0,'sale requires an open merchant')
MerchantFrame:Show();MerchantFrame.selectedTab=2;f:QueueBulk('sell');check(not f.preview,'buyback tab is not a sell context')
MerchantFrame.selectedTab=1;GMMLegionDB.bagFilters.sell={q0=true};f:QueueBulk('sell')
check(f.preview and #f.preview.queue==1 and #sold==0,'bulk preview performs no sale and excludes protected items')
StaticPopupDialogs.GMMLEGION_BAG_BULK.OnCancel();check(not f.preview and #sold==0,'cancel leaves items unchanged')
f:QueueBulk('sell');slots['0:2']={id=13,count=5};StaticPopupDialogs.GMMLEGION_BAG_BULK.OnAccept();MOCK:Drain()
check(#sold==0 and slots['0:2'].id==13,'changed preview slot cannot sell a replacement item')
put(0,2,11,'A junk',0,15,2);f:QueueBulk('sell');StaticPopupDialogs.GMMLEGION_BAG_BULK.OnAccept();MOCK:Drain()
check(#sold==1 and sold[1].count==2 and not slots['0:2']and not held,'confirmed sale handles the whole stack and leaves no cursor item')
put(0,2,11,'A junk',0);f:QueueBulk('sell');MerchantFrame:Hide();StaticPopupDialogs.GMMLEGION_BAG_BULK.OnAccept();MOCK:Drain()
check(#sold==1 and slots['0:2'],'closing merchant cancels a pending sale before dispatch')
GMMLegionDB.bagFilters.destroy={consumable=true};f:QueueBulk('destroy');check(#deleted==0 and f.preview,'destruction is previewed first')
MOCK.combat=true;StaticPopupDialogs.GMMLEGION_BAG_BULK.OnAccept();MOCK:Drain();MOCK.combat=false
check(#deleted==0 and slots['0:4'],'combat prevents confirmed destruction')
f:QueueBulk('destroy');StaticPopupDialogs.GMMLEGION_BAG_BULK.OnAccept();MOCK:Drain()
check(#deleted==1 and deleted[1].id==13 and slots['0:3'],'confirmed destruction matches the chosen type and preserves quest items')
GMMLegionDB.bagFilters.destroy={q0=true};f:SetMode('select');f:Refresh();f.slots[2].guard:Click();f:QueueBulk('destroy')
check(f.preview and #f.preview.queue==1 and f.preview.queue[1].s==2,'selection limits bulk operations to selected matching slots')
f:Hide();check(not f.preview and not f.job and not f.bulkPanel:IsShown(),'closing bags dismisses pending batch and conditions');f:Show()
-- Sorting preserves pinned positions, specialized bag families, and total counts.
slots={};put(0,4,20,'Pinned',0);put(0,6,21,'Z last',0);put(0,7,22,'A first',0);put(1,3,23,'Herb',0,7)
families[1]=32;items[15].uncached=nil;f:Pins()['0:4']=20;f.mode=nil;f.search:SetText('');f:RequestSort(true);MOCK:Drain()
check(slots['0:1'].id==22 and slots['0:2'].id==21 and slots['0:4'].id==20,'sort orders unpinned slots while keeping pin position')
check(slots['1:1'].id==23 and not slots['1:3']and not held,'sort keeps specialized bags in their own family')
local n=0;for _,v in pairs(slots)do n=n+v.count end;check(n==4 and not f.sortJob,'sorting preserves inventory and terminates')
put(0,7,24,'A locked',0);slots['0:7'].locked=true;f:RequestSort(true);MOCK:Drain()
check(not f.sortJob and slots['0:7'].id==24,'sort waiting for locked items is bounded')
MOCK.combat=true;f:RequestSort(true);check(not f.sortJob,'sort refuses combat');MOCK.combat=false
MerchantFrame:Show();f:RequestSort(true);check(not f.sortJob,'sort refuses merchant transactions');MerchantFrame:Hide()
f.sort:Click('RightButton');check(GMMLegionDB.autoSortBags,'right click toggles saved automatic sorting');f.sort:Click('RightButton')
f.search:SetText('Pinned');f:SetMode('pin');check(f.slots[1].bag==0 and f.slots[1].slot==4,'filtered pin control retains actual slot identity');f.slots[1].guard:Click();check(not f:IsPinned(0,4),'filtered pin toggle unlocks the actual item')
for _,frame in ipairs(MOCK.frames)do assert(not frame:GetScript('OnUpdate'),'new bag controls must not add idle polling')end
check(#GMMLegionDiagnostics.errors==0,table.concat(GMMLegionDiagnostics.errors,'\n'))
-- Automatic merchant mode must not reuse broad manual sale filters.
slots={};put(0,1,31,'Pinned gray',0);put(0,2,32,'Gray',0);put(0,3,33,'Common',1);put(0,4,34,'Quest gray',0,12)
f.mode=nil;f.search:SetText('');f:Pins()['0:1']=31;GMMLegionDB.autoSellJunk=true;GMMLegionDB.bagFilters.sell={q0=true,q1=true,consumable=true}
MerchantFrame:Show();MerchantFrame.selectedTab=1;local soldBefore=#sold;f.autoSellGeneration=8;f:TryAutoSell(8,GetTime()+2);MOCK:Drain()
check(#sold==soldBefore+1 and sold[#sold].id==32 and slots['0:1']and slots['0:3']and slots['0:4'],'automatic sale is gray-only and excludes pins/quests despite broad manual filter')
put(0,2,35,'Delayed gray',0);items[35].uncached=true;f.autoSellGeneration=9;f:TryAutoSell(9,GetTime()+2)
A:SetOption('autoSellJunk',false);items[35].uncached=false;MOCK:Drain()
check(slots['0:2']and #sold==soldBefore+1,'turning automatic sale off cancels metadata retry')
GMMLegionDB.autoSellJunk=true;items[35].uncached=true;f.autoSellGeneration=10;f:TryAutoSell(10,GetTime()+2)
MerchantFrame:Hide();MOCK:Fire('MERCHANT_CLOSED');items[35].uncached=false;MOCK:Drain()
check(slots['0:2']and not held,'merchant close cancels automatic sale retry')
MerchantFrame:Show();MOCK.combat=true;f.autoSellGeneration=11;f:TryAutoSell(11,GetTime()+2);MOCK.combat=false
check(slots['0:2']and not f.job,'automatic sales never dispatch during combat')
items[35].uncached=true;f.autoSellGeneration=12;f:TryAutoSell(12,GetTime()+1);MOCK:Drain()
check(slots['0:2']and not f.job,'uncached automatic sale waiting expires without deleting item')
items[35].uncached=false;GMMLegionDB.autoSellJunk=false;MerchantFrame:Hide();GMMLegionDB.autoSortBags=false
