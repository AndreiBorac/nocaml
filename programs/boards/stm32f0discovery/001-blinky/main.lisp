;; copyright (c) 2020 by Andrei Borac

(require "stdlib.lisp")
(require "mmio.lisp")

(require "constants.lisp")

(require "main.rb")

(defun blinky (prior)
  (let ((current (int-xor prior int-0x00000100 (Integer))))
    (progn
      (mmio-wr (int-add int-GPIOC_BASE int-GPIO_ODR (Integer)) current)
      (blinky current))))

(defun main ()
  (progn
    (mmio-wr (int-add int-RCC_BASE int-RCC_AHBENR (Integer)) (int-or (mmio-rd (int-add int-RCC_BASE int-RCC_AHBENR (Integer)) (Integer)) int-0x00080000 (Integer)))
    (mmio-wr (int-add int-GPIOC_BASE int-GPIO_MODER (Integer)) int-0x00010000)
    (blinky zero)))
