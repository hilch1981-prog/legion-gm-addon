local A=GMMLegion735
local N={};A.UI=N
local window={bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Border',tile=true,tileSize=32,edgeSize=24,insets={left=7,right=7,top=7,bottom=7}}
local inset={bgFile='Interface\\ChatFrame\\ChatFrameBackground',edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',tile=true,tileSize=16,edgeSize=12,insets={left=3,right=3,top=3,bottom=3}}
function N:Panel(f,inner)
 f:SetBackdrop(inner and inset or window);f:SetBackdropColor(.025,.035,.045,1);f:SetBackdropBorderColor(.7,.63,.42,1)
end
function N:Text(parent,text,x,y,width,small)
 local f=parent:CreateFontString(nil,'OVERLAY',small and 'GameFontHighlightSmall' or 'GameFontNormal')
 f:SetPoint('TOPLEFT',parent,'TOPLEFT',x or 0,y or 0);if width then f:SetWidth(width) end
 f:SetJustifyH('LEFT');f:SetText(text or '');return f
end
function N:Button(parent,text,x,y,width,height,callback,secure,name)
 local b=CreateFrame('Button',name,parent,secure and 'UIPanelButtonTemplate,SecureActionButtonTemplate' or 'UIPanelButtonTemplate')
 b:SetPoint('TOPLEFT',parent,'TOPLEFT',x or 0,y or 0);b:SetSize(width or 100,height or 24);b:SetText(text or '')
 if callback then b:SetScript('OnClick',callback) end
 return b
end
function N:Edit(parent,x,y,width,text)
 local e=CreateFrame('EditBox',nil,parent);e:SetSize(width,25);e:SetPoint('TOPLEFT',x,y);N:Panel(e,true)
 e:SetFontObject(ChatFontNormal);e:SetTextInsets(6,6,0,0);e:SetAutoFocus(false);e:SetMaxLetters(120)
 e:SetScript('OnEscapePressed',function(s)s:ClearFocus()end);e:SetText(text or '');return e
end
function N:Check(parent,text,x,y,fn)
 local b=CreateFrame('CheckButton',nil,parent,'UICheckButtonTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(24,24)
 b.label=N:Text(b,text,27,-5,215,true);b:SetScript('OnClick',function(s)fn(s:GetChecked() and true or false)end);return b
end
function N:Hint(b,title,body)
 b:SetScript('OnEnter',function(s)GameTooltip:SetOwner(s,'ANCHOR_RIGHT');GameTooltip:SetText(title,1,.82,0);if body then GameTooltip:AddLine(body,1,1,1,true)end;GameTooltip:Show()end)
 b:SetScript('OnLeave',function()GameTooltip:Hide()end)
end
function N:Icon(parent,texture,x,y,size)
 local t=parent:CreateTexture(nil,'ARTWORK');t:SetPoint('TOPLEFT',x,y);t:SetSize(size or 24,size or 24);t:SetTexture(texture or 134400);t:SetTexCoord(.07,.93,.07,.93);return t
end
function N:FitFrame(f)
 local wanted=f.mainWindow and (GMMLegionDB.windowScale or 1)or 1
 local widthLimit,heightLimit=(UIParent:GetWidth()-175)/f.fitWidth,(UIParent:GetHeight()-28)/f.fitHeight
 f:SetScale(math.min(wanted*math.min(1,widthLimit,heightLimit),widthLimit,heightLimit))
end
local combatWindows=CreateFrame('Frame','GMMLegionCombatWindows',UIParent,'SecureHandlerStateTemplate')
combatWindows:SetAllPoints(UIParent);N.combatWindows=combatWindows
function N:ApplyCombatVisibility()
 if A:Combat()then return end
 if GMMLegionDB.hideCombat then RegisterStateDriver(combatWindows,'visibility','[combat] hide; show')
 else UnregisterStateDriver(combatWindows,'visibility');combatWindows:Show()end
end
A:On('PLAYER_LOGIN',function()N:ApplyCombatVisibility()end)
function N:BringToFront(f)
 local level=10
 for _,other in pairs(A.frames)do if other~=f then level=math.max(level,other:GetFrameLevel()+20)end end
 f:SetFrameLevel(level);f:Raise()
end
local function fitWindows()
 if A:Combat()then return end
 for _,f in pairs(A.frames)do if f.fitWidth then N:FitFrame(f)end end
end
A:On('DISPLAY_SIZE_CHANGED',fitWindows);A:On('UI_SCALE_CHANGED',fitWindows);A:On('PLAYER_REGEN_ENABLED',fitWindows)
function N:Frame(key,title,width,height)
 local gmWindow=(width or 1080)>=1000 or key=='Settings'or key=='Quests'or key=='Difficulty'or key=='NamePrompt'
 local f=CreateFrame('Frame','GMMLegion'..key,gmWindow and combatWindows or UIParent);f:SetSize(width or 1080,height or 700);f:SetFrameStrata('HIGH');f:SetClampedToScreen(true);N:Panel(f)
 f:SetToplevel(true)
 f.fitWidth=width or 1080;f.fitHeight=height or 700
 f:SetMovable(true);f:EnableMouse(true);f:RegisterForDrag('LeftButton')
 f.mainWindow=(width or 1080)>=1000
 f:SetScript('OnDragStart',function(s)if not A:Combat() and not (s.mainWindow and GMMLegionDB.windowLocked) then s:StartMoving()end end)
 f:SetScript('OnDragStop',function(s)s:StopMovingOrSizing();A:SavePoint(s,s.mainWindow and 'main' or key)end)
 f.title=N:Text(f,title,18,-16,(width or 1080)-80)
 f.close=CreateFrame('Button',nil,f,'UIPanelCloseButton');f.close:SetPoint('TOPRIGHT',-4,-4);f.close:SetScript('OnClick',function()if not A:Combat() then f:Hide()end end)
 if f.mainWindow then
  f.lock=N:Button(f,'',-51,-8,22,23,function()GMMLegionDB.windowLocked=not GMMLegionDB.windowLocked;f:RefreshLock()end)
  f.lock:ClearAllPoints();f.lock:SetPoint('TOPRIGHT',-37,-8)
  f.lock.icon=N:Icon(f.lock,'Interface\\Buttons\\LockButton-Unlocked-Up',1,-1,20)
  function f:RefreshLock()self.lock.icon:SetTexture(GMMLegionDB.windowLocked and 'Interface\\Buttons\\LockButton-Locked-Up' or 'Interface\\Buttons\\LockButton-Unlocked-Up')end
  f:RefreshLock();N:Hint(f.lock,A:L('lockWindow'))
 end
 A:RestorePoint(f,f.mainWindow and 'main' or key,'CENTER',f.mainWindow and 78 or 0,0)
 N:FitFrame(f)
 A.frames[key]=f
 -- The quest helper contains a secure completion button and follows the map.
 -- Blizzard's generic Escape list can call Hide in combat even while its
 -- combat parent is already hidden. Let the guarded map hook close it instead.
 if key~='Quests'then table.insert(UISpecialFrames,f:GetName())end
 N:BringToFront(f)
 return f
end
local menu={{'travel','Travel'},{'items','Items'},{'spells','Spells'},{'professions','Professions'},{'utilities','Utilities'},{'commands','Commands'},{'island','Island'}}
function N:Menu(owner)
 local m=CreateFrame('Frame',nil,owner);m:SetSize(154,247);N:Panel(m);m:SetPoint('TOPRIGHT',owner,'TOPLEFT',0,0)
 local label=N:Button(m,A:L('menuCaption'),7,-6,76,24);label:Disable();label:SetAlpha(.45);m.caption=label
 local gear=CreateFrame('Button',nil,m);gear:SetPoint('TOPRIGHT',-7,-6);gear:SetSize(25,25);gear:SetNormalTexture('Interface\\Icons\\INV_Misc_Gear_01');gear:SetScript('OnClick',function()A:Show('Settings')end);m.gear=gear
 N:Hint(gear,A:L('settings'));m.buttons={}
 for i,v in ipairs(menu) do
  local key,dest=v[1],v[2]
  local b=N:Button(m,A:L(key),7,-36-(i-1)*29,140,26,function()
   if A:Combat() then return end
   if dest=='Island' then A:GoIsland();return end
   owner:Hide();A:Show(dest)
  end);m.buttons[dest]=b
 end
 owner.menu=m
end
function N:Card(parent,label,texture,x,y,width,height,secure)
 local b=CreateFrame('Button',nil,parent,secure and 'SecureActionButtonTemplate' or nil);b:SetPoint('TOPLEFT',x,y);b:SetSize(width,height);N:Panel(b,true)
 b.icon=N:Icon(b,texture,width-43,-(height-30)/2,30)
 b.label=N:Text(b,label,14,-(height-14)/2,width-68)
 b:SetHighlightTexture('Interface\\QuestFrame\\UI-QuestTitleHighlight','ADD')
 return b
end
function N:List(parent,x,y,width,height,rowheight,columns,secure)
 columns=columns or 1
 local f=CreateFrame('Frame',nil,parent);f:SetPoint('TOPLEFT',x,y);f:SetSize(width,height);N:Panel(f,true);f.rows={};f.page=1;f.data={};f.columns=columns;f.perPage=math.floor((height-62)/rowheight)*columns
 local rw=(width-16-(columns-1)*10)/columns
 for i=1,f.perPage do
  local b=CreateFrame('Button',nil,f,secure and 'SecureActionButtonTemplate' or nil);b:SetPoint('TOPLEFT',8+((i-1)%columns)*(rw+10),-8-math.floor((i-1)/columns)*rowheight);b:SetSize(rw,rowheight-4);N:Panel(b,true)
  b.icon=N:Icon(b,134400,5,-5,math.min(34,rowheight-14));b.title=N:Text(b,'',rowheight-3,-5,rw-rowheight-8,true);b.title:SetHeight(rowheight-12)
  b:SetHighlightTexture('Interface\\QuestFrame\\UI-QuestTitleHighlight','ADD')
  b:SetScript(secure and 'PostClick' or 'OnClick',function(_,mouse)if b.entry and f.onSelect then f.onSelect(b.entry,mouse)end end);b:RegisterForClicks('LeftButtonUp','RightButtonUp');f.rows[i]=b
 end
 f.prev=N:Button(f,A:L('previous'),8,-height+30,80,22,function()f.page=math.max(1,f.page-1);f:Refresh()end)
 f.next=N:Button(f,A:L('next'),width-88,-height+30,80,22,function()f.page=math.min(math.max(1,math.ceil(#f.data/f.perPage)),f.page+1);f:Refresh()end)
 f.status=N:Text(f,'',95,-height+25,width-190,true);f.status:SetJustifyH('CENTER')
 function f:Refresh()
  local pages=math.max(1,math.ceil(#self.data/self.perPage));self.page=math.min(self.page,pages)
  for i,b in ipairs(self.rows) do
   local entry=i<=self.perPage and self.data[(self.page-1)*self.perPage+i];b.entry=entry and (self.resolve and self.resolve(entry) or entry)
   if b.entry then b:Show();if self.render then self.render(b,b.entry)end else b:Hide()end
  end
  self.status:SetText(#self.data..'  ·  '..self.page..' / '..pages)
  if self.page>1 then self.prev:Enable() else self.prev:Disable()end
  if self.page<pages then self.next:Enable() else self.next:Disable()end
 end
 function f:SetData(data)self.data=data or {};self.page=1;self:Refresh()end
 f:EnableMouseWheel(true);f:SetScript('OnMouseWheel',function(s,d)s.page=math.max(1,math.min(math.max(1,math.ceil(#s.data/s.perPage)),s.page-d));s:Refresh()end)
 return f
end
function N:Choice(parent,text,icon,x,y,width,height,callback)
 local b=N:Card(parent,text,icon,x,y,width,height,false)
 b.icon:ClearAllPoints();b.icon:SetPoint('RIGHT',-5,0);b.icon:SetSize(height-8,height-8)
 b.label:ClearAllPoints();b.label:SetPoint('LEFT',8,0);b.label:SetWidth(width-height-6);b.label:SetFontObject(GameFontHighlightSmall)
 b:SetScript('OnClick',callback)
 function b:SetSelected(on)self:SetBackdropBorderColor(on and 1 or .4,on and .82 or .4,on and .1 or .4,1)end
 return b
end
-- A selectable dropdown, never a hidden sequence of cycle-button states.
function N:DropDown(parent,x,y,width,values,fn)
 local b=CreateFrame('Button',nil,parent);b:SetPoint('TOPLEFT',x,y);b:SetSize(width,24);N:Panel(b,true)
 b.label=N:Text(b,'',8,-5,width-29,true);N:Text(b,'▼',width-22,-5,18,true);b.values=values;b.value=false
 function b:Refresh()
  local name=A:L('all');for _,v in ipairs(self.values)do if v.value==self.value then name=v.label;break end end;self.label:SetText(name)
 end
 function b:SetValues(v)self.values=v;self:Refresh()end
 function b:SetValue(v,silent)self.value=v or false;self:Refresh();if not silent then fn(self.value)end end
 b:SetScript('OnClick',function()
  if b.popup and b.popup:IsShown()then b.popup:Hide();return end
  if N.openDropdown then N.openDropdown:Hide()end
  if not b.popup then
   local p=CreateFrame('Frame',nil,b);b.popup=p;p:SetPoint('TOPLEFT',b,'BOTTOMLEFT',0,-2);p:SetSize(width,276);p:SetFrameStrata('TOOLTIP');p:SetClampedToScreen(true);p:EnableMouse(true);N:Panel(p,true);p.buttons={}
   for i=1,11 do local entry=N:Button(p,'',4,-4-(i-1)*24,width-8,23,function(s)if s.option then b:SetValue(s.option.value);p:Hide()end end);p.buttons[i]=entry end
   function p:Refresh()
    for i,v in ipairs(self.buttons)do v.option=b.values[self.offset+i];if v.option then v:SetText(v.option.label);v:Show()else v:Hide()end end
    self:SetHeight(math.min(11,#b.values)*24+8)
   end
   p:EnableMouseWheel(true);p:SetScript('OnMouseWheel',function(s,d)s.offset=math.max(0,math.min(math.max(0,#b.values-11),s.offset-d*3));s:Refresh()end)
  end
  N.openDropdown=b.popup;b.popup.offset=0;b.popup:Refresh();b.popup:Show()
 end)
 parent:HookScript('OnHide',function()if b.popup then b.popup:Hide()end end);b:Refresh();return b
end
function N:Cycle(parent,label,values,x,y,width,fn)
 local b=N:Button(parent,'',x,y,width,25);b.index=1
 function b:Refresh()self:SetText(label..': '..tostring(values[self.index].label))end
 b:RegisterForClicks('LeftButtonUp','RightButtonUp');b:SetScript('OnClick',function(s,mouse)s.index=((s.index-1+(mouse=='RightButton' and -1 or 1))%#values)+1;s:Refresh();fn(values[s.index].value)end);b:Refresh();return b
end
function A:RefreshSettings()
 local f=self.frames.Settings;if f then f:Refresh()end
end
function A:SetOption(key,value)
 if self:Combat()then self:Print(self:L('combat'),true);self:RefreshSettings();return false end
 if key=='autoLoot'then SetCVar('autoLootDefault',value and '1'or '0')
 elseif key=='windowScale'or key=='scale'then
  local low,high=key=='scale'and .65 or .6,key=='scale'and 1.6 or 1.1
  GMMLegionDB[key]=math.floor(math.max(low,math.min(high,tonumber(value)or 1))*100+.5)/100
  if key=='scale'then if self.mini then self.mini:SetScale(GMMLegionDB.scale)end else fitWindows()end
 elseif key=='questCompanion'or key=='hideCombat'or key=='unifiedBags'or key=='autoSortBags'or key=='autoSellJunk'then
  GMMLegionDB[key]=value and true or false
  if key=='questCompanion'then self:UpdateQuestCompanion()
  elseif key=='hideCombat'then N:ApplyCombatVisibility()
  elseif key=='unifiedBags'then
   local bags=self.frames.Bags;if bags then bags:Hide()end;self:UpdateBagBindings()
  elseif key=='autoSortBags'then
   local bags=self.frames.Bags;if bags then if value then bags:RequestSort(false)else bags:StopSort()end end
  elseif key=='autoSellJunk'and not value then
   local bags=self.frames.Bags;if bags then bags.autoSellGeneration=(bags.autoSellGeneration or 0)+1;if bags.job and bags.job.automatic then bags:StopJob()end end
  end
 else return false end
 self:RefreshSettings();return true
end
function A:RestoreWindowPositions()
 if self:Combat()then return end
 GMMLegionDB.points.main=nil;GMMLegionDB.points.Bags=nil;GMMLegionDB.windowLocked=false;GMMLegionDB.bagLocked=false
 for _,f in pairs(self.frames)do if f.mainWindow then self:RestorePoint(f,'main','CENTER',78,0);f:RefreshLock()end end
 local bags=self.frames.Bags;if bags then bags:ClearAllPoints();bags:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',-8,-65);bags:RefreshLock()end
 self:RefreshSettings()
end
function A:CreateSettings()
 local f=N:Frame('Settings',self:L('settings'),400,535);f:SetFrameStrata('DIALOG');f.checks={};f.languageButtons={}
 N:Text(f,self:L('language'),18,-49,330,true)
 for i,v in ipairs({{'auto','AUTO'},{'koKR','한국어'},{'enUS','English'}})do
  local code=v[1];local b=N:Button(f,v[2],18+(i-1)*124,-70,116,25,function()
   if A:Combat()then return end;GMMLegionDB.locale=code;f:Refresh();f.note:SetText(A:L('languageReload'))
  end);f.languageButtons[code]=b
 end
 local function scaleRow(key,label,y)
  N:Text(f,A:L(label),18,y,150,true);local number=N:Text(f,'',170,y,122,true)
  local less=N:Button(f,'−',299,y+5,34,25,function()A:SetOption(key,GMMLegionDB[key]-.05)end)
  local more=N:Button(f,'+',342,y+5,34,25,function()A:SetOption(key,GMMLegionDB[key]+.05)end)
  return {value=number,less=less,more=more}
 end
 f.windowScale=scaleRow('windowScale','settingsWindowScale',-115);f.miniScale=scaleRow('scale','settingsMiniScale',-151)
 local rows={{'questCompanion','settingsQuest'},{'hideCombat','settingsCombat'},{'autoLoot','settingsLoot'},{'autoSortBags','settingsSort'},{'unifiedBags','settingsBags'},{'autoSellJunk','settingsSell'}}
 for i,r in ipairs(rows)do local key=r[1]
  local b=N:Check(f,self:L(r[2]),18,-183-(i-1)*33,function(on)A:SetOption(key,on)end);b.label:SetWidth(key=='autoSortBags'and 230 or 333);f.checks[key]=b
  N:Hint(b,self:L(r[2]),self:L(r[2]..'Hint'))
 end
 f.sortNow=N:Button(f,self:L('settingsSortNow'),282,-284,96,24,function()
  if A:Combat()then return end
  if GMMLegionDB.unifiedBags==false then SortBags();return end
  A:Show('Bags');A.frames.Bags:RequestSort(true)
 end)
 f.restore=N:Button(f,self:L('settingsRestore'),18,-391,360,26,function()A:RestoreWindowPositions()end)
 f.reload=N:Button(f,self:L('reload'),18,-430,174,25,function()if not A:Combat()then ReloadUI()end end)
 f.diagnostics=N:Button(f,self:L('diagnostics'),204,-430,174,25,function()A:RunDiagnostics()end)
 f.note=N:Text(f,self:L('settingsImmediate'),18,-472,362,true);f.note:SetHeight(46)
 function f:Refresh()
  for key,b in pairs(self.checks)do b:SetChecked(key=='autoLoot'and GetCVar('autoLootDefault')=='1'or key~='autoLoot'and GMMLegionDB[key]==true)end
  for code,b in pairs(self.languageButtons)do if code==GMMLegionDB.locale then b:Disable()else b:Enable()end end
  self.windowScale.value:SetText(string.format('%d%%',GMMLegionDB.windowScale*100+.5));self.miniScale.value:SetText(string.format('%d%%',GMMLegionDB.scale*100+.5))
 end
 f:SetScript('OnShow',function()f:Refresh()end);f:Refresh()
end
A:On('CVAR_UPDATE',function()local f=A.frames.Settings;if f and f:IsShown()then f:Refresh()end end)
