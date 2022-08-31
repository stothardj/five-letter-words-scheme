#!/usr/bin/guile3.0 -s
!#

(use-modules (ice-9 textual-ports)
             (srfi srfi-1)
             (srfi srfi-9)
             (srfi srfi-43))

(define test-strings
  '("foo" "hello" "abcde" "fghij" "klmno" "pqrst" "uvwxy" "zabcf" "zabcd"))

(define-record-type <word>
  (make-word text bitmap index)
  word?
  (text    word-text)
  (bitmap  word-bitmap)
  (index   word-index))

(define-record-type <graph-row>
  (make-graph-row text connections)
  graph-row?
  (text         graph-row-text)
  (connections  graph-row-connections))

(define* (log #:rest ss)
  (for-each (λ (s)
              (display s (current-error-port))
              (display " " (current-error-port))) ss)
  (newline (current-error-port)))

(define (right-length? s) (= (string-length s) 5))

(define a-int (char->integer #\a))
(define (char->bitmap c) (ash 1 (- (char->integer c) a-int)))
(define (string->bitmap s)
  (string-fold (λ (c acc)
                 (logior acc (char->bitmap c)))
               0 s))

(define (valid-words words)
  (let* ((five-long (filter right-length? words))
         (bitmaps (map string->bitmap five-long))
         (with-bitmaps (zip five-long bitmaps))
         (no-duplicates (filter (λ (p) (= 5 (logcount (second p)))) with-bitmaps)))
    (map (λ (el i) (make-word (first el) (second el) i))
         no-duplicates
         (iota (length no-duplicates)))))

(define (distinct-words? w1 w2)
  (not (logtest (word-bitmap w1) (word-bitmap w2))))
(define (all-distinct-words w ws)
  (filter (λ (w0) (and (< (word-index w) (word-index w0))
                       (distinct-words? w w0))) ws))
(define (create-graph ws)
  (list->vector (map (λ (w) (make-graph-row (word-text w)
                                            (map word-index (all-distinct-words w ws)))) ws)))

; Note this is signifcantly faster than using lset-intersection.
(define (sorted-intersection-h l1 l2 accum)
  (cond ((null? l1) accum)
        ((null? l2) accum)
        ((= (car l1) (car l2)) (sorted-intersection-h (cdr l1) (cdr l2) (cons (car l1) accum)))
        ((< (car l1) (car l2)) (sorted-intersection-h (cdr l1) l2 accum))
        (else (sorted-intersection-h l1 (cdr l2) accum))))
(define (sorted-intersection l1 l2)
  (reverse (sorted-intersection-h l1 l2 '())))

(define (find-cliques graph depth included connections accum)
  (if (= depth 4)
      (append (map (λ (c)
                     (vector-set! included 4 c)
                     (vector-copy included)) connections)
              accum)
      (fold (λ (c acc)
              (let* ((new-conns (graph-row-connections (vector-ref graph c)))
                     (intersection (sorted-intersection connections new-conns)))
                (if (null? intersection)
                    acc
                    (begin (vector-set! included depth c)
                           (find-cliques graph (+ 1 depth) included intersection acc))))) accum connections)))



(define (clique-text-from-indexes graph indexes)
  (vector-map (λ (i n) (graph-row-text (vector-ref graph n))) indexes))
(define (find-all-cliques graph)
  (let* ((depth 1)
         (included (make-vector 5 0))
         (clique-indexes (vector-fold
                          (λ (i accum row)
                            ;; (log "Checking" (graph-row-text row))
                            (vector-set! included 0 i)
                            (find-cliques graph 1 included (graph-row-connections row) accum))
                          '()
                          graph)))
    (map (λ (indexes) (clique-text-from-indexes graph indexes)) clique-indexes)))

(define (display-clique clique)
  (vector-for-each (λ (i t) (display t) (display " ")) clique))

(define (read-line) (get-line (current-input-port)))

(define (read-lines)
  (let loop ((line (read-line))
              (lines '()))
    (if (eof-object? line)
        lines
        (loop (read-line)
              (cons line lines)))))

(define (main)
  (for-each (λ (c)
              (display-clique c)
              (newline))
            (find-all-cliques (create-graph (valid-words (read-lines))))))

(main)



