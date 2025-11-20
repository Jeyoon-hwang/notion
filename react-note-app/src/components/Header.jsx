const Header = ({ darkMode, onToggleDarkMode, onUndo, onRedo, onClear, onDownload }) => {
  return (
    <div className="header">
      <div className="app-title">
        <span>✏️</span>
        <span>Digital Note</span>
      </div>
      <div className="header-actions">
        <button className="icon-btn" onClick={onUndo} title="실행 취소">
          ↶
        </button>
        <button className="icon-btn" onClick={onRedo} title="다시 실행">
          ↷
        </button>
        <button className="icon-btn" onClick={onClear} title="전체 지우기">
          🗑️
        </button>
        <button className="icon-btn" onClick={onDownload} title="저장">
          💾
        </button>
        <button className="icon-btn" onClick={onToggleDarkMode} title="다크 모드">
          {darkMode ? '☀️' : '🌙'}
        </button>
      </div>
    </div>
  );
};

export default Header;
