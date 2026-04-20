const hud        = document.getElementById('hud');
const fillHealth = document.getElementById('fill-health');
const fillArmor  = document.getElementById('fill-armor');
const fillHunger = document.getElementById('fill-hunger');
const fillThirst = document.getElementById('fill-thirst');
const valHealth  = document.getElementById('val-health');
const valArmor   = document.getElementById('val-armor');
const valHunger  = document.getElementById('val-hunger');
const valThirst  = document.getElementById('val-thirst');
const valCash    = document.getElementById('val-cash');
const valSpeed   = document.getElementById('val-speed');
const hudSpeed   = document.getElementById('hud-speed');
const hudName    = document.getElementById('hud-player-name');
const hudJob     = document.getElementById('hud-job');

function setBar(fill, valEl, value) {
  const clamped = Math.max(0, Math.min(100, value));
  fill.style.width = clamped + '%';
  valEl.textContent = clamped;
}

function formatMoney(amount) {
  return Math.floor(amount).toLocaleString('it-IT');
}

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || !data.action) return;

  switch (data.action) {

    case 'showHUD':
      hud.classList.remove('hud-hidden');
      hud.classList.add('hud-visible');
      break;

    case 'hideHUD':
      hud.classList.remove('hud-visible');
      hud.classList.add('hud-hidden');
      break;

    case 'updateAll':
      if (data.data) {
        if (data.data.name) hudName.textContent = data.data.name;
        if (data.data.job)  hudJob.textContent  = data.data.job;
        if (data.data.cash !== undefined) valCash.textContent = formatMoney(data.data.cash);
        if (data.data.status) {
          setBar(fillHunger, valHunger, data.data.status.hunger ?? 100);
          setBar(fillThirst, valThirst, data.data.status.thirst ?? 100);
        }
      }
      break;

    case 'updateVitals':
      setBar(fillHealth, valHealth, data.health ?? 100);
      setBar(fillArmor,  valArmor,  data.armor  ?? 0);
      valSpeed.textContent = data.speed ?? 0;
      if (data.inVehicle) {
        hudSpeed.classList.remove('speed-hidden');
        hudSpeed.classList.add('speed-visible');
      } else {
        hudSpeed.classList.remove('speed-visible');
        hudSpeed.classList.add('speed-hidden');
      }
      break;

    case 'updateMoney':
      if (data.cash !== undefined) valCash.textContent = formatMoney(data.cash);
      break;

    case 'updateStatus':
      if (data.status) {
        setBar(fillHunger, valHunger, data.status.hunger ?? 100);
        setBar(fillThirst, valThirst, data.status.thirst ?? 100);
      }
      break;
  }
});
