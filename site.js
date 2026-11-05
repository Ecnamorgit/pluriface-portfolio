/* Pluriface — comportements communs : menu mobile, apparition au défilement */
(function () {
  /* Coordonnées masquées pour les robots : écrites à l'envers dans data-m / data-t,
     remises à l'endroit ici. Un humain voit et clique normalement ; un aspirateur
     d'adresses qui lit le HTML brut ne trouve ni e-mail ni numéro. */
  const decode = (s) => s.split('').reverse().join('');
  document.querySelectorAll('[data-m]').forEach(a => { const m = decode(a.dataset.m); a.href = 'mailto:' + m; a.textContent = m; });
  document.querySelectorAll('[data-t]').forEach(a => { const t = decode(a.dataset.t); a.href = 'tel:+33' + t.replace(/\s/g, '').slice(1); a.textContent = t; });

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
      window.location.href = 'mailto:' + decode(document.querySelector('[data-m]').dataset.m) + '?subject=' + subject + '&body=' + body;
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
