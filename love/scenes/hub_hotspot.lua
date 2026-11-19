local sm=require("core.scene_manager"); local input=require("core.input"); local bridge=require("core.bridge"); local font=require("core.font"); local icon=require("core.icon"); local bg=require("effects.uplink_bg")
local M={}; local CYAN={.22,.80,.98}; local st={hotspot={},wifi={},t=0,busy=false,status="READING HOTSPOT STATE",confirm=false}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b) local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z); love.graphics.setFont(f); C(c or {.9,.94,.98}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
local function refresh() bridge.call("network_status",{},function(r) if r.ok and r.network then st.hotspot=r.network.hotspot or {}; st.wifi=r.network.wifi or {}; st.status="HOTSPOT STATUS UPDATED" else st.status="STATUS · "..tostring(r.error or "unavailable") end end) end
local function toggle(confirm_disruption)
 if st.busy then return end
 st.busy=true; st.status=st.hotspot.on and "STOPPING ACCESS POINT…" or "STARTING ACCESS POINT…"
 bridge.call("hotspot_toggle",{confirm_disruption=confirm_disruption==true},function(r)
  st.busy=false
  if r.confirm_required then st.confirm=true; st.status="CONFIRM SINGLE-RADIO DISRUPTION"
  else st.confirm=false; st.status=r.ok and ("HOTSPOT "..string.upper(r.state or "UPDATED")) or ("HOTSPOT · "..tostring(r.error or r.reason or "failed")); refresh() end
 end)
end
function M.enter() st.t=0; st.busy=false; st.confirm=false; refresh(); input.clear(); input.on("press",function(a)
 if st.confirm then
  if a=="a" then toggle(true) elseif a=="b" then st.confirm=false; st.status="HOTSPOT START CANCELLED" end
  return
 end
 if a=="a" then toggle(false) elseif a=="y" then refresh() elseif a=="b" then sm.back() end
end) end
function M.leave() input.clear() end; function M.update(dt) st.t=st.t+dt end
function M.draw()
 local W,H=love.graphics.getDimensions(); bg.draw(W,H,st.t,"hotspot",CYAN,1); T("UPLINK  /  ACCESS POINT",14,9,W-28,8,{.38,.83,.97},"left",true); T("HOTSPOT",14,24,W-28,21,{.94,.97,1},"left",true)
 local on=st.hotspot.on==true; C({.02,.055,.08},.96); love.graphics.rectangle("fill",14,68,W-28,178,8,8); C(on and CYAN or {.31,.47,.57},.7); love.graphics.rectangle("line",14,68,W-28,178,8,8); icon.draw("signal",W/2-18,88,36,on and CYAN or {.52,.62,.7}); T(on and "ACCESS POINT ACTIVE" or "ACCESS POINT STOPPED",28,137,W-56,12,on and CYAN or {.68,.75,.82},"center",true); T("NETWORK NAME",28,172,W-56,7,{.5,.7,.81},"center"); T(on and (st.hotspot.ssid or "VoidDesk-AP") or "—",28,186,W-56,15,{.94,.97,1},"center",true); T("UPSTREAM WI-FI  "..tostring(st.wifi.ssid or "not connected"),28,218,W-56,8,{.61,.76,.86},"center")
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",14,260,W-28,94,7,7); C(CYAN,.3); love.graphics.rectangle("line",14,260,W-28,94,7,7); T("RADIO NOTE",25,271,W-50,8,{.46,.82,.96},"left",true); T("On single-radio hardware, starting the hotspot may interrupt the upstream Wi-Fi link. The service script attempts to restore station mode when the hotspot stops.",25,291,W-50,9,{.72,.82,.89})
 T(st.status,12,H-48,W-24,8,{.49,.82,.95},"center"); T("A START / STOP HOTSPOT    Y REFRESH    B BACK",12,H-27,W-24,8,{.72,.87,.95},"center",true)
 if st.confirm then
  C({.008,.018,.03},.88); love.graphics.rectangle("fill",0,0,W,H)
  local bx,by,bw,bh=48,H*.34,W-96,130
  C({.025,.065,.09},.99); love.graphics.rectangle("fill",bx,by,bw,bh,8,8)
  C({1,.68,.28},.95); love.graphics.setLineWidth(2); love.graphics.rectangle("line",bx,by,bw,bh,8,8)
  T("SINGLE-RADIO HOTSPOT",bx+12,by+14,bw-24,12,{1,.72,.36},"center",true)
  T("Starting the access point may interrupt the current Wi-Fi connection. Continue?",bx+18,by+43,bw-36,9,{.89,.93,.97},"center")
  T("A CONFIRM     B CANCEL",bx+12,by+94,bw-24,9,CYAN,"center",true)
 end
 love.graphics.setColor(1,1,1,1)
end
return M