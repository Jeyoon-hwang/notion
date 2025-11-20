import { useState, useEffect } from 'react';
import './App.css';
import Canvas from './components/Canvas';
import Header from './components/Header';
import FloatingToolbar from './components/FloatingToolbar';
import SliderPanel from './components/SliderPanel';
import Modal from './components/Modal';
import GestureHint from './components/GestureHint';

function App() {
  const [darkMode, setDarkMode] = useState(false);
  const [currentTool, setCurrentTool] = useState('pen');
  const [currentColor, setCurrentColor] = useState('#000000');
  const [lineWidth, setLineWidth] = useState(3);
  const [opacity, setOpacity] = useState(1.0);
  const [showClearModal, setShowClearModal] = useState(false);
  const [showGestureHint, setShowGestureHint] = useState(false);
  const [canvasActions, setCanvasActions] = useState(null);

  useEffect(() => {
    setTimeout(() => setShowGestureHint(true), 1000);
  }, []);

  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
  };

  const handleUndo = () => {
    canvasActions?.undo();
  };

  const handleRedo = () => {
    canvasActions?.redo();
  };

  const handleClear = () => {
    setShowClearModal(true);
  };

  const confirmClear = () => {
    canvasActions?.clear();
    setShowClearModal(false);
  };

  const handleDownload = () => {
    canvasActions?.download();
  };

  return (
    <div className={`app ${darkMode ? 'dark-mode' : ''}`}>
      <Header
        darkMode={darkMode}
        onToggleDarkMode={toggleDarkMode}
        onUndo={handleUndo}
        onRedo={handleRedo}
        onClear={handleClear}
        onDownload={handleDownload}
      />

      <Canvas
        currentTool={currentTool}
        currentColor={currentColor}
        lineWidth={lineWidth}
        opacity={opacity}
        darkMode={darkMode}
        setCanvasActions={setCanvasActions}
      />

      <SliderPanel
        lineWidth={lineWidth}
        opacity={opacity}
        onLineWidthChange={setLineWidth}
        onOpacityChange={setOpacity}
      />

      <FloatingToolbar
        currentTool={currentTool}
        currentColor={currentColor}
        onToolChange={setCurrentTool}
        onColorChange={setCurrentColor}
      />

      {showGestureHint && <GestureHint />}

      {showClearModal && (
        <Modal
          title="전체 지우기"
          message="모든 내용을 지우시겠습니까?"
          onConfirm={confirmClear}
          onCancel={() => setShowClearModal(false)}
        />
      )}
    </div>
  );
}

export default App;
