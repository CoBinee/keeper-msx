; Maze.s : 迷路
;


; モジュール宣言
;
    .module Maze

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include	"Maze.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 迷路を初期化する
;
_MazeInitialize::
    
    ; レジスタの保存

    ; 迷路の初期化
    ld      de, #_maze
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x00)
10$:
    push    bc
    push    de
    ld      hl, #mazeDefault
    ld      bc, #MAZE_LENGTH
    ldir
    pop     hl
;   ld      bc, #MAZE_AREA
;   add     hl, bc
    ld      (hl), c
    pop     bc
    djnz    10$

    ; 順番の設定
    ld      hl, #mazeOrder
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x00)
20$:
    ld      (hl), c
    inc     hl
    inc     c
    djnz    20$
    ld      de, #mazeOrder
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
21$:
    push    bc
    call    _SystemGetRandom
    rrca
    rrca
    and     #(MAZE_SIZE_X * MAZE_SIZE_Y - 0x01)
    ld      c, a
    ld      b, #0x00
    ld      hl, #mazeOrder
    add     hl, bc
    ld      c, (hl)
    ld      a, (de)
    ld      (hl), a
    ld      a, c
    ld      (de), a
    pop     bc
    inc     hl
    djnz    21$
    ld      de, #mazeOrder
    ld      bc, #(((MAZE_SIZE_X * MAZE_SIZE_Y) << 8) | 0x00)
22$:
    push    bc
    ld      a, (de)
    ld      c, #0x00
    srl     a
    rr      c
    srl     a
    rr      c
    srl     a
    rr      c
    ld      b, a
    ld      hl, #(_maze + MAZE_ORDER)
    add     hl, bc
    pop     bc
    ld      (hl), c
    inc     de
    inc     c
    djnz    22$
    
    ; 各エリアの設定
    ld      ix, #_maze
    ld      b, #(MAZE_SIZE_X * MAZE_SIZE_Y)
30$:
    call    _SystemGetRandom
    ld      MAZE_SEED(ix), a
    ld      e, MAZE_ORDER(ix)
    ld      d, #0x00
    ld      hl, #mazeFlag
    add     hl, de
    ld      a, (hl)
    ld      MAZE_FLAG(ix), a
    ld      hl, #mazeCrystal
    add     hl, de
    ld      a, (hl)
    ld      MAZE_CRYSTAL(ix), a
    ld      hl, #mazeTreasure
    add     hl, de
    ld      a, (hl)
    ld      MAZE_TREASURE(ix), a
    ld      hl, #mazeCurse
    add     hl, de
    ld      a, (hl)
    ld      MAZE_CURSE(ix), a
    ld      de, #MAZE_LENGTH
    add     ix, de
    djnz    30$

    ; レジスタの復帰
    
    ; 終了
    ret

; 迷路を更新する
;
_MazeUpdate::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; 迷路を描画する
;
_MazeRender::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 迷路を取得する
;
MazeGet::

    ; レジスタの保存
    push    de

    ; a  < エリア
    ; hl > 迷路

    ; 迷路の取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #_maze
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 順番を取得する
;
_MazeGetOrder::

    ; レジスタの保存
    push    hl
    push    de

    ; a < エリア
    ; a > 順番

    ; 順番の取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_ORDER)
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 乱数の種を取得する
;
_MazeGetSeed::

    ; レジスタの保存
    push    hl
    push    de

    ; a < エリア
    ; a > 乱数の種

    ; 乱数の種の取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_SEED)
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; フラグを取得する
;
_MazeGetFlag::

    ; レジスタの保存
    push    hl
    push    de

    ; a < エリア
    ; a > フラグ

    ; フラグの取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_FLAG)
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 壁を取得する
;
_MazeGetWalls::

    ; レジスタの保存
    push    de

    ; a  < エリア
    ; hl > 壁

    ; 壁の取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_WALL_0_0)
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; エネミーを取得する
;
_MazeGetEnemys::

    ; レジスタの保存
    push    de

    ; a  < エリア
    ; hl > エネミー

    ; エネミーの取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_ENEMY)
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; クリスタルを取得する
;
_MazeGetCrystals::

    ; レジスタの保存
    push    de

    ; a  < エリア
    ; hl > クリスタル

    ; クリスタルの取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_CRYSTAL)
    add     hl, de

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 宝を取得する
;
_MazeGetTreasure::

    ; レジスタの保存
    push    hl
    push    de

    ; a < エリア
    ; a > アイテム

    ; 宝の取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_TREASURE)
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 宝を拾う
;
_MazePickupTreasure::

    ; レジスタの保存
    push    hl
    push    de

    ; a < エリア
    ; a > アイテム

    ; 宝の取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_TREASURE)
    add     hl, de
    ld      a, (hl)
    ld      (hl), #ITEM_NULL

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 呪いを取得する
;
_MazeGetCurse::

    ; レジスタの保存
    push    hl
    push    de

    ; a < エリア
    ; a > 呪いの数

    ; 呪いの取得
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      hl, #(_maze + MAZE_CURSE)
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 開始のエリアを取得する
;
_MazeGetStartArea::

    ; レジスタの保存

    ; a > エリア

    ; エリアの取得
    ld      a, (mazeOrder + 0x0000)

    ; レジスタの復帰

    ; 終了
    ret

; 上のエリアを取得する
;
_MazeGetTopArea::

    ; レジスタの保存
    push    bc

    ; a < エリア
    ; a > エリア

    ; エリアの取得
    ld      c, a
    sub     #MAZE_SIZE_X
    and     #((MAZE_SIZE_Y - 0x01) * MAZE_SIZE_X)
    ld      b, a
    ld      a, c
    and     #(MAZE_SIZE_X - 0x01)
    or      b

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 下のエリアを取得する
;
_MazeGetBottomArea::

    ; レジスタの保存
    push    bc

    ; a < エリア
    ; a > エリア

    ; エリアの取得
    ld      c, a
    add     a, #MAZE_SIZE_X
    and     #((MAZE_SIZE_Y - 0x01) * MAZE_SIZE_X)
    ld      b, a
    ld      a, c
    and     #(MAZE_SIZE_X - 0x01)
    or      b

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 左のエリアを取得する
;
_MazeGetLeftArea::

    ; レジスタの保存
    push    bc

    ; a < エリア
    ; a > エリア

    ; エリアの取得
    ld      b, a
    dec     a
    and     #(MAZE_SIZE_X - 0x01)
    ld      c, a
    ld      a, b
    and     #((MAZE_SIZE_Y - 0x01) * MAZE_SIZE_X)
    or      c

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 右のエリアを取得する
;
_MazeGetRightArea::

    ; レジスタの保存
    push    bc

    ; a < エリア
    ; a > エリア

    ; エリアの取得
    ld      b, a
    inc     a
    and     #(MAZE_SIZE_X - 0x01)
    ld      c, a
    ld      a, b
    and     #((MAZE_SIZE_Y - 0x01) * MAZE_SIZE_X)
    or      c

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; 迷路の初期値
;
mazeDefault:

    .db     MAZE_AREA_NULL
    .db     MAZE_ORDER_NULL
    .db     MAZE_SEED_NULL
    .db     MAZE_FLAG_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111, 0b11111110 ; MAZE_WALL_NULL, MAZE_WALL_NULL
    .db     0b11111111 ; MAZE_ENEMY_NULL
    .db     MAZE_CRYSTAL_NULL
    .db     ITEM_NULL
    .db     MAZE_CURSE_NULL
    .db     0x00, 0x00, 0x00, 0x00

; フラグ
;
mazeFlag:

    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_EXIT
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL
    .db     MAZE_FLAG_NULL

; クリスタル
;
mazeCrystal:

    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b11111111
    .db     0b00000000
    .db     0b00000000
    .db     0b00000000
    .db     0b00000000

; 宝
;
mazeTreasure:

    .db     ITEM_COMPASS
    .db     ITEM_ARMOR
    .db     ITEM_BOOTS
    .db     ITEM_NECKLACE
    .db     ITEM_SHIELD
    .db     ITEM_CANDLE
    .db     ITEM_SWORD
    .db     ITEM_ROD
    .db     ITEM_HELMET
    .db     ITEM_RING
    .db     ITEM_SWORD
    .db     ITEM_NULL
    .db     ITEM_NULL
    .db     ITEM_NULL
    .db     ITEM_NULL
    .db     ITEM_NULL

; 呪い
;
mazeCurse:

    .db     0x04
    .db     0x04
    .db     0x04
    .db     0x04
    .db     0x06
    .db     0x06
    .db     0x06
    .db     0x06
    .db     0x08
    .db     0x08
    .db     0x08
    .db     0x08
    .db     0x0c
    .db     0x0c
    .db     0x0c
    .db     0x10


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 迷路
;
_maze::
    
    .ds     MAZE_SIZE_X * MAZE_SIZE_Y * MAZE_LENGTH

; 順番
;
mazeOrder:

    .ds     MAZE_SIZE_X * MAZE_SIZE_Y
