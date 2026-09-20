import { Component } from 'inferno';
import { useBackend } from '../backend';
import { Box, Icon } from '../components';
import { NtosWindow } from '../layouts';

type Palette = {
  accent: string;
  chrome: string;
  deep: string;
  line: string;
  text: string;
  muted: string;
  disabled: string;
  surface: string;
  canvas: string;
  secure: string;
  danger: string;
  notice: string;
  noticeText: string;
};

const PALETTES: Record<string, Palette> = {
  dark: {
    accent: '#4a9eff',
    chrome: '#1b1e24',
    deep: '#101217',
    line: '#33394a',
    text: '#e6e9ef',
    muted: '#8b93a3',
    disabled: '#4d5361',
    surface: '#1c1f26',
    canvas: '#15171c',
    secure: '#57c785',
    danger: '#ff8080',
    notice: '#3a2f1c',
    noticeText: '#f0c674',
  },
  light: {
    accent: '#1a73e8',
    chrome: '#dfe3ea',
    deep: '#c3cad4',
    line: '#aab3c0',
    text: '#1f2328',
    muted: '#5f6672',
    disabled: '#a7aebb',
    surface: '#ffffff',
    canvas: '#f2f3f5',
    secure: '#1e8e3e',
    danger: '#c5221f',
    notice: '#fdf3d8',
    noticeText: '#7a5b12',
  },
};

const FRAME_ADDRESS =
  /^https:\/\/[a-z0-9.-]{4,64}\/i\/[a-f0-9]{32}\/[a-z0-9][a-z0-9-]{0,62}$/;
const FRAME_SANDBOX = 'allow-scripts';
const FRAME_POLICY = [
  "default-src 'none'",
  "script-src 'unsafe-inline'",
  "style-src 'unsafe-inline'",
  'img-src https: data:',
  'media-src https:',
  "font-src data:",
  "connect-src 'none'",
  "form-action 'none'",
  "frame-src 'none'",
  "child-src 'none'",
  "worker-src 'none'",
  "object-src 'none'",
  "base-uri 'none'",
  'sandbox allow-scripts',
].join('; ');
const PROBE_TIMEOUT = 700;
const LAG_TICK = 1000;
const LAG_LIMIT = 4000;
const CSP_PROBE =
  '<meta http-equiv="Content-Security-Policy" content="script-src \'none\'">' +
  '<script>parent.postMessage("scpnet-probe-csp","*")</script>';
const SANDBOX_PROBE =
  '<script>parent.postMessage("scpnet-probe-sandbox","*")</script>';

let rendererCheck: Promise<boolean> | null = null;

const escapes = (): Promise<boolean> =>
  new Promise((resolve) => {
    let settled = false;
    const frames: HTMLIFrameElement[] = [];
    const finish = (leaked: boolean) => {
      if (settled) {
        return;
      }
      settled = true;
      window.removeEventListener('message', listener);
      window.clearTimeout(timer);
      for (const frame of frames) {
        frame.remove();
      }
      resolve(leaked);
    };
    const listener = (event: MessageEvent) => {
      if (
        event.data === 'scpnet-probe-csp' ||
        event.data === 'scpnet-probe-sandbox'
      ) {
        finish(true);
      }
    };
    const timer = window.setTimeout(() => finish(false), PROBE_TIMEOUT);
    window.addEventListener('message', listener);
    try {
      const probes: [string, string | null][] = [
        [CSP_PROBE, null],
        [SANDBOX_PROBE, ''],
      ];
      for (const [markup, sandbox] of probes) {
        const frame = document.createElement('iframe');
        frame.style.display = 'none';
        if (sandbox !== null) {
          frame.setAttribute('sandbox', sandbox);
        }
        frame.srcdoc = markup;
        document.body.appendChild(frame);
        frames.push(frame);
      }
    } catch {
      finish(true);
    }
  });

const rendererAllows = (): Promise<boolean> => {
  if (!rendererCheck) {
    rendererCheck = (async () => {
      const frame = document.createElement('iframe');
      if (!('sandbox' in frame) || !('srcdoc' in frame)) {
        return false;
      }
      return !(await escapes());
    })().catch(() => false);
  }
  return rendererCheck;
};

type SitePage = {
  slug: string;
  title: string;
};

type Site = {
  id: string;
  domain: string;
  title: string;
  version: string;
  icon?: string;
  pages: SitePage[];
};

type Page = {
  site_id: string;
  slug: string;
  version: string;
  title: string;
  frame: string | null;
  text: string;
};

type Found = {
  site_id: string;
  slug: string;
  title: string;
  snippet: string;
};

type Tab = {
  id: number;
  title: string;
  active: boolean;
};

type Data = {
  tabs: Tab[];
  can_open_tab: boolean;
  available: boolean;
  loading: boolean;
  catalog: Site[];
  site: Site | null;
  page: Page | null;
  view: string;
  address: string;
  has_back: boolean;
  has_forward: boolean;
  theme: string;
  search: {
    query: string | null;
    results: Found[];
    pending: boolean;
    error: string | null;
  };
  login: {
    code: string | null;
    pending: boolean;
    retry_seconds: number;
    error: string | null;
  };
};

const palette = (data: Data) => PALETTES[data.theme] || PALETTES.dark;

type FieldProps = {
  value: string;
  placeholder: string;
  height: string;
  fontSize: string;
  color: string;
  onEnter: (value: string) => void;
};

class Field extends Component<FieldProps> {
  private input: HTMLInputElement | null = null;

  componentDidMount() {
    if (this.input) {
      this.input.value = this.props.value;
    }
  }

  componentDidUpdate(prevProps: FieldProps) {
    if (
      this.input &&
      prevProps.value !== this.props.value &&
      document.activeElement !== this.input
    ) {
      this.input.value = this.props.value;
    }
  }

  render() {
    const { placeholder, height, fontSize, color, onEnter } = this.props;
    return (
      <input
        ref={(node: any) => {
          this.input = node;
        }}
        placeholder={placeholder}
        maxLength={120}
        onKeyDown={(event: any) => {
          if (event.keyCode === 13) {
            onEnter(event.target.value);
            event.target.blur();
          }
        }}
        style={{
          flex: '1',
          'min-width': '0',
          width: 'auto',
          height: height,
          background: 'transparent',
          border: '0',
          outline: 'none',
          padding: '0',
          color: color,
          'font-family': 'inherit',
          'font-size': fontSize,
        }}
      />
    );
  }
}

const ToolButton = (props) => {
  const { icon, disabled, t, onClick } = props;
  return (
    <Box
      onClick={() => !disabled && onClick()}
      style={{
        display: 'flex',
        'align-items': 'center',
        'justify-content': 'center',
        'flex-shrink': '0',
        width: '26px',
        height: '26px',
        'border-radius': '13px',
        cursor: disabled ? 'default' : 'pointer',
        color: disabled ? t.disabled : t.text,
      }}
    >
      <Icon name={icon} style={{ 'font-size': '0.9rem' }} />
    </Box>
  );
};

const Avatar = (props) => {
  const { site, size, t } = props;
  if (site.icon) {
    return (
      <img
        src={site.icon}
        alt=""
        width={size}
        height={size}
        style={{ 'border-radius': '50%', 'object-fit': 'cover' }}
      />
    );
  }
  return (
    <Box
      style={{
        display: 'flex',
        'align-items': 'center',
        'justify-content': 'center',
        'flex-shrink': '0',
        width: size,
        height: size,
        'border-radius': '50%',
        background: t.accent,
        color: t.deep,
        'font-size': '1.3rem',
        'font-weight': 'bold',
      }}
    >
      {site.domain.slice(0, 1).toUpperCase()}
    </Box>
  );
};

const Pill = (props) => {
  const { icon, text, t, onClick } = props;
  return (
    <Box
      onClick={onClick}
      style={{
        display: 'flex',
        'align-items': 'center',
        gap: '8px',
        padding: '8px 16px',
        'border-radius': '18px',
        background: t.surface,
        border: '1px solid ' + t.line,
        color: t.text,
        cursor: 'pointer',
      }}
    >
      <Icon name={icon} style={{ color: t.muted }} />
      {text}
    </Box>
  );
};

const TabStrip = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { tabs, can_open_tab } = data;
  const t = palette(data);
  return (
    <Box
      style={{
        display: 'flex',
        'align-items': 'flex-end',
        gap: '2px',
        padding: '6px 8px 0',
        background: t.deep,
      }}
    >
      {tabs.map((tab) => (
        <Box
          key={tab.id}
          onClick={() => act('tab_select', { id: tab.id })}
          style={{
            display: 'flex',
            'align-items': 'center',
            gap: '8px',
            'max-width': '200px',
            padding: '6px 12px',
            'border-radius': '8px 8px 0 0',
            background: tab.active ? t.chrome : 'transparent',
            color: tab.active ? t.text : t.muted,
            cursor: 'pointer',
          }}
        >
          <Icon
            name="globe"
            style={{ color: tab.active ? t.accent : t.muted, 'font-size': '0.8rem' }}
          />
          <Box
            style={{
              overflow: 'hidden',
              'text-overflow': 'ellipsis',
              'white-space': 'nowrap',
              'font-size': '0.85rem',
            }}
          >
            {tab.title}
          </Box>
          {tabs.length > 1 && (
            <Box
              onClick={() => act('tab_close', { id: tab.id })}
              style={{ color: t.muted, 'font-size': '0.7rem' }}
            >
              <Icon name="times" />
            </Box>
          )}
        </Box>
      ))}
      {can_open_tab && (
        <Box
          onClick={() => act('tab_open')}
          style={{
            padding: '4px 10px 6px',
            cursor: 'pointer',
            color: t.muted,
            'font-size': '1.1rem',
          }}
        >
          <Icon name="plus" />
        </Box>
      )}
    </Box>
  );
};

const Toolbar = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { address, has_back, has_forward, site, theme } = data;
  const t = palette(data);
  return (
    <Box
      style={{
        display: 'flex',
        'align-items': 'center',
        gap: '5px',
        padding: '6px 8px',
        background: t.chrome,
      }}
    >
      <ToolButton
        icon="arrow-left"
        t={t}
        disabled={!has_back}
        onClick={() => act('back')}
      />
      <ToolButton
        icon="arrow-right"
        t={t}
        disabled={!has_forward}
        onClick={() => act('forward')}
      />
      <ToolButton icon="sync" t={t} onClick={() => act('refresh')} />
      <ToolButton icon="home" t={t} onClick={() => act('home')} />
      <Box
        style={{
          display: 'flex',
          'align-items': 'center',
          gap: '8px',
          flex: '1',
          'min-width': '0',
          height: '28px',
          padding: '0 12px',
          background: t.deep,
          border: '1px solid ' + t.line,
          'border-radius': '14px',
        }}
      >
        <Icon
          name={site ? 'lock' : 'globe'}
          style={{
            color: site ? t.secure : t.muted,
            'font-size': '0.8rem',
          }}
        />
        <Field
          value={address}
          height="26px"
          fontSize="1rem"
          color={t.text}
          placeholder="Введите адрес .f13 или поисковый запрос"
          onEnter={(value) => act('go', { query: value })}
        />
      </Box>
      <ToolButton
        icon="list"
        t={t}
        onClick={() => act('view', { name: 'catalog' })}
      />
      <ToolButton
        icon="plus-square"
        t={t}
        onClick={() => act('view', { name: 'create' })}
      />
      <ToolButton
        icon={theme === 'light' ? 'moon-o' : 'sun-o'}
        t={t}
        onClick={() => act('theme')}
      />
    </Box>
  );
};

const HomePage = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { catalog } = data;
  const t = palette(data);
  return (
    <Box
      style={{
        display: 'flex',
        'flex-direction': 'column',
        'align-items': 'center',
        padding: '60px 24px 32px',
      }}
    >
      <Box
        style={{
          'font-size': '3.4rem',
          'font-weight': 'bold',
          'line-height': '1',
        }}
      >
        SCP
        <Box as="span" style={{ color: t.accent }}>
          net
        </Box>
      </Box>
      <Box mt={0.5} style={{ color: t.muted, 'letter-spacing': '2px' }}>
        СЕТЬ СТАНЦИОННЫХ САЙТОВ
      </Box>
      <Box
        style={{
          display: 'flex',
          'align-items': 'center',
          gap: '10px',
          width: '100%',
          'max-width': '520px',
          height: '42px',
          margin: '28px 0 0',
          padding: '0 18px',
          background: t.surface,
          border: '1px solid ' + t.line,
          'border-radius': '21px',
        }}
      >
        <Icon name="search" style={{ color: t.muted }} />
        <Field
          value=""
          height="40px"
          fontSize="1.1rem"
          color={t.text}
          placeholder="Поиск в SCPnet"
          onEnter={(value) => act('go', { query: value })}
        />
      </Box>
      <Box mt={2} style={{ display: 'flex', gap: '10px' }}>
        <Pill
          icon="list"
          text="Список сайтов"
          t={t}
          onClick={() => act('view', { name: 'catalog' })}
        />
        <Pill
          icon="plus"
          text="Создать сайт"
          t={t}
          onClick={() => act('view', { name: 'create' })}
        />
      </Box>
      {catalog.length ? (
        <Box
          style={{
            display: 'flex',
            'flex-wrap': 'wrap',
            'justify-content': 'center',
            gap: '12px',
            'max-width': '640px',
            'margin-top': '32px',
          }}
        >
          {catalog.slice(0, 8).map((site) => (
            <Box
              key={site.id}
              onClick={() =>
                act('open', { site_id: site.id, slug: site.pages[0].slug })
              }
              style={{
                display: 'flex',
                'flex-direction': 'column',
                'align-items': 'center',
                gap: '8px',
                width: '96px',
                padding: '10px 4px',
                'border-radius': '10px',
                cursor: 'pointer',
                background: t.surface,
              }}
            >
              <Avatar site={site} size="40px" t={t} />
              <Box
                style={{
                  width: '100%',
                  overflow: 'hidden',
                  'text-overflow': 'ellipsis',
                  'white-space': 'nowrap',
                  'text-align': 'center',
                  'font-size': '0.75rem',
                  color: t.muted,
                }}
              >
                {site.domain}
              </Box>
            </Box>
          ))}
        </Box>
      ) : null}
    </Box>
  );
};

const CatalogPage = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { catalog } = data;
  const t = palette(data);
  return (
    <Box style={{ padding: '24px' }}>
      <Box mb={2} style={{ 'font-size': '1.4rem', 'font-weight': 'bold' }}>
        Список сайтов
      </Box>
      {(catalog.length &&
        catalog.map((site) => (
          <Box
            key={site.id}
            style={{
              display: 'flex',
              'align-items': 'center',
              gap: '14px',
              padding: '12px 14px',
              'margin-bottom': '8px',
              'border-radius': '10px',
              background: t.surface,
            }}
          >
            <Avatar site={site} size="36px" t={t} />
            <Box style={{ flex: '1', 'min-width': '0' }}>
              <Box style={{ 'font-weight': 'bold' }}>{site.title}</Box>
              <Box style={{ color: t.muted, 'font-size': '0.85rem' }}>
                {site.domain}
              </Box>
            </Box>
            {site.pages.map((page) => (
              <Box
                key={page.slug}
                onClick={() =>
                  act('open', { site_id: site.id, slug: page.slug })
                }
                style={{
                  padding: '6px 12px',
                  'border-radius': '14px',
                  background: t.chrome,
                  color: t.accent,
                  cursor: 'pointer',
                  'font-size': '0.85rem',
                }}
              >
                {page.title}
              </Box>
            ))}
          </Box>
        ))) || <Box style={{ color: t.muted }}>Каталог пуст.</Box>}
    </Box>
  );
};

const CreatePage = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { login } = data;
  const t = palette(data);
  return (
    <Box
      style={{
        display: 'flex',
        'flex-direction': 'column',
        'align-items': 'center',
        padding: '60px 24px',
      }}
    >
      <Box style={{ 'font-size': '1.6rem', 'font-weight': 'bold' }}>
        Создать сайт
      </Box>
      <Box
        mt={1}
        style={{
          color: t.muted,
          'max-width': '440px',
          'text-align': 'center',
        }}
      >
        Сайты собираются во внешнем редакторе. Возьмите одноразовый код,
        откройте редактор на любом устройстве и введите его.
      </Box>
      {(login.code && (
        <Box
          mt={3}
          style={{
            padding: '18px 28px',
            'border-radius': '12px',
            background: t.surface,
            border: '1px solid ' + t.line,
            'text-align': 'center',
          }}
        >
          <Box
            style={{
              'font-size': '2rem',
              'font-weight': 'bold',
              'letter-spacing': '2px',
            }}
          >
            {login.code}
          </Box>
          <Box mt={1} style={{ color: t.muted }}>
            Действует 15 минут. Никому не передавайте.
          </Box>
        </Box>
      )) || (
        <Box mt={3}>
          <Pill
            icon="key"
            t={t}
            text={login.pending ? 'Запрос…' : 'Получить код'}
            onClick={() =>
              !login.pending && !login.retry_seconds && act('login')
            }
          />
        </Box>
      )}
      {login.retry_seconds > 0 && (
        <Box mt={1} style={{ color: t.muted }}>
          Следующая попытка через {login.retry_seconds} с
        </Box>
      )}
      {login.error && (
        <Box mt={1} style={{ color: t.danger }}>
          {login.error}
        </Box>
      )}
    </Box>
  );
};

const SearchPage = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { search } = data;
  const t = palette(data);
  return (
    <Box style={{ padding: '24px' }}>
      <Box mb={2} style={{ color: t.muted }}>
        Результаты по запросу «{search.query}»
      </Box>
      {(search.results.length &&
        search.results.map((entry) => (
          <Box
            key={entry.site_id + '/' + entry.slug}
            onClick={() =>
              act('open', { site_id: entry.site_id, slug: entry.slug })
            }
            style={{
              padding: '12px 14px',
              'margin-bottom': '8px',
              'border-radius': '10px',
              background: t.surface,
              cursor: 'pointer',
            }}
          >
            <Box style={{ color: t.accent, 'font-weight': 'bold' }}>
              {entry.title}
            </Box>
            <Box style={{ color: t.muted, 'font-size': '0.85rem' }}>
              {entry.snippet}
            </Box>
          </Box>
        ))) || <Box style={{ color: t.muted }}>Ничего не нашлось.</Box>}
    </Box>
  );
};

const PageText = (props) => {
  const { text, t } = props;
  if (!text) {
    return (
      <Box style={{ padding: '24px', color: t.muted }}>Страница пуста.</Box>
    );
  }
  return (
    <Box style={{ padding: '24px', 'white-space': 'pre-wrap' }}>{text}</Box>
  );
};

type FrameProps = {
  url: string;
  title: string;
  t: Palette;
  fallback: any;
};

type FrameState = {
  allowed: boolean | null;
  stopped: boolean;
};

class PageFrame extends Component<FrameProps, FrameState> {
  private alive = true;
  private timer = 0;
  private lastTick = 0;

  constructor(props: FrameProps) {
    super(props);
    this.state = { allowed: null, stopped: false };
  }

  componentDidMount() {
    rendererAllows().then((result) => {
      if (this.alive) {
        this.setState({ allowed: result });
        this.watch();
      }
    });
  }

  componentWillUnmount() {
    this.alive = false;
    window.clearInterval(this.timer);
  }

  watch() {
    window.clearInterval(this.timer);
    if ((this.state as FrameState).allowed !== true) {
      return;
    }
    this.lastTick = Date.now();
    this.timer = window.setInterval(() => {
      const now = Date.now();
      const lag = now - this.lastTick - LAG_TICK;
      this.lastTick = now;
      if (lag > LAG_LIMIT) {
        window.clearInterval(this.timer);
        this.setState({ stopped: true });
      }
    }, LAG_TICK);
  }

  render() {
    const { url, title, t, fallback } = this.props;
    const { allowed, stopped } = this.state as FrameState;
    if (allowed === null) {
      return <Box style={{ padding: '24px', color: t.muted }}>Загрузка…</Box>;
    }
    if (allowed === false || stopped) {
      return (
        <Box>
          <Box style={{ padding: '12px 24px 0', color: t.muted }}>
            {stopped
              ? 'Страница подвесила клиент и была остановлена.'
              : 'Этот клиент не умеет показывать страницы целиком.'}
          </Box>
          {fallback}
        </Box>
      );
    }
    return (
      <iframe
        title={title}
        ref={(node: any) => {
          if (!node || node.dataset.scpnetLoaded === url) {
            return;
          }
          node.dataset.scpnetLoaded = url;
          node.setAttribute('sandbox', FRAME_SANDBOX);
          node.setAttribute('csp', FRAME_POLICY);
          node.setAttribute('referrerpolicy', 'no-referrer');
          node.setAttribute('allow', '');
          node.setAttribute('src', url);
        }}
        style={{
          width: '100%',
          height: '100%',
          border: 'none',
          background: '#ffffff',
        }}
      />
    );
  }
}

export const NtosSCPnet = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { available, loading, site, page, view, search } = data;
  const t = palette(data);
  const frame = page && FRAME_ADDRESS.test(page.frame || '') ? page.frame : null;
  const title = (page && page.title) || (site && site.title) || 'SCPnet';
  return (
    <NtosWindow width={900} height={700} resizable>
      <NtosWindow.Content>
        <Box
          style={{
            display: 'flex',
            'flex-direction': 'column',
            height: '100%',
            background: t.canvas,
            color: t.text,
          }}
        >
          <TabStrip />
          <Toolbar />
          {!available && (
            <Box
              style={{
                padding: '8px 24px',
                background: t.notice,
                color: t.noticeText,
                'font-size': '0.85rem',
              }}
            >
              SCPnet недоступен. Показано сохранённое.
            </Box>
          )}
          {search.error && (
            <Box
              style={{
                padding: '8px 24px',
                background: t.notice,
                color: t.danger,
                'font-size': '0.85rem',
              }}
            >
              {search.error}
            </Box>
          )}
          <Box style={{ flex: '1', 'min-height': '0', overflow: 'auto' }}>
            {(loading && (
              <Box style={{ padding: '24px', color: t.muted }}>
                <Icon name="spinner" spin mr={1} />
                Загрузка…
              </Box>
            )) ||
              (site &&
                ((page &&
                  ((frame && (
                    <PageFrame
                      key={frame}
                      url={frame}
                      title={title}
                      t={t}
                      fallback={<PageText text={page.text} t={t} />}
                    />
                  )) || <PageText text={page.text} t={t} />)) || (
                  <Box style={{ padding: '24px', color: t.muted }}>
                    Страница не открылась.
                  </Box>
                ))) ||
              (search.query && <SearchPage />) ||
              (view === 'catalog' && <CatalogPage />) ||
              (view === 'create' && <CreatePage />) || <HomePage />}
          </Box>
        </Box>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
