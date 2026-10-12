local A=GMMLegion735;local N=A.UI
local COLUMNS,STEP,SIZE=8,42,36
local function active(v)return v==true or v==1 end
local function slotKey(b,s)return b..':'..s end
local function itemID(link)return link and tonumber(link:match('item:(%d+)'))end
local function merchant()return MerchantFrame and MerchantFrame:IsShown()and MerchantFrame.selectedTab~=2 end
local function copy(t)local out={};for k,v in pairs(t or {})do out[k]=v end;return out end
local B={}
function B:Pins()
 GMMLegionDB.bagPins=GMMLegionDB.bagPins or {}
 local who=(GetRealmName()or '')..':'..(UnitGUID('player')or UnitName('player'))
 GMMLegionDB.bagPins[who]=GMMLegionDB.bagPins[who]or {};return GMMLegionDB.bagPins[who]
end
function B:IsPinned(b,s)
 local id=itemID(GetContainerItemLink(b,s));return id~=nil and self:Pins()[slotKey(b,s)]==id
end
function B:Busy()return A:Combat()or GetCursorInfo()or self.job or self.preview or self.sortJob end
function B:TogglePin(b,s)
 if self:Busy()then return end
 local link=GetContainerItemLink(b,s);local _,_,locked=GetContainerItemInfo(b,s)
 if not link or active(locked)then return end
 local key=slotKey(b,s);self:Pins()[key]=not self:IsPinned(b,s)and itemID(link)or nil
 self.selected[key]=nil;self:Refresh()
end
function B:IsQuest(b,s)
 local quest,qid=GetContainerItemQuestInfo(b,s)
 return active(quest)or (tonumber(qid)or 0)>0 or select(12,GetItemInfo(GetContainerItemLink(b,s)or 0))==12
end
function B:SetMode(mode)
 if self:Busy()then return end
 self.mode=self.mode~=mode and mode or nil;self.selected={};self:Refresh()
end
function B:Filters(mode)
 GMMLegionDB.bagFilters=GMMLegionDB.bagFilters or {}
 GMMLegionDB.bagFilters[mode]=GMMLegionDB.bagFilters[mode]or {q0=true};return GMMLegionDB.bagFilters[mode]
end
function B:Matches(b,s,mode,filters,selection)
 if self:IsPinned(b,s)then return end
 local link=GetContainerItemLink(b,s);if not link then return end
 local _,count,locked=GetContainerItemInfo(b,s);if active(locked)then return end
 if selection then local v=selection[slotKey(b,s)];if not v or v.link~=link or v.count~=(count or 1)then return end end
 local name,_,quality,_,_,_,_,_,_,_,price,class=GetItemInfo(link)
 if not name or quality==nil then return end
 local quest=self:IsQuest(b,s)
 if mode=='sell'and (quest or not price or price<=0)then return end
 if quest then if not filters.quest then return end
 elseif not filters['q'..quality]and not (filters.consumable and class==0)then return end
 return link,count or 1
end
function B:StopJob(message)
 self.job=nil;self.preview=nil
 if StaticPopup_Hide then StaticPopup_Hide('GMMLEGION_BAG_BULK')end
 if message then A:Print(message)end
 if self:IsShown()then self:Refresh()end
end
function B:StepJob(job)
 if self.job~=job then return end
 if A:Combat()or GetCursorInfo()or (not self:IsShown()and not job.automatic)or (job.automatic and not GMMLegionDB.autoSellJunk)or (job.mode=='sell'and (not merchant()or (InRepairMode and InRepairMode())))then self:StopJob(A:L('bagStopped'));return end
 local now=GetTime()
 if job.pending then
  local v=job.pending;local link=GetContainerItemLink(v.b,v.s);local _,count=GetContainerItemInfo(v.b,v.s)
  if link~=v.link or (count or 1)~=v.count then job.done=job.done+1;job.pending=nil
  elseif now>job.deadline then self:StopJob(A:L('bagStopped'));return end
 end
 if not job.pending then
  local v=job.queue[job.index]
  if not v then self:StopJob(string.format(A:L('bagProcessed'),job.done,job.skipped));return end
  job.index=job.index+1
  local link,count=self:Matches(v.b,v.s,job.mode,job.filters,job.selection)
  if link==v.link and count==v.count then
   -- Selling uses the merchant's cursor-drop path, never an insecure item-use call.
   -- The snapshot and cursor identity are checked immediately before every operation.
   PickupContainerItem(v.b,v.s)
   local kind,id=GetCursorInfo()
   if kind~='item'or id~=itemID(v.link)then if kind then ClearCursor()end;self:StopJob(A:L('bagStopped'));return end
   if job.mode=='sell'then PickupMerchantItem(0)else DeleteCursorItem()end
   if GetCursorInfo()then ClearCursor();self:StopJob(A:L('bagStopped'));return end
   job.pending=v;job.deadline=now+3
  else job.skipped=job.skipped+1 end
 end
 A:After(.15,function()self:StepJob(job)end)
end
function B:QueueBulk(mode)
 if self:Busy()then A:Print(A:L('bagBusy'));return end
 if mode=='sell'and not merchant()then A:Print(A:L('bagNeedMerchant'));return end
 local filters=copy(self:Filters(mode));local selection=self.mode=='select'and copy(self.selected)or nil
 local queue,lines={},{}
 for b=0,4 do for s=1,GetContainerNumSlots(b)do
  local link,count=self:Matches(b,s,mode,filters,selection)
  if link then queue[#queue+1]={b=b,s=s,link=link,count=count};if #lines<8 then lines[#lines+1]=link..' ×'..count end end
 end end
 if #queue==0 then A:Print(A:L('bagNoMatches'));return end
 if #queue>8 then lines[#lines+1]=string.format(A:L('bagMore'),#queue-8)end
 local preview={mode=mode,queue=queue,filters=filters,selection=selection};self.preview=preview
 StaticPopupDialogs.GMMLEGION_BAG_BULK={text=A:L(mode=='sell'and 'bagConfirmSell'or 'bagConfirmDestroy'),button1=A:L(mode=='sell'and 'bagSell'or 'bagDestroy'),button2=A:L('cancel'),timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3,
  OnAccept=function()
   if self.preview~=preview then return end;self.preview=nil
   if self:Busy()or not self:IsShown()or (mode=='sell'and not merchant())then return end
   preview.index=1;preview.done=0;preview.skipped=0;self.job=preview;self.selected={}
   if self.bulkPanel then self.bulkPanel:Hide()end
   self:Refresh();self:StepJob(preview)
  end,
  OnCancel=function()if self.preview==preview then self.preview=nil;self:Refresh()end end,
  OnHide=function()if self.preview==preview then self.preview=nil;self:Refresh()end end}
 StaticPopup_Show('GMMLEGION_BAG_BULK',#queue,table.concat(lines,'\n'));self:Refresh()
end
function B:BulkPanel(mode)
 if self:Busy()then return end
 local p=self.bulkPanel
 if not p then
  p=CreateFrame('Frame','GMMLegionBagConditions',UIParent);self.bulkPanel=p;p:SetSize(350,345);p:SetPoint('CENTER');p:SetFrameStrata('DIALOG');p:EnableMouse(true);p:SetClampedToScreen(true);N:Panel(p)
  p.title=N:Text(p,'',15,-16,320);p.checks={}
  local opts={'q0','q1','q2','q3','q4','q5','q6','q7','quest','consumable'}
  for i,key in ipairs(opts)do
   local quality=key:match('^q(%d)$');local label=quality and A:L('quality'..quality)or A:L('bag'..key)
   local b=N:Check(p,label,12+((i-1)%2)*170,-45-math.floor((i-1)/2)*34,function(on)self:Filters(p.mode)[key]=on end)
   b.label:SetWidth(140);if quality then local r,g,blue=GetItemQualityColor(tonumber(quality));b.label:SetTextColor(r,g,blue)end;p.checks[key]=b
  end
  p.hint=N:Text(p,A:L('bagFilterHint'),15,-222,320,true)
  p.run=N:Button(p,A:L('bagPreview'),15,-305,190,26,function()self:QueueBulk(p.mode)end)
  p.close=N:Button(p,A:L('close'),225,-305,110,26,function()p:Hide()end)
  table.insert(UISpecialFrames,p:GetName())
 end
 p.mode=mode;p.title:SetText(A:L(mode=='sell'and 'bagSellConditions'or 'bagDestroyConditions'))
 for key,b in pairs(p.checks)do b:SetChecked(self:Filters(mode)[key]);b:Enable()end
 if mode=='sell'then p.checks.quest:SetChecked(false);p.checks.quest:Disable()end
 p:Show();p:Raise()
end
local function sortBlocked(f)
 if A:Combat()or GetCursorInfo()or f.job or f.preview or f.mode or f.search:GetText()~=''then return true end
 for _,name in ipairs({'LootFrame','TradeFrame','MailFrame','AuctionFrame','MerchantFrame','BankFrame','GuildBankFrame'})do if _G[name]and _G[name]:IsShown()then return true end end
end
function B:StopSort(message)
 self.sortJob=nil;if message then A:Print(message)end
 if self:IsShown()then self:Refresh()end
end
function B:RequestSort(manual)
 if not manual and not GMMLegionDB.autoSortBags then return end
 if self.sortJob or not self:IsShown()or sortBlocked(self)then return end
 self.selected={};local job={started=GetTime(),moves=0,manual=manual};self.sortJob=job;self:Refresh()
 A:After(.2,function()self:StepSort(job)end)
end
function B:StepSort(job)
 if self.sortJob~=job then return end
 if not self:IsShown()or sortBlocked(self)or GetTime()-job.started>30 or job.moves>400 then self:StopSort(job.manual and A:L('bagStopped'));return end
 if job.pending then
  local p=job.pending
  if itemID(GetContainerItemLink(p.a.b,p.a.s))==p.b.id and itemID(GetContainerItemLink(p.b.b,p.b.s))==p.a.id then job.pending=nil
  elseif GetTime()>p.deadline then self:StopSort(A:L('bagStopped'));return
  else A:After(.15,function()self:StepSort(job)end);return end
 end
 local groups={};local waiting=false
 for b=0,4 do
  local _,family=GetContainerNumFreeSlots(b);family=family or 0;groups[family]=groups[family]or {}
  for s=1,GetContainerNumSlots(b)do if not self:IsPinned(b,s)then
   local link=GetContainerItemLink(b,s);local id=itemID(link);local _,_,locked=GetContainerItemInfo(b,s);local key='\255'
   if active(locked)then waiting=true end
   if id then
    local name,_,_,_,_,class,subclass=GetItemInfo(link)
    if not name or not class or not subclass then waiting=true else key=class..'\031'..subclass..'\031'..name..'\031'..string.format('%010d',id)end
   end
   groups[family][#groups[family]+1]={b=b,s=s,id=id,key=key}
  end end
 end
 if waiting then A:After(.2,function()self:StepSort(job)end);return end
 for _,group in pairs(groups)do for i,a in ipairs(group)do
  local best=i;for j=i+1,#group do if group[j].key<group[best].key then best=j end end
  if best~=i then
   local b=group[best];if not a.id then a,b=b,a end
   PickupContainerItem(a.b,a.s);local kind,id=GetCursorInfo()
   if kind~='item'or id~=a.id then if kind then ClearCursor()end;self:StopSort(A:L('bagStopped'));return end
   PickupContainerItem(b.b,b.s);if GetCursorInfo()then PickupContainerItem(a.b,a.s)end
   if GetCursorInfo()then ClearCursor();self:StopSort(A:L('bagStopped'));return end
   job.moves=job.moves+1;job.pending={a=a,b=b,deadline=GetTime()+3};A:After(.15,function()self:StepSort(job)end);return
  end
 end end
 self:StopSort(job.manual and A:L('bagSorted'))
end
function A:ToggleBags()
 if self:Combat()then self:Print(self:L('combat'),true);return end
 if GMMLegionDB.unifiedBags==false then ToggleAllBags();return end
 local f=self.frames.Bags;if f and f:IsShown()then f:Hide()else self:Show('Bags')end
end
function A:CreateBags()
 local f=N:Frame('Bags',self:L('bags'),384,302);f.slots={};f.offset=0;f.columns=COLUMNS;f.selected={}
 for key,fn in pairs(B)do f[key]=fn end
 if GMMLegionDB.autoSortBags==nil then GMMLegionDB.autoSortBags=true end
 f.title:SetWidth(108)
 f.visibleRows=math.max(3,math.min(12,tonumber(GMMLegionDB.bagRows)or 3))
 if not GMMLegionDB.points.Bags then f:ClearAllPoints();f:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',-8,-65)end
 f:SetScript('OnDragStart',function(s)if not A:Combat()and not GMMLegionDB.bagLocked then s:StartMoving()end end)
 f.viewport=CreateFrame('Frame',nil,f);f.viewport:SetPoint('TOPLEFT',14,-46);f.viewport:SetWidth(COLUMNS*STEP)
 f.viewport:EnableMouseWheel(true);f.viewport:SetScript('OnMouseWheel',function(_,d)f:Scroll(d)end)
 f.select=N:Button(f,self:L('bagSelect'),128,-10,45,22,function()f:SetMode('select')end)
 N:Hint(f.select,self:L('bagSelect'),self:L('bagSelectHint'))
 f.grow=N:Button(f,'▼',180,-10,22,22,function()f:ChangeRows(1)end)
 f.shrink=N:Button(f,'▲',206,-10,22,22,function()f:ChangeRows(-1)end)
 N:Hint(f.grow,self:L('bagGrow'),self:L('bagResizeHint'));N:Hint(f.shrink,self:L('bagShrink'),self:L('bagResizeHint'))
 local function tool(key,texture,x,fn)
  local b=CreateFrame('Button',nil,f);b:SetSize(24,24);b:SetPoint('TOPLEFT',x,-8);b:SetNormalTexture(texture);b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
  b:SetScript('OnClick',fn);local label=N:Text(b,A:L(key),0,-17,28,true);label:SetJustifyH('CENTER');label:SetTextColor(1,.85,.2);return b
 end
 f.destroy=tool('bagDestroy','Interface\\Icons\\INV_Misc_Bone_01',236,function()f:BulkPanel('destroy')end)
 f.sort=tool('bagSort','Interface\\Icons\\INV_Misc_Bag_08',267,function(_,mouse)
  if mouse=='RightButton'then A:SetOption('autoSortBags',not GMMLegionDB.autoSortBags);A:Print(A:L(GMMLegionDB.autoSortBags and 'bagAutoOn'or 'bagAutoOff'));return end
  f:RequestSort(true)
 end);f.sort:RegisterForClicks('LeftButtonUp','RightButtonUp')
 f.sell=tool('bagSell','Interface\\Icons\\INV_Misc_Bag_10_Blue',298,function()f:BulkPanel('sell')end)
 N:Hint(f.destroy,self:L('bagDestroyConditions'),self:L('bagPreview'));N:Hint(f.sell,self:L('bagSellConditions'),self:L('bagNeedMerchant'));N:Hint(f.sort,self:L('sort'),self:L('bagSortHint'))
 f.lock=CreateFrame('Button',nil,f);f.lock:SetSize(22,22);f.lock:SetPoint('TOPRIGHT',-34,-10)
 function f:RefreshLock()self.lock:SetNormalTexture(GMMLegionDB.bagLocked and 'Interface\\Buttons\\LockButton-Locked-Up'or 'Interface\\Buttons\\LockButton-Unlocked-Up')end
 f.lock:RegisterForDrag('LeftButton');f.lock:SetScript('OnMouseDown',function(s)s.dragged=false end)
 f.lock:SetScript('OnDragStart',function(s)if not A:Combat()and not GMMLegionDB.bagLocked then s.dragged=true;f:StartMoving()end end)
 f.lock:SetScript('OnDragStop',function()f:StopMovingOrSizing();A:SavePoint(f,'Bags')end)
 f.lock:SetScript('OnClick',function(s)if s.dragged then s.dragged=false;return end;if not A:Combat()then GMMLegionDB.bagLocked=not GMMLegionDB.bagLocked;f:RefreshLock()end end)
 f:RefreshLock();N:Hint(f.lock,self:L('lockWindow'))
 f.up=N:Button(f,'▲',354,-46,22,23,function()f:Scroll(1)end)
 f.down=N:Button(f,'▼',0,0,22,23,function()f:Scroll(-1)end);f.down:ClearAllPoints();f.down:SetPoint('BOTTOMRIGHT',-8,130)
 f.searchLabel=N:Text(f,self:L('search'),0,0,34,true);f.searchLabel:ClearAllPoints();f.searchLabel:SetPoint('BOTTOMLEFT',14,102)
 f.search=N:Edit(f,0,0,204);f.search:ClearAllPoints();f.search:SetPoint('BOTTOMLEFT',52,93)
 f.pin=N:Button(f,self:L('bagPin'),0,0,94,24,function()f:SetMode('pin')end)
 f.pin:ClearAllPoints();f.pin:SetPoint('BOTTOMRIGHT',-14,93);N:Hint(f.pin,self:L('bagPin'),self:L('bagPinHint'));N:Hint(f.search,self:L('search'),self:L('bagSearchHint'))
 f.status=N:Text(f,'',0,0,354,true);f.status:ClearAllPoints();f.status:SetPoint('BOTTOMLEFT',14,74)
 f.money=N:Text(f,'',0,0,354,true);f.money:ClearAllPoints();f.money:SetPoint('BOTTOMLEFT',14,55)
 f.bagLabel=N:Text(f,self:L('equippedBags'),0,0,150,true);f.bagLabel:ClearAllPoints();f.bagLabel:SetPoint('BOTTOMLEFT',14,23)
 f.empty=N:Text(f,self:L('empty'),12,-62,310,true);f.empty:Hide()
 f.bagButtons={}
 for bag=1,4 do
  local b=CreateFrame('Button',nil,f);b:SetPoint('BOTTOMRIGHT',-18-(4-bag)*40,12);b:SetSize(30,30);N:Panel(b,true)
  local inv,empty=GetInventorySlotInfo('Bag'..(bag-1)..'Slot');b.inv=inv or ContainerIDToInventoryID(bag);b.bag=bag
  b.emptyTexture=empty or 'Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag'
  b.icon=N:Icon(b,b.emptyTexture,2,-2,26)
  b.number=N:Text(b,tostring(bag),0,1,12,true);b.number:SetTextColor(.4,1,1)
  b.count=N:Text(b,'',8,-19,22,true);b.count:SetJustifyH('RIGHT')
  b:RegisterForClicks('LeftButtonUp','RightButtonUp');b:RegisterForDrag('LeftButton')
  local function drop()if not A:Combat()and CursorHasItem()then PutItemInBag(b.inv)end end
  b:SetScript('OnClick',function()if A:Combat()then return end;if CursorHasItem()then drop()elseif ToggleBag then ToggleBag(bag)end end)
  b:SetScript('OnDragStart',function()if not A:Combat()then PickupBagFromSlot(b.inv)end end);b:SetScript('OnReceiveDrag',drop)
  b:SetScript('OnEnter',function(s)
   GameTooltip:SetOwner(s,'ANCHOR_LEFT')
   if not GameTooltip:SetInventoryItem('player',s.inv)then GameTooltip:SetText(A:L('emptyBagSlot')..' '..bag,1,.82,0)end
   local total=GetContainerNumSlots(bag)or 0
   if total>0 then GameTooltip:AddLine(A:L('free')..' '..(GetContainerNumFreeSlots(bag)or 0)..' / '..total,1,1,1)end
   GameTooltip:AddLine(A:L('bagEquipHint'),.3,1,.3,true);GameTooltip:AddLine(A:L('bagClickHint'),.7,.7,.7,true);GameTooltip:Show()
  end)
  b:SetScript('OnLeave',function()GameTooltip:Hide()end);f.bagButtons[bag]=b
 end
 function f:MakeSlot(i)
  local holder=CreateFrame('Frame',nil,self.viewport);holder:SetSize(SIZE,SIZE);holder:SetPoint('TOPLEFT',((i-1)%COLUMNS)*STEP,-math.floor((i-1)/COLUMNS)*STEP)
  -- Inherited Blizzard XML is the secure entry point. Do not wrap OnClick or drag
  -- handlers: that taints potion/food use and loses merchant/bank click behavior.
  local b=CreateFrame('Button','GMMLegionBagItem'..i,holder,'ContainerFrameItemButtonTemplate')
  b.holder=holder;b:SetSize(SIZE,SIZE);b:ClearAllPoints();b:SetPoint('TOPLEFT',0,0);N:Panel(b,true)
  b:SetNormalTexture('Interface\\Buttons\\UI-Quickslot2');b:SetPushedTexture('Interface\\Buttons\\UI-Quickslot-Depress');b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
  for _,key in ipairs({'ExtendedSlot','ExtendedOverlay','ExtendedOverlay2','NewItemTexture','BattlepayItemTexture','flash','UpgradeIcon','JunkIcon','BagStaticTop','BagStaticBottom'})do if b[key]then b[key]:Hide()end end
  b.icon=b.icon or _G[b:GetName()..'IconTexture'];b.cd=_G[b:GetName()..'Cooldown']
  b.overlay=CreateFrame('Frame',nil,b);b.overlay:SetAllPoints(b);b.overlay:SetFrameLevel(b:GetFrameLevel()+3)
  b.countText=_G[b:GetName()..'Count']or b.Count
  b.bagNumber=N:Text(b.overlay,'',0,-24,10,true);b.bagNumber:SetTextColor(.4,1,1)
  b.itemLevel=N:Text(b.overlay,'',0,1,36,true);b.itemLevel:SetJustifyH('CENTER');b.itemLevel:SetTextColor(1,.85,.1)
  b.questMark=N:Icon(b.overlay,'Interface\\GossipFrame\\AvailableQuestIcon',0,-8,20);b.questMark:Hide()
  b.glow=b.overlay:CreateTexture(nil,'OVERLAY');b.glow:SetTexture('Interface\\Buttons\\UI-ActionButton-Border');b.glow:SetBlendMode('ADD');b.glow:SetVertexColor(.1,.5,1);b.glow:SetSize(58,58);b.glow:SetPoint('CENTER');b.glow:Hide()
  local function tip(s)
   if b.bag==nil then return end
   GameTooltip:SetOwner(s,'ANCHOR_LEFT');GameTooltip:SetBagItem(b.bag,b.slot)
   if f:IsPinned(b.bag,b.slot)then GameTooltip:AddLine(A:L('bagPinned'),.3,.7,1,true)end
   if f.mode then GameTooltip:AddLine(A:L(f.mode=='pin'and 'bagPinHint'or 'bagSelectHint'),.3,1,.5,true)end
   GameTooltip:Show()
  end
  b:SetScript('OnEnter',tip)
  b:SetScript('OnLeave',function()GameTooltip:Hide()end)
  b:EnableMouseWheel(true);b:SetScript('OnMouseWheel',function(_,d)f:Scroll(d)end)
  b.guard=CreateFrame('Button',nil,b);b.guard:SetAllPoints(b);b.guard:SetFrameLevel(b:GetFrameLevel()+6);b.guard:RegisterForClicks('LeftButtonUp','RightButtonUp');b.guard:RegisterForDrag('LeftButton')
  b.check=N:Icon(b.guard,'Interface\\Buttons\\UI-CheckBox-Check',1,-1,34);b.check:Hide()
  b.guard:SetScript('OnClick',function(_,mouse)
   if b.bag==nil or A:Combat()or f.job or f.preview or f.sortJob then return end
   if f.mode=='pin'then f:TogglePin(b.bag,b.slot)
   elseif f:IsPinned(b.bag,b.slot)then A:Print(A:L('bagPinned'))
   elseif f.mode=='select'then
    local link=GetContainerItemLink(b.bag,b.slot);local _,count,locked=GetContainerItemInfo(b.bag,b.slot);local key=slotKey(b.bag,b.slot)
    if link and not active(locked)then f.selected[key]=not f.selected[key]and {link=link,count=count or 1}or nil;f:Refresh()end
   elseif mouse=='RightButton'then A:Print(A:L('bagQuestProtected'))end
  end)
  b.guard:SetScript('OnEnter',tip);b.guard:SetScript('OnLeave',function()GameTooltip:Hide()end)
  b.guard:EnableMouseWheel(true);b.guard:SetScript('OnMouseWheel',function(_,d)f:Scroll(d)end)
  -- A transparent native left-click-only sibling protects quest sales while
  -- retaining pickup, links and native dragging at a merchant.
  b.questGuard=CreateFrame('Button',b:GetName()..'QuestGuard',holder,'ContainerFrameItemButtonTemplate')
  b.questGuard:SetAllPoints(b);b.questGuard:SetAlpha(0);b.questGuard:SetFrameLevel(b:GetFrameLevel()+4);b.questGuard:RegisterForClicks('LeftButtonUp');b.questGuard:Hide()
  b.questGuard:HookScript('OnMouseDown',function(_,mouse)if mouse=='RightButton'then A:Print(A:L('bagQuestProtected'))end end)
  b.questGuard:EnableMouseWheel(true);b.questGuard:SetScript('OnMouseWheel',function(_,d)f:Scroll(d)end)
  self.slots[i]=b;return b
 end
 function f:RefreshVisuals()
  for _,b in ipairs(self.slots)do
   if b.bag~=nil then
    local texture,count,locked,quality,readable=GetContainerItemInfo(b.bag,b.slot)
    b.hasItem=texture~=nil;b.count=count;b.readable=readable
    SetItemButtonTexture(b,texture);SetItemButtonCount(b,count or 0);SetItemButtonDesaturated(b,active(locked));b.bagNumber:SetText(texture and tostring(b.bag)or '')
    local link=texture and GetContainerItemLink(b.bag,b.slot)
    local level=link and ((GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(link))or select(4,GetItemInfo(link)))
    b.itemLevel:SetText(level and tostring(level)or '')
    if texture and quality and quality>1 then local r,g,blue=GetItemQualityColor(quality);b:SetBackdropBorderColor(r,g,blue,1)else b:SetBackdropBorderColor(.7,.63,.42,1)end
    local start,duration,enable=GetContainerItemCooldown(b.bag,b.slot);CooldownFrame_Set(b.cd,start or 0,duration or 0,enable or 0)
    local pinned=self:IsPinned(b.bag,b.slot);local quest=texture and self:IsQuest(b.bag,b.slot)
    if pinned then b.glow:Show()else b.glow:Hide()end
    if quest then b.questMark:Show()else b.questMark:Hide()end
    local key=slotKey(b.bag,b.slot);local selected=self.selected[key]
    if selected and (selected.link~=link or selected.count~=(count or 1))then self.selected[key]=nil;selected=nil end
    if self.mode=='pin'and pinned or self.mode=='select'and selected then b.check:Show()else b.check:Hide()end
    if pinned or self.mode or self.job or self.preview or self.sortJob then b.guard:Show();b.questGuard:Hide()
    else b.guard:Hide();if quest and merchant()then b.questGuard:Show()else b.questGuard:Hide()end end
    b.questGuard.hasItem=b.hasItem;b.questGuard.count=count;b.questGuard.readable=readable
   end
  end
  for _,b in ipairs(self.bagButtons)do
   local texture=GetInventoryItemTexture('player',b.inv);b.icon:SetTexture(texture or b.emptyTexture)
   b.count:SetText(texture and tostring(GetContainerNumSlots(b.bag)or 0)or '')
   b.icon:SetDesaturated(IsInventoryItemLocked and active(IsInventoryItemLocked(b.inv))or false)
  end
  self.money:SetText(A:L('money')..': '..GetCoinTextureString(GetMoney()))
  self.select:SetText(A:L(self.mode=='select'and 'bagSelecting'or 'bagSelect'));self.pin:SetText(A:L(self.mode=='pin'and 'bagPinning'or 'bagPin'))
 end
 function f:Layout()
  local maximum=math.max(3,math.min(12,math.floor((UIParent:GetHeight()-204)/STEP)))
  self.visibleRows=math.max(3,math.min(maximum,self.visibleRows));self.capacity=self.visibleRows*COLUMNS
  self.viewport:SetHeight(self.visibleRows*STEP);self:SetHeight(self.visibleRows*STEP+176)
  self.fitHeight=self:GetHeight();N:FitFrame(self)
  if self.visibleRows>3 then self.shrink:Enable()else self.shrink:Disable()end
  if self.visibleRows<maximum then self.grow:Enable()else self.grow:Disable()end
 end
 function f:ChangeRows(delta)
  if A:Combat()then return end
  self.visibleRows=self.visibleRows+delta;self:Layout();GMMLegionDB.bagRows=self.visibleRows;self:Refresh()
 end
 function f:Scroll(delta)
  if A:Combat()then return end
  self.offset=math.max(0,math.min(self.maxOffset or 0,self.offset-delta));self:Refresh()
 end
 function f:Refresh()
  if A:Combat()then self.dirty=true;self:RefreshVisuals();return end
  self.dirty=false;self:Layout()
  local rows={};local free,total=0,0;local query=A:Trim(self.search:GetText()):lower()
  for bag=0,4 do
   local slots=GetContainerNumSlots(bag)or 0;local unused=GetContainerNumFreeSlots(bag)or 0
   free=free+math.max(0,unused);total=total+slots
   for slot=1,slots do
    local link=GetContainerItemLink(bag,slot);local name=link and GetItemInfo(link)or ''
    if query==''or (name and name:lower():find(query,1,true))then rows[#rows+1]={bag=bag,slot=slot}end
   end
  end
  self.maxOffset=math.max(0,math.ceil(#rows/COLUMNS)-self.visibleRows);self.offset=math.min(self.offset,self.maxOffset)
  for i=1,self.capacity do if not self.slots[i]then self:MakeSlot(i)end end
  for i,b in ipairs(self.slots)do
   local r=i<=self.capacity and rows[self.offset*COLUMNS+i]
   if not r or r.bag~=b.bag or r.slot~=b.slot then
    if StackSplitFrame and (StackSplitFrame.owner==b or StackSplitFrame.owner==b.questGuard)then StackSplitFrame:Hide()end
   end
   if r then b.bag,b.slot=r.bag,r.slot;b.holder:SetID(r.bag);b:SetID(r.slot);b.questGuard:SetID(r.slot);b:Show();b.holder:Show()
   else b.bag,b.slot=nil,nil;b.holder:Hide();b:Hide();b.guard:Hide();b.questGuard:Hide()end
  end
  local suffix=query~=''and (' · '..A:L('search')..' '..#rows)or (' · '..A:L('bagWheel'))
  self.status:SetText(A:L('free')..' '..free..' / '..total..suffix)
  if #rows==0 then self.empty:Show()else self.empty:Hide()end
  if self.offset>0 then self.up:Enable()else self.up:Disable()end
  if self.offset<self.maxOffset then self.down:Enable()else self.down:Disable()end
  self:RefreshVisuals()
  if self.mode=='select'then local n=0;for _ in pairs(self.selected)do n=n+1 end;self.status:SetText(A:L('free')..' '..free..' / '..total..' · '..string.format(A:L('bagSelected'),n))end
 end
 f.search:SetScript('OnTextChanged',function()f.offset=0;f:Refresh()end)
 f.search:SetScript('OnEscapePressed',function(s)s:SetText('');s:ClearFocus()end)
 f.search:SetScript('OnEnterPressed',function(s)s:ClearFocus()end)
 f:HookScript('OnHide',function()f.search:ClearFocus();GameTooltip:Hide();f:StopMovingOrSizing();f:StopJob();f:StopSort();f.mode=nil;f.selected={};if f.bulkPanel then f.bulkPanel:Hide()end end)
 f:SetScript('OnShow',function()f:Refresh()end);f:Refresh()
end
local queued=false
local function bagsChanged()
 local f=A.frames.Bags;if not f or not f:IsShown()then return end
 if queued then return end;queued=true
 A:After(.08,function()queued=false;f:Refresh()end)
end
for _,ev in ipairs({'BAG_UPDATE_DELAYED','BAG_UPDATE_COOLDOWN','ITEM_LOCK_CHANGED','PLAYER_MONEY','PLAYER_EQUIPMENT_CHANGED','GET_ITEM_INFO_RECEIVED','PLAYER_REGEN_ENABLED','MERCHANT_SHOW','MERCHANT_CLOSED','DISPLAY_SIZE_CHANGED','UI_SCALE_CHANGED'})do A:On(ev,bagsChanged)end
A:On('BAG_UPDATE_DELAYED',function()
 local f=A.frames.Bags;if not f or not GMMLegionDB.autoSortBags or f.sortJob or f.job then return end
 f.sortGeneration=(f.sortGeneration or 0)+1;local generation=f.sortGeneration
 A:After(.7,function()if f.sortGeneration==generation and GMMLegionDB.autoSortBags then f:RequestSort(false)end end)
end)
A:On('PLAYER_REGEN_DISABLED',function()local f=A.frames.Bags;if f then f:StopJob();f:StopSort()end end)
A:On('MERCHANT_CLOSED',function()local f=A.frames.Bags;if f and (f.preview or f.job)and (f.preview or f.job).mode=='sell'then f:StopJob(A:L('bagStopped'))end end)
-- Keep Blizzard's global bag functions unmodified; override only the user's
-- backpack/all-bags keys, with lower priority than explicit minibar bindings.
local bagBindings=CreateFrame('Frame');local bindingUpdate=false
local bagToggle=CreateFrame('Button','GMMLegionBagToggle',UIParent)
bagToggle:SetSize(1,1);bagToggle:SetPoint('TOPLEFT');bagToggle:SetAlpha(0);bagToggle:EnableMouse(false);bagToggle:RegisterForClicks('AnyUp')
bagToggle:SetScript('OnClick',function()A:ToggleBags()end)
function A:UpdateBagBindings()
 if self:Combat()or bindingUpdate then return end;bindingUpdate=true
 ClearOverrideBindings(bagBindings)
 if GMMLegionDB.unifiedBags~=false then
  for _,action in ipairs({'OPENALLBAGS','TOGGLEBACKPACK'})do
   for _,key in ipairs({GetBindingKey(action)})do SetOverrideBindingClick(bagBindings,false,key,bagToggle:GetName(),'LeftButton')end
  end
 end
 bindingUpdate=false
end
for _,ev in ipairs({'PLAYER_LOGIN','UPDATE_BINDINGS','PLAYER_REGEN_ENABLED'})do A:On(ev,function()A:UpdateBagBindings()end)end
local function showInventoryWithService()
 A:After(.1,function()
  if GMMLegionDB.unifiedBags==false or A:Combat()or not ((MerchantFrame and MerchantFrame:IsShown())or (BankFrame and BankFrame:IsShown()))then return end
  A:Show('Bags')
  for i=1,(NUM_CONTAINER_FRAMES or 13)do
   local frame=_G['ContainerFrame'..i];local bag=frame and frame:GetID()
   if frame and frame:IsShown()and bag>=0 and bag<=4 then frame:Hide()end
  end
 end)
end
A:On('MERCHANT_SHOW',showInventoryWithService);A:On('BANKFRAME_OPENED',showInventoryWithService)
-- Automatic sales always use gray-only eligibility, never the manual sale filter.
-- Wait briefly for uncached items and slot unlocks; never retry a dispatched sale.
function B:TryAutoSell(generation,deadline)
 if self.autoSellGeneration~=generation or not GMMLegionDB.autoSellJunk or not merchant()or A:Combat()then return end
 if self:Busy()or self.mode or (InRepairMode and InRepairMode())then return end
 local queue,waiting={},false;local filters={q0=true}
 for b=0,4 do for s=1,GetContainerNumSlots(b)do
  local link=GetContainerItemLink(b,s)
  if link and not self:IsPinned(b,s)then
   local _,_,locked=GetContainerItemInfo(b,s)
   if not GetItemInfo(link)or active(locked)then waiting=true end
   local item,count=self:Matches(b,s,'sell',filters)
   if item then queue[#queue+1]={b=b,s=s,link=item,count=count}end
  end
 end end
 if waiting and GetTime()<deadline then A:After(.25,function()self:TryAutoSell(generation,deadline)end);return end
 if #queue==0 then return end
 local job={mode='sell',automatic=true,queue=queue,filters=filters,index=1,done=0,skipped=0};self.job=job;self:StepJob(job)
end
A:On('MERCHANT_SHOW',function()
 if not GMMLegionDB.autoSellJunk or A:Combat()then return end
 local f=A.frames.Bags
 if not f then A:CreateBags();f=A.frames.Bags;f:Hide()end
 f.autoSellGeneration=(f.autoSellGeneration or 0)+1;local generation=f.autoSellGeneration
 A:After(.3,function()f:TryAutoSell(generation,GetTime()+10)end)
end)
A:On('MERCHANT_CLOSED',function()local f=A.frames.Bags;if f then f.autoSellGeneration=(f.autoSellGeneration or 0)+1 end end)

