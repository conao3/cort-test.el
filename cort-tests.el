;;; cort-tests.el --- cort test file       -*- lexical-binding: t; -*-

;; Copyright (C) 2018-2019 Naoya Yamashita <conao3@gmail.com>

;; Author: Naoya Yamashita <conao3@gmail.com>
;; Maintainer: Naoya Yamashita <conao3@gmail.com>
;; URL: https://github.com/conao3/cort.el

;; This program is free software: you can redistribute it and/or modify
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

;; cort-test test file

;;; Code:

(require 'cort)

(defun quote-a ()
  'a)

(defvar var 'a)
(cort-deftest simple
  '((:equal var
            'a)
    (:= 100
        100)))

(cort-deftest quote-a
  '((:eq 'a 'a)
    (:eq (quote-a) 'a)
    (:eq 'a (quote-a))
    (:eq (quote-a) (quote-a))))

(cort-deftest arith
  '((:= (+ 4 5)   9)
    (:= (- 4 5)   -1)
    (:= (* 4 5)   20)
    (:= (/ 4 5)   0)
    (:= (/ 4.0 5) 0.8)
    (:= (mod 4 5) 4)
    (:< 40 42)))

(cort-deftest string-concat
  '((:string= (concat "aaa" "bbb") "aaabbb")
    (:string= (mapconcat #'identity '("aaa" "bbb" "ccc") ",")
              "aaa,bbb,ccc")))

(cort-deftest string-split
  '((:equal (split-string "aaa,bbb,ccc" ",") '("aaa" "bbb" "ccc"))))

(cort-deftest string-length
  '((:= (length "asdfg")  5)
    (:= (length "あいうえお")  5)
    (:= (string-width "あいうえお") 10)))

(cort-deftest string-pickup
  '((:string= (substring "abcdef" 0 2)  "ab")
    (:string= (substring "abcdef" 0 -2) "abcd")
    (:string= (substring "abcdef" 0 -1) "abcde")
    (:string= (substring "abcdef" 2)    "cdef")))

(cort-deftest string-serch
  '((:= (string-match "bc" "abcd") 1)))

(cort-deftest err
  '((:cort-error 'void-function (a 'a))
    (:cort-error 'error (a 'a))
    (:cort-error 'arith-error (/ 1 0))
    (:cort-error 'void-variable (+ 1 a))))

(cort-deftest generate
  (cort-generate :equal
    '(((+ 4 5) 9)
      ((- 4 5) -1))))

(when (version<= "25.1" emacs-version)
  (cort-deftest generate-macroexpand
    (cort-generate :macroexpand
      '(((defun test ()
           (message "test"))
         (defalias 'test
           (function
            (lambda nil
              (message "test")))))))))

(cort-deftest generate-shell
  (cort-generate :shell-command
    '(("expr 1 + 10"
       "11")
      ("printf \"\\n\\n\\t \\nhello world\\n\\t\\n \\n\""
       "hello world"))))

(cort-deftest-generate deftest-generate :equal
  '(((+ 4 5) 9)
    ((- 4 5) -1)))

(cort-deftest-generate deftest-generate-string-match :string-match-p
  '(("emacs-27.1" "emacs-[0-9]+\\.[0-9]+")))

(cort-deftest hook
  '((:equal cort-var 'cort-test           ; (2) could use cort-var
            (lambda ()
              (setq cort-var 'cort-test)) ; (1) set cort-var
            (lambda (&rest _args)
              (setq cort-var 0)))         ; (3) reset cort-var
    (:equal cort-var 0)))                 ; (4) now cort-var is 0

(cort-deftest hook-generate
  `(,@(cort-generate-with-hook :equal
        (lambda ()
          (setq cort-var2 'cort-test))
        (lambda ()
          (setq cort-var2 0))
        '((cort-var2 'cort-test)))
    (:equal cort-var2 0)))

(cort-deftest-generate-with-hook cort-generate-with-hook :equal
  (lambda ()
    (setq cort-var3 'cort-test))
  (lambda ()
    (setq cort-var3 0))
  '((cort-var3 'cort-test)))

(cort-deftest cort-generate-with-hook-after-check
  '((:equal cort-var3 0)))

;; (provide 'cort-tests)

;;; cort-tests.el ends here
