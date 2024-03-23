; Enemy.s : エネミー
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
    .include    "Maze.inc"
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

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; エネミーのクリア
    call    EnemyClear

    ; 倒したエネミーの属性の初期化
    xor     a
    ld      (enemyAttribute), a

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの存在
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$

    ; エネミーの死亡
    ld      a, ENEMY_POWER_L(ix)
    or      ENEMY_POWER_H(ix)
    jr      nz, 11$
    call    EnemyDead
    jr      19$
11$:

    ; エネミーの潜行
    bit     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
    jr      z, 12$
    call    EnemyDive
    jr      19$
12$:

    ; エネミー別の処理
    ld      hl, #19$
    push    hl
    ld      a, ENEMY_TYPE(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
19$:

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (enemySprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 19$
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    ld      a, h
    or      l
    jr      z, 19$
    bit     #0x01, ENEMY_BLINK(ix)
    jr      nz, 19$
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 11$
    call    20$
    jr      19$
11$:
    call    20$
    call    20$
    call    20$
    call    20$
;   jr      19$
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      90$

    ; ひとつのスプライトの描画
20$:
    push    de
    push    hl
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    pop     de
    ex      de, hl
    ld      a, ENEMY_POSITION_X(ix)
    ld      bc, #0x0000
    cp      #0x80
    jr      nc, 21$
    ld      bc, #0x2080
21$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X(ix)
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
    bit     #ENEMY_FLAG_DAMAGE_BIT, ENEMY_FLAG(ix)
    jr      z, 22$
    ld      a, #VDP_COLOR_LIGHT_RED
22$:
    or      c
    ld      (de), a
    inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    ld      e, a
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 29$
    ld      e, #0x00
29$:
    ret

    ; スプライトの更新
90$:
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #ENEMY_SPRITE_LENGTH
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エリアに入る
;
_EnemyEnter::

    ; レジスタの保存

    ; エネミーのクリア
    call    EnemyClear

    ; エネミーの取得
    ld      a, (_game + GAME_AREA)
    call    _MazeGetEnemys
    ld      e, (hl)
    ld      a, (_game + GAME_AREA)
    call    _MazeGetOrder
    add     a, a
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemyGroup
    add     hl, bc

    ; エネミーの配置
    ld      d, #0b10000000
    ld      b, #0x00
10$:
    ld      a, e
    and     d
    jr      z, 19$
    ld      a, (hl)
    or      a
    jr      z, 19$
    push    bc
    push    de
    push    af
    ld      a, b
    call    _WallGetEnemyLocation
    call    _SystemGetRandom
    and     #0x03
    ld      c, a
    pop     af
    call    _EnemyEntry
    pop     de
    pop     bc
    jr      nc, 19$
    ld      ENEMY_GROUP(iy), d
    push    hl
    ld      hl, #enemyExist
    inc     (hl)
    pop     hl
19$:
    inc     hl
    inc     b
    srl     d
    jr      nz, 10$

    ; レジスタの復帰

    ; 終了
    ret

; エリアから出る
;
_EnemyExit::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; エネミーをクリアする
;
EnemyClear:

    ; レジスタの保存

    ; 初期値の設定
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 生存数のクリア
    xor     a
    ld      (enemyExist), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを登録する
;
_EnemyEntry::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix

    ; a  < エネミーの種類
    ; de < Y/X 位置
    ; c  < 向き
    ; iy > エントリ
    ; cf > 1 = 登録した

    ; エネミーの登録
    ld      ix, #_enemy
    ld      h, a
    ld      l, c
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 11$
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    or      a
    jr      19$
11$:
    push    hl
    push    de
    ld      a, h
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #enemyDefault
    add     hl, bc
    ld      a, (hl)
    inc     hl
    ld      h, (hl)
    ld      l, a
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     hl
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d
    ld      ENEMY_DIRECTION(ix), l
    call    _EnemyIsPath
    jr      nc, 12$
    res     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
12$:
    call    _EnemySetAttackRect
    call    _EnemySetDamageRect
    push    ix
    pop     iy
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 倒したエネミーの属性を取得する
;
_EnemyGetAttribute::

    ; レジスタの保存

    ; a > 倒したエネミーの属性

    ; 属性の取得
    ld      a, (enemyAttribute)

    ; レジスタの復帰

    ; 終了
    ret

;  生存しているエネミーの数を取得する
;
_EnemyGetExist::

    ; レジスタの保存

    ; a > エネミーの数

    ; 生存数の取得
    ld      a, (enemyExist)

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが死亡する
;
EnemyDead:

    ; レジスタの保存

    ; ix < エネミー

    ; 点滅の更新
    dec     ENEMY_BLINK(ix)
    jr      nz, 19$

    ; 倒したエネミーの属性の更新
    ld      hl, #(enemyAttribute)
    ld      a, ENEMY_ATTRIBUTE(ix)
    or      (hl)
    ld      (hl), a

    ; エネミーの削除
    ld      ENEMY_TYPE(ix), #ENEMY_TYPE_NULL

    ; グループの更新
    ld      c, a
    ld      a, (_game + GAME_AREA)
    call    _MazeGetEnemys
    ld      a, ENEMY_GROUP(ix)
    cpl
    and     (hl)
    ld      (hl), a

    ; アイテムを持っていたらプレイヤに追加
    ld      a, ENEMY_ITEM(ix)
    or      a
    call    nz, _PlayerAddItem

    ; エリア内のエネミーが全滅したら宝が出現
    ld      hl, #enemyExist
    dec     (hl)
    jr      nz, 10$
    call    _WallDigTreasure
    jr      nc, 10$
    ld      a, #SOUND_SE_DIG
    call    _SoundPlaySe
10$:

    ; BGM の再生
    bit     #ENEMY_FLAG_BOSS_BIT, ENEMY_FLAG(ix)
    ld      a, #SOUND_BGM_GAME
    call    nz, _SoundPlayBgm

    ; 死亡の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが潜る
;
EnemyDive:

    ; レジスタの保存

    ; ix < エネミー

    ; 潜行
    inc     ENEMY_DIVE(ix)
    ld      a, ENEMY_DIVE(ix)
    cp      #ENEMY_DIVE_SPEED
    jr      c, 19$
    ld      ENEMY_DIVE(ix), #0x00
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      z, 11$
    jr      nc, 10$
    dec     ENEMY_POSITION_X(ix)
    jr      11$
10$:
    inc     ENEMY_POSITION_X(ix)
;   jr      11$
11$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    jr      z, 13$
    jr      nc, 12$
    dec     ENEMY_POSITION_Y(ix)
    jr      13$
12$:
    inc     ENEMY_POSITION_Y(ix)
;   jr      13$
13$:
    call    _EnemyIsPath
    jr      nc, 19$
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallGetPattern
    cp      #(WALL_PATTERN_TOP | WALL_PATTERN_BOTTOM | WALL_PATTERN_LEFT | WALL_PATTERN_RIGHT)
    jr      z, 19$

    ; 潜行の完了
    call    _EnemySetStepDirectionForPlayer
    xor     a
    ld      ENEMY_STATE(ix), a
    res     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
19$:
    
    ; 攻撃の設定
    ld      a, #ENEMY_DIVE_ATTACK_RECT_R
    call    _EnemySetAttackRect

;   ; ダメージの設定
;   ld      a, #ENEMY_DIVE_DAMAGE_RECT_R
;   call    _EnemySetDamageRect

    ; アニメーションの更新
    ld      hl, #enemyDiveSprite
    call    _EnemyAnimateSprite
    inc     ENEMY_ANIMATION(ix)

    ; レジスタの復帰

    ; 終了
    ret

; 無条件で１歩移動する
;
_EnemyMove:

    ; レジスタの保存
    
    ; ix < エネミー

    ; 向いている方向に移動
    ld      a, ENEMY_DIRECTION(ix)
    dec     a
    jr      z, 11$
    dec     a
    jr      z, 12$
    dec     a
    jr      z, 13$
10$:
    dec     ENEMY_POSITION_Y(ix)
    jr      19$
11$:
    inc     ENEMY_POSITION_Y(ix)
    jr      19$
12$:
    dec     ENEMY_POSITION_X(ix)
    jr      19$
13$:
    inc     ENEMY_POSITION_X(ix)
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; １歩移動する
;
_EnemyStep:

    ; レジスタの保存
    
    ; ix < エネミー
    ; cf > 1 = 移動した

    ; 向いている方向に移動
    ld      a, ENEMY_DIRECTION(ix)
    call    _EnemyIsStep
    jr      nc, 19$
    ld      a, ENEMY_DIRECTION(ix)
    dec     a
    jr      z, 11$
    dec     a
    jr      z, 12$
    dec     a
    jr      z, 13$
10$:
    dec     ENEMY_POSITION_Y(ix)
    jr      18$
11$:
    inc     ENEMY_POSITION_Y(ix)
    jr      18$
12$:
    dec     ENEMY_POSITION_X(ix)
    jr      18$
13$:
    inc     ENEMY_POSITION_X(ix)
;   jr      18$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; １歩移動して突き当たりを判定する
;
_EnemyStepToEnd::

    ; レジスタの保存
    
    ; ix < エネミー
    ; cf > 1 = 突き当たった

    ; 向いている方向に移動
    call    _EnemyStep
    ccf

    ; レジスタの復帰

    ; 終了
    ret

; １歩移動して曲がり角を判定する
;
_EnemyStepToCorner::

    ; レジスタの保存
    push    de
    
    ; ix < エネミー
    ; cf > 1 = 曲がり角にあたった

    ; 向いている方向に移動
    call    _EnemyStep
    jr      nc, 18$
    call    _EnemyIsWayPoint
    jr      nc, 17$
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallGetPattern
    cpl
    bit     #0x01, ENEMY_DIRECTION(ix)
    jr      nz, 10$
    and     #(WALL_PATTERN_LEFT | WALL_PATTERN_RIGHT)
    jr      nz, 18$
    jr      17$
10$:
    and     #(WALL_PATTERN_TOP | WALL_PATTERN_BOTTOM)
    jr      nz, 18$
;   jr      17$
17$:
    or      a
    jr      19$
18$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 指定した方向へ移動できるかどうかを判定する
;
_EnemyIsStep:

    ; レジスタの保存
    push    bc
    push    de
    
    ; ix < エネミー
    ; a  < 方向
    ; cf > 1 = 移動可能

    ; 大きさの取得
    ld      c, ENEMY_DAMAGE_RECT_R(ix)
    ld      b, c
    inc     b

    ; 向いている方向に移動できるか
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    dec     a
    jr      z, 11$
    dec     a
    jr      z, 12$
    dec     a
    jr      z, 13$

    ; ↑へ移動
10$:
    ld      a, d
    sub     b
    jr      c, 18$
    ld      d, a
    call    _WallIsPath
    jr      nc, 18$
    jr      17$

    ; ↓へ移動
11$:
    ld      a, d
    add     a, c
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      nc, 18$
    ld      d, a
    ld      e, ENEMY_POSITION_X(ix)
    call    _WallIsPath
    jr      nc, 18$
    jr      17$

    ; ←へ移動
12$:
    ld      a, e
    sub     b
    jr      c, 18$
    ld      e, a
    call    _WallIsPath
    jr      nc, 18$
    jr      17$

    ; →へ移動
13$:
    ld      a, e
    add     a, c
    jr      c, 18$
    ld      e, a
    call    _WallIsPath
    jr      nc, 18$
;   jr      17$

    ; 移動の完了
17$:
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 通路にいるかどうかを判定する
;
_EnemyIsPath::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; cf > 1 = 通路

    ; 大きさの取得
    ld      c, ENEMY_DAMAGE_RECT_R(ix)
    ld      b, c
    dec     b

    ; 通路の判定
    ld      a, ENEMY_POSITION_X(ix)
    ld      e, a
    and     #(WALL_SIZE_PIXEL - 0x01)
    cp      #(WALL_SIZE_PIXEL / 2)
    jr      nz, 12$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     c
    jr      nc, 10$
    xor     a
10$:
    ld      d, a
    call    _WallIsPath
    jr      nc, 19$
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, b
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      c, 11$
    ld      a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - 0x01)
11$:
    ld      d, a
    call    _WallIsPath
    jr      19$
12$:
    ld      a, ENEMY_POSITION_Y(ix)
    ld      d, a
    and     #(WALL_SIZE_PIXEL - 0x01)
    cp      #(WALL_SIZE_PIXEL / 2)
    jr      nz, 18$
    ld      a, ENEMY_POSITION_X(ix)
    sub     c
    jr      nc, 13$
    xor     a
13$:
    ld      e, a
    call    _WallIsPath
    jr      nc, 19$
    ld      a, ENEMY_POSITION_X(ix)
    add     a, b
    jr      nc, 14$
    ld      a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - 0x01)
14$:
    ld      e, a
    call    _WallIsPath
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 通過点かどうかを判定する
;
_EnemyIsWayPoint::

    ; レジスタの保存

    ; ix < エネミー
    ; cf > 1 = 通過点

    ; 位置の判定
    ld      a, ENEMY_POSITION_X(ix)
    and     #(WALL_SIZE_PIXEL - 0x01)
    cp      #(WALL_SIZE_PIXEL / 2)
    jr      nz, 10$
    ld      a, ENEMY_POSITION_Y(ix)
    and     #(WALL_SIZE_PIXEL - 0x01)
    cp      #(WALL_SIZE_PIXEL / 2)
    jr      nz, 10$
    scf
    jr      19$
10$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのいる方向を向く
;
_EnemySetDirectionForPlayer::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー

    ; 向きの設定
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 10$
    neg
10$:
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 11$
    neg
11$:
    ld      d, a
    or      e
    jr      z, 19$
    ld      a, e
    cp      d
    jr      c, 12$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      b, #ENEMY_DIRECTION_LEFT
    jr      c, 13$
    ld      b, #ENEMY_DIRECTION_RIGHT
    jr      13$
12$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      b, #ENEMY_DIRECTION_UP
    jr      c, 13$
    ld      b, #ENEMY_DIRECTION_DOWN
;   jr      13$
13$:
    ld      ENEMY_DIRECTION(ix), b
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; 移動可能なプレイヤのいる方向を向く（潜行なし）
;
_EnemySetStepDirectionForPlayer::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < エネミー

    ; パターンの取得
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallGetPattern
    ld      c, a

    ; 今いる位置に合わせて設定
    ld      a, e
    and     #(WALL_SIZE_PIXEL - 0x01)
    cp      #(WALL_SIZE_PIXEL / 2)
    jp      nz, 120$
    ld      a, d
    and     #(WALL_SIZE_PIXEL - 0x01)
    cp      #(WALL_SIZE_PIXEL / 2)
    jp      nz, 110$

    ; 中心位置での方向の取得
100$:
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 101$
    neg
101$:
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 102$
    neg
102$:
    ld      d, a
    or      e
    jp      z, 130$
    ld      a, e
    cp      d
    jr      c, 105$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      b, #ENEMY_DIRECTION_LEFT
    jr      c, 103$
    ld      b, #ENEMY_DIRECTION_RIGHT
103$:
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jp      z, 180$
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      b, #ENEMY_DIRECTION_UP
    jr      c, 104$
    ld      b, #ENEMY_DIRECTION_DOWN
104$:
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jp      z, 180$
    jp      130$
105$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      b, #ENEMY_DIRECTION_UP
    jr      c, 106$
    ld      b, #ENEMY_DIRECTION_DOWN
106$:
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 180$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      d, #ENEMY_DIRECTION_LEFT
    jr      c, 107$
    ld      d, #ENEMY_DIRECTION_RIGHT
107$:
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 180$
    jr      130$

    ; X 軸があっている位置での方向の取得
110$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    jr      nc, 111$
    ld      b, #ENEMY_DIRECTION_UP
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 180$
    ld      b, #ENEMY_DIRECTION_DOWN
    jr      180$
111$:
    ld      b, #ENEMY_DIRECTION_DOWN
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 180$
    ld      b, #ENEMY_DIRECTION_UP
    jr      180$

    ; Y 軸があっている位置での方向の取得
120$:
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    jr      nc, 121$
    ld      b, #ENEMY_DIRECTION_LEFT
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 180$
    ld      b, #ENEMY_DIRECTION_RIGHT
    jr      180$
121$:
    ld      b, #ENEMY_DIRECTION_RIGHT
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 180$
    ld      b, #ENEMY_DIRECTION_LEFT
    jr      180$

    ; 動ける方向に動く
130$:
    call    _EnemySetRandomDirection
    jr      190$

    ; 向きの設定
180$:
    ld      ENEMY_DIRECTION(ix), b
;   jr      190$

    ; 向きの設定の完了
190$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 移動可能なプレイヤのいる方向を向く（潜行あり）
;
_EnemySetDiveDirectionForPlayer::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < エネミー

    ; パターンの取得
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallGetPattern
    ld      c, a

    ; 向きの設定
    ld      a, (_player + PLAYER_POSITION_X)
    sub     ENEMY_POSITION_X(ix)
    jr      nc, 10$
    neg
10$:
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 11$
    neg
11$:
    ld      d, a
    or      e
    jr      z, 14$
    ld      a, e
    cp      d
    jr      c, 12$
    ld      a, (_player + PLAYER_POSITION_X)
    cp      ENEMY_POSITION_X(ix)
    ld      b, #ENEMY_DIRECTION_LEFT
    jr      c, 13$
    ld      b, #ENEMY_DIRECTION_RIGHT
    jr      13$
12$:
    ld      a, (_player + PLAYER_POSITION_Y)
    cp      ENEMY_POSITION_Y(ix)
    ld      b, #ENEMY_DIRECTION_UP
    jr      c, 13$
    ld      b, #ENEMY_DIRECTION_DOWN
;   jr      13$
13$:
    ld      ENEMY_DIRECTION(ix), b
    ld      e, b
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      a, (hl)
    and     c
    jr      z, 19$
    set     #ENEMY_FLAG_DIVE_BIT, ENEMY_FLAG(ix)
    jr      19$
14$:
    call    _EnemySetRandomDirection
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; ランダムな方向を向く
;
_EnemySetRandomDirection::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < エネミー

    ; パターンの取得
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    call    _WallGetPattern
    ld      c, a

    ; 向きの設定
    call    _SystemGetRandom
    rlca
    add     a, ENEMY_DIRECTION(ix)
    and     #0x03
    ld      b, #0x04
10$:
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDirectionPattern
    add     hl, de
    ld      d, a
    ld      a, (hl)
    and     c
    ld      a, d
    jr      nz, 11$
    ld      ENEMY_DIRECTION(ix), a
    jr      19$
11$:
    inc     a
    and     #0x03
    djnz    10$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 攻撃範囲を設定する
;
_EnemySetAttackRect::

    ; レジスタの保存
    push    bc

    ; ix < エネミー

    ; 範囲の設定
    ld      b, ENEMY_ATTACK_RECT_R(ix)
    ld      a, ENEMY_POSITION_X(ix)
    sub     b
    jr      nc, 10$
    xor     a
10$:
    ld      ENEMY_ATTACK_RECT_LEFT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     b
    jr      nc, 11$
    xor     a
11$:
    ld      ENEMY_ATTACK_RECT_TOP(ix), a
    dec     b
    ld      a, ENEMY_POSITION_X(ix)
    add     a, b
    jr      nc, 12$
    ld      a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - 0x01)
12$:
    ld      ENEMY_ATTACK_RECT_RIGHT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, b
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      c, 13$
    ld      a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - 0x01)
13$:
    ld      ENEMY_ATTACK_RECT_BOTTOM(ix), a

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; ダメージ範囲を設定する
;
_EnemySetDamageRect::

    ; レジスタの保存
    push    bc

    ; ix < エネミー

    ; 範囲の設定
    ld      b, ENEMY_DAMAGE_RECT_R(ix)
    ld      a, ENEMY_POSITION_X(ix)
    sub     b
    jr      nc, 10$
    xor     a
10$:
    ld      ENEMY_DAMAGE_RECT_LEFT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    sub     b
    jr      nc, 11$
    xor     a
11$:
    ld      ENEMY_DAMAGE_RECT_TOP(ix), a
    dec     b
    ld      a, ENEMY_POSITION_X(ix)
    add     a, b
    jr      nc, 12$
    ld      a, #(WALL_VIEW_SIZE_X * WALL_SIZE_PIXEL - 0x01)
12$:
    ld      ENEMY_DAMAGE_RECT_RIGHT(ix), a
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, b
    cp      #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL)
    jr      c, 13$
    ld      a, #(WALL_VIEW_SIZE_Y * WALL_SIZE_PIXEL - 0x01)
13$:
    ld      ENEMY_DAMAGE_RECT_BOTTOM(ix), a

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; エネミーのスプライトをアニメーションさせる
;
_EnemyAnimateSprite::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < エネミー
    ; hl < スプライト

    ; スプライトの設定
    bit     #ENEMY_FLAG_2x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 10$
    ld      a, ENEMY_ANIMATION(ix)
    and     #ENEMY_ANIMATION_CYCLE
    rrca
    ld      e, a
    ld      d, #0x00
    add     hl, de
    jr      19$
10$:
    ld      a, ENEMY_ANIMATION(ix)
    and     #ENEMY_ANIMATION_CYCLE
    rlca
    ld      e, a
    ld      d, #0x00
    add     hl, de
;   jr      19$
19$:
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
enemyProc:
    
    .dw     _EnemyNull
    .dw     _EnemyGhoul
    .dw     _EnemyGoblin
    .dw     _EnemyBat
    .dw     _EnemySpider
    .dw     _EnemyGhost
    .dw     _EnemyMage
    .dw     _EnemyReaper
    .dw     _EnemyGolem
    .dw     _EnemyDragonGreen
    .dw     _EnemyDragonBlue
    .dw     _EnemyDragonRed
    .dw     _EnemyShadow
    .dw     _EnemyBolt
    .dw     _EnemyBall
    .dw     _EnemyFire

; エネミーの初期値
;
enemyDefault:

    .dw     _enemyNullDefault
    .dw     _enemyGhoulDefault
    .dw     _enemyGoblinDefault
    .dw     _enemyBatDefault
    .dw     _enemySpiderDefault
    .dw     _enemyGhostDefault
    .dw     _enemyMageDefault
    .dw     _enemyReaperDefault
    .dw     _enemyGolemDefault
    .dw     _enemyDragonGreenDefault
    .dw     _enemyDragonBlueDefault
    .dw     _enemyDragonRedDefault
    .dw     _enemyShadowDefault
    .dw     _enemyBoltDefault
    .dw     _enemyBallDefault
    .dw     _enemyFireDefault

; グループ
;
enemyGroup:

    ; ザコ
    .db     ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_BAT,    ENEMY_TYPE_BAT,    ENEMY_TYPE_BAT,    ENEMY_TYPE_BAT
    .db     ENEMY_TYPE_GHOUL,  ENEMY_TYPE_GHOUL,  ENEMY_TYPE_GHOUL,  ENEMY_TYPE_GHOUL,  ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_SPIDER, ENEMY_TYPE_SPIDER, ENEMY_TYPE_GHOUL,  ENEMY_TYPE_BAT,    ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_GOBLIN, ENEMY_TYPE_GOBLIN, ENEMY_TYPE_GOBLIN, ENEMY_TYPE_SPIDER, ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_GOBLIN, ENEMY_TYPE_GOBLIN, ENEMY_TYPE_SPIDER, ENEMY_TYPE_BAT,    ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_GHOST,  ENEMY_TYPE_GHOST,  ENEMY_TYPE_GOBLIN, ENEMY_TYPE_SPIDER, ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_MAGE,   ENEMY_TYPE_MAGE,   ENEMY_TYPE_MAGE,   ENEMY_TYPE_MAGE,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_REAPER, ENEMY_TYPE_GHOST,  ENEMY_TYPE_GHOUL,  ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_REAPER, ENEMY_TYPE_REAPER, ENEMY_TYPE_MAGE,   ENEMY_TYPE_GHOST,  ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_GOLEM,  ENEMY_TYPE_GOLEM,  ENEMY_TYPE_REAPER, ENEMY_TYPE_GHOST,  ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_GOLEM,  ENEMY_TYPE_GOLEM,  ENEMY_TYPE_REAPER, ENEMY_TYPE_MAGE,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL,   ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_GOLEM,  ENEMY_TYPE_REAPER, ENEMY_TYPE_MAGE,   ENEMY_TYPE_GHOST,  ENEMY_TYPE_SPIDER, ENEMY_TYPE_GOBLIN, ENEMY_TYPE_GHOUL,  ENEMY_TYPE_BAT
    ; ボス
    .db     ENEMY_TYPE_DRAGON_GREEN, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_DRAGON_BLUE,  ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_DRAGON_RED,   ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL
    .db     ENEMY_TYPE_SHADOW,       ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL, ENEMY_TYPE_NULL

; 潜行
;
enemyDiveSprite:

    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_DARK_YELLOW
    .db     -0x08 - 0x01, -0x08, 0x41, VDP_COLOR_LIGHT_YELLOW

; 向き
;
enemyDirectionPattern:

    .db     WALL_PATTERN_TOP, WALL_PATTERN_BOTTOM, WALL_PATTERN_LEFT, WALL_PATTERN_RIGHT


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; 倒したエネミーの属性
;
enemyAttribute:

    .ds     0x01

; 生存しているエネミーの数
;
enemyExist:

    .ds     0x01

; スプライト
;
enemySprite:

    .ds     0x01
