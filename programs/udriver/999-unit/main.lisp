;; copyright (c) 2020 by Andrei Borac

(require "abort.lisp")
(require "stdlib.lisp")
(require "stdopt.lisp")
(require "stdio.lisp")
(require "pitab.lisp")
(require "amoqueue.lisp")
(require "random.lisp")

(require "trace.lisp")

(require "main.rb")

(defun assert (stdio str f)
  (progn
    (stdio-write-fully stdio two str zero (blob-length str (Integer)))
    (case (f)
          ((False) (system-exit one))
          ((True) unit))))

(defun list3 (a b c)
  (ListCons a (ListCons b (ListCons c list-fini))))

(defun list6 (a b c d e f)
  (ListCons a (ListCons b (ListCons c (ListCons d (ListCons e (ListCons f list-fini)))))))

(defun list9 (a b c d e f g h i)
  (ListCons a (ListCons b (ListCons c (ListCons d (ListCons e (ListCons f (ListCons g (ListCons h (ListCons i list-fini))))))))))

(defun and3 (a b c)
  (case a
        ((False) false)
        ((True) (case b
                      ((False) false)
                      ((True) c)))))

(defun record-eq (p q)
  (case p ((Record pa pb pc) (case q ((Record qa qb qc) (and3 (int-eq pa qa) (int-eq pb qb) (int-eq pc qc)))))))

(defun main (argv envp)
  (let ((stdio (stdio-new)))
    (progn
      ;; stdlib
      (assert stdio
              str-test-reverse-1
              (lambda () (list-eq int-eq (reverse (list3 int-1 int-2 int-3)) (list3 int-3 int-2 int-1))))
      (assert stdio
              str-test-concat-1
              (lambda () (list-eq int-eq (concat (list3 int-1 int-2 int-3) list-fini) (list3 int-1 int-2 int-3))))
      (assert stdio
              str-test-concat-2
              (lambda () (list-eq int-eq (concat list-fini (list3 int-1 int-2 int-3)) (list3 int-1 int-2 int-3))))
      (assert stdio
              str-test-concat-3
              (lambda () (list-eq int-eq (concat (list3 int-1 int-2 int-3) (list3 int-4 int-5 int-6)) (list6 int-1 int-2 int-3 int-4 int-5 int-6))))
      (assert stdio
              str-test-filter-1
              (lambda () (list-eq int-eq
                                  (filter (lambda (x) (int-gt x zero)) (list6 int-0 int-1 int-0 int-2 int-0 int-3))
                                  (list3 int-1 int-2 int-3))))
      (assert stdio
              str-test-map-1
              (lambda () (list-eq int-eq
                                  (map (lambda (x) (int-add x one (Integer))) (list6 int-0 int-1 int-2 int-3 int-4 int-5))
                                  (list6 int-1 int-2 int-3 int-4 int-5 int-6))))
      (assert stdio
              str-test-blob-extract-range-1
              (lambda () (blob-eq (blob-extract-range str-hello-world int-1 int-9) str-hello-world-trunc)))
      ;; iter can't really be unit tested; it's mainly intended for
      ;; situations in which side effects like I/O are effected.
      (assert stdio
              str-test-foldl-1
              (lambda () (int-eq (foldl (lambda (a e) (int-sub e a (Integer))) zero (list3 int-3 int-6 int-7)) int-4)))
      (assert stdio
              str-test-foldr-1
              (lambda () (int-eq (foldr (lambda (e a) (int-sub e a (Integer))) (list3 int-7 int-6 int-3) zero) int-4)))
      (assert stdio
              str-test-concat-all-1
              (lambda () (list-eq int-eq
                                  (concat-all (list3 (list3 int-1 int-2 int-3)
                                                     (list3 int-4 int-5 int-6)
                                                     (list3 int-7 int-8 int-9)))
                                  (list9 int-1 int-2 int-3 int-4 int-5 int-6 int-7 int-8 int-9))))
      (assert stdio
              str-test-replicate-1
              (lambda () (list-eq int-eq
                                  (replicate int-3 int-1)
                                  (list3 int-1 int-1 int-1))))
      (assert stdio
              str-test-int-negate-1
              (lambda () (int-eq (int-negate zero) zero)))
      (assert stdio
              str-test-int-negate-2
              (lambda () (int-eq (int-negate (int-negate int-1)) int-1)))
      ;; pitab
      (assert stdio
              str-test-pitab-coalesce-1
              (lambda () (blob-eq (pitab-coalesce (ListCons (PitabEntry str-hello-world int-0 int-6)
                                                            (ListCons (PitabEntry str-hello-world int-6 int-6) list-fini)))
                                  str-hello-world)))
      (assert stdio
              str-test-pitab-head-rest-1
              (lambda ()
                (let ((hello (stdopt-fail-fast (pitab-head (pitab-new-blob str-hello-world) int-6)))
                      (world (stdopt-fail-fast (pitab-rest (pitab-new-blob str-hello-world) int-6))))
                  (blob-eq (pitab-coalesce (pitab-concat hello world)) str-hello-world))))
      ;; random
      (let ((rng0 (random-new)))
        (case (random-next rng0)
              ((Pair val1 rng1)
               (progn
                 (trace val1)
                 (case (random-next rng1)
                       ((Pair val2 rng2)
                        (progn
                          (trace val2)
                          (case (random-next rng2)
                                ((Pair val3 rng3)
                                 (progn
                                   (trace val3)
                                   (let ((rng4 (random-skip rng3 int-997)))
                                     (case (random-next rng4)
                                           ((Pair val5 rng5)
                                            (progn
                                              (trace val5)
                                              (case (random-next rng5)
                                                    ((Pair val6 rng6)
                                                     (progn
                                                       (trace val6)
                                                       (case (random-next rng6)
                                                             ((Pair val7 rng7)
                                                              (trace val7))))))))))))))))))))
      ;; records
      (assert stdio
              str-test-records-1
              (lambda ()
                (let ((r (Record int-1 int-2 int-3)))
                  (record-eq (case-fields r ((Record "grape" r-g "orange" r-o "apple" r-a) (Record r-g r-o r-a))) (Record int-3 int-2 int-1)))))
      (assert stdio
              str-test-records-2
              (lambda ()
                (let ((r (Record int-1 int-2 int-3)))
                  (record-eq (adjust-fields r Record "grape" int-1 "orange" int-2 "apple" int-3) (Record int-3 int-2 int-1)))))
      zero)))
