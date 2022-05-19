;;; org-inline-video-thumbnails.el --- Load video as inline images -*- lexical-binding: t -*-

;; Authors: Kisaragi Hiu <mail@kisaragi-hiu.com>
;; URL: https://kisaragi-hiu.com/projects/org-inline-video-thumbnails
;; Version: 2.0.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: org convenience hypermedia

;;; Commentary:
;;
;; Org has inline image support, but this doesn't extend to videos.
;; I'd like to see a thumbnail of a video as an inline image.
;;
;; This library sets up `image' and `image-convert' so that that works.
;;
;; Concerns: Is ffmpegthumbnailer a good fit outside of Org?
;;
;;; Code:

(require 'image-converter)

;;;; The `ffmpegthumbnailer' image converter.

(cl-defmethod image-converter--probe ((_type (eql 'ffmpegthumbnailer)))
  "Check whether to use ffmpegthumbnailer.

This actually just delegates to the ffmpeg converter."
  (image-converter--probe 'ffmpeg))

(cl-defmethod image-converter--convert ((_type (eql 'ffmpegthumbnailer))
                                        source image-format)
  "Convert using ffmpegthumbnailer."
  (let ((command '("ffmpegthumbnailer"))
        result)
    (setq result (if image-format
                     ;; Converting from stdin seems to fail, so just delegate to ffmpeg.
                     (image-converter--convert 'ffmpeg source image-format)
                   (apply #'call-process
                          (car command)
                          nil '(t nil) nil
                          (append (cdr command)
                                  (list "-i" (expand-file-name source)
                                        "-c" "png"
                                        "-o" "-")))))
    (cond
     ;; ffmpeg error
     ((stringp result) result)
     ;; call-process exit code
     ((not (equal 0 result))
      "ffmpegthumbnailer error when converting")
     (t nil))))

(cl-pushnew '(ffmpegthumbnailer :command "ffmpegthumbnailer")
            image-converter--converters
            :test #'equal)

;;;; Use it.

(defvar org-inline-video-thumbnails-video-name-extensions '("mp4" "mkv" "ogv")
  "Video extensions.

We need to specify extra video extensions because ffmpeg's
decoder names don't map 1:1 to extensions, with \"mp4\" notably
missing.")

(setq image-converter 'ffmpegthumbnailer
      image-use-external-converter t
      ;; This is how org-display-inline-images figure out whether a
      ;; link is an inline image. Doing this is better than modifying
      ;; Org.
      image-file-name-extensions
      (append org-inline-video-thumbnails-video-name-extensions
              image-file-name-extensions))

;; Taken from `image-convert-p'. That function doesn't overwrite
;; `image-converter-regexp' again if it's already set.
(when-let ((formats (image-converter--probe image-converter)))
  (setq image-converter-regexp
        (concat "\\."
                (regexp-opt
                 (append org-inline-video-thumbnails-video-name-extensions
                         formats))
                "\\'")))

;; (define-minor-mode org-inline-video-thumbnails-mode
;;   "Preview videos as images using a thumbnail."
;;   :global nil :lighter "IVidThumb"
;;   (cond
;;    (org-inline-video-thumbnails-mode
;;     (setq-local
;;      image-converter 'ffmpegthumbnailer
;;      image-use-external-converter t
;;      image-file-name-extensions (append
;;                                  org-inline-video-thumbnails-video-name-extensions
;;                                  image-file-name-extensions)))
;;    (t
;;     ;; Yeah right...
;;     (let ((org-mode-hook (remq 'org-inline-video-thumbnails-mode org-mode-hook)))
;;       (revert-buffer)))))

(provide 'org-inline-video-thumbnails)
;;; org-inline-video-thumbnails.el ends here
