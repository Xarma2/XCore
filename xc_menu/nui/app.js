const contextOverlay  = document.getElementById('context-overlay');
const contextTitle    = document.getElementById('context-title');
const contextItems    = document.getElementById('context-items');
const radialOverlay   = document.getElementById('radial-overlay');
const radialSvg       = document.getElementById('radial-svg');
const radialLabel     = document.getElementById('radial-label');
const progressContainer = document.getElementById('progress-container');
const progressLabel   = document.getElementById('progress-label');
const progressFill    = document.getElementById('progress-fill');
const progressCancel  = document.getElementById('progress-cancel');

let progressTimer = null;
let canCancel = true;

function openContext(title, elements) {
  contextTitle.textContent = title;
  contextItems.innerHTML = '';
  elements.forEach(el => {
    const item = document.createElement('div');
    item.className = 'ctx-item' + (el.disabled ? ' disabled' : '');
    item.innerHTML = `
      <div class="ctx-item-icon">${el.icon || ''}</div>
      <div class="ctx-item-body">
        <div class="ctx-item-label">${el.label}</div>
        ${el.description ? `<div class="ctx-item-desc">${el.description}</div>` : ''}
      </div>
    `;
    if (!el.disabled) {
      item.addEventListener('click', () => {
        fetch(`https://xc_menu/xc_menu:selectElement`, {
          method: 'POST', body: JSON.stringify(el)
        });
        contextOverlay.classList.add('hidden');
      });
    }
    contextItems.appendChild(item);
  });
  contextOverlay.classList.remove('hidden');
}

contextOverlay.addEventListener('click', (e) => {
  if (e.target === contextOverlay) {
    fetch(`https://xc_menu/xc_menu:closeContext`, { method: 'POST', body: JSON.stringify({}) });
    contextOverlay.classList.add('hidden');
  }
});

function openRadial(items) {
  radialSvg.innerHTML = '';
  const count = items.length;
  const angleStep = (2 * Math.PI) / count;
  const outerR = 160, innerR = 50;

  items.forEach((item, i) => {
    const startAngle = i * angleStep - Math.PI / 2;
    const endAngle   = startAngle + angleStep;
    const gap = 0.04;
    const x1 = Math.cos(startAngle + gap) * innerR;
    const y1 = Math.sin(startAngle + gap) * innerR;
    const x2 = Math.cos(endAngle - gap)   * innerR;
    const y2 = Math.sin(endAngle - gap)   * innerR;
    const x3 = Math.cos(endAngle - gap)   * outerR;
    const y3 = Math.sin(endAngle - gap)   * outerR;
    const x4 = Math.cos(startAngle + gap) * outerR;
    const y4 = Math.sin(startAngle + gap) * outerR;

    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', `M ${x1} ${y1} L ${x4} ${y4} A ${outerR} ${outerR} 0 0 1 ${x3} ${y3} L ${x2} ${y2} A ${innerR} ${innerR} 0 0 0 ${x1} ${y1} Z`);
    path.setAttribute('fill', 'rgba(8,11,20,0.88)');
    path.setAttribute('stroke', 'rgba(0,170,255,0.3)');
    path.setAttribute('stroke-width', '1');
    path.classList.add('radial-slice');
    path.addEventListener('mouseenter', () => { radialLabel.textContent = item.label; });
    path.addEventListener('mouseleave', () => { radialLabel.textContent = ''; });
    path.addEventListener('click', () => {
      fetch(`https://xc_menu/xc_menu:radialSelect`, { method:'POST', body: JSON.stringify({ id: item.id }) });
      radialOverlay.classList.add('hidden');
    });

    const midAngle = startAngle + angleStep / 2;
    const textR = (innerR + outerR) / 2;
    const tx = Math.cos(midAngle) * textR;
    const ty = Math.sin(midAngle) * textR;

    const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    text.setAttribute('x', tx);
    text.setAttribute('y', ty);
    text.setAttribute('text-anchor', 'middle');
    text.setAttribute('dominant-baseline', 'middle');
    text.classList.add('radial-text');
    text.textContent = item.icon || item.label.substring(0, 3);

    radialSvg.appendChild(path);
    radialSvg.appendChild(text);
  });

  radialOverlay.classList.remove('hidden');
}

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    if (!radialOverlay.classList.contains('hidden')) {
      fetch(`https://xc_menu/xc_menu:closeRadial`, { method:'POST', body: JSON.stringify({}) });
      radialOverlay.classList.add('hidden');
    }
    if (!contextOverlay.classList.contains('hidden')) {
      fetch(`https://xc_menu/xc_menu:closeContext`, { method:'POST', body: JSON.stringify({}) });
      contextOverlay.classList.add('hidden');
    }
  }
});

function startProgress(label, duration, cancellable) {
  progressLabel.textContent = label;
  progressFill.style.width = '0%';
  progressFill.style.transition = `width ${duration}ms linear`;
  progressCancel.style.display = cancellable ? 'block' : 'none';
  canCancel = cancellable;
  progressContainer.classList.remove('hidden');

  requestAnimationFrame(() => {
    progressFill.style.width = '100%';
  });

  progressTimer = setTimeout(() => {
    progressContainer.classList.add('hidden');
    fetch(`https://xc_menu/xc_menu:progressFinish`, { method:'POST', body: JSON.stringify({}) });
  }, duration);
}

window.cancelProgress = function() {
  if (!canCancel) return;
  clearTimeout(progressTimer);
  progressContainer.classList.add('hidden');
  progressFill.style.width = '0%';
  fetch(`https://xc_menu/xc_menu:progressCancel`, { method:'POST', body: JSON.stringify({}) });
};

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || !data.action) return;
  switch (data.action) {
    case 'openContext':  openContext(data.title, data.elements || []); break;
    case 'closeContext': contextOverlay.classList.add('hidden'); break;
    case 'openRadial':   openRadial(data.items || []); break;
    case 'closeRadial':  radialOverlay.classList.add('hidden'); break;
    case 'startProgress': startProgress(data.label, data.duration, data.canCancel !== false); break;
  }
});
