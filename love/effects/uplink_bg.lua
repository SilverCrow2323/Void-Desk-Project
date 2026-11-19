local M={}
local function C(c,a) love.graphics.setColor(c[1],c[2],c[3],a or 1) end
function M.draw(W,H,t,mode,accent,alpha)
 accent=accent or {.22,.78,.96}; alpha=alpha or 1
 love.graphics.clear(.008,.018,.032,1)
 for i=0,12 do C({.12,.30,.42},.10*alpha); local y=(i*42+t*5)%H; love.graphics.line(0,y,W,y) end
 for i=0,10 do C({.10,.24,.34},.07*alpha); local x=(i*68-t*3)%W; love.graphics.line(x,0,x,H) end
 if mode=="wifi" then
  local cx,cy=W*.78,H*.35
  for i=1,4 do C(accent,(.22-i*.035)*alpha); love.graphics.arc("line","open",cx,cy,18+i*23+(t*12)%18,math.rad(205),math.rad(335)) end
  C(accent,.2*alpha); love.graphics.circle("fill",cx,cy,4)
 elseif mode=="hotspot" then
  local cx,cy=W*.5,H*.24
  for i=1,5 do C(accent,.16*alpha); love.graphics.circle("line",cx,cy,12+i*23+(t*17)%23) end
  C(accent,.28*alpha); love.graphics.circle("fill",cx,cy,5)
 elseif mode=="bluetooth" then
  local cx,cy=W*.78,H*.38
  for i=1,7 do local x=(i*79+t*13)%W; local y=(i*47+math.sin(t+i)*25)%H; C(accent,.18*alpha); love.graphics.line(cx,cy,x,y); love.graphics.circle("fill",x,y,2) end
 elseif mode=="server" then
  for i=1,5 do local x=W*.58+(i-1)*21; C(accent,.12*alpha); love.graphics.rectangle("line",x,H*.16,14,H*.58,2,2); for j=1,4 do C(accent,(.2+.1*math.sin(t*2+i+j))*alpha); love.graphics.circle("fill",x+7,H*.22+j*H*.115,1.8) end end
 elseif mode=="transfer" then
  for i=1,12 do local y=(i*29+t*(18+i%3*8))%H; local x=(i*53)%W; C(accent,.16*alpha); love.graphics.line(x,y,x+44,y); C(accent,.5*alpha); love.graphics.circle("fill",x+(t*42%44),y,2) end
 elseif mode=="probe" then
  local cx,cy=W*.78,H*.36
  for i=1,4 do C(accent,.13*alpha); love.graphics.circle("line",cx,cy,i*27) end
  C(accent,.45*alpha); love.graphics.arc("line","open",cx,cy,108,t*.7,t*.7+1.1); love.graphics.line(cx,cy,cx+math.cos(t*.7)*108,cy+math.sin(t*.7)*108)
 else
  local pts={}
  for i=1,9 do local x=((i-1)%3)*W*.36+W*.14; local y=math.floor((i-1)/3)*H*.28+H*.18; pts[i]={x=x+math.sin(t*.5+i)*5,y=y+math.cos(t*.6+i)*4} end
  for i=1,#pts do for j=i+1,#pts do if j-i==1 or j-i==3 then C(accent,.10*alpha); love.graphics.line(pts[i].x,pts[i].y,pts[j].x,pts[j].y) end end; C(accent,.22*alpha); love.graphics.circle("fill",pts[i].x,pts[i].y,2) end
  for i=1,18 do local x=(i*73+t*(8+i%4*2))%W; local y=(i*41+math.sin(t+i)*16)%H; C(accent,.22*alpha); love.graphics.circle("fill",x,y,1.2) end
 end
 love.graphics.setColor(1,1,1,1)
end
return M