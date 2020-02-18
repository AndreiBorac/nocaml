;; copyright (c) 2020 by Andrei Borac

(require "contrail.rb")

(defun contrail-private-flash-unlock ()
  (progn
    (mmio-wr (int-add int-FLASH_R_BASE int-FLASH_KEYR (Integer)) int-FLASH_KEY1)
    (mmio-wr (int-add int-FLASH_R_BASE int-FLASH_KEYR (Integer)) int-FLASH_KEY2)))

(defun contrail-private-flash-lock ()
  (let ((addr (int-add int-FLASH_R_BASE int-FLASH_CR (Integer))))
    (mmio-wr addr (int-or (mmio-rd addr (Integer)) int-FLASH_CR_LOCK (Integer)))))

(defun contrail-private-flash-busy-wait (u)
  (case (int-eq (int-and (mmio-rd (int-add int-FLASH_R_BASE int-FLASH_SR (Integer)) (Integer)) one (Integer)) one)
        ((False)
         unit)
        ((True)
         (contrail-private-flash-busy-wait u))))

(defun contrail-private-flash-program-halfword (addr halfword)
  (progn
    (mmio-wr-16 addr halfword)
    (contrail-private-flash-busy-wait unit)))

(defun contrail-private-flash-write-word (addr word)
  (progn
    (contrail-private-flash-program-halfword addr word)
    (contrail-private-flash-program-halfword (int-add addr int-2 (Integer)) (int-shrl word int-16 (Integer)))))

(defun contrail-private-flash-write (addr pt remaining)
  (case (int-eq remaining zero)
        ((False)
         (case (pitab-head-and-rest pt int-4)
               ((OptionSuccess pair)
                (case pair
                      ((Pair pthd pttl)
                       (progn
                         (contrail-private-flash-write-word addr (packer-unpack-32 (pitab-coalesce pthd) (Integer)))
                         (contrail-private-flash-write (int-add addr int-4 (Integer)) pttl (int-sub remaining int-4 (Integer)))))))
               ((OptionFailure _) (abort))))
        ((True)
         unit)))

(defun contrail-write (pt)
  (let ((len (pitab-length pt))
        (addr (contrail-sbrk len (Integer))))
    (case (int-eq addr zero)
          ((False)
           (let ((pad (Blob (int-and (int-sub zero len (Integer)) int-3 (Integer))))
                 (pt (pitab-concat-all (ListCons (pitab-new-blob (packer-pack-32 len (Blob int-4)))
                                                 (ListCons pt
                                                           (ListCons (pitab-new-blob pad)
                                                                     list-fini))))))
             (progn
               (contrail-private-flash-unlock)
               (contrail-private-flash-write addr pt (pitab-length pt))
               (contrail-private-flash-lock))))
          ((True)
           unit))))
