;; copyright (c) 2020 by Andrei Borac

(require "abort.lisp")
(require "stdlib.lisp")
(require "stdopt.lisp")
(require "pitab.lisp")
(require "mmio.lisp")
(require "packer.lisp")

(require "constants.lisp")
(require "contrail.lisp")

(require "main.rb")

(defun main ()
  (progn
    (contrail-write (pitab-new-blob str-hello-world))
    (contrail-write (pitab-new-blob str-hello-world))
    (abort)))
