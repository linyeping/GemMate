/**
 * GemMate Website — Screenshot Gallery Lightbox
 *
 * Click any .phone-mockup__screen img to open fullscreen lightbox.
 * Supports keyboard (Esc / Arrow) and touch swipe navigation.
 */
const Gallery = (() => {
  let overlay = null;
  let imgEl  = null;
  let counter = null;
  let images = [];
  let current = 0;
  let touchStartX = 0;

  /* ---- Build DOM once ---- */
  function build() {
    overlay = document.createElement('div');
    overlay.className = 'gallery-overlay';
    overlay.innerHTML = `
      <button class="gallery-close" aria-label="Close">&times;</button>
      <button class="gallery-prev" aria-label="Previous">&#8249;</button>
      <button class="gallery-next" aria-label="Next">&#8250;</button>
      <div class="gallery-img-wrap">
        <img class="gallery-img" alt="">
      </div>
      <div class="gallery-counter"></div>
    `;
    document.body.appendChild(overlay);

    imgEl   = overlay.querySelector('.gallery-img');
    counter = overlay.querySelector('.gallery-counter');

    overlay.querySelector('.gallery-close').addEventListener('click', close);
    overlay.querySelector('.gallery-prev').addEventListener('click', prev);
    overlay.querySelector('.gallery-next').addEventListener('click', next);
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.classList.contains('gallery-img-wrap')) close();
    });

    /* Touch */
    overlay.addEventListener('touchstart', (e) => { touchStartX = e.changedTouches[0].clientX; }, { passive: true });
    overlay.addEventListener('touchend', (e) => {
      const dx = e.changedTouches[0].clientX - touchStartX;
      if (Math.abs(dx) > 50) dx > 0 ? prev() : next();
    });

    /* Keyboard */
    document.addEventListener('keydown', (e) => {
      if (!overlay.classList.contains('is-open')) return;
      if (e.key === 'Escape') close();
      if (e.key === 'ArrowLeft')  prev();
      if (e.key === 'ArrowRight') next();
    });
  }

  /* ---- Navigation ---- */
  function show(index) {
    current = ((index % images.length) + images.length) % images.length;
    imgEl.src = images[current].src;
    imgEl.alt = images[current].alt || '';
    counter.textContent = `${current + 1} / ${images.length}`;
  }

  function prev() { show(current - 1); }
  function next() { show(current + 1); }

  function open(index) {
    show(index);
    overlay.classList.add('is-open');
    document.body.style.overflow = 'hidden';
  }

  function close() {
    overlay.classList.remove('is-open');
    document.body.style.overflow = '';
  }

  /* ---- Init ---- */
  function init() {
    const imgs = document.querySelectorAll('.phone-mockup__screen img');
    if (!imgs.length) return;

    images = Array.from(imgs);
    build();

    images.forEach((img, i) => {
      img.style.cursor = 'zoom-in';
      img.addEventListener('click', (e) => {
        e.stopPropagation();
        open(i);
      });
    });
  }

  return { init };
})();
