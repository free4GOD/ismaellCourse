.code16
.global _start
.text

# Direccion Fisica = Segmento * 16 + Offset
# 0xA0000 = 0xA000 * 16 +
VIDEO_ADDRESS_SEGMENT = 0xA000

# Resoluciones a soportar, con cualquier cantidad de colores:
# 320x200
# 320x400
# 640x480
# 800x600
# 1024x768
# 1280x800
# 1920x1080

SCREEN_MODE		= 0x13
SCREEN_WIDTH		= 320
SCREEN_HEIGHT		= 200
SCREEN_COLORDEPTH	= 8

_start:
# Enter graphical mode
  movw $SCREEN_MODE, %ax           # VGA MODE
  int $0x10                        # 320x200 256colors

# Get Font bitmap with BIOS INT, save to "font" variable
  pushw %es
  mov $0x1130, %ax
  mov $0x03, %bh                   # ROM 8x8 double dot font pointer
  int $0x10
  mov %es, %ax
  mov %ax, (font)
  mov %bp, (font+2)
  popw %es

# Draw something
  # Create a VideoRes struct
  pushw $video_ctx
  pushw $SCREEN_WIDTH
  pushw $SCREEN_HEIGHT
  pushw $SCREEN_COLORDEPTH
  call VideoResDefine
  .byte 0xcc
  # Set position
  pushw $video_ctx
  pushw $((SCREEN_WIDTH * (SCREEN_HEIGHT - 8) + (SCREEN_WIDTH - (hello_end - hello - 1) * 8)) / 2)
  call VideoResSetPos
  # Set current color
  #movb $10, (video_ctx+VIDEORES_COLOR)
  pushw $video_ctx
  pushw $10
  call VideoResSetColor
  pushw $video_ctx
  pushw $hello # String
  call printstr

# Halt
halt:
  xor %ax, %ax
  int $0x16
  movb $3, %al
  int $0x10
  int $0x20


#------------------------------------------------------------------------------
# Video Abstractions
#
# VideoRes:
VIDEORES_BASE	= 0x00 /* Base Video Address (16 bits) */
VIDEORES_WIDTH	= 0x02 /*  Width (16 bits) */
VIDEORES_HEIGHT	= 0x04 /* Height (16 bits) */
VIDEORES_CWIDTH	= 0x06 /* Color width in bytes (16 bits) */
VIDEORES_PTR	= 0x08 /* Current position (16 bits) */
VIDEORES_COLOR	= 0x0A /* Current color (32 bits) */
VIDEORES__LEN__	= 0x0E

VideoResDefine: #(VideoRes *v, width, height, color_depth)
  push %bp
  movw %sp, %bp
  push %di
  movw 10(%bp), %di
  
  movw $0xA000, %ax
  stosw # VIDEORES_BASE(%di)
  movw 8(%bp), %ax
  stosw # VIDEORES_WIDTH(%di)
  movw 6(%bp), %ax
  stosw # VIDEORES_HEIGHT(%di)
  movw 4(%bp), %ax
  shl $3, %ax
  stosw # VIDEORES_CWIDTH(%di)
  xor %ax, %ax
  stosw # VIDEORES_PTR(%di)
  stosw # VIDEORES_COLOR(%di)
  stosw
  pop %di
  pop %bp
  retw $8

VideoResSetColor: #(VideoRes *v, color)
  push %bp
  movw %sp, %bp
  push %di
  movw 6(%bp), %di
  movw 4(%bp), %ax
  stosw # VIDEORES_COLOR(%di)
  pop %di
  pop %bp
  retw $4

VideoResSetPos: #(VideoRes *v, x, y)
  push %bp
  movw %sp, %bp
  push %di
  movw 8(%bp), %di
  movw 4(%bp), %ax
  mulw VIDEORES_WIDTH(%di)
  addw %ax, 6(%bp)
  mulw VIDEORES_CWIDTH(%di)
  movw %ax, VIDEORES_PTR(%di)
  pop %di
  pop %bp
  retw $6

#------------------------------------------------------------------------------

# printstr(VideoRes *v, const char *str) # str = 20(%bp), v = 18(%bp)
printstr:
  pushaw
  mov %sp, %bp

  push %es
  push %ds

  # %es = video segment
  mov $VIDEO_ADDRESS_SEGMENT, %ax
  mov %ax, %es
  # %ds = video font segment
  mov (font), %ax
  mov %ax, %ds

  movw 18(%bp), %si	# String
  movw 20(%bp), %bp	# VideoRes struct
  movw %cs:VIDEORES_PTR(%bp), %di    # Load current position in %di
  movw %cs:VIDEORES_COLOR(%bp), %dx

Lnextchar:
  # Load string char
  xor %ax, %ax
  lodsb %cs:(%si), %al
  test %al, %al
  jz 4f

  # Calculate char addr in the bitmap
  shl $3, %ax
  add %cs:(font+2), %ax
  mov %ax, %bx

# Print char

  mov $8, %cl
Lnextline:
  mov $8, %ch
  movb (%bx), %al
  inc %bx
1:
  rol $1, %al
  test $1, %al
  jz 2f
  # FIXME for CWIDTH != 1
  movb %dl, %es:(%di)
2:
  inc %di # FIXME for CWIDTH != 1
  dec %ch
  jnz 1b
  addw %cs:VIDEORES_WIDTH(%bp), %di
  sub $8, %di
  dec %cl
  jnz Lnextline
  add $8, %di
  movw %cs:VIDEORES_WIDTH(%bp), %ax
  shl $3, %ax
  sub %ax, %di
  jmp Lnextchar

4:
  pop %ds
  pop %es
  popaw
  retw $4

## Nested loops with 4-bit resolution each, example:
#	movw $0x20, %cl
#1:
#	...
#	orw $0x03, %cl
#2:
#	...
#	dec %cl
#	test $0xf, %cl
#	jnz 2b
#	...
#	sub $0x10, %cl
#	and $0xf0, %cl
#	jnz 1b


#-----------------------------------------
# Variables
font:  .long 0
hello: .asciz "Hola Mundo!"
hello_end:
video_ctx: .fill VIDEORES__LEN__, 1, 0
