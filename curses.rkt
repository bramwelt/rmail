#lang racket

(require "lib/curses.rkt")
(require "mail.rkt")

(define (display-message-list imap win)
    (let ([imap-connection (rmail-connection imap)]
          [total-messages (rmail-total-messages imap)])
      (for ([header (headers imap-connection total-messages)] [i (in-range total-messages)])
           (waddstr win (number->string (+ 1 i)))
           (waddstr win " - ")
           (waddstr win (get-subject (second header)))
           (waddstr win "\n"))))

; Command Line Arguments
;
(command-line
  #:program "rmail"
  #:once-each
  [("-s" "--server") imap-server
                    "IMAP Server"
                    (server imap-server)]
  #:args (imap-username imap-password)
  (username imap-username)
  (password imap-password))

(define list-item 1 )
(define list-max 10)

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
    [(>= row list-max) list-max]
    [else (+ row 1)]))

(define (dec-row! row)
  (cond
    [(<= row 1) 1]
    [else (- row 1)]))

(define win (initscr))

(void (cbreak))
(void (noecho))
(void (start_color))

(define (next-input win list-item)
  (let ([c (integer->char (wgetch win))])
    (cond
        [(char=? c #\q) (void (endwin)) (exit)]
        [(char=? c #\k) (set! list-item (inc-row! list-item))]
        [(char=? c #\j) (set! list-item (dec-row! list-item))]
        [(char=? c #\p) (waddstr win (number->string list-item))])
    (void (wrefresh win))
    (next-input win list-item)))

; Setup connection
(define current-imap (make-rmail (server) (username) (password)))
(set! list-max (rmail-total-messages current-imap))

(display-message-list current-imap win)

(next-input win list-item)
