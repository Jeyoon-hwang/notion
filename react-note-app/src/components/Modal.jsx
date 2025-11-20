const Modal = ({ title, message, onConfirm, onCancel }) => {
  return (
    <div className="modal">
      <div className="modal-content">
        <div className="modal-title">{title}</div>
        <p>{message}</p>
        <div className="modal-buttons">
          <button className="modal-btn secondary" onClick={onCancel}>
            취소
          </button>
          <button className="modal-btn primary" onClick={onConfirm}>
            지우기
          </button>
        </div>
      </div>
    </div>
  );
};

export default Modal;
