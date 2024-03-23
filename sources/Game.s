; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include    "Maze.inc"
    .include    "Wall.inc"
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

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; 迷路の初期化
    call    _MazeInitialize
    call    _MazeGetStartArea
    ld      (_game + GAME_AREA), a

    ; 壁の初期化
    call    _WallInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ;　エネミーの初期化
    call    _EnemyInitialize

    ; アイテムの初期化
    call    _ItemInitialize

    ; ステータスの初期化
    ld      hl, #gameStatusPatternName
    ld      de, #(_patternName + 0x02c0)
    ld      bc, #0x0040
    ldir
    
    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE_GAME) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)

    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (_game + GAME_STATE), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 開始の描画
    call    GamePrintStart

    ; ステータスの描画
    call    GamePrintStatus
    
    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a

    ; BGM の再生
    ld      a, #SOUND_BGM_GAME
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #GAME_STATE_ENTER
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エリアに入る
;
GameEnter:

    ; レジスタの保存

    ; エリアに入る
    call    _WallEnter
    call    _PlayerEnter
    call    _EnemyEnter

    ; BGM の再生
    ld      a, #SOUND_BGM_GAME
    call    _SoundPlayBgm

    ; 状態の更新
    ld      a, #GAME_STATE_PLAY
    ld      (_game + GAME_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒットチェック／最初の 1 フレームだけ行わないようにする
    call    GameHit

    ; 迷路の更新
    call    _MazeUpdate

    ; 壁の更新
    call    _WallUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate
    
    ; アイテムの更新
    call    _ItemUpdate

    ; 迷路の描画
    call    _MazeRender

    ; 壁の描画
    call    _WallRender

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; アイテムの描画
    call    _ItemRender

    ; ステータスの描画
    call    GamePrintStatus

    ; クリア
    call    _PlayerIsReturn
    jr      nc, 90$
    ld      a, #GAME_STATE_CLEAR
    ld      (_game + GAME_STATE), a
    jr      99$
90$:

    ; 死亡
    call    _PlayerIsDead
    jr      nc, 91$
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
    jr      99$
91$:

    ; エリアの移動
    ld      a, (_game + GAME_REQUEST)
    and     #GAME_REQUEST_AREA
    jr      z, 92$
    ld      a, #GAME_STATE_EXIT
    ld      (_game + GAME_STATE), a
    jr      99$
92$:

    ; プレイの完了
99$:

    ; レジスタの復帰

    ; 終了
    ret

; エリアから出る
;
GameExit:

    ; レジスタの保存

    ; エリアから出る
    call    _WallExit
    call    _PlayerExit
    call    _EnemyExit

    ; 次のエリア
    ld      hl, #(_game + GAME_REQUEST)
    ld      a, (_game + GAME_AREA)
    bit     #GAME_REQUEST_AREA_TOP_BIT, (hl)
    jr      z, 80$
    call    _MazeGetTopArea
    jr      89$
80$:
    bit     #GAME_REQUEST_AREA_BOTTOM_BIT, (hl)
    jr      z, 81$
    call    _MazeGetBottomArea
    jr      89$
81$:
    bit     #GAME_REQUEST_AREA_LEFT_BIT, (hl)
    jr      z, 82$
    call    _MazeGetLeftArea
    jr      89$
82$:
    bit     #GAME_REQUEST_AREA_RIGHT_BIT, (hl)
    jr      z, 89$
    call    _MazeGetRightArea
;   jr      89$
89$:
    ld      (_game + GAME_AREA), a
    ld      a, (hl)
    and     #~GAME_REQUEST_AREA
    ld      (hl), a

    ; 状態の更新
    ld      a, #GAME_STATE_ENTER
    ld      (_game + GAME_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; ゲームオーバーの描画
    call    GamePrintOver

    ; BGM の再生
    call    _SoundStop
    ld      a, #SOUND_BGM_OVER
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    call    _SoundIsPlayBgm
    jr      c, 19$
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a

    ; クリアの描画
    call    GamePrintClear

    ; BGM の再生
    call    _SoundStop
    ld      a, #SOUND_BGM_CLEAR
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    call    _SoundIsPlayBgm
    jr      c, 19$
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ヒットチェックを行う
;
GameHit:

    ; レジスタの保存

    ; プレイヤのダメージのクリア
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_DAMAGE_BIT, (hl)

    ; エネミーのダメージのクリア
    ld      hl, #(_enemy + ENEMY_FLAG)
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    res     #ENEMY_FLAG_DAMAGE_BIT, (hl)
    add     hl, de
    djnz    10$

    ; プレイヤのパワーの残存
    ld      hl, (_player + PLAYER_POWER_L)
    ld      a, h
    or      l
    jp      z, 90$

    ; プレイヤとエネミーの判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
200$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jp      z, 290$

    ; エネミーのパワーの残存
    ld      a, ENEMY_POWER_L(ix)
    or      ENEMY_POWER_H(ix)
    jp      z, 290$

    ; プレイヤ→エネミー

    ; エネミーが潜行中／無敵
    ld      a, ENEMY_FLAG(ix)
    and     #(ENEMY_FLAG_DIVE | ENEMY_FLAG_INVINCIBLE)
    jr      nz, 219$

    ; プレイヤの攻撃
    ld      a, (_player + PLAYER_ATTACK_POINT)
    or      a
    jr      z, 219$
    ld      c, a
    ld      de, (_player + PLAYER_ATTACK_RECT_LEFT)
    ld      a, ENEMY_DAMAGE_RECT_RIGHT(ix)
    cp      e
    jr      c, 219$
    ld      a, ENEMY_DAMAGE_RECT_BOTTOM(ix)
    cp      d
    jr      c, 219$
    ld      de, (_player + PLAYER_ATTACK_RECT_RIGHT)
    ld      a, e
    cp      ENEMY_DAMAGE_RECT_LEFT(ix)
    jr      c, 219$
    ld      a, d
    cp      ENEMY_DAMAGE_RECT_TOP(ix)
    jr      c, 219$
    ld      l, ENEMY_POWER_L(ix)
    ld      h, ENEMY_POWER_H(ix)
    ld      b, #0x00
    or      a
    sbc     hl, bc
    jr      nc, 210$
    ld      l, b
    ld      h, b
210$:
    ld      ENEMY_POWER_L(ix), l
    ld      ENEMY_POWER_H(ix), h
    ld      a, h
    or      l
    jr      z, 211$
    set     #ENEMY_FLAG_DAMAGE_BIT, ENEMY_FLAG(ix)
;   call    _SoundIsPlaySe
;   ld      a, #SOUND_SE_DAMAGE
;   call    nc, _SoundPlaySe
    jr      219$
211$:
    ld      ENEMY_BLINK(ix), #ENEMY_BLINK_DEAD
;   jr      219$
219$:

    ; エネミー→プレイヤ

    ; エネミーの攻撃
    ld      a, ENEMY_ATTACK_POINT(ix)
    or      a
    jr      z, 229$
    ld      c, a
    ld      de, (_player + PLAYER_DAMAGE_RECT_LEFT)
    ld      a, ENEMY_ATTACK_RECT_RIGHT(ix)
    cp      e
    jr      c, 229$
    ld      a, ENEMY_ATTACK_RECT_BOTTOM(ix)
    cp      d
    jr      c, 229$
    ld      de, (_player + PLAYER_DAMAGE_RECT_RIGHT)
    ld      a, e
    cp      ENEMY_ATTACK_RECT_LEFT(ix)
    jr      c, 229$
    ld      a, d
    cp      ENEMY_ATTACK_RECT_TOP(ix)
    jr      c, 229$
    bit     #ENEMY_FLAG_SPELL_BIT, ENEMY_FLAG(ix)
    jr      z, 220$
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL
    call    _PlayerGetShieldDirection
    jr      nc, 220$
    xor     #0b00000001
    cp      ENEMY_DIRECTION(ix)
    jr      nz, 220$
    ld      a, #SOUND_SE_SHIELD
    call    _SoundPlaySe
    jr      229$
220$:
    ld      hl, #(_player + PLAYER_DAMAGE_POINT)
    ld      a, c
    add     a, (hl)
    jr      nc, 221$
    ld      a, #0xff
221$:
    ld      (hl), a
229$:

    ; 次のエネミーへ
290$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     b
    jp      nz, 200$

    ; プレイヤのダメージ
    ld      a, (_player + PLAYER_DAMAGE_POINT)
    or      a
    jr      z, 30$
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_DAMAGE_BIT, (hl)
30$:

    ; 判定の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを描画する
;
GamePrintStatus:

    ; レジスタの保存

    ; パワーの描画
    ld      hl, (_player + PLAYER_POWER_L)
    call    _AppGetDecimal_9999
    ld      de, #(_patternName + 0x02c1)
    ld      b, #0x03
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    xor     a
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    12$

    ; クリスタルの描画
    ld      a, (_player + PLAYER_CRYSTAL)
    call    _AppGetDecimal_255
    ld      de, #(_patternName + 0x02e2)
    ld      b, #0x02
20$:
    ld      a, (hl)
    or      a
    jr      nz, 21$
    xor     a
    ld      (de), a
    inc     hl
    inc     de
    djnz    20$
21$:
    inc     b
22$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    22$

    ; アイテムの描画
    ld      de, #(_patternName + 0x02ce)

    ; ソードの描画
    ld      a, (_player + PLAYER_SWORD)
    add     a, a
    add     a, a
    add     a, #ITEM_SWORD_PATTERN_NAME
    call    38$

    ; ヘルメットの描画
    ld      a, (_player + PLAYER_HELMET)
    or      a
    ld      a, #ITEM_HELMET_PATTERN_NAME
    call    nz, 38$

    ; アーマーの描画
    ld      a, (_player + PLAYER_ARMOR)
    or      a
    ld      a, #ITEM_ARMOR_PATTERN_NAME
    call    nz, 38$

    ; シールドの描画
    ld      a, (_player + PLAYER_SHIELD)
    or      a
    ld      a, #ITEM_SHIELD_PATTERN_NAME
    call    nz, 38$

    ; ブーツの描画
    ld      a, (_player + PLAYER_BOOTS)
    or      a
    ld      a, #ITEM_BOOTS_PATTERN_NAME
    call    nz, 38$

    ; キャンドルの描画
    ld      a, (_player + PLAYER_CANDLE)
    or      a
    ld      a, #ITEM_CANDLE_PATTERN_NAME
    call    nz, 38$

    ; リングの描画
    ld      a, (_player + PLAYER_RING)
    or      a
    ld      a, #ITEM_RING_PATTERN_NAME
    call    nz, 38$

    ; ネックレスの描画
    ld      a, (_player + PLAYER_NECKLACE)
    or      a
    ld      a, #ITEM_NECKLACE_PATTERN_NAME
    call    nz, 38$

    ; ロッドの描画
    ld      a, (_player + PLAYER_ROD)
    or      a
    ld      a, #ITEM_ROD_PATTERN_NAME
    call    nz, 38$
    jr      39$

    ; アイテム１つの描画
38$:
    ld      (de), a
    inc     de
    inc     a
    ld      (de), a
    inc     de
    inc     a
    ld      hl, #0x001e
    add     hl, de
    ld      (hl), a
    inc     hl
    inc     a
    ld      (hl), a
;   inc     hl
;   inc     a
    ret

    ; アイテム描画の完了
39$:

    ; コンパスの描画
    ld      a, (_player + PLAYER_COMPASS)
    or      a
    jr      z, 49$
    ld      c, #0x00
    ld      a, (_game + GAME_AREA)
    call    _MazeGetFlag
    and     #MAZE_FLAG_EXIT
    jr      nz, 40$
    ld      a, (_game + GAME_AREA)
    call    _MazeGetTreasure
    or      a
    jr      z, 48$
40$:
    call    _WallGetTreasureLocation
    ld      a, (_player + PLAYER_POSITION_X)
    sub     e
    jr      nc, 41$
    neg
41$:
    ld      l, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     d
    jr      nc, 42$
    neg
42$:
    ld      h, a
    cp      l
    jr      nc, 43$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      e
    ld      a, #0x03
    adc     a, c
    ld      c, a
    jr      48$
43$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      d
    ld      a, #0x01
    adc     a, c
    ld      c, a
;   jr      48$
48$:
    ld      a, c
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #gameStatusCompassPatternName
    add     hl, bc
    ld      de, #(_patternName + 0x02cb)
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
;   inc     de
;   inc     hl
49$:

    ; レジスタの復帰

    ; 終了
    ret

; 開始を描画する
;
GamePrintStart:

    ; レジスタの保存

    ; 画面のクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x02c0 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 開始の描画
    ld      hl, #gameStartPatternName
    ld      de, #(_patternName + 0x0148)
    ld      bc, #0x0010
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーを描画する
;
GamePrintOver:

    ; レジスタの保存

    ; 画面のクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x02c0 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; ゲームオーバーの描画
    ld      hl, #gameOverPatternName
    ld      de, #(_patternName + 0x014b)
    ld      bc, #0x000a
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; クリアを描画する
;
GamePrintClear:

    ; レジスタの保存

    ; 画面のクリア
    ld      hl, #(_patternName + 0x0000)
    ld      de, #(_patternName + 0x0001)
    ld      bc, #(0x02c0 - 0x0001)
    ld      (hl), #0x00
    ldir

    ; クリアの描画
    ld      hl, #gameClearPatternName0
    ld      de, #(_patternName + 0x0108)
    ld      bc, #0x0010
    ldir
    ld      hl, #gameClearPatternName1
    ld      de, #(_patternName + 0x0146)
    ld      bc, #0x0014
    ldir
    ld      hl, #gameClearPatternName2
    ld      de, #(_patternName + 0x018e)
    ld      bc, #0x0004
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GameEnter
    .dw     GamePlay
    .dw     GameExit
    .dw     GameOver
    .dw     GameClear

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_REQUEST_NULL
    .db     GAME_AREA_NULL

; ステータス
;
gameStatusPatternName:

    .db     0xac, 0x11, 0x10, 0x10, 0x10, 0x0f, 0x11, 0x10, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x80, 0x81
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0xbc, 0x00, 0x00, 0x00, 0x10, 0x0f, 0x11, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x82, 0x83
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

gameStatusCompassPatternName:

    .db     0xf8, 0xf9, 0xfa, 0xfb ; なし
    .db     0xf0, 0xf1, 0xfa, 0xfb ; ↑
    .db     0xf8, 0xf9, 0xf2, 0xf3 ; ↓
    .db     0xf4, 0xfe, 0xf5, 0xff ; ←
    .db     0xfc, 0xf6, 0xfd, 0xf7 ; →

; 開始
;
gameStartPatternName:

    ; RETURN FROM mayQ
    .db     0x32, 0x25, 0x34, 0x35, 0x32, 0x2e, 0x00, 0x26, 0x32, 0x2f, 0x2d, 0x00, 0xc4, 0xc5, 0xC6, 0xc7

; ゲームオーバー
;
gameOverPatternName:

    ; GAME  OVER
    .db     0x27, 0x21, 0x2d, 0x25, 0x00, 0x00, 0x2f, 0x36, 0x25, 0x32

; クリア
;
gameClearPatternName0:

    ; CONGRATULATIONS!
    .db     0x23, 0x2f, 0x2e, 0x27, 0x32, 0x21, 0x34, 0x35, 0x2c, 0x21, 0x34, 0x29, 0x2f, 0x2e, 0x33, 0x01

gameClearPatternName1:

    ; YOU'VE RETURNED FROM
    .db     0x39, 0x2f, 0x35, 0x07, 0x36, 0x25, 0x00, 0x32, 0x25, 0x34, 0x35, 0x32, 0x2e, 0x25, 0x24, 0x00, 0x26, 0x32, 0x2f, 0x2d

gameClearPatternName2:

    ; mayQ
    .db     0xc4, 0xc5, 0xc6, 0xc7


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::
    
    .ds     GAME_LENGTH
