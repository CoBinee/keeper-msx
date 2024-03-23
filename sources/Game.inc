; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_PLAYER_ITEM         =   0x00
GAME_SPRITE_PLAYER_BODY         =   0x04
GAME_SPRITE_PLAYER_SWORD_0      =   0x08
GAME_SPRITE_PLAYER_SWORD_1      =   0x74
GAME_SPRITE_ENEMY               =   0x10
GAME_SPRITE_EXIT_0              =   0x78
GAME_SPRITE_EXIT_1              =   0x7c

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_FRAME                      =   0x02
GAME_REQUEST                    =   0x03
GAME_AREA                       =   0x04
GAME_LENGTH                     =   0x05

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_ENTER                =   0x20
GAME_STATE_PLAY                 =   0x30
GAME_STATE_EXIT                 =   0x40
GAME_STATE_OVER                 =   0x50
GAME_STATE_CLEAR                =   0x60

; フラグ
GAME_FLAG_NULL                  =   0x00

; フレーム
GAME_FRAME_NULL                 =   0x00

; リクエスト
GAME_REQUEST_NULL               =   0x00
GAME_REQUEST_AREA               =   0x0f
GAME_REQUEST_AREA_TOP_BIT       =   0x03
GAME_REQUEST_AREA_TOP           =   (1 << GAME_REQUEST_AREA_TOP_BIT)
GAME_REQUEST_AREA_BOTTOM_BIT    =   0x02
GAME_REQUEST_AREA_BOTTOM        =   (1 << GAME_REQUEST_AREA_BOTTOM_BIT)
GAME_REQUEST_AREA_LEFT_BIT      =   0x01
GAME_REQUEST_AREA_LEFT          =   (1 << GAME_REQUEST_AREA_LEFT_BIT)
GAME_REQUEST_AREA_RIGHT_BIT     =   0x00
GAME_REQUEST_AREA_RIGHT         =   (1 << GAME_REQUEST_AREA_RIGHT_BIT)

; エリア
GAME_AREA_NULL                  =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _game
