; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_X               =   0x02
PLAYER_POSITION_Y               =   0x03
PLAYER_DIRECTION                =   0x04
PLAYER_SPEED                    =   0x05
PLAYER_BOOTS                    =   0x06
PLAYER_POWER_L                  =   0x07
PLAYER_POWER_H                  =   0x08
PLAYER_CRYSTAL                  =   0x09
PLAYER_CURSE                    =   0x0a
PLAYER_SWORD                    =   0x0b
PLAYER_SWING                    =   0x0c
PLAYER_HELMET                   =   0x0d
PLAYER_ARMOR                    =   0x0e
PLAYER_SHIELD                   =   0x0f
PLAYER_COMPASS                  =   0x10
PLAYER_CANDLE                   =   0x11
PLAYER_RING                     =   0x12
PLAYER_NECKLACE                 =   0x13
PLAYER_ROD                      =   0x14
PLAYER_ATTACK_POINT             =   0x15
PLAYER_ATTACK_RECT_LEFT         =   0x16
PLAYER_ATTACK_RECT_TOP          =   0x17
PLAYER_ATTACK_RECT_RIGHT        =   0x18
PLAYER_ATTACK_RECT_BOTTOM       =   0x19
PLAYER_DAMAGE_POINT             =   0x1a
PLAYER_DAMAGE_RECT_LEFT         =   0x1b
PLAYER_DAMAGE_RECT_TOP          =   0x1c
PLAYER_DAMAGE_RECT_RIGHT        =   0x1d
PLAYER_DAMAGE_RECT_BOTTOM       =   0x1e
PLAYER_FRAME                    =   0x1f
PLAYER_ANIMATION                =   0x20
PLAYER_BLINK                    =   0x21
PLAYER_COLOR                    =   0x22
PLAYER_SPRITE_BODY_L            =   0x23
PLAYER_SPRITE_BODY_H            =   0x24
PLAYER_SPRITE_SWORD_L           =   0x25
PLAYER_SPRITE_SWORD_H           =   0x26
PLAYER_LENGTH                   =   0x27

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_PLAY               =   0x10
PLAYER_STATE_DEAD               =   0x20
PLAYER_STATE_RETURN             =   0x30

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_EXIT                =   0x0f
PLAYER_FLAG_EXIT_TOP_BIT        =   0x03
PLAYER_FLAG_EXIT_TOP            =   (1 << PLAYER_FLAG_EXIT_TOP_BIT)
PLAYER_FLAG_EXIT_BOTTOM_BIT     =   0x02
PLAYER_FLAG_EXIT_BOTTOM         =   (1 << PLAYER_FLAG_EXIT_BOTTOM_BIT)
PLAYER_FLAG_EXIT_LEFT_BIT       =   0x01
PLAYER_FLAG_EXIT_LEFT           =   (1 << PLAYER_FLAG_EXIT_LEFT_BIT)
PLAYER_FLAG_EXIT_RIGHT_BIT      =   0x00
PLAYER_FLAG_EXIT_RIGHT          =   (1 << PLAYER_FLAG_EXIT_RIGHT_BIT)
PLAYER_FLAG_ATTACK_BIT          =   0x04
PLAYER_FLAG_ATTACK              =   (1 << PLAYER_FLAG_ATTACK_BIT)
PLAYER_FLAG_DAMAGE_BIT          =   0x05
PLAYER_FLAG_DAMAGE              =   (1 << PLAYER_FLAG_DAMAGE_BIT)
PLAYER_FLAG_MOVE_BIT            =   0x06
PLAYER_FLAG_MOVE                =   (1 << PLAYER_FLAG_MOVE_BIT)
PLAYER_FLAG_RETURN_BIT          =   0x07
PLAYER_FLAG_RETURN              =   (1 << PLAYER_FLAG_RETURN_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 向き
PLAYER_DIRECTION_UP             =   0x00
PLAYER_DIRECTION_DOWN           =   0x01
PLAYER_DIRECTION_LEFT           =   0x02
PLAYER_DIRECTION_RIGHT          =   0x03

; 速度　
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_NORMAL             =   0x01
PLAYER_SPEED_HIGH               =   0x02
PLAYER_SPEED_CURSE              =   0x01

; ブーツ
PLAYER_BOOTS_NULL               =   0x00

; パワー
PLAYER_POWER_NULL               =   0x00
PLAYER_POWER_MAXIMUM            =   1000
PLAYER_POWER_DIG                =   1
PLAYER_POWER_CRYSTAL            =   10

; クリスタル
PLAYER_CRYSTAL_NULL             =   0x00
PLAYER_CRYSTAL_MAXIMUM          =   100

; 呪い
PLAYER_CURSE_NULL               =   0x00

; ソード
PLAYER_SWORD_SHORT              =   0x00
PLAYER_SWORD_MIDDLE             =   0x01
PLAYER_SWORD_LONG               =   0x02

; 振る
PLAYER_SWING_NULL               =   0x00
PLAYER_SWING_DIG                =   0x00
PLAYER_SWING_ATTACK             =   0x08

; ヘルメット
PLAYER_HELMET_NULL              =   0x00

; アーマー
PLAYER_ARMOR_NULL               =   0x00

; シールド
PLAYER_SHIELD_NULL              =   0x00

; コンパス
PLAYER_COMPASS_NULL             =   0x00

; キャンドル
PLAYER_CANDLE_NULL              =   0x00

; リング
PLAYER_RING_NULL                =   0x00

; ネックレス
PLAYER_NECKLACE_NULL            =   0x00

; ロッド
PLAYER_ROD_NULL                 =   0x00

; 攻撃
PLAYER_ATTACK_POINT_NULL        =   0x00
PLAYER_ATTACK_RECT_NULL         =   0x00
PLAYER_ATTACK_RECT_R            =   0x08

; ダメージ
PLAYER_DAMAGE_POINT_NULL        =   0x00
PLAYER_DAMAGE_RECT_NULL         =   0x00
PLAYER_DAMAGE_RECT_R            =   0x08

; フレーム
PLAYER_FRAME_NULL               =   0x00

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00

; 点滅
PLAYER_BLINK_NULL               =   0x00
PLAYER_BLINK_DEAD               =   0x48
PLAYER_BLINK_RETURN             =   0x48

; 色
PLAYER_COLOR_NULL               =   0x00

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; 大きさ
PLAYER_SIZE_R                   =   0x08

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerEnter
    .globl  _PlayerExit
    .globl  _PlayerAddPower
    .globl  _PlayerSubPower
    .globl  _PlayerAddDamage
    .globl  _PlayerIsDead
    .globl  _PlayerIsReturn
    .globl  _PlayerAddItem
    .globl  _PlayerIsItem
    .globl  _PlayerGetShieldDirection

; 外部変数宣言
;

    .globl  _player
