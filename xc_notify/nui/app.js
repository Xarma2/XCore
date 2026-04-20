const container = document.getElementById('notify-container');

const icons = {
  success: '✓',
  error:   '✕',
  warning: '⚠',
  info:    'ℹ',
  primary: '★',
};

const titles = {
  success: 'Successo',
  error:   'Errore',
  warning: 'Attenzione',
  info:    'Info',
  primary: 'XCore',
};

function createNotify(type, msg, duration, title) {
  const el = document.createElement('div');
  el.className = `notify ${type}`;

  el.innerHTML = `
    <div class="notify-icon">${icons[type] || 'ℹ'}</div>
    <div class="notify-body">
      <div class="notify-title">${title || titles[type] || 'XCore'}</div>
      <div class="notify-msg">${msg}</div>
    </div>
    <div class="notify-progress" style="animation-duration: ${duration}ms"></div>
  `;

  container.appendChild(el);

  setTimeout(() => {
    el.classList.add('removing');
    setTimeout(() => el.remove(), 300);
  }, duration);
}

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || data.action !== 'notify') return;
  createNotify(
    data.type     || 'info',
    data.msg      || '',
    data.duration || 3000,
    data.title
  );
});
