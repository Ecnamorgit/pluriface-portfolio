/* Pluriface — comportements communs : menu mobile, apparition au défilement */
(function () {
  const btn = document.getElementById('menu-btn');
  const nav = document.getElementById('nav');
  if (btn && nav) {
    btn.addEventListener('click', () => {
      const open = nav.classList.toggle('open');
      btn.setAttribute('aria-expanded', open);
    });
    nav.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
      nav.classList.remove('open');
      btn.setAttribute('aria-expanded', 'false');
    }));
  }

  /* Formulaire de contact : sans identifiant Formspree, on ouvre un e-mail pré-rempli. */
  const form = document.getElementById('contact-form');
  if (form && form.action.includes('VOTRE_ID')) {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const d = new FormData(form);
      const subject = encodeURIComponent('Projet : ' + d.get('type') + ' — ' + d.get('nom'));
      const body = encodeURIComponent(d.get('message') + '\n\n— ' + d.get('nom') + ' · ' + d.get('email'));
      window.location.href = 'mailto:pluriface@gmail.com?subject=' + subject + '&body=' + body;
    });
  }
  const items = document.querySelectorAll('.reveal');
  if (!('IntersectionObserver' in window)) { items.forEach(el => el.classList.add('in')); return; }
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e, i) => {
      if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
    });
  }, { threshold: 0.12 });
  items.forEach((el, i) => { el.style.transitionDelay = (i % 4) * 60 + 'ms'; io.observe(el); });

})();
