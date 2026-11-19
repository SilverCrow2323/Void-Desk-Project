-- VOIDDESK // START SESSION — Desktop Environment Hub
local bridge=require("core.bridge")
local sm=require("core.scene_manager")
local input=require("core.input")
local font=require("core.font")
local icon=require("core.icon")
local M={}
local catalog={
 {id="xfce",name="XFCE",mark="Xf",color={.95,.42,.18},tag="THE FULL DESKTOP",desc="Complete desktop, panel, file manager and settings.",features="Full session · Broad app compatibility",disk="~1.8–2.5 GB",ram="~350–550 MB",supported=true},
 {id="icewm",name="IceWM",mark="IW",color={.30,.72,.95},tag="LEAN & FAST",desc="Classic window manager with a tiny memory footprint.",features="Fast startup · Traditional menus · Lightweight",disk="~10–30 MB*",ram="~80–140 MB",supported=true},
 {id="lxde",name="LXDE",mark="LX",color={.32,.82,.57},tag="LIGHTWEIGHT DESKTOP",desc="Traditional desktop built around Openbox.",features="PCManFM · LXPanel · Openbox",disk="~250–450 MB*",ram="~150–250 MB",supported=true},
 {id="lxqt",name="LXQt",mark="Qt",color={.23,.66,.90},tag="MODERN LIGHTWEIGHT",desc="Qt-based lightweight desktop to evaluate next.",features="Qt stack · Modular · Modern workflow",disk="TBD",ram="TBD",planned=true},
 {id="openbox",name="Openbox",mark="Ob",color={.72,.58,.92},tag="BARE WINDOW MANAGER",desc="Minimal foundation for a custom VoidDesk session.",features="Very lean · Highly configurable",disk="TBD",ram="TBD",planned=true},
 {id="fluxbox",name="Fluxbox",mark="Fb",color={.95,.68,.26},tag="CLASSIC & TINY",desc="Small, keyboard-friendly window manager.",features="Tabbing · Workspaces · Minimal dependencies",disk="TBD",ram="TBD",planned=true},
 {id="mate",name="MATE",mark="M",color={.46,.75,.42},tag="TRADITIONAL FULL DESKTOP",desc="Familiar full desktop, with a larger dependency set.",features="Complete desktop · Mature applets",disk="TBD",ram="TBD",planned=true},
}
local st={sessions={},sel=1,detail=false,busy=false,status="SCANNING DESKTOP ENVIRONMENTS",disk=0,t=0}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align) love.graphics.setFont(font.regular(z) or love.graphics.newFont(z)); C(c or {.9,.94,.98}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
local function box(x,y,w,h,fill,line) C(fill); love.graphics.rectangle("fill",x,y,w,h,7,7); if line then C(line); love.graphics.setLineWidth(2); love.graphics.rectangle("line",x,y,w,h,7,7); love.graphics.setLineWidth(1) end end
local function env() return catalog[st.sel] end
local function installed(id) for _,s in ipairs(st.sessions) do if s.id==id then return s.installed==true end end return false end
local function refresh()
 st.status="CHECKING SESSION CATALOGUE…"
 bridge.call("session_list",{},function(r) if r.ok then st.sessions=r.sessions or {}; st.status="CATALOGUE UPDATED" else st.status="CHECK FAILED · "..tostring(r.error) end end)
 bridge.call("system_status",{},function(r) if r.ok and r.system then st.disk=tonumber(((r.system.disk or {})[1] or {}).free_gb) or 0 end end)
end
local function launch(e)
 if not installed(e.id) then st.status=e.name.." IS NOT INSTALLED"; return end
 st.busy=true
 local function go() bridge.call("session_launch",{id=e.id},function(r) st.busy=false; st.status=r.ok and (r.note or ("STARTING "..e.name)) or (e.name.." · "..tostring(r.error)); if r.ok and r.handoff then love.event.quit() end end) end
 sm.switch("bootanim",{next="hub_session",name=e.name,duration=2.5,on_complete=go})
end
local function install(e)
 if e.planned then st.status="NOT AVAILABLE YET · "..e.name; return end
 if installed(e.id) then st.status="ALREADY INSTALLED · REINSTALL NOT WIRED YET"; return end
 st.busy=true; st.status="STARTING "..e.name.." INSTALLER…"
 local cmd=e.id=="xfce" and "xfce_install" or "env_install"
 bridge.call(cmd,e.id=="xfce" and {} or {id=e.id},function(r) st.busy=false; st.status=r.ok and (r.note or "INSTALL STARTED") or ("INSTALL FAILED · "..tostring(r.error)); refresh() end)
end
function M.enter()
 st.sel=1; st.detail=false; st.busy=false; st.t=0; refresh(); input.clear()
 input.on("press",function(a)
  if st.busy then return end
  if st.detail then local e=env()
   if a=="b" then st.detail=false
   elseif a=="a" then if installed(e.id) then launch(e) else install(e) end
   elseif a=="x" then install(e)
   elseif a=="y" then refresh() end
  else
   if a=="left" then st.sel=math.max(1,st.sel-1)
   elseif a=="right" then st.sel=math.min(#catalog,st.sel+1)
   elseif a=="up" then st.sel=math.max(1,st.sel-2)
   elseif a=="down" then st.sel=math.min(#catalog,st.sel+2)
   elseif a=="a" then st.detail=true
   elseif a=="y" then refresh()
   elseif a=="b" then sm.back() end
  end
 end)
end
function M.leave() input.clear() end
function M.update(dt) st.t=st.t+dt end
local function background(W,H)
 love.graphics.clear(.018,.026,.043,1)
 for i=0,10 do C({.12,.19,.27},.12); love.graphics.line(0,(i*49+st.t*7)%H,W,(i*49+st.t*7)%H) end
 for i=1,18 do local x=(i*73)%W; local y=(i*47-st.t*(4+i%3)*5)%H; C({.2,.65,.9},.13); love.graphics.circle("fill",x,y,1.5) end
 C({.14,.72,.94},.6); love.graphics.rectangle("fill",0,0,W,3)
end
local function card(e,i,x,y,w,h)
 local yes=installed(e.id); local sel=i==st.sel; local accent=e.color
 if sel then box(x-2,y-2,w+4,h+4,{.09,.13,.17},accent); local a=st.t*2.8; C(accent); love.graphics.circle("fill",x+35+math.cos(a)*23,y+34+math.sin(a)*23,2.7); C(accent,.3); love.graphics.circle("line",x+35,y+34,23) end
 box(x,y,w,h,yes and {.055,.085,.115} or {.045,.052,.066},yes and accent or {.20,.24,.29})
 C(yes and accent or {.42,.45,.5},yes and 1 or .55); love.graphics.circle("fill",x+35,y+34,20)
 C({.025,.035,.05}); love.graphics.circle("fill",x+35,y+34,16)
 T(e.mark,x+17,y+25,36,14,yes and accent or {.58,.61,.66},"center")
 T(e.name,x+65,y+11,w-75,16,yes and {.95,.97,1} or {.67,.7,.75})
 T(e.tag,x+65,y+32,w-75,8,accent)
 T(e.desc,x+12,y+60,w-24,9,yes and {.72,.79,.86} or {.48,.52,.58})
 T((yes and "✓ INSTALLED") or (e.planned and "◌ PLANNED" or "+ NOT INSTALLED"),x+12,y+h-18,w-24,9,yes and {.35,.9,.58} or {.8,.67,.38})
 T(e.disk.." · RAM "..e.ram,x+12,y+h-33,w-24,8,{.57,.64,.72})
end
local function detail(W,H)
 local e=env(); love.graphics.setColor(0,0,0,.8); love.graphics.rectangle("fill",0,0,W,H)
 local w=math.min(W-28,430); local h=math.min(H-58,330); local x=(W-w)/2; local y=(H-h)/2
 box(x,y,w,h,{.035,.052,.074},e.color); C(e.color,.2); love.graphics.rectangle("fill",x+1,y+1,w-2,7,4,4)
 C(e.color); love.graphics.circle("fill",x+44,y+48,26); C({.025,.035,.05}); love.graphics.circle("fill",x+44,y+48,21)
 T(e.mark,x+19,y+39,50,18,e.color,"center"); T(e.name,x+82,y+22,w-100,22,{.96,.98,1}); T(e.tag,x+82,y+50,w-100,9,e.color)
 T(e.desc,x+20,y+89,w-40,11,{.82,.87,.92}); T("PROFILE",x+20,y+119,w-40,8,e.color)
 T(e.features,x+20,y+136,w-40,10,{.75,.82,.89}); T("DISK  "..e.disk.."     MEMORY  "..e.ram,x+20,y+163,w-40,10,{.68,.77,.86})
 T("AVAILABLE SPACE  "..string.format("%.1f GB",st.disk),x+20,y+185,w-40,9,{.56,.68,.78})
 local by=y+h-88; box(x+18,by,w-36,38,e.color)
 icon.draw(installed(e.id) and "play" or "download",x+27,by+8,22,{.03,.05,.07})
 T(installed(e.id) and "START SESSION" or "INSTALL ENVIRONMENT",x+58,by+11,w-90,13,{.025,.04,.06})
 T(installed(e.id) and "X  Reinstall (not wired)   ·   Y  Check updates (not wired)" or "X  Install   ·   Y  Refresh status",x+20,by+44,w-40,8,{.75,.81,.88})
 if e.planned then T("PLANNED · installer and launcher not connected",x+20,by+61,w-40,8,{.95,.67,.35}) end
 T("B  CLOSE",x+20,y+h-17,w-40,9,{.56,.66,.76})
end
function M.draw()
 local W,H=love.graphics.getDimensions(); background(W,H)
 T("VOIDDESK  /  SESSION CONTROL",15,11,W-30,9,{.35,.78,.96})
 T("CHOOSE YOUR DESKTOP",15,29,W-30,20,{.94,.97,1})
 T("Seven profiles · three currently installable · select a card for controls",15,54,W-30,8,{.58,.67,.77})
 local gap=8; local m=13; local top=77; local cw=(W-2*m-gap)/2; local ch=math.max(72,math.min(91,(H-top-44-gap*2)/4))
 for i,e in ipairs(catalog) do local col=(i-1)%2; local row=math.floor((i-1)/2); card(e,i,m+col*(cw+gap),top+row*(ch+gap),cw,ch) end
 C({.04,.08,.12},.97); love.graphics.rectangle("fill",0,H-25,W,25)
 T(st.status,11,H-18,W-22,8,{.56,.78,.88})
 if st.detail then detail(W,H) end
 love.graphics.setColor(1,1,1,1)
end
return M
