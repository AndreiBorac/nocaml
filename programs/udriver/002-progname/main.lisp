;; copyright (c) 2020 by andrei borac

(require "stdlib.lisp")
(require "stdopt.lisp")
(require "stdio.lisp")

(defun main (argv envp)
  (case argv
        ((ListFini) one)
        ((ListCons head tail)
         (progn
           (stdio-write-fully (stdio-new) one head zero (blob-length head (Integer)))
           zero))))
