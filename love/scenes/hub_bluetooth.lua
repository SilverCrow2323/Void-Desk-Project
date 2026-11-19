local sm=require("core.scene_manager")
local input=require("core.input")
local bridge=require("core.bridge")
local font=require("core.font")
local icon=require("core.icon")
local bg=require("effects.uplink_bg")
local M={}
local CYAN={.22,.80,.98}
local st={bt={},devices={},selected=1,t=0,busy=false,status="READING BLUETOOTH STATE",
 confirm_remove=false,pending_mac=nil}

local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b)
 local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z)
 love.graphics.setFont(f); C(c or {.9,.94,.98})
 love.graphics.printf(tostring(s or ""),x,y,w,align or "left")
end
local function refresh()
 bridge.call("network_status",{},function(r)
  if r.ok and r.network then
   st.bt=r.network.bt or {}; st.status="BLUETOOTH STATUS UPDATED"
  else st.status="STATUS · "..tostring(r.error or "unavailable") end
 end)
end
local function scan()
 if st.busy then return end
 st.busy=true; st.status="SCANNING NEARBY DEVICES…"
 bridge.call("bt_scan",{},function(r)
  st.busy=false
  if r.ok then
   st.devices=r.devices or {}
   st.selected=math.min(st.selected,math.max(1,#st.devices))
   st.status=tostring(#st.devices).." DEVICES DISCOVERED"
  else st.status="SCAN · "..tostring(r.error or "unavailable") end
 end)
end
local function selected_device()
 return st.devices[st.selected]
end
local function action(name)
 local d=selected_device()
 if not d or not d.mac then st.status="SELECT A DISCOVERED DEVICE FIRST"; return end
 if name=="remove" and not d.paired then
  st.status="THIS DEVICE IS NOT PAIRED"; return
 end
 st.busy=true; st.status=string.upper(name).." · "..tostring(d.name or d.mac)
 bridge.call("bt_action",{action=name,mac=d.mac},function(r)
  st.busy=false
  if r.confirm_required then
   st.pending_mac=d.mac; st.confirm_remove=true
   st.status="CONFIRM · REMOVE BLUETOOTH PAIRING"
  else
   st.confirm_remove=false; st.pending_mac=nil
   st.status=r.ok and (r.output or (string.upper(name).." COMPLETE")) or tostring(r.error or "Bluetooth action failed")
   refresh()
   if name=="remove" or name=="pair" then scan() end
  end
 end)
end
local function remove_pairing(confirm)
 local mac=st.pending_mac
 if not mac then st.confirm_remove=false; return end
 st.busy=true; st.status="REMOVING BLUETOOTH ASSOCIATION…"
 bridge.call("bt_action",{action="remove",mac=mac,confirm=confirm==true},function(r)
  st.busy=false; st.confirm_remove=false; st.pending_mac=nil
  st.status=r.ok and "PAIRING REMOVED" or tostring(r.error or "Unpair failed")
  refresh(); scan()
 end)
end
local function power()
 if not st.bt.available then st.status="BLUETOOTH ADAPTER NOT AVAILABLE"; return end
 st.busy=true
 local name=st.bt.on and "power_off" or "power_on"
 st.status="CHANGING BLUETOOTH POWER…"
 bridge.call("bt_action",{action=name},function(r)
  st.busy=false
  st.status=r.ok and "BLUETOOTH POWER UPDATED" or tostring(r.error or "Power action failed")
  refresh()
 end)
end

function M.enter()
 st.t=0; st.busy=false; st.selected=1; st.devices={}
 st.confirm_remove=false; st.pending_mac=nil
 refresh(); scan(); input.clear()
 input.on("press",function(a)
  if st.confirm_remove then
   if a=="a" then remove_pairing(true)
   elseif a=="b" then st.confirm_remove=false; st.pending_mac=nil; st.status="UNPAIR CANCELLED" end
   return
  end
  if st.busy and a~="b" then return end
  if a=="up" then st.selected=math.max(1,st.selected-1)
  elseif a=="down" then st.selected=math.min(math.max(1,#st.devices),st.selected+1)
  elseif a=="a" then action("pair")
  elseif a=="x" then action("connect")
  elseif a=="l1" then action("trust")
  elseif a=="r1" then action("disconnect")
  elseif a=="select" then action("remove")
  elseif a=="start" then power()
  elseif a=="y" then scan()
  elseif a=="b" then sm.back() end
 end)
end
function M.leave() input.clear() end
function M.update(dt) st.t=st.t+dt end

function M.draw()
 local W,H=love.graphics.getDimensions()
 bg.draw(W,H,st.t,"bluetooth",CYAN,1)
 T("UPLINK  /  DEVICE RADIO",14,9,W-28,8,{.38,.83,.97},"left",true)
 T("BLUETOOTH",14,24,W-28,21,{.94,.97,1},"left",true)
 C({.02,.055,.08},.95); love.graphics.rectangle("fill",12,61,W-24,76,7,7)
 C(CYAN,.48); love.graphics.rectangle("line",12,61,W-24,76,7,7)
 icon.draw("bluetooth",23,79,29,st.bt.on and CYAN or {.52,.62,.7})
 T(st.bt.name or "Bluetooth adapter",64,71,W-84,10,{.94,.97,1},"left",true)
 T(st.bt.available and (st.bt.on and "POWERED ON" or "POWERED OFF") or "NO ADAPTER",
   64,91,W-84,8,st.bt.on and CYAN or {.68,.75,.82})
 T("PAIRED DEVICES  "..tostring(st.bt.count or 0),64,109,W-84,8,{.58,.72,.82})
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",12,145,W-24,H-205,7,7)
 C(CYAN,.3); love.graphics.rectangle("line",12,145,W-24,H-205,7,7)
 T("DISCOVERED DEVICES",22,154,W-44,8,{.46,.82,.96},"left",true)
 for i=1,math.min(6,#st.devices) do
  local d=st.devices[i]; local y=177+(i-1)*31
  if i==st.selected then
   C(CYAN,.14); love.graphics.rectangle("fill",20,y-3,W-40,27,4,4)
   C(CYAN,.75); love.graphics.rectangle("line",20,y-3,W-40,27,4,4)
  end
  T(d.name or "Unknown device",28,y+1,W*.46,8,{.92,.96,.99},"left",true)
  T(d.paired and "PAIRED" or "DISCOVERED",W*.53,y+2,W*.18,7,
    d.paired and {.4,.9,.58} or {.68,.74,.81},"right",true)
  T(d.mac or "",W*.72,y+2,W*.24,6,{.57,.73,.84},"right")
 end
 if #st.devices==0 then
  T(st.busy and "Scanning…" or "No nearby devices · press Y to scan",
    22,215,W-44,9,{.59,.72,.82},"center")
 end
 T(st.status,12,H-54,W-24,7,{.49,.82,.95},"center")
 T("START POWER   A PAIR   X CONNECT   L1 TRUST   R1 DISCONNECT",
   8,H-36,W-16,7,{.72,.87,.95},"center",true)
 T("SELECT UNPAIR   Y SCAN   B BACK",8,H-19,W-16,7,{.72,.87,.95},"center")
 if st.confirm_remove then
  C({.008,.018,.03},.90); love.graphics.rectangle("fill",0,0,W,H)
  local bx,by,bw,bh=42,H*.36,W-84,122
  C({.025,.055,.08},.99); love.graphics.rectangle("fill",bx,by,bw,bh,7,7)
  C({1,.68,.28},.95); love.graphics.setLineWidth(2); love.graphics.rectangle("line",bx,by,bw,bh,7,7)
  T("REMOVE BLUETOOTH PAIRING?",bx+12,by+14,bw-24,11,{1,.72,.36},"center",true)
  T("This device will need to be paired again before reconnecting.",bx+16,by+42,bw-32,8,{.86,.91,.96},"center")
  T("A CONFIRM     B CANCEL",bx+12,by+86,bw-24,8,CYAN,"center",true)
 end
 love.graphics.setColor(1,1,1,1)
end
return M
