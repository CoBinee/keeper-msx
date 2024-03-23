; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include    "Game.inc"
    .include    "Wall.inc"
    .include	"Player.inc"
    .include    "Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存
    
    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの設定／身体
    ld      a, (_player + PLAYER_SHIELD)
    or      a
    jr      z, 20$
    ld      a, #0x60
20$:
    ld      e, a
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      z, 22$
    cp      #PLAYER_SWING_ATTACK
    jr      nc, 21$
    ld      a, #0x20
    jr      22$
21$:
    ld      a, #0x40
;   jr      22$:
22$:
    add     a, e
    ld      e, a
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x04
;   rrca
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSpriteBody
    add     hl, de
    ld      (_player + PLAYER_SPRITE_BODY_L), hl

    ; スプライトの設定／剣
    ld      hl, #0x0000
    ld      a, (_player + PLAYER_SWING)
    cp      #PLAYER_SWING_ATTACK
    jr      c, 30$
    ld      a, (_player + PLAYER_SWORD)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSpriteSword
    add     hl, de
30$:
    ld      (_player + PLAYER_SPRITE_SWORD_L), hl

    ; 色の設定
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_DAMAGE_BIT, a
    ld      a, #VDP_COLOR_LIGHT_RED
    jr      nz, 40$
    ld      a, (_player + PLAYER_CURSE)
    or      a
    ld      a, #VDP_COLOR_MEDIUM_GREEN
    jr      nz, 40$
    ld      a, #VDP_COLOR_WHITE
40$:
    ld      (_player + PLAYER_COLOR), a

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; プレイヤの存在
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      z, 90$

    ; 点滅
    ld      hl, #(_player + PLAYER_BLINK)
    bit     #0x01, (hl)
    jr      nz, 90$

    ; 位置の取得
    ld      bc, #0x0000
    ld      a, (_player + PLAYER_POSITION_X)
    cp      #0x80
    jr      nc, 10$
    ld      bc, #0x2080
10$:

    ; スプライトの描画／身体
    ld      hl, (_player + PLAYER_SPRITE_BODY_L)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_BODY)
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_COLOR)
    or      c
    ld      (de), a
;   inc     hl
;   inc     de

    ; スプライトの描画／剣
    ld      hl, (_player + PLAYER_SPRITE_SWORD_L)
    ld      a, h
    or      l
    jr      z, 39$
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_SWORD_0)
    ld      a, (_game + GAME_FRAME)
    rra
    jr      nc, 30$
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_SWORD_1)
30$:
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      c
    ld      (de), a
;   inc     hl
;   inc     de
39$:

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが行動する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; パラメータの更新

    ; フラグのクリア
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_MOVE_BIT, (hl)

    ; ダメージの更新
100$:
    ld      a, (_player + PLAYER_DAMAGE_POINT)
    or      a
    jr      z, 109$
    ld      d, a
    ld      a, (_player + PLAYER_HELMET)
    ld      hl, #(_player + PLAYER_ARMOR)
    add     a, (hl)
    ld      hl, #(_player + PLAYER_SHIELD)
    add     a, (hl)
    ld      e, a
    ld      a, d
    sub     e
    jr      c, 101$
    jr      nz, 102$
101$:
    ld      a, #0x01
102$:
    ld      e, a
    ld      d, #0x00
    ld      hl, (_player + PLAYER_POWER_L)
    or      a
    sbc     hl, de
    jr      nc, 103$
    ld      l, d
    ld      h, d
103$:
    ld      (_player + PLAYER_POWER_L), hl
    ld      a, d
    ld      (_player + PLAYER_DAMAGE_POINT), a
    ld      a, h
    or      l
    jr      nz, 109$
109$:

    ; 呪いの更新
    ld      hl, #(_player + PLAYER_CURSE)
    ld      a, (hl)
    or      a
    jr      z, 119$
    dec     (hl)
119$:

    ; 死亡判定
    ld      hl, (_player + PLAYER_POWER_L)
    ld      a, h
    or      l
    jr      nz, 199$

    ; 状態の更新
    ld      a, #PLAYER_STATE_DEAD
    ld      (_player + PLAYER_STATE), a
    jp      90$
199$:

    ; 剣を振る
    ld      hl, #(_player + PLAYER_FLAG)
    ld      de, #(_player + PLAYER_SWING)
    bit     #PLAYER_FLAG_ATTACK_BIT, (hl)
    jr      nz, 210$

    ; 剣を抜く
200$:
    ld      a, (de)
    or      a
    jr      z, 201$
    dec     a
    ld      (de), a
    jr      290$
201$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 290$
    set     #PLAYER_FLAG_ATTACK_BIT, (hl)
    ld      a, (de)
    inc     a
    ld      (de), a
    ld      a, #SOUND_SE_SWORD_OPEN
    call    _SoundPlaySe
    jr      290$

    ; 剣をしまう
210$:
    ld      a, (de)
    cp      #PLAYER_SWING_ATTACK
    jr      nc, 211$
    inc     a
    ld      (de), a
    jr      290$
211$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      nz, 290$
    res     #PLAYER_FLAG_ATTACK_BIT, (hl)
    ld      a, (de)
    dec     a
    ld      (de), a
    ld      a, #SOUND_SE_SWORD_CLOSE
    call    _SoundPlaySe
;   jr      290$

    ; 剣を振るの完了
290$:

    ; 移動の開始
    ld      a, (_player + PLAYER_CURSE)
    or      a
    jr      z, 300$
    and     #0x01
    jp      nz, 399$
    ld      b, #PLAYER_SPEED_CURSE
    jr      309$
300$:
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      nz, 301$
    ld      b, #PLAYER_SPEED_HIGH
    jr      309$
301$:
    ld      a, (_player + PLAYER_BOOTS)
    add     a, #PLAYER_SPEED_NORMAL
    ld      b, a
;   jr      309$
309$:

    ; ↑の操作
310$:
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 320$
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x0f
    ld      c, a
    cp      #0x08
    jr      nz, 311$
    ld      a, #PLAYER_DIRECTION_UP
    ld      (_player + PLAYER_DIRECTION), a
    jp      350$
311$:
    ld      a, (_player + PLAYER_DIRECTION)
    cp      #PLAYER_DIRECTION_LEFT
    jp      z, 370$
    cp      #PLAYER_DIRECTION_RIGHT
    jp      z, 380$
    ld      a, c
    cp      #0x08
    jp      c, 380$
    jp      370$

    ; ↓の操作
320$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 330$
    ld      a, (_player + PLAYER_POSITION_X)
    and     #0x0f
    ld      c, a
    cp      #0x08
    jr      nz, 321$
    ld      a, #PLAYER_DIRECTION_DOWN
    ld      (_player + PLAYER_DIRECTION), a
    jp      360$
321$:
    ld      a, (_player + PLAYER_DIRECTION)
    cp      #PLAYER_DIRECTION_LEFT
    jp      z, 370$
    cp      #PLAYER_DIRECTION_RIGHT
    jp      z, 380$
    ld      a, c
    cp      #0x08
    jp      c, 380$
    jp      370$

    ; ←の操作
330$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 340$
    ld      a, (_player + PLAYER_POSITION_Y)
    and     #0x0f
    ld      c, a
    cp      #0x08
    jr      nz, 331$
    ld      a, #PLAYER_DIRECTION_LEFT
    ld      (_player + PLAYER_DIRECTION), a
    jp      370$
331$:
    ld      a, (_player + PLAYER_DIRECTION)
    cp      #PLAYER_DIRECTION_UP
    jr      z, 350$
    cp      #PLAYER_DIRECTION_DOWN
    jr      z, 360$
    ld      a, c
    cp      #0x08
    jr      c, 360$
    jr      350$

    ; →の操作
340$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jp      z, 399$
    ld      a, (_player + PLAYER_POSITION_Y)
    and     #0x0f
    ld      c, a
    cp      #0x08
    jr      nz, 341$
    ld      a, #PLAYER_DIRECTION_RIGHT
    ld      (_player + PLAYER_DIRECTION), a
    jp      380$
341$:
    ld      a, (_player + PLAYER_DIRECTION)
    cp      #PLAYER_DIRECTION_UP
    jr      z, 350$
    cp      #PLAYER_DIRECTION_DOWN
    jr      z, 360$
    ld      a, c
    cp      #0x08
    jr      c, 360$
    jr      350$

    ; ↑へ移動
350$:
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      e, (hl)
    inc     hl
    ld      a, (hl)
    sub     #(PLAYER_SIZE_R + 0x01)
    jr      c, 358$
    ld      d, a
    call    _WallIsPath
    jr      c, 351$
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      nz, 359$
;   call    _WallIsDig
;   jr      nc, 359$
    call    _WallDig
    jr      nc, 351$
    ld      de, #PLAYER_POWER_DIG
    call    _PlayerSubPower
;   ld      a, #SOUND_SE_DIG
;   call    _SoundPlaySe
351$:
    dec     (hl)
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    jr      359$
358$:
    ld      (hl), #PLAYER_SIZE_R
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_EXIT_TOP_BIT, (hl)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_TOP_BIT, (hl)
    jp      399$
359$:
    jp      390$

    ; ↓へ移動
360$:
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      e, (hl)
    inc     hl
    ld      a, (hl)
    add     a, #PLAYER_SIZE_R
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      nc, 368$
    ld      d, a
    call    _WallIsPath
    jr      c, 361$
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      nz, 369$
;   call    _WallIsDig
;   jr      nc, 369$
    call    _WallDig
    jr      nc, 361$
    ld      de, #PLAYER_POWER_DIG
    call    _PlayerSubPower
;   ld      a, #SOUND_SE_DIG
;   call    _SoundPlaySe
361$:
    inc     (hl)
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    jr      369$
368$:
    ld      (hl), #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - PLAYER_SIZE_R)
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_EXIT_BOTTOM_BIT, (hl)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_BOTTOM_BIT, (hl)
    jp      399$
369$:
    jr      390$

    ; ←へ移動
370$:
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      d, (hl)
    dec     hl
    ld      a, (hl)
    sub     #(PLAYER_SIZE_R + 0x01)
    jr      c, 378$
    ld      e, a
    call    _WallIsPath
    jr      c, 371$
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      nz, 379$
;   call    _WallIsDig
;   jr      nc, 379$
    call    _WallDig
    jr      nc, 371$
    ld      de, #PLAYER_POWER_DIG
    call    _PlayerSubPower
;   ld      a, #SOUND_SE_DIG
;   call    _SoundPlaySe
371$:
    dec     (hl)
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    jr      379$
378$:
    ld      (hl), #PLAYER_SIZE_R
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_EXIT_LEFT_BIT, (hl)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_LEFT_BIT, (hl)
    jr      399$
379$:
    jr      390$

    ; →へ移動
380$:
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      d, (hl)
    dec     hl
    ld      a, (hl)
    add     a, #PLAYER_SIZE_R
    jr      c, 388$
    ld      e, a
    call    _WallIsPath
    jr      c, 381$
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      nz, 389$
;   call    _WallIsDig
;   jr      nc, 389$
    call    _WallDig
    jr      nc, 381$
    ld      de, #PLAYER_POWER_DIG
    call    _PlayerSubPower
;   ld      a, #SOUND_SE_DIG
;   call    _SoundPlaySe
381$:
    inc     (hl)
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MOVE_BIT, (hl)
    jr      389$
388$:
    ld      (hl), #-PLAYER_SIZE_R
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_EXIT_RIGHT_BIT, (hl)
    ld      hl, #(_game + GAME_REQUEST)
    set     #GAME_REQUEST_AREA_RIGHT_BIT, (hl)
    jr      399$
389$:
;   jr      390$

    ; 移動の完了
390$:
    dec     b
    jp      nz, 309$
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)
399$:

    ; 攻撃の設定
    call    PlayerSetAttackRect
    ld      hl, #(_player + PLAYER_ATTACK_POINT)
    ld      (hl), #0x00
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MOVE_BIT, a
    jr      z, 40$
    ld      a, (_player + PLAYER_SWING)
    cp      #PLAYER_SWING_ATTACK
    jr      c, 40$
    ld      a, (_player + PLAYER_SWORD)
    ld      c, a
    ld      a, (_player + PLAYER_SPEED)
    add     a, c
    ld      (hl), a
40$:

    ; ダメージの設定
    call    PlayerSetDamageRect

    ; アイテムを拾う
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MOVE_BIT, a
    jr      z, 69$
    ld      de, (_player + PLAYER_POSITION_X)
    call    _WallPickupTreasure
    call    _PlayerAddItem
69$:

    ; 出口の判定
    ld      de, (_player + PLAYER_POSITION_X)
    call    _WallIsExit
    jr      nc, 79$

    ; 状態の更新
    ld      a, #PLAYER_STATE_RETURN
    ld      (_player + PLAYER_STATE), a
79$:

    ; 行動の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが死亡する
;
PlayerDead::

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_DEAD
    ld      (_player + PLAYER_BLINK), a

    ; BGM の再生
    ld      a, #SOUND_BGM_MISS
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 点滅の更新
    ld      hl, #(_player + PLAYER_BLINK)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    xor     a
    ld      (_player + PLAYER_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが帰還する
;
PlayerReturn:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (_player + PLAYER_FRAME), a

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_RETURN
    ld      (_player + PLAYER_BLINK), a

    ; BGM の再生
    ld      a, #SOUND_BGM_EXIT
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 出口の取得
    call    _WallGetTreasureLocation

    ; 出口に入る
    ld      a, (_player + PLAYER_FRAME)
    and     #0x03
    jr      nz, 19$
    ld      hl, #(_player + PLAYER_POSITION_X)
    ld      a, (hl)
    cp      e
    jr      z, 11$
    jr      nc, 10$
    inc     (hl)
    jr      19$
10$:
    dec     (hl)
    jr      19$
11$:
    ld      hl, #(_player + PLAYER_POSITION_Y)
    ld      a, (hl)
    cp      d
    jr      z, 19$
    jr      nc, 12$
    inc     (hl)
    jr      19$
12$:
    dec     (hl)
;   jr      19$
19$:

    ; 点滅の更新
    ld      a, (_player + PLAYER_POSITION_X)
    cp      e
    jr      nz, 29$
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      d
    jr      nz, 29$
    ld      hl, #(_player + PLAYER_BLINK)
    dec     (hl)
    jr      nz, 29$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_RETURN_BIT, (hl)

    ; 状態の更新
    xor     a
    ld      (_player + PLAYER_STATE), a
;   jr      29$
29$:

    ; フレームの更新
    ld      hl, #(_player + PLAYER_FRAME)
    inc     (hl)
    
    ; レジスタの復帰

    ; 終了
    ret

; エリアに入る
;
_PlayerEnter::

    ; レジスタの保存

    ; 現在地を掘る
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, #-PLAYER_SIZE_R
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #-PLAYER_SIZE_R
    ld      d, a
    call    _WallDig
    ld      a, e
    add     a, #(PLAYER_SIZE_R * 0x02 - 0x01)
    ld      e, a
    call    _WallDig
    ld      a, d
    add     a, #(PLAYER_SIZE_R * 0x02 - 0x01)
    ld      d, a
    call    _WallDig
    ld      a, e
    add     a, #(-(PLAYER_SIZE_R * 0x02 - 0x01))
    ld      e, a
    call    _WallDig

    ; 範囲の設定
    call    PlayerSetAttackRect
    call    PlayerSetDamageRect
    
    ; 状態の更新
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エリアから出る
;
_PlayerExit::

    ; レジスタの保存

    ; 出る方向の更新
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_EXIT_TOP_BIT, (hl)
    jr      z, 10$
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - PLAYER_SIZE_R * 0x02)
    ld      (_player + PLAYER_POSITION_Y), a
    jr      19$
10$:
    bit     #PLAYER_FLAG_EXIT_BOTTOM_BIT, (hl)
    jr      z, 11$
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - PLAYER_SIZE_R * 0x02)
    ld      (_player + PLAYER_POSITION_Y), a
    jr      19$
11$:
    bit     #PLAYER_FLAG_EXIT_LEFT_BIT, (hl)
    jr      z, 12$
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - PLAYER_SIZE_R * 0x02)
    ld      (_player + PLAYER_POSITION_X), a
    jr      19$
12$:
    bit     #PLAYER_FLAG_EXIT_RIGHT_BIT, (hl)
    jr      z, 19$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - PLAYER_SIZE_R * 0x02)
    ld      (_player + PLAYER_POSITION_X), a
;   jr      19$
19$:
    ld      a, (hl)
    and     #~PLAYER_FLAG_EXIT
    ld      (hl), a

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤにパワーを加える
;
_PlayerAddPower::

    ; レジスタの保存
    push    hl
    push    de

    ; de < パワー

    ; パワーの加算
    ld      hl, (_player + PLAYER_POWER_L)
    add     hl, de
    push    hl
    ld      de, #PLAYER_POWER_MAXIMUM
    or      a
    sbc     hl, de
    pop     hl
    jr      c, 10$
    ex      de, hl
10$:
    ld      (_player + PLAYER_POWER_L), hl

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤにパワーを減らす
;
_PlayerSubPower::

    ; レジスタの保存
    push    hl

    ; de < パワー

    ; パワーの加算
    ld      hl, (_player + PLAYER_POWER_L)
    or      a
    sbc     hl, de
    jr      nc, 10$
    ld      hl, #0x0000
10$:
    ld      (_player + PLAYER_POWER_L), hl

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤの攻撃範囲を設定する
;
PlayerSetAttackRect:

    ; レジスタの保存

    ; 範囲の設定
    ld      a, (_player + PLAYER_SWORD)
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerAttackRect
    add     hl, de
    ld      de, #(_player + PLAYER_ATTACK_RECT_LEFT)
    ld      bc, (_player + PLAYER_POSITION_X)
    ld      a, c
    sub     (hl)
    jr      nc, 10$
    xor     a
10$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    sub     (hl)
    jr      nc, 11$
    xor     a
11$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    jr      nc, 12$
    ld      a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - 0x01)
12$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, b
    add     a, (hl)
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      c, 13$
    ld      a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - 0x01)
13$:
    ld      (de), a
;   inc     hl
;   inc     de

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのダメージ範囲を設定する
;
PlayerSetDamageRect:

    ; レジスタの保存

    ; 範囲の設定
    ld      hl, #(_player + PLAYER_DAMAGE_RECT_LEFT)
    ld      de, (_player + PLAYER_POSITION_X)
    ld      a, e
    sub     #PLAYER_DAMAGE_RECT_R
    jr      nc, 10$
    xor     a
10$:
    ld      (hl), a
    inc     hl
    ld      a, d
    sub     #PLAYER_DAMAGE_RECT_R
    jr      nc, 11$
    xor     a
11$:
    ld      (hl), a
    inc     hl
    ld      a, e
    add     a, #(PLAYER_DAMAGE_RECT_R - 0x01)
    jr      nc, 12$
    ld      a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - 0x01)
12$:
    ld      (hl), a
    inc     hl
    ld      a, d
    add     a, #(PLAYER_DAMAGE_RECT_R - 0x01)
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      c, 13$
    ld      a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - 0x01)
13$:
    ld      (hl), a
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤにダメージを加える
;
_PlayerAddDamage::

    ; レジスタの保存
    push    hl

    ; a < ダメージ量
    
    ; ダメージの加算
    ld      hl, #(_player + PLAYER_DAMAGE_POINT)
    add     a, (hl)
    jr      nc, 10$
    ld      a, #0xff
10$:
    ld      (hl), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤが死亡したかどうかを判定する
;
_PlayerIsDead::

    ; レジスタの保存

    ; cf > 1 = 死亡

    ; 死亡の判定
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが帰還したかどうかを判定する
;
_PlayerIsReturn::

    ; レジスタの保存

    ; cf > 1 = 帰還した

    ; 帰還の判定
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_RETURN_BIT, a
    jr      z, 10$
    scf
    jr      19$
10$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤにアイテムを追加する
;
_PlayerAddItem::

    ; レジスタの保存
    push    hl
    push    de

    ; a < アイテム

    ; アイテムの存在
    or      a
    jr      z, 90$

    ; クリスタル
    cp      #ITEM_CRYSTAL
    jr      nz, 109$
    ld      hl, #(_player + PLAYER_CRYSTAL)
    inc     (hl)
    ld      de, #PLAYER_POWER_CRYSTAL
    call    _PlayerAddPower
    ld      a, #SOUND_SE_CRYSTAL
    call    _SoundPlaySe
    jr      90$
109$:

    ; 呪い
    cp      #ITEM_CURSE
    jr      nz, 119$
    ld      a, #ITEM_CURSE_FRAME
    ld      (_player + PLAYER_CURSE), a
    jr      90$
119$:

    ; その他のアイテム
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerItem
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    inc     (hl)
    ld      a, #SOUND_SE_TREASURE
    call    _SoundPlaySe
;   jr      90$

    ; アイテム追加の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤがアイテムを持っているかを判定する
;
_PlayerIsItem::

    ; レジスタの保存
    push    hl
    push    de

    ; a  < アイテム
    ; cf > 1 = 持っている

    ; アイテムの存在
    or      a
    jr      z, 18$
    cp      #ITEM_CRYSTAL
    jr      nz, 10$
    ld      hl, #(_player + PLAYER_CRYSTAL)
    jr      11$
10$:
    cp      #ITEM_CURSE
    jr      z, 18$
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerItem
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
11$:
    ld      a, (hl)
    or      a
    jr      z, 18$
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; シールドの向きを取得する
;
_PlayerGetShieldDirection::

    ; レジスタの保存
    push    hl
    push    de

    ; a  > 向き
    ; cf > 1 = シールドが有効

    ; シールドの取得
    ld      a, (_player + PLAYER_SHIELD)
    or      a
    jr      z, 18$
    ld      a, (_player + PLAYER_SWING)
    or      a
    jr      nz, 10$
    ld      a, (_player + PLAYER_DIRECTION)
    jr      11$
10$:
    cp      #PLAYER_SWING_ATTACK
    jr      nz, 18$
    ld      a, (_player + PLAYER_DIRECTION)
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerAttackShieldDirection
    add     hl, de
    ld      a, (hl)
11$:
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerPlay
    .dw     PlayerDead
    .dw     PlayerReturn

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .db     0x80 ; PLAYER_POSITION_NULL
    .db     0x58 ; PLAYER_POSITION_NULL
    .db     PLAYER_DIRECTION_DOWN
    .db     PLAYER_SPEED_NORMAL
    .db     PLAYER_BOOTS_NULL
    .dw     PLAYER_POWER_MAXIMUM ; PLAYER_POWER_NULL
    .db     PLAYER_CRYSTAL_NULL
    .db     PLAYER_CURSE_NULL
    .db     PLAYER_SWORD_SHORT
    .db     PLAYER_SWING_NULL
    .db     PLAYER_HELMET_NULL
    .db     PLAYER_ARMOR_NULL
    .db     PLAYER_SHIELD_NULL
    .db     PLAYER_COMPASS_NULL
    .db     PLAYER_CANDLE_NULL
    .db     PLAYER_RING_NULL
    .db     PLAYER_NECKLACE_NULL
    .db     PLAYER_ROD_NULL
    .db     PLAYER_ATTACK_POINT_NULL
    .db     PLAYER_ATTACK_RECT_NULL
    .db     PLAYER_ATTACK_RECT_NULL
    .db     PLAYER_ATTACK_RECT_NULL
    .db     PLAYER_ATTACK_RECT_NULL
    .db     PLAYER_DAMAGE_POINT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_DAMAGE_RECT_NULL
    .db     PLAYER_FRAME_NULL
    .db     PLAYER_ANIMATION_NULL
    .db     PLAYER_BLINK_NULL
    .db     PLAYER_COLOR_NULL
    .dw     PLAYER_SPRITE_NULL
    .dw     PLAYER_SPRITE_NULL

; 攻撃範囲
;
playerAttackRect:

    ; PLAYER_SWORD_SHORT
    .db     PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R + 0x02, PLAYER_ATTACK_RECT_R + 0x00 - 0x01, PLAYER_ATTACK_RECT_R - 0x04 - 0x01 ; ↑
    .db     PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R - 0x04, PLAYER_ATTACK_RECT_R + 0x00 - 0x01, PLAYER_ATTACK_RECT_R + 0x02 - 0x01 ; ↓
    .db     PLAYER_ATTACK_RECT_R + 0x02, PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R - 0x04 - 0x01, PLAYER_ATTACK_RECT_R + 0x00 - 0x01 ; ←
    .db     PLAYER_ATTACK_RECT_R - 0x04, PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R + 0x02 - 0x01, PLAYER_ATTACK_RECT_R + 0x00 - 0x01 ; →
    ; PLAYER_SWORD_MIDDLE
    .db     PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R + 0x04, PLAYER_ATTACK_RECT_R + 0x00 - 0x01, PLAYER_ATTACK_RECT_R - 0x04 - 0x01 ; ↑
    .db     PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R - 0x04, PLAYER_ATTACK_RECT_R + 0x00 - 0x01, PLAYER_ATTACK_RECT_R + 0x04 - 0x01 ; ↓
    .db     PLAYER_ATTACK_RECT_R + 0x04, PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R - 0x04 - 0x01, PLAYER_ATTACK_RECT_R + 0x00 - 0x01 ; ←
    .db     PLAYER_ATTACK_RECT_R - 0x04, PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R + 0x04 - 0x01, PLAYER_ATTACK_RECT_R + 0x00 - 0x01 ; →
    ; PLAYER_SWORD_LONG
    .db     PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R + 0x06, PLAYER_ATTACK_RECT_R + 0x00 - 0x01, PLAYER_ATTACK_RECT_R - 0x04 - 0x01 ; ↑
    .db     PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R - 0x04, PLAYER_ATTACK_RECT_R + 0x00 - 0x01, PLAYER_ATTACK_RECT_R + 0x06 - 0x01 ; ↓
    .db     PLAYER_ATTACK_RECT_R + 0x06, PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R - 0x04 - 0x01, PLAYER_ATTACK_RECT_R + 0x00 - 0x01 ; ←
    .db     PLAYER_ATTACK_RECT_R - 0x04, PLAYER_ATTACK_RECT_R + 0x00, PLAYER_ATTACK_RECT_R + 0x06 - 0x01, PLAYER_ATTACK_RECT_R + 0x00 - 0x01 ; →

; 攻撃中のシールドの向き
;
playerAttackShieldDirection:

    .db     PLAYER_DIRECTION_LEFT
    .db     PLAYER_DIRECTION_RIGHT
    .db     PLAYER_DIRECTION_DOWN
    .db     PLAYER_DIRECTION_UP

; アイテム
;
playerItem:

    .dw     _player + PLAYER_ANIMATION
    .dw     _player + PLAYER_SWORD
    .dw     _player + PLAYER_HELMET
    .dw     _player + PLAYER_ARMOR
    .dw     _player + PLAYER_SHIELD
    .dw     _player + PLAYER_BOOTS
    .dw     _player + PLAYER_COMPASS
    .dw     _player + PLAYER_CANDLE
    .dw     _player + PLAYER_RING
    .dw     _player + PLAYER_NECKLACE
    .dw     _player + PLAYER_ROD

; スプライト
;
playerSpriteBody:

    ; シールドなし／移動
    .db     -0x08 - 0x01, -0x08, 0x08, VDP_COLOR_WHITE ; ↑
    .db     -0x08 - 0x01, -0x08, 0x09, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x0a, VDP_COLOR_WHITE ; ↓
    .db     -0x08 - 0x01, -0x08, 0x0b, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x0c, VDP_COLOR_WHITE ; ←
    .db     -0x08 - 0x01, -0x08, 0x0d, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x0e, VDP_COLOR_WHITE ; →
    .db     -0x08 - 0x01, -0x08, 0x0f, VDP_COLOR_WHITE 
    ; シールドなし／振る
    .db     -0x08 - 0x01, -0x08, 0x10, VDP_COLOR_WHITE ; ↑
    .db     -0x08 - 0x01, -0x08, 0x11, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x12, VDP_COLOR_WHITE ; ↓
    .db     -0x08 - 0x01, -0x08, 0x13, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x14, VDP_COLOR_WHITE ; ←
    .db     -0x08 - 0x01, -0x08, 0x15, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x16, VDP_COLOR_WHITE ; → 
    .db     -0x08 - 0x01, -0x08, 0x17, VDP_COLOR_WHITE
    ; シールドなし／攻撃
    .db     -0x08 - 0x01, -0x08, 0x18, VDP_COLOR_WHITE ; ↑
    .db     -0x08 - 0x01, -0x08, 0x19, VDP_COLOR_WHITE 
    .db     -0x08 - 0x01, -0x08, 0x1a, VDP_COLOR_WHITE ; ↓ 
    .db     -0x08 - 0x01, -0x08, 0x1b, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x1c, VDP_COLOR_WHITE ; ← 
    .db     -0x08 - 0x01, -0x08, 0x1d, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x1e, VDP_COLOR_WHITE ; →
    .db     -0x08 - 0x01, -0x08, 0x1f, VDP_COLOR_WHITE
    ; シールドあり／移動
    .db     -0x08 - 0x01, -0x08, 0x28, VDP_COLOR_WHITE ; ↑
    .db     -0x08 - 0x01, -0x08, 0x29, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x2a, VDP_COLOR_WHITE ; ↓
    .db     -0x08 - 0x01, -0x08, 0x2b, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x2c, VDP_COLOR_WHITE ; ←
    .db     -0x08 - 0x01, -0x08, 0x2d, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x2e, VDP_COLOR_WHITE ; →
    .db     -0x08 - 0x01, -0x08, 0x2f, VDP_COLOR_WHITE
    ; シールドあり／振る
    .db     -0x08 - 0x01, -0x08, 0x30, VDP_COLOR_WHITE ; ↑
    .db     -0x08 - 0x01, -0x08, 0x31, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x32, VDP_COLOR_WHITE ; ↓ 
    .db     -0x08 - 0x01, -0x08, 0x33, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x34, VDP_COLOR_WHITE ; ←
    .db     -0x08 - 0x01, -0x08, 0x35, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x36, VDP_COLOR_WHITE ; →
    .db     -0x08 - 0x01, -0x08, 0x37, VDP_COLOR_WHITE
    ; シールドあり／攻撃
    .db     -0x08 - 0x01, -0x08, 0x38, VDP_COLOR_WHITE ; ↑ 
    .db     -0x08 - 0x01, -0x08, 0x39, VDP_COLOR_WHITE 
    .db     -0x08 - 0x01, -0x08, 0x3a, VDP_COLOR_WHITE ; ↓
    .db     -0x08 - 0x01, -0x08, 0x3b, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x3c, VDP_COLOR_WHITE ; ←
    .db     -0x08 - 0x01, -0x08, 0x3d, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x3e, VDP_COLOR_WHITE ; →
    .db     -0x08 - 0x01, -0x08, 0x3f, VDP_COLOR_WHITE

playerSpriteSword:

    ; PLAYER_SWORD_SHORT
    .db     -0x0e - 0x01, -0x08, 0x04, VDP_COLOR_CYAN ; ↑
    .db     -0x02 - 0x01, -0x08, 0x05, VDP_COLOR_CYAN ; ↓
    .db     -0x08 - 0x01, -0x0e, 0x06, VDP_COLOR_CYAN ; ←
    .db     -0x08 - 0x01, -0x02, 0x07, VDP_COLOR_CYAN ; →
    ; PLAYER_SWORD_MIDDLE
    .db     -0x0e - 0x01, -0x08, 0x20, VDP_COLOR_CYAN ; ↑
    .db     -0x02 - 0x01, -0x08, 0x21, VDP_COLOR_CYAN ; ↓
    .db     -0x08 - 0x01, -0x0e, 0x22, VDP_COLOR_CYAN ; ←
    .db     -0x08 - 0x01, -0x02, 0x23, VDP_COLOR_CYAN ; →
    ; PLAYER_SWORD_LONG
    .db     -0x0e - 0x01, -0x08, 0x24, VDP_COLOR_CYAN ; ↑
    .db     -0x02 - 0x01, -0x08, 0x25, VDP_COLOR_CYAN ; ↓
    .db     -0x08 - 0x01, -0x0e, 0x26, VDP_COLOR_CYAN ; ←
    .db     -0x08 - 0x01, -0x02, 0x27, VDP_COLOR_CYAN ; →


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH
