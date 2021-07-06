(defpackage :cl-upp
  (:use :common-lisp)
  (:export #:read-spec))

(cl::in-package :cl-upp)

(defun read-spec (path)
  (format t "Read library: ~A~%" path))
