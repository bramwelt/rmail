#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

(provide (all-defined-out))

(define lib-curses (ffi-lib "libncurses" '("5" #f)))
(define-ffi-definer define-curses lib-curses)

;
; Ncurses Failure Check
;
; Most Ncurses functions will return an integer error code. If the
; integer is non-zero an error has occured. For function that take
; multiple arguments (window, pad, coordinates, etc) this integer can
; represent an error in any of the arguments.
(define (check v who)
    (unless (zero? v)
          (endwin)
          (error who "failed: ~a" v)))

; ncurses.h C Defines
(define COLOR_BLACK 0)
(define COLOR_RED 1)
(define COLOR_GREEN 2)
(define COLOR_YELLOW 3)
(define COLOR_BLUE 4)
(define COLOR_MAGENTA 5)
(define COLOR_CYAN 6)
(define COLOR_WHITE 7)

(define A_NORMAL 0)
(define A_ATTRIBUTES -256)
(define A_CHARTEXT 255)
(define A_COLOR 65280)
(define A_STANDOUT 65536)
(define A_UNDERLINE 131072)
(define A_REVERSE 262144)
(define A_BLINK 524288)
(define A_DIM 1048576)
(define A_BOLD 2097152)
(define A_ALTCHARSET 4194304)
(define A_INVIS 8388608)
(define A_PROTECT 16777216)
(define A_HORIZONTAL 33554432)
(define A_LEFT 67108864)
(define A_LOW 134217728)
(define A_RIGHT 268435456)
(define A_TOP 536870912)
(define A_VERTICAL 1073741824)

(define _WINDOW-pointer (_cpointer 'WINDOW))
(define _chtype _ulong)
(define _attr _chtype)

(define-curses initscr (_fun -> _WINDOW-pointer))

(define-curses cbreak (_fun -> (r : _int)
                             -> (check r 'cbreak)))

(define-curses scrollok (_fun _WINDOW-pointer _bool -> (r : _int)
                                                    -> (check r 'scrollok)))

(define-curses scroll (_fun _WINDOW-pointer -> (r : _int)
                                            -> (check r 'scroll)))

(define-curses scrl (_fun _int -> (r : _int)
                               -> (check r 'scrl)))

(define-curses noecho (_fun -> (r : _int)
                            -> (check r 'noecho)))

(define-curses echo (_fun -> (r : _int)
                          -> (check r 'echo)))

(define-curses start_color (_fun -> (r : _int)
                                 -> (check r 'start_color)))

(define-curses init_pair (_fun _short _short _short -> (r : _int)
                                                    -> (check r 'init_pair)))

(define-curses COLOR_PAIR (_fun _int ->  _int))

(define-curses curs_set (_fun _int -> _int))

; Window Functions
(define-curses waddstr (_fun _WINDOW-pointer _string -> (r : _int)
                                                     -> (check r 'waddstr)))

(define-curses mvwaddstr (_fun _WINDOW-pointer _int _int _string -> (r : _int)
                                                                 -> (check r 'mvwaddstr)))

(define-curses mvwchgat (_fun _WINDOW-pointer
                              (y : _int)
                              (x : _int)
                              (n : _int)
                              (attr : _attr)
                              (color : _short) -> (r : _int)
                                               -> (check r 'mvwchgat)))

(define-curses wchgat (_fun _WINDOW-pointer
                            (n : _int)
                            (attr : _attr)
                            (color : _short) -> (r : _int)
                                             -> (check r 'mvwchgat)))

(define-curses wscrl (_fun _WINDOW-pointer _int -> (r : _int)
                                                -> (check r 'wscrl)))

(define-curses waddnstr (_fun _WINDOW-pointer _string _int -> (r : _int)
                                                           -> (check r 'waddnstr)))

(define-curses wrefresh (_fun _WINDOW-pointer -> (r : _int)
                                              -> (check r 'wrefresh)))

(define-curses wgetch (_fun _WINDOW-pointer ->  _int))

(define-curses wmove (_fun _WINDOW-pointer _int _int -> _int))

(define-curses wattron (_fun _WINDOW-pointer _int -> (r : _int)
                                                  -> (check r 'wattron)))

(define-curses wattroff (_fun _WINDOW-pointer _int -> (r : _int)
                                                   -> (check r 'wattroff)))
(define-curses wborder (_fun _WINDOW-pointer
                             _chtype
                             _chtype
                             _chtype
                             _chtype
                             _chtype
                             _chtype
                             _chtype
                             _chtype  -> (r : _int)
                                      -> (check r 'wborder)))

(define-curses endwin (_fun -> (r : _int)
                            -> (check r 'endwin)))
