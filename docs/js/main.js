/**
 * GemMate Website — Main orchestrator
 */
document.addEventListener('DOMContentLoaded', () => {
  // 1. Language
  I18n.init();

  // 2. Navigation
  Nav.init();

  // 3. Scroll animations
  ScrollAnimations.init();

  // 4. Particle background (hero only)
  if (document.getElementById('particleCanvas')) {
    ParticleSystem.init('particleCanvas');
  }

  // 5. Video lazy loading
  initVideoLazy();

  // 6. Smooth scroll for anchor links
  initSmoothScroll();

  // 7. Code block copy buttons
  initCodeCopy();

  // 8. Screenshot gallery lightbox
  if (typeof Gallery !== 'undefined') {
    Gallery.init();
  }

  // 9. Phone tilt follow mouse
  initPhoneTilt();
});

/**
 * YouTube lazy load — show thumbnail, load iframe on click
 */
function initVideoLazy() {
  const containers = document.querySelectorAll('.video-container[data-video-id]');
  containers.forEach(container => {
    container.addEventListener('click', () => {
      const videoId = container.dataset.videoId;
      const iframe = document.createElement('iframe');
      iframe.src = `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0`;
      iframe.setAttribute('allow', 'autoplay; encrypted-media');
      iframe.setAttribute('allowfullscreen', '');
      iframe.setAttribute('loading', 'lazy');
      container.innerHTML = '';
      container.appendChild(iframe);
      container.style.cursor = 'default';
    });
  });
}

/**
 * Smooth scroll for in-page anchors
 */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(link => {
    link.addEventListener('click', (e) => {
      const target = document.querySelector(link.getAttribute('href'));
      if (target) {
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });
}

/**
 * Phone mockup 3D tilt — follows mouse cursor in real time
 */
function initPhoneTilt() {
  const phone = document.querySelector('.phone-mockup--tilt');
  if (!phone) return;
  const hero = phone.closest('.hero') || phone.parentElement;

  // Sensitivity: higher = more tilt. Max ±18deg Y, ±12deg X
  const maxRotY = 18;
  const maxRotX = 12;

  hero.addEventListener('mousemove', (e) => {
    const rect = hero.getBoundingClientRect();
    // -1 to 1, centered
    const x = (e.clientX - rect.left) / rect.width * 2 - 1;
    const y = (e.clientY - rect.top) / rect.height * 2 - 1;

    const rotY = x * maxRotY;
    const rotX = -y * maxRotX;

    phone.style.transform =
      `perspective(1000px) rotateY(${rotY}deg) rotateX(${rotX}deg)`;
  });

  hero.addEventListener('mouseleave', () => {
    phone.style.transform =
      'perspective(1000px) rotateY(-8deg) rotateX(4deg)';
  });

  // Disable on mobile / reduced motion
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches ||
      window.matchMedia('(max-width: 768px)').matches) {
    hero.onmousemove = null;
    hero.onmouseleave = null;
  }
}

/**
 * Code block copy-to-clipboard
 */
function initCodeCopy() {
  document.querySelectorAll('.code-block__copy').forEach(btn => {
    btn.addEventListener('click', () => {
      const code = btn.closest('.code-block').querySelector('code');
      if (!code) return;
      navigator.clipboard.writeText(code.textContent).then(() => {
        const orig = btn.textContent;
        btn.textContent = 'Copied!';
        btn.style.color = 'var(--color-cyan)';
        setTimeout(() => {
          btn.textContent = orig;
          btn.style.color = '';
        }, 2000);
      });
    });
  });
}
