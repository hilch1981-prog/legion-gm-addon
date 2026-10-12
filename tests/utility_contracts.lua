-- Regressions from live SPP command failures; UI/server behavior still needs game testing.
local A=GMMLegion735;local u=A.frames.Utilities
local function check(ok,label)assert(ok,label);MOCK.passed=MOCK.passed+1 end
local function card(key)
 for index,r in ipairs(A.actions)do if r.key==key then u.page=math.ceil(index/16);u:Refresh();return u.cards[(index-1)%16+1]end end
 error('Missing utility '..key)
end
MOCK.combat=false;MOCK:Drain();A:Show('Utilities')
MOCK.target='TestGM';MOCK.targetIsPlayer=true;MOCK:ResetSent();card('respawn'):Click()
check(not MOCK.target and #MOCK.sent==1 and MOCK.sent[1][1]=='.respawn','area respawn clears player target via hardware macro')
MOCK.target='Enemy';MOCK.targetIsPlayer=false;MOCK.targetGUID='Creature-0-1-1-1-123-0001';MOCK.targetDead=true
MOCK:ResetSent();card('respawn'):Click('RightButton')
check(MOCK.sent[1][1]=='.respawn'and MOCK.target=='Enemy','selected respawn retains dead creature target')
MOCK.targetDead=false;MOCK:Drain()
check(GMMLegionDiagnostics.utilityHistory[#GMMLegionDiagnostics.utilityHistory].status=='confirmed','respawn acknowledgement requires same GUID dead-to-alive transition')
MOCK:ResetSent();card('respawn'):Click('RightButton');check(#MOCK.sent==0,'reject living creature respawn')
MOCK.targetGUID='Pet-0-1';MOCK.targetDead=true;card('respawn'):Click('RightButton');check(#MOCK.sent==0,'reject dead pet respawn')
MOCK.targetGUID='Player-Other';MOCK.targetIsPlayer=true;card('respawn'):Click('RightButton');check(#MOCK.sent==0,'reject player respawn')
MOCK.targetGUID=nil;MOCK.targetDead=false
MOCK.target='Other';MOCK:ResetSent();card('repair'):Click();check(MOCK.target=='TestGM'and MOCK.sent[1][1]=='.repairitems','left repair targets self')
A:Emit('GMM_SERVER_REPLY','A visible server error');check(u.note:GetText():find('A visible server error',1,true),'server rejection stays visible rather than success notification')
A:Send('.help');check(not A.utilityRequest,'unrelated commands cannot be attributed to previous utility')
for _,key in ipairs({'god','cast','power','dismount','unstuck'})do
 MOCK:ResetSent();card(key):Click('RightButton');check(#MOCK.sent==0,'self-only action refuses another player: '..key)
end
MOCK:ResetSent();card('unstuck'):Click();check(MOCK.sent[1][1]=='.start','unstuck uses registered SPP start command')
MOCK.target=nil;MOCK:ResetSent();card('up10'):Click('RightButton')
check(A.frames.NamePrompt:IsShown()and #MOCK.sent==0,'level change without target prompts for a name')
local prompt=A.frames.NamePrompt;prompt.edit:SetText('AnotherPlayer');prompt.ok:Click()
check(MOCK.sent[1][1]=='.levelup AnotherPlayer 10','named level command uses server name-before-delta syntax')
MOCK:ResetSent();card('down1'):Click();check(MOCK.sent[1][1]=='.levelup -1','self level change keeps delta-only syntax')
MOCK.skills={};MOCK.skills[164]={1,75};MOCK.skills[185]={150,150};MOCK:ResetSent();card('maxskill'):Click()
check(#MOCK.sent==1 and MOCK.sent[1][1]=='.setskill 164 75 75','maximize learns no new ranks and skips already-max skills')
MOCK.skills[164]={75,75};MOCK:ResetSent();card('maxskill'):Click();check(#MOCK.sent==0,'maxed skills do not generate redundant commands')
MOCK:ResetSent();card('crafts'):Click();check(A.frames.Professions:IsShown()and #MOCK.sent==0,'profession picker sends no unsupported bulk command')
A.frames.Professions.all:Click();check(A.frames.Professions.hide:GetChecked()and #MOCK.sent==0,'recipe selector filters unlearned recipes')
card('talents'):Click();MOCK:Drain();local f=A.frames.Spells
check(f.utilityMode=='talents'and next(f.utilitySpellIDs)and #f.list.data>0,'talent picker finds current-class DB2 spell IDs')
for _,ref in ipairs(f.list.data)do assert(f.utilitySpellIDs[A:CatalogRow('spells',ref).id],'talent filter leaked another spell')end
check(true,'talent results restricted to supplied class IDs')
f.reset:Click();MOCK:Drain();check(not f.utilityMode and not f.utilitySpellIDs,'reset restores normal spell search')
card('myclass'):Click();MOCK:Drain();check(f.classMask==128 and f.mine:GetChecked(),'class picker honors player class and level')
card('gmskills'):Click();MOCK:Drain();check(f.utilityMode=='gm'and not f.classMask and not f.utilitySpellIDs and #f.list.data>0,'GM search has full catalog access without invented GM membership')
MOCK:ResetSent();WorldMapFrame:Hide();MOCK.mapArea=81;MOCK.mapName='StonetalonMountains';MOCK.mapFloor=0
local mapAPI=GetMapInfo;card('explore'):Click();MOCK:Drain()
check(GMMLegionDB.mapReveal and WorldMapFrame:IsShown()and #MOCK.sent==0,'map card opens client map without unsupported server command')
check(GMMLegionDiagnostics.mapReveal.tiles>0 and not GMMLegionDiagnostics.mapReveal.serverExplorationChanged,'map overlay generated for actual DB2 map')
local count=#A.mapRevealTextures;A:UpdateMapReveal();check(#A.mapRevealTextures==count and GetMapInfo==mapAPI,'repaint reuses texture pool and preserves native API')
MOCK.mapArea=-1;A:UpdateMapReveal();local shown=0;for _,t in ipairs(A.mapRevealTextures)do if t:IsShown()then shown=shown+1 end end
check(shown==0,'unsupported map hides old map textures')
MOCK.mapArea=81;MOCK.mapFloor=1;A:UpdateMapReveal();check(not A.mapRevealTextures[1]:IsShown(),'dungeon floor never inherits zone artwork')
MOCK.mapFloor=0;MOCK.mapName='WrongPhase';A:UpdateMapReveal();check(not A.mapRevealTextures[1]:IsShown(),'map prefix mismatch is rejected')
MOCK.mapName='StonetalonMountains';A:UpdateMapReveal();card('explore'):Click('RightButton')
check(not GMMLegionDB.mapReveal and not A.mapRevealTextures[1]:IsShown()and #MOCK.sent==0,'right click restores normal fog with no gameplay command')
MOCK.combat=true;A:SetMapReveal(true);check(not GMMLegionDB.mapReveal,'combat rejection leaves map setting unchanged');MOCK.combat=false
-- A non-multiple tile checks UV padding at a map edge, independent of real art files.
local saved=A.data.mapFog[-1];A.data.mapFog[-1]='TestMap|Edge,300,270,7,11';MOCK.mapArea=-1;MOCK.mapName='TestMap';A:SetMapReveal(true)
local edge=A.mapRevealTextures[4];check(edge:GetWidth()==44 and edge:GetHeight()==14 and edge.texCoord[2]==44/64 and edge.texCoord[4]==14/16,'edge tile uses power-of-two texture padding')
A:SetMapReveal(false);A.data.mapFog[-1]=saved;MOCK.mapArea=nil;MOCK.mapName=nil;MOCK.targetDead=false;MOCK.targetGUID=nil;WorldMapFrame:Hide();MOCK:Drain()
for _,r in ipairs(A.actions)do assert(not r.command:find('%.learn all')and r.command~='.maxskill'and r.command~='.unstuck','known unsupported command remained')end
check(true,'no unsupported utility bulk commands remain')
check(#GMMLegionDiagnostics.errors==0,table.concat(GMMLegionDiagnostics.errors,'\n'))
