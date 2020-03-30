;; copyright (c) 2020 by Andrei Borac

(require "stdio.rb")

(defun stdio-new ()
  (StandardIO (Blob int-65536)))

(defun stdio-fail-fast (opt) ;; => 'a
  (case opt
        ((OptionSuccess a) a)
        ((OptionFailure errno) (abort)))) ;; TODO: print errno

(defun stdio-read (stdio-object fd count) ;; => OptionSuccess blob:Blob | OptionFailure errno:Integer
  (case stdio-object
        ((StandardIO common-blob)
         (let ((count (int-min count (blob-length common-blob (Integer))))
               (common-blob-address (Integer))
               (read-retv (Integer))
               (_ (system-blob-address common-blob zero common-blob-address read-retv)))
           (progn
             (system-read fd common-blob-address count read-retv)
             (case (int-lt-signed read-retv zero)
                   ((False) (OptionSuccess (blob-extract-range common-blob zero read-retv)))
                   ((True) (OptionFailure (int-negate read-retv)))))))))

(defun stdio-write (stdio-object fd blob off len) ;; => OptionSuccess written:Integer | OptionFailure errno:Integer
  (case (int-lte (int-add off len (Integer)) (blob-length blob (Integer)))
        ((False) (OptionFailure int-22))
        ((True) (let ((blob-address (Integer))
                      (write-retv (Integer))
                      (_ (system-blob-address blob off blob-address write-retv)))
                  (progn
                    (system-write fd blob-address len write-retv)
                    (case (int-lt-signed write-retv zero)
                          ((False) (OptionSuccess write-retv))
                          ((True) (OptionFailure (int-negate write-retv)))))))))

(defun stdio-read-fully-rec (stdio-object fd count blobs) ;; => OptionSuccess blob | OptionFailure errno:Integer
  (case (int-gt count zero)
        ((False) (OptionSuccess (pitab-coalesce (pitab-concat-all (map pitab-new-blob (reverse blobs))))))
        ((True) (case (stdio-read stdio-object fd count)
                      ((OptionFailure errno) (OptionFailure errno))
                      ((OptionSuccess blob)
                       (case (int-eq (blob-length blob (Integer)) zero)
                             ((False) (stdio-read-fully-rec stdio-object fd (int-sub count (blob-length blob (Integer)) (Integer)) (ListCons blob blobs)))
                             ((True) (OptionFailure zero))))))))

(defun stdio-read-fully (stdio-object fd count) ;; => OptionSuccess blob | OptionFailure errno:Integer
  (stdio-read-fully-rec stdio-object fd count list-fini))

(defun stdio-read-fully-slurp-rec (stdio-object fd blobs) ;; => OptionSuccess blob | OptionFailure errno:Integer
  (case stdio-object
        ((StandardIO common-blob)
         (case (stdio-read stdio-object fd (blob-length common-blob (Integer)))
               ((OptionFailure errno) (OptionFailure errno))
               ((OptionSuccess blob)
                (case (int-eq (blob-length blob (Integer)) zero)
                      ((False) (stdio-read-fully-slurp-rec stdio-object fd (ListCons blob blobs)))
                      ((True) (OptionSuccess (pitab-coalesce (pitab-concat-all (map pitab-new-blob (reverse blobs))))))))))))

(defun stdio-read-fully-slurp (stdio-object fd) ;; => OptionSuccess blob | OptionFailure errno:Integer
  (stdio-read-fully-slurp-rec stdio-object fd list-fini))

(defun stdio-write-fully (stdio-object fd blob off len) ;; => unit:Unit
  (case (int-gt len zero)
        ((False) unit)
        ((True) (let ((written (stdio-fail-fast (stdio-write stdio-object fd blob off len)))
                      (next-off (int-add off written (Integer)))
                      (next-len (int-sub len written (Integer))))
                  (stdio-write-fully stdio-object fd blob next-off next-len)))))
