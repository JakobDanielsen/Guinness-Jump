pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- guinnes jump
-- jakob

--todo:
	--[[
		-- mer eye candy!!
		-- sikkert no problemer med speedrun clock
		--win condition
		--npc
	--]]
function _init()
				
				speedrun_mode = false
				update_speedrun_menu()
				
				
				cartdata("guinnes_jump_data")
				weird_mode_unlocked = false
				if dget(0)==1 then
					weird_mode_unlocked = true
				end
    if weird_mode_unlocked then
   		menuitem(2, "weird mode??? ", function() 
    		weird_mode = not weird_mode 
    		if weird_mode then respawn(450) else respawn(220) end
 				 if weird_mode then
 				  sfx(13)
 				  show_big_text("?????") 
 				 end
 				end)
 			end
 			if dget(1)==1 then
 				speedrun_mode = true
				end
 			
    poke(0x5f2d, 1) --mouse devkit
    poke(0x5f36,0x2) -- even circles
    _set_fps(60)
    entityinit()
    bgclr = 0
end

function update_speedrun_menu()
 			 menuitem(1, "speedrun: "..tostr(speedrun_mode), function()
    speedrun_mode = not speedrun_mode
    if speedrun_mode then
    	dset(1,1)
    else
    	dset(1,0)
    end
    update_speedrun_menu()
  			end)
				end

function _update60()
	if not game_over then
	update_wind()
	snwmake()
	bgsnwmake()
	bgcloudmake()
	fgcloudmake()
	 timer += 1 -- dette holder vれすret i gang
		if not cant_move then 
    
    speedrun_frames += 1
    if speedrun_frames >= 60 then
        speedrun_seconds += 1
        speedrun_frames = 0
    end
		end
		slingshot_update()
		move_player(player)
		if weird_mode then
			update_red_coins()
		end
		updatevariables()
		display_zone_name()
		rnd_ambientsound()
		
		if weird_mode then
			check_win(1) //weird
			check_win(2) // coins
		else
			check_win(0) // normal
		end
		zone_control()
	 if btn(⬆️) then player.vy =-3 end
	 if btn(⬅️) then player.vx =-2 end
		if btn(➡️) then player.vx =2 end
	 if btn(⬇️) then player.vx =0 end
		if (speedrun_mode or cant_move) and (btn(🅾️) and btn(❎)) then
			if weird_mode then
				respawn(450)
			else
				respawn(220)
			end
		end

	end
	updatemouse()
	if cant_move then _game_over_delay_counter +=1 end
end

function _draw()
	pal()
	palt(0, false)
 palt(11, true)
	if weird_mode then
		poke(0x5f2e,1)
		poke(0x5f2e,1)
  --pal({[0]=-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1},1)
		pal({[0]=0,-15,-14,3,-12,-11,-10,7,-8,-2,-7,11,-4,-3,14,15},1)
	end
	
	
	cls(bgclr)
	camera(cam.x,cam.y)
	prtdraw(bgsnw)
	clouddraw(bgclouds)
	--print(player.x, cam.x,cam.y)
	--print(player.y, cam.x,cam.y+7)
	
	-- tegner tれしrnet basert pれし mapsegs
	
	-- tegner kartet avhengig av mode
	if weird_mode then
		-- tegner standard pico-8 map (128x64 tiles) i posisjon 0,0
		map(0, 0, 0, 0, 128, 64)
	else
		-- tegner tれしrnet basert pれし mapsegs
		for i=1,#mapsegs do
			local seg = mapsegs[i]
			local world_y = -(i-1)*256
			map(seg.mx, seg.my, 0, world_y, 32, 32)
		end
	end
	
	draw_npcs()
	draw_player()
	draw_coins() 
	clouddraw(fgclouds)
	draw_grab_point()
	draw_trajectory()
	draw_particles()
	if cant_move and _game_over_delay_counter >= _game_over_delay then draw_victory_screen() end
	draw_big_text()
	prtdraw(snw)
	draw_mouse()
	--print(player.x,cam.x,cam.y+6)
	--print(snowfrequency,cam.x,cam.y)
 --print(player.y,cam.x,cam.y+6+6)
 --print(player.grounded,cam.x,cam.y+6+6+6)
	--print(bgsnowfrequency,cam.x,cam.y+6)
	draw_coin_meter()
	draw_speedrun_clock()
end
-->8
--draw 

function draw_player()
	if not player.alive then p_sprite=33 end
	spr(1,flr(player.x),flr(player.y))
end

function draw_mouse()
	pset(mouse.x,mouse.y,7)
end

function draw_grab_point()
	if player.alive and player.grounded and (overlap(mouse,player)or grab_point.grabbed) and not cant_move then
		spr(2,
		mid(player.x+player.cx-grab_point.cx-max_radius_x,grab_point.x,player.x+max_radius_x+player.cx-grab_point.cx),
		mid(player.y+player.cy-grab_point.cy-max_radius_y,grab_point.y,player.y+max_radius_y+player.cy-grab_point.cy))
	end
end

function draw_trajectory()
	if grab_point.grabbed then
		local intensity = 2
		local dotdensity = 2
	 local x0 = flr(player.x + player.cx)
	 local y0 = flr(player.y + player.cy)
	 local x1 = flr(x0 + potential_vx * intensity)
	 local y1 = flr(y0 + potential_vy * intensity)
	 local dx = abs(x1 - x0)
	 local dy = abs(y1 - y0)
	 local sx = x0 < x1 and 1 or -1
	 local sy = y0 < y1 and 1 or -1
	 local err = dx - dy
	 local i = 0
	 while true do
	  if i % dotdensity == 0 then
	   pset(x0, y0, 7)
	  end
	  if x0 == x1 and y0 == y1 then break end
	  local e2 = err * 2
	  if e2 > -dy then
	   err -= dy
	   x0 += sx
	  end
	  if e2 < dx then
	   err += dx
	   y0 += sy
	  end
	  i += 1
	 end
	end
end

function draw_particles()
	for p in all(particles) do
		circfill(round(p.x),round(p.y),p.r,7)
		if flr(rnd(10))==1 then p.r-=0.8 end
		if p.r <= 0 then del(particles, p) end 
	end
end

function print_wave(txt, x, y, col)
    local speed = 1       -- hvor raskt bれまlgen ruller
    local amplitude = 1.9     -- hvor mange piksler den spretter opp og ned
    local wave_length = 0.05 -- hvor stor forskyvning det er mellom hver bokstav
    
    for i = 1, #txt do
        local char = sub(txt, i, i)
        
        -- standard pico-8-font er 4 piksler bred per bokstav
        local char_x = x + (i - 1) * 4 
        
        -- regner ut y-posisjonen basert pれし tid og bokstavens plassering i ordet
        local char_y = y + sin(t() * speed - i * wave_length) * amplitude
        
        print(char, char_x, char_y, col)
    end
end

victory_music_played = false
function draw_victory_screen()
	if not victory_music_played then 
		music(10) 
		victory_music_played = true
	end
	local r = {
	x1=cam.x+10,
	y1=cam.y+20,
	x2=cam.x+128-10,
	y2=cam.y+128-40}
	rectfill(r.x1,r.y1,r.x2,r.y2,1)
	rect(r.x1+1,r.y1+1,r.x2-1,r.y2-1,7)
	--print ("time: "..format_time(timer),cam.x+10+10-1,cam.y+31+50+1,13)
	print("jumps: "..jump_counter,cam.x+30,cam.y+40,7)

	print ("time: "..format_time(speedrun_seconds),cam.x+30,cam.y+31+40,7)
	print ("press z + x to restart",r.x1+3,r.y2-7,5)
	if not wm_unlock_seen and (_game_over_delay_counter> _game_over_delay+180)  then
		print_wave("weird mode added to pause menu",r.x1-5,r.y2+20-7,2)
		print_wave("weird mode added to pause menu",r.x1-5-1,r.y2+20-7-1,7)
	end

end




function draw_npc(npc)
	spr(npc.spr,npc.x,npc.y)
end

function draw_npcs()
	draw_npc(pils)
end

function draw_coin(x,y)
	sprite = 11+ time()*5%4
	spr(sprite,x,y)
end

function draw_coins()
	if not weird_mode then return end
	for c in all(red_coins) do
		if not c.taken then
			draw_coin(c.x,c.y)
		end
	end
end

function draw_coin_meter()
	if player.red_coins > 0 then
	 print("["..player.red_coins.."/6]",cam.x+2,cam.y+2,8)
	end
end

function draw_speedrun_clock()
    if speedrun_mode then print(format_time(speedrun_seconds),cam.x+96,cam.y+1,7) end
end
-->8
--enitty info
function entityinit()
	gravity = 0.18
	terminal_velocity = 6
	jump_counter = 0
	
	timer = 0 -- beholdes for snれま og skyer
	speedrun_frames = 0
	speedrun_seconds = 0
	
	weird_mode = false
	
	-- her er hele kartet ditt:
	mapsegs = {
		{mx=0,  my=32}, -- seksjon 1: nede venstre
		{mx=0,  my=0},  -- seksjon 2: opp en
		{mx=32, my=32}, -- seksjon 3: hれまyre og ned
		{mx=32, my=0},  -- seksjon 4: opp en
		{mx=64, my=32}, -- seksjon 5: hれまyre og ned
		{mx=64, my=0},  -- seksjon 6: opp en
		{mx=96, my=32}, -- seksjon 7: hれまyre og ned
		{mx=96, my=0}   -- seksjon 8: toppen av tれしrnet!
	}
	
	player = {
		x=-1,
		y=220, 
		w=5,
		h=8,
		vx=1,
		vy=-3,
		cx=2, 
		cy=4, 
		grounded=false,
		alive = true,
		remainder_x = 0,
		remainder_y = 0,
		red_coins = 0
	}
	
	mouse = { x=32, y=32, mouse_down = false, w=1, h=1 }
	grab_point = { x=nil, y=nil, w=3, h=3, cx=1, cy=1, grabbed = false }
	cam = { x=nil, y=nil }
	particles = {}
	
	
	-- npc's:
	
	pils = {
	x=235,y=-616,
	spr=111,
	dialogue=
	{"blablablabalabl",
	"my story? i escaped. escaped from a bar and opened up this shop",
	"hey! you're not supposed to be back here"}
	}
	
	red_coins={
		{x=30*8,y=33*8,taken=false,w=8,h=8
		},{x=63*8,y=18*8,taken=false,w=8,h=8
		},{x=93*8,y=62*8,taken=false,w=8,h=8
		},{x=63*8,y=35*8,taken=false,w=8,h=8
		},{x=91*8,y=1*8,taken=false,w=8,h=8
		},{x=119*8,y=59*8,taken=false,w=8,h=8
		}
	}
	
end
-->8
--moveplayer
function move_player(p)
  -- === sfx cooldown for slopes ===
  p.slope_sfx_timer = p.slope_sfx_timer or 0
  if p.slope_sfx_timer > 0 then p.slope_sfx_timer -= 1 end

  -- === justerbare sprett- og plattform-variabler ===
  local slope_bounce_y = 0.25 
  local slope_bounce_x = 0.5  
  local slope_extra_x  = 0.5  

  -- === y ===
  local dy = p.vy
  if not p.grounded then dy += gravity end
  dy = mid(-terminal_velocity, dy, terminal_velocity)
  p.vy = dy
  p.remainder_y += dy
  local move_y = flr(abs(p.remainder_y)) * sgn(p.remainder_y)
  p.remainder_y -= move_y
  local step_y = sgn(move_y)
  
  for i=1, abs(move_y) do
    p.y += step_y
    
    if step_y > 0 then
      local current_tile_left = get_world_tile(p.x, p.y + p.h)
      local current_tile_right = get_world_tile(p.x + p.w - 1, p.y + p.h)
      
      -- sjekk om vi lander delvis pれし en ekte solid blokk (flagg 0)
      local touching_solid = fget(current_tile_left, 0) or fget(current_tile_right, 0)
      
      -- 1. sjekk for venstre slope (flagg 2)
      if (fget(current_tile_left, 2) or fget(current_tile_right, 2)) and not touching_solid then
        p.y = flr((p.y + p.h) / 8) * 8 - p.h
        p.vy = -p.vy * slope_bounce_y
        p.vx = -abs(p.vy) * slope_bounce_x - slope_extra_x
        p.grounded = false
        if p.slope_sfx_timer == 0 then
          sfx(0)
          p.slope_sfx_timer = 30
        end
        break
        
      -- 2. sjekk for hれまyre slope (flagg 3)
      elseif (fget(current_tile_left, 3) or fget(current_tile_right, 3)) and not touching_solid then
        p.y = flr((p.y + p.h) / 8) * 8 - p.h
        p.vy = -p.vy * slope_bounce_y
        p.vx = abs(p.vy) * slope_bounce_x + slope_extra_x
        p.grounded = false
        if p.slope_sfx_timer == 0 then
          sfx(0)
          p.slope_sfx_timer = 30
        end
        break
        
      -- 3. sjekk for semi-solid (flagg 4)
      elseif fget(current_tile_left, 4) or fget(current_tile_right, 4) then
        local tile_top = flr((p.y + p.h) / 8) * 8
        if (p.y + p.h - step_y) <= tile_top then
          p.y = tile_top - p.h
          p.grounded = true
          p.vy = 0
          p.remainder_y = 0
          if player.alive then sfx(flr(rnd({4,5,6}))) end
          break
        end
      end
    end

    -- sjekker standard collision
    local hit_y = collide(p.x, p.y, p.w, p.h)
    
    -- hvis vi er pれし vei opp, sjekk om vi krasjer hodet inn i en slope (hindrer inni-klipping nedenfra)
    if not hit_y and step_y < 0 then
      local t_tl = get_world_tile(p.x, p.y)
      local t_tr = get_world_tile(p.x + p.w - 1, p.y)
      if fget(t_tl, 2) or fget(t_tl, 3) or fget(t_tr, 2) or fget(t_tr, 3) then
        hit_y = true
      end
    end

    -- standard solid-kollisjon (vanlige vegger/gulv/slope-tak)
    if hit_y then
      p.y -= step_y
      if step_y > 0 then
        p.y = flr((p.y + p.h) / 8) * 8 - p.h
        p.grounded = true
        if player.alive then sfx(flr(rnd({4,5,6}))) end
      else
        p.y = flr(p.y / 8) * 8
      end
      p.vy = 0
      p.remainder_y = 0
      break
    end
  end
  
  -- === x ===
  p.remainder_x += p.vx
  local dx = flr(abs(p.remainder_x) + 0.5) * sgn(p.remainder_x)
  p.remainder_x -= dx
  local step_x = sgn(dx)
  
  for i=1, abs(dx) do
    p.x += step_x
    
    local hit_x = collide(p.x, p.y, p.w, p.h)
    
    -- sjekk horisontalt for れし hindre at man "sklir inn i" sloper fra siden
    if not hit_x then
      local side_x = p.x
      if step_x > 0 then side_x = p.x + p.w - 1 end
      
      local t_top = get_world_tile(side_x, p.y)
      local t_bot = get_world_tile(side_x, p.y + p.h - 1)
      
      -- behandle sloper som solide vegger om vi treffer dem horisontalt
      if fget(t_top, 2) or fget(t_top, 3) or fget(t_bot, 2) or fget(t_bot, 3) then
        hit_x = true
      end
    end

    if hit_x then
      p.x -= step_x
      if step_x > 0 then
        p.x = flr((p.x + p.w) / 8) * 8 - p.w
      else
        p.x = flr(p.x / 8) * 8
      end
      p.vx = (p.vx * -1) * 0.3
      p.remainder_x = 0
      break
    end
  end

  -- === oppdatert og flyttet grounded-sjekk ===
  -- nれし sjekker vi etter x-bevegelsen, slik at vi garantert vet om vi har bakke under oss
  p.grounded = false
  if p.vy >= 0 then
    if collide(p.x, p.y + 1, p.w, p.h) then
      p.grounded = true
    else
      local t_left = get_world_tile(p.x, p.y + p.h + 1)
      local t_right = get_world_tile(p.x + p.w - 1, p.y + p.h + 1)
      if fget(t_left, 4) or fget(t_right, 4) then
        -- lれまsningen: vi er kun grounded pれし en semi-solid hvis bunnen av spilleren 
        -- ligger 100% kant-i-kant med toppen av tilen
        local foot_y = p.y + p.h
        if foot_y == flr((foot_y + 1) / 8) * 8 then
          p.grounded = true
        end
      end
    end
  end
  
  -- === friksjon ===
  local on_ice = p.grounded and is_ice(p.x, p.y, p.w, p.h)
  
  if p.grounded and not on_ice then
    -- sjekk at vi ikke aktivt styrer spilleren fれまr vi bremser opp
    if not (btn(0) or btn(1)) then
      p.vx *= 0.2 -- juster nedbremsing her (0.2 er rask stopp, 0.8 er glattere)
      if abs(p.vx) < 0.2 then 
        p.vx = 0 
        p.remainder_x = 0
      end
    end
  end
  
  -- begrensninger for tれしrnet
  if weird_mode then
    p.x = mid(0, p.x, 1024 - p.w)
    p.y = mid(0, p.y, 800 - p.h)
  else
    p.x = mid(0, p.x, 256 - p.w)
    p.y = mid(-1992, p.y, 256 - p.h)
  end
  
end
-->8
-- ny kart og kollisjonslogikk
-- finner riktig map-tile i spritesheetet basert pれし vertikal posisjon
function get_world_tile(px, py)
	-- weird mode: mappet er akkurat som i editoren
	if weird_mode then
		return mget(flr(px / 8), flr(py / 8))
	end

	-- vanlig mode: finner ut hvilken seksjon spilleren er i
	local seg_index = flr((255 - py) / 256) + 1
	if seg_index < 1 or seg_index > #mapsegs then return 0 end
	
	local seg = mapsegs[seg_index]
	
	local tx = seg.mx + flr(px / 8)
	local ty = seg.my + flr((py + ((seg_index - 1) * 256)) / 8)
	
	return mget(tx, ty)
end

function is_solid(px, py)
	-- veggene utenfor sidene og bunnen av mappet er alltid solide
	if weird_mode then
		if px < 0 or px > 1023 or py > 800 then return true end
	else
		if px < 0 or px > 255 or py > 255 then return true end 
	end
	
	return fget(get_world_tile(px, py), 0)
end

function is_ice(x, y, w, h)
	return fget(get_world_tile(x, y + h), 1) or fget(get_world_tile(x + w - 1, y + h), 1)
end

function collide(x, y, w, h)
	return is_solid(x, y)
			or is_solid(x + w - 1, y)
			or is_solid(x, y + h - 1)
			or is_solid(x + w - 1, y + h - 1)
end

function overlap(a, b)
 return a.x < b.x + b.w and a.x + a.w > b.x
    and a.y < b.y + b.h and a.y + a.h > b.y
end

-->8
--update variebles

function updatevariables()
	--camera (lれしst til det 256 piksler brede og nれし 2048 piksler hれまye tれしrnet)
	local px = flr(player.x)
	local py = flr(player.y)
	
	if weird_mode then
		-- kameraet stopper ved map-kantene (1024 bredt, 512 hれまyt)
		cam.x = mid(0, px - 64 + 4, 1024 - 128)
		cam.y = mid(0, py - 64, 512 - 128)
		if py>730 then
			 respawn(450)
			 sfx(38)
		 end
	else
		cam.x = mid(0, px - 64 + 4, 128)
		cam.y = mid(-1992, py - 64, 128)
	end
	
	--grab_point
	if grab_point.grabbed then
		grab_point.x=mouse.x-grab_point.cx
		grab_point.y=mouse.y-grab_point.cy
	else
		grab_point.x=player.x+player.cx-grab_point.cx
		grab_point.y=player.y+player.cy-grab_point.cy
	end
	
	--grabbing
	if player.alive and not cant_move and (overlap(mouse,player)or overlap(mouse,grab_point)) and mouse.mouse_down then
		grab_point.grabbed = true
	else 
		grab_point.grabbed = false
	end
end
-->8
--other functions

function distance_center(a, b)
    local ax, ay = a.x + a.cx, a.y + a.cy
    local bx, by = b.x + b.cx, b.y + b.cy
    local dx, dy = bx - ax, by - ay
    return flr(sqrt(dx*dx + dy*dy))
end

function round(n)
  if n >= 0 then return flr(n + 0.5) else return ceil(n - 0.5) end
end

function ceil(n)
  return -flr(-n)
end

_msg = ""
_msg_timer = 0
msg_duration = 300  

function show_big_text(msg)
  _msg = msg
  _msg_timer = msg_duration
end

fade_frames = 15  

function get_lines(msg, max_w)
  local lines, words, current = {}, {}, ""
  for i=1,#msg do
    local c = sub(msg,i,i)
    if c==" " then
      if current~="" then add(words,current) current="" end
    else
      current=current..c
    end
  end
  if current~="" then add(words,current) end

  local line=""
  for i=1,#words do
    local w=words[i]
    local test=line=="" and w or line.." "..w
    if #test*4>max_w and line~="" then
      add(lines,line)
      line=w
    else
      line=test
    end
  end
  if line~="" then add(lines,line) end
  return lines
end

function draw_big_text()
  if _msg_timer > 0 then
    local col = 7
    local elapsed = msg_duration - _msg_timer
    if elapsed < fade_frames or _msg_timer < fade_frames then col = 6 end
    if elapsed < fade_frames/2 or _msg_timer < fade_frames/2 then col = 13 end

    local lines = get_lines(_msg, 120)  
    local line_h = 6
    local center_y = cam.y + 50
    local start_y = center_y - flr((#lines * line_h) / 2)

    for i=1,#lines do
      local w = #lines[i] * 4
      local x = cam.x + 64 - flr(w/2)
      local y = start_y + (i-1) * line_h
      print(lines[i], x-2, y, col)
    end
    _msg_timer -= 1
  end
end

zone_msg = {"the bottom","◆ durans stronghold ◆", "old site"}
zone_index = nil
zone_viewed = {false,false,false}

-- obs! koordinatene her vil trenge justering siden verdenskartet har byttet form!
function display_zone_name()
	if player.alive and player.grounded then
		if player.x <= 80 and  player.y>=220 then
			zone_index=1
		elseif player.x >= 120 and player.y<=-888 then
			zone_index=2
		elseif player.y<=-616 then
			zone_index=3
		end
	end
	if zone_index and zone_viewed[zone_index] == false then	
		show_big_text(zone_msg[zone_index])
		zone_viewed[zone_index] = true
		if not (zone_index==3) then
					sfx(11)
		end
		zone_index = nil
		
	end
end

function respawn(y)
	victory_music_played = false
	_game_over_delay_counter = 0
 timer=0
 speedrun_seconds = 0
 speedrun_frames = 0
 jump_counter = 0
 cant_move = false
	sfx(-1)
	music(-1)
	_msg_timer = 0
	player.x = 0
	player.y = y
	player.vx = 1
	player.vy = -0.5
	player.red_coins = 0
	for c in all(red_coins) do
		c.taken = false
	end
end

lockout = 0
function rnd_ambientsound()
	local px = player.x
	local py = player.y
	if lockout<0 then 
		if px>140 and py<168 then 
			if rnd()>0.999 then 
				local rnd_sound = rnd()
				if rnd_sound<=0.2 then
					sfx(12) 
					lockout = 2000+rnd(700)
					wind_duration = 860
				elseif rnd_sound>= 0.6 and py<=-888 then 
					sfx(16)
					sfx(17)
					sfx(18)
					lockout = 400+rnd(700)
					
				else 
					sfx(15)
					lockout = 200+rnd(300) 
				end
			end
		end
	end
	lockout -=1
end

_game_over_delay = 60
_game_over_delay_counter = 0
function check_win(win_type)
	local px = player.x
	local py = player.y
	if win_type == 0 then --vanlig
		if player.grounded and py<=-1784 then
			--game_over = true
			cant_move = true
			weird_mode_unlocked=true
			if dget(0)==1 then -- bare se unlock frste gang
				wm_unlock_seen = true 
			end
			dset(0, 1)
			if _game_over_delay_counter >= _game_over_delay then draw_victory_screen() end
		end
	elseif win_type == 1 then --weird
		
	elseif win_type == 2 then --red coins
		
	end
end

function cheat_win()

end

function updatemouse()
	mouse.x=stat(32)+cam.x
	mouse.y=stat(33)+cam.y
	if stat(34)==1 then mouse.mouse_down = true 
	else mouse.mouse_down = false end 
end

function zone_control()
	if player.y<-96 and player.y>-439 then
		snowfrequency = 3
		bgsnowfrequency = 4
		snow_life = 4
	else 
		snowfrequency = 6
		bgsnowfrequency = 6
		snow_life = 3
	end
	if player.y<=-1544+16 then
		bgclr=14
	else
		bgclr=0
	end
	if player.y<=-1400 then
		snowfrequency = 20
		bgsnowfrequency = 20
		snow_life = 3
	end
	if player.y<=-1200 then
		snowfrequency = 10
		bgsnowfrequency = 10
	end
end

wind_duration = 0
wind_multiplier = 1
function update_wind()
	if wind_duration>0 then
		if wind_duration<60 then
			wind_multiplier = wind_duration/60
		end
		
		for p in all(snw) do
			p.x+=1*wind_multiplier
		end
		for p in all(bgsnw) do
			p.x+=1*wind_multiplier
		end
		for p in all(bgclouds) do
			p.vx=0.3*wind_multiplier
		end
		for p in all(fgclouds) do
			p.vx=0.6*wind_multiplier
		end
	end
	if wind_duration == 0 then
		wind_multiplier = 1
	end
	wind_duration -=1
end

function update_red_coins()
	for c in all(red_coins) do
		if overlap(c,player) and c.taken == false then
			sfx(14)
			c.taken = true
			player.red_coins+=1
		end
	end
end

function format_time(total_s)
  local h = flr(total_s / 3600)
  local m = flr((total_s % 3600) / 60)
  local s = total_s % 60
  
  local function pad(n) return (n < 10 and "0"..n or ""..n) end
  return pad(h)..":"..pad(m)..":"..pad(s)
end

function time_to_frames(s)
  -- s = "hh:mm:ss"
  local h   = tonum(sub(s, 1, 2))
  local m   = tonum(sub(s, 4, 5))
  local sec = tonum(sub(s, 7, 8))
  return (h * 3600 + m * 60 + sec) * 60
end

--[[
function pils_npc_idle()
	
	-- kun hvis i range
	
end
--]]
-->8
--slingshot funciton

potential_vx=0
potential_vy=0
x_sensitivity=0.2
y_sensitivity=0.4
max_radius_x = 10
max_radius_y = 10
deadzone_multiplier_x = 1
deadzone_multiplier_y = 1

function slingshot_update()
  if grab_point.grabbed and player.grounded then
    potential_vy = mid(-max_radius_y, deadzone_multiplier_y*(player.y-grab_point.y+player.cy-grab_point.cy), max_radius_y)
    potential_vx = mid(-max_radius_x, deadzone_multiplier_x*(player.x-grab_point.x+player.cx-grab_point.cx), max_radius_x)
  end
  if not grab_point.grabbed then
    player.vx += potential_vx * x_sensitivity
    player.vy += potential_vy * y_sensitivity
    if potential_vy < -6 then sfx(7) end
    if potential_vx != 0 or potential_vy != 0 then  
      jump_counter += 1
    end
    potential_vx = 0
    potential_vy = 0
  end
end
-->8
-- particle system

-- code from: atzlochtlan

snow_life = 3

snw={}
snowfrequency = 5

bgsnw={}
bgsnowfrequency = 6

function snwmake()
			if timer % snowfrequency == 0 then
    for i=1,1 do
        add(snw,{x=rnd(286)-20,
            y=player.y-120+rnd(30),dx=0/2,
            dy=(rnd(1.5)+0.5)/2,rad=rnd(1.1),
            act=(10+rnd(30))*snow_life,clr=7,ang=0})
           
    end
   end  
    for p in all(snw) do
        p.x+=(sin(p.ang)*1.5)/2
  p.ang+=0.03/2
        p.y+=p.dy
       
        if p.act<5 then p.rad=0 end
        if p.y>248 then p.act=-1 end
        p.act-=1
        if p.act<0 then
            del(snw,p)
        end
    end
end

function bgsnwmake()
			if timer % bgsnowfrequency == 0 then
    for i=1,1 do
        add(bgsnw,{x=rnd(286)-20,
            y=player.y-100+rnd(50),dx=0/2,
            dy=(rnd(0.5)+0.1)/2,rad=0,
            act=(80+rnd(30))*snow_life,clr=13,ang=0})
    end
   end   
    for p in all(bgsnw) do
        p.x+=(sin(p.ang)*0.7)/2
  p.ang+=0.03/2
        p.y+=p.dy
       
        if p.act<5 then p.rad=0 end
        if p.y>248 then p.act=-1 end
        p.act-=1
        if p.act<0 then
            del(bgsnw,p)
        end
    end
end

fgclouds = {typ="fg"}
bgclouds = {typ="bg"}
cloudfrequency = 40


function bgcloudmake()
	if timer % cloudfrequency == 0 then
		if rnd(1)>0.7 then return end
		add(bgclouds,{
		x=-16,
		y=rnd(1400)-1900,
		vx=rnd(0.25)+0.01,
		sp=flr(rnd(3))+1}) // 1,2 or 3 - wow i didnt know // worked
	end
	 for c in all(bgclouds) do
			c.x += c.vx
			if c.x>266 or c.x<-16 then
				del(bgclouds,c)
			end
		end
end

function fgcloudmake()
	if timer % cloudfrequency == 2 then
		if rnd(1)>0.4 then return end
		add(fgclouds,{
		x=-24,
		y=rnd(700)-2100,
		vx=rnd(0.25)+0.03})
	end
	 for c in all(fgclouds) do
			c.x += c.vx
			if c.x>266 or c.x<-24 then
				del(fgclouds,c)
			end
	end
end

function clouddraw(cloudlist)
	for c in all(cloudlist) do
	 cspr = {x=0,y=0,w=0,h=0}
		if cloudlist.typ=="bg" then
				if c.sp==1 then
				 cspr =	{x=48,y=24,w=8,h=8}
				elseif c.sp==2 then
				 cspr =	{x=8,y=32,w=8,h=8}
				else 
				 cspr =	{x=0,y=40,w=16,h=8}
				end
		elseif cloudlist.typ=="fg" then
		 cspr = {x=72,y=24,w=24,h=8}
	end
			sspr(cspr.x,cspr.y,cspr.w,cspr.h,c.x,c.y)
	end
end


function prtdraw(prt)
    for p in all(prt) do
        circfill(p.x,p.y,p.rad,p.clr)
    end
end


__gfx__
0000000067776bbb6b6bbbbb44444444444442444444444400000000444444444444444444444444bbbbdbbbbbb88bbbbbb88bbbbb8888bbbbb88bbb77777777
0000000077777bbbbbbbbbbb22222222222222222222222211011111222222222222222222222222bbbd1dbbbbb82bbbbbb82bbbb822222bbbb82bbb77c77777
0070070044444bbb6b6bbbbb2222212221222222221222221101111122bbbbbbbbbbbbbbbbbbbb22bbb1d1bbbbb82bbbbb8222bb82222222bb8222bb7cccccc7
0007700044444bbbbbbbbbbb221111111111111111111122000000002bbbbbbbbbbbbbbbbbbbbbb2bbbb1bbbbbb82bbbbb8222bb82222222bb8222bb7c1111c7
0007700024442bbbbbbbbbbb22111111111111111111112200000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbdbbbbbb82bbbbb8222bb82222222bb8222bb7c1111c7
0070070024442bbbbbbbbbbb22111111111111111111112211111101bbbbbbbbbbbbbbbbbbbbbbbbbbbd1dbbbbb82bbbbb8222bb82222222bb8222bb7c1c11c7
0000000024442bbbbbbbbbbb22111111111111111111112210111101bbbbbbbbbbbbbbbbbbbbbbbbbbb1d1bbbbb22bbbbbb22bbbb222222bbbb22bbb7cccccc7
0000000067776bbbbbbbbbbb22111111111111111111112200000000bbbbbbbbbbbbbbbbbbbbbbbbbbbb1bbbbbb22bbbbbb22bbbbb2222bbbbb22bbb77777777
4444444444444444444444442211111111111111111111221bb10bbbbbb10bb11101111b199a9491b10111111101111b11011111777777777777777777777777
2222222222222222222222222211111111111111111111221bb10bbbbbb10bb1110111bb22222222bb0111111101111b11011111777777777777777777777777
222212221111111122212222221111111111111111111122bbb10bbbbbb10bbb11011bbb44449442bbb111111101111b11011111777777777777777777777777
22111111111111111111112222111111111111111111112211111111111111110000111122222222111100000000000b000000007777ccc7ccccccc7c7cc7777
22111111111111111111112222111111111111111111112200000000000000001110000049444494000001011111101b11111101777cccc1cccccccccccccc77
221111111111111111111122221111111111111111111122bbb00bbbbbb00bbb11b00bbb22222222bbb00b011111101b1111110177ccc11c11111111111ccc77
222222222222222222222222221111111111111111111122bbb10bbbbbb10bbb1bb10bbb44294444bbb10bb11011101b1011110177cc111111111c111111cc77
222222222222222222222222221111111111111111111122bbb10bbbbbb10bbbbbb10bbb11111111bbb10bbb0000000b0000000077cc1111111111111111cc77
0dddd1dd1101111111011011221111111111111111111122eee0eee001111110eee10eee01111110bbbbbbbdb11011110bbbbbbb77cc1111111111111111cc77
0d111d1d1101111111011111221111111111111111111122eeeeeeee01111110eee10eee01111110bbbbbb1db11011110dbbbbbb77c1c11111111111111c1c77
011111111101111111011111221111111111111111111122e0eee0ee01111010eee10eee01111110bbbbb111b1101111011bbbbb77cc1111111111111111cc77
000000000000000000000000221111111111111111111122eeeeeeee111101111111111111111111bbbb0000b00000000000bbbb77cc1111111111111111cc77
dddd0ddd1111110111111101221111111111111111111122e0e0e0e0111111110000000011111111bbbd0dddb1111101dddd0bbb77cc1111111111111111cc77
111d0d111111110111011101221111111111111111111122eeeeeeee01111111eee00eee01111111bb1d0d11b1111101111d0dbb77cc1111111111111111cc77
111101101011110110101101222222222222222222222222e0e0e0e001111110eee10eee01111110b1110110b10111011111011b77cc1111111111111111cc77
000000000000000000000000222222222222222222222222eeeeeeee01111110eee10eee0111111000000000b00000000000000077cc11111111111111c1cc77
0ddddddd11011111bbb10bbb00000000e0e0e0e0e0e0e0e0bbbbbbbbbbb00bbb1e66666ebbbbbbbbbbbbbbbbbbbbbbbb0000000077cc1c11111111111111cc77
0d11111d11011111bbb10bbb0e0e0e0e0e0e0e0eee0eee0ebbbbbbbbbbb10bbb16ddddd6bbbbbbbbbbbbbbb6777bbbbb0000000077c1c111111111111111cc77
0111111111011111bbb10bbb00000000e0e0e0e0e0e0e0e0bbbbbbbbbbb10bbb01111111bbbb77777bbbb67777777bbb0000000077cc1111111111111111cc77
0000000000000000111111110e0e0e0e0e0e0e0e0eee0eeebbd6666b1101111100000000bb67777777777777777776bb0000000077ccc111c111111c111c1c77
dddd0ddd111111010000000000000000e000e000e0e0e0e0b666666600000000dddd0dddb7777766777777777777776b0000000077cccccccccccccccccccc77
111d0d1111111101bbb00bbb0e000e000e0e0e0e0e0e0e0ed666ddddbbb00bbb111d0d1167776666666666666777667b00000000777cccccccccccccccccc777
1111011010dd1101bbb10bbb0000000000e000e0e0e0e0e0bbbddddbbbb10bbb11110110bbb6666666666666666666bb00000000777777777777777777777777
000000000d1dd0d0bbb10bbb000e000e0e0e0e0e0e0e0e0ebbbbbbbbbbb10bbb00000000bbbbbbbbbbbbbbbbbbbbbbbb00000000777777777777777777777777
01111010bbbbbbbbb7777777777777777777777bb777777b7777777b66666666bbbbbbbbb7777777b6776777776767677776777bbbbbbbb47bbbbbbb0ddddddd
10110111bbbbbbbb777777777777777777777777777777777777777766666665bbbbbbbb77777777777676777676767777676767bbbbbb4277bbbbbb0d11111d
10010111bb66666b677777777777777777777776777777777777777655555556bbbbbbbb77777777676767677777777776777676bbbbb422777bbbbb01111111
01101011b666666b666767666666666666676666655555566666666655555555bbbbbbbb77655555666666666666766666666666bbbb42216777bbbb00000000
11111100bdd666db665555555555555555555556555555555555556655555555bbbbbbbb76555555666666666666666666666666bbb4221156777bbb66666666
11111100bbbbbbbb555555555555555555555555555555555555555655655555bbbbbbbb66655555622222222222222222222226bb422111556777bb22222222
11111010bbbbbbbb555555555555555555555555555555555555555566666666b7bbbbbb66666665222222222222222222222222b42211115556777b22222222
01110100bbbbbbbb555555555555555555555555555555555555555b66666666b6b7bbbbb6666666222222222222222222222222422111115555677722222222
bbbbbbbbbbbbbbbb5d55555555555555555555d555555555b1111b1bb7777777777777777777777b222200000000000000002022221111224422224444444444
bbbbbbbbbbbbbbbb5d555555555d5d55555555d5555555551b11b111777777777777777777777777222000000000000000000222221111224422224422222222
bbbbbd6666bbbbbb5d55555555d5d555555555d5555555551bb1b111777777777777777777777777222000000000000000000222221111224422224422010111
bbd666666666bbbb5d555555555d5d55555555d555555555b11b1b11776555555555555555555677220000000000000000000222221111224422224421101011
bb66dddd66666bbb5d5555555555d555555555d555555555111111bb765555555555555555555667222000000000000000000222221111224422224411111100
bd6dddddd6666bbb5d55555555555555555555d555555555111111bb665555555555555555555566222000000000000000000222221111224422224411111100
bbbbdddddddddbbb5d55555555d55555555555d55555555511111b1b665555555555555555555566222000000000000000000222221111224422224411111010
bbbbbbbbbbbbbbbb5d55555555555555555555d555555555b111b1bb666555555555555555555666222000000000000000000222221111224422224401110100
b777777beeeeeeee5d55555555555555555555d55555555555555555665555556555555655555566222000000000000000000222222222224422224467776bbb
77777777eeeeeeee5dd5555555555555555555d55555555555555555656555555555555555555566222000000000000000000222222222224422224477777bbb
77777777eeeeeeee5dd5555555555555555555d55555555555555555665555555555656555555566222000000000000000000222221111224422224499979bbb
65555556eeeeeeee5dd5555555555555555555d55d55555556565555665555555555565555555566222200000000000000000222221111224422224499999bbb
55555555eeeeeeee5ddd555555555555555555d55d555dd555655555665555555565555555555566122222220000000000022221221111224422224449994bbb
55555555eeeeeeee5dddd555d55ddddddd555dd55dddddd555555655665555555555555555555566111111111111111111111111221111224422224449994bbb
55555555eeeeeeee5dddddddddddddddddddddd55dddddd555555555665555555555555555555566111111111111111111111111221111224444444449994bbb
55555555eeeeeeeeb5555555555555555555555bb555555b65555556665555555555555555555656b1111111111111111111111b221111224444444467776bbb
bb1111bbbbbbbbb777777777b7777777bbbbbbbb66555566d777777d6655555555555555555555667777777b0111101011100000221111224424444400000111
bbbb1bbbbbbbbb777777777777777777bbbbbbbb6655556677777777665555555555555555555666777777771011011111100000221111222222222200000111
bbbbbbbbbbbbb7777777777767777777bbbbbbbb6665556677777777666555555555555555555566777777771111111111100000221111222211112200000111
bbbbbbbbbbbb77766676666666666666bbbbbbbb6655556677555677665555555555555555555566555555771000101111110000221111222211112200000111
bbbbbbbbbbb777656666666666555555bbbbbbbb6655556666555566666555555555555555555666555556671100011011111111221111222211112200011111
bbbbbbbbbb7776552222222265555555bbbbbbbb6655556666555666666665556555555555656666556566661000101011111111221111222211112211111111
bbbbbbbbb77765552222222255555555bbbb7bbb6655556666555566666666666666666666666666666666661000001011111111222222222211112211111111
bbbbbbbb7776555522222222b5555555b7b767bb6655565665555566b6666666666666666666666b6666666b00000010b111111122222222221111221111111b
0000000000000000003242424242529272923252000000000000000002121212000000003151237392d523233151232330500000000000000000b2122312b100
00000000000000000002031223231223232323122323129292000000000000001616161616161616120303c122c1c1130302c1c18282c1729216161616161616
00000000000000000072920000927200000072920000000000000000021223120000000031512323305123233151232332520000000000000000c1122312c100
00000000001212000003031273231223232323122323120303000003030000021616161616161616169292c18282c1030303c1c18282c1929216161616161616
00000000000000000092920084929200000092920000000000000000021223120000000031512323325223233151232392920000000000000000b21223d1f100
00000000001222221203032260602203030303126060120302030303020302031616161616161616169272c18282c1c1c1c1c1c1828222929216161616161616
0000000000000084758585859592920000007292000000000000000002121212000000003252232392922323315123239292000000000000002213f012d3f313
00000000002212121202031223231223232323122323120303030203030303031616161616161616167292c16060c1c1c122c1c18282c1927216161616161616
0000000000000094558655558685a700000092920000000000000003030303030000000092922323927223233151232392920000000000000303020303030203
00000000000000121203031223231223232323127323121292030392121212221616161616161616030303221222121212121212828212929216161616161616
00000000000000007787878787970000000092920000000000000000121212220000000072922323929223233151237330500000000000001202020302020303
000000000000001212030312232322237323231223232212129292121281a1126262626262626262020302221212121212121212606012929262626262626262
00000000000000000000000000000000009030500000000000000000b261711200000000929223233050732331517323315100000000000000a0a01203031212
00000000000000122203031203031260606060126060122212929212812323a15353535353535353539292121212120303131212122212929253535353535353
00000000000000000000000000000000000031510000000000000000b223231200000030929292724040404040404040404050000000000000a0a000a0a01212
0000000000000012120303b712121212221222121212122213929212232323234343434343434343439272221222120203020312222212929243434343434343
00000000000000000000000000000000000032520000000000000000b223231200000303021212b70303030203030303020303030202000000a0a000a0a00000
00000000000000120203020303030302030203929292929202029212237323233333333333333333339292122212121212121212121212927233333333333333
00000000000000000000000000000000000092920000000000000000121212130000a003022212030303030203030303030302030300000000a0a000a0a00000
00000000000000000303030203020303030203039203929202030312232323230000000000000000009292126171222212121212617112929200000000000000
00000000000000000000000000000000000072920000000000000003020303030000a00072922323729223239292230092720000a000000000020300a0a00000
0000000000000000a000030302122222121212121222121203030322232323230000000000000000009292122323121222121212232312929200000000000000
000000000000840000000000000000000000929284000000000000000404121200000000929223009292000072720000009200000000000000000000a0a00000
00000000000000000000b212121271b1000000000000000012020312232323230000000000000000009292122323121212121212232312929203020200000000
000000000024344470800000000000809024343444000000000000000412041200000000007200009272000092920000000000000000000000000000a0a00000
00000000000000000000126122122322000000000000000000030312030373230000000000000000009292222303121212121212237312927212220000000000
95000000002535450000000000000000002535554570800000000000b212120400000000000000000000000072000000000000000000000000000000a0a00000
00000000000000000000b223121212b1000000000000000000030222232323230000000000000000007292126003120212121212606012929212000000000000
55950000002636460000000000000000002636364600000000000000b204121200000000000000000000000000000000000000000000000000000000a0a00000
00000000000000000000122212122222000000000000000002020312232323230000000000000000009292131212120312120312121212929200000000000000
86968400006565650000000000000000000000000000000000000000121204040000000000000000000000000000000000000000000000000000000002030000
00000000000000000000b212121271b1000000000000000000929212237303030000000000000000000302031212121212120312031202030300000000000000
55559500006565656500000000000000000000000000000000000000121212120000000000000000000000000000000000000000000000000000000000000000
00000000000000000000126112122312000000000000000000929212232323730000000000000000001222121212122212121212021212221200000000000000
86879700006565656500000000840000000000000000000000000000b21212040000000000000000000000000000000000000000000000000000000000000000
00000000000000000000b223122212b1840000000000000000929213122212120000000000000000009212121212121212121212122212129200000000000000
97000000002434447080902434440000000000000000000000000000b20412120000000000000000000000000084000000000000000000000000000000000000
00000000000000000000121224343434344400000000000003030203030303030000000000000000009292121212121212221212121212929200000000000000
00000000002535450000002535450000008400000000000000000000041212120000759500000047000000007595000000000000000000759500000000470000
00000092d45092000084b22455555555555500000000000000030303030302030000000000000303039292121222121212121212121212929200000000000000
00000000002636460000002636460000002444000024440000000000121204120000769600000075950000007696000000007595000000769600000075950000
00002392325292001734345555555536364600000000000000002212121222120000000000000022129272121212121212121212121212929200000000000000
00000000000000000000000000000000002646000026460000000000b21212120000779700656576960000007797700000007696000065779700000076960000
922323922323929225555555555546656565000000000000000000b2617112610000000000000000129292121212121212121212121212927200000000000000
00000000000000000000000000000000000000000000000000000000b22444040065006565656577976500656565650000907797650065656500000077970000
922323922323929225555555364665656565000000000000000000b2232312230000000000000000009292030212121223231212121222729200000000000000
00000000000000000000000000000000000000000000000000000000042646040000000065006565656565656565656565656565656565656565656500006500
920121922323929225555546656565656500000000000000000000b2232312230000000000000000007292030312232323232323122212929200000000000000
00000000000000000000000000000000000000000000000000008400120404120000000000000000656504040465656504040404046565656565650000000000
92232392232392922555466565656565650000000000000000000012222222120000000000000000009292221212232323237323121212927200000000000000
00000000000000000000000000000000000000000000000000243444040404120000000000000065650404040404040404040404040404656500000000000000
922323927323929225556565656500656500000000000000000000b2617112610000000000000000009292121223232323232323231212929200000000000000
00000000000000000000000065650000000000000000000000263646b20404120000000000000065d1e1e1e1e1e1e1e1e1e1e1e1e1e1e1f16565000000000000
922323920121920425566565650000656500000000000000000084b2232312230000000000000000009203020323232323232323232212929200000000000000
00000000000000000084006565656565650000000000000000656565040404120000000000000000d3e3e3e2e2e2e2e2e2e2e2e2e2e2e2f36565650000000000
922323922323920456656565000000545400000084000000000054b2732312230000000000000000009202030303732323232373121212929200000000000000
00008400243434343434343444656565656500842444840065656565040404120000000000000000656565d3e3e3e3e2e2e3e3e3e3e3f3656500000000000000
92232392232392926565650000000055550000005400000000005512221222120000000000000000009292030203232323232323030303039200000000000000
3434344455555555555555554565652434343434555544656565656504040404000000000000000000656565656565d3f3656565656565000000000000000000
927323922323929265656500000000555600000035540000000056b2617112610000000000000000009292221212121223731212030302037200000000000000
55555555555555555555553555243455555555555535552434446565040404040000000000000000000000000000656565656565650065000024440000000000
920121929292929265650000000000560000000055550000000000b2232312230000000000000000009272121212122212121212120203039200000000000000
5555555555553555555555555555555535555555555555555535d1e1e1e1e1e10000000000000000000000000000006500006500000000000026354400000000
920000000000920465540000000000000000000056560000000000b2235412730000000000000000009292122212121212121212122212729200000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888eeeeee888eeeeee888777777888eeeeee888eeeeee888eeeeee888eeeeee888eeeeee888888888ff8ff8888228822888222822888888822888888228888
8888ee888ee88ee88eee88778887788ee888ee88ee8e8ee88ee888ee88ee8eeee88ee888ee88888888ff888ff888222222888222822888882282888888222888
888eee8e8ee8eeee8eee8777778778eeeee8ee8eee8e8ee8eee8eeee8eee8eeee8eeeee8ee88888888ff888ff888282282888222888888228882888888288888
888eee8e8ee8eeee8eee8777888778eeee88ee8eee888ee8eee888ee8eee888ee8eeeee8ee88e8e888ff888ff888222222888888222888228882888822288888
888eee8e8ee8eeee8eee8777877778eeeee8ee8eeeee8ee8eeeee8ee8eee8e8ee8eeeee8ee88888888ff888ff888822228888228222888882282888222288888
888eee888ee8eee888ee8777888778eee888ee8eeeee8ee8eee888ee8eee888ee8eeeee8ee888888888ff8ff8888828828888228222888888822888222888888
888eeeeeeee8eeeeeeee8777777778eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee8eeeeeeee888888888888888888888888888888888888888888888888888888
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111177111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111171111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666116616161166166611111111111111771111161611111ccc1ccc11111111161611111ccc1ccc11111111166611661616116616661111166111661616
1111166616161616161116111111177711111171111116161777111c111c1111111116161777111c111c11111111166616161616161116111111161616161616
111116161616161616661661111111111111177111111161111111cc1ccc111111111666111111cc1ccc11111111161616161616166616611111161616161616
1111161616161616111616111111177711111171111116161777111c1c111171111111161777111c1c1111711111161616161616111616111111161616161666
11111616166111661661166611111111111111771111161611111ccc1ccc17111111166611111ccc1ccc17111111161616611166166116661666166616611666
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1111116616661666166611111666116616661661166611111111111111771111161611111cc11ccc1c1111111111161611111cc11ccc1c111111111116161111
1111161116161616161611111616161611611616116111111777111111711111161617771c1c11c11c1111111111161617771c1c11c11c111111111116161777
1111161116611666166111111666161611611616116111111111111117711111116111111c1c11c11c1111111111166611111c1c11c11c111111111116161111
1111161616161616161611111611161611611616116111111777111111711111161617771c1c11c11c1111711111111617771c1c11c11c111171111116661777
1111166616161616166616661611166116661616116111111111111111771111161611111c1c1ccc1ccc17111111166611111c1c1ccc1ccc1711111116661111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111661666166611111111111111771111161611111cc11ccc1c1111111111161611111cc11ccc1c1111111771111111111111111111111111111111111111
111116111616166611111777111111711111161617771c1c11c11c1111111111161617771c1c11c11c1111111171111111111111111111111111111111111111
111116111666161611111111111117711111116111111c1c11c11c1111111111166611111c1c11c11c1111111177111111111111111111111111111111111111
111116111616161611111777111111711111161617771c1c11c11c1111711111111617771c1c11c11c1111111171111111111111111111111111111111111111
111111661616161611111111111111771111161611111c1c1ccc1ccc17111111166611111c1c1ccc1ccc11111771111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616661666166611661611166611661111111111111177177111111111111111111111111111111111111111111111111111111111111111111111
11111616161616161161116116111611161116111111177711111171117111111111111111111111111111111111111111111111111111111111111111111111
11111666166616611161116116111611166116661111111111111771117711111111111111111111111111111111111111111111111111111111111111111111
11111611161616161161116116111611161111161111177711111171117111111111111111111111111111111111111111111111111111111111111111111111
11111611161616161161166611661666166616611111111111111177177111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111dd11ddd11dd11d111dd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111d1d1d1d1d111d111d1111d11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111ddd1ddd11111d1d1ddd1d1111111ddd11111111711111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111d1d1d111d111111111d11d11111771111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111d1d1d1111dd11111dd111111111777111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111777711111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111771111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111117111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666166616111166111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111616116116111611111117771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111666116116111666111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611116116111116111117771111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111611166616661661111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1ee11ee111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1ee11e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1e111e1e1e1e11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1eee1e1e1eee11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
82888222822882228888828282228882828282228888888888888888888888888888888888888888888882228228822282228882822282288222822288866688
82888828828282888888828288828828828282888888888888888888888888888888888888888888888888828828828288828828828288288282888288888888
82888828828282288888822288228828822282228888888888888888888888888888888888888888888888228828822288228828822288288222822288822288
82888828828282888888888288828828888288828888888888888888888888888888888888888888888888828828828288828828828288288882828888888888
82228222828282228888888282228288888282228888888888888888888888888888888888888888888882228222822282228288822282228882822288822288
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000101010010101000000000000301010101010100000001000000030303010000010101000000000400080303030100000000000000010000010003030300000101010101010001010101040801000001010101000101010101010101100100010101010101010101010101010000040101000101010101010001010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000006264000000000000000000002900455500000000000000000000000000000000002b215521210000002a30200000212929222221212122222121212222272922000030302c000000000000000000000021212121002121222100212221210000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006555000000000000000000000000000000000021216521210000002030303122212929212121212121212121222221292921212120303000000000000000002a3838212221212121212121212121222138382c0000000000
0000000000000000000000000000000000000000000000000000000000000071000000000000000000650000000000000000000000000000000048212121212100000030302030302029272121212121323221212121212929302030303020000000000000000030203038383838383838383838383838383030200000000000
000000000000000000000000000000000000000000000000000000000000095200000000000000000000000000000000000000000000000000004a724b72727200000030303030203030292121213221060621322121212930303030303030000000000000000030203030302030303030303030303030303020300000000000
0000000000000000000048000000480000000000000000000000000071404052000000000000000000000000000000000000000000000000004a5b5b5b5b5b5b0000000a30303030303020213221067e37322106213721303030303020300000000000000000000a2221211c1c1c1c1c1c1c1c1c1c1c1c212221000000000000
0000000000000000480042434343440048000000000000000000000052404052000000000000000000000000000000000000000000000000006a5b5b5b5b5b5b0000000000000000303030210621325d3237213221062130203000000a00000000000000000000000021211c163232323232323232171c212200000000000000
000000000000000042435555555555434400000000000000000000715540405200000000000000000000000000000000000000000000000000007c6b6b5b5b6b00000000000000000a3030213221327d323221322132213030000000000000000000380000003800002938383232383832323838323238382700000000000000
000000000000000052555555555555555442440000000000000071555440405200000000000000000000000000000000000000000000000000000070007c7f0000000000000000000030202132213221323221322132213030000000000000000000200000003000002930303232303032323020323220302900000000000000
00000000000000485255555563636363646264000000000000005255545f40520000000000000000000000001919191919190000000000000000000000007000000000000000000000303021322132213232213221322120300000000000000000000a00000000000029291c323232323232323232321c292900000000000000
00000000000000425555556437292932325600000000000000715555644040524e00000000000000000000191919191919191900000000000000000000000000000000000000000000203021322132213232217e21322230300000000000000000000000000000000029291c060606060606060606061c292900000000000000
00000000000000525555543732292937320000480048000000525554404040526974000000000000000000007d212121217d0000000000000000000000000000000000000000000000302021322137213232215d21322130200000000000000000000000000000000029291c1c1c1c1c16171c1c1c1c1c292900000000000000
00000000000000525555543256292932000073434346000000525554404040525559007400000000000000002916404037290000000000000000000000000000000000000000000000203021322132213232217d21372130300000000000000000000000000000000029292216171c1c32321c1c16171c292938383838000000
0000000000004255555554565629275600000000000000007155555546404052555558584e00000000000048297b404040274800000000000000000000000000000000000000000000303021372132210606213221322130300000000000000000000000000000000029291c32321c1c32321c1c32321c29291c1c1c0a000000
000000000000525555555544562729565600000000000000626364404040405255555568790000000000004a4f303030304f4c48000000000000000000000000000000000000000000303021322106212121210621322129290000000000000000000000000000000029291c32321c1c32321c2232321c29291c22000a000000
0000000000006255555555554243434456560000000000004040404040404052685555690000000000004a5b5b5b5b5b5b5b5b4c00000000000000000000000000000000000000000030202106217e212121212121062127290000000000000000000000000000000029291c37321c383838381c32371c29291c000000000000
0000000000000062635555555255555456565648000000007440404040405768557878790000000000006a5b5b5b5b5b5b5b5b6c00000000000000000000000000000000000000000030302121215d21212121212121212729000000000000001c1c1c0000001c1c2227291c06061c303030301c06061c292900000000000000
000048000000000000626363525555544243444344000000575957585957685579000000000000000000707c6b5b5b6b6b6b7f0000000000000000191919191900000000000000000029292121217d21212121212122212929000000000000001c1c1c0000001c1c1c29271c221c1c1c1c1c1c1c1c221c292900000000000000
0057590000000000000000006263636452535462640000006769675569675555000000000000000000000000007c7f000070000000000000000019191919191900000000000000000027292221212121222121212121217b29000000000000001c221c1c1c1c1c1c1c29291c1c1c21212121212121221c292900000000000000
0067690000480000000000000000005662636400560000007779676869775568000000000000000000000000000070000000000000000000000000292716291700000000000000000029292122212121213130302929293030000000000000001c1c371c3838381c1c3838381c1c1c1c1c1c1c1c221c1c292900000000000000
00777900005759000000000000000000005656000000000000007778795677781919000000000000000000000000000000000000000000004800006d5f407b7b0000000000000000003030203030303020303020292727203000000000000000221c321c3030301c1c3030301c22221c1c1c1c1c1c1c22292900000000000000
00000000006769000000000000000000005600000000000000005656560000001919190000000000000000000000000000000000000000004a4b4f303030303000000000000000000030303030303030303030202929293030000000000000001c1c061c1c30301c1c30301c1c1c1c1c1c16323232171c292900000000000000
0000000000777900090305070000000000000000000000000000005656000000215d00000000000000000000000000000000000000000000006a6b6b5b5b5b5b00000000000000000029292121212121181a212121212130300000000000000038381c321c3030221c30301c1632171c1c32323237321c292900000000000000
0000000000000000001315000000000000000000000000000000005600000000405d00000000000000000000000000000000000000000000000000707c6b6b6b0000002a30300000002729212121211832321a2121222130300000000000000030301c321c20301c1c30301c3232321c2232323232321c292900000000000000
000000000000000000131529292929292929272900000000000000000000000030304f48000000000000000000000000000000480000000000000000000000700000003030200000002929212221213232323221212121203000203000000000301c1c061c30301c2230201c3232321c1c32323232321c292900000000000000
00000000000000000013152927292929292929290000000000000000000000005b5b5b4c000000000000000000000000004a724b4c000000000000000000000000000000000000000030203021182132373232211a2121303000000000000000301c281c382030221c20301c3232322206060606060606292900000000000000
00000000000000000013150000292900000003050000000000000000000000005b6b6b6c000000000000000000000000006a6b5b5c0000000000000000000f000000000000000000002030201832213232373221321a21302000000000000000301c281c303020221c30301c2828281c1c1c221c1c2222292961616161616161
00000000000000000013150000292900000013150000000000000000000000006c0000700000000000000000030500000000707c6c0000000000000000000f0f00000000000000000030302106062130303030210606222030000000000000003021061c1c1c1c1c1c30291c2828281c1c281c1c28281c292961616161616161
0000000000000000001315292703052929291315000000000000000000000000700000000000000003050000232500000000007000000000000000000f1d1e1f000000000000000000302021323221323232322132322130300000000000000030381c1c2828281c1c29291c2828281c22281c1c28281c292961616161616161
00000000000000000023252929232529292923250000000000000000000000000000000000000000131500002929000000000000000000000031220f0f3d3e3f000000000000000000303021323221323232372132322130200000000000000030301c222828281c1c2929222828281c1c281c1c28281c292961616161616161
00000000000000000029290000292900000029270000000000000000000000000000000000000000231500002929320000290000000000003030203030302030000000000000000000203021323221323232322132323030300000000000000030301c1c1c211c221c27271c0606061c1c061c1c282822292961616161616161
00000000000000000029270000292900000029290000000000000020212021200000000000000000295d0032292932002929000000000000002020302020303000000000000000000020302106062206060606210606213030000000000000002030382929383829273838221c221c1c38381c1c28281c292961616161616161
0000000000000000090304040404052929290305000000000000003030303030000000004d053232275d323203053232272900000000000000001c2132211c00000000000000000000303021323221323232322132322129290000000000000030303027292030292930301c1c1c221c30201c1c28281c292961616161616161
__sfx__
9001000002130081300e14013150171601a1601e1601e150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000000000000000000000000000000000000
1905080018350183001830018335183001830018300183001e30003300063000d300083000b30018300113000a3000a3000d300103000830005300063000130000300003003e300003003d3003d3000030000300
190500013f0503f0503f0003a0003f0003e0003e0000700332003050033200303003320031900314003110030d0030b0030700304003020030200301003010030000300003000030000300003000030000300003
000300003e6203b610396103661035610346103361033610256101c60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910400001f6201161000000000003c00000000000003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
900400001f62011610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910400001a62007610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000001110011110111102121041210c1210d13100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
000300002d6602c6502b6302062018630116300d6300a620226001f6001e6001c6001b6001a6001960016600156001360012600106000e6000c6000a600086000560002600006000060000600006000060000600
010500003a0003a000390003800036000350003400032000310002f0002c0002b000290002700026000250002300021000200001f0001e0001c0001b00019000170001500014000110000f0000d0000b00008000
600a00002415524135241151210034000191001910219102191021910219102191021910219105191001910019100191001910008100091000c1000e10011100181001d1001c100131000f1000d1000b1000a100
a11b00000000100001010010101101011010210103101031010310103101031010310103101031010310103101021010110101101011010010000100001000010000100001000010000100001000010000100001
91380000016140161103611046210462102621046110261102611026210361103621036210262105641026210261102621036110362103621066111664102621026110262103611036210a631066210261502601
4a1f00000160101611036110462101621016310263102631036210262103631036310463101621006150260102601026010360103601036010660105601026010260102601036010360105601066010260502601
c30600003105031050310503105030000310403104031040310403100031030310303103031030310003102031020310203102031000310103101031010310103100031010310103101031015300003100031000
a70300001860518605186051860518605186051860518605186051860518605186051860518605186051860518605186050b6450060500605006050b64500605006050b635006050b6250b615006051860518605
871600000000000001000010e0140e0110e0210e0210e0210e0220e0220e0220e0220e0220e0220e0210e0150000000001000010a0140a0110a0210a0210a0210a0220a0220a0220a0220a0220a0220a0220a015
911600000000000001000010e0140e0110e0110e0110e0110e0120e0120e0120e0120e0120e0120e0110e01500000000010000111014110111101111011110111101211012110121101211012110121101211015
911600000000000000000000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0000e0001800018001180010e0140e0100e0100e0100e0100e0100e0100e0100e0100e0100e0100e0100e015
310b0000070500a0500d0501005012050150501805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
911500003491032910309102f910309102b9102d9102b910289102491026910289103491032910309102f910309102b9102d9102b910289102491026910289103491032910309102f910309102b9102d9102b910
911500000c0100c0100c0100c0100c0100c0100c0100c01013010130101301013010110101101011010110101101011010110101101009010090100b0100b0100c0100c0100c0100c0100c0100c0100c0100c010
91150000289102491026910289103491032910309102f910309102b9102d9102b910289102491026910289103491032910309102f910309102b9102d9102b910289102491026910289103491032910309102f910
91150000309102b9102d9102b910289102491026910289103491032910309102f910309102b9102d9102b910289102491026910289103491032910309102f910309102b9102d9102b91028910249102691028910
911500000c0000c0000c0000c0000c0100c0100c0100c0100c0100c0100c0100c01013010130101301013010110101101011010110101101011010110101101009010090100b0100b0100c0100c0100c0100c010
911500000c0100c0100c0100c0100c0000c0000c0000c0000c0100c0100c0100c0100c0100c0100c0100c01013010130101301013010110101101011010110101101011010110101101009010090100b0100b010
011000000c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c05000000000000c0550c0550c055000000c050000000c000000000d000000000f0500f0500f0500f050
0110000000000230002105521055210550000021055000001d0550000018055000001a05500000000001d0551d055000000000000000000000000000000000000000000000000000000000000000001805518055
0110000018055000001d055000001d05500000240550000021055000001d0001d0000000000000000000000000000000000000000000000000000000000180001800000000000000000000000000000000000000
011000000f0500f0500f0500f0500f0500f0500f0500f050110501105011050110501105011050110501105011050110501105011050000000000000000000000000000000000000000000000000000000000000
070f000014055180551405511055140550c0051405518055140551105514055160551805516055140551105515055180551505511055150550c00515055180551505511055150551605518055160551505511055
070f000014055180551405511055140550c0051405518055140551105514055160551805516055140551105514055180551405510055140550c00514055180551405510055140551605518055160551405510055
070f000016055190551605512055160550c0051605519055160551205516055180551905518055160551205516055190551605512055160550c00516055190551605512055160551805519055180551605512055
070f0000160551a0551605513055160550c005160551a055160551305516055180551a055180551605513055160551a0551605513055160550c005160551a055160551305516055180551a055180551605513055
010f00000c0520c0550c0000c0000c0040c0040c0520c0550c0000c0000c0040c0040c0520c0520c0520c0550e0520e0550e0000e0000c0040c0040e0520e0550e0000e0000c0040c0040e0520e0520e0520e055
010f00000f0520f0550f000100000c0000c0000f0520f0550f000100000c0000c0000f0520f0520f0520f0550d0520d0550f000100000c0000c0000d0520d0550f000100000c0000c0000d0520d0520d0520d055
010f00000f0520f0550f000100000c0000c0000f0520f0550f000100000c0000c0000f0520f0550f0000c0000c0000f0000f0520f0550c0000f0000c0000f0000f0520f0550c0000f0000f0520f0551000000000
010f000013052130550f000100000c0000c00013052130550f000100000c0000c00013052130550f0000c0000c0000f00013052130550c0000f0000c0000f00013052130550c0000f00013052130550000000000
070b000018053180431803318023180131800318003180031800318003180000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 14155744
00 16184344
02 17194344
01 1a1b4344
02 16184344
00 41424344
01 1b1a4344
02 1c1d4344
00 10111244
00 41424344
01 1e224344
00 1f234344
00 1e224344
00 20244344
02 21254344

