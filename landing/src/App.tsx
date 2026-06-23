import {
  Anchor,
  BookOpen,
  Bug,
  CloudSun,
  Compass,
  Download,
  Fish,
  Gauge,
  HeartPulse,
  Home,
  Map,
  MapPin,
  Moon,
  Radio,
  Send,
  ShoppingBasket,
  Store,
  Users,
  Waves,
  Wind,
  Youtube,
  type LucideIcon,
} from "lucide-react";
import { externalLinkProps, links } from "./config";

type Feature = {
  title: string;
  text: string;
  Icon: LucideIcon;
};

type Step = {
  number: string;
  title: string;
  text: string;
  image: string;
};

type Screenshot = {
  title: string;
  image: string;
};

const features: Feature[] = [
  {
    title: "Озеро Агамим",
    text: "Первый открытый водоем с разными точками ловли.",
    Icon: Map,
  },
  {
    title: "Точки ловли",
    text: "Камыши, ряска, старая лодка, глубокие ямы и спокойная вода.",
    Icon: MapPin,
  },
  {
    title: "Снасти и магазин",
    text: "Удочки, лески, поводки, крючки, поплавки, наживки, еда и одежда.",
    Icon: ShoppingBasket,
  },
  {
    title: "Поклевка и вываживание",
    text: "Заброс, ожидание, подсечка, натяжение лески и борьба с рыбой.",
    Icon: Fish,
  },
  {
    title: "Погода, время и ветер",
    text: "Время суток, температура, ветер и состояние рыбака влияют на рыбалку.",
    Icon: CloudSun,
  },
  {
    title: "Рыбная гавань",
    text: "Продажа рыбы, рынок, контракты, репутация и прогресс.",
    Icon: Anchor,
  },
];

const steps: Step[] = [
  {
    number: "01",
    title: "Выбери точку",
    text: "Изучи карту Озера Агамим и найди подходящее место.",
    image: "/steps/choose-spot.png",
  },
  {
    number: "02",
    title: "Собери снасть",
    text: "Подбери удочку, леску, крючок, поплавок и наживку.",
    image: "/steps/assemble-tackle.png",
  },
  {
    number: "03",
    title: "Дождись поклевки",
    text: "Следи за поплавком, погодой, глубиной и временем суток.",
    image: "/steps/wait-bite.png",
  },
  {
    number: "04",
    title: "Вываживай рыбу",
    text: "Удерживай натяжение лески и доведи борьбу до трофея.",
    image: "/steps/reel-fish.png",
  },
];

const screenshots: Screenshot[] = [
  {
    title: "Карта Озера Агамим",
    image: "/screenshots/agamin-map.jpg",
  },
  {
    title: "Вываживание",
    image: "/screenshots/gameplay-reeling.jpg",
  },
  {
    title: "Ночная рыбалка",
    image: "/screenshots/night-fishing.jpg",
  },
  {
    title: "Энциклопедия рыб",
    image: "/screenshots/fish-encyclopedia.jpg",
  },
  {
    title: "Магазин наживок",
    image: "/screenshots/shop-baits.jpg",
  },
  {
    title: "Магазин удочек",
    image: "/screenshots/shop-rods.jpg",
  },
  {
    title: "Настройка глубины",
    image: "/screenshots/float-depth-night.jpg",
  },
  {
    title: "Tuman FM",
    image: "/screenshots/tuman-fm-settings.jpg",
  },
  {
    title: "Навыки маховой ловли",
    image: "/screenshots/skill-tree.jpg",
  },
];

const fishingFactors: Feature[] = [
  { title: "Глубина", text: "Поплавок и дистанция меняют ожидание поклевки.", Icon: Waves },
  { title: "Наживка", text: "Разная рыба реагирует на разные приманки.", Icon: Fish },
  { title: "Крючок", text: "Размер снасти важен для подсечки и удержания.", Icon: Gauge },
  { title: "Погода", text: "Состояние водоема зависит от условий дня.", Icon: CloudSun },
  { title: "Ветер", text: "Направление и сила ветра влияют на ловлю.", Icon: Wind },
  { title: "Самочувствие", text: "Температура и состояние рыбака тоже имеют значение.", Icon: HeartPulse },
  { title: "Снасть", text: "Удочка, леска и поводок задают пределы борьбы.", Icon: Compass },
];

const inProgress: Feature[] = [
  {
    title: "Река Ивница",
    text: "Следующий водоем с течением и новыми условиями ловли.",
    Icon: Waves,
  },
  {
    title: "Ловля на течении",
    text: "Будущая механика проводки для проточной воды.",
    Icon: Radio,
  },
  {
    title: "Спиннинг и катушки",
    text: "Сейчас отключены в beta-сборке и вернутся после доработки.",
    Icon: Gauge,
  },
  {
    title: "Дом рыбака",
    text: "Будет расширен до отдельной сцены для отдыха, еды, снастей и трофеев.",
    Icon: Home,
  },
  {
    title: "Будущие водоёмы",
    text: "Новые места уже видны на карте как контент в разработке и откроются позже.",
    Icon: Map,
  },
  {
    title: "Пресеты снастей",
    text: "Запланированы сохранённые сборки для быстрого переключения готовых комплектов.",
    Icon: BookOpen,
  },
];

const navItems = [
  { label: "Об игре", href: "#about" },
  { label: "Особенности", href: "#features" },
  { label: "Скриншоты", href: "#screenshots" },
  { label: "В разработке", href: "#roadmap" },
  { label: "ЗБТ", href: "#zbt" },
];

function App() {
  return (
    <div className="site-shell">
      <header className="site-header">
        <a className="brand" href="#top" aria-label="Рыбное Место">
          <span className="brand-mark">
            <Fish size={24} aria-hidden="true" />
          </span>
          <span>Рыбное Место</span>
        </a>

        <nav className="main-nav" aria-label="Главная навигация">
          {navItems.map((item) => (
            <a key={item.href} href={item.href}>
              {item.label}
            </a>
          ))}
        </nav>

        <div className="social-links" aria-label="Социальные ссылки">
          <a {...externalLinkProps(links.telegram)} aria-label="Telegram">
            <Send size={18} aria-hidden="true" />
          </a>
          <a {...externalLinkProps(links.vk)} aria-label="VK">
            VK
          </a>
          <a {...externalLinkProps(links.youtube)} aria-label="YouTube">
            <Youtube size={19} aria-hidden="true" />
          </a>
        </div>
      </header>

      <main id="top">
        <section className="hero" aria-labelledby="hero-title">
          <div className="hero-overlay" />
          <div className="section-inner hero-inner">
            <p className="eyebrow">Android beta · Gagger Studio</p>
            <h1 id="hero-title">Рыбное Место</h1>
            <p className="hero-lead">
              Атмосферная мобильная рыбалка с живыми водоемами, снастями и настоящим
              ожиданием поклевки.
            </p>
            <p className="hero-copy">
              Выбирай точку на озере, собирай снасть, следи за погодой, жди поклевку и
              вываживай рыбу в своем темпе.
            </p>
            <div className="hero-actions" aria-label="Основные действия">
              <a className="button button-primary" {...externalLinkProps(links.apk)}>
                <Download size={20} aria-hidden="true" />
                Скачать APK
              </a>
              <a className="button button-secondary" {...externalLinkProps(links.telegram)}>
                <Users size={20} aria-hidden="true" />
                Вступить в ЗБТ
              </a>
            </div>
            <p className="hero-meta">Android · Beta build · Русский язык · Игра в разработке</p>
          </div>
        </section>

        <section className="section" id="about" aria-labelledby="about-title">
          <div className="section-inner section-grid">
            <div className="section-heading">
              <p className="eyebrow">Что уже есть</p>
              <h2 id="about-title">Рыбалка с ритмом настоящего ожидания</h2>
            </div>
            <p className="section-intro">
              В основе игры - Озеро Агамим, выбор места, подбор снастей, погода, время
              суток и спокойная борьба с рыбой без лишних обещаний будущих режимов.
            </p>
          </div>
        </section>

        <section className="section section-tight" id="features" aria-labelledby="features-title">
          <div className="section-inner">
            <div className="section-heading centered">
              <p className="eyebrow">Особенности</p>
              <h2 id="features-title">Что уже есть в игре</h2>
            </div>

            <div className="feature-grid">
              {features.map(({ title, text, Icon }) => (
                <article className="feature-card" key={title}>
                  <Icon size={30} aria-hidden="true" />
                  <h3>{title}</h3>
                  <p>{text}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="radio-section" aria-labelledby="radio-title">
          <div className="section-inner radio-inner">
            <div className="radio-copy">
              <p className="eyebrow">Tuman FM</p>
              <h2 id="radio-title">Радио у воды</h2>
              <p>
                Tuman FM - отдельная игровая радиостанция, а не просто замена фоновой
                музыки. В эфире можно слушать треки, ловить сводки о погоде, новости
                гавани и полезные подсказки по рыбалке. Иногда радио намекает, где
                появился редкий клёв.
              </p>
              <div className="radio-points" aria-label="Возможности Tuman FM">
                <span>Музыка в эфире</span>
                <span>Сводки погоды</span>
                <span>Подсказки по клёву</span>
                <span>Редкие места</span>
              </div>
            </div>
            <figure className="radio-preview">
              <img src="/screenshots/tuman-fm-settings.jpg" alt="Настройки Tuman FM" loading="lazy" />
              <figcaption>
                <Radio size={18} aria-hidden="true" />
                Tuman FM имеет отдельную громкость и работает как внутриигровой эфир.
              </figcaption>
            </figure>
          </div>
        </section>

        <section className="section" aria-labelledby="loop-title">
          <div className="section-inner">
            <div className="section-heading centered">
              <p className="eyebrow">Игровой цикл</p>
              <h2 id="loop-title">Как устроена игра</h2>
            </div>

            <div className="steps-grid">
              {steps.map((step) => (
                <article className="step-card" key={step.title}>
                  <img src={step.image} alt="" loading="lazy" />
                  <div className="step-content">
                    <span>{step.number}</span>
                    <h3>{step.title}</h3>
                    <p>{step.text}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="section screenshots-section" id="screenshots" aria-labelledby="screenshots-title">
          <div className="section-inner">
            <div className="section-heading centered">
              <p className="eyebrow">Скриншоты</p>
              <h2 id="screenshots-title">Скриншоты из игры</h2>
            </div>

            <div className="screenshots-grid">
              {screenshots.map((screenshot) => (
                <figure className="screenshot-card" key={screenshot.title}>
                  <div className="screenshot-frame">
                    <img src={screenshot.image} alt={screenshot.title} loading="lazy" />
                  </div>
                  <figcaption>{screenshot.title}</figcaption>
                </figure>
              ))}
            </div>
          </div>
        </section>

        <section className="section factors-section" aria-labelledby="factors-title">
          <div className="section-inner">
            <div className="section-heading centered">
              <p className="eyebrow">Условия</p>
              <h2 id="factors-title">Что влияет на рыбалку</h2>
            </div>

            <div className="factor-strip">
              {fishingFactors.map(({ title, text, Icon }) => (
                <article className="factor-card" key={title}>
                  <Icon size={25} aria-hidden="true" />
                  <div>
                    <h3>{title}</h3>
                    <p>{text}</p>
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="section roadmap-section" id="roadmap" aria-labelledby="roadmap-title">
          <div className="section-inner">
            <div className="section-heading centered">
              <p className="eyebrow">Честный статус</p>
              <h2 id="roadmap-title">В разработке</h2>
              <p className="section-note">
                Эти пункты указаны как планы и доработки, а не как готовые возможности
                текущей beta-сборки.
              </p>
            </div>

            <div className="roadmap-grid">
              {inProgress.map(({ title, text, Icon }) => (
                <article className="roadmap-card" key={title}>
                  <div className="roadmap-card-head">
                    <span className="badge">В разработке</span>
                    <Icon size={28} aria-hidden="true" />
                  </div>
                  <h3>{title}</h3>
                  <p>{text}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="cta-section" id="zbt" aria-labelledby="zbt-title">
          <div className="section-inner cta-inner">
            <div>
              <p className="eyebrow">ЗБТ</p>
              <h2 id="zbt-title">Помоги улучшить игру</h2>
              <p>
                Игра находится в активной разработке. В тестовой версии возможны ошибки,
                временная графика и изменения баланса. Скачай APK, попробуй игру и отправь
                отзыв.
              </p>
            </div>
            <div className="cta-actions">
              <a className="button button-primary" {...externalLinkProps(links.apk)}>
                <Download size={20} aria-hidden="true" />
                Скачать тестовую версию
              </a>
              <a className="button button-secondary" {...externalLinkProps(links.bugReport)}>
                <Bug size={20} aria-hidden="true" />
                Сообщить об ошибке
              </a>
              <a className="button button-ghost" {...externalLinkProps(links.telegram)}>
                <Send size={20} aria-hidden="true" />
                Вступить в Telegram
              </a>
            </div>
          </div>
        </section>
      </main>

      <footer className="site-footer">
        <div className="section-inner footer-inner">
          <a className="brand footer-brand" href="#top" aria-label="Рыбное Место">
            <span className="brand-mark">
              <Fish size={24} aria-hidden="true" />
            </span>
            <span>
              Рыбное Место
              <small>Gagger Studio</small>
            </span>
          </a>
          <nav aria-label="Ссылки в подвале">
            <a {...externalLinkProps(links.apk)}>APK</a>
            <a href="#zbt">ЗБТ</a>
            <a {...externalLinkProps(links.telegram)}>Telegram</a>
            <a {...externalLinkProps(links.bugReport)}>Сообщить об ошибке</a>
            <a {...externalLinkProps(links.privacy)}>Privacy Policy</a>
          </nav>
        </div>
      </footer>
    </div>
  );
}

export default App;
