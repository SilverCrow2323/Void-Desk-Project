local sm=require("core.scene_manager")
local input=require("core.input")
local bridge=require("core.bridge")
local font=require("core.font")
local icon=require("core.icon")
local bg=require("effects.uplink_bg")
local M={}
local CYAN={.22,.80,.98}
local st={wifi={},info={},profiles={},networks={},mode="saved",selected=1,
 t=0,status="READING WI-FI STATE",busy=false,confirm_forget=false,pending_id=nil}

local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
local function T(s,x,y,w,z,c,align,b)
 local f=(b and font.bold or font.regular)(z) or love.graphics.newFont(z)
 love.graphics.setFont(f); C(c or {.9,.94,.98})
 love.graphics.printf(tostring(s or ""),x,y,w,align or "left")
end
local function request_status()
 bridge.call("network_status",{},function(r)
  if r.ok and r.network then
   st.wifi=r.network.wifi or {}; st.info=r.network.info or {}
   st.status="WI-FI STATUS UPDATED"
  else st.status="STATUS · "..tostring(r.error or "unavailable") end
 end)
end
local function load_saved()
 bridge.call("wifi_saved",{},function(r)
  if r.ok then
   st.profiles=r.profiles or {}
   if st.mode=="saved" and #st.profiles==0 then st.mode="nearby" end
  else
   st.profiles={}; st.status="SAVED PROFILES · "..tostring(r.error or "unavailable")
  end
 end)
end
local function scan()
 if st.busy then return end
 st.busy=true; st.status="SCANNING NEARBY NETWORKS…"
 bridge.call("wifi_scan",{},function(r)
  st.busy=false
  if r.ok then
   st.networks=r.networks or {}; st.mode="nearby"; st.selected=1
   st.status=tostring(#st.networks).." NETWORKS FOUND"
  else st.status="SCAN · "..tostring(r.error or "unavailable") end
 end)
end
local function current_rows()
 return st.mode=="saved" and st.profiles or st.networks
end
local function switch_mode(mode)
 st.mode=mode; st.selected=1
 if mode=="saved" then load_saved() else scan() end
end
local function select_profile()
 local p=current_rows()[st.selected]
 if st.mode~="saved" or not p then
  st.status="NEW NETWORKS MUST BE CONFIGURED IN muOS"
  return
 end
 st.busy=true; st.status="CONNECTING TO "..tostring(p.ssid or "SAVED NETWORK").."…"
 bridge.call("wifi_profile_action",{action="select",id=p.id},function(r)
  st.busy=false
  st.status=r.ok and ("CONNECTING · "..tostring(r.ssid or p.ssid)) or ("CONNECT · "..tostring(r.error or "failed"))
  request_status()
 end)
end
local function forget_profile(confirm)
 local p=st.pending_id and {id=st.pending_id} or current_rows()[st.selected]
 if not p or not p.id then st.status="SELECT A SAVED PROFILE"; return end
 st.busy=true; st.status="FORGETTING SAVED NETWORK…"
 bridge.call("wifi_profile_action",{action="forget",id=p.id,confirm=confirm==true},function(r)
  st.busy=false
  if r.confirm_required then
   st.pending_id=p.id; st.confirm_forget=true
   st.status="CONFIRM · REMOVE SAVED WI-FI PROFILE"
  else
   st.confirm_forget=false; st.pending_id=nil
   st.status=r.ok and (r.saved and "SAVED WI-FI PROFILE REMOVED" or "PROFILE REMOVED · PERSISTENCE NOT CONFIRMED") or ("FORGET · "..tostring(r.error or "failed"))
   load_saved()
  end
 end)
end
local function simple_profile_action(action)
 st.busy=true; st.status=action=="disconnect" and "DISCONNECTING WI-FI…" or "REASSOCIATING WI-FI…"
 bridge.call("wifi_profile_action",{action=action},function(r)
  st.busy=false
  st.status=r.ok and string.upper(tostring(r.state or "DONE")) or (string.upper(action).." · "..tostring(r.error or "failed"))
  request_status()
 end)
end

function M.enter()
 st.selected=1; st.t=0; st.busy=false; st.confirm_forget=false; st.pending_id=nil
 request_status(); load_saved(); scan()
 input.clear()
 input.on("press",function(a)
  if st.confirm_forget then
   if a=="a" then forget_profile(true)
   elseif a=="b" then st.confirm_forget=false; st.pending_id=nil; st.status="FORGET CANCELLED" end
   return
  end
  local rows=current_rows()
  if a=="up" then st.selected=math.max(1,st.selected-1)
  elseif a=="down" then st.selected=math.min(math.max(1,#rows),st.selected+1)
  elseif a=="a" then select_profile()
  elseif a=="x" then if st.mode=="saved" then forget_profile(false) else st.status="SWITCH TO SAVED PROFILES TO FORGET A NETWORK" end
  elseif a=="y" then scan(); load_saved()
  elseif a=="start" then simple_profile_action("disconnect")
  elseif a=="l1" or a=="r1" then switch_mode(st.mode=="saved" and "nearby" or "saved")
  elseif a=="b" then sm.back() end
 end)
end
function M.leave() input.clear() end
function M.update(dt) st.t=st.t+dt end

function M.draw()
 local W,H=love.graphics.getDimensions()
 bg.draw(W,H,st.t,"wifi",CYAN,1)
 T("UPLINK  /  RADIO CONTROL",14,9,W-28,8,{.38,.83,.97},"left",true)
 T("WI-FI",14,24,W-28,21,{.94,.97,1},"left",true)
 C({.02,.055,.08},.95); love.graphics.rectangle("fill",12,59,W-24,75,7,7)
 C(CYAN,.5); love.graphics.rectangle("line",12,59,W-24,75,7,7)
 local on=st.wifi.radio_on==true
 icon.draw("wifi",22,77,28,on and CYAN or {.5,.59,.67})
 T(on and "RADIO ENABLED" or st.wifi.radio_on==false and "RADIO DISABLED" or "RADIO STATE UNKNOWN",60,68,W-78,10,on and CYAN or {.7,.76,.82},"left",true)
 T("CONNECTED TO  "..tostring(st.wifi.ssid or "—"),60,86,W-78,8,{.82,.9,.96})
 T("IP  "..tostring(st.wifi.ip or "—").."   ·   GATEWAY  "..tostring(st.info.gateway or "—"),60,105,W-78,7,{.58,.72,.82})
 local saved=st.mode=="saved"
 local tab_y=143
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",12,tab_y,W-24,26,5,5)
 C(saved and CYAN or {.12,.28,.38},saved and .35 or .2); love.graphics.rectangle("fill",16,tab_y+3,(W-40)/2,20,3,3)
 C(not saved and CYAN or {.12,.28,.38},not saved and .35 or .2); love.graphics.rectangle("fill",W/2+4,tab_y+3,(W-40)/2,20,3,3)
 T("SAVED PROFILES",20,tab_y+8,(W-40)/2,8,saved and CYAN or {.54,.67,.77},"center",true)
 T("NEARBY NETWORKS",W/2+8,tab_y+8,(W-40)/2,8,not saved and CYAN or {.54,.67,.77},"center",true)
 local panel_y=176; local panel_h=H-247
 C({.018,.042,.064},.94); love.graphics.rectangle("fill",12,panel_y,W-24,panel_h,7,7)
 C(CYAN,.3); love.graphics.rectangle("line",12,panel_y,W-24,panel_h,7,7)
 local rows=current_rows()
 T(saved and "KNOWN WI-FI CONNECTIONS" or "DETECTED ACCESS POINTS",22,panel_y+9,W-44,8,{.45,.82,.96},"left",true)
 for i=1,math.min(5,#rows) do
  local row=rows[i]; local y=panel_y+29+(i-1)*34
  if i==st.selected then
   C(CYAN,.13); love.graphics.rectangle("fill",19,y-3,W-38,29,4,4)
   C(CYAN,.7); love.graphics.rectangle("line",19,y-3,W-38,29,4,4)
  end
  T(row.ssid or "Hidden network",28,y+1,W*.48,8,{.92,.96,.99},"left",true)
  local meta
  if saved then meta=row.current and "CONNECTED" or row.disabled and "DISABLED" or ("PROFILE #"..tostring(row.id))
  else meta=tostring(row.signal or 0).."%  ·  "..(row.secure and "SECURED" or "OPEN") end
  T(meta,W*.53,y+2,W*.37,7,row.current and {.4,.9,.55} or {.57,.73,.84},"right")
 end
 if #rows==0 then
  local msg=st.busy and "Working…" or saved and "No saved profiles · switch to Nearby or configure in muOS" or "No scan results · press Y to scan"
  T(msg,24,panel_y+67,W-48,8,{.59,.72,.82},"center")
 end
 T(st.status,12,H-57,W-24,7,{.49,.82,.95},"center")
 T("A CONNECT   X FORGET   START DISCONNECT   Y SCAN",8,H-39,W-16,7,{.72,.87,.95},"center",true)
 T("L1/R1 SWITCH TAB   B BACK",8,H-23,W-16,7,{.72,.87,.95},"center")
 if st.confirm_forget then
  C({.008,.018,.03},.90); love.graphics.rectangle("fill",0,0,W,H)
  local bx,by,bw,bh=42,H*.36,W-84,120
  C({.025,.055,.08},.99); love.graphics.rectangle("fill",bx,by,bw,bh,7,7)
  C({1,.68,.28},.95); love.graphics.setLineWidth(2); love.graphics.rectangle("line",bx,by,bw,bh,7,7)
  T("FORGET SAVED NETWORK?",bx+12,by+14,bw-24,11,{1,.72,.36},"center",true)
  T("The selected profile will be removed from wpa_supplicant.",bx+16,by+42,bw-32,8,{.86,.91,.96},"center")
  T("A CONFIRM     B CANCEL",bx+12,by+84,bw-24,8,CYAN,"center",true)
 end
 love.graphics.setColor(1,1,1,1)
end
return M
