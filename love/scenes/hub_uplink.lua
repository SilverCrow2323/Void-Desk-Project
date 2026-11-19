-- VOIDDESK // UPLINK — dedicated network-control layout
local sm=require("core.scene_manager"); local input=require("core.input"); local bridge=require("core.bridge")
local font=require("core.font"); local icon=require("core.icon"); local bg=require("effects.uplink_bg")
local M={}; local CYAN={.22,.80,.98}; local DIM={.48,.62,.71}
local st={network={wifi={},hotspot={},bt={},info={}},tailscale={},sync={},focus=1,t=0,status="READING NETWORK STATE",refresh_t=0}
local quick={{title="WI-FI",icon="wifi",kind="wifi"},{title="HOTSPOT",icon="signal",kind="hotspot"},{title="BLUETOOTH",icon="bluetooth",kind="bt"}}
local services={{title="B.S. SERVER",icon="globe",kind="basestation",sub="BaseStation PC companion"},{title="TAILSCALE",icon="uplink",kind="tailscale",sub="Private tailnet · peers · Taildrop"},{title="SYNCTHING",icon="refresh",kind="sync",sub="Folders · devices · sync state"},{title="FTP",icon="upload",kind="ftp",sub="FTPiercer transfer client"}}
local maintenance={{title="NETWORK PROBE",desc="IP · gateway · DNS · internet reachability",icon="globe",kind="probe"},{title="WI-FI SCANNER",desc="Discover nearby wireless networks",icon="search",kind="wifi_scan"},{title="REFRESH CONNECTIONS",desc="Reload radio and service status",icon="refresh",kind="refresh"}}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b) local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z); love.graphics.setFont(f); C(c or {.9,.94,.98}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
local refresh
local function open(kind)
 local routes={wifi="hub_wifi",hotspot="hub_hotspot",bt="hub_bluetooth",basestation="hub_basestation",tailscale="hub_tailscale",sync="hub_syncthing",ftp="hub_ftp",probe="hub_network_tools",wifi_scan="hub_wifi"}
 if kind=="refresh" then refresh(); return true end; local scene=routes[kind]; if scene then return sm.push(scene,{}) end; return false
end
refresh=function()
 st.status="UPDATING CONNECTIONS…"
 bridge.call("network_status",{},function(r) if r.ok and r.network then st.network=r.network; st.status="NETWORK STATE UPDATED" else st.status="NETWORK STATUS · "..tostring(r.error or r.reason or "unavailable") end end)
 bridge.call("tailscale_status",{},function(r) st.tailscale=r.ok and r or {error=r.error or "unavailable"} end)
 bridge.call("syncthing_status",{},function(r) st.sync=r.ok and r or {message=r.error or "unavailable"} end)
end
local function toggle_quick(i)
 if i==1 then local v=st.network.wifi or {}; if v.radio_on==nil then st.status="WI-FI RADIO CONTROL UNAVAILABLE"; return end; local a=v.radio_on and "radio_off" or "radio_on"; st.status="CHANGING WI-FI RADIO…"; bridge.call("wifi_action",{action=a},function(r) st.status=r.ok and ("WI-FI RADIO "..string.upper(r.state or "UPDATED")) or ("WI-FI · "..tostring(r.error or r.reason or "failed")); refresh() end)
 elseif i==2 then st.status="CHANGING HOTSPOT…"; bridge.call("hotspot_toggle",{},function(r) st.status=r.ok and ("HOTSPOT "..string.upper(r.state or "UPDATED")) or ("HOTSPOT · "..tostring(r.error or r.reason or "failed")); refresh() end)
 elseif i==3 then local v=st.network.bt or {}; if not v.available then st.status="BLUETOOTH ADAPTER UNAVAILABLE"; return end; local a=v.on and "power_off" or "power_on"; st.status="CHANGING BLUETOOTH POWER…"; bridge.call("bt_action",{action=a},function(r) st.status=r.ok and "BLUETOOTH POWER UPDATED" or ("BLUETOOTH · "..tostring(r.error or r.reason or "failed")); refresh() end) end
end
function M.enter()
 st.focus=1; st.t=0; st.refresh_t=0; refresh(); input.clear()
 input.on("press",function(a)
  if a=="left" or a=="up" then st.focus=(st.focus-2)%10+1 elseif a=="right" or a=="down" then st.focus=st.focus%10+1
  elseif a=="a" then if st.focus<=3 then open(quick[st.focus].kind) elseif st.focus<=7 then open(services[st.focus-3].kind) else open(maintenance[st.focus-7].kind) end
  elseif a=="x" and st.focus<=3 then toggle_quick(st.focus) elseif a=="y" then refresh() elseif a=="b" then sm.back() end
 end)
end
function M.leave() input.clear() end
function M.update(dt) st.t=st.t+dt; st.refresh_t=st.refresh_t+dt; if st.refresh_t>9 then st.refresh_t=0; refresh() end end
local function panel(x,y,w,h,selected) C({.018,.044,.066},.95); love.graphics.rectangle("fill",x,y,w,h,6,6); C(selected and CYAN or {.16,.31,.42},selected and .95 or .58); love.graphics.setLineWidth(selected and 2 or 1); love.graphics.rectangle("line",x,y,w,h,6,6) end
local function draw_quick(i,item,x,y,w,h)
 local n=st.network[item.kind] or {}; local selected=st.focus==i
 local active=item.kind=="wifi" and n.radio_on==true or item.kind=="hotspot" and n.on==true or item.kind=="bt" and n.on==true
 local known=item.kind=="wifi" and n.radio_on~=nil or item.kind=="hotspot" or item.kind=="bt" and n.available
 local status=not known and "N/A" or active and "ON" or "OFF"
 local label=item.kind=="wifi" and (n.connected and (n.ssid or "CONNECTED") or "NOT CONNECTED") or item.kind=="hotspot" and (n.on and (n.ssid or "ACTIVE") or "NOT BROADCASTING") or (n.name or "Bluetooth adapter")
 panel(x,y,w,h,selected); icon.draw(item.icon,x+10,y+11,23,active and CYAN or DIM); T(item.title,x+42,y+9,w-98,9,{.91,.95,.98},"left",true); T(label,x+11,y+39,w-22,8,{.64,.76,.84})
 local sx=x+w-45; C(active and {.11,.56,.72} or {.13,.17,.21}); love.graphics.rectangle("fill",sx,y+8,34,15,7,7); C(active and CYAN or {.4,.48,.55}); love.graphics.circle("fill",sx+(active and 25 or 9),y+15.5,5); T(status,sx-3,y+28,40,7,active and CYAN or {.60,.68,.74},"center",true)
end
local function draw_service(i,item,x,y,w,h)
 local selected=st.focus==i; panel(x,y,w,h,selected); icon.draw(item.icon,x+10,y+15,25,selected and CYAN or {.62,.76,.84}); T(item.title,x+45,y+7,w-55,9,{.94,.96,.98},"left",true); T(item.sub,x+45,y+21,w-55,7,{.52,.66,.75})
 local status
 if item.kind=="tailscale" then status=st.tailscale.error or (st.tailscale.installed and (st.tailscale.backend or (st.tailscale.daemon and "RUNNING" or "STOPPED")) or "NOT INSTALLED")
 elseif item.kind=="sync" then status=st.sync.message or st.sync.state or (st.sync.available and "READY" or "NOT CONFIGURED")
 elseif item.kind=="basestation" then status="PC ONLY · COMPANION" else status="CLIENT UI NOT MIGRATED" end
 T(status,x+45,y+36,w-55,7,{.31,.78,.94})
end
function M.draw()
 local W,H=love.graphics.getDimensions(); bg.draw(W,H,st.t,"mesh",CYAN,1)
 T("VOIDDESK  /  NETWORK CONTROL",14,8,W-28,8,{.36,.84,.98},"left",true); T("UPLINK",14,22,W-28,22,{.92,.97,1},"left",true); T("CONNECTIVITY  ·  SHARING  ·  REMOTE SERVICES",15,48,W-30,7,DIM)
 local gap=8; local margin=12; local qw=(W-margin*2-gap*2)/3
 for i,item in ipairs(quick) do draw_quick(i,item,margin+(i-1)*(qw+gap),63,qw,67) end
 T("SERVICE LINKS",13,140,W-26,8,{.35,.78,.94},"left",true); local sw=(W-36)/2
 for i,item in ipairs(services) do local col=(i-1)%2; local row=math.floor((i-1)/2); draw_service(i+3,item,12+col*(sw+12),155+row*59,sw,52) end
 T("CONNECTION MAINTENANCE",13,278,W-26,8,{.35,.78,.94},"left",true)
 for i,item in ipairs(maintenance) do local y=292+(i-1)*34; local sel=st.focus==i+7; if sel then C(CYAN,.13); love.graphics.rectangle("fill",12,y,W-24,29,4,4); C(CYAN,.9); love.graphics.rectangle("line",12,y,W-24,29,4,4) end; icon.draw(item.icon,20,y+5,18,sel and CYAN or DIM); T(item.title,48,y+3,170,8,{.88,.93,.97},"left",true); T(item.desc,212,y+5,W-230,7,{.56,.68,.77}) end
 C({.012,.035,.052},.92); love.graphics.rectangle("fill",0,H-29,W,29); T(st.status,12,H-25,W-24,7,{.50,.82,.94},"center"); T("A OPEN   X POWER   Y REFRESH   ◀ ▶ NAVIGATE   B BACK",12,H-12,W-24,7,{.68,.82,.9},"center",true); love.graphics.setColor(1,1,1,1)
end
return M