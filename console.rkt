#lang racket

(require racket/cmdline)

(require "mail.rkt")

(define imap-server (make-parameter "imap-mail.outlook.com"))
(define username (make-parameter ""))
(define password (make-parameter ""))

; Allow overriding of username, password, server
(command-line
  #:program "rmail"
  #:once-each
  [("-u" "--username") u
                      "IMAP Username"
                      (username u)]
  [("-p" "--password") p
                      "IMAP Password"
                      (password p)]
  [("-s" "--server") h
                    "IMAP Server"
                    (imap-server h)])

(displayln (string-append "-- DEBUG: Connecting to " (imap-server)))

(define-values [imap-connection total-messages recent-messages]
  (rmail-connect imap-server username password))

(define-values [mailboxes]
  (rmail-mailboxes imap-connection))
;
; Output
;

(display "Mailboxes: " )
(displayln mailboxes)

(displayln "Messages: ")
(for ([header (headers imap-connection total-messages)])
     (display " - ")
     (display (first header))
     (display " ")
     (displayln (get-subject (second header))))

(displayln "First message: ")
(displayln (caar (get-imap-message imap-connection (list 1))))

(displayln "-- DEBUG: Disconnected")
(rmail-disconnect imap-connection)
