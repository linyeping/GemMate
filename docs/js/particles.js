/**
 * Particle network background for hero section
 */
const ParticleSystem = {
  canvas: null,
  ctx: null,
  particles: [],
  mouse: { x: -1000, y: -1000 },
  animId: null,
  dpr: 1,

  init(canvasId) {
    this.canvas = document.getElementById(canvasId);
    if (!this.canvas) return;

    // Respect reduced motion
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    this.ctx = this.canvas.getContext('2d');
    this.dpr = Math.min(window.devicePixelRatio || 1, 2);
    this.resize();
    this.createParticles();
    this.bindEvents();
    this.animate();
  },

  resize() {
    const rect = this.canvas.parentElement.getBoundingClientRect();
    this.canvas.width = rect.width * this.dpr;
    this.canvas.height = rect.height * this.dpr;
    this.canvas.style.width = rect.width + 'px';
    this.canvas.style.height = rect.height + 'px';
    this.ctx.scale(this.dpr, this.dpr);
    this.width = rect.width;
    this.height = rect.height;
  },

  createParticles() {
    const count = Math.min(70, Math.floor((this.width * this.height) / 15000));
    this.particles = [];
    for (let i = 0; i < count; i++) {
      this.particles.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        vx: (Math.random() - 0.5) * 0.4,
        vy: (Math.random() - 0.5) * 0.4,
        r: Math.random() * 1.5 + 0.5,
        opacity: Math.random() * 0.5 + 0.2,
      });
    }
  },

  bindEvents() {
    let resizeTimer;
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(() => {
        this.resize();
        this.createParticles();
      }, 200);
    });

    // Only track mouse on desktop
    if (window.innerWidth > 768) {
      this.canvas.parentElement.addEventListener('mousemove', (e) => {
        const rect = this.canvas.getBoundingClientRect();
        this.mouse.x = e.clientX - rect.left;
        this.mouse.y = e.clientY - rect.top;
      });

      this.canvas.parentElement.addEventListener('mouseleave', () => {
        this.mouse.x = -1000;
        this.mouse.y = -1000;
      });
    }
  },

  animate() {
    this.ctx.clearRect(0, 0, this.width, this.height);

    const maxDist = 120;

    for (let i = 0; i < this.particles.length; i++) {
      const p = this.particles[i];

      // Move
      p.x += p.vx;
      p.y += p.vy;

      // Bounce off edges
      if (p.x < 0 || p.x > this.width) p.vx *= -1;
      if (p.y < 0 || p.y > this.height) p.vy *= -1;

      // Mouse interaction
      const mdx = this.mouse.x - p.x;
      const mdy = this.mouse.y - p.y;
      const md = Math.sqrt(mdx * mdx + mdy * mdy);
      if (md < 150) {
        p.x -= mdx * 0.01;
        p.y -= mdy * 0.01;
      }

      // Draw particle
      this.ctx.beginPath();
      this.ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      this.ctx.fillStyle = `rgba(77, 208, 225, ${p.opacity})`;
      this.ctx.fill();

      // Draw connections
      for (let j = i + 1; j < this.particles.length; j++) {
        const p2 = this.particles[j];
        const dx = p.x - p2.x;
        const dy = p.y - p2.y;
        const dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < maxDist) {
          const alpha = (1 - dist / maxDist) * 0.15;
          this.ctx.beginPath();
          this.ctx.moveTo(p.x, p.y);
          this.ctx.lineTo(p2.x, p2.y);
          this.ctx.strokeStyle = `rgba(77, 208, 225, ${alpha})`;
          this.ctx.lineWidth = 0.5;
          this.ctx.stroke();
        }
      }
    }

    this.animId = requestAnimationFrame(() => this.animate());
  },

  destroy() {
    if (this.animId) cancelAnimationFrame(this.animId);
  }
};
