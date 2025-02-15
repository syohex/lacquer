;;; setting.el --- Setting about lacquer  -*- lexical-binding: t; -*-

;;; Commentary:
;; Setting class of lacquer.

;;; Code:


(require 'utils)
(require 'eieio)
(require 'cl-generic)


(defclass lacquer-setting-cls ()
  ((cls-cache-path :initarg :cls-cache-path
                   :initform "~/.emacs.d/.lacquer"
                   :type string
                   :custom string
                   :documentation "String of cache content.")
   (cls-theme-list :initarg :cls-theme-list
                   :initform nil
                   :type list
                   :custom list
                   :documentation "Theme list.")
   (cls-font-list :initarg :cls-font-list
                  :initform nil
                  :type list
                  :custom list
                  :documentation "Font list.")
   (cls-cache-str :initarg :cls-cache-str
                  :initform ""
                  :type string
                  :custom string
                  :documentation "Cache(string) of read `lacquer-cache'.")
   (cls-setting :initarg :cls-setting
                :initform '(("theme" . nil)
                            ("font" . nil)
                            ("font-size" . 0))
                :type cons
                :custom cons
                :documentation "Currnet setting.(theme,font and font-size).")
   )
  "Lacquer setting self.")


(cl-defmethod cls-parse-cache ((this lacquer-setting-cls) key)
  "Parse THIS's string of cache by KEY.
Return string."
  (string-replace (format "%s=" key) "" (progn
                                          (string-match (format "^%s=.+$" key) (oref this cls-cache-str))
                                          (match-string 0 (oref this cls-cache-str))
                                          )))


(cl-defmethod cls-check-setting ((this lacquer-setting-cls) key value)
  "Check THIS's setting value by KEY and VALUE, and return right value."
  (cond ((string= key "theme")
         (let ((theme (intern value)))
           (if (lacquer-is-existing (oref this cls-theme-list) theme (lambda (v) (nth 1 v)))
               theme (cls-get this key))))
        ((string= key "font")
         (let ((font (intern value)))
           (if (and (lacquer-is-existing (oref this cls-font-list) font) (lacquer-font-installed-p value))
               font (cls-get this key))))
        (t
         (if value (string-to-number value) (cls-get this key)))))


(cl-defmethod cls-init ((this lacquer-setting-cls))
  "Init THIS."
  (cl-loop for (k . v) in (oref this cls-setting)
           do (setf (cdr
                     (assoc k (oref this cls-setting)))
                    (cls-check-setting this k (cls-parse-cache this k)))
           ))


(cl-defmethod cls-call ((this lacquer-setting-cls))
  "Initialization call THIS's theme, font and font-sie."
  (cl-loop for (k . v) in (oref this cls-setting)
           do (if (string= k "font-size")
                  (set-face-attribute 'default nil :height v)
                (funcall v)
                )))


(cl-defmethod cls-get ((this lacquer-setting-cls) key)
  "Get current setting(theme, font and font-size) from THIS by KEY.
Return symbol of theme or font, int of font-size."
  (cdr (assoc key (oref this cls-setting))))


(cl-defmethod cls-set ((this lacquer-setting-cls) key value)
  "Set KEY and VALUE to THIS's setting(theme, font and font-size)."
  (unless (eq value (cdr
                     (assoc key (oref this cls-setting))))
    (setf (cdr
           (assoc key (oref this cls-setting))) value)
    (cls-write-cache this)
    ))


(cl-defmethod cls-write-cache ((this lacquer-setting-cls))
  "Wirte THIS's' setting to cache."
  (write-region
   (cl-loop with str = ""
            for (k . v) in (oref this cls-setting)
            do (setq str (concat str (format "%s=" k) (format "%s" v) "\n"))
            finally return str)
   nil (oref this cls-cache-path)))


(provide 'setting)

;;; setting.el ends here
