; EnemyOne.s : 種類別のエネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Wall.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "EnemyOne.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 何もしない
;
_EnemyNull::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; グール
;
_EnemyGhoul::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
;   ld      b, ENEMY_SPEED(ix)
;10$:
    call    _EnemyStepToEnd
    jr      nc, 18$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    call    _EnemySetDiveDirectionForPlayer
    bit     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
18$:
;   djnz    10$
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyGhoulSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; ゴブリン
;
_EnemyGoblin::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
;   ld      b, ENEMY_SPEED(ix)
;10$:
    call    _EnemyStepToCorner
    jr      nc, 18$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    call    _EnemySetDiveDirectionForPlayer
    bit     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
18$:
;   djnz    10$
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyGoblinSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; バット
;
_EnemyBat::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_PARAM_0 : 移動の繰り返し回数
    call    _SystemGetRandom
    rlca
    and     #0x07
    add     a, #0x07
    ld      ENEMY_PARAM_0(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
;   ld      b, ENEMY_SPEED(ix)
;10$:
    call    _EnemyStepToCorner
    jr      nc, 18$
    dec     ENEMY_PARAM_0(ix)
    jr      z, 11$
    call    _EnemySetRandomDirection
    jr      18$
11$:
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    call    _EnemySetDiveDirectionForPlayer
    bit     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
18$:
;   djnz    10$
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyBatSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; スパイダー
;
_EnemySpider::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_PARAM_0 : 待機時間
    call    _SystemGetRandom
    rlca
    and     #0x3f
    add     a, #0x30
    ld      ENEMY_PARAM_0(ix), a

    ; ENEMY_PARAM_1 : 移動の繰り返し回数
    call    _SystemGetRandom
    rlca
    and     #0x03
    add     a, #0x04
    ld      ENEMY_PARAM_1(ix), a

    ; ENEMY_PARAM_2 : 攻撃力の保存
    ld      a, ENEMY_ATTACK_POINT(ix)
    ld      ENEMY_PARAM_2(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 待機
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jr      z, 19$
    dec     ENEMY_PARAM_0(ix)
    jr      30$
19$:

    ; 移動
    ld      b, ENEMY_SPEED(ix)
20$:
    call    _EnemyStepToCorner
    jr      nc, 28$
    ld      d, ENEMY_DIRECTION(ix)
    dec     ENEMY_PARAM_1(ix)
    jr      z, 21$
    call    _EnemySetRandomDirection
    jr      22$
21$:
    call    _EnemySetStepDirectionForPlayer
22$:
    ld      a, ENEMY_DIRECTION(ix)
    cp      d
    jr      z, 28$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    jr      29$
28$:
    djnz    20$
29$:

    ; 行動の完了
30$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemySpiderSprite
    call    _EnemyAnimateSprite

    ; 移動中の設定
    ld      a, ENEMY_PARAM_0(ix)
    or      a
    jr      nz, 40$
    ld      a, ENEMY_PARAM_2(ix)
    ld      ENEMY_ATTACK_POINT(ix), a
    ld      a, ENEMY_ANIMATION(ix)
    add     a, #0x04
    ld      ENEMY_ANIMATION(ix), a
    jr      49$
40$:
    ld      ENEMY_ATTACK_POINT(ix), #0x00
;   jr      49$
49$:

    ; レジスタの復帰

    ; 終了
    ret

; ゴースト
;
_EnemyGhost::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 移動距離の取得
    ld      a, (_player + PLAYER_POSITION_X)
    and     #~(WALL_SIZE_PIXEL - 0x01)
    add     a, #(WALL_SIZE_PIXEL / 2)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 00$
    neg
00$:
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    and     #~(WALL_SIZE_PIXEL - 0x01)
    add     a, #(WALL_SIZE_PIXEL / 2)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 01$
    neg
01$:
    ld      d, a

    ; ENEMY_PARAM_0 : 移動量
    or      e
    jr      z, 03$
    call    _EnemySetDirectionForPlayer
    bit     #0x01, ENEMY_DIRECTION(ix)
    jr      nz, 02$
    ld      ENEMY_PARAM_0(ix), d
    jr      08$
02$:
    ld      ENEMY_PARAM_0(ix), e
    jr      08$
03$:
    ld      e, #0x40
    ld      a, ENEMY_POSITION_X(ix)
    add     a, e
    ld      d, #ENEMY_DIRECTION_RIGHT
    jr      nc, 04$
    ld      d, #ENEMY_DIRECTION_LEFT
04$:
    ld      ENEMY_DIRECTION(ix), d
    ld      ENEMY_PARAM_0(ix), e
08$:

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
;   ld      b, ENEMY_SPEED(ix)
;10$:
    call    _EnemyMove
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 18$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    jr      nz, 19$
18$:
;   djnz    10$
19$:

    ; 点滅
    ld      a, #ITEM_CANDLE
    call    _PlayerIsItem
    jr      nc, 20$
    ld      ENEMY_BLINK(ix), #0x00
    jr      29$
20$:
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallIsPath
    jr      nc, 21$
    ld      a, ENEMY_BLINK(ix)
    or      a
    jr      z, 29$
    dec     ENEMY_BLINK(ix)
    jr      29$
21$:
    ld      a, ENEMY_BLINK(ix)
    cp      #ENEMY_GHOST_BLINK_FADE
    jr      nc, 29$
    inc     ENEMY_BLINK(ix)
;   jr      29$
29$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyGhostSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; メイジ
;
_EnemyMage::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_PARAM_0 : インターバル
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x30
    ld      ENEMY_PARAM_0(ix), a

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #0x00

    ; 点滅の設定
    ld      ENEMY_BLINK(ix), #ENEMY_MAGE_BLINK_FADE

    ; フラグの設定
    set     #ENEMY_FLAG_INVINCIBLE_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 0x01 : 待機
100$:
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      nz, 110$
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 109$
    call    _WallGetRandomLocation
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d
    res     #ENEMY_FLAG_INVINCIBLE_BIT, ENEMY_FLAG(ix)
    ld      ENEMY_STATE(ix), #0x02
;   jr      109$
109$:
    jr      190$

    ; 0x02 : 出現
110$:
    dec     a
    jr      nz, 120$
    dec     ENEMY_BLINK(ix)
    jr      nz, 119$
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallIsPath
    jr      c, 111$
    ld      ENEMY_STATE(ix), #0x05
    jr      119$
111$:
    ld      ENEMY_PARAM_0(ix), #ENEMY_MAGE_INTERVAL_CAST
    ld      ENEMY_STATE(ix), #0x03
;   jr      119$
119$:
    jr      190$

    ; 0x03 : 詠唱
120$:
    dec     a
    jr      nz, 130$
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 129$
    call    _EnemySetDirectionForPlayer
    ld      a, #ENEMY_TYPE_BOLT
    call    EnemyCastSpell
    ld      ENEMY_ANIMATION(ix), #ENEMY_ANIMATION_CYCLE
    ld      ENEMY_PARAM_0(ix), #ENEMY_MAGE_INTERVAL_LOCK
    ld      ENEMY_STATE(ix), #0x04
;   jr      129$
129$:
    jr      190$

    ; 0x04 : 硬直
130$:
    dec     a
    jr      nz, 140$
    dec     ENEMY_PARAM_0(ix)
    jr      nz, 139$
    ld      ENEMY_STATE(ix), #0x05
;   jr      139$
139$:
    jr      190$

    ; 0x05 : 退場
140$:
    inc     ENEMY_BLINK(ix)
    ld      a, ENEMY_BLINK(ix)
    cp      #ENEMY_MAGE_BLINK_FADE
    jr      c, 149$
    ld      ENEMY_STATE(ix), #0x00
;   jr      149$
149$:
;   jr      190$

    ; 行動の完了
190$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyMageSprite
    call    _EnemyAnimateSprite

    ; レジスタの復帰

    ; 終了
    ret

; リーパー
;
_EnemyReaper::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    bit     #0x00, ENEMY_ANIMATION(ix)
    jr      nz, 19$
    call    _EnemyStepToEnd
    jr      nc, 19$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    call    _EnemySetDiveDirectionForPlayer
    bit     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyReaperSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; ゴーレム
;
_EnemyGolem::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
;   ld      b, ENEMY_SPEED(ix)
;10$:
    call    _EnemyStepToCorner
    jr      nc, 18$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    call    _EnemySetDiveDirectionForPlayer
    bit     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
    jr      nz, 19$
18$:
;   djnz    10$
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyGolemSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; グリーンドラゴン
;
_EnemyDragonGreen::

; ブルードラゴン
;
_EnemyDragonBlue::

; レッドドラゴン
;
_EnemyDragonRed::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #ENEMY_DRAGON_POSITION_X
    ld      ENEMY_POSITION_Y(ix), #ENEMY_DRAGON_POSITION_Y

    ; ENEMY_PARAM_0 : 封印アイテム

    ; ENEMY_PARAM_1 : 移動量

    ; ENEMY_PARAM_2 : インターバル

    ; ENEMY_PARAM_3 : 攻撃力の保存
    ld      a, ENEMY_ATTACK_POINT(ix)
    ld      ENEMY_PARAM_3(ix), a

    ; 封印の解除
    ld      a, ENEMY_PARAM_0(ix)
    call    _PlayerIsItem
    jr      nc, 00$

    ; フラグの設定
    res     #ENEMY_FLAG_INVINCIBLE_BIT, ENEMY_FLAG(ix)

    ; BGM の再生
    ld      a, #SOUND_BGM_DRAGON
    call    _SoundPlayBgm

    ; 状態の更新
    ld      ENEMY_STATE(ix), #0x02
    jr      09$

    ; 封印されている
00$:

    ; 状態の更新
    ld      ENEMY_STATE(ix), #0x01
;   jr      09$

    ; 初期化の完了
09$:

    ; 0x01 : 封印
10$:
    ld      a, ENEMY_STATE(ix)
    cp      #0x01
    jr      nz, 20$
    ld      hl, #enemyDragonSealedSprite
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    jp      90$

    ; 0x02 : 移動の開始
20$:
    ld      a, ENEMY_STATE(ix)
    cp      #0x02
    jr      nz, 30$
    ld      c, #0b00000011
    ld      a, (_player + PLAYER_POSITION_X)
    and     #~(WALL_SIZE_PIXEL - 0x01)
    add     a, #WALL_SIZE_PIXEL
    jr      nc, 21$
    ld      a, #((WALL_VIEW_SIZE_X - 0x01) * WALL_SIZE_PIXEL)
21$:
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 22$
    neg
    res     #0x00, c
22$:
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    and     #~(WALL_SIZE_PIXEL - 0x01)
    add     a, #WALL_SIZE_PIXEL
    cp      #((WALL_VIEW_SIZE_Y - 0x01) * WALL_SIZE_PIXEL)
    jr      c, 23$
    ld      a, #((WALL_VIEW_SIZE_Y - 0x01) * WALL_SIZE_PIXEL)
23$:
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 24$
    neg
    res     #0x01, c
24$:
    ld      d, a
    or      e
    jr      nz, 25$
    ld      e, #0x40
    ld      a, ENEMY_POSITION_X(ix)
    cp      #0x80
    jr      c, 26$
    res     #0x00, c
    jr      26$
25$:
    ld      a, e
    cp      d
    jr      nc, 26$
    ld      a, c
    rrca
    and     #0x01
    ld      ENEMY_DIRECTION(ix), a
    ld      ENEMY_PARAM_1(ix), d
    jr      29$
26$:
    ld      a, c
    and     #0x01
    or      #0x02
    ld      ENEMY_DIRECTION(ix), a
    ld      ENEMY_PARAM_1(ix), e
;   jr      29$
29$:
    ld      ENEMY_STATE(ix), #0x03

    ; 0x03 : 移動
30$:
    ld      a, ENEMY_STATE(ix)
    cp      #0x03
    jr      nz, 40$
;   ld      b, #ENEMY_SPEED(ix)
;31$:
    call    _EnemyMove
    dec     ENEMY_PARAM_1(ix)
    jr      z, 32$
;   djnz    31$
    jp      80$
32$:
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 33$
    neg
33$:
    cp      #ENEMY_DRAGON_FIRE_RANGE
    jr      nc, 38$
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 34$
    neg
34$:
    cp      #ENEMY_DRAGON_FIRE_RANGE
    jr      nc, 38$
    ld      ENEMY_STATE(ix), #0x04
    jr      39$
38$:
    ld      ENEMY_STATE(ix), #0x02
    jp      80$
39$:

    ; 0x04 : 詠唱の開始
40$:
    ld      a, ENEMY_STATE(ix)
    cp      #0x04
    jr      nz, 50$
    ld      ENEMY_PARAM_2(ix), #ENEMY_DRAGON_INTERVAL_CAST
    ld      ENEMY_STATE(ix), #0x05
;   jr      49$
49$:

    ; 0x05 : 詠唱中
50$:
    ld      a, ENEMY_STATE(ix)
    cp      #0x05
    jr      nz, 60$
    dec     ENEMY_PARAM_2(ix)
    jr      nz, 80$
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _EnemySetDirectionForPlayer
    ld      a, ENEMY_DIRECTION(ix)
    dec     a
    jr      z, 51$
    dec     a
    jr      z, 52$
    dec     a
    jr      z, 53$
    ld      a, d
    cp      #ENEMY_DRAGON_FIRE_DISTANCE
    jr      c, 58$
    sub     #ENEMY_DRAGON_FIRE_OFFSET
    ld      d, a
    jr      57$
51$:
    ld      a, d
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL + 0x01 - ENEMY_DRAGON_FIRE_DISTANCE)
    jr      nc, 58$
    add     a, #ENEMY_DRAGON_FIRE_OFFSET
    ld      d, a
    jr      57$
52$:
    ld      a, e
    cp      #ENEMY_DRAGON_FIRE_DISTANCE
    jr      c, 58$
    sub     #ENEMY_DRAGON_FIRE_OFFSET
    ld      e, a
    jr      57$
53$:
    ld      a, e
    cp      #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL + 0x01 - ENEMY_DRAGON_FIRE_DISTANCE)
    jr      nc, 58$
    add     a, #ENEMY_DRAGON_FIRE_OFFSET
    ld      e, a
;   jr      57$
57$:
    ld      a, #ENEMY_TYPE_FIRE
    ld      c, ENEMY_DIRECTION(ix)
    call    _EnemyEntry
    push    ix
    pop     hl
    ld      ENEMY_PARAM_0(iy), l
    ld      ENEMY_PARAM_1(iy), h
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x50
    ld      ENEMY_PARAM_2(iy), a
    ld      ENEMY_PARAM_2(ix), a
    ld      ENEMY_ATTACK_POINT(ix), #0x00
    ld      ENEMY_STATE(ix), #0x06
    jr      59$
58$:
    ld      ENEMY_STATE(ix), #0x02
    jr      80$
59$:

    ; 0x06 : 炎を吐く
60$:
    ld      ENEMY_ANIMATION(ix), #(ENEMY_ANIMATION_CYCLE * 0x02 - 0x02)
    dec     ENEMY_PARAM_2(ix)
    jr      nz, 80$
    ld      a, ENEMY_PARAM_3(ix)
    ld      ENEMY_ATTACK_POINT(ix), a
    ld      ENEMY_STATE(ix), #0x02
;   jr      80$
69$:

    ; アニメーションの更新
80$:
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_DRAGON_GREEN
    jr      nz, 81$
    ld      hl, #enemyDragonGreenSprite
    jr      83$
81$:
    cp      #ENEMY_TYPE_DRAGON_BLUE
    jr      nz, 82$
    ld      hl, #enemyDragonBlueSprite
    jr      83$
82$:
    ld      hl, #enemyDragonRedSprite
;   jr      83$
83$:
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; レジスタの復帰

    ; 終了
    ret

; シャドウ
;
_EnemyShadow::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 位置の設定
    ld      ENEMY_POSITION_X(ix), #ENEMY_SHADOW_POSITION_X
    ld      ENEMY_POSITION_Y(ix), #ENEMY_SHADOW_POSITION_Y

    ; ENEMY_PARAM_0 : X 速度
    call    _SystemGetRandom
    rrca
    rrca
    and     #0x02
    sub     #0x01
    ld      ENEMY_PARAM_0(ix), a
    
    ; ENEMY_PARAM_1 : Y 速度
    call    _SystemGetRandom
    rlca
    and     #0x02
    sub     #0x01
    ld      ENEMY_PARAM_1(ix), a

    ; ENEMY_PARAM_2 : インターバル
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x10
    ld      ENEMY_PARAM_2(ix), a

    ; 封印の解除
    ld      a, #ITEM_RING
    call    _PlayerIsItem
    jr      nc, 00$
    ld      a, #ITEM_NECKLACE
    call    _PlayerIsItem
    jr      nc, 00$
    ld      a, #ITEM_ROD
    call    _PlayerIsItem
    jr      nc, 00$

    ; フラグの設定
    res     #ENEMY_FLAG_INVINCIBLE_BIT, ENEMY_FLAG(ix)

    ; BGM の再生
    ld      a, #SOUND_BGM_BOSS
    call    _SoundPlayBgm

    ; 状態の更新
    ld      ENEMY_STATE(ix), #0x02
    jr      09$

    ; 封印されている
00$:

    ; スプライトの設定
    xor     a
    ld      ENEMY_SPRITE_L(ix), a
    ld      ENEMY_SPRITE_H(ix), a

    ; 状態の更新
    ld      ENEMY_STATE(ix), #0x01
;   jr      09$

    ; 初期化の完了
09$:

    ; 封印
    ld      a, ENEMY_STATE(ix)
    dec     a
    jr      z, 90$

    ; 移動
    ld      b, ENEMY_SPEED(ix)
10$:
    ld      a, ENEMY_POSITION_X(ix)
    add     a, ENEMY_PARAM_0(ix)
    ld      ENEMY_POSITION_X(ix), a
    cp      #(ENEMY_DAMAGE_RECT_R_2x2 + 0x01)
    jr      c, 11$
    cp      #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - ENEMY_DAMAGE_RECT_R_2x2)
    jr      c, 12$
11$:
    ld      a, ENEMY_PARAM_0(ix)
    neg
    ld      ENEMY_PARAM_0(ix), a
12$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, ENEMY_PARAM_1(ix)
    ld      ENEMY_POSITION_Y(ix), a
    cp      #(ENEMY_DAMAGE_RECT_R_2x2 + 0x01)
    jr      c, 13$
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - ENEMY_DAMAGE_RECT_R_2x2)
    jr      c, 14$
13$:
    ld      a, ENEMY_PARAM_1(ix)
    neg
    ld      ENEMY_PARAM_1(ix), a
14$:
    djnz    10$

    ; 攻撃
    dec     ENEMY_PARAM_2(ix)
    jr      nz, 29$
    call    _EnemySetDirectionForPlayer
    ld      b, #0x04
20$:
    ld      a, #ENEMY_TYPE_BALL
    call    EnemyCastSpell
    ld      a, ENEMY_DIRECTION(ix)
    inc     a
    and     #0x03
    ld      ENEMY_DIRECTION(ix), a
    djnz    20$
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x10
    ld      ENEMY_PARAM_2(ix), a
29$:

    ; アニメーションの更新
    ld      hl, #enemyShadowSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; 行動の完了
90$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; レジスタの復帰

    ; 終了
    ret

; ボルト
;
_EnemyBolt::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; SE の再生
    ld      a, #SOUND_SE_CAST
    call    _SoundPlaySe

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      b, ENEMY_SPEED(ix)
10$:
    call    _EnemyStep
    jr      nc, 11$
    djnz    10$
    jr      19$
11$:
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x03
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBoltSprite
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; ボール
;
_EnemyBall::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; SE の再生
    ld      a, #SOUND_SE_CAST
    call    _SoundPlaySe

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      b, ENEMY_SPEED(ix)
10$:
    call    _EnemyMove
    ld      a, ENEMY_POSITION_X(ix)
    cp      #ENEMY_DAMAGE_RECT_R_1x1
    jr      c, 11$
    cp      #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - ENEMY_DAMAGE_RECT_R_1x1 + 0x01)
    jr      nc, 11$
    ld      a, ENEMY_POSITION_Y(ix)
    cp      #ENEMY_DAMAGE_RECT_R_1x1
    jr      c, 11$
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - ENEMY_DAMAGE_RECT_R_1x1 + 0x01)
    jr      nc, 11$
    djnz    10$
    jr      19$
11$:
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      a, ENEMY_DIRECTION(ix)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x03
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyBallSprite
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; ファイア
;
_EnemyFire::

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_PARAM_0,1 : 親

    ; ENEMY_PARAM_2 : インターバル

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 待機
    dec     ENEMY_PARAM_2(ix)
    jr      z, 10$
    ld      l, ENEMY_PARAM_0(ix)
    ld      h, ENEMY_PARAM_1(ix)
    ld      de, #ENEMY_TYPE
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 10$
    jr      19$
10$:
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL
19$:

    ; 攻撃の設定
    call    _EnemySetAttackRect

    ; ダメージの設定
    call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      a, ENEMY_DIRECTION(ix)
    rrca
    rrca
    ld      e, a
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x03
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyFireSprite
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    inc     ENEMY_ANIMATION(ix)

    ; SE の再生
    call    _SoundIsPlaySe
    ld      a, #SOUND_SE_FIRE
    call    nc, _SoundPlaySe

    ; レジスタの復帰

    ; 終了
    ret

; 魔法を唱える
;
EnemyCastSpell:

    ; レジスタの保存
    push    bc
    push    de
    push    iy

    ; ix < エネミー
    ; a  < 魔法の種類

    ; 位置の取得
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    ld      b, ENEMY_DAMAGE_RECT_R(ix)
    ld      c, a
    ld      a, ENEMY_DIRECTION(ix)
    or      a
    jr      nz, 11$
    ld      a, d
    sub     b
    jr      nc, 10$
    xor     a
10$:
    ld      d, a
    jr      19$
11$:
    dec     a
    jr      nz, 13$
    ld      a, d
    dec     b
    add     a, b
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      c, 12$
    ld      a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - 0x01)
12$:
    ld      d, a
    jr      19$
13$:
    dec     a
    jr      nz, 15$
    ld      a, e
    sub     b
    jr      nc, 14$
    xor     a
14$:
    ld      e, a
    jr      19$
15$:
    ld      a, e
    dec     b
    add     a, b
    jr      nc, 16$
    ld      a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - 0x01)
16$:
    ld      e, a
;   jr      19$
19$:

    ; 魔法の登録
    ld      a, c
    ld      c, ENEMY_DIRECTION(ix)
    call    _EnemyEntry

    ; レジスタの復帰
    pop     iy
    pop     de
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; エネミーの定義
;

; base parameters
;
; SPEED:  ATTACK x1     x2     x3 / DAMAGE
;     1:     14(15) 30(32) 48(51) / 15(14)
;     2:     19(20) 30(33) 44(44) / 10( 8)
;
;           SPD ATK DEF /  xN, POWER ATTACK
; GHOUL   :   1   1   1 /  x1,    14      2 
; GOBLIN  :   2   1   1 /  x1,    19      2
; BAT     :   1   1   0 /  x1,    10      1
; SPIDER  :   2   1   2 /  x2,    38      3
; GHOST   :   2   1   2 /  x2,    40      3
; MAGE    :   1   2   2 /  x1,    33      -
; REAPER  :   2   2   2 /  x3,    99      3
; GOLEM   :   2   2   3 /  x3,    90      4
; G.DRAGON:   2   2   2 / x16,   480      3
; B.DRAGON:   2   2   3 / x16,   528      4
; R.DRAGON:   2   3   3 / x16,   704      5
; SHADOW  :   2   3   3 / x16,   704      -
;
; AREA 00 :   1   1   0 / COMPASS
;      01 :   1   1   1 / ARMOR
;      02 :   2   1   1 / BOOTS
;      03 :   2   1   1 / NECKLACE
;      04 :   2   1   2 / SHIELD
;      05 :   2   1   2 / CANDLE
;      06 :   2   2   2 / SWORD
;      07 :   2   2   2 / ROD
;      08 :   2   2   3 / HELMET
;      09 :   2   2   3 / RING
;      10 :   2   3   3 / SWORD
;      11 :   1   1   1 / -----
;      12 :   1   1   1 / -----
;      13 :   1   1   1 / -----
;      14 :   1   1   1 / -----
;      15 :   1   1   1 / -----

; なし
_enemyNullDefault:

    .db     ENEMY_TYPE_NULL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     ENEMY_SPEED_NULL
    .dw     ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyNullSprite:

    .db     0xcc, 0xcc, 0x00, 0x00

; グール
_enemyGhoulDefault:

    .db     ENEMY_TYPE_GHOUL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DIVE
    .db     ENEMY_ATTRIBUTE_GHOUL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     14 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     2 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyGhoulSprite:

    .db     -0x08 - 0x01, -0x08, 0x50, VDP_COLOR_GRAY
    .db     -0x08 - 0x01, -0x08, 0x51, VDP_COLOR_GRAY

; ゴブリン
_enemyGoblinDefault:

    .db     ENEMY_TYPE_GOBLIN
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DIVE
    .db     ENEMY_ATTRIBUTE_GOBLIN
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     19 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     2 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyGoblinSprite:

    .db     -0x08 - 0x01, -0x08, 0x52, VDP_COLOR_MEDIUM_GREEN
    .db     -0x08 - 0x01, -0x08, 0x53, VDP_COLOR_MEDIUM_GREEN

; バット
_enemyBatDefault:

    .db     ENEMY_TYPE_BAT
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DIVE
    .db     ENEMY_ATTRIBUTE_BAT
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     10 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     1 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyBatSprite:

    .db     -0x08 - 0x01, -0x08, 0x54, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x55, VDP_COLOR_LIGHT_BLUE

; スパイダー
_enemySpiderDefault:

    .db     ENEMY_TYPE_SPIDER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DIVE
    .db     ENEMY_ATTRIBUTE_SPIDER
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     2 ; ENEMY_SPEED_NULL
    .dw     38 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     3 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemySpiderSprite:

    .db     -0x08 - 0x01, -0x08, 0x56, VDP_COLOR_DARK_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x57, VDP_COLOR_DARK_YELLOW

; ゴースト
_enemyGhostDefault:

    .db     ENEMY_TYPE_GHOST
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .db     ENEMY_ATTRIBUTE_GHOST
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     40 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     3 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_GHOST_BLINK_FADE ; ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyGhostSprite:

    .db     -0x08 - 0x01, -0x08, 0x58, VDP_COLOR_DARK_BLUE
    .db     -0x08 - 0x01, -0x08, 0x59, VDP_COLOR_DARK_BLUE

; メイジ
_enemyMageDefault:

    .db     ENEMY_TYPE_MAGE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_MAGE
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     33 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     0 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyMageSprite:

    .db     -0x08 - 0x01, -0x08, 0x5a, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01, -0x08, 0x5b, VDP_COLOR_MAGENTA

; リーパー
_enemyReaperDefault:

    .db     ENEMY_TYPE_REAPER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DIVE
    .db     ENEMY_ATTRIBUTE_REAPER
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     99 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     3 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyReaperSprite:

    .db     -0x08 - 0x01, -0x08, 0x5c, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x5d, VDP_COLOR_LIGHT_GREEN

; ゴーレム
_enemyGolemDefault:

    .db     ENEMY_TYPE_GOLEM
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_DIVE
    .db     ENEMY_ATTRIBUTE_GOLEM
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     90 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     4 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyGolemSprite:

    .db     -0x08 - 0x01, -0x08, 0x5e, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x08, 0x5f, VDP_COLOR_MEDIUM_RED

; グリーンドラゴン
_enemyDragonGreenDefault:

    .db     ENEMY_TYPE_DRAGON_GREEN
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     480 ; ENEMY_POWER_NULL
    .db     ITEM_CRYSTAL
    .db     ENEMY_DIVE_NULL
    .db     3 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_2x2
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_2x2
    .db     ITEM_NECKLACE ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyDragonGreenSprite:

    .db     -0x10 - 0x01, -0x10, 0x60, VDP_COLOR_MEDIUM_GREEN
    .db     -0x10 - 0x01,  0x00, 0x61, VDP_COLOR_MEDIUM_GREEN
    .db      0x00 - 0x01, -0x10, 0x62, VDP_COLOR_MEDIUM_GREEN
    .db      0x00 - 0x01,  0x00, 0x63, VDP_COLOR_MEDIUM_GREEN
    .db     -0x10 - 0x01, -0x10, 0x64, VDP_COLOR_MEDIUM_GREEN
    .db     -0x10 - 0x01,  0x00, 0x65, VDP_COLOR_MEDIUM_GREEN
    .db      0x00 - 0x01, -0x10, 0x66, VDP_COLOR_MEDIUM_GREEN
    .db      0x00 - 0x01,  0x00, 0x67, VDP_COLOR_MEDIUM_GREEN

; ブルードラゴン
_enemyDragonBlueDefault:

    .db     ENEMY_TYPE_DRAGON_BLUE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     528 ; ENEMY_POWER_NULL
    .db     ITEM_CRYSTAL
    .db     ENEMY_DIVE_NULL
    .db     4 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_2x2
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_2x2
    .db     ITEM_ROD ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyDragonBlueSprite:

    .db     -0x10 - 0x01, -0x10, 0x60, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0x61, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0x62, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0x63, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01, -0x10, 0x64, VDP_COLOR_DARK_BLUE
    .db     -0x10 - 0x01,  0x00, 0x65, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01, -0x10, 0x66, VDP_COLOR_DARK_BLUE
    .db      0x00 - 0x01,  0x00, 0x67, VDP_COLOR_DARK_BLUE

; レッドドラゴン
_enemyDragonRedDefault:

    .db     ENEMY_TYPE_DRAGON_RED
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     704 ; ENEMY_POWER_NULL
    .db     ITEM_CRYSTAL
    .db     ENEMY_DIVE_NULL
    .db     5 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_2x2
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_2x2
    .db     ITEM_RING ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyDragonRedSprite:

    .db     -0x10 - 0x01, -0x10, 0x60, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x61, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x62, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x63, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01, -0x10, 0x64, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x65, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x66, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x67, VDP_COLOR_MEDIUM_RED

; 封印されたドラゴン
enemyDragonSealedSprite:

    .db     -0x10 - 0x01, -0x10, 0x60, VDP_COLOR_GRAY
    .db     -0x10 - 0x01,  0x00, 0x61, VDP_COLOR_GRAY
    .db      0x00 - 0x01, -0x10, 0x62, VDP_COLOR_GRAY
    .db      0x00 - 0x01,  0x00, 0x63, VDP_COLOR_GRAY

; シャドウ
_enemyShadowDefault:

    .db     ENEMY_TYPE_SHADOW
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_BOSS | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     2 ; ENEMY_SPEED_NULL
    .dw     704 ; ENEMY_POWER_NULL
    .db     ITEM_CRYSTAL
    .db     ENEMY_DIVE_NULL
    .db     0 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_2x2
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_2x2
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyShadowSprite:

    .db     -0x10 - 0x01, -0x10, 0x68, VDP_COLOR_MAGENTA
    .db     -0x10 - 0x01,  0x00, 0x69, VDP_COLOR_MAGENTA
    .db      0x00 - 0x01, -0x10, 0x6a, VDP_COLOR_MAGENTA
    .db      0x00 - 0x01,  0x00, 0x6b, VDP_COLOR_MAGENTA
    .db     -0x10 - 0x01, -0x10, 0x6c, VDP_COLOR_MAGENTA
    .db     -0x10 - 0x01,  0x00, 0x6d, VDP_COLOR_MAGENTA
    .db      0x00 - 0x01, -0x10, 0x6e, VDP_COLOR_MAGENTA
    .db      0x00 - 0x01,  0x00, 0x6f, VDP_COLOR_MAGENTA

; ボルト
_enemyBoltDefault:

    .db     ENEMY_TYPE_BOLT
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_SPELL | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     8 ; ENEMY_SPEED_NULL
    .dw     1 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     20 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyBoltSprite:

    .db     -0x08 - 0x01, -0x08, 0x42, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x42, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x42, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x42, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x43, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x43, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x43, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x43, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x44, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x45, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x45, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x45, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x45, VDP_COLOR_LIGHT_BLUE

; ボール
_enemyBallDefault:

    .db     ENEMY_TYPE_BALL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_SPELL | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     6 ; ENEMY_SPEED_NULL
    .dw     1 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     30 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_1x1
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_1x1
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyBallSprite:

    .db     -0x08 - 0x01, -0x08, 0x46, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x46, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x46, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x46, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x47, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x47, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x47, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x47, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x48, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x48, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x48, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x48, VDP_COLOR_LIGHT_BLUE
    .db     -0x08 - 0x01, -0x08, 0x49, VDP_COLOR_LIGHT_RED
    .db     -0x08 - 0x01, -0x08, 0x49, VDP_COLOR_LIGHT_GREEN
    .db     -0x08 - 0x01, -0x08, 0x49, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x49, VDP_COLOR_LIGHT_BLUE

; ファイア
_enemyFireDefault:

    .db     ENEMY_TYPE_FIRE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_2x2 | ENEMY_FLAG_INVINCIBLE
    .db     ENEMY_ATTRIBUTE_NULL
    .db     ENEMY_GROUP_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_DIRECTION_DOWN
    .db     1 ; ENEMY_SPEED_NULL
    .dw     1 ; ENEMY_POWER_NULL
    .db     ITEM_NULL
    .db     ENEMY_DIVE_NULL
    .db     2 ; ENEMY_ATTACK_POINT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_NULL
    .db     ENEMY_ATTACK_RECT_R_2x2
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_NULL
    .db     ENEMY_DAMAGE_RECT_R_2x2
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL

enemyFireSprite:

    ; ↑
    .db     -0x10 - 0x01, -0x10, 0x70, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01,  0x00, 0x71, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01, -0x10, 0x72, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01,  0x00, 0x73, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01, -0x10, 0x70, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x71, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x72, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x73, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01, -0x10, 0x70, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01,  0x00, 0x71, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x10, 0x72, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0x73, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0x70, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x71, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x72, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x73, VDP_COLOR_MEDIUM_RED
    ; ↓
    .db     -0x10 - 0x01, -0x10, 0x74, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01,  0x00, 0x75, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01, -0x10, 0x76, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01,  0x00, 0x77, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01, -0x10, 0x74, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x75, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x76, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x77, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01, -0x10, 0x74, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01,  0x00, 0x75, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x10, 0x76, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0x77, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0x74, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x75, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x76, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x77, VDP_COLOR_MEDIUM_RED
    ; ←
    .db     -0x10 - 0x01, -0x10, 0x78, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01,  0x00, 0x79, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01, -0x10, 0x7a, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01,  0x00, 0x7b, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01, -0x10, 0x78, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x79, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x7a, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x7b, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01, -0x10, 0x78, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01,  0x00, 0x79, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x10, 0x7a, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0x7b, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0x78, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x79, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x7a, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x7b, VDP_COLOR_MEDIUM_RED
    ; →
    .db     -0x10 - 0x01, -0x10, 0x7c, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01,  0x00, 0x7d, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01, -0x10, 0x7e, VDP_COLOR_LIGHT_RED
    .db      0x00 - 0x01,  0x00, 0x7f, VDP_COLOR_LIGHT_RED
    .db     -0x10 - 0x01, -0x10, 0x7c, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x7d, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x7e, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x7f, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01, -0x10, 0x7c, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01,  0x00, 0x7d, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01, -0x10, 0x7e, VDP_COLOR_DARK_RED
    .db      0x00 - 0x01,  0x00, 0x7f, VDP_COLOR_DARK_RED
    .db     -0x10 - 0x01, -0x10, 0x7c, VDP_COLOR_MEDIUM_RED
    .db     -0x10 - 0x01,  0x00, 0x7d, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01, -0x10, 0x7e, VDP_COLOR_MEDIUM_RED
    .db      0x00 - 0x01,  0x00, 0x7f, VDP_COLOR_MEDIUM_RED


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

