local A=GMMLegion735
MOCK.passed=0
local function check(ok,message)assert(ok,message);MOCK.passed=MOCK.passed+1 end
MOCK:Fire('ADDON_LOADED','GMminibar');MOCK:Fire('PLAYER_LOGIN');MOCK:Drain()
check(A.ready and A.mini~=nil,'login')
for _,key in ipairs({'Utilities','Spells','Items','Professions','Travel','Bags','Quests','Commands','Difficulty','Settings'})do A:Show(key);MOCK:Drain()end
check(#GMMLegionDiagnostics.errors==0,table.concat(GMMLegionDiagnostics.errors,'\n'))
check(WorldMapFrame:IsShown(),'quest helper must open quest map')
local slots=0;for _ in pairs(A.mini.buttons)do slots=slots+1 end;check(slots==11,'minibar slots')
for _,key in ipairs({'Utilities','Spells','Items','Professions','Travel','Commands'})do check(A.frames[key]:GetWidth()==1080 and A.frames[key]:GetHeight()==700,'window dimensions '..key)end
for _,p in ipairs(A.data.professions)do check(#p.tiers==10 and p.tiers[10].cap==800,p.name..' tiers through Legion')end
local fishing,archaeology
for _,p in ipairs(A.data.professions)do if p.id==794 then archaeology=p elseif p.id==356 then fishing=p end end
check(archaeology.tiers[1].id==78670,'exclude artifact searching spell')
check(fishing.tiers[10].skillOnly,'Legion fishing direct cap')
local spells=A.frames.Spells;A:Show('Spells');MOCK.target='AnotherPlayer';MOCK.known[133]=nil
spells:Select({id=133,name='Fireball',ko='화염구',rank='',level=1});MOCK:ResetSent();spells.learn:Click()
check(MOCK.target=='TestGM' and #MOCK.sent==1 and MOCK.sent[1][1]=='.learn 133','hardware self learn')
MOCK.known[133]=true;MOCK:Fire('SPELLS_CHANGED');MOCK:Drain()
check(not spells.learn:IsEnabled()and spells.unlearn:IsEnabled(),'learned state acknowledged from client')
MOCK.known[3276]=nil;spells:Select({id=3276,name='Heavy Linen Bandage',ko='두꺼운 리넨 붕대',rank='',level=0})
MOCK.known[3276]=true;MOCK:Fire('NEW_RECIPE_LEARNED',3276);MOCK:Drain()
check(not spells.learn:IsEnabled()and spells.unlearn:IsEnabled(),'Legion recipe event refreshes learned detail without a spellbook event')
local found;A:SearchCatalog('spells','133',{},function(rows)found=rows end);MOCK:Drain();check(#found==1 and found[1].id==133,'exact spell search')
A:SearchCatalog('spells','133',{hideKnown=true},function(rows)found=rows end);MOCK:Drain();check(#found==0,'hide known')
local cancelled=false
A:SearchCatalog('spells','',{},function()cancelled=true end);A:SearchCatalog('spells','133',{},function()end);MOCK:Drain();check(not cancelled,'cancel old catalog search')
A:SearchCatalog('items','118',{},function(rows)found=rows end);MOCK:Drain();check(#found==1 and found[1].id==118,'potion catalog')
local prof=A.frames.Professions;prof.profession=A.data.professions[2];prof:Refresh()
check(prof.profession.id==164 and prof.tiers[1].learn:IsEnabled()and not prof.tiers[2].learn:IsEnabled(),'sequential first rank')
MOCK.skills[164]={1,75};prof:Refresh()
check(not prof.tiers[1].learn:IsEnabled()and prof.tiers[1].max:IsEnabled()and prof.tiers[2].learn:IsEnabled()and not prof.tiers[3].learn:IsEnabled(),'skill rank and maximize gating')
MOCK:ResetSent();prof.tiers[1].max:Click();check(MOCK.sent[1][1]=='.setskill 164 75 75','maximize exact rank cap')
MOCK.skills[356]={600,700};prof.profession=fishing;prof:Refresh();MOCK:ResetSent();prof.tiers[10].learn:Click();check(MOCK.sent[1][1]=='.setskill 356 600 800','fishing cap path')
local bags=A.frames.Bags
local function binding(b)return b.bag and (b:GetParent():GetID()..' '..b:GetID())end
check(#bags.bagButtons==4,'four equipped bag slots')
check(bags.slots[1]:GetScript('OnClick')==MOCK.nativeBagClick,'native Blizzard container click preserved')
bags.slots[1]:Click('RightButton');check(MOCK.used[#MOCK.used]=='0 1','potion secure bag/slot action')
bags.slots[1]:Click('LeftButton');check(MOCK.picked[1]==0 and MOCK.picked[2]==1,'left click item movement')
MOCK.cursor=true;bags.bagButtons[4]:Click();check(MOCK.putBag==23,'bag equip inventory slot');MOCK.cursor=false
MOCK.combat=true;bags:Refresh();check(bags.dirty,'defer bag rebinding in combat');MOCK:Fire('BAG_UPDATE_DELAYED');MOCK:Drain();MOCK.combat=false;MOCK:Fire('PLAYER_REGEN_ENABLED');MOCK:Drain();check(not bags.dirty,'refresh after combat')
local dest={map=0,x=1,y=2,z=3,difficulty=2,kind='dungeon'}
MOCK.rejectDifficulty=true;MOCK.dungeon=1;MOCK:ResetSent();A:Teleport(dest);MOCK:Drain();check(#MOCK.sent==0,'difficulty denial cancels teleport')
MOCK.rejectDifficulty=false;A:Teleport(dest);check(#MOCK.sent==0,'wait before teleport');MOCK:Drain();check(#MOCK.sent==1 and MOCK.sent[1][1]:find('%.go xyz'),'confirmed difficulty then teleport')
MOCK.dungeon=1;MOCK:ResetSent();A:Teleport(dest);A:Teleport({map=1,x=4,y=5,z=6});MOCK:Drain();check(#MOCK.sent==1 and MOCK.sent[1][1]:find('4.00000',1,true),'new destination cancels stale pending teleport')
local previous=-1;local ids={};local portals,taxi=0,0
for _,r in ipairs(A.data.travel)do
 assert(r.level>=previous,'level sort');previous=r.level;assert(not ids[r.id],'duplicate destination');ids[r.id]=true
 assert(r.x==r.x and r.y==r.y and r.z==r.z and r.map>=0,'finite coordinates')
 if r.source:find('WorldSafeLocs',1,true)then portals=portals+1;assert(r.map~=r.instance,'entrance must be outside instance')end
 if r.kind=='flight'then taxi=taxi+1 end
end
check(portals>250 and taxi>300,'entrance and flight catalog')
local u=A.frames.Utilities;u.page=2;u:Refresh();local summon
for _,b in ipairs(u.cards)do if b.entry and b.entry.key=='summon'then summon=b end end
MOCK.target='AnotherPlayer';MOCK.targetIsPlayer=true;MOCK:ResetSent();summon:Click();check(MOCK.sent[1][1]=='.summon AnotherPlayer','summon keeps target')
MOCK:ResetSent();A:ExecuteAction(A.byAction.repair,'RightButton');check(MOCK.sent[1][1]=='.repairitems','target repair')
check(not A:Send('.learn 133\n.reload all'),'command injection rejected')
MOCK.quests={{title='A quest',id=999999}};A.frames.Quests:Refresh();check(A:CurrentQuest()==999999,'Legion quest ID return position')
check(A.frames.Quests.complete:GetAttribute('macrotext'):find('/say .quest complete 999999',1,true),'secure completion command')
check(not A.frames.Quests.start:IsEnabled(),'unavailable start coordinate is not fabricated')
check(A.frames.Quests.find:IsEnabled(),'unknown objectives offer an explanation rather than a silent disabled button')
MOCK:ResetSent();A.frames.Quests.find:GetScript('OnClick')();check(#MOCK.sent==0,'unverified objective callback also rejects teleport')
local quest=A.frames.Quests
UIParent:SetSize(1024,768);WorldMapFrame:SetSize(990,540);WorldMapFrame.mockLeft=12;WorldMapFrame.mockBottom=110;WorldMapFrame:Show();quest:Dock()
local anchor,_,_,qx,qy=quest:GetPoint();local qs=quest:GetScale()
check(anchor=='BOTTOMRIGHT' and qx*qs<=1024 and qy*qs>=0 and qy*qs+quest:GetHeight()*qs<=768 and quest:GetFrameStrata()=='DIALOG','quest helper stays fully visible on small screen')
UIParent:SetSize(1920,1080);WorldMapFrame:SetSize(700,500);WorldMapFrame.mockLeft=50;WorldMapFrame.mockBottom=0;quest:Dock()
check(quest:GetPoint()=='BOTTOMLEFT','quest helper docks beside map when space allows');WorldMapFrame:Hide()
for _,f in ipairs(MOCK.frames)do assert(not f:GetScript('OnUpdate'),'no idle polling')end
check(true,'no idle polling')
-- Regressions observed in the RC1 catalog/UI, using the actual Legion data.
check(A:DataName({name='Fallback',ko=''})=='Fallback','empty localization falls back to source name')
A:SearchCatalog('spells','12294',{class=1,playerOnly=true},function(rows)found=rows end);MOCK:Drain()
check(#found==1 and found[1].id==12294,'Warrior specialization spell Mortal Strike is present')
A:SearchCatalog('spells','7934',{class=1,playerOnly=true},function(rows)found=rows end);MOCK:Drain()
check(#found==0,'First Aid class eligibility is not a Warrior spell classification')
A:SearchCatalog('spells','133',{class=128,playerOnly=true},function(rows)found=rows end);MOCK:Drain()
check(#found==1,'Mage specialization Fireball remains searchable')
A:SearchCatalog('items','',{refs=true,class=2,hideInternal=true},function(rows)found=rows end);MOCK:Drain()
check(#found>2000 and type(found[1])=='number' and A:CatalogRow('items',found[#found]).class==2,'all weapon pages remain accessible with compact references')
local group
for _,g in ipairs(A.data.itemGroups)do if g.key=='journal:63'then group=g;break end end
local itemIDs={};for _,id in ipairs(group.ids)do itemIDs[id]=true end
A:SearchCatalog('items','',{refs=true,ids=itemIDs},function(rows)found=rows end);MOCK:Drain()
check(#found>0,'Deadmines loot is joined from JournalEncounterItem')
for _,ref in ipairs(found)do assert(itemIDs[A:CatalogRow('items',ref).id],'item outside dungeon filter')end
check(A.frames.Items.list.columns==2 and A.frames.Items.quantityPopup~=nil,'two-column item browser and quantity prompt')
A:Show('Items');MOCK:Drain();check(not A.frames.Spells:IsShown(),'menu switches one main window at a time')
local items=A.frames.Items;items.advancedVisible=true;items:LayoutFilters()
for i=17,#items.list.rows do assert(not items.list.rows[i]:IsShown(),'advanced filters must not overflow rows')end
check(true,'filter expansion reserves list space')
items.list.onSelect({id=118,name='Minor Healing Potion',ko='최하급 치유 물약',level=1,itemlevel=5},'LeftButton');items.count:SetText('2');MOCK.target='AnotherPlayer';MOCK:ResetSent();items.add:Click()
check(MOCK.target=='TestGM' and MOCK.sent[1][1]=='.additem 118 2','quantity popup preserves secure self item grant')
local travel=A.frames.Travel
check(#travel.categoryButtons==6 and #travel.headers==7,'original six teleport categories and seven table columns')
travel.category='zone';travel:Search();local hasFlight=false
for _,r in ipairs(travel.list.data)do assert(r.kind~='raid'and r.kind~='dungeon','region category leak');if r.kind=='flight'then hasFlight=true end end
check(hasFlight,'flight masters remain in region browsing')
travel.category='raid';travel.sortKey='recommendedLevel';travel.ascending=false;travel:Search()
for i=2,#travel.list.data do assert(A:TravelLevel(travel.list.data[i-1])>=A:TravelLevel(travel.list.data[i]),'descending level order')end
check(#travel.list.data>0,'raid header sorting')
for _,b in ipairs(travel.list.rows)do local _,_,_,x=b.cells[7]:GetPoint();assert(x+b.cells[7]:GetWidth()<=b:GetWidth(),'table exceeds row bounds')end
check(true,'aligned teleport columns fit in frame')
local row=travel.list.data[1];MOCK:ResetSent();travel.list.onSelect(row,'RightButton');MOCK:Drain()
check(#MOCK.sent==0 and GMMLegionDB.favorites[row.id],'right click favorites never teleports')
check(A.frames.Items.menu:GetHeight()==247 and not A.frames.Items.menu.caption:IsEnabled(),'compact inert menu header')
check(A.frames.Spells.classPanel~=nil and A.frames.Spells.minimum:GetText()=='0' and A.frames.Spells.maximum:GetText()=='110','original spell panels and Legion level range')
spells:Select(nil);check(spells.ranks:GetText()==A:L('rank'),'cleared spell selection clears stale learned rank')
check(A.data.travelRegions['taxi:339'].zone=='Darkshore','explicit flight-node zone wins over overlapping Ashenvale map bounds')
local icc;for _,r in ipairs(A.data.travel)do if r.instance==631 and r.difficulty==5 then icc=r end end
check(icc and A:TravelLevel(icc)==80,'legacy heroic raid level uses the instance record rather than expansion entry level')
local trial;for _,r in ipairs(A.data.travel)do if r.instance==649 then trial=r;break end end
check(trial and A:TravelRegion(trial).area==210,'Trial of the Crusader uses Icecrown parent zone instead of overlapping Hrothgars Landing')
travel.reset:Click();check(travel.sortKey=='level' and travel.ascending and not travel.category,'travel reset restores default ascending level order')
travel.headers[6]:Click();check(not travel.ascending,'first click on default level header reverses the sort immediately')
-- Bag regressions: compact layout, scroll bindings, real modified click flow.
bags.visibleRows=3;bags:Refresh()
check(bags:GetWidth()==384 and bags:GetHeight()==302 and bags.capacity==24,'bag starts at the legacy compact height rather than eight fixed rows')
check(bags.bagButtons[4].icon:GetTexture()==bags.bagButtons[4].emptyTexture and bags.bagButtons[4].number:GetText()=='4','empty equipment slots are numbered empty bag textures')
MOCK.cursor=false;bags.bagButtons[1]:Click();check(MOCK.openedBag==1,'equipped bag click opens it without removing it')
bags.bagButtons[1]:GetScript('OnDragStart')();check(MOCK.pickBag==20,'drag equipped bag uses its inventory slot')
bags:Scroll(-1);check(bags.offset==1 and binding(bags.slots[1])=='0 9','scroll moves one row and updates secure bag-slot binding')
bags:Scroll(-100);check(binding(bags.slots[1])=='1 1' and not bags.down:IsEnabled(),'last row is reachable and scrolling is clamped')
bags.search:SetText('Item item:118');check(bags.offset==0 and binding(bags.slots[2])=='1 1','filtered item retains its original bag identity')
bags.slots[2]:Click('RightButton');check(MOCK.used[#MOCK.used]=='1 1','filtered right click uses the actual item slot')
bags.search:SetText('no matching item');check(bags.empty:IsShown()and not bags.slots[1]:IsShown()and binding(bags.slots[1])==nil,'empty search clears stale secure item bindings')
bags.search:GetScript('OnEscapePressed')(bags.search);MOCK.shift=true;MOCK.chatOpen=false;bags.slots[1]:Click('LeftButton')
check(MOCK.splitPrompt and MOCK.splitPrompt.count==5 and StackSplitFrame:IsShown(),'shift click without chat opens the Legion global split stack dialog')
bags.slots[1]:SplitStack(2);check(MOCK.split[1]==0 and MOCK.split[2]==1 and MOCK.split[3]==2,'stack split operates on the captured bag slot')
MOCK.chatOpen=true;MOCK.splitPrompt=nil;bags.slots[1]:Click('LeftButton');check(MOCK.insertedLink=='item:118'and not MOCK.splitPrompt,'modified chat link is handled before splitting')
MOCK.chatOpen=false;MOCK.shift=false;StackSplitFrame:Hide()
bags.grow:Click();check(bags:GetHeight()==344 and bags.capacity==32 and GMMLegionDB.bagRows==4,'height control adds one row and persists it')
local before=binding(bags.slots[1]);MOCK.combat=true;bags:Scroll(-1);bags:ChangeRows(1);bags:Refresh()
check(bags.visibleRows==4 and binding(bags.slots[1])==before and bags.dirty,'combat never remaps protected item buttons')
MOCK.combat=false;bags:Refresh();bags.shrink:Click()
local normalCapacity=GetContainerNumSlots
GetContainerNumSlots=function(bag)return bag==0 and 20 or 36 end;bags:Refresh();bags:Scroll(-100)
local last;for _,b in ipairs(bags.slots)do if b.bag~=nil then last=b end end
check(last.bag==4 and last.slot==36 and binding(last)=='4 36','inventory beyond 64 slots remains reachable without page truncation')
GetContainerNumSlots=normalCapacity;bags.offset=0;bags:Refresh()
check(bags.slots[1].countText:GetParent()~=bags.slots[1].cd,'item counts remain visible when the cooldown frame hides')
check(#GMMLegionDiagnostics.errors==0,table.concat(GMMLegionDiagnostics.errors,'\n'))
