; EnemyOne.inc : 種類別のエネミー
;


; マクロの定義
;

; なし

; グール

; ゴブリン

; バット

; スパイダー

; ゴースト
ENEMY_GHOST_BLINK_FADE          =   0x0b

; メイジ
ENEMY_MAGE_BLINK_FADE           =   0x17
ENEMY_MAGE_INTERVAL_CAST        =   0x30
ENEMY_MAGE_INTERVAL_LOCK        =   0x30

; リーパー

; ゴーレム

; ドラゴン
ENEMY_DRAGON_POSITION_X         =   0x80
ENEMY_DRAGON_POSITION_Y         =   0x50
ENEMY_DRAGON_FIRE_RANGE         =   0x48
ENEMY_DRAGON_FIRE_OFFSET        =   0x20
ENEMY_DRAGON_FIRE_DISTANCE      =   0x30
ENEMY_DRAGON_INTERVAL_CAST      =   0x30

; シャドウ
ENEMY_SHADOW_POSITION_X         =   0x80
ENEMY_SHADOW_POSITION_Y         =   0x50

; ボルト

; ボール

; ファイア

; 外部関数宣言
;

    .globl  _EnemyNull
    .globl  _EnemyGhoul
    .globl  _EnemyGoblin
    .globl  _EnemyBat
    .globl  _EnemySpider
    .globl  _EnemyGhost
    .globl  _EnemyMage
    .globl  _EnemyReaper
    .globl  _EnemyGolem
    .globl  _EnemyDragonGreen
    .globl  _EnemyDragonBlue
    .globl  _EnemyDragonRed
    .globl  _EnemyShadow
    .globl  _EnemyBolt
    .globl  _EnemyBall
    .globl  _EnemyFire

; 外部変数宣言
;

    .globl  _enemyNullDefault
    .globl  _enemyGhoulDefault
    .globl  _enemyGoblinDefault
    .globl  _enemyBatDefault
    .globl  _enemySpiderDefault
    .globl  _enemyGhostDefault
    .globl  _enemyMageDefault
    .globl  _enemyReaperDefault
    .globl  _enemyGolemDefault
    .globl  _enemyDragonGreenDefault
    .globl  _enemyDragonBlueDefault
    .globl  _enemyDragonRedDefault
    .globl  _enemyShadowDefault
    .globl  _enemyBoltDefault
    .globl  _enemyBallDefault
    .globl  _enemyFireDefault
