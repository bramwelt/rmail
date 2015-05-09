#lang racket

; Possible future requires
;net/unihead
;net/mime
;net/base64
;net/qp

(require racket/cmdline
         net/imap
         net/head)

; Default to INBOX mailbox
(define mailbox "INBOX")
(define use-ssl #t )
(imap-port-number 993)

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

; This should be a struct...
(define-values [imap-connection total-messages recent-messages]
  (imap-connect (imap-server) (username) (password) mailbox #:tls? use-ssl))

(displayln "-- DEBUG: Connected")

; This should be included in the above struct
(define-values [mailboxes]
  (map (lambda (mailbox-information)
         (last mailbox-information))
  (imap-list-child-mailboxes imap-connection #f)))

(define (create-mailbox mailbox)
  (unless (imap-mailbox-exists? imap-connection mailbox)
    (imap-create-mailbox imap-connection mailbox)))

; A header is returned as:
;   '(uid #bytes)
; bytes->string/utf-8 can be used to output bytes, though something like
; this will be called by display
(define (headers imap-connection)
  (imap-get-messages
    imap-connection (stream->list (in-range 1 (+ total-messages 1))) '(uid header)))

(define (get-subject header)
  (extract-field #"SUBJECT" header))

(define (get-imap-message index)
  (imap-get-messages
    imap-connection index '(body)))

;
; Output
;

(display "Mailboxes: " )
(displayln mailboxes)

(displayln "Messages: ")
(for ([header (headers imap-connection)])
     (display " - ")
     (display (first header))
     (display " ")
     (displayln (get-subject (second header))))

(displayln "First message: ")
(displayln (caar (get-imap-message (list 1))))

(imap-disconnect imap-connection)
(displayln "-- DEBUG: Disconnected")
