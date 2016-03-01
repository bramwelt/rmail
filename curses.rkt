#lang racket/base

(require "lib/curses.rkt")
(require "mail.rkt")

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

;; Bounded cursor rows
(define (inc-row! row)
  (cond
    [(>= row 10) 10]
    [else (+ row 1)]))

(define (dec-row! row)
  (cond
    [(<= row 1) 1]
    [else (- row 1)]))
;


(define win (initscr))
(define list-item 1)

(void (cbreak))
(void (noecho))
(void (waddstr win "Hello\n"))

(define (next-input win list-item)
  (let ([c (integer->char (wgetch win))])
    (cond
        [(char=? c #\q) (void (endwin)) (exit)]
        [(char=? c #\k) (set! list-item (inc-row! list-item))]
        [(char=? c #\j) (set! list-item (dec-row! list-item))]
        [(char=? c #\p) (waddstr win (number->string list-item))]
        [else (void (waddstr win (string c)))])
    (void (wrefresh win))
    (next-input win list-item)))

(next-input win list-item)

; (sleep 1)
; (void (endwin))
