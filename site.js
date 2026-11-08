/* Pluriface — comportements communs : menu mobile, apparition au défilement */
(function () {
  window.pluriface = true;
  /* L'e-mail reste écrit à l'envers dans data-m et remis à l'endroit ici : c'est
     l'adresse que cherchent les aspirateurs, pas le numéro. Le téléphone, lui, est
     désormais en clair dans le HTML et déclaré dans les données structurées — sans
     quoi Google ne voyait aucune coordonnée, ce qui coûte en référencement local. */
  const decode = (s) => s.split('').reverse().join('');
  document.querySelectorAll('[data-m]').forEach(a => { const m = decode(a.dataset.m); a.href = 'mailto:' + m; a.textContent = m; });

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

  /* Formulaire de contact.

     POINT_ENVOI est la SEULE ligne à renseigner le jour où un vrai point d'envoi
     existe : l'adresse d'un service de formulaire, ou celle du script d'envoi du
     NAS. Tant qu'elle est vide, le formulaire prépare un e-mail.

     Et dans les deux cas, le message est AUSSI affiché prêt à copier. C'est le
     point qui manquait : sur un téléphone sans application de courrier configurée,
     mailto: n'ouvre rien du tout, et le visiteur se retrouvait devant un bouton
     mort sans le savoir. Un envoi qui échoue doit le dire. */
  const POINT_ENVOI = '';

  const form = document.getElementById('contact-form');
  const repli = document.getElementById('form-fallback');

  if (form) {
    if (POINT_ENVOI) form.action = POINT_ENVOI;

    const adresse = () => {
      const a = document.querySelector('[data-m]');
      return a ? decode(a.dataset.m) : '';
    };

    const message = (d) =>
      d.get('message') + '\n\n— ' + d.get('nom') + ' · ' + d.get('email') +
      '\nType de projet : ' + d.get('type');

    const afficherRepli = (titre, corps, destinataire) => {
      if (!repli) return;
      repli.textContent = '';

      const h = document.createElement('p');
      h.className = 'fallback-title';
      h.textContent = titre;
      repli.appendChild(h);

      const p = document.createElement('p');
      p.textContent = 'Copiez ce message et envoyez-le à ';
      const lien = document.createElement('a');
      lien.href = 'mailto:' + destinataire;
      lien.textContent = destinataire;
      p.appendChild(lien);
      p.appendChild(document.createTextNode(' .'));
      repli.appendChild(p);

      const zone = document.createElement('textarea');
      zone.readOnly = true;
      zone.rows = 6;
      zone.value = corps;
      zone.setAttribute('aria-label', 'Votre message, prêt à copier');
      repli.appendChild(zone);

      const copier = document.createElement('button');
      copier.type = 'button';
      copier.className = 'btn btn-ghost btn-sm';
      copier.textContent = 'Copier le message';
      copier.addEventListener('click', () => {
        zone.select();
        const dit = (t) => { copier.textContent = t; setTimeout(() => { copier.textContent = 'Copier le message'; }, 2500); };
        if (navigator.clipboard) {
          navigator.clipboard.writeText(corps).then(() => dit('Copié'), () => dit('Sélectionnez puis copiez'));
        } else {
          dit('Sélectionnez puis copiez');
        }
      });
      repli.appendChild(copier);

      repli.hidden = false;
      repli.setAttribute('tabindex', '-1');
      repli.focus();
    };

    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const d = new FormData(form);
      const corps = message(d);
      const dest = adresse();

      if (!POINT_ENVOI) {
        const sujet = 'Projet : ' + d.get('type') + ' — ' + d.get('nom');
        window.location.href = 'mailto:' + dest +
          '?subject=' + encodeURIComponent(sujet) +
          '&body=' + encodeURIComponent(corps);
        afficherRepli(
          'Votre logiciel de courrier devrait s\'ouvrir.',
          corps, dest);
        return;
      }

      const bouton = form.querySelector('button[type="submit"]');
      const libelle = bouton ? bouton.textContent : '';
      if (bouton) { bouton.disabled = true; bouton.textContent = 'Envoi…'; }

      fetch(POINT_ENVOI, { method: 'POST', body: d, headers: { Accept: 'application/json' } })
        .then((r) => {
          if (!r.ok) throw new Error(r.status);
          if (repli) {
            repli.textContent = '';
            const p = document.createElement('p');
            p.className = 'fallback-title';
            p.textContent = 'Message envoyé. Je réponds sous 48 h.';
            repli.appendChild(p);
            repli.hidden = false;
            repli.setAttribute('tabindex', '-1');
            repli.focus();
          }
          form.reset();
        })
        .catch(() => afficherRepli(
          "L'envoi n'a pas abouti.", corps, dest))
        .then(() => { if (bouton) { bouton.disabled = false; bouton.textContent = libelle; } });
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
