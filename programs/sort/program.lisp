;; copyright (c) 2020 by Andrei Borac

(require "stdlib.lisp")

(require "program.rb")

(defun quicksort (list)
  (case list
        ((ListFini)
         list-fini)
        ((ListCons head tail)
         (let ((lt (filter-reverse (lambda (x) (int-lt x head)) tail))
               (lt (quicksort lt))
               (gte (filter-reverse (lambda (x) (not (int-lt x head))) tail))
               (gte (quicksort gte)))
           (concat lt (ListCons head gte))))))

(defun prefix-sum-rec (list total accu)
  (case list
        ((ListFini)
         accu)
        ((ListCons head tail)
         (let ((total-prime (int-add total head (Integer))))
           (selfcall tail total-prime (ListCons total-prime accu))))))

(defun prefix-sum (list)
  (reverse (prefix-sum-rec list zero list-fini)))

(defun main-quicksort-and-prefix-sum (input)
  (let ((quicksorted (quicksort input)))
    (Pair quicksorted (prefix-sum quicksorted))))

(defun main-replicate (seed times)
  (foldl (lambda (acc piece)
           (blob-append-2 acc piece))
         blob-empty
         (replicate times seed)))

(defun iterate (n z f)
  (foldl (lambda (acc part)
           (f))
         z
         (replicate n list-fini)))

(defun main-quicksort-ntimes (input n)
  (iterate n list-fini (lambda () (quicksort input))))
