; Wall.s : 壁
;


; モジュール宣言
;
    .module Wall

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Maze.inc"
    .include	"Wall.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 壁を初期化する
;
_WallInitialize::
    
    ; レジスタの保存
    
    ; 壁の初期化
    ld      hl, #(_wall + 0x0000)
    ld      de, #(_wall + 0x0001)
    ld      bc, #(WALL_SIZE_X * WALL_SIZE_Y - 0x0001)
    ld      (hl), #WALL_NULL
    ldir

    ; 出口の初期化
    ld      hl, #(wallExit + 0x0000)
    ld      de, #(wallExit + 0x0001)
    ld      bc, #(WALL_EXIT_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; 壁を更新する
;
_WallUpdate::
    
    ; レジスタの保存

    ; 出口の更新
    ld      a, (wallExit + WALL_EXIT_STATE)
    or      a
    jr      nz, 10$
    ld      hl, (wallExit + WALL_EXIT_WALL_L)
    ld      a, h
    or      l
    jr      z, 19$    
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      nz, 19$
    ld      a, #WALL_EXIT_STATE_DIG
    ld      (wallExit + WALL_EXIT_STATE), a
    jr      11$
10$:
    dec     a
    jr      nz, 12$
11$:
    call    _EnemyGetAttribute
    inc     a
    jr      nz, 18$
    ld      a, (_player + PLAYER_CRYSTAL)
    cp      #PLAYER_CRYSTAL_MAXIMUM
    jr      c, 18$
    ld      a, #SOUND_BGM_OPEN
    call    _SoundPlayBgm
    ld      a, #WALL_EXIT_STATE_OPEN
    ld      (wallExit + WALL_EXIT_STATE), a
;   jr      12$
12$:
    ld      hl, #(wallExit + WALL_EXIT_ANIMATION)
    inc     (hl)
18$:
    ld      a, (wallExit + WALL_EXIT_ANIMATION)
    and     #0x0c
    rlca
    ld      e, a
    ld      d, #0x00
    ld      hl, #wallExitSprite
    add     hl, de
    ld      (wallExit + WALL_EXIT_SPRITE_L), hl
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 壁を描画する
;
_WallRender::

    ; レジスタの保存

    ; 出口の描画
    ld      hl, (wallExit + WALL_EXIT_SPRITE_L)
    ld      a, h
    or      l
    jr      z, 19$
    ld      de, #(_sprite + GAME_SPRITE_EXIT_0)
    ld      bc, (wallExit + WALL_EXIT_POSITION_X)
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エリアに入る
;
_WallEnter::

    ; レジスタの保存

    ; 乱数の種の設定
    ld      a, (_game + GAME_AREA)
    call    _MazeGetSeed
    ld      (wallSeed), a

    ; 壁の展開

    ; LEFT-TOP
100$:
    ld      a, (_game + GAME_AREA)
    call    _MazeGetTopArea
    call    _MazeGetLeftArea
    call    _MazeGetWalls
    ld      de, #(MAZE_WALL_SIZE_Y * MAZE_WALL_BYTE_X - 0x0001)
    add     hl, de
    ld      a, (hl)
    rrca
    rrca
    rrca
    and     #WALL_TYPE_WALL
    ld      (_wall + 0x0000), a

    ; CENTER-TOP
    ld      a, (_game + GAME_AREA)
    call    _MazeGetTopArea
    call    _MazeGetWalls
    ld      de, #((MAZE_WALL_SIZE_Y - 0x0001) * MAZE_WALL_BYTE_X)
    add     hl, de
    ld      de, #(_wall + WALL_VIEW_LEFT)
    ld      a, (hl)
    inc     hl
    rrca
    ld      c, a
    ld      b, #WALL_TYPE_WALL
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    ld      a, (hl)
    inc     hl
    rrca
    ld      c, a
;   ld      b, #WALL_TYPE_WALL
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
;   inc     de

    ; RIGHT-TOP
120$:
    ld      a, (_game + GAME_AREA)
    call    _MazeGetTopArea
    call    _MazeGetRightArea
    call    _MazeGetWalls
    ld      de, #((MAZE_WALL_SIZE_Y - 0x0001) * MAZE_WALL_BYTE_X)
    add     hl, de
    ld      de, #(_wall + WALL_VIEW_RIGHT + 0x0001)
    ld      a, (hl)
    ld      c, a
    and     #WALL_TYPE_WALL
    ld      (de), a
    dec     de
    ld      a, c
    rrca
    and     #WALL_TYPE_WALL
    ld      (de), a

    ; LEFT-MIDDLE
    ld      a, (_game + GAME_AREA)
    call    _MazeGetLeftArea
    call    _MazeGetWalls
    inc     hl
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X)
    ex      de, hl
    ld      b, #MAZE_WALL_SIZE_Y
130$:
    push    bc
    ld      a, (de)
    inc     de
    inc     de
    rrca
    rrca
    rrca
    and     #WALL_TYPE_WALL
    ld      (hl), a
    ld      bc, #WALL_SIZE_X
    add     hl, bc
    pop     bc
    djnz    130$

    ; CENTER-MIDDLE
    ld      a, (_game + GAME_AREA)
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      b, #MAZE_WALL_SIZE_Y
140$:
    push    bc
    ld      a, (hl)
    inc     hl
    rrca
    ld      c, a
    ld      b, #WALL_TYPE_WALL
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    ld      a, (hl)
    inc     hl
    rrca
    ld      c, a
;   ld      b, #WALL_TYPE_WALL
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    inc     de
    inc     de
    inc     de
    pop     bc
    djnz    140$

    ; RIGHT-MIDDLE
    ld      a, (_game + GAME_AREA)
    call    _MazeGetRightArea
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X + WALL_VIEW_RIGHT + 0x0001)
    ex      de, hl
    ld      b, #MAZE_WALL_SIZE_Y
150$:
    push    bc
    ld      a, (de)
    inc     de
    inc     de
    ld      c, a
    and     #WALL_TYPE_WALL
    ld      (hl), a
    dec     hl
    ld      a, c
    rrca
    and     #WALL_TYPE_WALL
    ld      (hl), a
    ld      bc, #(WALL_SIZE_X + 0x0001)
    add     hl, bc
    pop     bc
    djnz    150$

    ; LEFT-BOTTOM
160$:
    ld      a, (_game + GAME_AREA)
    call    _MazeGetBottomArea
    call    _MazeGetLeftArea
    call    _MazeGetWalls
    inc     hl
    ld      de, #(_wall + WALL_VIEW_BOTTOM * WALL_SIZE_X)
    ex      de, hl
    ld      a, (de)
    inc     de
    inc     de
    rrca
    rrca
    rrca
    and     #WALL_TYPE_WALL
    ld      (hl), a
    ld      bc, #WALL_SIZE_X
    add     hl, bc
    ld      a, (de)
    rrca
    rrca
    rrca
    and     #WALL_TYPE_WALL
    ld      (hl), a

    ; CENTER_BOTTOM
    ld      a, (_game + GAME_AREA)
    call    _MazeGetBottomArea
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_BOTTOM * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      b, #0x02
170$:
    push    bc
    ld      a, (hl)
    inc     hl
    rrca
    ld      c, a
    ld      b, #WALL_TYPE_WALL
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    ld      a, (hl)
    inc     hl
    rrca
    ld      c, a
;   ld      b, #WALL_TYPE_WALL
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    rlc     c
    ld      a, c
    and     b
    ld      (de), a
    inc     de
    inc     de
    inc     de
    inc     de
    pop     bc
    djnz    170$

    ; RIGHT-BOTTOM
180$:
    ld      a, (_game + GAME_AREA)
    call    _MazeGetBottomArea
    call    _MazeGetRightArea
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_BOTTOM * WALL_SIZE_X + WALL_VIEW_RIGHT + 0x0001)
    ex      de, hl
    ld      a, (de)
    inc     de
    inc     de
    ld      c, a
    and     #WALL_TYPE_WALL
    ld      (hl), a
    dec     hl
    ld      a, c
    rrca
    and     #WALL_TYPE_WALL
    ld      (hl), a
    ld      bc, #(WALL_SIZE_X + 0x0001)
    add     hl, bc
    ld      a, (de)
    ld      c, a
    and     #WALL_TYPE_WALL
    ld      (hl), a
    dec     hl
    ld      a, c
    rrca
    and     #WALL_TYPE_WALL
    ld      (hl), a

    ; 配置の作成
    ld      hl, #wallLocateDefault
    ld      de, #wallLocate
    ld      bc, #WALL_LOCATE_LENGTH
    ldir
    ld      hl, #wallLocate
    ld      b, #WALL_LOCATE_LENGTH
20$:
    call    WallGetRandom
    srl     a
    cp      #WALL_LOCATE_LENGTH
    jr      nc, 20$
    push    hl
    ld      e, a
    ld      d, #0x00
    ld      hl, #wallLocate
    add     hl, de
    ex      de, hl
    pop     hl
    ld      c, (hl)
    ld      a, (de)
    ld      (hl), a
    ld      a, c
    ld      (de), a
    inc     hl
    djnz    20$

    ; クリスタルの展開
    ld      a, (_game + GAME_AREA)
    call    _MazeGetCrystals
    ld      c, (hl)
    ld      hl, #(wallLocate + WALL_LOCATE_CRYSTAL)
30$:
    sla     c
    jr      nc, 39$
    push    hl
    ld      e, (hl)
    ld      d, #0x00
    ld      hl, #_wall
    add     hl, de
    ld      a, (hl)
    and     #(WALL_PATTERN_MASK | WALL_TYPE_WALL)
    or      #WALL_TYPE_CRYSTAL
    ld      (hl), a
    pop     hl
39$:
    inc     hl
    inc     b
    ld      a, c
    or      a
    jr      nz, 30$

    ; 宝の展開
    ld      a, (_game + GAME_AREA)
    call    _MazeGetTreasure
    or      a
    jr      z, 49$
    ld      a, (wallLocate + WALL_LOCATE_TREASURE)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_wall
    add     hl, de
    ld      a, (hl)
    or      #WALL_TYPE_TREASURE
    ld      (hl), a
49$:

    ; 呪いの展開
    ld      a, (_game + GAME_AREA)
    call    _MazeGetCurse
    or      a
    jr      z, 59$
    ld      b, a
    ld      hl, #(wallLocate + WALL_LOCATE_CURSE)
50$:
    push    hl
    ld      e, (hl)
    ld      d, #0x00
    ld      hl, #_wall
    add     hl, de
    ld      a, (hl)
    or      #WALL_TYPE_CURSE
    ld      (hl), a
    pop     hl
    inc     hl
    djnz    50$
59$:

    ; 出口の設定
    ld      hl, #(wallExit + 0x0000)
    ld      de, #(wallExit + 0x0001)
    ld      bc, #(WALL_EXIT_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      a, (_game + GAME_AREA)
    call    _MazeGetFlag
    and     #MAZE_FLAG_EXIT
    jr      z, 69$
    ld      a, (wallLocate + WALL_LOCATE_TREASURE)
    ld      e, a
    ld      d, #0x00
    ld      hl, #_wall
    add     hl, de
    ld      (wallExit + WALL_EXIT_WALL_L), hl
    ld      hl, #wallLocatePosition
    add     hl, de
    ld      a, (hl)
    ld      d, a
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      (wallExit + WALL_EXIT_POSITION_X), a
    ld      a, d
    and     #0xf0
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      (wallExit + WALL_EXIT_POSITION_Y), a
    xor     a
    ld      (wallExit + WALL_EXIT_ANIMATION), a
    jr      69$
69$:

    ; パターンの作成

    ; LEFT-TOP
700$:

    ; CENTER-TOP
710$:

    ; RIGHT-TOP
720$:

    ; LEFT-MIDDLE
730$:

    ; CENTER-MIDDLE
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      c, #WALL_VIEW_SIZE_Y
740$:
    ld      b, #WALL_VIEW_SIZE_X
741$:
    ld      a, (de)
    ld      hl, #-WALL_SIZE_X
    add     hl, de
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 742$
    set     #WALL_PATTERN_TOP_BIT, a
742$:
    ld      hl, #-0x0001
    add     hl, de
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 743$
    set     #WALL_PATTERN_LEFT_BIT, a
743$:
    inc     hl
    inc     hl
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 744$
    set     #WALL_PATTERN_RIGHT_BIT, a
744$:
    ld      hl, #WALL_SIZE_X
    add     hl, de
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 745$
    set     #WALL_PATTERN_BOTTOM_BIT, a
745$:
    ld      (de), a
    inc     de
    djnz    741$
    inc     de
    inc     de
    dec     c
    jr      nz, 740$

    ; RIGHT-MIDDLE
750$:

    ; LEFT_BOTTOM
760$:

    ; CENTER-BOTTOM
    ld      de, #(_wall + WALL_VIEW_BOTTOM * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      b, #WALL_VIEW_SIZE_X
770$:
    ld      a, (de)
    ld      hl, #-WALL_SIZE_X
    add     hl, de
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 771$
    set     #WALL_PATTERN_TOP_BIT, a
771$:
    ld      hl, #-0x0001
    add     hl, de
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 772$
    set     #WALL_PATTERN_LEFT_BIT, a
772$:
    inc     hl
    inc     hl
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 773$
    set     #WALL_PATTERN_RIGHT_BIT, a
773$:
    ld      hl, #WALL_SIZE_X
    add     hl, de
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      z, 774$
    set     #WALL_PATTERN_BOTTOM_BIT, a
774$:
    ld      (de), a
    inc     de
    djnz    770$

    ; RIGHT-BOTTOM
780$:

    ; パターンネームの展開
    ld      hl, #_patternName
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      b, #WALL_VIEW_SIZE_Y
80$:
    push    bc
    ld      b, #WALL_VIEW_SIZE_X
81$:
    push    bc
    ld      a, (de)
    inc     de
    push    de
    ex      de, hl
;   and     #(WALL_TYPE_MASK | WALL_PATTERN_MASK)
    ld      b, #0x00
    add     a, a
    rl      b
    add     a, a
    rl      b
    ld      c, a
    ld      hl, #wallPatternName
    add     hl, bc
    ex      de, hl
    ld      bc, #0x001f
    ld      a, (de)
    inc     de
    ld      (hl), a
    inc     hl
    ld      a, (de)
    inc     de
    ld      (hl), a
    add     hl, bc
    ld      a, (de)
    inc     de
    ld      (hl), a
    inc     hl
    ld      a, (de)
    inc     de
    ld      (hl), a
    or      a
    sbc     hl, bc
    pop     de
    pop     bc
    djnz    81$
    ld      bc, #0x0020
    add     hl, bc
    inc     de
    inc     de
    pop     bc
    djnz    80$

    ; レジスタの復帰

    ; 終了
    ret

; エリアから出る
;
_WallExit::

    ; レジスタの保存

    ; 壁の反映

    ; LEFT-TOP
100$:

    ; CENTER-TOP
110$:

    ; RIGHT-TOP
120$:

    ; LEFT-MIDDLE
130$:

    ; CENTER-MIDDLE
    ld      a, (_game + GAME_AREA)
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      b, #MAZE_WALL_SIZE_Y
140$:
    push    bc
    ld      c, #0x00
    ld      b, #0x08
141$:
    ld      a, (de)
    inc     de
    rlca
    rlca
    rl      c
    djnz    141$
    ld      a, c
    ld      (hl), a
    inc     hl
    ld      c, #0x00
    ld      b, #0x07
142$:
    ld      a, (de)
    inc     de
    rlca
    rlca
    rl      c
    djnz    142$
    ld      a, c
    add     a, a
    ld      (hl), a
    inc     hl
    inc     de
    inc     de
    inc     de
    pop     bc
    djnz    140$

    ; RIGHT-MIDDLE
    ld      a, (_game + GAME_AREA)
    call    _MazeGetRightArea
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_TOP * WALL_SIZE_X + WALL_VIEW_RIGHT)
    ex      de, hl
    ld      b, #MAZE_WALL_SIZE_Y
150$:
    push    bc
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jr      nz, 151$
    ld      a, (de)
    and     #0b01111111
    ld      (de), a
151$:
    inc     de
    inc     de
    ld      bc, #WALL_SIZE_X
    add     hl, bc
    pop     bc
    djnz    150$

    ; LEFT-BOTTOM
160$:

    ; CENTER-BOTTOM
    ld      a, (_game + GAME_AREA)
    call    _MazeGetBottomArea
    call    _MazeGetWalls
    ld      de, #(_wall + WALL_VIEW_BOTTOM * WALL_SIZE_X + WALL_VIEW_LEFT)
    ld      c, #0x00
    ld      b, #0x08
170$:
    ld      a, (de)
    inc     de
    rlca
    rlca
    rl      c
    djnz    170$
    ld      a, c
    ld      (hl), a
    inc     hl
    ld      c, #0x00
    ld      b, #0x07
171$:
    ld      a, (de)
    inc     de
    rlca
    rlca
    rl      c
    djnz    171$
    ld      a, c
    add     a, a
    ld      (hl), a

    ; RIGHT-BOTTOM
    ld      a, (_game + GAME_AREA)
    call    _MazeGetBottomArea
    call    _MazeGetRightArea
    call    _MazeGetWalls
    ld      a, (_wall + WALL_VIEW_BOTTOM * WALL_SIZE_X + WALL_VIEW_RIGHT)
    bit     #WALL_TYPE_WALL_BIT, a
    jr      nz, 180$
    res     #0x07, (hl)
180$:

    ; クリスタルの回収
    ld      hl, #(wallLocate + WALL_LOCATE_CRYSTAL)
    ld      bc, #((WALL_LOCATE_CRYSTAL_LENGTH << 8) | 0x00)
20$:
    push    hl
    ld      e, (hl)
    ld      d, #0x00
    ld      hl, #_wall
    add     hl, de
    ld      a, (hl)
    and     #(WALL_TYPE_MASK & ~WALL_TYPE_WALL)
    cp      #WALL_TYPE_CRYSTAL
    jr      nz, 21$
    scf
    jr      22$
21$:
    or      a
;   jr      22$
22$:
    rl      c
    pop     hl
    inc     hl
    djnz    20$
    ld      a, (_game + GAME_AREA)
    call    _MazeGetCrystals
    ld      (hl), c

    ; 宝の回収

    ; 呪いの回収

    ; レジスタの復帰

    ; 終了
    ret

; 乱数を取得する
;
WallGetRandom:

    ; レジスタの保存
    push    de

    ; a > 乱数

    ; 乱数の取得
    ld      a, (wallSeed)
    ld      e, a
    add     a, a
    add     a, a
    add     a, e
    inc     a
    ld      (wallSeed), a

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 壁を取得する
;
WallGet:

    ; レジスタの保存
    push    de

    ; de < Y/X 位置
    ; hl > _wall

    ; 壁の取得
    ld      a, d
    and     #0xf0
    ld      d, a
    rrca
    rrca
    rrca
    add     a, d
    add     a, #WALL_SIZE_X
    ld      d, a
    ld      a, e
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    inc     a
    add     a, d
    ld      e, a
    ld      d, #0x00
    ld      hl, #_wall
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 壁を掘る
;
_WallDig::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < Y/X 位置
    ; cf > 1 = 掘った

    ; 掘る
    ld      a, d
    and     #0xf0
    ld      c, a
    rrca
    rrca
    rrca
    add     a, c
    add     a, #WALL_SIZE_X
    ld      c, a
    ld      a, e
    and     #0xf0
    rrca
    rrca
    rrca
    rrca
    inc     a
    add     a, c
    ld      c, a
    ld      b, #0x00
    ld      hl, #(_wall + 0x0000)
    add     hl, bc
    bit     #WALL_TYPE_WALL_BIT, (hl)
    jp      z, 180$
    ld      a, e
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, d
    and     #0xf0
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, e
    ld      e, a
    res     #WALL_TYPE_WALL_BIT, (hl)
    ld      a, (hl)
;   and     #(WALL_TYPE_MASK | WALL_PATTERN_MASK)
    ld      hl, #(_patternName + 0x0000)
    add     hl, de
    call    110$
    ld      a, d
    or      a
    jr      nz, 100$
    ld      a, e
    and     #0xc0
    jr      z, 101$
100$:
    ld      hl, #(_wall - WALL_SIZE_X)
    add     hl, bc
    res     #WALL_PATTERN_BOTTOM_BIT, (hl)
    ld      a, (hl)
;   and     #(WALL_TYPE_MASK | WALL_PATTERN_MASK)
    ld      hl, #(_patternName - 0x0040)
    add     hl, de
    call    110$
101$:
    ld      a, e
    and     #0x3f
    jr      z, 102$
    ld      hl, #(_wall - 0x0001)
    add     hl, bc
    res     #WALL_PATTERN_RIGHT_BIT, (hl)
    ld      a, (hl)
;   and     #(WALL_TYPE_MASK | WALL_PATTERN_MASK)
    ld      hl, #(_patternName - 0x0002)
    add     hl, de
    call    110$
102$:
    ld      a, e
    and     #0x3f
    cp      #0x1e
    jr      nc, 103$
    ld      hl, #(_wall + 0x0001)
    add     hl, bc
    res     #WALL_PATTERN_LEFT_BIT, (hl)
    ld      a, (hl)
;   and     #(WALL_TYPE_MASK | WALL_PATTERN_MASK)
    ld      hl, #(_patternName + 0x0002)
    add     hl, de
    call    110$
103$:
    ld      a, d
    cp      #0x02
    jr      nz, 104$
    ld      a, e
    and     #0xc0
    cp      #0x80
    jr      z, 105$
104$:
    ld      hl, #(_wall + WALL_SIZE_X)
    add     hl, bc
    res     #WALL_PATTERN_TOP_BIT, (hl)
    ld      a, (hl)
;   and     #(WALL_TYPE_MASK | WALL_PATTERN_MASK)
    ld      hl, #(_patternName + 0x0040)
    add     hl, de
    call    110$
105$:
    scf
    jr      190$

    ; パターンネームの設定
110$:
    push    bc
    push    de
    push    hl
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #wallPatternName
    add     hl, de
    pop     de
    ex      de, hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    inc     de
    ld      bc, #0x001f
    add     hl, bc
    ld      a, (de)
    ld      (hl), a
    inc     de
    inc     hl
    ld      a, (de)
    ld      (hl), a
    pop     de
    pop     bc
    ret

    ; すでに掘ってある
180$:
    or      a
;   jr      190$

    ; 掘るの完了
190$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 宝を掘る
;
_WallDigTreasure::

    ; レジスタの保存
    push    hl
    push    de

    ; cf > 1 = 掘った

    ; 宝がある場合は掘る
    ld      a, (_game + GAME_AREA)
    call    _MazeGetTreasure
    or      a
    jr      z, 19$
    ld      a, (wallLocate + WALL_LOCATE_TREASURE)
    ld      e, a
    ld      d, #0x00
    ld      hl, #wallLocatePosition
    add     hl, de
    ld      a, (hl)
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, (hl)
    and     #0xf0
    ld      d, a
    call    _WallDig
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; すでに掘られた通路かを判定する
;
_WallIsPath::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; cf > 1 = 通路

    ; 通路の判定
    call    WallGet
    ld      a, (hl)
    and     #WALL_TYPE_WALL
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 出口に入ったどうかを判定する
;
_WallIsExit::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; cf > 1 = 出口に入った

    ; 出口の判定
    ld      a, (wallExit + WALL_EXIT_STATE)
    cp      #WALL_EXIT_STATE_OPEN
    jr      nz, 18$
    ld      hl, (wallExit + WALL_EXIT_POSITION_X)
    ld      a, l
    sub     e
    jr      nc, 10$
    neg
10$:
    cp      #WALL_EXIT_R
    jr      nc, 18$
    ld      a, h
    sub     d
    jr      nc, 11$
    neg
11$:
    cp      #WALL_EXIT_R
    jr      nc, 18$
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 宝を拾う
;
_WallPickupTreasure::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < Y/X 位置
    ; a  > アイテム

    ; アイテムを拾う
    call    WallGet
    ld      a, (hl)
    bit     #WALL_TYPE_WALL_BIT, a
    jr      nz, 18$
    and     #WALL_TYPE_MASK
    jr      z, 18$
    cp      #WALL_TYPE_CRYSTAL
    jr      nz, 10$
    ld      a, #ITEM_CRYSTAL
    jr      17$
10$:
    cp      #WALL_TYPE_CURSE
    jr      nz, 11$
    ld      a, #ITEM_CURSE
    jr      19$
11$:
    cp      #WALL_TYPE_TREASURE
    jr      nz, 12$
    ld      a, (_game + GAME_AREA)
    call    _MazePickupTreasure
    jr      17$
12$:
    jr      18$
17$:
    push    af
    ld      a, (hl)
    and     #WALL_PATTERN_MASK
    ld      (hl), a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #wallPatternName
    add     hl, bc
    push    hl
    ld      a, e
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      a, d
    and     #0xf0
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, e
    ld      e, a
    ld      hl, #_patternName
    add     hl, de
    pop     de
    ld      a, (de)
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    ld      (hl), a
    ld      bc, #0x001f
    add     hl, bc
    inc     de
    ld      a, (de)
    ld      (hl), a
    inc     hl
    inc     de
    ld      a, (de)
    ld      (hl), a
;   inc     hl
;   inc     de
    pop     af
    jr      19$
18$:
    xor     a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 指定した位置のパターンを取得する
;
_WallGetPattern::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; a  > パターン

    ; パターンの取得
    call    WallGet
    ld      a, (hl)
    and     #WALL_PATTERN_MASK

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; エネミーの配置を取得する
;
_WallGetEnemyLocation::

    ; レジスタの保存
    push    hl

    ; a  < エネミーの順番
    ; de > Y/X 位置

    ; 位置の取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #(wallLocateEnemyPosition)
    add     hl, de
    ld      a, (hl)
    ld      d, a
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      e, a
    ld      a, d
    and     #0xf0
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      d, a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 宝の配置を取得する
;
_WallGetTreasureLocation::

    ; レジスタの保存
    push    hl

    ; de > Y/X 位置

    ; 位置の取得
    ld      a, (wallLocate + WALL_LOCATE_TREASURE)
    ld      e, a
    ld      d, #0x00
    ld      hl, #wallLocatePosition
    add     hl, de
    ld      a, (hl)
    ld      d, a
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      e, a
    ld      a, d
    and     #0xf0
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      d, a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; ランダムな配置を取得する
;
_WallGetRandomLocation::

    ; レジスタの保存
    push    hl

    ; de > Y/X 位置

    ; 位置の取得
    call    _SystemGetRandom
    rrca
    rrca
    and     #(WALL_LOCATE_RANDOM_LENGTH - 0x01)
    add     a, #WALL_LOCATE_RANDOM
    ld      e, a
    ld      d, #0x00
    ld      hl, #wallLocate
    add     hl, de
    ld      e, (hl)
;   ld      d, #0x00
    ld      hl, #wallLocatePosition
    add     hl, de
    ld      a, (hl)
    ld      d, a
    and     #0x0f
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      e, a
    ld      a, d
    and     #0xf0
    add     a, #(WALL_SIZE_PIXEL / 2)
    ld      d, a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

;　パターンネーム
;
wallPatternName:

    ; 地面 - 通路
    .db     0x45, 0x46, 0x49, 0x4a
    .db     0x41, 0x42, 0x49, 0x4a
    .db     0x45, 0x46, 0x4d, 0x4e
    .db     0x41, 0x42, 0x4d, 0x4e
    .db     0x44, 0x46, 0x48, 0x4a
    .db     0x40, 0x42, 0x48, 0x4a
    .db     0x44, 0x46, 0x4c, 0x4e
    .db     0x40, 0x42, 0x4c, 0x4e
    .db     0x45, 0x47, 0x49, 0x4b
    .db     0x41, 0x43, 0x49, 0x4b
    .db     0x45, 0x47, 0x4d, 0x4f
    .db     0x41, 0x43, 0x4d, 0x4f
    .db     0x44, 0x47, 0x48, 0x4b
    .db     0x40, 0x43, 0x48, 0x4b
    .db     0x44, 0x47, 0x4c, 0x4f
    .db     0x40, 0x43, 0x4c, 0x4f
    ; 地面 - クリスタル
    .db     0x55, 0x56, 0x59, 0x5a
    .db     0x51, 0x52, 0x59, 0x5a
    .db     0x55, 0x56, 0x5d, 0x5e
    .db     0x51, 0x52, 0x5d, 0x5e
    .db     0x54, 0x56, 0x58, 0x5a
    .db     0x50, 0x52, 0x58, 0x5a
    .db     0x54, 0x56, 0x5c, 0x5e
    .db     0x50, 0x52, 0x5c, 0x5e
    .db     0x55, 0x57, 0x59, 0x5b
    .db     0x51, 0x53, 0x59, 0x5b
    .db     0x55, 0x57, 0x5d, 0x5f
    .db     0x51, 0x53, 0x5d, 0x5f
    .db     0x54, 0x57, 0x58, 0x5b
    .db     0x50, 0x53, 0x58, 0x5b
    .db     0x54, 0x57, 0x5c, 0x5f
    .db     0x50, 0x53, 0x5c, 0x5f
    ; 地面 - 宝
    .db     0x65, 0x66, 0x69, 0x6a
    .db     0x61, 0x62, 0x69, 0x6a
    .db     0x65, 0x66, 0x6d, 0x6e
    .db     0x61, 0x62, 0x6d, 0x6e
    .db     0x64, 0x66, 0x68, 0x6a
    .db     0x60, 0x62, 0x68, 0x6a
    .db     0x64, 0x66, 0x6c, 0x6e
    .db     0x60, 0x62, 0x6c, 0x6e
    .db     0x65, 0x67, 0x69, 0x6b
    .db     0x61, 0x63, 0x69, 0x6b
    .db     0x65, 0x67, 0x6d, 0x6f
    .db     0x61, 0x63, 0x6d, 0x6f
    .db     0x64, 0x67, 0x68, 0x6b
    .db     0x60, 0x63, 0x68, 0x6b
    .db     0x64, 0x67, 0x6c, 0x6f
    .db     0x60, 0x63, 0x6c, 0x6f
    ; 地面 - 呪い
    .db     0x75, 0x76, 0x79, 0x7a
    .db     0x71, 0x72, 0x79, 0x7a
    .db     0x75, 0x76, 0x7d, 0x7e
    .db     0x71, 0x72, 0x7d, 0x7e
    .db     0x74, 0x76, 0x78, 0x7a
    .db     0x70, 0x72, 0x78, 0x7a
    .db     0x74, 0x76, 0x7c, 0x7e
    .db     0x70, 0x72, 0x7c, 0x7e
    .db     0x75, 0x77, 0x79, 0x7b
    .db     0x71, 0x73, 0x79, 0x7b
    .db     0x75, 0x77, 0x7d, 0x7f
    .db     0x71, 0x73, 0x7d, 0x7f
    .db     0x74, 0x77, 0x78, 0x7b
    .db     0x70, 0x73, 0x78, 0x7b
    .db     0x74, 0x77, 0x7c, 0x7f
    .db     0x70, 0x73, 0x7c, 0x7f
    ; 壁 - 通路
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    ; 壁 - クリスタル
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    .db     0x8c, 0x8d, 0x8e, 0x8f
    ; 壁 - 宝
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    .db     0x80, 0x80, 0x80, 0x80
    ; 壁 - 呪い
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90
    .db     0x90, 0x90, 0x90, 0x90

; 位置
;
wallLocateDefault:

    .db     0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33
    .db     0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45
    .db     0x4a, 0x4b,       0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54,       0x56, 0x57
    .db     0x5c, 0x5d, 0x5e, 0x5f, 0x60,                         0x65, 0x66, 0x67, 0x68, 0x69
    .db     0x6e, 0x6f, 0x70, 0x71, 0x72,                         0x77, 0x78, 0x79, 0x7a, 0x7b
    .db     0x80, 0x81, 0x82, 0x83, 0x84,                         0x89, 0x8a, 0x8b, 0x8c, 0x8d
    .db     0x92, 0x93,       0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c,       0x9e, 0x9f
    .db     0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xb0, 0xb1
    .db     0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf, 0xc0, 0xc1, 0xc2, 0xc3
    
wallLocatePosition:

    .db     0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x0f
    .db     0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x0f
    .db     0x10, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x1f
    .db     0x20, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x2f
    .db     0x30, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x3f
    .db     0x40, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x4f
    .db     0x50, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x5f
    .db     0x60, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x6f
    .db     0x70, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f, 0x7f
    .db     0x80, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f, 0x8f
    .db     0x90, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f, 0x9f
    .db     0xa0, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xaf
    .db     0xa0, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, 0xaf

wallLocateEnemyPosition:

    .db     0x64, 0x49, 0x46, 0x69
    .db     0x3c, 0x73, 0x33, 0x7c

; 出口
;
wallExitSprite:

    .db     -0x08 - 0x01, -0x08, 0x4d, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01, -0x08, 0x4c, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x4e, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01, -0x08, 0x4c, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x4f, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01, -0x08, 0x4c, VDP_COLOR_BLACK
    .db     -0x08 - 0x01, -0x08, 0x00, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01, -0x08, 0x4c, VDP_COLOR_BLACK
    

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 壁
;
_wall::
    
    .ds     WALL_SIZE_X * WALL_SIZE_Y

; 配置
;
wallLocate:

    .ds     WALL_LOCATE_LENGTH

; 乱数の種
;
wallSeed:

    .ds     0x01

; 出口
;
wallExit:

    .ds     WALL_EXIT_LENGTH

