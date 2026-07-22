;;; early-init.el --- Pre-init settings -*- lexical-binding: t; -*-

;; Prevent package.el from auto-initializing before init loads.
;; straight.el is bootstrapped from ~/.emacs and manages packages itself.
(setq package-enable-at-startup nil)
