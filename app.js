// ===== Note App - Main Application =====

class NoteApp {
    constructor() {
        this.notes = [];
        this.folders = [];
        this.currentNote = null;
        this.currentFolder = null;
        this.autoSaveTimer = null;
        this.searchQuery = '';
        this.sortBy = 'modified';
        this.drawingLayer = null;

        this.init();
    }

    // ===== Initialization =====
    init() {
        this.loadData();
        this.setupEventListeners();
        this.renderNotesList();
        this.applyTheme();

        // Hide loading screen
        setTimeout(() => {
            document.getElementById('loading-screen').classList.add('hidden');
        }, 500);
    }

    // ===== Data Management =====
    loadData() {
        try {
            const notesData = localStorage.getItem('myNotes');
            const foldersData = localStorage.getItem('myFolders');
            const settings = localStorage.getItem('mySettings');

            this.notes = notesData ? JSON.parse(notesData) : [];
            this.folders = foldersData ? JSON.parse(foldersData) : this.getDefaultFolders();
            this.settings = settings ? JSON.parse(settings) : this.getDefaultSettings();
        } catch (error) {
            console.error('Error loading data:', error);
            this.notes = [];
            this.folders = this.getDefaultFolders();
            this.settings = this.getDefaultSettings();
        }
    }

    saveData() {
        try {
            localStorage.setItem('myNotes', JSON.stringify(this.notes));
            localStorage.setItem('myFolders', JSON.stringify(this.folders));
            localStorage.setItem('mySettings', JSON.stringify(this.settings));
            this.updateSaveStatus('저장됨');
        } catch (error) {
            console.error('Error saving data:', error);
            this.updateSaveStatus('저장 실패', true);
        }
    }

    getDefaultFolders() {
        return [
            { id: 'default', name: '전체 노트', icon: '📝', color: '#4299e1', expanded: true },
            { id: 'favorites', name: '즐겨찾기', icon: '⭐', color: '#f6ad55', expanded: true },
            { id: 'locked', name: '잠금', icon: '🔒', color: '#fc8181', expanded: true }
        ];
    }

    getDefaultSettings() {
        return {
            theme: 'light',
            autoSave: true,
            spellCheck: false
        };
    }

    // ===== Event Listeners =====
    setupEventListeners() {
        // Sidebar
        document.getElementById('new-note-btn').addEventListener('click', () => this.createNewNote());
        document.getElementById('new-folder-btn').addEventListener('click', () => this.createNewFolder());
        document.getElementById('search-input').addEventListener('input', (e) => this.handleSearch(e.target.value));
        document.getElementById('sort-select').addEventListener('change', (e) => this.handleSort(e.target.value));
        document.getElementById('toggle-sidebar').addEventListener('click', () => this.toggleSidebar());

        // Welcome screen
        document.getElementById('welcome-new-note').addEventListener('click', () => this.createNewNote());

        // Editor
        document.getElementById('note-title').addEventListener('input', () => this.handleNoteChange());
        document.getElementById('editor-content').addEventListener('input', () => this.handleNoteChange());
        document.getElementById('editor-content').addEventListener('keydown', (e) => this.handleKeyboard(e));

        // Editor actions
        document.getElementById('delete-note-btn').addEventListener('click', () => this.deleteCurrentNote());
        document.getElementById('star-note-btn').addEventListener('click', () => this.toggleFavorite());
        document.getElementById('lock-note-btn').addEventListener('click', () => this.toggleLock());
        document.getElementById('share-note-btn').addEventListener('click', () => this.shareNote());

        // Toolbar
        document.querySelectorAll('.toolbar-btn[data-command]').forEach(btn => {
            btn.addEventListener('click', () => {
                const command = btn.dataset.command;
                document.execCommand(command, false, null);
                this.handleNoteChange();
            });
        });

        document.getElementById('heading-select').addEventListener('change', (e) => {
            document.execCommand('formatBlock', false, e.target.value);
            this.handleNoteChange();
        });

        document.getElementById('text-color').addEventListener('change', (e) => {
            document.execCommand('foreColor', false, e.target.value);
        });

        document.getElementById('bg-color').addEventListener('change', (e) => {
            document.execCommand('backColor', false, e.target.value);
        });

        document.getElementById('checklist-btn').addEventListener('click', () => this.insertChecklist());

        // Drawing mode
        document.getElementById('drawing-mode-btn').addEventListener('click', () => this.toggleDrawingMode());

        // Tags
        document.getElementById('tag-input').addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.addTag(e.target.value);
                e.target.value = '';
            }
        });

        // Footer buttons
        document.getElementById('dark-mode-toggle').addEventListener('click', () => this.toggleTheme());
        document.getElementById('export-btn').addEventListener('click', () => this.openExportModal());
        document.getElementById('settings-btn').addEventListener('click', () => this.openSettingsModal());

        // Modals
        this.setupModalListeners();
    }

    setupModalListeners() {
        // Password modal
        document.getElementById('password-submit').addEventListener('click', () => this.submitPassword());
        document.getElementById('password-cancel').addEventListener('click', () => this.closeModal('password-modal'));

        // Set password modal
        document.getElementById('set-password-submit').addEventListener('click', () => this.setPassword());
        document.getElementById('set-password-cancel').addEventListener('click', () => this.closeModal('set-password-modal'));

        // Settings modal
        document.getElementById('settings-close').addEventListener('click', () => this.closeModal('settings-modal'));
        document.getElementById('clear-data-btn').addEventListener('click', () => this.clearAllData());
        document.getElementById('import-data-btn').addEventListener('click', () => document.getElementById('import-file-input').click());
        document.getElementById('import-file-input').addEventListener('change', (e) => this.importData(e));

        // Theme radio buttons
        document.querySelectorAll('input[name="theme"]').forEach(radio => {
            radio.addEventListener('change', (e) => {
                this.settings.theme = e.target.value;
                this.applyTheme();
                this.saveData();
            });
        });

        // Auto-save checkbox
        document.getElementById('auto-save').addEventListener('change', (e) => {
            this.settings.autoSave = e.target.checked;
            this.saveData();
        });

        // Export modal
        document.getElementById('export-close').addEventListener('click', () => this.closeModal('export-modal'));
        document.getElementById('export-json').addEventListener('click', () => this.exportAsJSON());
        document.getElementById('export-txt').addEventListener('click', () => this.exportAsTXT());
        document.getElementById('export-html').addEventListener('click', () => this.exportAsHTML());
    }

    // ===== Note Operations =====
    createNewNote() {
        const note = {
            id: this.generateId(),
            title: '제목 없음',
            content: '<p>여기에 내용을 입력하세요...</p>',
            tags: [],
            folder: 'default',
            created: new Date().toISOString(),
            modified: new Date().toISOString(),
            locked: false,
            password: null,
            starred: false,
            drawing: null
        };

        this.notes.unshift(note);
        this.saveData();
        this.openNote(note);
        this.renderNotesList();

        // Focus on title
        setTimeout(() => {
            document.getElementById('note-title').select();
        }, 100);
    }

    toggleDrawingMode() {
        if (this.drawingLayer) {
            this.drawingLayer.toggleMode();
        }
    }

    openNote(note) {
        // Check if note is locked
        if (note.locked && !this.verifyNoteAccess(note)) {
            this.showPasswordModal(note);
            return;
        }

        this.currentNote = note;

        // Hide welcome screen, show editor
        document.getElementById('welcome-screen').classList.add('hidden');
        document.getElementById('note-editor').classList.remove('hidden');

        // Populate editor
        document.getElementById('note-title').value = note.title;
        document.getElementById('editor-content').innerHTML = note.content;
        document.getElementById('note-date').textContent = `생성: ${this.formatDate(note.created)}`;
        document.getElementById('note-modified').textContent = `수정: ${this.formatDate(note.modified)}`;

        // Update folder display
        const folder = this.folders.find(f => f.id === note.folder);
        document.getElementById('note-folder').textContent = `📁 폴더: ${folder ? folder.name : '없음'}`;

        // Update lock button
        document.getElementById('lock-note-btn').textContent = note.locked ? '🔒' : '🔓';

        // Update star button
        document.getElementById('star-note-btn').textContent = note.starred ? '⭐' : '☆';

        // Update tags
        this.renderTags();

        // Update word count
        this.updateWordCount();

        // Highlight active note in list
        this.updateActiveNote();

        // Initialize drawing layer
        if (!this.drawingLayer) {
            this.drawingLayer = new DrawingLayer(this);
        }
        this.drawingLayer.loadDrawing();
    }

    handleNoteChange() {
        if (!this.currentNote) return;

        this.currentNote.title = document.getElementById('note-title').value || '제목 없음';
        this.currentNote.content = document.getElementById('editor-content').innerHTML;
        this.currentNote.modified = new Date().toISOString();

        document.getElementById('note-modified').textContent = `수정: ${this.formatDate(this.currentNote.modified)}`;

        this.updateWordCount();
        this.updateSaveStatus('저장 중...', false, true);

        // Auto-save
        if (this.settings.autoSave) {
            clearTimeout(this.autoSaveTimer);
            this.autoSaveTimer = setTimeout(() => {
                this.saveData();
                this.renderNotesList();
            }, 3000);
        }
    }

    deleteCurrentNote() {
        if (!this.currentNote) return;

        if (confirm('이 노트를 삭제하시겠습니까?')) {
            this.notes = this.notes.filter(n => n.id !== this.currentNote.id);
            this.saveData();
            this.currentNote = null;

            // Show welcome screen
            document.getElementById('note-editor').classList.add('hidden');
            document.getElementById('welcome-screen').classList.remove('hidden');

            this.renderNotesList();
        }
    }

    toggleFavorite() {
        if (!this.currentNote) return;

        this.currentNote.starred = !this.currentNote.starred;
        document.getElementById('star-note-btn').textContent = this.currentNote.starred ? '⭐' : '☆';
        this.saveData();
        this.renderNotesList();
    }

    toggleLock() {
        if (!this.currentNote) return;

        if (this.currentNote.locked) {
            // Unlock note
            if (confirm('노트 잠금을 해제하시겠습니까?')) {
                this.currentNote.locked = false;
                this.currentNote.password = null;
                document.getElementById('lock-note-btn').textContent = '🔓';
                this.saveData();
                this.renderNotesList();
            }
        } else {
            // Lock note - show password modal
            this.showSetPasswordModal();
        }
    }

    shareNote() {
        if (!this.currentNote) return;

        const shareText = `${this.currentNote.title}\n\n${this.stripHTML(this.currentNote.content)}`;

        if (navigator.share) {
            navigator.share({
                title: this.currentNote.title,
                text: shareText
            }).catch(err => console.log('Share failed:', err));
        } else {
            // Fallback: copy to clipboard
            navigator.clipboard.writeText(shareText).then(() => {
                alert('노트가 클립보드에 복사되었습니다!');
            }).catch(err => {
                console.error('Copy failed:', err);
            });
        }
    }

    // ===== Folder Operations =====
    createNewFolder() {
        const name = prompt('새 폴더 이름을 입력하세요:');
        if (!name) return;

        const folder = {
            id: this.generateId(),
            name: name,
            icon: '📁',
            color: this.getRandomColor(),
            expanded: true
        };

        this.folders.push(folder);
        this.saveData();
        this.renderNotesList();
    }

    // ===== Search & Filter =====
    handleSearch(query) {
        this.searchQuery = query.toLowerCase();
        this.renderNotesList();
    }

    handleSort(sortBy) {
        this.sortBy = sortBy;
        this.renderNotesList();
    }

    filterNotes() {
        let filtered = [...this.notes];

        // Search filter
        if (this.searchQuery) {
            filtered = filtered.filter(note =>
                note.title.toLowerCase().includes(this.searchQuery) ||
                this.stripHTML(note.content).toLowerCase().includes(this.searchQuery) ||
                note.tags.some(tag => tag.toLowerCase().includes(this.searchQuery))
            );
        }

        // Sort
        filtered.sort((a, b) => {
            switch (this.sortBy) {
                case 'modified':
                    return new Date(b.modified) - new Date(a.modified);
                case 'created':
                    return new Date(b.created) - new Date(a.created);
                case 'title':
                    return a.title.localeCompare(b.title);
                default:
                    return 0;
            }
        });

        return filtered;
    }

    // ===== Rendering =====
    renderNotesList() {
        const container = document.getElementById('notes-list');
        container.innerHTML = '';

        const filteredNotes = this.filterNotes();

        // Group notes by folder
        const notesByFolder = {};
        this.folders.forEach(folder => {
            notesByFolder[folder.id] = [];
        });

        filteredNotes.forEach(note => {
            if (note.starred) {
                notesByFolder['favorites'] = notesByFolder['favorites'] || [];
                notesByFolder['favorites'].push(note);
            }
            if (note.locked) {
                notesByFolder['locked'] = notesByFolder['locked'] || [];
                notesByFolder['locked'].push(note);
            }
            notesByFolder[note.folder] = notesByFolder[note.folder] || [];
            notesByFolder[note.folder].push(note);
        });

        // Render folders and their notes
        this.folders.forEach(folder => {
            const notes = notesByFolder[folder.id] || [];
            if (notes.length === 0 && ['favorites', 'locked'].includes(folder.id)) return;

            const folderEl = this.createFolderElement(folder, notes);
            container.appendChild(folderEl);
        });
    }

    createFolderElement(folder, notes) {
        const div = document.createElement('div');
        div.className = 'folder-item';

        const header = document.createElement('div');
        header.className = 'folder-header';
        header.innerHTML = `
            <button class="folder-toggle">${folder.expanded ? '▼' : '▶'}</button>
            <span>${folder.icon} ${folder.name} (${notes.length})</span>
        `;

        header.querySelector('.folder-toggle').addEventListener('click', (e) => {
            e.stopPropagation();
            folder.expanded = !folder.expanded;
            this.saveData();
            this.renderNotesList();
        });

        div.appendChild(header);

        if (folder.expanded) {
            const notesContainer = document.createElement('div');
            notesContainer.className = 'folder-notes';

            notes.forEach(note => {
                const noteEl = this.createNoteElement(note);
                notesContainer.appendChild(noteEl);
            });

            div.appendChild(notesContainer);
        }

        return div;
    }

    createNoteElement(note) {
        const div = document.createElement('div');
        div.className = 'note-item';
        if (this.currentNote && this.currentNote.id === note.id) {
            div.classList.add('active');
        }

        const preview = this.stripHTML(note.content).substring(0, 100);

        div.innerHTML = `
            <div class="note-item-header">
                <div class="note-title">${this.escapeHTML(note.title)}</div>
                <div class="note-icons">
                    ${note.starred ? '⭐' : ''}
                    ${note.locked ? '🔒' : ''}
                    ${note.tags.length > 0 ? '🏷️' : ''}
                </div>
            </div>
            <div class="note-preview">${this.escapeHTML(preview)}...</div>
            <div class="note-date">${this.formatDate(note.modified)}</div>
        `;

        div.addEventListener('click', () => this.openNote(note));

        return div;
    }

    updateActiveNote() {
        document.querySelectorAll('.note-item').forEach(el => {
            el.classList.remove('active');
        });

        if (this.currentNote) {
            const activeNote = Array.from(document.querySelectorAll('.note-item')).find(el =>
                el.querySelector('.note-title').textContent === this.currentNote.title
            );
            if (activeNote) {
                activeNote.classList.add('active');
            }
        }
    }

    // ===== Tags =====
    addTag(tagText) {
        if (!this.currentNote || !tagText.trim()) return;

        const tag = tagText.trim().replace(/^#/, '');
        if (!this.currentNote.tags.includes(tag)) {
            this.currentNote.tags.push(tag);
            this.renderTags();
            this.saveData();
        }
    }

    removeTag(tag) {
        if (!this.currentNote) return;

        this.currentNote.tags = this.currentNote.tags.filter(t => t !== tag);
        this.renderTags();
        this.saveData();
    }

    renderTags() {
        if (!this.currentNote) return;

        const container = document.getElementById('tags-display');
        container.innerHTML = '';

        this.currentNote.tags.forEach(tag => {
            const tagEl = document.createElement('span');
            tagEl.className = 'tag';
            tagEl.innerHTML = `
                #${this.escapeHTML(tag)}
                <button class="tag-remove">×</button>
            `;

            tagEl.querySelector('.tag-remove').addEventListener('click', () => this.removeTag(tag));
            container.appendChild(tagEl);
        });
    }

    // ===== Rich Text Editor =====
    insertChecklist() {
        const checklistHTML = `
            <div class="checklist-item">
                <input type="checkbox">
                <span contenteditable="true">체크리스트 항목</span>
            </div>
        `;

        document.execCommand('insertHTML', false, checklistHTML);
        this.handleNoteChange();
    }

    handleKeyboard(e) {
        // Ctrl+B: Bold
        if (e.ctrlKey && e.key === 'b') {
            e.preventDefault();
            document.execCommand('bold');
            this.handleNoteChange();
        }
        // Ctrl+I: Italic
        else if (e.ctrlKey && e.key === 'i') {
            e.preventDefault();
            document.execCommand('italic');
            this.handleNoteChange();
        }
        // Ctrl+U: Underline
        else if (e.ctrlKey && e.key === 'u') {
            e.preventDefault();
            document.execCommand('underline');
            this.handleNoteChange();
        }
        // Ctrl+S: Save
        else if (e.ctrlKey && e.key === 's') {
            e.preventDefault();
            this.saveData();
            this.renderNotesList();
        }
    }

    // ===== Password & Security =====
    showPasswordModal(note) {
        this.tempNote = note;
        document.getElementById('password-modal').classList.remove('hidden');
        document.getElementById('password-input').value = '';
        document.getElementById('password-input').focus();
    }

    submitPassword() {
        const password = document.getElementById('password-input').value;

        if (this.hashPassword(password) === this.tempNote.password) {
            this.closeModal('password-modal');
            this.openNote(this.tempNote);
        } else {
            alert('비밀번호가 틀렸습니다.');
            document.getElementById('password-input').value = '';
        }
    }

    showSetPasswordModal() {
        document.getElementById('set-password-modal').classList.remove('hidden');
        document.getElementById('new-password').value = '';
        document.getElementById('confirm-password').value = '';
        document.getElementById('new-password').focus();
    }

    setPassword() {
        const newPassword = document.getElementById('new-password').value;
        const confirmPassword = document.getElementById('confirm-password').value;

        if (!newPassword) {
            alert('비밀번호를 입력하세요.');
            return;
        }

        if (newPassword !== confirmPassword) {
            alert('비밀번호가 일치하지 않습니다.');
            return;
        }

        this.currentNote.locked = true;
        this.currentNote.password = this.hashPassword(newPassword);
        document.getElementById('lock-note-btn').textContent = '🔒';

        this.closeModal('set-password-modal');
        this.saveData();
        this.renderNotesList();

        alert('노트가 잠겼습니다.');
    }

    verifyNoteAccess(note) {
        // In a real app, you'd track unlocked notes in session
        return false;
    }

    hashPassword(password) {
        // Simple hash - in production use proper crypto
        let hash = 0;
        for (let i = 0; i < password.length; i++) {
            const char = password.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash;
        }
        return hash.toString();
    }

    // ===== Theme =====
    toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

        this.settings.theme = newTheme;
        document.documentElement.setAttribute('data-theme', newTheme);
        document.getElementById('dark-mode-toggle').textContent = newTheme === 'dark' ? '☀️' : '🌙';

        this.saveData();
    }

    applyTheme() {
        const theme = this.settings.theme === 'auto' ?
            (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light') :
            this.settings.theme;

        document.documentElement.setAttribute('data-theme', theme);
        document.getElementById('dark-mode-toggle').textContent = theme === 'dark' ? '☀️' : '🌙';

        // Update radio buttons in settings
        document.querySelector(`input[name="theme"][value="${this.settings.theme}"]`).checked = true;
    }

    // ===== Export =====
    openExportModal() {
        document.getElementById('export-modal').classList.remove('hidden');
    }

    exportAsJSON() {
        const data = {
            notes: this.notes,
            folders: this.folders,
            exported: new Date().toISOString()
        };

        const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
        this.downloadFile(blob, `mynotes-backup-${this.getDateString()}.json`);

        this.closeModal('export-modal');
    }

    exportAsTXT() {
        if (!this.currentNote) {
            alert('노트를 선택하세요.');
            return;
        }

        const text = `${this.currentNote.title}\n\n${this.stripHTML(this.currentNote.content)}`;
        const blob = new Blob([text], { type: 'text/plain' });
        this.downloadFile(blob, `${this.currentNote.title}.txt`);

        this.closeModal('export-modal');
    }

    exportAsHTML() {
        if (!this.currentNote) {
            alert('노트를 선택하세요.');
            return;
        }

        const html = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${this.escapeHTML(this.currentNote.title)}</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>${this.escapeHTML(this.currentNote.title)}</h1>
    <p><em>생성: ${this.formatDate(this.currentNote.created)}</em></p>
    ${this.currentNote.content}
</body>
</html>
        `;

        const blob = new Blob([html], { type: 'text/html' });
        this.downloadFile(blob, `${this.currentNote.title}.html`);

        this.closeModal('export-modal');
    }

    importData(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            try {
                const data = JSON.parse(event.target.result);

                if (confirm('현재 데이터를 백업 데이터로 교체하시겠습니까? (기존 데이터는 삭제됩니다)')) {
                    this.notes = data.notes || [];
                    this.folders = data.folders || this.getDefaultFolders();
                    this.saveData();
                    this.renderNotesList();
                    alert('데이터를 가져왔습니다!');
                }
            } catch (error) {
                alert('잘못된 파일 형식입니다.');
            }
        };
        reader.readAsText(file);
    }

    downloadFile(blob, filename) {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.click();
        URL.revokeObjectURL(url);
    }

    // ===== Settings =====
    openSettingsModal() {
        document.getElementById('settings-modal').classList.remove('hidden');
    }

    clearAllData() {
        if (confirm('모든 데이터를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다!')) {
            if (confirm('정말로 모든 노트와 폴더를 삭제하시겠습니까?')) {
                localStorage.clear();
                location.reload();
            }
        }
    }

    // ===== UI Helpers =====
    toggleSidebar() {
        document.getElementById('sidebar').classList.toggle('collapsed');
    }

    closeModal(modalId) {
        document.getElementById(modalId).classList.add('hidden');
    }

    updateSaveStatus(status, error = false, saving = false) {
        const statusEl = document.getElementById('save-status');
        statusEl.textContent = status;

        if (saving) {
            statusEl.classList.add('saving');
        } else {
            statusEl.classList.remove('saving');
        }

        if (error) {
            statusEl.style.color = 'var(--danger)';
        } else {
            statusEl.style.color = 'var(--text-muted)';
        }
    }

    updateWordCount() {
        if (!this.currentNote) return;

        const text = this.stripHTML(this.currentNote.content);
        const words = text.trim().split(/\s+/).filter(w => w.length > 0).length;
        const chars = text.length;

        document.getElementById('word-count').textContent = `${words} 단어`;
        document.getElementById('char-count').textContent = `${chars} 글자`;
    }

    // ===== Utilities =====
    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const now = new Date();
        const diff = now - date;

        // Less than 1 minute
        if (diff < 60000) {
            return '방금 전';
        }
        // Less than 1 hour
        if (diff < 3600000) {
            const mins = Math.floor(diff / 60000);
            return `${mins}분 전`;
        }
        // Less than 1 day
        if (diff < 86400000) {
            const hours = Math.floor(diff / 3600000);
            return `${hours}시간 전`;
        }
        // Less than 7 days
        if (diff < 604800000) {
            const days = Math.floor(diff / 86400000);
            return `${days}일 전`;
        }

        // Default format
        return date.toLocaleDateString('ko-KR', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }

    getDateString() {
        const now = new Date();
        return now.toISOString().split('T')[0];
    }

    stripHTML(html) {
        const tmp = document.createElement('div');
        tmp.innerHTML = html;
        return tmp.textContent || tmp.innerText || '';
    }

    escapeHTML(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    getRandomColor() {
        const colors = ['#4299e1', '#48bb78', '#ed8936', '#f56565', '#9f7aea', '#38b2ac'];
        return colors[Math.floor(Math.random() * colors.length)];
    }
}

// ===== Drawing Layer Class =====
class DrawingLayer {
    constructor(app) {
        this.app = app;
        this.canvas = document.getElementById('drawing-canvas');
        this.ctx = this.canvas.getContext('2d');
        this.isDrawing = false;
        this.isActive = false;
        this.tool = 'pen';
        this.color = '#000000';
        this.size = 5;
        this.lastX = 0;
        this.lastY = 0;

        this.setupCanvas();
        this.setupEventListeners();
    }

    setupCanvas() {
        const container = this.canvas.parentElement;
        this.canvas.width = container.clientWidth;
        this.canvas.height = container.clientHeight;

        // Resize canvas when window resizes
        window.addEventListener('resize', () => {
            const imageData = this.ctx.getImageData(0, 0, this.canvas.width, this.canvas.height);
            this.canvas.width = container.clientWidth;
            this.canvas.height = container.clientHeight;
            this.ctx.putImageData(imageData, 0, 0);
        });
    }

    setupEventListeners() {
        // Drawing toolbar buttons
        document.getElementById('draw-pen').addEventListener('click', () => this.setTool('pen'));
        document.getElementById('draw-eraser').addEventListener('click', () => this.setTool('eraser'));
        document.getElementById('draw-highlighter').addEventListener('click', () => this.setTool('highlighter'));
        document.getElementById('draw-color').addEventListener('change', (e) => this.setColor(e.target.value));
        document.getElementById('draw-size').addEventListener('change', (e) => this.setSize(e.target.value));
        document.getElementById('clear-drawing').addEventListener('click', () => this.clearCanvas());
        document.getElementById('save-drawing').addEventListener('click', () => this.saveAndExit());

        // Canvas events
        this.canvas.addEventListener('mousedown', (e) => this.startDrawing(e));
        this.canvas.addEventListener('mousemove', (e) => this.draw(e));
        this.canvas.addEventListener('mouseup', () => this.stopDrawing());
        this.canvas.addEventListener('mouseout', () => this.stopDrawing());

        // Touch events for mobile
        this.canvas.addEventListener('touchstart', (e) => {
            e.preventDefault();
            const touch = e.touches[0];
            const mouseEvent = new MouseEvent('mousedown', {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            this.canvas.dispatchEvent(mouseEvent);
        });

        this.canvas.addEventListener('touchmove', (e) => {
            e.preventDefault();
            const touch = e.touches[0];
            const mouseEvent = new MouseEvent('mousemove', {
                clientX: touch.clientX,
                clientY: touch.clientY
            });
            this.canvas.dispatchEvent(mouseEvent);
        });

        this.canvas.addEventListener('touchend', (e) => {
            e.preventDefault();
            const mouseEvent = new MouseEvent('mouseup', {});
            this.canvas.dispatchEvent(mouseEvent);
        });
    }

    toggleMode() {
        this.isActive = !this.isActive;

        if (this.isActive) {
            // Enter drawing mode
            this.canvas.classList.remove('hidden');
            this.canvas.classList.add('active');
            document.getElementById('drawing-toolbar').classList.remove('hidden');
            document.getElementById('editor-content').contentEditable = 'false';
            document.querySelector('.note-editor').classList.add('drawing-mode-active');
        } else {
            // Exit drawing mode
            this.saveAndExit();
        }
    }

    setTool(tool) {
        this.tool = tool;

        // Update button states
        document.querySelectorAll('#drawing-toolbar .toolbar-btn').forEach(btn => {
            btn.classList.remove('active');
        });

        if (tool === 'pen') {
            document.getElementById('draw-pen').classList.add('active');
            this.color = document.getElementById('draw-color').value;
            this.ctx.globalAlpha = 1.0;
        } else if (tool === 'eraser') {
            document.getElementById('draw-eraser').classList.add('active');
            this.ctx.globalAlpha = 1.0;
        } else if (tool === 'highlighter') {
            document.getElementById('draw-highlighter').classList.add('active');
            this.color = document.getElementById('draw-color').value;
            this.ctx.globalAlpha = 0.3;
        }
    }

    setColor(color) {
        this.color = color;
    }

    setSize(size) {
        this.size = parseInt(size);
    }

    startDrawing(e) {
        if (!this.isActive) return;

        this.isDrawing = true;
        const rect = this.canvas.getBoundingClientRect();
        this.lastX = e.clientX - rect.left;
        this.lastY = e.clientY - rect.top;
    }

    draw(e) {
        if (!this.isDrawing || !this.isActive) return;

        const rect = this.canvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        this.ctx.beginPath();
        this.ctx.moveTo(this.lastX, this.lastY);
        this.ctx.lineTo(x, y);

        if (this.tool === 'eraser') {
            this.ctx.strokeStyle = 'rgba(255, 255, 255, 1)';
            this.ctx.globalCompositeOperation = 'destination-out';
        } else {
            this.ctx.strokeStyle = this.color;
            this.ctx.globalCompositeOperation = 'source-over';
        }

        this.ctx.lineWidth = this.size;
        this.ctx.lineCap = 'round';
        this.ctx.lineJoin = 'round';
        this.ctx.stroke();

        this.lastX = x;
        this.lastY = y;
    }

    stopDrawing() {
        this.isDrawing = false;
    }

    clearCanvas() {
        if (confirm('모든 그림을 지우시겠습니까?')) {
            this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        }
    }

    saveAndExit() {
        // Save canvas as data URL
        const drawingData = this.canvas.toDataURL();

        if (this.app.currentNote) {
            this.app.currentNote.drawing = drawingData;
            this.app.saveData();
        }

        // Exit drawing mode
        this.isActive = false;
        this.canvas.classList.add('hidden');
        this.canvas.classList.remove('active');
        document.getElementById('drawing-toolbar').classList.add('hidden');
        document.getElementById('editor-content').contentEditable = 'true';
        document.querySelector('.note-editor').classList.remove('drawing-mode-active');
    }

    loadDrawing() {
        // Clear canvas first
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

        // Load drawing if exists
        if (this.app.currentNote && this.app.currentNote.drawing) {
            const img = new Image();
            img.onload = () => {
                this.ctx.drawImage(img, 0, 0);
            };
            img.src = this.app.currentNote.drawing;

            // Show canvas in background (not active)
            this.canvas.classList.remove('hidden');
            this.canvas.classList.remove('active');
        } else {
            this.canvas.classList.add('hidden');
        }
    }
}

// ===== Initialize App =====
document.addEventListener('DOMContentLoaded', () => {
    window.app = new NoteApp();
});
