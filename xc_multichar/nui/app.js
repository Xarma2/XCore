const app       = document.getElementById('app');
const charSlots = document.getElementById('char-slots');
const createForm = document.getElementById('create-form');

let currentSlot = null;
let maxSlots    = 3;

function nuiPost(event, data) {
  return fetch(`https://xc_multichar/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data || {}),
  });
}

function renderSlots(characters) {
  charSlots.innerHTML = '';
  for (let i = 1; i <= maxSlots; i++) {
    const char = characters.find(c => c.slot === i);
    const el = document.createElement('div');
    el.className = 'char-slot' + (char ? '' : ' empty');

    if (char) {
      const initials = (char.firstname?.[0] || '?') + (char.lastname?.[0] || '?');
      el.innerHTML = `
        <div class="char-avatar">${initials.toUpperCase()}</div>
        <div class="char-name">${char.firstname} ${char.lastname}</div>
        <div class="char-job">${char.job_label || 'Disoccupato'}</div>
        <div class="char-stats">
          <span class="char-stat">Slot ${i}</span>
          ${char.dob ? `<span class="char-stat">${char.dob}</span>` : ''}
        </div>
        <div class="char-actions">
          <button class="btn-select" onclick="selectChar(${i})">Gioca</button>
          <button class="btn-delete" onclick="deleteChar(${char.id}, event)">🗑</button>
        </div>
      `;
    } else {
      el.innerHTML = `
        <div class="empty-icon">+</div>
        <div class="empty-label">Slot ${i} — Crea</div>
      `;
      el.addEventListener('click', () => openCreateForm(i));
    }
    charSlots.appendChild(el);
  }
}

window.selectChar = function(slot) {
  nuiPost('xc_multichar:select', { slot });
};

window.deleteChar = function(charId, event) {
  event.stopPropagation();
  if (!confirm('Sei sicuro di voler eliminare questo personaggio?')) return;
  nuiPost('xc_multichar:delete', { charId });
};

window.openCreateForm = function(slot) {
  currentSlot = slot;
  createForm.classList.remove('hidden');
};

window.closeCreateForm = function() {
  createForm.classList.add('hidden');
  currentSlot = null;
};

window.submitCreate = function() {
  const firstname = document.getElementById('inp-firstname').value.trim();
  const lastname  = document.getElementById('inp-lastname').value.trim();
  const dob       = document.getElementById('inp-dob').value;
  const gender    = parseInt(document.getElementById('inp-gender').value);

  if (!firstname || !lastname) {
    alert('Inserisci nome e cognome.');
    return;
  }

  nuiPost('xc_multichar:create', { slot: currentSlot, firstname, lastname, dob, gender });
  closeCreateForm();
};

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || !data.action) return;

  switch (data.action) {
    case 'open':
      maxSlots = data.maxSlots || 3;
      renderSlots(data.characters || []);
      app.classList.remove('hidden');
      break;
    case 'close':
      app.classList.add('hidden');
      break;
    case 'updateCharacters':
      renderSlots(data.characters || []);
      break;
  }
});
