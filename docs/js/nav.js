/**
 * Navigation: sticky header, hamburger menu, active page
 */
const Nav = {
  init() {
    this.nav = document.getElementById('nav');
    this.hamburger = document.getElementById('hamburger');
    this.mobileMenu = document.getElementById('mobileMenu');
    if (!this.nav) return;

    this.bindScroll();
    this.bindHamburger();
    this.setActivePage();
  },

  bindScroll() {
    let ticking = false;
    window.addEventListener('scroll', () => {
      if (!ticking) {
        requestAnimationFrame(() => {
          this.nav.classList.toggle('is-scrolled', window.scrollY > 30);
          ticking = false;
        });
        ticking = true;
      }
    });
    // Initial check
    this.nav.classList.toggle('is-scrolled', window.scrollY > 30);
  },

  bindHamburger() {
    if (!this.hamburger || !this.mobileMenu) return;

    this.hamburger.addEventListener('click', () => {
      const isOpen = this.hamburger.classList.toggle('is-open');
      this.mobileMenu.classList.toggle('is-open', isOpen);
      document.body.style.overflow = isOpen ? 'hidden' : '';
    });

    // Close on link click
    this.mobileMenu.querySelectorAll('.nav__link').forEach(link => {
      link.addEventListener('click', () => {
        this.hamburger.classList.remove('is-open');
        this.mobileMenu.classList.remove('is-open');
        document.body.style.overflow = '';
      });
    });

    // Close on escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.mobileMenu.classList.contains('is-open')) {
        this.hamburger.classList.remove('is-open');
        this.mobileMenu.classList.remove('is-open');
        document.body.style.overflow = '';
      }
    });
  },

  setActivePage() {
    const path = window.location.pathname;
    const page = path.split('/').pop() || 'index.html';

    document.querySelectorAll('.nav__link').forEach(link => {
      const href = link.getAttribute('href');
      link.classList.remove('is-active');
      if (href === page || (page === '' && href === 'index.html')) {
        link.classList.add('is-active');
      }
    });
  }
};
