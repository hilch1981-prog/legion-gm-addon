GMMLegion735 = {version='1.0.0',frames={},listeners={},data={},jobs={},toggles={}}
local A=GMMLegion735
local driver=CreateFrame('Frame'); A.driver=driver
function A:On(event,fn)
 if not self.listeners[event] then self.listeners[event]={};if event:sub(1,4)~='GMM_' then driver:RegisterEvent(event) end end
 table.insert(self.listeners[event],fn)
end
function A:Emit(event,...)
 for _,fn in ipairs(self.listeners[event] or {}) do
  local ok,err=pcall(fn,...)
  if not ok then self:Error(event..': '..tostring(err)) end
 end
end
driver:SetScript('OnEvent',function(_,event,...) A:Emit(event,...) end)
function A:Error(err)
 GMMLegionDiagnostics=GMMLegionDiagnostics or {errors={},events={}}
 local log=GMMLegionDiagnostics.errors;log[#log+1]=tostring(err)
 self.sessionErrors=self.sessionErrors or {};self.sessionErrors[#self.sessionErrors+1]=tostring(err)
 if #log>30 then table.remove(log,1) end
 self:Print(tostring(err),true)
end
function A:Print(text,err)
 if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage((err and '|cffff6666' or '|cffffd200')..'GM MINI BAR:|r '..tostring(text)) end
end
function A:After(delay,fn) C_Timer.After(delay,function() local ok,e=pcall(fn);if not ok then A:Error(e) end end) end
function A:Combat() return InCombatLockdown and InCombatLockdown() end
function A:Trim(s) return tostring(s or ''):match('^%s*(.-)%s*$') end
function A:ValidName(s) return type(s)=='string' and #s>0 and #s<50 and not s:find('[%s%c%d%p]') end
function A:PlayerName() return UnitName('player') end
function A:Known(id)
 return (IsSpellKnown and IsSpellKnown(id)) or (IsPlayerSpell and IsPlayerSpell(id)) or false
end
function A:Send(command)
 command=self:Trim(command)
 if command:sub(1,1)~='.' or command:find('[\r\n]') or #command>240 then self:Print(self:L('invalid'),true);return false end
 if not self.ready then return false end
 if UnitIsDeadOrGhost('player') and command:match('^%.revive') then
  SendChatMessage(command,'GUILD')
 else SendChatMessage(command,'SAY') end
 local h=GMMLegionDB.history;table.insert(h,1,{command=command,time=time()});if #h>30 then table.remove(h) end
 self:Emit('GMM_COMMAND_SENT',command)
 return true
end
-- Pure lookup/search callbacks never silently redirect a selected player.
-- Blizzard's SecureActionButtonTemplate performs the hardware self target.
function A:SecureAction(button,callback,right)
 if self:Combat() then return false end
 button:RegisterForClicks('LeftButtonUp','RightButtonUp')
 button:SetAttribute('type1','target');button:SetAttribute('unit1','player')
 if right then button:SetAttribute('type2','target');button:SetAttribute('unit2','target') end
 button:SetScript('PostClick',function(b,mouse)
  if A:Combat() then A:Print(A:L('combat'),true);return end
  if mouse=='LeftButton' and not b.requirePlayer and not UnitIsUnit('target','player') then A:Print(A:L('selfTargetFail'),true);return end
  if mouse=='RightButton' and not right then return end
  callback(b,mouse)
 end)
 return true
end
function A:SetSecureEnabled(button,enabled)
 if self:Combat() then return end
 if enabled then button:Enable() else button:Disable() end
end
function A:RestorePoint(frame,key,point,x,y)
 local p=GMMLegionDB.points[key]
 frame:ClearAllPoints()
 if p then frame:SetPoint(p[1],UIParent,p[1],p[2],p[3]) else frame:SetPoint(point or 'CENTER',UIParent,point or 'CENTER',x or 0,y or 0) end
end
function A:SavePoint(frame,key)
 local p,_,_,x,y=frame:GetPoint();GMMLegionDB.points[key]={p,x,y}
end
function A:Show(key)
 if self:Combat() then self:Print(self:L('combat'),true);return end
 if key=='Bags'and GMMLegionDB.unifiedBags==false then ToggleAllBags();return end
 if ({Travel=true,Items=true,Spells=true,Professions=true,Utilities=true,Commands=true})[key]then
  for k,f in pairs(self.frames)do if k~=key and f.mainWindow then f:Hide()end end
 end
 if key=='Quests' and ToggleQuestLog and (not WorldMapFrame or not WorldMapFrame:IsShown()) then ToggleQuestLog()end
 if self.frames[key] then local f=self.frames[key];if f.mainWindow then self:RestorePoint(f,'main','CENTER',78,0);f:RefreshLock()end;f:Show();self.UI:BringToFront(f);return end
 local fn=self['Create'..key]
 if fn then fn(self) else self:Print(self:L('unavailable'),true) end
end
A:On('ADDON_LOADED',function(name)
 if name~='GMminibar' then return end
 GMMLegionDB=type(GMMLegionDB)=='table' and GMMLegionDB or {}
 local d=GMMLegionDB
 d.schema=1;d.points=d.points or {};d.history=d.history or {};d.favorites=d.favorites or {};d.bindings=d.bindings or {}
 d.scale=math.max(.65,math.min(1.60,tonumber(d.scale) or 1));d.locale=d.locale or 'auto'
 d.windowScale=math.max(.6,math.min(1.1,tonumber(d.windowScale)or 1))
 for key,value in pairs({questCompanion=true,hideCombat=true,unifiedBags=true,autoSortBags=true,autoSellJunk=false})do if d[key]==nil then d[key]=value end end
 GMMLegionDiagnostics=type(GMMLegionDiagnostics)=='table' and GMMLegionDiagnostics or {}
 GMMLegionDiagnostics.errors=GMMLegionDiagnostics.errors or {};GMMLegionDiagnostics.events=GMMLegionDiagnostics.events or {}
 A.ready=true
end)
A:On('PLAYER_LOGIN',function()
 A:CreateMiniBar()
 local ver,build,_,toc=GetBuildInfo()
 A.client={version=ver,build=build,interface=toc,locale=GetLocale()}
 A:Print(A:L('loaded')..' /gmbar')
 if tonumber(toc)~=70300 then A:Print(A:L('wrongVersion'),true) end
end)
SLASH_GMMLEGION1='/gmbar';SLASH_GMMLEGION2='/gmminibar';SLASH_GMMLEGION3='/gmlegion'
SlashCmdList.GMMLEGION=function(text)
 local cmd=A:Trim(text):lower()
 if cmd=='reset' then
  if A:Combat() then return end
  GMMLegionDB.points={};GMMLegionDB.scale=1;A:ResetMiniBar()
 elseif cmd=='bags' then A:Show('Bags')
 elseif cmd=='quest' then A:Show('Quests')
 elseif cmd=='test' then A:RunDiagnostics()
 elseif cmd=='audit' then A:AuditUtilityCommands()
 elseif cmd=='auditstop' then A.utilityAudit=nil
 else A:Show('Utilities') end
end
