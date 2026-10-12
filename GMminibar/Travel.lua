local A=GMMLegion735;local N=A.UI
local diffKeys={[1]='normal',[2]='heroic',[3]='normal',[4]='normal',[5]='heroic',[6]='heroic',[9]='normal',[14]='normal',[15]='heroic',[16]='mythic',[23]='mythic'}
function A:TravelLabel(r)
 local label=self:DataName(r)
 if r.difficulty and r.difficulty>0 then
  label=label..' ('..self:L(diffKeys[r.difficulty]or 'normal')
  if (r.players or 0)>0 then label=label..' '..string.format(self:L('playerCount'),r.players) end
  label=label..')'
 end
 return label
end
function A:Teleport(r)
 if self:Combat() then self:Print(self:L('combat'),true);return end
 if not r or not r.map or not r.x or not r.y or not r.z then return end
 self.travelToken=(self.travelToken or 0)+1;local token=self.travelToken
 local cmd=string.format('.go xyz %.5f %.5f %.5f %d %.5f',r.x,r.y,r.z,r.map,r.o or 0)
 local difficulty=r.difficulty or 0;local get,set
 if r.kind=='dungeon' and difficulty>0 then get,set=GetDungeonDifficultyID,SetDungeonDifficultyID
 elseif r.kind=='raid' and difficulty>=14 then get,set=GetRaidDifficultyID,SetRaidDifficultyID
 elseif r.kind=='raid' and difficulty>=3 and difficulty<=6 then get,set=GetLegacyRaidDifficultyID,SetLegacyRaidDifficultyID end
 local f=self.frames.Travel
 if get and set and get()~=difficulty then
  if IsInGroup()and not UnitIsGroupLeader('player')then self:Print(self:L('difficultyDenied'),true);return end
  set(difficulty);if f then f.note:SetText(self:L('pendingDifficulty'))end
  local tries=0
  local function verify()
   if token~=A.travelToken or A:Combat()then return end
   if get()==difficulty then A:Send(cmd);if f then f.note:SetText(A:L('pending'))end
   elseif tries<30 and not A:Combat()then tries=tries+1;C_Timer.After(.2,verify)
   else A:Print(A:L('difficultyDenied'),true);if f then f.note:SetText(A:L('difficultyDenied'))end end
  end
  C_Timer.After(.2,verify)
 else self:Send(cmd);if f then f.note:SetText(self:L('pending'))end end
end
function A:TravelRegion(r)
 return (self.data.travelRegions or {})[r.id]or r
end
function A:TravelLevel(r)
 return self:TravelRegion(r).level or r.level
end
function A:CreateTravel()
 local f=N:Frame('Travel',self:L('travel'),1080,700);N:Menu(f);f.category=false;f.continent=false;f.sortKey='level';f.ascending=true;f.categoryButtons={}
 N:Icon(f,'Interface\\Icons\\INV_Misc_Map_01',14,-9,30);f.title:ClearAllPoints();f.title:SetPoint('TOPLEFT',54,-17)
 N:Text(f,self:L('travelHint'),54,-41,940,true);N:Text(f,self:L('search'),18,-62,62,true)
 f.search=N:Edit(f,84,-55,521);N:Button(f,self:L('search'),616,-55,80,24,function()f:Search()end)
 f.search:SetScript('OnEnterPressed',function(e)e:ClearFocus();f:Search()end)
 N:Text(f,self:L('continent'),18,-87,80,true)
 local maps={{label=self:L('allRegions'),value=false}};local seen={}
 for _,r in ipairs(self.data.travel)do local meta=self:TravelRegion(r);local name=A:DataName({name=meta.continent,ko=meta.continentKo});if not seen[name]then seen[name]=true;maps[#maps+1]={label=name,value=name}end end
 table.sort(maps,function(a,b)if not a.value then return b.value~=false elseif not b.value then return false else return a.label<b.label end end)
 f.continentDrop=N:DropDown(f,98,-79,174,maps,function(v)f.continent=v;f.zone=false;f:UpdateZones();f:Search()end)
 N:Text(f,self:L('areaCity'),291,-87,105,true)
 f.zoneDrop=N:DropDown(f,400,-79,217,{{label=self:L('all'),value=false}},function(v)f.zone=v;f:Search()end)
 f.factionOnly=N:Check(f,self:L('myFaction'),899,-79,function()f:Search()end);f.factionOnly.label:SetWidth(120)
 for i,key in ipairs({'all','zone','city','dungeon','raid','battleground'})do
  local b=N:Choice(f,self:L(key),nil,14+(i-1)*99,-122,92,24,function()f.category=key=='all'and false or key;f:Search()end)
  b.icon:Hide();b.label:SetWidth(76);b.label:SetJustifyH('CENTER');b.key=key;f.categoryButtons[i]=b
 end
 f.favorite=N:Check(f,self:L('mapFavorites'),862,-121,function()f:Search()end);f.favorite.label:SetWidth(153)
 f.reset=N:Button(f,self:L('clear'),754,-122,98,24,function()f.category=false;f.continent=false;f.zone=false;f.sortKey='level';f.ascending=true;f.search:SetText('');f.favorite:SetChecked(false);f.factionOnly:SetChecked(false);f.continentDrop:SetValue(false,true);f.note:SetText(A:L('travelClick'));f:UpdateZones();f:Search()end)
 local columns={{'favorite',26},{'continent',116},{'areaCity',174},{'destination',390},{'type',98},{'recommendedLevel',116},{'faction',106}};f.headers={}
 local x=27
 for i,c in ipairs(columns)do
  local key=c[1];local b=N:Button(f,key=='favorite'and '★'or self:L(key),x,-155,c[2]-6,18,function()
   if f.sortKey==key or (key=='recommendedLevel'and f.sortKey=='level')then f.ascending=not f.ascending;f.sortKey=key else f.sortKey=key;f.ascending=true end;f:Search()
  end);f.headers[i]=b;x=x+c[2]
 end
 f.list=N:List(f,14,-173,1052,505,26,1,true);f.list:SetBackdrop(nil)
 for _,b in ipairs(f.list.rows)do
  b.icon:Hide();b.title:Hide();b.cells={};local cx=5
  for i,c in ipairs(columns)do b.cells[i]=N:Text(b,'',cx,-4,c[2]-6,true);b.cells[i]:SetHeight(16);cx=cx+c[2]end
  b:SetAttribute('type1','macro');b:SetAttribute('macrotext1','/dismount')
  b:SetScript('OnEnter',function(s)if s.entry then local r=s.entry;GameTooltip:SetOwner(s,'ANCHOR_RIGHT');GameTooltip:SetText(A:TravelLabel(r));GameTooltip:AddLine(A:L(r.kind),1,1,1);GameTooltip:AddLine(A:L('travelClick'),.7,.85,1,true);GameTooltip:Show()end end)
  b:SetScript('OnLeave',function()GameTooltip:Hide()end)
 end
 f.list.render=function(b,r)
  local meta=A:TravelRegion(r);local level=A:TravelLevel(r);local above=level>UnitLevel('player');local color=above and '|cffff5555'or '|cffffffff'
  local values={GMMLegionDB.favorites[r.id]and '|cffffd200★|r'or '☆',A:DataName({name=meta.continent,ko=meta.continentKo}),A:DataName({name=meta.zone,ko=meta.zoneKo}),A:TravelLabel(r),A:L(r.kind),tostring(level),A:L(r.faction)}
  for i,v in ipairs(values)do b.cells[i]:SetText((i==2 or i==3 or i==4 or i==6)and color..v..'|r'or v)end
 end
 f.list.onSelect=function(r,mouse)
  if A:Combat()then A:Print(A:L('combat'),true);return end
  if mouse=='RightButton'then GMMLegionDB.favorites[r.id]=not GMMLegionDB.favorites[r.id];f:Search();return end
  f.selected=r;A:Teleport(r)
 end
 f.note=N:Text(f,self:L('travelClick'),200,-641,650,true);f.note:SetHeight(18)
 function f:UpdateZones()
  local values={{label=A:L('all'),value=false}};local found={}
  for _,r in ipairs(A.data.travel)do
   local meta=A:TravelRegion(r);local continent=A:DataName({name=meta.continent,ko=meta.continentKo});local name=A:DataName({name=meta.zone,ko=meta.zoneKo})
   if name~=''and (not self.continent or continent==self.continent)and not found[name]then found[name]=true;values[#values+1]={label=name,value=name}end
  end
  table.sort(values,function(a,b)if not a.value then return b.value~=false elseif not b.value then return false else return a.label<b.label end end)
  self.zoneDrop:SetValues(values);self.zoneDrop:SetValue(false,true)
 end
 function f:SortValue(r,key)
  local m=A:TravelRegion(r)
  if key=='favorite'then return GMMLegionDB.favorites[r.id]and 0 or 1
  elseif key=='level'or key=='recommendedLevel'then return A:TravelLevel(r)
  elseif key=='continent'then return A:DataName({name=m.continent,ko=m.continentKo})
  elseif key=='areaCity'then return A:DataName({name=m.zone,ko=m.zoneKo})
  elseif key=='destination'then return A:TravelLabel(r)
  elseif key=='type'then return A:L(r.kind)
  elseif key=='faction'then return A:L(r.faction)end
  return r.level
 end
 function f:Search()
  local rows={};local q=A:Trim(self.search:GetText()):lower();local faction=(UnitFactionGroup('player')or ''):lower()
  for _,r in ipairs(A.data.travel)do
   local m=A:TravelRegion(r);local continent=A:DataName({name=m.continent,ko=m.continentKo});local zone=A:DataName({name=m.zone,ko=m.zoneKo})
   local category=not self.category or self.category==r.kind or (self.category=='zone'and (r.kind=='flight'or r.kind=='inn'or r.kind=='classhall'))
   local words=(r.name..' '..r.ko..' '..continent..' '..zone..' '..A:L(r.kind)..' '..A:TravelLabel(r)):lower()
   if category and (not self.continent or self.continent==continent)and (not self.zone or self.zone==zone)
    and (not self.favorite:GetChecked()or GMMLegionDB.favorites[r.id])and (not self.factionOnly:GetChecked()or r.faction=='neutral'or r.faction==faction)
    and (q==''or words:find(q,1,true))then rows[#rows+1]=r end
  end
  table.sort(rows,function(a,b)local va,vb=self:SortValue(a,self.sortKey),self:SortValue(b,self.sortKey);if va~=vb then if self.ascending then return va<vb else return va>vb end end;local la,lb=A:TravelLevel(a),A:TravelLevel(b);if la~=lb then return la<lb end;local na,nb=A:TravelLabel(a),A:TravelLabel(b);if na~=nb then return na<nb end;return a.id<b.id end)
  for _,b in ipairs(self.categoryButtons)do b:SetSelected(b.key==(self.category or 'all'))end
  for i,b in ipairs(self.headers)do local key=columns[i][1];b:SetText((key=='favorite'and '★'or A:L(key))..((key==self.sortKey or key=='recommendedLevel'and self.sortKey=='level')and (self.ascending and ' ▲'or ' ▼')or ''))end
  self.list:SetData(rows)
 end
 f:UpdateZones();f:Search()
end

