; Item.inc : アイテム
;


; マクロの定義
;

; アイテム
ITEM_NULL                       =   0x00
ITEM_SWORD                      =   0x01
ITEM_HELMET                     =   0x02
ITEM_ARMOR                      =   0x03
ITEM_SHIELD                     =   0x04
ITEM_BOOTS                      =   0x05
ITEM_COMPASS                    =   0x06
ITEM_CANDLE                     =   0x07
ITEM_RING                       =   0x08
ITEM_NECKLACE                   =   0x09
ITEM_ROD                        =   0x0a
ITEM_CRYSTAL                    =   0x10
ITEM_CURSE                      =   0xff

; ソード
ITEM_SWORD_PATTERN_NAME         =   0xe0

; ヘルメット
ITEM_HELMET_PATTERN_NAME        =   0xa0

; アーマー
ITEM_ARMOR_PATTERN_NAME         =   0xa8

; シールド
ITEM_SHIELD_PATTERN_NAME        =   0xb0

; ブーツ
ITEM_BOOTS_PATTERN_NAME         =   0xb8

; コンパス
ITEM_COMPASS_PATTERN_NAME       =   0xf0

; キャンドル
ITEM_CANDLE_PATTERN_NAME        =   0xd8

; リング
ITEM_RING_PATTERN_NAME          =   0xc0

; ネックレス
ITEM_NECKLACE_PATTERN_NAME      =   0xc8

; ロッド
ITEM_ROD_PATTERN_NAME           =   0xd0

; クリスタル
ITEM_CRYSTAL_RED_PATTERN_NAME   =   0xc4
ITEM_CRYSTAL_GREEN_PATTERN_NAME =   0xcc
ITEM_CRYSTAL_BLUE_PATTERN_NAME  =   0xd4

; 呪い
ITEM_CURSE_FRAME                =   0x60

; 外部関数宣言
;

    .globl  _ItemInitialize
    .globl  _ItemUpdate
    .globl  _ItemRender

; 外部変数宣言
;

;   .globl  _item
