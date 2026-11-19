local sm=require("core.scene_manager")
local input=require("core.input")
local bridge=require("core.bridge")
local font=require("core.font")
local icon=require("core.icon")
local bg=require("effects.forge_bg")
local M={}
local RED={.94,.16,.12}
local modules={
{icon="download",title="FORGE INSTALLER",sub="Curated tools for your VoidDesk setup",hint="Browse recommendations and install selected packages.",run=function() return sm.push("hub_forge_installer",{}) end},
{icon="list",title="APT PACKAGE MANAGER",sub="Search the full Debian package catalogue",hint="Find, inspect, install and remove packages.",run=function() return sm.push("hub_apt",{}) end},
{icon="trash",title="INSTALLED & REMOVE",sub="Review what is already installed",hint="Browse installed packages and remove unwanted software.",run=function() return sm.push("hub_apt",{tab="INSTALLED"}) end},
{icon="refresh",title="SYSTEM MAINTENANCE",sub="Refresh indexes, upgrade and clean",hint="Maintain package metadata and the APT cache.",run=function() return sm.push("hub_apt",{tab="SYSTEM"}) end},
{icon="gear",title="OPERATIONS & PROGRESS",sub="Track active and completed tasks",hint="Inspect package jobs and review operation logs.",run=function() return sm.push("hub_apt",{tab="JOBS"}) end},
{icon="terminal",title="SHELL & CLI",sub="Open the local service terminal",hint="Advanced tools for supported command-line workflows.",run=function() return sm.push("hub_shell",{}) end},
}
local st={sel=1,t=0,status="FORGE SYSTEM READY"}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b) local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z); love.graphics.setFont(f); C(c or {.9,.92,.95}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
local function refresh() st.status="SCANNING PACKAGE ENVIRONMENT…"; bridge.call("system_status",{},function(r) st.status=r.ok and "FORGE SYSTEM READY" or "SYSTEM STATUS UNAVAILABLE" end) end
local function activate() local m=modules[st.sel]; if not m.run() then st.status="MODULE UNAVAILABLE · "..m.title end end
function M.enter() st.sel=1; st.t=0; refresh(); input.clear(); input.on("press",function(a) if a=="left" or a=="up" then st.sel=(st.sel-2)%#modules+1 elseif a=="right" or a=="down" then st.sel=st.sel%#modules+1 elseif a=="a" then activate() elseif a=="y" then refresh() elseif a=="b" then sm.back() end end) end
function M.leave() input.clear() end
function M.update(dt) st.t=st.t+dt end
local function node(m,i,cx,cy,r,sel) local a=-math.pi/2+(i-1)*2*math.pi/#modules; local x,y=cx+math.cos(a)*r,cy+math.sin(a)*r; local rad=sel and 29 or 21; if sel then C(RED,.18+.08*math.sin(st.t*4)); love.graphics.circle("fill",x,y,rad+12); C(RED,.9); love.graphics.setLineWidth(2); love.graphics.circle("line",x,y,rad+5); local p=st.t*2.4; C({1,.52,.24}); love.graphics.circle("fill",x+math.cos(p)*(rad+10),y+math.sin(p)*(rad+10),2.5) end; C(sel and {.13,.035,.035} or {.045,.045,.052},.97); love.graphics.circle("fill",x,y,rad); C(sel and RED or {.36,.22,.22},.8); love.graphics.circle("line",x,y,rad); icon.draw(m.icon,x-(sel and 15 or 12),y-(sel and 12 or 9),sel and 30 or 24,sel and {1,.52,.32} or {.68,.48,.46}); T(m.title,x-58,y+(y>cy and rad+4 or -rad-15),116,7,sel and {1,.72,.62} or {.58,.48,.47},"center",sel) end
function M.draw() local W,H=love.graphics.getDimensions(); bg.draw(W,H,st.t,RED,1); love.graphics.setColor(.012,.009,.012,.30); love.graphics.rectangle("fill",0,0,W,H); T("VOIDDESK  /  SOFTWARE WORKSHOP",14,9,W-28,8,{1,.35,.27},"left",true); T("THE FORGE",14,24,W-28,22,{.98,.94,.92},"left",true); T("PACKAGE CONTROL  •  INSTALL  •  MAINTAIN",15,50,W-30,8,{.62,.49,.48}); local cx,cy=W/2,H*.48; local r=math.min(112,H*.245,W*.28); C({.72,.13,.10},.34); love.graphics.setLineWidth(1.4); love.graphics.circle("line",cx,cy,r); C({.95,.22,.14},.14); love.graphics.circle("line",cx,cy,r+8); for i=1,18 do local a=i*math.pi*2/18+st.t*.07; C({1,.28,.14},.35); love.graphics.circle("fill",cx+math.cos(a)*(r+8),cy+math.sin(a)*(r+8),1.1) end; for i,m in ipairs(modules) do node(m,i,cx,cy,r,i==st.sel) end; local m=modules[st.sel]; C({.025,.018,.022},.96); love.graphics.circle("fill",cx,cy,math.min(59,H*.135)); C(RED,.6); love.graphics.circle("line",cx,cy,math.min(59,H*.135)); icon.draw(m.icon,cx-17,cy-25,34,{1,.43,.29}); T("SELECTED",cx-45,cy+12,90,7,{.69,.48,.45},"center",true); T(m.title,cx-75,cy+24,150,8,{1,.78,.68},"center",true); local py=H-83; C({.025,.018,.022},.94); love.graphics.rectangle("fill",10,py,W-20,51,6,6); C(RED,.65); love.graphics.rectangle("line",10,py,W-20,51,6,6); T(m.sub,18,py+6,W-36,10,{.97,.91,.89},"center",true); T(m.hint,18,py+22,W-36,8,{.69,.61,.61},"center"); T(st.status,12,H-27,W-24,7,{.61,.47,.46},"center"); T("A OPEN     ◀ ▶ ROTATE     Y REFRESH     B BACK",12,H-14,W-24,8,{.85,.48,.42},"center",true); love.graphics.setColor(1,1,1,1) end
return M