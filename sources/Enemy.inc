; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_ATTRIBUTE                 =   0x03
ENEMY_GROUP                     =   0x04
ENEMY_POSITION_X                =   0x05
ENEMY_POSITION_Y                =   0x06
ENEMY_DIRECTION                 =   0x07
ENEMY_SPEED                     =   0x08
ENEMY_POWER_L                   =   0x09
ENEMY_POWER_H                   =   0x0a
ENEMY_ITEM                      =   0x0b
ENEMY_DIVE                      =   0x0c
ENEMY_ATTACK_POINT              =   0x0d
ENEMY_ATTACK_RECT_LEFT          =   0x0e
ENEMY_ATTACK_RECT_TOP           =   0x0f
ENEMY_ATTACK_RECT_RIGHT         =   0x10
ENEMY_ATTACK_RECT_BOTTOM        =   0x11
ENEMY_ATTACK_RECT_R             =   0x12
ENEMY_DAMAGE_RECT_LEFT          =   0x13
ENEMY_DAMAGE_RECT_TOP           =   0x14
ENEMY_DAMAGE_RECT_RIGHT         =   0x15
ENEMY_DAMAGE_RECT_BOTTOM        =   0x16
ENEMY_DAMAGE_RECT_R             =   0x17
ENEMY_PARAM_0                   =   0x18
ENEMY_PARAM_1                   =   0x19
ENEMY_PARAM_2                   =   0x1a
ENEMY_PARAM_3                   =   0x1b
ENEMY_ANIMATION                 =   0x1c
ENEMY_BLINK                     =   0x1d
ENEMY_SPRITE_L                  =   0x1e
ENEMY_SPRITE_H                  =   0x1f
ENEMY_LENGTH                    =   0x20
ENEMY_ENTRY                     =   0x10

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_GHOUL                =   0x01
ENEMY_TYPE_GOBLIN               =   0x02
ENEMY_TYPE_BAT                  =   0x03
ENEMY_TYPE_SPIDER               =   0x04
ENEMY_TYPE_GHOST                =   0x05
ENEMY_TYPE_MAGE                 =   0x06
ENEMY_TYPE_REAPER               =   0x07
ENEMY_TYPE_GOLEM                =   0x08
ENEMY_TYPE_DRAGON_GREEN         =   0x09
ENEMY_TYPE_DRAGON_BLUE          =   0x0a
ENEMY_TYPE_DRAGON_RED           =   0x0b
ENEMY_TYPE_SHADOW               =   0x0c
ENEMY_TYPE_BOLT                 =   0x0d
ENEMY_TYPE_BALL                 =   0x0e
ENEMY_TYPE_FIRE                 =   0x0f

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_DAMAGE_BIT           =   0x02
ENEMY_FLAG_DAMAGE               =   (1 << ENEMY_FLAG_DAMAGE_BIT)
ENEMY_FLAG_INVINCIBLE_BIT       =   0x03
ENEMY_FLAG_INVINCIBLE           =   (1 << ENEMY_FLAG_INVINCIBLE_BIT)
ENEMY_FLAG_DIVE_BIT             =   0x04
ENEMY_FLAG_DIVE                 =   (1 << ENEMY_FLAG_DIVE_BIT)
ENEMY_FLAG_SPELL_BIT            =   0x05
ENEMY_FLAG_SPELL                =   (1 << ENEMY_FLAG_SPELL_BIT)
ENEMY_FLAG_BOSS_BIT             =   0x06
ENEMY_FLAG_BOSS                 =   (1 << ENEMY_FLAG_BOSS_BIT)
ENEMY_FLAG_2x2_BIT              =   0x07
ENEMY_FLAG_2x2                  =   (1 << ENEMY_FLAG_2x2_BIT)

; 属性
ENEMY_ATTRIBUTE_NULL            =   0x00
ENEMY_ATTRIBUTE_GHOUL           =   0x01
ENEMY_ATTRIBUTE_GOBLIN          =   0x02
ENEMY_ATTRIBUTE_BAT             =   0x04
ENEMY_ATTRIBUTE_SPIDER          =   0x08
ENEMY_ATTRIBUTE_GHOST           =   0x10
ENEMY_ATTRIBUTE_MAGE            =   0x20
ENEMY_ATTRIBUTE_REAPER          =   0x40
ENEMY_ATTRIBUTE_GOLEM           =   0x80

; グループ
ENEMY_GROUP_NULL                =   0x00

; 位置
ENEMY_POSITION_NULL             =   0x00

; 向き
ENEMY_DIRECTION_UP              =   0x00
ENEMY_DIRECTION_DOWN            =   0x01
ENEMY_DIRECTION_LEFT            =   0x02
ENEMY_DIRECTION_RIGHT           =   0x03

; 速度
ENEMY_SPEED_NULL                =   0x00

; パワー
ENEMY_POWER_NULL                =   0x00
ENEMY_POWER_NORMAL              =   0x0e
ENEMY_POWER_HIGH                =   0x12

; アイテム
ENEMY_ITEM_NULL                 =   0x00

; 潜行
ENEMY_DIVE_NULL                 =   0x00
ENEMY_DIVE_SPEED                =   0x02
ENEMY_DIVE_ATTACK_RECT_R        =   0x07
ENEMY_DIVE_DAMAGE_RECT_R        =   0x08

; 攻撃
ENEMY_ATTACK_POINT_NULL         =   0x00
ENEMY_ATTACK_RECT_NULL          =   0x00
ENEMY_ATTACK_RECT_R_1x1         =   0x07
ENEMY_ATTACK_RECT_R_2x2         =   0x0e

; ダメージ
ENEMY_DAMAGE_RECT_NULL          =   0x00
ENEMY_DAMAGE_RECT_R_1x1         =   0x08
ENEMY_DAMAGE_RECT_R_2x2         =   0x10

; パラメータ
ENEMY_PARAM_NULL                =   0x00

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00
ENEMY_ANIMATION_CYCLE           =   0x08

; 点滅
ENEMY_BLINK_NULL                =   0x00
ENEMY_BLINK_DEAD                =   0x18

; スプライト
ENEMY_SPRITE_NULL               =   0x00
ENEMY_SPRITE_LENGTH             =   (ENEMY_ENTRY * 0x04)

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyEnter
    .globl  _EnemyExit
    .globl  _EnemyEntry
    .globl  _EnemyGetAttribute
    .globl  _EnemyGetExist
    .globl  _EnemyMove
    .globl  _EnemyStep
    .globl  _EnemyStepToEnd
    .globl  _EnemyStepToCorner
    .globl  _EnemyIsStep
    .globl  _EnemyIsPath
    .globl  _EnemyIsWayPoint
    .globl  _EnemySetDirectionForPlayer
    .globl  _EnemySetStepDirectionForPlayer
    .globl  _EnemySetDiveDirectionForPlayer
    .globl  _EnemySetRandomDirection
    .globl  _EnemySetAttackRect
    .globl  _EnemySetDamageRect
    .globl  _EnemyAnimateSprite

; 外部変数宣言
;

    .globl  _enemy

