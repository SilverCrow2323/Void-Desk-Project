local sm=require("core.scene_manager"); local input=require("core.input"); local bridge=require("core.bridge"); local font=require("core.font"); local bg=require("effects.uplink_bg")
local M={}; local CYAN={.22,.80,.98}; local st={network={},info={},system={},probe={},t=0,busy=false,status="DIAGNOSTICS READY"}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b) local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z); love.graphics.setFont(f); C(c or {.9,.94,.98}); love.graphics.printf(tostring(s or ""),x,y,w,align or "left") end
local function refresh() st.status="REFRESHING INTERFACE STATE…"; bridge.call("network_status",{},function(r) if r.ok and r.network then st.network=r.network; st.info=r.network.info or {}; st.status="INTERFACE STATE UPDATED" else st.status="NETWORK STATUS · "..tostring(r.error or "failed") end end); bridge.call("system_info",{},function(r) if r.ok then st.system=r.info or {} end end) end
local function probe() if st.busy then return end; st.busy=true; st.status="RUNNING ROUTE / DNS / INTERNET CHECKS…"; bridge.call("network_probe",{},function(r) st.busy=false; if r.ok then st.probe=r.probe or {}; st.status="NETWORK PROBE COMPLETE" else st.status="PROBE · "..tostring(r.error or "failed") end end) end
function M.enter() st.t=0; st.busy=false; refresh(); probe(); input.clear(); input.on("press",function(a) if a=="a" then probe() elseif a=="y" then refresh() elseif a=="x" then sm.push("hub_wifi",{}) elseif a=="l1" then sm.push("hub_hotspot",{}) elseif a=="r1" then sm.push("hub_bluetooth",{}) elseif a=="b" then sm.back() end end) end
function M.leave() input.clear() end; function M.update(dt) st.t=st.t+dt end
local function row(label,value,y) T(label,28,y,150,8,{.56,.72,.82}); T(value or "—",180,y,410,9,{.92,.96,.99},"right",true) end
function M.draw()
 local W,H=love.graphics.getDimensions(); bg.draw(W,H,st.t,"probe",CYAN,1); T("UPLINK  /  NETWORK MAINTENANCE",14,9,W-28,8,{.38,.83,.97},"left",true); T("NETWORK PROBE",14,24,W-28,20,{.94,.97,1},"left",true)
 C({.02,.055,.08},.95); love.graphics.rectangle("fill",12,59,W-24,168,7,7); C(CYAN,.48); love.graphics.rectangle("line",12,59,W-24,168,7,7); T("LOCAL CONNECTION",22,70,W-44,8,{.45,.82,.96},"left",true)
 row("Hostname",st.system.hostname or st.info.hostname,93); row("Local IP",st.system.ip or (st.network.wifi or {}).ip,115); row("Default gateway",st.probe.gateway or st.info.gateway,137); row("Interface",st.probe.interface,159); row("Wi-Fi SSID",(st.network.wifi or {}).ssid,181); row("Bluetooth",(st.network.bt or {}).name,203)
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",12,237,W-24,121,7,7); C(CYAN,.3); love.graphics.rectangle("line",12,237,W-24,121,7,7); T("ACTIVE PROBES",22,247,W-44,8,{.45,.82,.96},"left",true)
 row("Internet / ICMP",st.probe.internet==nil and "NOT AVAILABLE" or st.probe.internet and "REACHABLE" or "NO REPLY",269); row("DNS resolution",st.probe.dns==nil and "NOT AVAILABLE" or st.probe.dns and "RESOLVED" or "FAILED",291); row("Latency",st.probe.latency_ms and (tostring(st.probe.latency_ms).." ms") or "—",313)
 T(st.status,12,H-53,W-24,7,{.49,.82,.95},"center"); T("A RUN PROBE   Y REFRESH   X WI-FI   L1 HOTSPOT   R1 BLUETOOTH",8,H-34,W-16,7,{.72,.87,.95},"center",true); T("B BACK",8,H-16,W-16,7,{.72,.87,.95},"center"); love.graphics.setColor(1,1,1,1)
end
return M