; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmTitle_A, soundBgmTitle_B, soundBgmTitle_C
    .dw     soundBgmGame_A, soundBgmGame_B, soundBgmGame_C
    .dw     soundBgmDragon_A, soundBgmDragon_B, soundBgmDragon_C
    .dw     soundBgmBoss_A, soundBgmBoss_B, soundBgmBoss_C
    .dw     soundBgmOpen_A, soundBgmOpen_B, soundNull
    .dw     soundBgmMiss_A, soundNull, soundNull
    .dw     soundBgmOver_A, soundBgmOver_B, soundBgmOver_C
    .dw     soundBgmExit_A, soundBgmExit_B, soundBgmExit_C
    .dw     soundBgmClear_A, soundBgmClear_B, soundBgmClear_C

; タイトル
soundBgmTitle_A:

    .ascii  "T4@*@16V15,6L8"
    .ascii  "O5EO4BFEABO5CD"
    .ascii  "O5EDCO4BABO5CO4B"
    .ascii  "O4A9R"
    .db     0xff

soundBgmTitle_B:

    .ascii  "T4@16V15,6L8"
    .ascii  "O4EDCDEDCD"
    .ascii  "O4EDCDEDCD"
    .ascii  "O4C9R"
    .db     0xff

soundBgmTitle_C:

    .ascii  "T4@16V15,6L8"
    .ascii  "O3AGFEAGFE"
    .ascii  "O3AGFEAGFE"
    .ascii  "O3F9R"
    .db     0xff

; ゲーム
soundBgmGame_A:

    .ascii  "T6@3V15,4L5"
    .ascii  "O2GGGG3A3O2GGGG3A3"
    .ascii  "O2GGGG3A3O2GGGG3A3O2GGGG3A3O2GGGG3A3"
    .ascii  "O2GGGG3A3O2GGGG3A3O2GGGG3A3O2GGGG3A3"
    .db     0xff

soundBgmGame_B:

    .ascii  "T6@12V15,8L9"
    .ascii  "RR"
    .ascii  "O5DEFE"
    .ascii  "O5DEFE"
    .db     0xff

soundBgmGame_C:

    .ascii  "T6@12V15,8L9"
    .ascii  "RR"
    .ascii  "O4GAB-A"
    .ascii  "O4GAB-A"
    .db     0xff

; ドラゴン
soundBgmDragon_A:

    .ascii  "T3@1V15,5"
    .ascii  "L5O4FAG+B3F6AG+B3F6AG+B3F6AG+B"
    .ascii  "L5O4FAG+B3F6AG+B3F6AG+B3F6AG+B3F3"
    .ascii  "L5O4G-B-A-B-3G-6B-A-B-G-3B-3B-3B-A-3B-G-3G-A-A-3G-"
    .ascii  "L5O4A3G+A3G+A3G+A3G+A3G+A3G+A3G+A3G+A3G+A3G+A3G+3"
    .db     0xff

soundBgmDragon_B:

    .ascii  "T3@1V15,5"
    .ascii  "L5O4CE-DF+3C6E-DF+3C6E-DF+3C6E-DF+"
    .ascii  "L5O4CE-DF+3C6E-DF+3C6E-DF+3C6E-DF+3C3"
    .ascii  "L5O4D-D-D-D-3C6D-D-CD-3D-3D-3D-D-3D-C3CCC3C"
    .ascii  "L5O4F3G+F3G+F3G+F3G+F3G+F3G+F3G+F3G+F3G+F3G+F3G+3"
    .db     0xff

soundBgmDragon_C:

    .ascii  "T3@2V15,8"
    .ascii  "L9O3F8R3FFF8R3G-5"
    .ascii  "L9O3D8R3DDDR3"
    .ascii  "L9O3E-8R3E-R3E-E-"
    .ascii  "L9O3EO2D+O3F+G"
    .db     0xff

; ボス
soundBgmBoss_A:

    .ascii  "T3@5V15,3"
    .ascii  "L3O3AAAAAAAAO4F+F+F+F+F+F+F+F+FFFFFFFFAAAAAAAA"
    .ascii  "L3O5EO4AAAAAAA"
    .ascii  "L3O3AAAAAAAAO4F+F+F+F+F+F+F+F+FFFFFFFFAAAAAAAA"
    .ascii  "L3O3AO4F+5A5F+O3AO4F+5A5F+O3AO4F+5A5F+"
    .ascii  "L3O5EO4AAAAAAA"
    .db     0xff

soundBgmBoss_B:

    .ascii  "T3@5V15,3"
    .ascii  "L3O3EEEEEEEEAAAAAAAAG+G+G+G+G+G+G+G+O4C+C+C+C+C+C+C+C+"
    .ascii  "L3O4AAAAAAAA"
    .ascii  "L3O3EEEEEEEEAAAAAAAAG+G+G+G+G+G+G+G+O4C+C+C+C+C+C+C+C+"
    .ascii  "L3O3EA5O4C5O3AO3EA5O4C5O3AO3EA5O4C5O3A"
    .ascii  "L3O4AAAAAAAA"
    .db     0xff

soundBgmBoss_C:

    .ascii  "T3@2V15,3"
    .ascii  "L6O3CC7R3CC7R3O2BB7R3BB7R3"
    .ascii  "L3O3EO2A8R"
    .ascii  "L6O3CC7R3CC7R3O2BB7R3BB7R3"
    .ascii  "L3O2AA5A5AO2AA5A5AO2AA5A5A"
    .ascii  "L3O3EO2A8R"
    .db     0xff

; オープン
soundBgmOpen_A:

    .ascii  "T5@2V15,3L1"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4D+EF+BF+ED+O3B"
    .ascii  "O4DEF+BF+EDO3B"
    .ascii  "O4DEF+BF+EDO3B"
    .ascii  "O4DEF+BF+EDO3B"
    .ascii  "O4DEF+BF+EDO3B"
    .ascii  "O4DEF+BF+EDO3B"
    .ascii  "O4DEF+BF+EDO3B"
    .ascii  "O4DEF+BF+EDO3B"
    .db     0xff

soundBgmOpen_B:

    .ascii  "T5@2V15,3L1"
    .ascii  "O2BBBO3F+F+F+BB"
    .ascii  "O3BO4F+F+F+O3BB"
    .ascii  "O4F+F+O2BBBO3F+F+F+BB"
    .ascii  "O3F+F+O2BBAAAO3E"
    .ascii  "O3EEAAAO4EEE"
    .ascii  "O3AAEEO2AAAO3E"
    .ascii  "O3EEAAEEO2AA"
    .ascii  "O2GGGO3DDDGG"
    .ascii  "O3GO4DDDO3GGDD"
    .ascii  "O2GGGO3DDDGG"
    .ascii  "O3DDO2GGF+F+F+O3C+"
    .ascii  "O3C+C+F+F+F+O4C+C+C+"
    .ascii  "O3F+F+C+C+O2F+F+F+O3C+"
    .ascii  "O3C+C+F+F+C+C+O2F+F+"
    .db     0xff

; ミス
soundBgmMiss_A:

    .ascii  "T1@0V15L1O5CO4BA+BR0G-FEFR0AA-GA-RE-DC+DR0FED+FR0CO3BA+O4CR0"
    .db     0x00

; ゲームオーバー
soundBgmOver_A:

    .ascii  "T4@14V15,9L9"
    .ascii  "O4ADDR"
    .db     0x00

soundBgmOver_B:

    .ascii  "T4@14V15,9L9"
    .ascii  "O4DO3BBR"
    .db     0x00

soundBgmOver_C:

    .ascii  "T4@14V15,9L9"
    .ascii  "O3GDO2AR"
    .db     0x00

; 出口
soundBgmExit_A:

    .ascii  "T1@0V15,3"
    .ascii  "L0O3DEF+L1CDEF+L2CDEF+G+A+L3O4CL5C"
    .db     0x00

soundBgmExit_B:

    .ascii  "T1@0V15,3"
    .ascii  "L0O3DECDEF+L1CDEF+G+L2CDEF+G+A+L3O4CL4C"
    .db     0x00

soundBgmExit_C:

    .ascii  "T1@0V15,3"
    .ascii  "L0O3CDCDECDEF+L1CDEF+G+L2CDEF+G+A+L3O4CL3C"
    .db     0x00

; クリア
soundBgmClear_A:

    .ascii  "T1@12V15,8"
    .ascii  "L5O4B7O5EG+9REO4BO5EO6C+O5B9R7R8R8"
    .db     0x00

soundBgmClear_B:

    .ascii  "T1@12V15,8"
    .ascii  "L5R3O4B7O5EG+9R3G+3EO4BO5EO6C+O5B9R3RR8R8"
    .db     0x00

soundBgmClear_C:

    .ascii  "T1@12V15,8"
    .ascii  "L5RO4B7O5EG+9REO4BO5EO6C+O5B9RR8R8"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeFade
    .dw     soundSeSwordOpen
    .dw     soundSeSwordClose
    .dw     soundSeShield
    .dw     soundSeDamage
    .dw     soundSeDig
    .dw     soundSeCrystal
    .dw     soundSeTreasure
    .dw     soundSeCast
    .dw     soundSeFire

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; フェード
soundSeFade:

    .ascii  "T2@0V16S4M5N7X5X5"
    .db     0x00

; 剣を抜く
soundSeSwordOpen:

    .ascii  "T1@0V13L0O3GG+ARL1O4EFG+AL0O5CD+"
    .db     0x00

; 剣をしまう
soundSeSwordClose:

    .ascii  "T1@0V13L0O5DC+O4BAGFECO3A-"
    .db     0x00

; シールド
soundSeShield:

    .ascii  "T1@0V13L0O6D-CV12D-CV11D-CV10D-C"
    .db     0x00

; ダメージ
soundSeDamage:

    .ascii  "T1@0V13L0O5DC+"
    .db     0x00

; 掘る
soundSeDig:

    .ascii  "T1@0V13L1O3EFG-FE"
    .db     0x00

; クリスタルを拾う
soundSeCrystal:

    .ascii  "T1@0V13O5B3O6E3"
    .db     0x00

; 宝を拾う
soundSeTreasure:

    .ascii  "T1@0V13L6O5ED3E"
    .db     0x00

; 呪文を唱える
soundSeCast:

    .ascii  "T1@0V13L0O4BB-AA+V12BB-AA+V11BB-AA+V10BB-AA+"
    .db     0x00

; 炎を吐く
soundSeFire:

    .ascii  "T1@0V13L0O3BA"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
