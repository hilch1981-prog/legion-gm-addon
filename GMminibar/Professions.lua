local A=GMMLegion735;local N=A.UI
function A:ProfessionState(skill)
 if GetProfessions and GetProfessionInfo then
  local indices={GetProfessions()}
  for i=1,6 do local idx=indices[i]
   if idx then
    local name,icon,rank,maxRank,_,_,skillID=GetProfessionInfo(idx)
    if skillID==skill then return rank or 0,maxRank or 0,name,icon end
   end
  end
 end
 return 0,0
end
function A:CreateProfessions()
 local f=N:Frame('Professions',self:L('professions'),1080,700);N:Menu(f);f.profession=self.data.professions[1]
 N:Icon(f,'Interface\\Icons\\Trade_Engineering',14,-9,30);f.title:ClearAllPoints();f.title:SetPoint('TOPLEFT',54,-17)
 N:Text(f,self:L('professionHint'),18,-47,1000,true)
 f.professionPanel=CreateFrame('Frame',nil,f);f.professionPanel:SetPoint('TOPLEFT',15,-72);f.professionPanel:SetSize(190,608);N:Panel(f.professionPanel,true);N:Text(f.professionPanel,self:L('professions'),10,-10,170)
 f.recipePanel=CreateFrame('Frame',nil,f);f.recipePanel:SetPoint('TOPLEFT',215,-72);f.recipePanel:SetSize(427,608);N:Panel(f.recipePanel,true);N:Text(f.recipePanel,self:L('craftedItems'),10,-10,407)
 f.search=N:Edit(f.recipePanel,10,-32,298);N:Button(f.recipePanel,self:L('search'),318,-32,99,25,function()f:Refresh()end)
 f.search:SetScript('OnEnterPressed',function(e)e:ClearFocus();f:Refresh()end)
 f.only=N:Check(f.recipePanel,self:L('onlyKnown'),10,-68,function()f:Refresh()end);f.only.label:SetWidth(155)
 f.hide=N:Check(f.recipePanel,self:L('hideKnown'),218,-68,function()f:Refresh()end);f.hide.label:SetWidth(170)
 f.recipes=N:List(f.recipePanel,2,-102,423,496,36);f.recipes:SetBackdrop(nil)
 f.buttons={}
 for i,p in ipairs(self.data.professions)do
  local b=N:Card(f.professionPanel,self:DataName(p),p.icon,10,-34-(i-1)*39,170,35)
  b.label:SetWidth(127);b.label:ClearAllPoints();b.label:SetPoint('TOPLEFT',9,-5);b.label:SetFontObject(GameFontHighlightSmall)
  b.icon:SetSize(23,23);b.icon:ClearAllPoints();b.icon:SetPoint('RIGHT',-6,0)
  b:SetScript('OnClick',function()f.profession=p;f.selected=nil;f:Refresh()end);f.buttons[i]={button=b,prof=p}
 end
 local panel=CreateFrame('Frame',nil,f);f.detailPanel=panel;panel:SetPoint('TOPLEFT',652,-72);panel:SetSize(412,608);N:Panel(panel,true)
 f.skillName=N:Text(panel,'',15,-15,337)
 f.skillState=N:Text(panel,'',15,-44,337,true)
 f.tiers={}
 for i=1,10 do
  local y=-75-(i-1)*36
  local label=N:Text(panel,'',14,y,116,true)
  local b=N:Button(panel,self:L('train'),130,y+6,109,27,nil,true)
  local max=N:Button(panel,self:L('maximize'),245,y+6,109,27,nil,true)
  self:SecureAction(b,function()
   local t=b.tier;if not t then return end
   local rank,cap=A:ProfessionState(f.profession.id)
   local prev=f.profession.tiers[i-1]
   if cap>=t.cap or (prev and cap<prev.cap)then return end
   if t.skillOnly then A:Send('.setskill '..f.profession.id..' '..math.max(1,rank)..' '..t.cap)
   else A:Send('.learn '..t.id)end
   f.feedback:SetText(A:L('pending'))
  end)
  self:SecureAction(max,function()
   local rank,cap=A:ProfessionState(f.profession.id)
   if max.tier and cap==max.tier.cap and rank<cap then A:Send('.setskill '..f.profession.id..' '..cap..' '..cap);f.feedback:SetText(A:L('pending'))end
  end)
  f.tiers[i]={label=label,learn=b,max=max}
 end
 f.all=N:Button(panel,self:L('recipePicker'),14,-442,340,26,function()
  if A:Combat()then return end
  f.search:SetText('');f.only:SetChecked(false);f.hide:SetChecked(true);f:Refresh();f.feedback:SetText(A:L('utilityPickerNote'))
 end)
 f.learn=N:Button(panel,self:L('learn'),14,-480,164,26,nil,true)
 self:SecureAction(f.learn,function()
  local r=f.selected;if r and not A:Known(r.id)then A:Send('.learn '..r.id);f.feedback:SetText(A:L('pending'))end
 end)
 f.unlearn=N:Button(panel,self:L('unlearn'),191,-480,163,26,nil,true)
 self:SecureAction(f.unlearn,function()local r=f.selected;if r and A:Known(r.id)then A:Send('.unlearn '..r.id);f.feedback:SetText(A:L('pending'))end end)
 f.feedback=N:Text(panel,'',15,-518,339,true)
 f.materials=N:Text(panel,'',15,-560,380,true);f.materials:SetHeight(38)
 f.recipes.render=function(b,r)
  b.icon:SetTexture(GetSpellTexture(r.id)or r.icon)
  b.title:SetText((A:Known(r.id)and '|cff5ee799'or '|cffffffff')..A:DataName(r)..'|r\n'..r.id..' · '..A:L('skill')..' '..r.skill..' · '..A:L(A:Known(r.id)and 'learned'or 'unlearned'))
 end
 f.recipes.onSelect=function(r)
  f.selected=r;f.feedback:SetText(A:DataName(r)..' · '..A:L('rank')..': '..(r.rank~=''and r.rank or '—'))
  A:SetSecureEnabled(f.learn,not A:Known(r.id));A:SetSecureEnabled(f.unlearn,A:Known(r.id))
  local parts={A:L('reagents')..': '}
  for _,re in ipairs(r.reagents or {})do
   local n=GetItemInfo(re[1])or ('#'..re[1]);local have=GetItemCount(re[1])or 0
   parts[#parts+1]=(have>=re[2]and '|cff5ee799'or '|cffff6666')..n..' '..have..'/'..re[2]..'|r'
  end
  f.materials:SetText(table.concat(parts,'  '))
 end
 function f:Refresh()
  if A:Combat()then return end
  local p=self.profession;local rank,cap=A:ProfessionState(p.id)
  self.skillName:SetText(A:DataName(p));self.skillState:SetText(A:L('liveSkill')..': '..rank..' / '..cap)
  for _,entry in ipairs(self.buttons)do
   local r,c=A:ProfessionState(entry.prof.id);entry.button.label:SetText(A:DataName(entry.prof)..'\n'..(c>0 and ('|cff5ee799'..r..'/'..c..'|r')or A:L('unlearned')))
  end
  for i,t in ipairs(self.tiers)do
   local tier=p.tiers[i];t.learn.tier=tier;t.max.tier=tier
   if tier then
    t.label:Show();t.learn:Show();t.max:Show();t.label:SetText((cap>=tier.cap and '|cff5ee799'or '|cffffd200')..A:L('skillTier'..i)..'|r\n'..(cap>=tier.cap and math.min(rank,tier.cap)or 0)..' / '..tier.cap)
    t.learn:SetText(A:L(cap>=tier.cap and 'learned'or 'train'))
    A:SetSecureEnabled(t.learn,cap<tier.cap and (i==1 or cap>=p.tiers[i-1].cap));A:SetSecureEnabled(t.max,cap==tier.cap and rank<cap)
   elseif not A:Combat()then t.label:Hide();t.learn:Hide();t.max:Hide()end
  end
  local q=A:Trim(self.search:GetText()):lower();local rows={}
  for _,r in ipairs(p.recipes)do
   local known=A:Known(r.id)
   if (q==''or tostring(r.id)==q or r.name:lower():find(q,1,true)or r.ko:find(q,1,true))and (not self.only:GetChecked()or known)and (not self.hide:GetChecked()or not known)then rows[#rows+1]=r end
  end
  self.recipes:SetData(rows);A:SetSecureEnabled(self.learn,self.selected and not A:Known(self.selected.id));A:SetSecureEnabled(self.unlearn,self.selected and A:Known(self.selected.id))
 end
 f:Refresh()
end
A:On('TRADE_SKILL_LIST_UPDATE',function()local f=A.frames.Professions;if f and f:IsShown()then f:Refresh()end end)
