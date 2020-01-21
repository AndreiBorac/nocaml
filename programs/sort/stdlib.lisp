;; copyright (c) 2020 by Andrei Borac

(require "stdlib.rb")

(defun not (x)
  (case x
        ((False) true)
        ((True) false)))

(defun reverse-rec (lista listb)
  (case lista
        ((ListFini)
         listb)
        ((ListCons head tail)
         (reverse-rec tail (ListCons head listb)))))

(defun reverse (x)
  (reverse-rec x list-fini))

(defun concat (lista listb)
  (reverse-rec (reverse lista) listb))

(defun filter-rec (pred list accu)
  (case list
        ((ListFini)
         accu)
        ((ListCons head tail)
         (case (pred head)
               ((False)
                (filter-rec pred tail accu))
               ((True)
                (filter-rec pred tail (ListCons head accu)))))))

(defun filter-reverse (pred list)
  (filter-rec pred list list-fini))

(defun filter (pred list)
  (reverse (filter-reverse pred list)))

(defun blob-append-2 (a b)
  (let ((len-a (blob-length a (Integer)))
        (len-b (blob-length b (Integer)))
        (len-o (int-add len-a len-b (Integer)))
        (output (Blob len-o)))
    (progn
      (blob-copy-range output zero len-a a zero)
      (blob-copy-range output len-a len-b b zero))))

(defun foldl (f z l)
  (case l
        ((ListFini)
         z)
        ((ListCons head tail)
         (foldl f (f z head) tail))))

(defun replicate-rec (n e accu)
  (case (int-gt n zero)
        ((False)
         accu)
        ((True)
         (replicate-rec (int-sub n one (Integer)) e (ListCons e accu)))))

(defun replicate (n e)
  (replicate-rec n e list-fini))
