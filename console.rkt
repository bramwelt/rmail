#lang racket

(require racket/cmdline)

(require "mail.rkt")

;
; Display functions
;
(define (display-message-list imap)
    (let ([imap-connection (rmail-connection imap)]
          [total-messages (rmail-total-messages imap)])
      (for ([header (headers imap-connection total-messages)] [i (in-range total-messages)])
           (display (+ 1 i))
           (display " - ")
           (displayln (get-subject (second header))))))

(define (display-help)
  (displayln "l - List messages")
  (displayln "# - Read message #")
  (displayln "q - Quit"))

(define (display-mailboxes imap)
  (display "Mailboxes: ")
  (displayln (rmail-mailboxes (rmail-connection imap))))

(define (display-message idx imap)
  (let ([total-messages (rmail-total-messages imap)]
        [imap-connection (rmail-connection imap)])
    (define (message-out-of-bounds)
      (displayln "Message index out of bounds"))
    (cond
      [(<= idx 0) (message-out-of-bounds)]
      [(>= total-messages idx)
         (displayln
           (caar (get-imap-message imap-connection (list idx))))]
      [else (message-out-of-bounds)])))

;
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

;
; REPL Menu
;
(define (next-input port current-imap)
  (display "> ")
  (let ([s (string-downcase (read-line port))])
    (cond
      [(string=? s "m") (display-mailboxes current-imap)]
      [(string=? s "l") (display-message-list current-imap)]
      [(string=? s "?") (display-help)]
      [(string=? s "q") (disconnect-and-exit current-imap)]
      [(number? (string->number s)) (display-message (string->number s) current-imap)]
      [else (displayln "Unrecognized input")])
    (next-input port current-imap)))

;
; Debug Output
;
(displayln (string-append "# Connecting to " (server) " ..."))

;
; Calling make-rmail starts the IMAP connection
;
(define current-imap (make-rmail (server) (username) (password)))

(displayln "# Connection established.")

;
; Start REPL Menu
;
(next-input (current-input-port) current-imap)
