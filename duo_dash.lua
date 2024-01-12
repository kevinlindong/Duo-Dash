--duo dash


--init

function _init()
 --initialize start menu
 init_menu()
 reset_arming_spikes()
 music_on = true
 if music_on then
  music(0)  
 else
  music(-1, 0, 0)
 end
 menuitem(2, "music: on", toggle_music)
end

function init_menu()
 --initialize game
 _update=update_menu
 _draw=draw_menu
 --particles
 starx={}
 stary={}
 starspd={}
 for i=1,700 do
  add(starx,flr(rnd(1024)))
  add(stary,flr(rnd(512)))
  add(starspd,rnd(1.5)+0.5)
 end
 --grays
 grays = {5, 6, 7, 13, 14, 15}
 gray_index = 1
 gray_change_delay = 7 
 gray_change_counter = 0  
end

function init_game()
 reset_arming_spikes()
 --player one variables
 player={
  sp=1,
  trail_sp1=1,
  x=8,
  y=468,
  w=8,
  h=8,
  dx=0,
  dy=0,
  anim=0,
  dash_anim=0,
  trail_anim=0,
  dash_trail_delay = 0,
  dash_trail_delay_threshold = 4,
  dash_trail_delay_threshold_two = 8,
  dash_trail_delay_threshold_three = 16,
  flp=false,
  spike_collision=false,
  dead=false,
  win=false,
  is_dashing=false,
  dash_direction="down",
  dash_speed=0,
  max_dash_speed=8,
  dash_acceleration=2,
  buffered_dash_direction=nil
 }
 --player two variables
 player2={
  sp=8,
  trail_sp1=1,
  x=8,
  y=496,
  w=8,
  h=8,
  dx=0,
  dy=0,
  anim=0,
  dash_anim=0,
  trail_anim=0,
  dash_trail_delay = 0,
  dash_trail_delay_threshold = 4,
  dash_trail_delay_threshold_two = 8,
  dash_trail_delay_threshold_three = 16,
  flp=false,
  spike_collision=false,
  dead=false,
  win=false,
  is_dashing=false,
  dash_direction="down",
  dash_speed=0,
  max_dash_speed=8,
  dash_acceleration=2,
  buffered_dash_direction=nil
 }
 --arming spikes
 arming_spikes = {}
 init_arming_spikes()
 for spike in all(arming_spikes) do
  spike.armed = false
  spike.timer = 0
  mset(spike.x, spike.y, get_unarmed_sprite(spike.x, spike.y))
 end
 --death circle
 death_transition_active = false
 death_transition_radius = 0
 death_transition_max_radius = 128
 death_transition_speed = 6
 death_transition_player_x = 0
 death_transition_player_y = 0
 --linear interpolation camera variables
 cam_x=0
 cam_y=440
 target_cam_x = 0
 target_cam_y = 0
 lerp_speed = 0.2
 --timer 	
 show_timer=true
 menuitem(1,"timer: show",timer)
 ms=0
 s=0
 m=0
 ftime="0:00.00"
 start_time = time()
 --map limits
 map_start=0
 map_end=1024
 --set state
 _update=update_game
 _draw=draw_game
end


--update and draw

function update_menu()
 --update menu
 animatestars()
 if btn(❎) or btn(🅾️) then
  init_game()
  sfx(0)
 end
 --flashing prompt
 gray_change_counter = gray_change_counter + 1
 if gray_change_counter >= gray_change_delay then
  gray_change_counter = 0  
  gray_index = gray_index + 1
 end
 if gray_index > #grays then
  gray_index = 1
 end
end

function update_game()
 --flashing prompt
 gray_change_counter = gray_change_counter + 1
 if gray_change_counter >= gray_change_delay then
  gray_change_counter = 0  
  gray_index = gray_index + 1
 end
 if gray_index > #grays then
  gray_index = 1
 end
 --update game
 player_update()
 player_animate()
 player2_update()
 player2_animate()
 animatestars()
 --camera
 target_cam_x = ((player.x + player2.x) / 2) - 64 + (player.w / 2)
 target_cam_y = ((player.y - 80 + player2.y) / 2) + (player.h / 2)
 cam_x = lerp(cam_x, target_cam_x, lerp_speed)
 cam_y = lerp(cam_y, target_cam_y, lerp_speed)
 cam_y = flr(cam_y)
 cam_x = mid(map_start, cam_x, map_end - 128)  
 camera(cam_x, cam_y - 25)
 --timer
 if not player.win and not player2.win then
  update_timer()
 end
 update_arming_spikes()
 --death circle
 if player.dead then
  death_transition_active = true
  death_transition_player_x = player.x
  death_transition_player_y = player.y
 end
 if player2.dead then
  death_transition_active = true
  death_transition_player_x = player2.x
  death_transition_player_y = player2.y
 end
end

function update_win() 
 --animate stars
 animatestars()
 --flashing prompt
 gray_change_counter = gray_change_counter + 1
 if gray_change_counter >= gray_change_delay then
  gray_change_counter = 0  
  gray_index = gray_index + 1
 end
 if gray_index > #grays then
  gray_index = 1
 end
end

function update_death()
 if btn(❎) or btn(🅾️) then
  sfx(2)
  init_game()
  for spike in all(arming_spikes) do
   spike.armed = false
   spike.timer = 0
   mset(spike.x, spike.y, get_unarmed_sprite(spike.x, spike.y))
  end
 end
 --flashing prompt
 gray_change_counter = gray_change_counter + 1
 if gray_change_counter >= gray_change_delay + 8.5 then
  gray_change_counter = 0  
  gray_index = gray_index + 1
 end
 if gray_index > #grays then
  gray_index = 1
 end
 --stars 
 animatestars()
end

function draw_menu()
 --render start menu
 cls()
 starfield()
 spr(76, 51, 50)
 spr(77, 59, 50)
 spr(78, 67, 50)
 spr(92, 51, 58)
 spr(93, 59, 58)
 spr(94, 67, 58)
 spr(95, 75, 58)
 spr(108, 51, 66)
 spr(109, 59, 66)
 spr(110, 67, 66)
 spr(111, 75, 66)
 spr(125, 59, 74)
 spr(126, 67, 74)
 spr(127, 75, 74)
 print("\^w\^t du  da", 26, 16, 12)
 print("\^w\^t   o   sh", 26, 16, 14)
 print("press ❎ or 🅾️ to start",19,102,grays[gray_index])
 print("use arrow keys to dash",21,110,6)
 print("by kevin dong",39,118,6)
end

function draw_game()
 --render game
 cls()
 starfield()
 map(0, 0)
 --timer
 if show_timer then
  rectfill(cam_x + 1, cam_y - 22, cam_x - 1 + max(7*4, #ftime*4)+2, cam_y-16, 0)
  print(ftime, cam_x + 2,cam_y - 21, 7, 0)	
 end
 player.trail_sp2=player.trail_sp1+1
 player.trail_sp3=player.trail_sp1+2
 player2.trail_sp2=player2.trail_sp1+1
 player2.trail_sp3=player2.trail_sp1+2
 --draw player one
 spr(player.sp, player.x, player.y, 1, 1, player.flp_x, player.flp_y)
 --draw trails
 if player.is_dashing and player.dash_trail_delay > player.dash_trail_delay_threshold then
  if player.dash_direction == "left" then
   spr(player.trail_sp1, player.x + player.w, player.y, 1, 1, player.flp_x, player.flp_y)
   if player.dash_trail_delay > player.dash_trail_delay_threshold_two then
    spr(player.trail_sp2, player.x + 2 * player.w, player.y, 1, 1, player.flp_x, player.flp_y)
    if player.dash_trail_delay > player.dash_trail_delay_threshold_three then
     spr(player.trail_sp3, player.x + 3 * player.w, player.y, 1, 1, player.flp_x, player.flp_y)
    end
   end
  elseif player.dash_direction == "right" then
   spr(player.trail_sp1, player.x - player.w, player.y, 1, 1, player.flp_x, player.flp_y)
   if player.dash_trail_delay > player.dash_trail_delay_threshold_two then
    spr(player.trail_sp2, player.x - 2 * player.w, player.y, 1, 1, player.flp_x, player.flp_y)
    if player.dash_trail_delay > player.dash_trail_delay_threshold_three then
     spr(player.trail_sp3, player.x - 3 * player.w, player.y, 1, 1, player.flp_x, player.flp_y)
    end
   end
  elseif player.dash_direction == "up" then
   spr(player.trail_sp1, player.x, player.y + player.h, 1, 1, player.flp_x, player.flp_y)
   if player.dash_trail_delay > player.dash_trail_delay_threshold_two then
    spr(player.trail_sp2, player.x, player.y + 2 * player.h, 1, 1, player.flp_x, player.flp_y)
    if player.dash_trail_delay > player.dash_trail_delay_threshold_three then
     spr(player.trail_sp3, player.x, player.y + 3 * player.h, 1, 1, player.flp_x, player.flp_y)
    end
   end
  elseif player.dash_direction == "down" then
  spr(player.trail_sp1, player.x, player.y - player.h, 1, 1, player.flp_x, player.flp_y)
   if player.dash_trail_delay > player.dash_trail_delay_threshold_two then
    spr(player.trail_sp2, player.x, player.y - 2 * player.h, 1, 1, player.flp_x, player.flp_y)
    if player.dash_trail_delay > player.dash_trail_delay_threshold_three then
     spr(player.trail_sp3, player.x, player.y - 3 * player.h, 1, 1, player.flp_x, player.flp_y)
    end
   end
  end
 end
 --draw player two
 spr(player2.sp, player2.x, player2.y, 1, 1, player2.flp_x, player2.flp_y)
 --draw trails
 if player2.is_dashing and player2.dash_trail_delay > player2.dash_trail_delay_threshold then
  if player2.dash_direction == "left" then
   spr(player2.trail_sp1, player2.x + player2.w, player2.y, 1, 1, player2.flp_x, player2.flp_y)
   if player2.dash_trail_delay > player2.dash_trail_delay_threshold_two then
    spr(player2.trail_sp2, player2.x + 2 * player2.w, player2.y, 1, 1, player2.flp_x, player2.flp_y)
    if player2.dash_trail_delay > player2.dash_trail_delay_threshold_three then
     spr(player2.trail_sp3, player2.x + 3 * player2.w, player2.y, 1, 1, player2.flp_x, player2.flp_y)
    end
   end
  elseif player2.dash_direction == "right" then
   spr(player2.trail_sp1, player2.x - player2.w, player2.y, 1, 1, player2.flp_x, player2.flp_y)
   if player2.dash_trail_delay > player2.dash_trail_delay_threshold_two then
    spr(player2.trail_sp2, player2.x - 2 * player2.w, player2.y, 1, 1, player2.flp_x, player2.flp_y)
    if player2.dash_trail_delay > player2.dash_trail_delay_threshold_three then
     spr(player2.trail_sp3, player2.x - 3 * player2.w, player2.y, 1, 1, player2.flp_x, player2.flp_y)
    end
   end
  elseif player2.dash_direction == "up" then
   spr(player2.trail_sp1, player2.x, player2.y + player2.h, 1, 1, player2.flp_x, player2.flp_y)
   if player2.dash_trail_delay > player2.dash_trail_delay_threshold_two then
    spr(player2.trail_sp2, player2.x, player2.y + 2 * player2.h, 1, 1, player2.flp_x, player2.flp_y)
    if player2.dash_trail_delay > player2.dash_trail_delay_threshold_three then
     spr(player2.trail_sp3, player2.x, player2.y + 3 * player2.h, 1, 1, player2.flp_x, player2.flp_y)
    end
   end
  elseif player2.dash_direction == "down" then
   spr(player2.trail_sp1, player2.x, player2.y - player2.h, 1, 1, player2.flp_x, player2.flp_y)
   if player2.dash_trail_delay > player2.dash_trail_delay_threshold_two then
    spr(player2.trail_sp2, player2.x, player2.y - 2 * player2.h, 1, 1, player2.flp_x, player2.flp_y)
    if player2.dash_trail_delay > player2.dash_trail_delay_threshold_three then
     spr(player2.trail_sp3, player2.x, player2.y - 3 * player2.h, 1, 1, player2.flp_x, player2.flp_y)
    end
   end
  end
 end
 --death
 if player.dead or player2.dead then
  handle_death_transition()
 end
 --win
 if win_transition_active then
  handle_win_transition()
 end
end

function draw_win()
 --render win screen
 cls()
 starfield()
 print("you won!",cam_x+49,cam_y+36,grays[gray_index])
 --render winning time
 if show_timer then
  print(ftime, cam_x + 50,cam_y + 52, 7, 0)	
 end
end

function draw_death()
 --render death screen
 cls()
 starfield()
 spr(90, cam_x+54, cam_y+10, 1, 1)
 spr(91, cam_x+62, cam_y+10, 1, 1)
 spr(106, cam_x+54, cam_y+18, 1, 1)
 spr(107, cam_x+62, cam_y+18, 1, 1)
 spr(122, cam_x+54, cam_y+26, 1, 1)
 spr(123, cam_x+62, cam_y+26, 1, 1)
 print("you died!",cam_x+45,cam_y+45,6)
 print("press ❎ or 🅾️ to play again",cam_x+8	,cam_y+80,grays[gray_index])
 print("dont give up!",cam_x+37,cam_y+72,6)
 update_death()
end


--collision logic

function collide_map(obj, aim, flag)
 --local variables
 local x, y, w, h = obj.x, obj.y, obj.w, obj.h
 local x1, y1, x2, y2
 --get direction
 if aim == "left" then
  x1, y1, x2, y2 = x - 1, y, x, y + h - 1
 elseif aim == "right" then
  x1, y1, x2, y2 = x + w, y, x + w + 1, y + h - 1
 elseif aim == "up" then
  x1, y1, x2, y2 = x, y - 1, x + w - 1, y
 elseif aim == "down" then
  x1, y1, x2, y2 = x, y + h, x + w - 1, y + h + 1
 end
 --collision logic
 x1, y1, x2, y2 = flr(x1 / 8), flr(y1 / 8), flr(x2 / 8), flr(y2 / 8)
 for ix = x1, x2 do
  for iy = y1, y2 do
   if fget(mget(ix, iy), flag) then
    if aim == "left" then 
     obj.x = ix * 8 + 8
    elseif aim == "right" then 
     obj.x = ix * 8 - obj.w
    elseif aim == "up" then 
     obj.y = iy * 8 + 8
    elseif aim == "down" then 
     obj.y = iy * 8 - obj.h
    end
    return true
   end
  end
 end
 --collision for unarmed spikes
 local inside_collision = false
 for spike in all(special_spikes) do
  if not spike.armed and is_player_inside_spike(obj, spike) then
   inside_collision = true
   break
  end
 end
 if inside_collision then
  return false
 end
 return false
end


--player one logic

function player_update()
 if player.dead or player2.dead or player.win then
  return
 end
 --dash movement
 if not player.is_dashing then
  if btnp(⬅️) then
   player.dash_direction = "left"
   player.is_dashing = true
   sfx(1)
  elseif btnp(➡️) then
   player.dash_direction = "right"
   player.is_dashing = true
   sfx(1)
  elseif btnp(⬆️) then
   player.dash_direction = "up"
   player.is_dashing = true
   sfx(1)
  elseif btnp(⬇️) then
   player.dash_direction = "down"
   player.is_dashing = true
   sfx(1)
  end
 end
 --buffer next dash direction input
 if player.is_dashing then
  if btnp(⬅️) then
   player.next_dash_direction = "left"
   sfx(1)
  elseif btnp(➡️) then
   player.next_dash_direction = "right"
   sfx(1)
  elseif btnp(⬆️) then
   player.next_dash_direction = "up"
   sfx(1)
  elseif btnp(⬇️) then
   player.next_dash_direction = "down"
   sfx(1)
  end
 end
 --start new dash
 if not player.is_dashing then
  local dash_direction = player.next_dash_direction or get_dash_direction()
  if dash_direction then
   player.dash_direction = dash_direction
   player.is_dashing = true
   player.next_dash_direction = nil
  end
 end
 --dashing handling
 if player.is_dashing then
  --accelerate to max speed
  if player.dash_speed < player.max_dash_speed then
   player.dash_speed += player.dash_acceleration
  else
  player.dash_speed = player.max_dash_speed
 end
 --apply dash direction
  if player.dash_direction == "left" then
   player.dx = -player.dash_speed
   player.dy = 0
  elseif player.dash_direction == "right" then
   player.dx = player.dash_speed
   player.dy = 0
  elseif player.dash_direction == "up" then
   player.dy = -player.dash_speed
   player.dx = 0
  elseif player.dash_direction == "down" then
   player.dy = player.dash_speed
   player.dx = 0
  end
 end
 --update player position
 player.x += player.dx
 player.y += player.dy
 --collision detection
 if (player.dash_direction == "left" and collide_map(player, "left", 1)) or
  (player.dash_direction == "right" and collide_map(player, "right", 1)) or
  (player.dash_direction == "up" and collide_map(player, "up", 1)) or
  (player.dash_direction == "down" and collide_map(player, "down", 1)) then
  player.is_dashing = false
  player.dash_speed = 0
  player.dx, player.dy = 0, 0
 end
 --limit player to map
 if player.x<map_start then
  player.x=map_start
 end
 if player.x>map_end-player.w then
   player.x=map_end-player.w
 end
 --head-on with spikes
 player.spike_collision = false
 if player.dash_direction == "left" then
  player.spike_collision = collide_map(player, "left", 2)
 elseif player.dash_direction == "right" then
  player.spike_collision = collide_map(player, "right", 2)
 elseif player.dash_direction == "up" then
  player.spike_collision = collide_map(player, "up", 2)
 elseif player.dash_direction == "down" then
  player.spike_collision = collide_map(player, "down", 2)
 end
 --death circle
 if player.spike_collision then
  sfx(3)
  player.dead = true
  death_transition_active = true
  death_transition_player_x = player.x
  death_transition_player_y = player.y
 end
 --win collision
 local win_condition = collide_map(player, "left", 3) or collide_map(player, "right", 3) or collide_map(player, "up", 3) or collide_map(player, "down", 3)
 if win_condition then
   player.win = true
 end
 if player.win and player2.win then
  init_win_transition()
 end
 --dash trail increment
 if player.is_dashing then
  player.dash_trail_delay += 1
 else
  player.dash_trail_delay = 0
 end
 --arming spike collision
 for spike in all(special_spikes) do
  if player.x == spike.x and player.y == spike.y then
   if not spike.armed then
    spike.armed = true
    spike.timer = 30 
    mset(spike.x, spike.y, get_armed_sprite(spike.x, spike.y))
   end
   for spike in all(special_spikes) do
    if player.x == spike.x and player.y == spike.y then
     if spike.armed and spike.timer < 30 then
      player.dead = true
     end
    end
   end
  end
 end
end

function player_animate()
 --dash animation
 if player.is_dashing then
  if player.dash_direction == "left" then
   player.flp_x=true
   player.sp = 19 + (player.dash_anim % 5)
   player.trail_sp1 = 33 + (player.trail_anim % 3)
  elseif player.dash_direction == "right" then
   player.flp_x=false
   player.sp = 19 + (player.dash_anim % 5)
   player.trail_sp1 = 33 + (player.trail_anim % 3)
  elseif player.dash_direction == "up" then
   player.flp_y=false
   player.sp = 3 + (player.dash_anim % 5)
   player.trail_sp1 = 49 + (player.trail_anim % 3)
  elseif player.dash_direction == "down" then
   player.flp_y=true
   player.sp = 3 + (player.dash_anim % 5)
   player.trail_sp1 = 49 + (player.trail_anim % 3)
  end
 --idle animation
 else
  if player.dash_direction == "left" then
   player.flp_x=true
   player.sp = 17 + (player.anim % 2)
  elseif player.dash_direction == "right" then
   player.flp_x=false
   player.sp = 17 + (player.anim % 2)
  elseif player.dash_direction == "up" then
   player.flp_y=true
   player.sp = 1 + (player.anim % 2)
  elseif player.dash_direction == "down" then
   player.flp_y=false
   player.sp = 1 + (player.anim % 2)
  end
 end
 --increment animation counters
 player.anim += 0.1
 player.dash_anim += 0.35
 player.trail_anim += 0.3
end


--collision logic two

function collide_map2(obj, aim, flag)
 --local variables
 local x, y, w, h = obj.x, obj.y, obj.w, obj.h
 local x1, y1, x2, y2
 --get direction
 if aim == "left" then
  x1, y1, x2, y2 = x - 1, y, x, y + h - 1
 elseif aim == "right" then
  x1, y1, x2, y2 = x + w, y, x + w + 1, y + h - 1
 elseif aim == "up" then
  x1, y1, x2, y2 = x, y - 1, x + w - 1, y
 elseif aim == "down" then
  x1, y1, x2, y2 = x, y + h, x + w - 1, y + h + 1
 end
 --collision logic
 x1, y1, x2, y2 = flr(x1 / 8), flr(y1 / 8), flr(x2 / 8), flr(y2 / 8)
 for ix = x1, x2 do
  for iy = y1, y2 do
   if fget(mget(ix, iy), flag) then
    if aim == "left" then 
     obj.x = ix * 8 + 8
    elseif aim == "right" then 
     obj.x = ix * 8 - obj.w
    elseif aim == "up" then 
     obj.y = iy * 8 + 8
    elseif aim == "down" then 
     obj.y = iy * 8 - obj.h
    end
    return true
   end
  end
 end
 --collision for unarmed spikes
 local inside_collision = false
 for spike in all(special_spikes) do
  if not spike.armed and is_player_inside_spike(obj, spike) then
   inside_collision = true
   break
  end
 end
 if inside_collision then
  return false
 end
 return false
end


--player two logic

function player2_update()
 if player.dead or player2.dead or player2.win then
  return
 end
 --dash movement
 if not player2.is_dashing then
  if btnp(⬅️) then
   player2.dash_direction = "left"
   player2.is_dashing = true
  elseif btnp(➡️) then
   player2.dash_direction = "right"
   player2.is_dashing = true
  elseif btnp(⬆️) then
   player2.dash_direction = "up"
   player2.is_dashing = true
  elseif btnp(⬇️) then
   player2.dash_direction = "down"
   player2.is_dashing = true
  end
 end
 --buffer next dash direction input
 if player2.is_dashing then
  if btnp(⬅️) then
   player2.next_dash_direction = "left"
  elseif btnp(➡️) then
   player2.next_dash_direction = "right"
  elseif btnp(⬆️) then
   player2.next_dash_direction = "up"
  elseif btnp(⬇️) then
   player2.next_dash_direction = "down"
  end
 end
 --start new dash
 if not player2.is_dashing then
  local dash_direction = player2.next_dash_direction or get_dash_direction()
  if dash_direction then
   player2.dash_direction = dash_direction
   player2.is_dashing = true
   player2.next_dash_direction = nil
  end
 end
 --dashing handling
 if player2.is_dashing then
  --accelerate to max speed
  if player2.dash_speed < player2.max_dash_speed then
   player2.dash_speed += player2.dash_acceleration
  else
  player2.dash_speed = player2.max_dash_speed
 end
 --apply dash direction
  if player2.dash_direction == "left" then
   player2.dx = -player2.dash_speed
   player2.dy = 0
  elseif player2.dash_direction == "right" then
   player2.dx = player2.dash_speed
   player2.dy = 0
  elseif player2.dash_direction == "up" then
   player2.dy = -player2.dash_speed
   player2.dx = 0
  elseif player2.dash_direction == "down" then
   player2.dy = player2.dash_speed
   player2.dx = 0
  end
 end
 --update player position
 player2.x += player2.dx
 player2.y += player2.dy
 --collision detection
 if (player2.dash_direction == "left" and collide_map2(player2, "left", 1)) or
  (player2.dash_direction == "right" and collide_map2(player2, "right", 1)) or
  (player2.dash_direction == "up" and collide_map2(player2, "up", 1)) or
  (player2.dash_direction == "down" and collide_map2(player2, "down", 1)) then
  player2.is_dashing = false
  player2.dash_speed = 0
  player2.dx, player2.dy = 0, 0
 end
 --limit player to map
 if player2.x<map_start then
  player2.x=map_start
 end
 if player2.x>map_end-player2.w then
   player2.x=map_end-player2.w
 end
 --head-on with spikes
 player2.spike_collision = false
 if player2.dash_direction == "left" then
  player2.spike_collision = collide_map2(player2, "left", 2)
 elseif player2.dash_direction == "right" then
  player2.spike_collision = collide_map2(player2, "right", 2)
 elseif player2.dash_direction == "up" then
  player2.spike_collision = collide_map2(player2, "up", 2)
 elseif player2.dash_direction == "down" then
  player2.spike_collision = collide_map2(player2, "down", 2)
 end
 --death circle
 if player2.spike_collision then
  sfx(3)
  player2.dead = true
  death_transition_active = true
  death_transition_player_x = player2.x
  death_transition_player_y = player2.y
 end
 --win collision
 local win_condition = collide_map2(player2, "left", 3) or collide_map2(player2, "right", 3) or collide_map2(player2, "up", 3) or collide_map2(player2, "down", 3)
 if win_condition then
  player2.win = true
 end
 if player.win and player2.win then
  init_win_transition()
 end
 --dash trail increment
 if player2.is_dashing then
  player2.dash_trail_delay += 1
 else
  player2.dash_trail_delay = 0
 end
 --arming spike collision
 for spike in all(special_spikes) do
  if player2.x == spike.x and player2.y == spike.y then
   if not spike.armed then
    spike.armed = true
    spike.timer = 30
    mset(spike.x, spike.y, get_armed_sprite(spike.x, spike.y))
   end
   for spike in all(special_spikes) do
    if player2.x == spike.x and player2.y == spike.y then
     if spike.armed and spike.timer < 30 then
      player2.dead = true
     end
    end
   end
  end
 end
end

function player2_animate()
 --dash animation
 if player2.is_dashing then
  if player2.dash_direction == "left" then
   player2.flp_x=true
   player2.sp = 26 + (player2.dash_anim % 5)
   player2.trail_sp1 = 40 + (player2.trail_anim % 3)
  elseif player2.dash_direction == "right" then
   player2.flp_x=false
   player2.sp = 26 + (player2.dash_anim % 5)
   player2.trail_sp1 = 40 + (player2.trail_anim % 3)
  elseif player2.dash_direction == "up" then
   player2.flp_y=false
   player2.sp = 10 + (player2.dash_anim % 5)
   player2.trail_sp1 = 56 + (player2.trail_anim % 3)
  elseif player2.dash_direction == "down" then
   player2.flp_y=true
   player2.sp = 10 + (player2.dash_anim % 5)
   player2.trail_sp1 = 56 + (player2.trail_anim % 3)
  end
 --idle animation
 else
  if player2.dash_direction == "left" then
   player2.flp_x=true
   player2.sp = 24 + (player2.anim % 2)
  elseif player2.dash_direction == "right" then
   player2.flp_x=false
   player2.sp = 24 + (player2.anim % 2)
  elseif player2.dash_direction == "up" then
   player2.flp_y=true
   player2.sp = 8 + (player2.anim % 2)
  elseif player2.dash_direction == "down" then
   player2.flp_y=false
   player2.sp = 8 + (player2.anim % 2)
  end
 end
 --increment animation counters
 player2.anim += 0.1
 player2.dash_anim += 0.35
 player2.trail_anim += 0.3
end


--other

--get player input
function get_dash_direction()
 if btnp(⬅️) then 
  return "left" 
 end
 if btnp(➡️) then 
  return "right" 
 end
 if btnp(⬆️) then 
  return "up" 
 end
 if btnp(⬇️) then 
  return "down" 
 end
 return nil
end

--linear interpolation camera
function lerp(a, b, t)
 return a + (b - a) * t
end

--timer
function timer()
 --show timer
 if show_timer then
  menuitem(_,"timer: hide")
  show_timer=false
 else
  menuitem(_,"timer: show")
  show_timer=true
 end
end

function update_timer()
 _time = time() - start_time
 ms = flr((_time % 1) * 100)
 s = flr(_time) % 60
 m = flr(_time / 60)
 ftime = m..":"..(s < 10 and "0" or "")..s.."."..(ms < 10 and "0" or "")..ms
end

--music
function toggle_music()
 music_on = not music_on 
 if music_on then
  menuitem(2, "music: on", toggle_music)
  music(0) 
 else
  menuitem(2, "music: off", toggle_music)
  music(-1)
 end
end

--stars
function starfield()
 for i=1,#starx do
  local scol=7
  if starspd[i]<1 then
   scol=1
  elseif starspd[i]<1.5 then
   scol=13
  end
  pset(starx[i],stary[i],scol)
 end
end

function animatestars()
 local wave_frequency = 0.02
 local max_amplitude = 0.3
 for i=1,#starx do
  starx[i] = starx[i] + starspd[i]
  if starx[i] > 1024 then
   starx[i] = starx[i] - 1024
  end
  local phase_shift = starx[i] * wave_frequency
   stary[i] = stary[i] + sin(phase_shift + time()) * (max_amplitude * starspd[i])
  end
end

--arming spikes
function init_arming_spikes()
 for i = 0, 127 do
  for j = 0, 63 do
   if fget(mget(i, j), 4) then  
    add(arming_spikes, {
     x = i,
     y = j,
     armed = false,
     timer = 0,
     direction = determine_spike_direction(i, j) 
    })
    mset(i, j, get_unarmed_sprite(i, j))
   end
  end
 end
end

function update_arming_spikes()
 if not death_transition_active then
  for spike in all(arming_spikes) do
   if spike.armed then
    sfx(11)
    spike.timer -= 1
    if spike.timer <= 0 then
     spike.armed = false
     mset(spike.x, spike.y, get_unarmed_sprite(spike.x, spike.y))
    end
   end
   if not spike.armed and spike.timer <= 0 and 
   (is_player_inside_spike(player, spike) or is_player_inside_spike(player2, spike)) then
    spike.timer = 25
   elseif not spike.armed and spike.timer > 0 then
    spike.timer -= 1
    if spike.timer == 0 then
     arm_spike(spike)
     if is_player_inside_spike(player, spike) then
      player.dead = true
     end
     if is_player_inside_spike(player2, spike) then
      player2.dead = true
     end
    end
   end
  end
 end
end

function is_player_inside_spike(player, spike)
 local spike_rect = { x = spike.x * 8, y = spike.y * 8, w = 8, h = 8 }
 return (player.x < spike_rect.x + spike_rect.w and	player.x + player.w > spike_rect.x and player.y < spike_rect.y + spike_rect.h and player.y + player.h > spike_rect.y)
end

function arm_spike(spike)
 spike.armed = true
 spike.timer = 20 
 mset(spike.x, spike.y, get_armed_sprite(spike.x, spike.y))
end

function is_spike_armed(x, y)
 for spike in all(arming_spikes) do
  if spike.x == x and spike.y == y then
   return spike.armed
  end
 end
 return false
end

function determine_spike_direction(x, y)
 local sprite = mget(x, y)
 local direction_map = {
  [96] = "up",    -- unarmed "up"
  [97] = "up",    -- armed "up"
  [98] = "down",  -- unarmed "down"
  [99] = "down",  -- armed "down"
  [100] = "left", -- unarmed "left"
  [101] = "left", -- armed "left"
  [102] = "right",-- unarmed "right"
  [103] = "right" -- armed "right"
 }
 return direction_map[sprite] or "up" 
end

function get_unarmed_sprite(x, y)
 local direction = determine_spike_direction(x, y)
 local sprite_offset = { up = 96, down = 98, left = 100, right = 102 }
 return sprite_offset[direction]
end

function get_armed_sprite(x, y)
 local direction = determine_spike_direction(x, y)
 local sprite_offset = { up = 97, down = 99, left = 101, right = 103 }
 return sprite_offset[direction]
end

--death circle
function handle_death_transition()
 if death_transition_active then
  death_transition_radius += death_transition_speed
  circfill(death_transition_player_x, death_transition_player_y, death_transition_radius, 0)
  starfield()
  if death_transition_radius >= death_transition_max_radius then
   death_transition_active = false
   init_death_menu()
  end
 end
end

function init_death_menu()
 _update = update_death
 _draw = draw_death
end

--win circle
function init_win_transition()
 win_transition_active = true
 win_transition_radius = 0
 win_transition_max_radius = 128
 win_transition_speed = 6
 win_transition_player1_x = player.x
 win_transition_player1_y = player.y
 win_transition_player2_x = player2.x
 win_transition_player2_y = player2.y
end

function handle_win_transition()
 if win_transition_active then
  win_transition_radius += win_transition_speed
  circfill(win_transition_player1_x, win_transition_player1_y, win_transition_radius, 0)
  circfill(win_transition_player2_x, win_transition_player2_y, win_transition_radius, 0)
  starfield()
  if win_transition_radius >= win_transition_max_radius then
   win_transition_active = false
   init_win_menu()
  end
 end
end

function init_win_menu()
 _update = update_win
 _draw = draw_win
end

--reset spikes
function reset_arming_spikes()
 for spike in all(arming_spikes) do
  spike.armed = false
  spike.timer = 0
  mset(spike.x, spike.y, get_unarmed_sprite(spike.x, spike.y))
 end
end
