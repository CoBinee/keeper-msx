; Sound.inc : サウンド
;


; マクロの定義
;

; BGM
SOUND_BGM_NULL                  =   0x00
SOUND_BGM_TITLE                 =   0x01
SOUND_BGM_GAME                  =   0x02
SOUND_BGM_DRAGON                =   0x03
SOUND_BGM_BOSS                  =   0x04
SOUND_BGM_OPEN                  =   0x05
SOUND_BGM_MISS                  =   0x06
SOUND_BGM_OVER                  =   0x07
SOUND_BGM_EXIT                  =   0x08
SOUND_BGM_CLEAR                 =   0x09

; SE
SOUND_SE_NULL                   =   0x00
SOUND_SE_BOOT                   =   0x01
SOUND_SE_CLICK                  =   0x02
SOUND_SE_FADE                   =   0x03
SOUND_SE_SWORD_OPEN             =   0x04
SOUND_SE_SWORD_CLOSE            =   0x05
SOUND_SE_SHIELD                 =   0x06
SOUND_SE_DAMAGE                 =   0x07
SOUND_SE_DIG                    =   0x08
SOUND_SE_CRYSTAL                =   0x09
SOUND_SE_TREASURE               =   0x0a
SOUND_SE_CAST                   =   0x0b
SOUND_SE_FIRE                   =   0x0c

; 外部関数宣言
;

    .globl  _SoundPlayBgm
    .globl  _SoundPlaySe
    .globl  _SoundStop
    .globl  _SoundIsPlayBgm
    .globl  _SoundIsPlaySe

; 外部変数宣言
;
