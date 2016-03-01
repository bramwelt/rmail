#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

(provide (all-defined-out))

(define-ffi-definer define-curses (ffi-lib "libncurses" '("5" #f)))

; Most programs would additionally use the sequence:
;
;   nonl();
;   intrflush(stdscr, FALSE);
;   keypad(stdscr, TRUE);

;
; Ncurses Failure Check
;
; Most Ncurses functions will return an integer error code. If the
; integer is non-zero an error has occured. For function that take
; multiple arguments (window, pad, coordinates, etc) this integer can
; represent an error in any of the arguments.
(define (check v who)
    (unless (zero? v)
          (error who "failed: ~a" v)))


(define _WINDOW-pointer (_cpointer 'WINDOW))

(define-curses initscr (_fun -> _WINDOW-pointer))

(define-curses cbreak (_fun -> (r : _int)
                             -> (check r 'cbreak)))

(define-curses noecho (_fun -> (r : _int)
                            -> (check r 'noecho)))

(define-curses echo (_fun -> (r : _int)
                          -> (check r 'echo)))

; Window Functions
(define-curses waddstr (_fun _WINDOW-pointer _string -> (r : _int)
                                                     -> (check r 'waddstr)))

(define-curses wrefresh (_fun _WINDOW-pointer -> (r : _int)
                                              -> (check r 'wrefresh)))

(define-curses wgetch (_fun _WINDOW-pointer ->  _int))

(define-curses endwin (_fun -> (r : _int)
                            -> (check r 'endwin)))
