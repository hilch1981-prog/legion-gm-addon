local A=GMMLegion735
function A:RunDiagnostics()
 local report={version=self.version,time=time(),client=self.client or {},checks={},errors=GMMLegionDiagnostics.errors or {},sessionErrors=self.sessionErrors or {},gameActionsVerified=false}
 local function check(name,ok,detail)report.checks[#report.checks+1]={name=name,ok=ok and true or false,detail=detail}end
 check('Client Interface 70300',select(4,GetBuildInfo())==70300)
 for _,name in ipairs({'GetProfessions','GetProfessionInfo','SetDungeonDifficultyID','GetDungeonDifficultyID','SetRaidDifficultyID','SetLegacyRaidDifficultyID','UnitPosition','PickupBagFromSlot','PutItemInBag','GetSpellInfo','IsPlayerSpell'})do check('API '..name,type(_G[name])=='function')end
 check('Single addon folder',GetAddOnInfo('GMminibar')~=nil)
 check('Spell data',self.data.spells and #self.data.spells>0)
 check('Item data',self.data.items and #self.data.items>0)
 check('Profession data',self.data.professions and #self.data.professions==14)
 check('Travel data',self.data.travel and #self.data.travel>300)
 check('Player spell classification',self.data.playerSpellClasses and self.data.playerSpellClasses[12294]==1)
 check('Dungeon and set item groups',self.data.itemGroups and #self.data.itemGroups>100)
 check('Travel region metadata',self.data.travelRegions and self.data.travelRegions['taxi:339']~=nil)
 check('Legion quest giver data',self.data.questGivers and self.data.questGivers[14098]=='34913,35830;34913')
 check('Legion objective data',self.data.questObjectives and self.data.questObjectives[24575]=='266403:2:201775:5:0')
 check('Minibar created',self.mini~=nil)
 if self.mini then
  local count=0;for _ in pairs(self.mini.buttons)do count=count+1 end
  check('Eleven minibar slots',count==11)
 end
 if UpdateAddOnMemoryUsage then UpdateAddOnMemoryUsage();report.memoryKB=GetAddOnMemoryUsage('GMminibar')end
 GMMLegionDiagnostics.last=report
 local pass=0;for _,c in ipairs(report.checks)do if c.ok then pass=pass+1 end end
 self:Print(self:L('diagnostics')..': '..pass..'/'..#report.checks..' · '..string.format('%.1f MiB',(report.memoryKB or 0)/1024))
 for _,c in ipairs(report.checks)do if not c.ok then self:Print(c.name..' FAILED',true)end end
 return report
end
for _,event in ipairs({'ADDON_ACTION_BLOCKED','ADDON_ACTION_FORBIDDEN'})do
 A:On(event,function(addon,func)
  if addon=='GMminibar' then A:Error(event..': '..tostring(func))end
 end)
end
A:On('PLAYER_LOGIN',function()A:After(3,function()A:RunDiagnostics()end)end)
A:On('PLAYER_LOGOUT',function()if GMMLegionDiagnostics.last then GMMLegionDiagnostics.last.sessionErrors=A.sessionErrors or {}end end)
