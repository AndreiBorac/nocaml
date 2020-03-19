;; copyright (c) 2020 by Andrei Borac

(require "abort.lisp")
(require "stdlib.lisp")
(require "stdopt.lisp")
(require "pitab.lisp")
(require "stdio.lisp")

(defun main (argv envp)
  (case argv
        ((ListFini) one)
        ((ListCons head tail)
         (progn
           (stdio-write-fully (stdio-new) one head zero (blob-length head (Integer)))
           zero))))
