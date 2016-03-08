#lang racket

; Possible future requires
;net/unihead
;net/mime
;net/base64
;net/qp

(provide (all-defined-out))

(require net/imap
         net/head)


; Default to INBOX mailbox
(define mailbox "INBOX")
(define use-ssl #t )
(imap-port-number 993)

(define server (make-parameter "imap-mail.outlook.com"))
(define username (make-parameter ""))
(define password (make-parameter ""))

(struct rmail
        (connection total-messages recent-messages))

(define (rmail-connect imap-server username password)
  ;(displayln (string-append (imap-server) (username) (password)))
  (imap-connect imap-server username password mailbox #:tls? use-ssl))

; This should be included in the above struct
(define (rmail-mailboxes imap-connection)
  (map (lambda (mailbox-information)
         (last mailbox-information))
  (imap-list-child-mailboxes imap-connection #f)))

(define (create-mailbox imap-connection mailbox)
  (unless (imap-mailbox-exists? imap-connection mailbox)
    (imap-create-mailbox imap-connection mailbox)))

; A header is returned as:
;   '(uid #bytes)
; bytes->string/utf-8 can be used to output bytes, though something like
; this will be called by display
(define (headers imap-connection total-messages)
  (imap-get-messages
    imap-connection (stream->list (in-range 1 (+ total-messages 1))) '(uid header)))

(define (get-subject header)
  (extract-field #"SUBJECT" header))

(define (get-imap-message imap-connection index)
  (imap-get-messages
    imap-connection index '(body)))

(define (rmail-disconnect imap-connection)
  (imap-disconnect imap-connection))

(define (make-rmail server username password)
  (let-values ([(imap-connection total-messages recent-messages)
                (rmail-connect server username password)])
              (rmail imap-connection total-messages recent-messages)))

(define (disconnect-and-exit imap)
  (rmail-disconnect (rmail-connection imap))
  (exit))
