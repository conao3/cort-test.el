;;; srt.el ---                                       -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Naoya Yamashita

;; Author: Naoya Yamashita
;; Keywords: test

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defvar srt-errorp nil
  "When test fail, this flag will be t.")

(defvar srt-test-cases nil
  "Test list such as ((TEST-NAME VALUE) (TEST-NAME VALUE))")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  support functions
;;

(defun srt-testpass (name key form expect)
  (let* ((mesheader  (format "[PASSED]  %s\n" name))
	 (mes        (concat mesheader)))
    (princ mes)))

(defun srt-testfail (name key form expect)
  (let* ((mesheader (format "[ERROR]  %s\n" name))
	 (meskey    (format "< tested on %s >\n" key))
	 (mesform   (format "form:\n%s\n" (pp-to-string form)))
	 (mesexpect (format "expected:\n%s\n" (pp-to-string expect)))
	 (mes       (concat mesheader meskey mesform mesexpect)))
    (princ mes)
    (setq srt-errorp t)))

(defun srt-test (key form expect &optional special)
  (if (not special)
      (let* ((funcname
	      (replace-regexp-in-string "^:+" "" (symbol-name key)))
	     (funcsym (intern funcname)))
	(funcall funcsym form expect))
    nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  main macro
;;

(defmacro srt-deftest (name value)
  (declare (indent 1))
  `(add-to-list 'srt-test-cases '(',name ,value) t))

(defun srt-run-tests-batch-and-exit ()
  (princ (format "%s\n" (emacs-version)))
  (mapc (lambda (x)
	  (let* ((name    (pop x))
		 (value   (pop x))
		 (key     (pop value))
		 (form    (pop value))
		 (expect  (pop value))
		 (special (pop value)))
	    (princ (format "(%s %s %s %s %s %s)\n"
			   name value key form expect special))
	    (if (srt-test key form expect special)
		(srt-testpass name key form expect)
	      (srt-testfail name key form expect))))
	srt-test-cases))

(provide 'srt)
;;; srt.el ends here
