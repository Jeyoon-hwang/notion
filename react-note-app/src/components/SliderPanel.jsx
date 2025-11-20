const SliderPanel = ({ lineWidth, opacity, onLineWidthChange, onOpacityChange }) => {
  return (
    <div className="slider-panel">
      <div className="slider-group">
        <div className="slider-icon">📏</div>
        <input
          type="range"
          className="vertical-slider"
          min="1"
          max="30"
          value={lineWidth}
          onChange={(e) => onLineWidthChange(parseInt(e.target.value))}
        />
        <div className="slider-value">{lineWidth}</div>
      </div>
      <div className="slider-group">
        <div className="slider-icon">💧</div>
        <input
          type="range"
          className="vertical-slider"
          min="0.1"
          max="1"
          step="0.1"
          value={opacity}
          onChange={(e) => onOpacityChange(parseFloat(e.target.value))}
        />
        <div className="slider-value">{opacity.toFixed(1)}</div>
      </div>
    </div>
  );
};

export default SliderPanel;
