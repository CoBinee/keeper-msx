; Wall.inc : 壁
;


; マクロの定義
;

; 壁
WALL_NULL                       =   0x00
WALL_TYPE_MASK                  =   0x70
WALL_TYPE_WALL_BIT              =   0x06
WALL_TYPE_WALL                  =   (1 << WALL_TYPE_WALL_BIT)
WALL_TYPE_PATH                  =   0x00
WALL_TYPE_CRYSTAL               =   0x10
WALL_TYPE_TREASURE              =   0x20
WALL_TYPE_CURSE                 =   0x30
WALL_PATTERN_MASK               =   0x0f
WALL_PATTERN_TOP_BIT            =   0x00
WALL_PATTERN_TOP                =   (1 << WALL_PATTERN_TOP_BIT)
WALL_PATTERN_BOTTOM_BIT         =   0x01
WALL_PATTERN_BOTTOM             =   (1 << WALL_PATTERN_BOTTOM_BIT)
WALL_PATTERN_LEFT_BIT           =   0x02
WALL_PATTERN_LEFT               =   (1 << WALL_PATTERN_LEFT_BIT)
WALL_PATTERN_RIGHT_BIT          =   0x03
WALL_PATTERN_RIGHT              =   (1 << WALL_PATTERN_RIGHT_BIT)

; 大きさ
WALL_SIZE_X                     =   0x12
WALL_SIZE_Y                     =   0x0d
WALL_SIZE_PIXEL                 =   0x10

; 表示領域
WALL_VIEW_LEFT                  =   0x01
WALL_VIEW_RIGHT                 =   0x10
WALL_VIEW_TOP                   =   0x01
WALL_VIEW_BOTTOM                =   0x0b
WALL_VIEW_SIZE_X                =   0x10
WALL_VIEW_SIZE_Y                =   0x0b

; 配置
WALL_LOCATE_ENEMY               =   0x00
WALL_LOCATE_ENEMY_LENGTH        =   0x08
WALL_LOCATE_CRYSTAL             =   (WALL_LOCATE_ENEMY + WALL_LOCATE_ENEMY_LENGTH)
WALL_LOCATE_CRYSTAL_LENGTH      =   0x08
WALL_LOCATE_TREASURE            =   (WALL_LOCATE_CRYSTAL + WALL_LOCATE_CRYSTAL_LENGTH)
WALL_LOCATE_TREASURE_LENGTH     =   0x01
WALL_LOCATE_CURSE               =   (WALL_LOCATE_TREASURE + WALL_LOCATE_TREASURE_LENGTH)
WALL_LOCATE_CURSE_LENGTH        =   0x10
WALL_LOCATE_RANDOM              =   (WALL_LOCATE_CURSE + WALL_LOCATE_CURSE_LENGTH)
WALL_LOCATE_RANDOM_LENGTH       =   0x40
WALL_LOCATE_LENGTH              =   (0x0e * 0x09 - 0x04 * 0x03 - 0x04)

; 出口
WALL_EXIT_STATE                 =   0x00
WALL_EXIT_WALL_L                =   0x01
WALL_EXIT_WALL_H                =   0x02
WALL_EXIT_POSITION_X            =   0x03
WALL_EXIT_POSITION_Y            =   0x04
WALL_EXIT_ANIMATION             =   0x05
WALL_EXIT_SPRITE_L              =   0x06
WALL_EXIT_SPRITE_H              =   0x07
WALL_EXIT_LENGTH                =   0x08
WALL_EXIT_STATE_NULL            =   0x00
WALL_EXIT_STATE_DIG             =   0x01
WALL_EXIT_STATE_OPEN            =   0x02
WALL_EXIT_R                     =   0x08

; 外部関数宣言
;

    .globl  _WallInitialize
    .globl  _WallUpdate
    .globl  _WallRender
    .globl  _WallEnter
    .globl  _WallExit
    .globl  _WallDig
    .globl  _WallDigTreasure
    .globl  _WallIsPath
    .globl  _WallIsExit
    .globl  _WallPickupTreasure
    .globl  _WallGetPattern
    .globl  _WallGetEnemyLocation
    .globl  _WallGetTreasureLocation
    .globl  _WallGetRandomLocation

; 外部変数宣言
;

    .globl  _wall
