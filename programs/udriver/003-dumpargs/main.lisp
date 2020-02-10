;; copyright (c) 2020 by andrei borac

(require "stdlib.lisp")
(require "stdopt.lisp")
(require "stdio.lisp")
(require "pitab.lisp")

(defun main (argv envp)
  (let ((args (pitab-concat-all (map (lambda (argi) (pitab-new-blob argi)) argv))))
    (progn
      (let ((coal (pitab-coalesce args)))
        (stdio-write-fully (stdio-new) one coal zero (blob-length coal (Integer))))
      zero)))
