/**
 * Pluriface Portfolio - Interactive JavaScript Engine
 */

document.addEventListener('DOMContentLoaded', () => {
  initNavbar();
  initThemeToggle();
  initProjectFilters();
  // Contact form removed — using direct mailto link instead
  initScrollAnimations();
});

/* --------------------------------------------------------------------------
   1. Navbar Scroll Effect & Mobile Menu
   -------------------------------------------------------------------------- */
function initNavbar() {
  const header = document.getElementById('header');
  const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
  const navMenu = document.getElementById('nav-menu');
  const navLinks = document.querySelectorAll('.nav-link');

  // Sticky header class change
  window.addEventListener('scroll', () => {
    if (window.scrollY > 50) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  });

  // Mobile menu toggle
  if (mobileMenuToggle && navMenu) {
    mobileMenuToggle.addEventListener('click', () => {
      navMenu.classList.toggle('active');
      const icon = mobileMenuToggle.querySelector('i');
      if (navMenu.classList.contains('active')) {
        icon.className = 'fa-solid fa-xmark';
      } else {
        icon.className = 'fa-solid fa-bars';
      }
    });

    // Close menu when clicking links
    navLinks.forEach(link => {
      link.addEventListener('click', () => {
        navMenu.classList.remove('active');
        const icon = mobileMenuToggle.querySelector('i');
        if (icon) icon.className = 'fa-solid fa-bars';
      });
    });
  }

  // Active link scroll spy
  const sections = document.querySelectorAll('section[id]');
  window.addEventListener('scroll', () => {
    const scrollY = window.pageYOffset;
    sections.forEach(current => {
      const sectionHeight = current.offsetHeight;
      const sectionTop = current.offsetTop - 100;
      const sectionId = current.getAttribute('id');
      const link = document.querySelector(`.nav-list a[href*=${sectionId}]`);

      if (link) {
        if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
          link.classList.add('active-link');
        } else {
          link.classList.remove('active-link');
        }
      }
    });
  });
}

/* --------------------------------------------------------------------------
   2. Dark / Light Theme Toggle
   -------------------------------------------------------------------------- */
function initThemeToggle() {
  const themeToggleBtn = document.getElementById('theme-toggle');
  const themeIcon = document.getElementById('theme-icon');

  // Check saved preference
  const savedTheme = localStorage.getItem('pluriface-theme');
  if (savedTheme === 'light') {
    document.documentElement.setAttribute('data-theme', 'light');
    if (themeIcon) themeIcon.className = 'fa-solid fa-sun';
  }

  if (themeToggleBtn && themeIcon) {
    themeToggleBtn.addEventListener('click', () => {
      const currentTheme = document.documentElement.getAttribute('data-theme');
      if (currentTheme === 'light') {
        document.documentElement.removeAttribute('data-theme');
        localStorage.setItem('pluriface-theme', 'dark');
        themeIcon.className = 'fa-solid fa-moon';
      } else {
        document.documentElement.setAttribute('data-theme', 'light');
        localStorage.setItem('pluriface-theme', 'light');
        themeIcon.className = 'fa-solid fa-sun';
      }
    });
  }
}

/* --------------------------------------------------------------------------
   3. Interactive Project Filters
   -------------------------------------------------------------------------- */
function initProjectFilters() {
  const filterBtns = document.querySelectorAll('.filter-btn');
  const projectCards = document.querySelectorAll('.project-card');

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      // Remove active class from all
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const filterValue = btn.getAttribute('data-filter');

      projectCards.forEach(card => {
        const categories = card.getAttribute('data-category').split(' ');
        
        if (filterValue === 'all' || categories.includes(filterValue)) {
          card.style.display = 'flex';
          setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0) scale(1)';
          }, 50);
        } else {
          card.style.opacity = '0';
          card.style.transform = 'translateY(20px) scale(0.95)';
          setTimeout(() => {
            card.style.display = 'none';
          }, 300);
        }
      });
    });
  });
}

/* --------------------------------------------------------------------------
   4. Intersection Observer for Scroll Animations
   -------------------------------------------------------------------------- */
function initScrollAnimations() {
  const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
  };

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animated-in');
        observer.unobserve(entry.target);
      }
    });
  }, observerOptions);

  document.querySelectorAll('.skill-card, .project-card, .about-content, .contact-wrapper').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(30px)';
    el.style.transition = 'opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1), transform 0.6s cubic-bezier(0.4, 0, 0.2, 1)';
    observer.observe(el);
  });

  // Define keyframes in JS style mutation
  const style = document.createElement('style');
  style.innerHTML = `
    .animated-in {
      opacity: 1 !important;
      transform: translateY(0) !important;
    }
  `;
  document.head.appendChild(style);
}

/* --------------------------------------------------------------------------
   5. Interactive Three.js 3D Pluriface Gem Showcase (Hero Section)
   -------------------------------------------------------------------------- */
function initHero3DLogo() {
  const container = document.getElementById('hero-3d-logo-box');
  if (!container || typeof THREE === 'undefined') return;

  container.innerHTML = '';

  const width = container.clientWidth || 450;
  const height = container.clientHeight || 240;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
  camera.position.z = 3.5;

  const renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
  renderer.setSize(width, height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  container.appendChild(renderer.domElement);

  // 1. Faceted Icosahedron Gem Geometry ("Pluri-face")
  const geometry = new THREE.IcosahedronGeometry(1.2, 0);

  // 2. Shiny Metallic Material with Sunset Specular
  const material = new THREE.MeshPhongMaterial({
    color: 0xff5e62,
    emissive: 0x3a0015,
    specular: 0xffa352,
    shininess: 90,
    flatShading: true
  });

  const mesh = new THREE.Mesh(geometry, material);
  scene.add(mesh);

  // 3. Wireframe edges glow
  const wireframeGeo = new THREE.WireframeGeometry(geometry);
  const wireframeMat = new THREE.LineBasicMaterial({
    color: 0xffa352,
    transparent: true,
    opacity: 0.75
  });
  const wireframe = new THREE.LineSegments(wireframeGeo, wireframeMat);
  mesh.add(wireframe);

  // 4. Orbiting Particles Ring around the 3D Gem
  const particlesGeo = new THREE.BufferGeometry();
  const particleCount = 80;
  const positions = new Float32Array(particleCount * 3);

  for (let i = 0; i < particleCount * 3; i += 3) {
    const angle = Math.random() * Math.PI * 2;
    const radius = 1.8 + Math.random() * 0.8;
    positions[i] = Math.cos(angle) * radius;
    positions[i + 1] = (Math.random() - 0.5) * 1.2;
    positions[i + 2] = Math.sin(angle) * radius;
  }

  particlesGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  const particlesMat = new THREE.PointsMaterial({
    color: 0xffa352,
    size: 0.05,
    transparent: true,
    opacity: 0.8
  });
  const particleSystem = new THREE.Points(particlesGeo, particlesMat);
  scene.add(particleSystem);

  // 5. Lighting
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
  scene.add(ambientLight);

  const light1 = new THREE.PointLight(0xff5e62, 2, 10);
  light1.position.set(3, 3, 3);
  scene.add(light1);

  const light2 = new THREE.PointLight(0x00f0ff, 2, 10);
  light2.position.set(-3, -2, 2);
  scene.add(light2);

  // Mouse Interaction
  let mouseX = 0;
  let mouseY = 0;
  window.addEventListener('mousemove', (e) => {
    mouseX = (e.clientX / window.innerWidth - 0.5) * 0.8;
    mouseY = (e.clientY / window.innerHeight - 0.5) * 0.8;
  });

  // Resize Handler
  window.addEventListener('resize', () => {
    const w = container.clientWidth;
    const h = container.clientHeight;
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
    renderer.setSize(w, h);
  });

  // Animation Loop
  function animate() {
    requestAnimationFrame(animate);

    mesh.rotation.x += 0.008;
    mesh.rotation.y += 0.012;

    particleSystem.rotation.y -= 0.004;

    mesh.rotation.x += (mouseY - mesh.rotation.x) * 0.03;
    mesh.rotation.y += (mouseX - mesh.rotation.y) * 0.03;

    renderer.render(scene, camera);
  }

  animate();
}
