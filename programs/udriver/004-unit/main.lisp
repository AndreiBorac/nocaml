;; copyright (c) 2020 by andrei borac

(require "stdlib.lisp")
(require "stdopt.lisp")
(require "stdio.lisp")
(require "pitab.lisp")

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
      (assert stdio
              str-test-concat-all-1
              (lambda () (list-eq int-eq
                                  (concat-all (list3 (list3 int-1 int-2 int-3)
                                                     (list3 int-4 int-5 int-6)
                                                     (list3 int-7 int-8 int-9)))
                                  (list9 int-1 int-2 int-3 int-4 int-5 int-6 int-7 int-8 int-9))))
      zero)))
