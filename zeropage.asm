playerPosX = 2	;cfloat
playerPosY = 4
playerDir = 6	;0-255


c_dir_x = 7
c_dir_y = 8

matrixPointX = 9    ;cfloat
matrixPointY = 11
matrixDist = 13     ;2 byte
scan_dir = 18       ;used to know the current ray direction

tex_id1 = 15
tex_dist1 = 16
tex_hpos1 = 17
focal_inc = 19


scan_text_xy = 21

tex_step1 = 22  ;2 byte
tex_top1 = 24
tex_pix1 = 25   ;2 byte

current_pixs = 27
current_line = 28
z_depth = 29    ;40 bytes, tell the current Z depth of the colons

spr_dist = 69   ;2 bytes

spr_id = 71
spr_pixp1 = 72
spr_pixp2 = 73
spr_pix_mask1 = 74
spr_pix_mask2 = 75
spr_linePos = 76    ;2 bytes
spr_cline = 78
spr_col = 79 
spr_deca = 80 ; 2 bytes

c_dir_x2 = 82
c_dir_y2 = 83
spr_loop = 84

sprite_ptr = 85 ;2 bytes
sprite_ptr_mask = 87 ;2 bytes
object_x = 89
object_y = 90
rotation_speed = 91 

counter = 92


Keyboard_f1 = 160
Keyboard_f3 = 161
Keyboard_f5 = 162
Keyboard_f7 = 163
Keyborad_left = 164
Keyboard_right = 165
Keyboard_up = 166
Keyboard_down = 167
Keyboard_action = 168
Keyboard_1 = 169
Keyboard_2 = 170
Keyboard_3 = 171
Keyboard_4 = 172

temp16 = $af
temp8 = $ae
K_tempVar = $ae
obj_dist = $B0
obj_col_hit = $c0
obj_pos_hitx = $d0
obj_pos_hity = $e0
charMap = $f0   ;used to speed up the flip