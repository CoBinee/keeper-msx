; Item.s : アイテム
;


; モジュール宣言
;
    .module Item

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Game.inc"
    .include	"Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; アイテムを初期化する
;
_ItemInitialize::
    
    ; レジスタの保存
    
;   ; アイテムの初期化
;   ld      hl, #itemDefault
;   ld      de, #_item
;   ld      bc, #ITEM_LENGTH
;   ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; アイテムを更新する
;
_ItemUpdate::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; アイテムを描画する
;
_ItemRender::

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

;　アイテムの初期値
;
; itemDefault:


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; アイテム
;
; _item::
    
