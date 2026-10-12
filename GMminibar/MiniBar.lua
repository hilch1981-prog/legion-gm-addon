local A=GMMLegion735;local N=A.UI
local slots={
 {'menu',134400,'Utilities'},{'bank','Interface\\Icons\\INV_Misc_Bag_08'},{'quests','Interface\\Icons\\INV_Misc_Book_07','Quests'},{'travel','Interface\\Icons\\INV_Misc_Map_01','Travel'},
 {'revive','Interface\\Icons\\Spell_Holy_Resurrection'},{'gm','Interface\\Icons\\INV_Misc_Food_54'},{'god','Interface\\Icons\\Spell_Holy_PowerWordShield'},{'stealth','Interface\\Icons\\Ability_Stealth'},{'kill','Interface\\Icons\\Ability_BackStab'},{'fly','Interface\\Icons\\Spell_Magic_FeatherFall'},{'speed','Interface\\Icons\\Ability_Rogue_Sprint'}}
function A:BindPopup(button,key)
 if self:Combat()then return end
 local f=self.frames.Bind
 if not f then
  f=N:Frame('Bind',self:L('bindings'),370,135);f:SetFrameStrata('DIALOG');f.hint=N:Text(f,self:L('bindHint'),18,-53,330,true)
  f:EnableKeyboard(true);f:SetScript('OnKeyDown',function(s,k)
   if k=='ESCAPE' then s:Hide();return end
   if k=='LSHIFT' or k=='RSHIFT' or k=='LCTRL' or k=='RCTRL' or k=='LALT' or k=='RALT'then return end
   if k=='DELETE' then GMMLegionDB.bindings[s.slot]=nil
   else
    local binding=(IsControlKeyDown()and 'CTRL-'or '')..(IsAltKeyDown()and 'ALT-'or '')..(IsShiftKeyDown()and 'SHIFT-'or '')..k
    for slot,old in pairs(GMMLegionDB.bindings)do if old==binding then GMMLegionDB.bindings[slot]=nil end end
    GMMLegionDB.bindings[s.slot]=binding
   end
   A:RefreshBindings();s:Hide()
  end)
 end
 f.slot=key;f.title:SetText(self:L('bindings')..' · '..self:L(key));f:Show()
end
function A:RefreshBindings()
 if self:Combat()or not self.mini then return end
 ClearOverrideBindings(self.mini)
 for key,b in pairs(self.mini.buttons)do
  local binding=GMMLegionDB.bindings[key]
  if binding then SetOverrideBindingClick(self.mini,true,binding,b:GetName(),'LeftButton')end
 end
end
function A:ResetMiniBar()
 if not self.mini or self:Combat()then return end
 self:RestorePoint(self.mini,'mini','TOP',0,-80);self.mini:SetScale(GMMLegionDB.scale);self:RefreshBindings()
end
function A:CreateMiniBar()
 if self.mini then return end
 local f=CreateFrame('Frame','GMMLegionMiniBar',UIParent);self.mini=f;f:SetSize(478,38);N:Panel(f,true);f:SetMovable(true);f:SetClampedToScreen(true);f:SetFrameStrata('MEDIUM');f.buttons={}
 local grip=CreateFrame('Button',nil,f);grip:SetPoint('LEFT',3,0);grip:SetSize(16,32)
 for row=0,2 do for col=0,1 do
  local dot=grip:CreateTexture(nil,'ARTWORK');dot:SetTexture('Interface\\Buttons\\WHITE8X8');dot:SetSize(3,3);dot:SetPoint('TOPLEFT',3+col*5,-8-row*6);dot:SetVertexColor(.85,.73,.42,1)
 end end
 N:Hint(grip,self:L('drag'));grip:RegisterForDrag('LeftButton')
 grip:SetScript('OnDragStart',function()if not A:Combat()then f:StartMoving()end end)
 grip:SetScript('OnDragStop',function()f:StopMovingOrSizing();A:SavePoint(f,'mini')end)
 local offset=21
 for i,r in ipairs(slots)do
  local key,icon,dest=r[1],r[2],r[3];local width=i==1 and 85 or 31
  local b=CreateFrame('Button','GMMLegionSlot_'..key,f,'SecureActionButtonTemplate');b:SetPoint('LEFT',offset,0);b:SetSize(width,29);offset=offset+width+3;N:Panel(b,true);f.buttons[key]=b
  if i==1 then b.label=N:Text(b,self:L('menu'),4,-7,77);b.label:SetJustifyH('CENTER')else b.icon=N:Icon(b,icon,3,-3,23)end
  b:RegisterForClicks('LeftButtonUp','RightButtonUp')
  if not dest and key~='kill' and key~='bank' then b:SetAttribute('type1','target');b:SetAttribute('unit1','player')end
  b:SetScript('PostClick',function(_,mouse)
   if mouse=='RightButton'then A:BindPopup(b,key);return end
   if dest then A:Show(dest)
   elseif key=='bank' then if IsControlKeyDown()then A:ToggleBags()else A:Send('.bank')end
   elseif key=='kill' then A:KillTarget()
   elseif not UnitIsUnit('target','player')then A:Print(A:L('selfTargetFail'),true)
   elseif key=='stealth'then A.toggles.stealth=not A.toggles.stealth;A:Send((A.toggles.stealth and '.aura 'or '.unaura ')..'1784')
   elseif key=='speed'then A.toggles.speed=not A.toggles.speed;A:Send('.modify speed all '..(A.toggles.speed and '3'or '1'))
   else A:ExecuteAction(A.byAction[key],'LeftButton')end
  end)
  N:Hint(b,self:L(key),A:L('rightBinding')..(key=='bank' and ('\n'..A:L('controlBags'))or ''))
 end
 local up=N:Button(f,'+',454,-3,20,15,function()A:SetOption('scale',GMMLegionDB.scale+.05)end)
 local down=N:Button(f,'−',454,-19,20,15,function()A:SetOption('scale',GMMLegionDB.scale-.05)end)
 N:Hint(up,self:L('scaleUp'));N:Hint(down,self:L('scaleDown'));self:ResetMiniBar()
end
A:On('PLAYER_REGEN_ENABLED',function()A:RefreshBindings()end)
-- These preconfigured hardware buttons may target and send GM commands in combat.
-- Only changing bindings/attributes and opening protected editors stays restricted.
function A:KillTarget()
 if not UnitExists('target')or UnitIsUnit('target','player')then self:Print(self:L('killSelect'),true);return end
 if UnitIsDeadOrGhost('target')then return end
 local guid=UnitGUID('target')
 if not self:Send('.die')then return end
 self:After(.8,function()
  if UnitGUID('target')==guid and not UnitIsDeadOrGhost('target')then A:Print(A:L('killPending'),true)end
 end)
end
