require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 3000;
const TTL = (parseInt(process.env.CACHE_TTL_SECONDS) || 60) * 1000;
const BASE = 'https://api.coingecko.com/api/v3';
const headers = process.env.COINGECKO_API_KEY
  ? { 'x-cg-demo-api-key': process.env.COINGECKO_API_KEY }
  : {};

// ---------- Mock data (fallback when API fails) ----------
const mockCoins = [
  ['bitcoin', 'btc', 'Bitcoin', 65000, 1280000000000, 30000000000, 19700000, 21000000, 1.2],
  ['ethereum', 'eth', 'Ethereum', 3400, 408000000000, 15000000000, 120000000, null, -0.8],
  ['tether', 'usdt', 'Tether', 1, 110000000000, 45000000000, 110000000000, null, 0.01],
  ['solana', 'sol', 'Solana', 150, 68000000000, 3000000000, 450000000, null, 4.5],
  ['ripple', 'xrp', 'XRP', 0.52, 29000000000, 1200000000, 55000000000, 100000000000, -2.1],
].map(([id, symbol, name, p, mc, vol, cs, ms, ch], i) => ({
  id, symbol, name,
  image: `https://assets.coingecko.com/coins/images/${i + 1}/small/${id}.png`,
  current_price: p, market_cap: mc, market_cap_rank: i + 1,
  total_volume: vol, circulating_supply: cs, total_supply: cs, max_supply: ms,
  price_change_percentage_24h: ch, high_24h: p * 1.02, low_24h: p * 0.98,
  ath: p * 1.5, atl: p * 0.01,
}));

const mockDetail = (id) => {
  const c = mockCoins.find((x) => x.id === id) || mockCoins[0];
  return { ...c, description: { en: `Mock data for ${c.name}.` } };
};

const mockChart = (days) => {
  const n = 60, now = Date.now(), step = (days * 86400000) / n;
  let price = 100;
  const prices = Array.from({ length: n }, (_, i) => {
    price += (Math.random() - 0.5) * 4;
    return [Math.round(now - (n - i) * step), Number(price.toFixed(2))];
  });
  return { prices };
};

const mockGlobal = {
  data: {
    active_cryptocurrencies: 14000,
    total_market_cap: { usd: 2400000000000 },
    total_volume: { usd: 90000000000 },
    market_cap_percentage: { btc: 52.1, eth: 17.3 },
    market_cap_change_percentage_24h_usd: 0.9,
  },
};

// ---------- Cache + fallback helper ----------
const cache = new Map(); // key -> { data, time }

async function getData(res, key, path, params, mock) {
  const hit = cache.get(key);
  if (hit && Date.now() - hit.time < TTL) {
    return res.json({ source: 'cache', ...wrap(hit.data) });
  }
  try {
    const { data } = await axios.get(BASE + path, { params, headers, timeout: 8000 });
    cache.set(key, { data, time: Date.now() });
    return res.json({ source: 'live', ...wrap(data) });
  } catch (err) {
    console.error(`[${key}]`, err.response?.status || err.message);
    if (hit) return res.json({ source: 'stale-cache', ...wrap(hit.data) });
    if (mock !== undefined) return res.json({ source: 'mock', ...wrap(mock) });
    return res.status(502).json({ error: 'Upstream API unavailable' });
  }
}
// Always respond as { source, data: ... }
const wrap = (data) => ({ data });

// ---------- Routes ----------
app.get('/api/health', (_, res) => res.json({ status: 'ok' }));

// List: /api/coins?page=1&per_page=50&ids=bitcoin,ethereum (ids used by watchlist)
app.get('/api/coins', (req, res) => {
  const page = req.query.page || 1;
  const per_page = req.query.per_page || 50;
  const ids = req.query.ids;
  const params = {
    vs_currency: 'usd', order: 'market_cap_desc', per_page, page,
    sparkline: false, price_change_percentage: '24h',
  };
  if (ids) params.ids = ids;
  const mock = ids
    ? mockCoins.filter((c) => ids.split(',').includes(c.id))
    : mockCoins;
  getData(res, `coins:${page}:${per_page}:${ids || ''}`, '/coins/markets', params, mock);
});

// Detail
app.get('/api/coins/:id', (req, res) => {
  const { id } = req.params;
  getData(res, `detail:${id}`, `/coins/${id}`, {
    localization: false, tickers: false, community_data: false,
    developer_data: false, sparkline: false,
  }, mockDetail(id));
});

// Chart: /api/coins/bitcoin/chart?days=7
app.get('/api/coins/:id/chart', (req, res) => {
  const { id } = req.params;
  const days = req.query.days || 7;
  getData(res, `chart:${id}:${days}`, `/coins/${id}/market_chart`,
    { vs_currency: 'usd', days }, mockChart(Number(days) || 7));
});

// Global stats
app.get('/api/market/global', (_, res) =>
  getData(res, 'global', '/global', {}, mockGlobal.data));

// Search: /api/search?q=btc
app.get('/api/search', (req, res) => {
  const q = (req.query.q || '').trim();
  if (!q) return res.json({ source: 'none', data: { coins: [] } });
  const mock = {
    coins: mockCoins
      .filter((c) => c.name.toLowerCase().includes(q.toLowerCase()) || c.symbol.includes(q.toLowerCase()))
      .map(({ id, name, symbol, image }) => ({ id, name, symbol, thumb: image })),
  };
  getData(res, `search:${q.toLowerCase()}`, '/search', { query: q }, mock);
});

app.use((req, res) => res.status(404).json({ error: 'Not found' }));

app.listen(PORT, '0.0.0.0', () => console.log(`Backend running on http://localhost:${PORT}`));
