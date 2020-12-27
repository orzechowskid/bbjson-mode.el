;;; bbjson-mode.el --- A major mode for JSON -*- lexical-binding: t; -*-

;;; Version: 1.0.0

;;; Author: Dan Orzechowski

;;; URL: https://github.com/orzechowskid/bbjson-mode.el

;;; License: GPLv3

;;; Commentary:
;; A major mode for JSON files which doesn't inherit from any javascript major-modes and doesn't try to do anything other than display, indentation, and font-locking.
;;
;; Indentation is controlled by the value of `bbjson-indent-offset'.

;;; Code:


;; dependencies


(require 'smie)


;; internals


(defvar bbjson-mode--font-lock-defaults
  '(("\\\"[^\\\"]*\\\"" . font-lock-string-face)
    ("true\\|false\\|null\\|undefined" . font-lock-constant-face)
    ("{\\|}\\|\\[\\|\\]\\|,\\|:" . font-lock-builtin-face))
  "font-lock matchers.")

(defconst bbjson-mode--grammar
  (smie-prec2->grammar
   (smie-bnf->prec2
    '(
      (id)
      (null-value ("null"))
      (boolean-value ("true") ("false"))
      (string-value (id))
      (number-value (id))
      (value (null-value) (boolean-value) (string-value) (number-value) (object-value) (array-value))
      (object-value ("{" "}") ("{" member-list "}"))
      (member (id ":" value))
      (member-list (member) (member-list "," member))
      (array-value ("[" "]") ("[" element-list "]"))
      (element-list (value) (element-list "," value))))))

(defun bbjson-mode--smie-rules (kind token)
  "Rules for indenting JSON files."
  (pcase (cons kind token)
    ;; base indent step
    ('(:elem . basic) bbjson-indent-offset)
    ;; prevents the last line of the file from indenting
    ;; (or seems to, anyway.  who knows.  SMIE is a giant black box)
    ('(:elem . args) 0)))


;; public interface


(defgroup bbjson-mode nil
  "Major mode for editing JSON."
  :group 'programming
  :prefix "bbjson-")


(defcustom bbjson-indent-offset 2
  "Default indent step."
  :type 'integer
  :group 'bbjson-mode)

;;;###autoload
(define-derived-mode bbjson-mode prog-mode "bbjson-mode"
  "A major-mode for JSON files which doesn't try to do too much."
  nil
  ;; no comments in JSON files
  (setq-local
   smie-indent-functions
   (seq-remove (lambda (el) (memq el '(smie-indent-fixindent smie-indent-comment))) smie-indent-functions))
  (smie-setup bbjson-mode--grammar #'bbjson-mode--smie-rules)
  (setq
   font-lock-defaults
   '(bbjson-mode--font-lock-defaults)))

(provide 'bbjson-mode)


;;; bbjson-mode ends here
