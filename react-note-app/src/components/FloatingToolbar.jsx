const FloatingToolbar = ({ currentTool, currentColor, onToolChange, onColorChange }) => {
  const colors = [
    '#000000',
    '#FF3B30',
    '#007AFF',
    '#34C759',
    '#FF9500',
    '#AF52DE',
  ];

  return (
    <div className="floating-toolbar">
      <button
        className={`tool-btn ${currentTool === 'pen' ? 'active' : ''}`}
        onClick={() => onToolChange('pen')}
      >
        <span>&#9998;&#65039;</span>
      </button>
      <button
        className={`tool-btn ${currentTool === 'eraser' ? 'active' : ''}`}
        onClick={() => onToolChange('eraser')}
      >
        <span>&#129529;</span>
      </button>
      <div className="toolbar-divider"></div>
      <div className="color-palette">
        {colors.map((color) => (
          <div
            key={color}
            className={`color-btn ${currentColor === color ? 'active' : ''}`}
            style={{ background: color }}
            onClick={() => onColorChange(color)}
          />
        ))}
      </div>
      <div className="toolbar-divider"></div>
      <input
        type="color"
        className="color-picker-input icon-btn"
        value={currentColor}
        onChange={(e) => onColorChange(e.target.value)}
        title="Color Picker"
      />
    </div>
  );
};

export default FloatingToolbar;
