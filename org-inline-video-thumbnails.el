;;; org-inline-video-thumbnails.el --- Load video as inline images -*- lexical-binding: t -*-

;; Authors: Kisaragi Hiu <mail@kisaragi-hiu.com>
;; URL: https://kisaragi-hiu.com/projects/org-inline-video-thumbnails
;; Version: 1.0.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: org convenience hypermedia

;;; Commentary:
;;
;; Org has inline image support, but this doesn't extend to videos.
;; I'd like to see a thumbnail of a video as an inline image.
;;
;; This library sets up `image' and `image-convert' so that that works.
;;
;; Concerns:
;; - Is the ffmpeg converter slower than gm?
;; - Would it be possible to use ffmpegthumbnailer instead?
;;
;;; Code:

(require 'image-converter)

(defvar org-inline-video-thumbnails-video-name-extensions '("mp4" "mkv" "ogv")
  "Video extensions.

We need to specify extra video extensions because ffmpeg's
decoder names don't map 1:1 to extensions, with \"mp4\" notably
missing.")

(setq image-converter 'ffmpeg
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

(provide 'org-inline-video-thumbnails)
;;; org-inline-video-thumbnails.el ends here
