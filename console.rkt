#lang racket

(require racket/cmdline)

(require "mail.rkt")

(define server (make-parameter "imap-mail.outlook.com"))
(define username (make-parameter ""))
(define password (make-parameter ""))

; Allow overriding of username, password, server
(command-line
  #:program "rmail"
  #:once-each
  [("-s" "--server") imap-server
                    "IMAP Server"
                    (server imap-server)]
  #:args (imap-username imap-password)
  (username imap-username)
  (password imap-password))

(define (display-message-list)
    (for ([header (headers imap-connection total-messages)] [i (in-range total-messages)])
         (display (+ 1 i))
         (display " - ")
         (displayln (get-subject (second header)))))

(define (display-help)
  (displayln "l - List messages")
  (displayln "# - Read message #")
  (displayln "q - Quit"))

(define (display-mailboxes)
  (display "Mailboxes: ")
  (displayln mailboxes))

(define (display-message idx)
  (define (message-out-of-bounds)
    (displayln "Message index out of bounds"))
  (cond
    [(<= idx 0) (message-out-of-bounds)]
    [(>= total-messages idx)
       (displayln
         (caar (get-imap-message imap-connection (list idx))))]
    [else (message-out-of-bounds)]))

(define (disconnect-and-exit)
  (rmail-disconnect imap-connection)
  (exit))

(define (next-input port)
  (display "> ")
  (let ([s (string-downcase (read-line port))])
    (cond
      [(string=? s "m") (display-mailboxes)]
      [(string=? s "l") (display-message-list)]
      [(string=? s "?") (display-help)]
      [(string=? s "q") (disconnect-and-exit)]
      [(number? (string->number s)) (display-message (string->number s))]
      [else (displayln "Unrecognized input")])
    (next-input port)))

;
; Debug Output
;
(displayln (string-append "# Connecting to " (server) " ..."))

(define-values [imap-connection total-messages recent-messages]
  (rmail-connect server username password))

(displayln "# Connection established.")

(define-values [mailboxes]
  (rmail-mailboxes imap-connection))

;
; Mail REPL
;
(next-input (current-input-port))

;(displayln "-- DEBUG: Disconnected")
;(rmail-disconnect imap-connection)
