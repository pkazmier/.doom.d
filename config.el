;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; ── General ─────────────────────────────────────────────────────────────────

(setq completion-ignore-case t
      confirm-kill-emacs nil
      display-line-numbers-type t
      global-hl-line-sticky-flag nil)

(load! "local")

;;; ── Bindings ────────────────────────────────────────────────────────────────

;; Escape is too far away
(setq evil-escape-key-sequence "jk")

;; Make C-s save and exit insert mode
(map! :g "C-s" (cmd! (call-interactively #'save-buffer) (evil-normal-state)))

;; Doom replaced most describe-xxx functions with equivalent helpful-xxx
;; functions, but did not do so for symbol. Why? Omission?
(map! :leader :desc "describe-symbol" :n "ho" #'helpful-symbol)

;; Sometimes I prefer to read docs full height
(map! :leader :desc "Raise popup window" :n "w M" #'+popup/raise)

;; Evil org missing this binding
(map! :after org
      :map (org-mode-map org-agenda-keymap)
      :localleader
      :desc "Add note" "z" #'org-add-note)

(map! :after org-ql-view
      :map org-ql-view-map
      :localleader
      :desc "Add note" "z" #'org-add-note)

(map! :after org-ql-view
      :map org-ql-view-map
      :leader
      :desc "Save all org buffers" "f s" #'org-save-all-org-buffers)

;; Need bindings to scroll the popup documentation window
(map! :after corfu
      :map corfu-popupinfo-map
      "M-d" #'corfu-popupinfo-scroll-up
      "M-u" #'corfu-popupinfo-scroll-down)

(map! :after evil-org-agenda
      :map evil-org-agenda-mode-map
      :desc "Quit agenda window" "q" #'quit-window)


;; Org keybindings (under Doom's SPC n "notes" prefix) ─────────────────────
(map! :leader
      (:prefix ("n" . "notes")
       :desc "1:1 meeting note"        "1" #'my/org-1on1-note
       :desc "View all agenda items"   "A" #'my/org-all-agenda-items
       :desc "Group meeting note"      "g" #'my/org-group-note
       :desc "Tasks for THIS file"     "O" #'my/org-tasks-for-current-file
       :desc "Tasks for a person"      "p" #'my/org-tasks-for-person
       :desc "Tasks for a project"     "P" #'my/org-tasks-for-project
       :desc "New project"             "+" #'my/org-new-project
       :desc "Remove file from agenda" "x" #'my/remove-from-agenda-files))

;;; ── Theme and faces ─────────────────────────────────────────────────────────

(setq doom-theme 'doom-one
      doom-modeline-height 35)

(custom-set-faces!
  '(aw-leading-char-face :inherit doom-modeline-emphasis :weight bold)
  '(aw-background-face :inherit shadow)
  '(helpful-heading :inherit variable-pitch)
  '(org-agenda-structure :inherit variable-pitch :height 1.5 :weight bold)
  '(org-agenda-structure-secondary :inherit font-lock-comment-face)
  '(org-document-title :inherit variable-pitch :height 1.4)
  '(org-super-agenda-header :inherit (doom-modeline-emphasis variable-pitch) :height 1.3 :weight bold))

;;; ── Writeroom ───────────────────────────────────────────────────────────────

(after! writeroom-mode
  (setq writeroom-width 40)
  (add-hook! writeroom-mode (display-line-numbers-mode (if writeroom-mode -1 1))))

(after! corfu
  (setq corfu-auto-trigger "."))

;;; ── Fonts ───────────────────────────────────────────────────────────────────

(setq doom-font-increment 1)

(setq-default line-spacing 0.2)
(setq doom-font (font-spec :family "Roboto Mono" :size 12)
      doom-big-font (font-spec :family "Roboto Mono" :size 18)
      doom-variable-pitch-font (font-spec :family "Roboto Condensed" :size 14))

;; (setq-default line-spacing 0.2)
;; (setq doom-font (font-spec :family "PragmataPro Liga" :size 12)
;;       doom-big-font (font-spec :family "PragmataPro Liga" :size 18)
;;       doom-variable-pitch-font (font-spec :family "Roboto Condensed" :size 14))

;; (setq-default line-spacing 0.2)
;; (setq doom-font (font-spec :family "Aporetic Sans Mono" :size 12)
;;       doom-big-font (font-spec :family "Aporetic Sans Mono" :size 18)
;;       doom-variable-pitch-font (font-spec :family "Source Sans 3" :size 14))

;; (setq-default line-spacing 0.2)
;; (setq doom-font (font-spec :family "Source Code Pro" :size 12)
;;       doom-big-font (font-spec :family "Source Code Pro" :size 18)
;;       doom-variable-pitch-font (font-spec :family "Source Sans 3" :size 14))


;; Do not apply line spacing to the minimap
(after! demap
  (add-hook! 'demap-minimap-window-set-hook (setq-local line-spacing nil)))

;;; ── Org ─────────────────────────────────────────────────────────────────────

;; These must be set before org loads
(setq org-directory "~/org/"
      org-roam-directory (expand-file-name org-directory))

(after! org
  (setq org-log-done 'time
        org-log-into-drawer 'LOGBOOK
        org-use-tag-inheritance nil
        org-startup-folded 'overview
        org-hide-emphasis-markers t
        org-deadline-warning-days 14
        org-agenda-start-on-weekday nil
        ;; Keep the global TODO list (SPC n t) focused on actionable items:
        ;; scheduled/deadline items surface in the agenda on their date, so
        ;; hide them from the flat todo list until then.
        org-agenda-todo-ignore-scheduled 'future  ; hide future-scheduled todos
        org-agenda-todo-ignore-deadlines 'far      ; hide deadlines beyond the 14-day warning window
        org-agenda-todo-ignore-timestamp 'future)  ; hide future plain-timestamp todos

  ;; All files listed within .agenda-files are included in the agenda.
  ;; That file is auto populated when new 1:1s or group meetings occur.
  (setq org-agenda-files
        (append
         (list
          (expand-file-name "tasks.org" org-directory)
          (expand-file-name "tickler.org" org-directory)
          (expand-file-name "recurring.org" org-directory))
         (when (file-exists-p (expand-file-name ".agenda-files" org-directory))
           (with-temp-buffer
             (insert-file-contents
              (expand-file-name ".agenda-files" org-directory))
             (split-string (buffer-string) "\n" t)))))

  ;; TODO keywords. Make them all 4 chars in length so agenda is aligned.
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"
           "NEXT(n)"
           "WAIT(w)"
           "|"
           "DONE(d)"
           "CNCL(c)")))

  ;; org-todo-list (SPC n t) has no native deadline display, so append a
  ;; countdown to each item after the buffer is built, then let org re-align
  ;; the tags around the longer headings.  A finalize-hook (rather than
  ;; prefix-format) keeps the TODO keyword at a fixed column, preserving its
  ;; reverse-video face.
  (defun my/org-agenda-append-deadlines ()
    (when (eq org-agenda-type 'todo)
      (let ((inhibit-read-only t))
        (save-excursion
          (goto-char (point-min))
          (while (not (eobp))
            (when-let* ((marker (or (get-text-property (point) 'org-hd-marker)
                                    (get-text-property (point) 'org-marker)))
                        (dl (org-with-point-at marker (org-entry-get nil "DEADLINE")))
                        (days (org-timestamp-to-now dl))
                        (str (cond ((< days 0) (format "  [%dd overdue]" (- days)))
                                   ((= days 0) "  [due today]")
                                   (t          (format "  [due in %dd]" days)))))
              ;; Insert at the end of the heading text, before any tag group;
              ;; org-agenda-align-tags re-pads the tags afterward.
              (beginning-of-line)
              (if (re-search-forward org-tag-group-re (line-end-position) t)
                  (goto-char (match-beginning 0))
                (end-of-line))
              (insert (propertize str 'face 'org-upcoming-deadline)))
            (forward-line 1)))
        (org-agenda-align-tags))))

  (add-hook 'org-agenda-finalize-hook #'my/org-agenda-append-deadlines)

  ;; Soft wrap when writing notes in org mode.
  (add-hook! org-mode
    (visual-fill-column-mode 1)))

;;; ── Performance: pre-parse agenda files during idle time ────────────────────

;; (after!
;;   org-agenda
;;   (run-with-idle-timer 5 t #'org-agenda-prepare-buffers org-agenda-files))

;;; ── org-roam ────────────────────────────────────────────────────────────────

(after! org-roam
  ;; Auto-assign an ID to every org file on save so roam can index it.
  (add-hook! org-mode
    (when (and (buffer-file-name)
               (string-prefix-p
                (expand-file-name org-directory) (buffer-file-name))
               (not
                (string-prefix-p
                 "_" (file-name-nondirectory (buffer-file-name)))))
      (org-id-get-create))))

;;; ── org-super-agenda ─────────────────────────────────────────────────────────

(use-package!
    org-super-agenda
  :after org-agenda
  :init
  (setq org-super-agenda-groups
        '((:discard (:tag "agenda"))
          (:name "🔥 Overdue" :deadline past :order 1)
          (:name "📅 Today" :scheduled today :deadline today :order 2)
          (:name "📆 Upcoming deadlines" :deadline future :order 3)
          (:name "⭐ High priority" :priority "A" :order 4)
          (:name "⏭ NEXT actions" :todo "NEXT" :order 5)
          (:name "⏳ Waiting" :todo ("WAIT") :order 6)
          (:name "📂 Other open" :todo t :order 7)
          (:name "✅ Done today" :todo ("DONE" "CNCL") :order 8)))
  :config
  (org-super-agenda-mode))


;;; ── Per-file / per-person / per-project task views ──────────────────────────

(defvar my/org-super-agenda-person-groups
  '((:name "📋 For next meeting" :tag "agenda")
    (:name "🔥 Overdue" :deadline past)
    (:name "📅 Today" :scheduled today :deadline today)
    (:name "📆 Upcoming deadlines" :deadline future)
    (:name "⭐ High priority" :priority "A")
    (:name "⏭ NEXT" :todo "NEXT")
    (:name "⏳ Waiting" :todo ("WAIT"))
    (:name "📂 Other open" :anything t))
  "Super-agenda groups for per-person and per-project task views.
Agenda items surface first; everything else follows.")

(defun my/org-file-primary-tag (file)
  "Return the first non-meta tag from FILE's #+FILETAGS keyword."
  (let ((skip
         '("project"
           "meeting"
           "1on1"
           "person"
           "team"
           "task"
           "tickler"
           "recurring"
           "someday"
           "inbox")))
    (with-temp-buffer
      (insert-file-contents file nil 0 500)
      (when (re-search-forward "^#\\+FILETAGS: *\\(.+\\)$" nil t)
        (let* ((raw (match-string 1))
               (tags (split-string raw "[: \t]+" t)))
          (seq-find (lambda (tag) (not (member tag skip))) tags))))))

(defun my/org-task-view (tag title)
  "Open a grouped, editable org-ql task view for TAG, labeled TITLE."
  (org-ql-search
    (org-agenda-files)
    `(and (todo) (tags ,tag))
    :title title
    :super-groups my/org-super-agenda-person-groups))

(defun my/org-all-agenda-items ()
  "Show all agenda items tagged :agenda: grouped by person."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (tags "agenda") (not (done)))
    :title "All agenda items"
    :super-groups '((:auto-tags t))))  ; auto-groups by tag — one section per person

(defun my/org-pick-task-view (prompt files tag-fn)
  "Pick from FILES (by #+TITLE), derive its tag via TAG-FN, open its task view."
  (let* ((choices
          (mapcar
           (lambda (f)
             (cons
              (or (my/org-file-title f) (file-name-base f)) (funcall tag-fn f)))
           files))
         (selected (completing-read prompt (mapcar #'car choices) nil t))
         (tag (cdr (assoc selected choices))))
    (when tag
      (my/org-task-view tag (format "Open items: %s" selected)))))

(defun my/org-project-files ()
  "Project .org files, excluding templates (leading underscore)."
  (directory-files (expand-file-name "projects" org-directory)
                   t
                   "^[^_].*\\.org$"))

(defun my/org-tasks-for-current-file ()
  "Show a grouped, editable task view for the current 1:1, group meeting, or
project file.  Derives the filter tag from the filename (1:1) or #+FILETAGS
(group meeting / project)."
  (interactive)
  (let* ((file (buffer-file-name))
         (base (and file (file-name-base file)))
         (tag
          (cond
           ((and base (string-prefix-p "1on1-" base))
            (concat "@" (substring base 5)))
           ((and file (or (string-match-p "/projects/" file)
                          (string-match-p "/meetings/" file)))
            (my/org-file-primary-tag file)))))
    (if tag
        (my/org-task-view tag (format "Open items: %s" tag))
      (message "Not in a 1:1, group meeting, or project file — no tag to filter by"))))

(defun my/org-tasks-for-person ()
  "Pick a person from 1:1 files and show their grouped task view."
  (interactive)
  (my/org-pick-task-view
   "Task view for: "
   (directory-files (expand-file-name "meetings" org-directory)
                    t "^1on1-.*\\.org$")
   (lambda (f)
     (concat "@" (replace-regexp-in-string "^1on1-" "" (file-name-base f))))))

(defun my/org-tasks-for-project ()
  "Pick a project and show its grouped task view."
  (interactive)
  (my/org-pick-task-view
   "Task view for project: " (my/org-project-files) #'my/org-file-primary-tag))

;;; ── Helper functions ─────────────────────────────────────────────────────────

(defun my/org-file-title (file)
  "Extract #+TITLE from FILE (reads first 500 bytes only)."
  (with-temp-buffer
    (insert-file-contents file nil 0 500)
    (when (re-search-forward "^#\\+TITLE: *\\(.+\\)$" nil t)
      (match-string 1))))

(defun my/slugify (name)
  "Convert NAME to a CamelCase slug, valid as both a filename and an Org tag.
Org tags allow only [[:alnum:]_@#%]; CamelCase joins words with no separator,
so e.g. \"Brian Kaczmarek\" -> \"BrianKaczmarek\"."
  (mapconcat #'capitalize
             (split-string (downcase name) "[^a-z0-9]+" t)
             ""))

(defun my/create-org-file-from-template (template-file substitutions dest-path)
  "Create DEST-PATH from TEMPLATE-FILE, applying SUBSTITUTIONS (alist of PATTERN
. REPLACEMENT)."
  (with-temp-file dest-path
    (insert-file-contents template-file)
    (dolist (sub substitutions)
      (goto-char (point-min))
      (while (search-forward (car sub) nil t)
        (replace-match (cdr sub) t t)))))

(defun my/goto-meetings-heading-and-insert ()
  "Find '* Meetings' and insert a new reverse-chronological dated entry."
  (goto-char (point-min))
  ;; Inactive timestamp ([...] not <...>) so these meeting-record entries
  ;; don't surface as phantom items in the org-agenda day view.
  (let ((stamp (format-time-string "[%Y-%m-%d %a]")))
    (if (re-search-forward "^\\* Meetings" nil t)
        (progn
          (forward-line 1)
          (insert (concat "\n** " stamp "\n"))
          (re-search-backward (concat "^\\*\\* " (regexp-quote stamp))))
      (goto-char (point-max))
      (insert (concat "\n* Meetings\n\n** " stamp "\n"))
      (re-search-backward (concat "^\\*\\* " (regexp-quote stamp)))))
  (end-of-line))

;;; ── .agenda-files management ─────────────────────────────────────────────────

(defun my/add-to-agenda-files (path)
  "Add PATH as a line to ~/org/.agenda-files (and the live agenda) if absent."
  (let* ((list-file (expand-file-name ".agenda-files" org-directory))
         (lines
          (when (file-exists-p list-file)
            (with-temp-buffer
              (insert-file-contents list-file)
              (split-string (buffer-string) "\n" t)))))
    (unless (member path lines)
      (append-to-file (concat path "\n") nil list-file)
      (add-to-list 'org-agenda-files path t))))

(defun my/remove-from-agenda-files ()
  "Remove current file from ~/org/.agenda-files."
  (interactive)
  (let* ((file (buffer-file-name))
         (agenda-list-file (expand-file-name ".agenda-files" org-directory)))
    (when (and file (file-exists-p agenda-list-file))
      (with-temp-file agenda-list-file
        (insert-file-contents agenda-list-file)
        (flush-lines (regexp-quote file)))
      (message "Removed %s from agenda files" (file-name-base file)))))

;;; ── Meeting notes ────────────────────────────────────────────────────────────

(defun my/org-meeting-group-files ()
  "Group-meeting .org files (excluding 1:1 files and templates)."
  (seq-filter
   (lambda (f)
     (let ((base (file-name-base f)))
       (not (or (string-prefix-p "1on1-" base) (string-prefix-p "_" base)))))
   (directory-files (expand-file-name "meetings" org-directory) t "\\.org$")))

(cl-defun
    my/org-meeting-note
    (&key prompt new-label new-prompt template (filename-prefix "") files)
  "Pick or create a meeting file under meetings/, insert a dated entry, open
task view.  PROMPT and NEW-PROMPT are the completing-read and new-file prompts;
NEW-LABEL is the \"create new\" sentinel. TEMPLATE is the template path;
FILENAME-PREFIX is prepended to the slug for the new file name. FILES is the
candidate list."
  (let* ((choices
          (mapcar
           (lambda (f)
             (cons (or (my/org-file-title f) (file-name-base f)) f))
           files))
         (all-choices (cons (cons new-label nil) choices))
         (selected (completing-read prompt (mapcar #'car all-choices) nil t))
         (file-path (cdr (assoc selected all-choices))))
    (unless file-path
      (let* ((name (read-string new-prompt))
             (slug (my/slugify name))
             (new-path
              (expand-file-name (concat filename-prefix slug ".org")
                                (expand-file-name "meetings" org-directory))))
        (my/create-org-file-from-template
         template
         `(("{{NAME}}" . ,name) ("{{slug}}" . ,slug)) new-path)
        (my/add-to-agenda-files new-path)
        (setq file-path new-path)))
    (find-file file-path)
    (my/goto-meetings-heading-and-insert)))

(defun my/org-1on1-note ()
  "Pick or create a 1:1 file, insert a dated entry, and open its task view."
  (interactive)
  (my/org-meeting-note
   :prompt "1:1 with: "
   :new-label "+ New person…"
   :new-prompt "Full name: "
   :template (expand-file-name "meetings/_1on1-template.org" org-directory)
   :filename-prefix "1on1-"
   :files
   (directory-files (expand-file-name "meetings" org-directory)
                    t "^1on1-.*\\.org$"))
  (let ((note-buf (current-buffer)))
    (save-selected-window (my/org-tasks-for-current-file))
    (switch-to-buffer note-buf)))

(defun my/org-group-note ()
  "Pick or create a group meeting file and insert a dated entry."
  (interactive)
  (my/org-meeting-note
   :prompt "Meeting: "
   :new-label "+ New meeting series…"
   :new-prompt "Meeting series name: "
   :template
   (expand-file-name "meetings/_group-template.org" org-directory)
   :files (my/org-meeting-group-files))
  (let ((note-buf (current-buffer)))
    (save-selected-window (my/org-tasks-for-current-file))
    (switch-to-buffer note-buf)))

;;; ── Project creation ─────────────────────────────────────────────────────────

(defun my/org-new-project (name tag)
  "Create a new project file from the template and open it.
NAME is the display title; TAG is the short project tag (e.g. \"ccm\") used in
#+FILETAGS and by the per-project task view. The file is named from NAME's slug
and added to the agenda set automatically."
  (interactive (list
                (read-string "Project name: ")
                (read-string "Project tag (short, e.g. ccm): ")))
  (let* ((template
          (expand-file-name "projects/_project-template.org" org-directory))
         (tag (replace-regexp-in-string "[^[:alnum:]_@#%]" "" (downcase tag)))
         (new-path
          (expand-file-name (concat (my/slugify name) ".org")
                            (expand-file-name "projects" org-directory))))
    (unless (file-exists-p new-path)
      (my/create-org-file-from-template
       template
       `(("{{PROJECT NAME}}" . ,name) ("{{tag}}" . ,tag)) new-path)
      (my/add-to-agenda-files new-path))
    (find-file new-path)))

;;; ── Capture helpers ──────────────────────────────────────────────────────────

(defun my/org-context-tags ()
  "Candidate context tags for agenda items: @person, project tags, meeting slugs."
  (delete-dups
   (append
    ;; People: 1on1-alice.org → @alice
    (mapcar (lambda (f)
              (concat "@" (replace-regexp-in-string
                           "^1on1-" "" (file-name-base f))))
            (directory-files (expand-file-name "meetings" org-directory)
                             t "^1on1-.*\\.org$"))
    ;; Projects: primary #+FILETAGS tag
    (delq nil (mapcar #'my/org-file-primary-tag (my/org-project-files)))
    ;; Group meetings: file slug
    (mapcar #'file-name-base (my/org-meeting-group-files)))))

(defun my/org-capture-agenda-template ()
  "Capture body for an agenda item: prompt for topic, then context tag(s).
Always appends the :agenda: tag so the item is hidden from the global agenda
and surfaces in the relevant person/project task view."
  (let* ((topic   (read-string "Topic: "))
         (tags    (completing-read-multiple
                   "Context tag(s) — person/project/meeting: "
                   (my/org-context-tags)))
         (alltags (delete-dups (append tags '("agenda"))))
         (created (format-time-string "[%Y-%m-%d %a %H:%M]")))
    (format "* TODO %s  :%s:\n  :PROPERTIES:\n  :CREATED: %s\n  :END:"
            topic (mapconcat #'identity alltags ":") created)))

;;; ── Capture templates ────────────────────────────────────────────────────────

(after!
  org
  (setq
   org-capture-templates
   `(("t"
      "Task"
      entry
      (file+headline ,(expand-file-name "tasks.org" org-directory) "Tasks")
      "* TODO %?\n  :PROPERTIES:\n  :CREATED: %U\n  :END:"
      :empty-lines 1)

     ("T"
      "Task with deadline"
      entry
      (file+headline ,(expand-file-name "tasks.org" org-directory) "Tasks")
      "* TODO %?\n  DEADLINE: %^{Deadline}t\n  :PROPERTIES:\n  :CREATED: %U\n  :END:"
      :empty-lines 1)

     ("a"
      "Agenda item for next meeting"
      entry
      (file+headline ,(expand-file-name "tasks.org" org-directory) "Tasks")
      #'my/org-capture-agenda-template
      :empty-lines 1)

     ("s"
      "Scheduled task (hidden until date)"
      entry
      (file ,(expand-file-name "tickler.org" org-directory))
      "* TODO %?\n  SCHEDULED: %^{Start date}t\n  :PROPERTIES:\n  :CREATED: %U\n  :END:"
      :empty-lines 1)

     ("r"
      "Recurring task"
      entry
      (file ,(expand-file-name "recurring.org" org-directory))
      "* TODO %?\n  SCHEDULED: %^{First date}t\n  :PROPERTIES:\n  :CREATED: %U\n  :END:\n  ;; Add repeater: e.g. +1w, +2w, .+1m"
      :empty-lines 1))))

