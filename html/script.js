let isOpen = false;
let blueprints = [];
let activeFilter = 'all';
let searchQuery = '';

const rootEl = document.getElementById('root');
const gridEl = document.getElementById('blueprint-grid');
const searchInput = document.getElementById('search-input');
const closeBtn = document.getElementById('close-btn');
const filterButtons = document.querySelectorAll('.filter-btn');
const toastEl = document.getElementById('tablet-toast');

function setOpen(state) {
  isOpen = state;

  if (!rootEl) return;

  if (state) {
    rootEl.classList.remove('hidden');
    rootEl.style.display = 'flex';
  } else {
    rootEl.classList.add('hidden');
    rootEl.style.display = 'none';
  }
}

function applyFilterAndSearch() {
  const q = searchQuery.trim().toLowerCase();

  return blueprints.filter((bp) => {
    if (activeFilter === 'learned' && !bp.learned) return false;
    if (activeFilter === 'locked' && bp.learned) return false;

    if (!q) return true;

    const haystack = [
      bp.name || '',
      bp.label || '',
      bp.category || '',
      bp.tier || '',
      bp.description || '',
    ].join(' ').toLowerCase();

    return haystack.includes(q);
  });
}

function capitalize(str) {
  if (!str) return '';
  str = String(str);
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function showToast(message) {
  if (!toastEl) return;
  toastEl.textContent = message;

  toastEl.classList.remove('hidden');
  // force reflow to restart transition
  void toastEl.offsetWidth;
  toastEl.classList.add('show');

  clearTimeout(showToast._timeout);
  showToast._timeout = setTimeout(() => {
    toastEl.classList.remove('show');
    toastEl.classList.add('hidden');
  }, 2200);
}

function renderBlueprints() {
  const filtered = applyFilterAndSearch();
  gridEl.innerHTML = '';

  if (!filtered.length) {
    const empty = document.createElement('div');
    empty.className = 'card';
    empty.innerHTML = `
      <div class="card-header">
        <div class="card-title">No results</div>
      </div>
      <div class="card-description">
        Try adjusting your filters or search query.
      </div>
    `;
    gridEl.appendChild(empty);
    return;
  }

  filtered.forEach((bp) => {
    let cardStateClass = 'locked';
    let statusBadgeClass = 'badge-locked';
    let statusText = 'Locked';

    if (bp.learned) {
      cardStateClass = 'learned';
      statusBadgeClass = 'badge-learned';
      statusText = 'Learned';
    } else if (bp.canLearn) {
      cardStateClass = 'available';
      statusBadgeClass = 'badge-available';
      statusText = 'Learnable';
    }

    const rarityRaw = (bp.rarity || 'common').toLowerCase();
    const rarityLabel = capitalize(rarityRaw);
    const rarityClass = `rarity-pill-${rarityRaw}`;
    const tooltipText = `${rarityLabel} • ${(bp.category || 'Blueprint').toUpperCase()} Blueprint`;

    const card = document.createElement('div');
    card.className = `card ${cardStateClass}`;
    card.dataset.name = bp.name;
    card.dataset.tooltip = tooltipText;

    let statusRowHTML = '';
    if (bp.learned) {
      statusRowHTML = `<span class="card-hint">Unlocked</span>`;
    } else if (bp.canLearn) {
      statusRowHTML = `<button class="learn-btn" data-name="${bp.name}">Learn</button>`;
    } else {
      statusRowHTML = `<span class="card-status-missing">${bp.missing || ''}</span>`;
    }

    card.innerHTML = `
      <div class="card-header">
        <div>
          <div class="card-title">${bp.label}</div>
          <div class="card-tier">${bp.tier || ''}</div>
          <div class="card-meta-row">
            <span class="rarity-pill ${rarityClass}">${rarityLabel}</span>
            <span class="card-category">${bp.category || 'Unsorted'}</span>
          </div>
        </div>
      </div>

      <span class="badge-status ${statusBadgeClass}">${statusText}</span>

      <div class="card-image">
        <img src="nui://ox_inventory/web/images/${bp.name}.png" onerror="this.style.display='none';">
      </div>

      <div class="card-description">${bp.description || ''}</div>

      <div class="card-status-row">
        ${statusRowHTML}
      </div>

      <div class="card-footer">
        <div class="card-id">${bp.name}</div>
        <div class="card-footer-right"></div>
      </div>
    `;

    const learnBtn = card.querySelector('.learn-btn');
    if (learnBtn) {
      learnBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        learnBlueprint(bp.name);
      });
    }

    gridEl.appendChild(card);
  });
}

function learnBlueprint(name) {
  fetch(`https://cx-blueprints/learnBlueprint`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify({ name }),
  }).catch(() => {});
}

// messages from Lua
window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || data.app !== 'cx_bptablet') return;

  if (data.action === 'open') {
    blueprints = data.data || [];
    setOpen(true);
    renderBlueprints();
  }

  if (data.action === 'update') {
    blueprints = data.data || [];
    if (isOpen) renderBlueprints();
  }

  if (data.action === 'close') {
    setOpen(false);
  }

  if (data.action === 'learned') {
    const label = data.label || 'a blueprint';
    showToast(`Learned ${label}`);
  }
});

// close button
if (closeBtn) {
  closeBtn.addEventListener('click', () => {
    fetch(`https://cx-blueprints/close`, {
      method: 'POST',
      body: JSON.stringify({}),
    }).catch(() => {});
  });
}

// search
if (searchInput) {
  searchInput.addEventListener('input', (e) => {
    searchQuery = e.target.value;
    renderBlueprints();
  });
}

// filters
filterButtons.forEach((btn) => {
  btn.addEventListener('click', () => {
    filterButtons.forEach((b) => b.classList.remove('active'));
    btn.classList.add('active');
    activeFilter = btn.dataset.filter;
    renderBlueprints();
  });
});

// safety: hide on load
document.addEventListener('DOMContentLoaded', () => {
  setOpen(false);
});
