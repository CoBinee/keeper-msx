; Maze.inc : 迷路
;


; マクロの定義
;

; 迷路
MAZE_AREA                       =   0x00
MAZE_ORDER                      =   0x01
MAZE_SEED                       =   0x03
MAZE_FLAG                       =   0x02
MAZE_WALL_0_0                   =   0x04
MAZE_WALL_0_1                   =   0x05
MAZE_WALL_1_0                   =   0x06
MAZE_WALL_1_1                   =   0x07
MAZE_WALL_2_0                   =   0x08
MAZE_WALL_2_1                   =   0x09
MAZE_WALL_3_0                   =   0x0a
MAZE_WALL_3_1                   =   0x0b
MAZE_WALL_4_0                   =   0x0c
MAZE_WALL_4_1                   =   0x0d
MAZE_WALL_5_0                   =   0x0e
MAZE_WALL_5_1                   =   0x0f
MAZE_WALL_6_0                   =   0x10
MAZE_WALL_6_1                   =   0x11
MAZE_WALL_7_0                   =   0x12
MAZE_WALL_7_1                   =   0x13
MAZE_WALL_8_0                   =   0x14
MAZE_WALL_8_1                   =   0x15
MAZE_WALL_9_0                   =   0x16
MAZE_WALL_9_1                   =   0x17
MAZE_ENEMY                      =   0x18
MAZE_CRYSTAL                    =   0x19
MAZE_TREASURE                   =   0x1a
MAZE_CURSE                      =   0x1b
MAZE_LENGTH                     =   0x20

; 大きさ
MAZE_SIZE_X                     =   0x04
MAZE_SIZE_Y                     =   0x04

; エリア
MAZE_AREA_NULL                  =   0x00

; 順番
MAZE_ORDER_NULL                 =   0x00

; 乱数の種
MAZE_SEED_NULL                  =   0x00

; フラグ
MAZE_FLAG_NULL                  =   0x00
MAZE_FLAG_EXIT_BIT              =   0x07
MAZE_FLAG_EXIT                  =   (1 << MAZE_FLAG_EXIT_BIT)

; 壁
MAZE_WALL_NULL                  =   0x00
MAZE_WALL_SIZE_X                =   0x0f
MAZE_WALL_BYTE_X                =   0x02
MAZE_WALL_SIZE_Y                =   0x0a

; エネミー
MAZE_ENEMY_NULL                 =   0x00

; クリスタル
MAZE_CRYSTAL_NULL               =   0x00

; 宝

; 呪い
MAZE_CURSE_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _MazeInitialize
    .globl  _MazeUpdate
    .globl  _MazeRender
    .globl  _MazeGetOrder
    .globl  _MazeGetSeed
    .globl  _MazeGetFlag
    .globl  _MazeGetWalls
    .globl  _MazeGetEnemys
    .globl  _MazeGetCrystals
    .globl  _MazeGetTreasure
    .globl  _MazePickupTreasure
    .globl  _MazeGetCurse
    .globl  _MazeGetStartArea
    .globl  _MazeGetTopArea
    .globl  _MazeGetBottomArea
    .globl  _MazeGetLeftArea
    .globl  _MazeGetRightArea

; 外部変数宣言
;

    .globl  _maze
