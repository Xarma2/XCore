const app          = document.getElementById('app');
const playersList  = document.getElementById('players-list');
const bansList     = document.getElementById('bans-list');
const actionModal  = document.getElementById('action-modal');
const modalName    = document.getElementById('modal-player-name');
const searchInput  = document.getElementById('search-input');

let allPlayers  = [];
let selectedPlayer = null;

function nuiPost(event, data) {
  return fetch(`https://xc_admin/${event}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data || {}),
  }).then(r => r.json()).catch(() => null);
}

function groupBadge(group) {
  return `<span class="group-badge group-${group}">${group}</span>`;
}

function renderPlayers(players) {
  if (!players.length) {
    playersList.innerHTML = '<p class="empty-msg">Nessun giocatore online.</p>';
    return;
  }
  playersList.innerHTML = players.map(p => `
    <div class="player-row" onclick="openModal(${JSON.stringify(p).replace(/"/g, '&quot;')})">
      <div class="player-id">${p.source}</div>
      <div class="player-info">
        <div class="player-name">${p.name} ${groupBadge(p.group)}</div>
        <div class="player-meta">${p.job} · ${p.identifiers?.license || 'N/A'}</div>
      </div>
      <div class="player-ping">${p.ping}ms</div>
    </div>
  `).join('');
}

window.filterPlayers = function() {
  const q = searchInput.value.toLowerCase();
  const filtered = allPlayers.filter(p =>
    p.name.toLowerCase().includes(q) ||
    String(p.source).includes(q) ||
    p.job.toLowerCase().includes(q)
  );
  renderPlayers(filtered);
};

window.refreshPlayers = function() {
  nuiPost('xc_admin:refresh', {}).then(players => {
    if (players) {
      allPlayers = players;
      renderPlayers(players);
    }
  });
};

window.openModal = function(player) {
  selectedPlayer = player;
  modalName.textContent = `${player.name} [${player.source}]`;
  document.getElementById('kick-form').classList.add('hidden');
  document.getElementById('ban-form').classList.add('hidden');
  actionModal.classList.remove('hidden');
};

window.closeModal = function() {
  actionModal.classList.add('hidden');
  selectedPlayer = null;
};

window.closePanel = function() {
  nuiPost('xc_admin:close', {});
  app.classList.add('hidden');
};

window.doTp       = () => { nuiPost('xc_admin:tp',       { source: selectedPlayer.source }); closeModal(); };
window.doSpectate = () => { nuiPost('xc_admin:spectate', { source: selectedPlayer.source }); closeModal(); };
window.doHeal     = () => { nuiPost('xc_admin:heal',     { source: selectedPlayer.source }); closeModal(); };
window.doRevive   = () => { nuiPost('xc_admin:revive',   { source: selectedPlayer.source }); closeModal(); };
window.doFreeze   = () => { nuiPost('xc_admin:freeze',   { source: selectedPlayer.source }); closeModal(); };

window.showKick = () => {
  document.getElementById('kick-form').classList.toggle('hidden');
  document.getElementById('ban-form').classList.add('hidden');
};
window.showBan = () => {
  document.getElementById('ban-form').classList.toggle('hidden');
  document.getElementById('kick-form').classList.add('hidden');
};

window.confirmKick = () => {
  const reason = document.getElementById('kick-reason').value || 'Nessun motivo';
  nuiPost('xc_admin:kick', { source: selectedPlayer.source, reason });
  closeModal();
};

window.confirmBan = () => {
  const reason   = document.getElementById('ban-reason').value || 'Nessun motivo';
  const duration = parseInt(document.getElementById('ban-duration').value) || 0;
  nuiPost('xc_admin:ban', { source: selectedPlayer.source, reason, duration });
  closeModal();
};

document.querySelectorAll('.tab').forEach(tab => {
  tab.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.add('hidden'));
    tab.classList.add('active');
    document.getElementById(`tab-${tab.dataset.tab}`).classList.remove('hidden');
  });
});

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || !data.action) return;
  switch (data.action) {
    case 'open':
      allPlayers = data.players || [];
      renderPlayers(allPlayers);
      app.classList.remove('hidden');
      break;
    case 'close':
      app.classList.add('hidden');
      break;
  }
});
