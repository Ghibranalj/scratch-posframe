;;; scratch-posframe.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023
;;
;; Author:  <ghibranalj>
;; Maintainer:  <ghibranalj>
;; Created: December 13, 2023
;; Modified: December 13, 2023
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/ghibranalj/scratch-posframe
;; Package-Requires: ((emacs "27.1") (posframe "1.3.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'posframe)

(defgroup scratch-posframe nil
  "scratch posframe"
  :prefix "scratch-posframe"
  :group 'scratch-buffer)

(defvar scratch-posframe--buffer nil)
(defvar scratch-posframe--frame nil)

(defcustom scratch-posframe-buffer-name "*scratch*"
  "name of scratch buffer"
  :type 'string
  :group 'scratch-posframe)

(defcustom scratch-posframe-parameters
  '((left-fringe . 8)
    (right-fringe . 8))
  "frame parameters used by scratch-posframe"
  :type 'string
  :group 'scratch-posframe)

(defcustom scratch-posframe-poshandler 'posframe-poshandler-frame-center
  "posframe used by scratch-posframe"
  :type 'symbol
  :group 'scratch-posframe)

(defcustom scratch-posframe-width 160
  "scratch-posframe width"
  :type 'number
  :group 'scratch-posframe)

(defcustom scratch-posframe-height 40
  "scratch-posframe height"
  :type 'number
  :group 'scratch-posframe)

(defcustom scratch-posframe-border-width 2
  "scratch-posframe border width"
  :type 'number
  :group 'scratch-posframe)

(defface scratch-posframe-border
  '((t (:inherit default :background "gray50")))
  "Face used by the scratch-posframe"
  :group 'scratch-posframe)

(defun scratch-posframe-close ()
  (interactive)
  (posframe-hide scratch-posframe--buffer)
  (if (fboundp 'evil-force-normal-state)
      (advice-remove 'evil-force-normal-state 'ignore))
  ;; NOTE if you override this function
  ;; you need to set this variable to nil
  (setq  scratch-posframe--frame nil))

(defun scratch-posframe--hide-when-focus-lost ()
  (when (and scratch-posframe--frame
             (or
              (not (frame-live-p scratch-posframe--frame))
              (not (frame-focus-state scratch-posframe--frame))))
    (scratch-posframe-close)
    (remove-hook 'post-command-hook #'scratch-posframe--hide-when-focus-lost)))
;;
(defun scratch-posframe-show ()
  (interactive)
  (remove-hook 'post-command-hook #'scratch-posframe--hide-when-focus-lost)
  ;; (if scratch-posframe--buffer
  ;;     (posframe-hide scratch-posframe--buffer))

  (let ((buffer (get-buffer-create scratch-posframe-buffer-name))
        (frame nil))
    (setq frame
          (posframe-show
           buffer
           :poshandler scratch-posframe-poshandler
           :height scratch-posframe-height :min-height scratch-posframe-height
           :width scratch-posframe-width :min-width scratch-posframe-width
           :parameters scratch-posframe-parameters
           :border-color (face-attribute 'scratch-posframe-border :background)
           :hidehandler #'(scratch-posframe--hide-when-focus-lost)
           :cursor t
           :respect-header-line t
           :border-width scratch-posframe-border-width))

    (setq scratch-posframe--buffer buffer)
    (setq scratch-posframe--frame frame)
    (x-focus-frame frame)
    (with-current-buffer buffer
      (setq-local header-line-format "scratch")
      (setq-local cursor-type nil))
    (dolist (window (window-list frame))
      (set-window-margins window 4 4)))
  ;; timeout 0.5 seconds
  (if (fboundp 'evil-force-normal-state)
      (advice-add 'evil-force-normal-state :override 'ignore))
  (run-with-timer 0.1 nil #'add-hook 'post-command-hook #'scratch-posframe--hide-when-focus-lost))

(defun scratch-posframe-toggle ()
  (interactive)
  (if scratch-posframe--frame
      (scratch-posframe-close)
    (scratch-posframe-show)))

(provide 'scratch-posframe)
;;; scratch-posframe.el ends here
