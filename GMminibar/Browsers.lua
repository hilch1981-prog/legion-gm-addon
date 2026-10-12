local A=GMMLegion735;local N=A.UI
function A:DataName(row)
 local lang=(GMMLegionDB.locale=='auto' and GetLocale()) or GMMLegionDB.locale
 return lang=='koKR' and row.ko and row.ko~='' and row.ko or row.name or ''
end
-- Numeric references keep the complete result set small; only visible rows are decoded.
local BASE=16777216
function A:CatalogRow(kind,ref)
 if type(ref)=='table'then return ref end
 local ci=math.floor(ref/BASE);local pos=ref%BASE;local chunk=self.data[kind][ci]
 local line=chunk:sub(pos,(chunk:find('\n',pos,true)or (#chunk+1))-1)
 local f={strsplit('\t',line)};local r={id=tonumber(f[1]),name=f[2],ko=f[3],level=tonumber(f[4])or 0}
 if kind=='spells'then
  r.class=(self.data.playerSpellClasses or {})[r.id]or 0;r.icon=tonumber(f[6]);r.rank=f[7]or ''
 else
  r.itemlevel=tonumber(f[5])or 0;r.quality=tonumber(f[6])or 0;r.class=tonumber(f[7]);r.subclass=tonumber(f[8]);r.icon=tonumber(f[9]);r.mask=tonumber(f[10]);r.bagSlots=tonumber(f[11])
 end
 return r
end
function A:IsInternalItem(name)
 local s=tostring(name or ''):lower()
 for _,p in ipairs({'^zz','^old%d','^old%[','^old[%s_%-:]','^test[%s_%-:]','^qa[%s_%-:]','^deprecated','^unused','^placeholder','^%[ph%]','^%[test%]','^%[unused%]','^%[deprecated%]','^%[dnd%]','^%[internal%]'})do if s:find(p)then return true end end
 return tostring(name):sub(1,3)=='OLD'
end
function A:SearchCatalog(kind,query,options,callback)
 local chunks=self.data[kind]or {};query=self:Trim(query):lower();options=options or {}
 self.searches=self.searches or {};local token={};self.searches[kind]=token
 local ci,pos,results=1,1,{};local exact=tonumber(query)
 local function step()
  if A.searches[kind]~=token then return end
  local count=0
  while ci<=#chunks and count<1800 do
   local chunk=chunks[ci];local finish=chunk:find('\n',pos,true)
   if not finish then ci=ci+1;pos=1
   else
    local start=pos;local id,en,ko,lev=chunk:sub(pos,finish-1):match('^(%d+)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t')
    pos=finish+1;count=count+1;id=tonumber(id);lev=tonumber(lev)or 0
    local mask=(A.data.playerSpellClasses or {})[id]or 0
    local match=id and (query==''or exact==id or (not exact and (en:lower():find(query,1,true)or ko:lower():find(query,1,true))))
    match=match and (not options.maxLevel or lev<=options.maxLevel)and (not options.minLevel or lev>=options.minLevel)
    if match and kind=='spells'then
     match=(not options.class or bit.band(mask,options.class)>0)and (not options.hideKnown or not A:Known(id))and (not options.ids or options.ids[id])
     if options.playerOnly and not exact then match=match and mask>0 end
    end
    if match then
     local ref=ci*BASE+start;local r
     if kind=='items'then
      r=A:CatalogRow(kind,ref)
      match=(not options.class or r.class==options.class)and (not options.subclass or r.subclass==options.subclass)
       and (not options.quality or r.quality==options.quality)and (not options.ids or options.ids[id])
       and (not options.types or options.types[r.class]~=false)and (not options.qualities or options.qualities[r.quality]~=false)
       and (not options.hideInternal or exact or not A:IsInternalItem(en))
     end
     if match then results[#results+1]=options.refs and ref or r or A:CatalogRow(kind,ref)end
    end
   end
  end
  if ci<=#chunks then C_Timer.After(.01,step)else callback(results,#results)end
 end
 step()
end
local icons={'INV_Sword_27','Spell_Holy_SealOfMight','INV_Weapon_Bow_07','INV_ThrowingKnife_04','Spell_Holy_PowerWordShield','Spell_Deathknight_ClassIcon','Spell_Nature_BloodLust','INV_Staff_13','Spell_Nature_Drowsy','Ability_Monk_ChiWave','Ability_Druid_Maul','ClassIcon_DemonHunter'}
local function panel(f,x,y,w,h,title)
 local p=CreateFrame('Frame',nil,f);p:SetPoint('TOPLEFT',x,y);p:SetSize(w,h);N:Panel(p,true)
 if title then N:Text(p,A:L(title),12,-10,w-24)end;return p
end
local function tooltip(b,kind,id)
 GameTooltip:SetOwner(b,'ANCHOR_RIGHT')
 if kind=='spell'then GameTooltip:SetSpellByID(id)else GameTooltip:SetHyperlink('item:'..id)end
 GameTooltip:Show()
end
function A:CreateSpells()
 local f=N:Frame('Spells',self:L('spells'),1080,700);N:Menu(f)
 local _,_,cid=UnitClass('player');f.classMask=2^((cid or 1)-1);f.classes={}
 f.classPanel=panel(f,14,-43,170,638,'class');f.listPanel=panel(f,194,-43,502,638,'spellQuery');f.detailPanel=panel(f,706,-43,350,638,'spellInfo')
 local p=f.listPanel;f.search=N:Edit(p,12,-32,397);f.searchButton=N:Button(p,self:L('search'),419,-32,73,26,function()f:Search()end)
 N:Text(p,self:L('searchFilters'),12,-75,240)
 N:Text(p,self:L('minLevel'),12,-101,82,true);f.minimum=N:Edit(p,95,-94,50,'0');f.minimum:SetNumeric(true)
 N:Text(p,self:L('maxLevel'),155,-101,82,true);f.maximum=N:Edit(p,238,-94,50,'110');f.maximum:SetNumeric(true)
 f.mine=N:Check(p,self:L('myLevel'),10,-125,function()f:Search()end);f.mine.label:SetWidth(133)
 f.hide=N:Check(p,self:L('hideKnown'),175,-125,function()f:Search()end);f.hide.label:SetWidth(175)
 f.reset=N:Button(p,self:L('clear'),412,-125,78,24,function()f.utilityMode=nil;f.utilitySpellIDs=nil;f.search:SetText('');f.minimum:SetText('0');f.maximum:SetText('110');f.mine:SetChecked(false);f.hide:SetChecked(false);f.classMask=nil;f:Search()end)
 for _,e in ipairs({f.search,f.minimum,f.maximum})do e:SetScript('OnEnterPressed',function(s)s:ClearFocus();f:Search()end)end
 f.list=N:List(p,2,-152,498,480,44);f.list:SetBackdrop(nil)
 f.list.resolve=function(ref)return A:CatalogRow('spells',ref)end
 f.list.render=function(b,r)
  local known=A:Known(r.id);b.icon:SetTexture(GetSpellTexture(r.id)or r.icon or 134400)
  b.title:SetText((known and '|cff55bbff'or '|cffffffff')..A:DataName(r)..'|r\n|cff9fcce5'..(known and '['..A:L('known')..'] · 'or '')..'ID: '..r.id..' · '..A:L('learnLevel')..': '..(r.level>0 and r.level or A:L('baseTalent'))..'|r')
 end
 for _,b in ipairs(f.list.rows)do b:SetScript('OnEnter',function(s)if s.entry then tooltip(s,'spell',s.entry.id)end end);b:SetScript('OnLeave',function()GameTooltip:Hide()end)end
 local d=f.detailPanel;f.spellIcon=N:Icon(d,134400,12,-43,40);f.spellName=N:Text(d,self:L('select'),62,-46,272);f.spellName:SetHeight(45)
 f.detail=N:Text(d,'',13,-102,324,true);f.detail:SetHeight(155);f.detail:SetJustifyV('TOP')
 f.learn=N:Button(d,self:L('learn'),14,-276,322,29,nil,true)
 self:SecureAction(f.learn,function()local r=f.selected;if r and not A:Known(r.id)and A:Send('.learn '..r.id)then f.feedback:SetText(A:L('pending'))end end)
 f.unlearn=N:Button(d,self:L('unlearn'),211,-311,125,23,nil,true)
 self:SecureAction(f.unlearn,function()local r=f.selected;if r and A:Known(r.id)then A:Send('.unlearn '..r.id);f.feedback:SetText(A:L('pending'))end end)
 f.feedback=N:Text(d,'',14,-340,322,true);f.feedback:SetHeight(32)
 f.ranks=N:Text(d,self:L('rank'),14,-380,322,true);f.rankButtons={}
 for i=1,6 do
  local b=N:Choice(d,'','Interface\\Icons\\INV_Misc_Book_09',14,-406-(i-1)*30,322,26,function(s)if s.entry then f:Select(s.entry)end end)
  b.icon:Hide();b.label:SetWidth(302);f.rankButtons[i]=b
 end
 function f:Select(r)
  self.selected=r;if not r then self.spellName:SetText(A:L('select'));self.detail:SetText('');self.spellIcon:SetTexture(nil);self.ranks:SetText(A:L('rank'));self.feedback:SetText('');A:SetSecureEnabled(self.learn,false);A:SetSecureEnabled(self.unlearn,false);for _,b in ipairs(self.rankButtons)do b:Hide()end;return end
  self.spellIcon:SetTexture(GetSpellTexture(r.id)or r.icon or 134400);self.spellName:SetText(A:DataName(r))
  local _,_,_,cast,minimum,maximum=GetSpellInfo(r.id)
  self.detail:SetText('ID: '..r.id..'\n\n'..A:L('learnLevel')..': '..(r.level>0 and r.level or A:L('baseTalent'))..'\n\n'..A:L('castTime')..': '..((cast or 0)==0 and A:L('instant')or tostring(cast/1000)..' s')..'\n\n'..A:L('range')..': '..tostring(minimum or 0)..'–'..tostring(maximum or 0)..'\n\n'..A:L(A:Known(r.id)and 'learned'or 'unlearned'))
  A:SetSecureEnabled(self.learn,not A:Known(r.id));A:SetSecureEnabled(self.unlearn,A:Known(r.id));self.feedback:SetText('')
  local groups=A.data.spellRanks or {};local related=groups['g'..tostring(groups[r.id])]or {r};local current=A:L('none')
  for _,entry in ipairs(related)do if A:Known(entry.id)then current=A:DataName({name=entry.rank,ko=entry.rankKo});if current==''then current=A:L('learned')end end end
  self.ranks:SetText(A:L('rank')..' · '..A:L('currentRank')..' '..current)
  for i,b in ipairs(self.rankButtons)do b.entry=related[i];if b.entry then
   local e=b.entry;local rank=A:DataName({name=e.rank or '',ko=e.rankKo});if rank==''then rank=A:L('singleRank')end
   b.label:SetText((A:Known(e.id)and '|cff55bbff'or '|cffffd200')..rank..' · ID '..e.id..'|r');b:SetSelected(e.id==r.id);b:Show()
  else b:Hide()end end
 end
 f.list.onSelect=function(r)f:Select(r)end
 function f:Search()
  local lo,hi=tonumber(self.minimum:GetText()),tonumber(self.maximum:GetText())
  if not lo or not hi or lo<0 or hi>110 or lo>hi then self.feedback:SetText(A:L('badLevels'));return end
  self.search:ClearFocus();self:Select(nil);self.list:SetData({});self.list.status:SetText(A:L('search')..'…')
  self.title:SetText(A:L('spells')..(self.utilityMode and ' · '..A:L(self.utilityMode=='gm'and 'gmskills'or self.utilityMode=='talents'and 'talents'or 'myclass')or ''))
  for _,b in ipairs(self.classes)do b:SetSelected(b.mask==self.classMask)end
  A:SearchCatalog('spells',self.search:GetText(),{refs=true,playerOnly=not self.utilitySpellIDs and self.utilityMode~='gm',ids=self.utilitySpellIDs,class=self.classMask,hideKnown=self.hide:GetChecked(),minLevel=lo,maxLevel=self.mine:GetChecked()and math.min(hi,UnitLevel('player'))or hi},function(rows)self.list:SetData(rows);self.feedback:SetText(self.utilityMode and A:L(self.utilityMode=='talents'and 'talentPickerNote'or 'utilityPickerNote')or '')end)
 end
 local function classButton(label,mask,icon,i,click)
  local b=N:Choice(f.classPanel,label,'Interface\\Icons\\'..icon,11,-38-i*36,148,32,click or function()f.utilityMode=nil;f.utilitySpellIDs=nil;f.classMask=mask;f:Search()end);b.mask=mask;f.classes[#f.classes+1]=b
 end
 classButton(self:L('all'),nil,'INV_Misc_Book_09',0)
 for id,icon in ipairs(icons)do classButton(A:L('class'..id),2^(id-1),icon,id)end
 classButton(self:L('professions'),-1,'INV_Misc_Gear_01',13,function()A:Show('Professions')end)
 N:Button(f.classPanel,self:L('myClass'),11,-598,148,26,function()f.utilityMode=nil;f.utilitySpellIDs=nil;f.classMask=2^((cid or 1)-1);f:Search()end)
 f:Search()
end
function A:OpenUtilityPicker(mode)
 if self:Combat()then self:Print(self:L('combat'),true);return end
 if mode=='professions'then self:Show('Professions');self.frames.Professions.feedback:SetText(self:L('utilityPickerNote'));return end
 self:Show('Spells');local f=self.frames.Spells;local _,_,cid=UnitClass('player')
 f.utilityMode=mode;f.utilitySpellIDs=nil;f.classMask=nil
 if mode=='class'then f.classMask=2^((cid or 1)-1)
 elseif mode=='talents'then
  f.utilitySpellIDs={};local data=self.data.utilitySpells or {}
  local ids=(data.talents or {})[cid or 0]
  for _,id in ipairs(ids or {})do f.utilitySpellIDs[id]=true end
 end
 f.search:SetText('');f.minimum:SetText('0');f.maximum:SetText('110');f.mine:SetChecked(mode=='class');f.hide:SetChecked(false);f:Search()
end
function A:CreateItems()
 local f=N:Frame('Items',self:L('items'),1080,700);N:Menu(f);f.category={};f.expanded={};f.categoryButtons={};f.qualities={}
 N:Icon(f,'Interface\\Icons\\INV_Misc_Bag_08',14,-9,30);f.title:ClearAllPoints();f.title:SetPoint('TOPLEFT',54,-17)
 N:Text(f,self:L('itemHint'),18,-47,1030,true);N:Text(f,self:L('category'),18,-78,205)
 f.categoryScroll=CreateFrame('ScrollFrame',nil,f,'UIPanelScrollFrameTemplate');f.categoryScroll:SetPoint('TOPLEFT',16,-96);f.categoryScroll:SetSize(205,565)
 f.categoryChild=CreateFrame('Frame',nil,f.categoryScroll);f.categoryChild:SetSize(178,565);f.categoryScroll:SetScrollChild(f.categoryChild)
 f.categoryScroll:EnableMouseWheel(true);f.categoryScroll:SetScript('OnMouseWheel',function(s,d)s:SetVerticalScroll(math.max(0,math.min(s:GetVerticalScrollRange(),s:GetVerticalScroll()-d*69)))end)
 N:Text(f,self:L('nameid'),246,-76,80,true);f.search=N:Edit(f,330,-69,401)
 N:Button(f,self:L('search'),740,-69,70,24,function()f:Search()end)
 f.reset=N:Button(f,self:L('clear'),819,-69,70,24,function()f.category={};f.categoryLabel=nil;f.search:SetText('');f.qualities={};f.minimum:SetText('0');f.maximum:SetText('110');f.mine:SetChecked(false);for _,b in ipairs(f.filterChecks)do b:SetChecked(true)end;f:Search();f:RefreshCategories()end)
 f.advancedButton=N:Button(f,self:L('advanced'),898,-69,160,24,function()f.advancedVisible=not f.advancedVisible;f:LayoutFilters()end)
 f.currentLabel=N:Text(f,'',246,-109,810,true)
 f.filters=CreateFrame('Frame',nil,f);f.filters:SetPoint('TOPLEFT',246,-105);f.filters:SetSize(810,88);f.filterChecks={}
 N:Text(f.filters,self:L('quality'),0,-9,65,true)
 for q=0,7 do
  local b=N:Check(f.filters,self:L('quality'..q),66+q*92,-3,function(on)f.qualities[q]=on;f:Search()end);b.label:SetWidth(66);b:SetChecked(true);f.filterChecks[#f.filterChecks+1]=b
 end
 N:Text(f.filters,self:L('minLevel'),0,-44,70,true);f.minimum=N:Edit(f.filters,72,-36,48,'0');f.minimum:SetNumeric(true)
 N:Text(f.filters,self:L('maxLevel'),133,-44,70,true);f.maximum=N:Edit(f.filters,205,-36,48,'110');f.maximum:SetNumeric(true)
 f.mine=N:Check(f.filters,self:L('myLevel'),274,-36,function()f:Search()end)
 f.list=N:List(f,238,-123,826,556,48,2);f.list:SetBackdrop(nil);f.list.resolve=function(ref)return A:CatalogRow('items',ref)end
 f.list.render=function(b,r)
  local _,_,_,hex=GetItemQualityColor(r.quality);b.icon:SetTexture(r.icon or 134400)
  b.title:SetText('|c'..(hex or 'ffffffff')..A:DataName(r)..'|r\n|cff9fcce5ID: '..r.id..' · '..A:L('level')..' '..r.level..' · iLv '..r.itemlevel..'|r')
 end
 for _,b in ipairs(f.list.rows)do b:SetScript('OnEnter',function(s)if s.entry then tooltip(s,'item',s.entry.id)end end);b:SetScript('OnLeave',function()GameTooltip:Hide()end)end
 local popup=N:Frame('ItemQuantity',self:L('add'),370,222);popup:SetFrameStrata('DIALOG');f.quantityPopup=popup
 f.itemName=N:Text(popup,'',18,-48,333);f.itemName:SetHeight(42);f.itemInfo=N:Text(popup,'',18,-92,333,true)
 N:Text(popup,self:L('count'),18,-129,80);f.count=N:Edit(popup,111,-122,230,'1');f.count:SetNumeric(true)
 f.add=N:Button(popup,self:L('add'),18,-169,159,29,nil,true)
 self:SecureAction(f.add,function()
  local r=f.selected;local count=math.floor(tonumber(f.count:GetText())or 0)
  if not r or count<1 or count>1000 then A:Print(A:L('invalid'),true);return end
  if A:Send('.additem '..r.id..' '..count)then popup:Hide();f.note:SetText(A:L('pending'))end
 end)
 N:Button(popup,self:L('cancel'),192,-169,159,29,function()popup:Hide()end);popup:Hide()
 f.note=f.currentLabel
 f.list.onSelect=function(r,mouse)
  if mouse=='RightButton'then A:Send('.lookup item '..r.id);return end
  local link=select(2,GetItemInfo(r.id));if link and HandleModifiedItemClick and HandleModifiedItemClick(link)then return end
  f.selected=r;f.itemName:SetText(A:DataName(r));f.itemInfo:SetText('ID: '..r.id..' · '..A:L('level')..' '..r.level..' · iLv '..r.itemlevel);f.count:SetText('1');A:SetSecureEnabled(f.add,true);popup:Show();N:BringToFront(popup)
 end
 function f:LayoutFilters()
  if self.advancedVisible then self.filters:Show()else self.filters:Hide()end
  self.advancedButton:SetText(A:L(self.advancedVisible and 'hideAdvanced'or 'advanced'))
  self.currentLabel:ClearAllPoints();self.currentLabel:SetPoint('TOPLEFT',246,self.advancedVisible and -176 or -109)
  local h=self.advancedVisible and 489 or 556;self.list:ClearAllPoints();self.list:SetPoint('TOPLEFT',238,self.advancedVisible and -190 or -123);self.list:SetHeight(h)
  self.list.perPage=self.advancedVisible and 16 or 20
  for _,b in ipairs({self.list.prev,self.list.next,self.list.status})do local _,_,_,x=b:GetPoint();b:ClearAllPoints();b:SetPoint('TOPLEFT',x,-h+(b==self.list.status and 25 or 30))end
  self.list:Refresh()
 end
 function f:RefreshCategories()
  local nodes={{label=A:L('all'),category={}}}
  for _,kind in ipairs({'raid','dungeon','sets','weapon','armor','consumable','material','recipe','container','other'})do
   nodes[#nodes+1]={label=(self.expanded[kind]and '− 'or '+ ')..A:L(kind),root=kind}
   if self.expanded[kind]then
    if kind=='raid'or kind=='dungeon'or kind=='sets'then
     for _,g in ipairs(A.data.itemGroups or {})do if g.kind==kind then nodes[#nodes+1]={label='  '..A:DataName(g),category={group=g}}end end
    else
     local id=({weapon=2,armor=4,consumable=0,material=7,recipe=9,container=1})[kind]
     nodes[#nodes+1]={label='  '..A:L('all'),category={class=id,other=kind=='other'}}
     if id and GetItemSubClassInfo then for sub=0,20 do local name=GetItemSubClassInfo(id,sub);if name and name~=''then nodes[#nodes+1]={label='  '..name,category={class=id,subclass=sub}}end end end
    end
   end
  end
  self.categoryChild:SetHeight(math.max(565,#nodes*23+8))
  for i,r in ipairs(nodes)do
   local b=self.categoryButtons[i]
   if not b then b=N:Choice(self.categoryChild,'',nil,2,-(i-1)*23,174,21,function(s)
    if s.node.root then local k=s.node.root;f.expanded[k]=not f.expanded[k];f:RefreshCategories()
    else f.category=s.node.category;f.categoryLabel=s.node.label;f:Search();f:RefreshCategories()end
   end);b.icon:Hide();b.label:SetWidth(158);self.categoryButtons[i]=b end
   b.node=r;b.label:SetText(r.label);b:SetSelected(r.category and ((r.category.group and self.category.group==r.category.group)or (not r.category.group and not self.category.group and r.category.class==self.category.class and r.category.subclass==self.category.subclass and r.category.other==self.category.other)));b:Show()
  end
  for i=#nodes+1,#self.categoryButtons do self.categoryButtons[i]:Hide()end
 end
 function f:Search()
  local lo,hi=tonumber(self.minimum:GetText()),tonumber(self.maximum:GetText());if not lo or not hi or lo<0 or hi>110 or lo>hi then self.note:SetText(A:L('badLevels'));return end
  self.search:ClearFocus();self.note:SetText(A:L('search')..'…');self.list:SetData({})
  local c=self.category;local ids;if c.group then ids={};for _,id in ipairs(c.group.ids)do ids[id]=true end end
  local types;if c.other then types={[0]=false,[1]=false,[2]=false,[4]=false,[7]=false,[9]=false}end
  A:SearchCatalog('items',self.search:GetText(),{refs=true,class=c.class,subclass=c.subclass,ids=ids,types=types,qualities=self.qualities,minLevel=lo,maxLevel=self.mine:GetChecked()and math.min(hi,UnitLevel('player'))or hi,hideInternal=true},function(rows)
   self.list:SetData(rows);self.note:SetText(A:L('currentFilter')..': '..(self.categoryLabel or A:L('all')))
  end)
 end
 for _,e in ipairs({f.search,f.minimum,f.maximum})do e:SetScript('OnEnterPressed',function(s)s:ClearFocus();f:Search()end)end
 self:SetSecureEnabled(f.add,false);f:LayoutFilters();f:RefreshCategories();f:Search()
end
local refreshQueued=false
local function refreshSpells()
 if refreshQueued then return end;refreshQueued=true
 A:After(.2,function()
  refreshQueued=false;local f=A.frames.Spells
  if f and f:IsShown()then if f.selected then f:Select(f.selected)end;if f.hide:GetChecked()then f:Search()else f.list:Refresh()end end
  local p=A.frames.Professions;if p and p:IsShown()then p:Refresh()end
 end)
end
A:On('SPELLS_CHANGED',refreshSpells);A:On('LEARNED_SPELL_IN_TAB',refreshSpells);A:On('SKILL_LINES_CHANGED',refreshSpells);A:On('PLAYER_REGEN_ENABLED',refreshSpells);A:On('NEW_RECIPE_LEARNED',refreshSpells)

