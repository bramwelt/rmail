#lang racket/base
(require ffi/unsafe
         ffi/unsafe/define)
 
(define-ffi-definer define-curses (ffi-lib "libncurses" '("5" #f)))

(define _WINDOW-pointer (_cpointer 'WINDOW))
 
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
 
;
; To get character-at-a-time input without echoing (most
; interactive, screen oriented programs want this), the following
; sequence should be used:
;
;   initscr(); cbreak(); noecho();
;
; Most programs would additionally use the sequence:
;
;   nonl();
;   intrflush(stdscr, FALSE);
;   keypad(stdscr, TRUE);


(define-curses initscr (_fun -> _WINDOW-pointer))
(define-curses waddstr (_fun _WINDOW-pointer _string -> (r : _int)
                                                     -> (check r 'waddstr)))
(define-curses wrefresh (_fun _WINDOW-pointer -> (r : _int)
                                              -> (check r 'wrefresh)))
(define-curses wgetch (_fun _WINDOW-pointer ->  _int))
(define-curses endwin (_fun -> (r : _int)
                            -> (check r 'endwin)))

(define-curses cbreak (_fun -> (r : _int)
                             -> (check r 'cbreak)))
(define-curses noecho (_fun -> (r : _int)
                            -> (check r 'noecho)))
(define-curses echo (_fun -> (r : _int)
                          -> (check r 'echo)))


(define win (initscr))

(void (cbreak))
(void (noecho))
(void (waddstr win "Hello\n"))

(define (next-input win)
  (let ([c (integer->char (wgetch win))])
    (cond
        [(char=? c #\q) (void (endwin)) (exit)]
        [else (void (waddstr win (string c)))])
    (void (wrefresh win))
    (next-input win)))

(next-input win)

; (sleep 1)
; (void (endwin))
