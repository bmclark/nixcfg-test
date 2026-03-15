;;; debug-vterm.el --- Debug vterm toggle -*- lexical-binding: t; -*-

;;; Commentary:
;; Eval this buffer (M-x eval-buffer), kill stale *vterm* buffers, then C-c v.

;;; Code:
(require 'vterm)

(defun bc/--plain-vterm-p (buf)
  "Return non-nil if BUF is a plain vterm, not an AI agent terminal."
  (and (buffer-live-p buf)
       (with-current-buffer buf (derived-mode-p 'vterm-mode))
       (string-match-p "\\`\\*vterm" (buffer-name buf))))

(defun bc/--vterm-window ()
  "Return the window currently displaying a plain vterm buffer, or nil."
  (cl-find-if (lambda (w) (bc/--plain-vterm-p (window-buffer w)))
              (window-list)))

(defun bc/toggle-vterm ()
  "Toggle vterm panel at the bottom of the frame."
  (interactive)
  (when bc/--vterm-prev-config
    (set-window-configuration bc/--vterm-prev-config)
    (setq bc/--vterm-prev-config nil))
  (let ((vw (bc/--vterm-window)))
    (if vw
        (if (eq (selected-window) vw)
            (progn (message "vterm: HIDE") (delete-window vw))
          (message "vterm: FOCUS") (select-window vw))
      (message "vterm: SHOW (split + vterm)")
      (let ((win (split-window (frame-root-window) -15 'below)))
        (select-window win)
        (vterm)
        (set-window-buffer win (current-buffer))
        (message "vterm: window %s now shows %S" win (buffer-name (window-buffer win)))))))

(message "Ready. Kill stale *vterm*, then test C-c v toggle.")

;;; debug-vterm.el ends here
