import React, { useEffect, useMemo, useState } from 'react'
import { useAuth } from '../AuthContext'
import { api } from '../api'

export default function AdminDashboard() {
  const { user } = useAuth()
  const [search, setSearch] = useState('')
  const [lab, setLab] = useState({ items: [], loading: false, error: '' })
  const [users, setUsers] = useState({ items: [], loading: false, error: '' })
  const [modal, setModal] = useState({ open: false, title: '', data: null })
  const [cols, setCols] = useState({ items: [], loading: false, error: '' })

  const q = useDebounced(search, 300)

  function normalizeSearch(s) {
    if (!s) return ''
    let v = String(s).trim()
    if (v.startsWith('#')) v = v.slice(1)
    return v
  }

  function shortId(id) { return String(id || '').slice(-6) }

  async function fetchLab() {
    setLab(s => ({ ...s, loading: true, error: '' }))
    try {
      const qn = normalizeSearch(q)
      const res = await api.get('/lab', { params: qn ? { q: qn } : {} })
      setLab({ items: res.data.records || [], loading: false, error: '' })
    } catch (e) {
      setLab({ items: [], loading: false, error: e.response?.data?.message || 'Failed to load lab records' })
    }
  }

  async function fetchUsers() {
    setUsers(s => ({ ...s, loading: true, error: '' }))
    try {
      const qn = normalizeSearch(q)
      const res = await api.get('/admin/users', { params: qn ? { q: qn } : {} })
      setUsers({ items: res.data.users || [], loading: false, error: '' })
    } catch (e) {
      setUsers({ items: [], loading: false, error: e.response?.data?.message || 'Failed to load users' })
    }
  }

  async function fetchCollections() {
    setCols(s => ({ ...s, loading: true, error: '' }))
    try {
      const qn = normalizeSearch(q)
      const res = await api.get('/collections/all', { params: qn ? { q: qn } : {} })
      setCols({ items: res.data.collections || [], loading: false, error: '' })
    } catch (e) {
      setCols({ items: [], loading: false, error: e.response?.data?.message || 'Failed to load collections' })
    }
  }

  useEffect(() => {
    fetchLab();
    fetchUsers();
    fetchCollections();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q])

  return (
    <div style={{ padding: 16 }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
        <div>
          <h1 style={{ color: '#0b6b5d', margin: 0 }}>Admin Dashboard</h1>
          <div style={{ color: '#6b7280', marginTop: 4 }}>Manage lab processing data and users</div>
        </div>
        <span style={{ background:'#eff6ff', color:'#2563eb', padding:'6px 10px', borderRadius:999, fontWeight:800 }}>{user?.name || 'Admin'}</span>
      </header>

      {/* Search */}
      <div style={{ marginBottom: 16 }}>
        <div style={{ position: 'relative' }}>
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="Search by Unique Code, Batch ID, Species, Email or Name"
            style={{ width: '100%', padding: '12px 40px 12px 40px', border: '1px solid #e5e7eb', borderRadius: 12 }}
          />
          <span style={{ position: 'absolute', left: 12, top: 10 }}>🔎</span>
          {search && (
            <button onClick={() => setSearch('')} style={{ position: 'absolute', right: 10, top: 8, border: 'none', background: 'transparent', cursor: 'pointer', fontSize: 18 }}>✖</button>
          )}
        </div>
      </div>

      {/* Three Columns */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 16 }}>
        {/* Lab Processing Data */}
        <Section title={`Lab Processing (${lab.items.length})`} loading={lab.loading} error={lab.error}>
          {lab.items.map(rec => (
            <Card key={rec._id} onClick={() => setModal({ open: true, title: `Lab Record #${String(rec._id).slice(-6)}`, data: rec })}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ fontWeight: 800, color: '#111827' }}>{rec.batchId || '-'}</div>
                  <div style={{ color: '#6b7280', fontSize: 12 }}>ID: {rec._id}</div>
                </div>
                <StatusBadge status={rec.status} />
              </div>
              <div style={{ color: '#374151', marginTop: 6, fontSize: 13 }}>
                {rec.notes || 'No notes'}
              </div>
              <div style={{ color: '#6b7280', marginTop: 6, fontSize: 12 }}>
                {rec.testDate ? new Date(rec.testDate).toLocaleString() : new Date(rec.createdAt).toLocaleString()}
              </div>
            </Card>
          ))}
          {!lab.loading && !lab.error && lab.items.length === 0 && <Empty>No lab records found.</Empty>}
        </Section>

        {/* Users Data */}
        <Section title={`Users (${users.items.length})`} loading={users.loading} error={users.error}>
          {users.items.map(u => (
            <Card key={u._id} onClick={() => setModal({ open: true, title: `User ${u.name}`, data: u })}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ fontWeight: 800, color: '#111827' }}>{u.name}</div>
                  <div style={{ color: '#2563eb' }}>{u.email}</div>
                </div>
                <span style={{ background:'#ecfeff', color:'#0891b2', padding:'4px 10px', borderRadius: 999, fontWeight: 800 }}>{u.role}</span>
              </div>
              <div style={{ color: '#6b7280', marginTop: 6, fontSize: 12 }}>ID: {u._id}</div>
            </Card>
          ))}
          {!users.loading && !users.error && users.items.length === 0 && <Empty>No users found.</Empty>}
        </Section>

        {/* Collections Data (search by species or unique code) */}
        <Section title={`Collections (${cols.items.length})`} loading={cols.loading} error={cols.error}>
          {cols.items.map(c => (
            <Card key={c._id} onClick={() => setModal({ open: true, title: `Collection ${c.species} #${shortId(c._id)}`, data: c })}>
              <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
                <div>
                  <div style={{ fontWeight: 800, color: '#111827' }}>
                    {c.species}
                    <span style={{ color:'#6b7280' }}> • {c.quantityKg} kg</span>
                    <span style={{ marginLeft: 8, background:'#f5f3ff', color:'#7c3aed', padding:'2px 8px', borderRadius: 999, fontWeight: 800, fontSize:12 }}>#{shortId(c._id)}</span>
                  </div>
                  <div style={{ color:'#6b7280', fontSize: 12 }}>ID: {c._id}</div>
                </div>
              </div>
            </Card>
          ))}
          {!cols.loading && !cols.error && cols.items.length === 0 && <Empty>No collections found.</Empty>}
        </Section>
      </div>

      {modal.open && (
        <Modal title={modal.title} onClose={() => setModal({ open: false, title: '', data: null })}>
          {renderDetails(modal.data)}
        </Modal>
      )}
    </div>
  )
}

function renderDetails(data) {
  if (!data) return null
  // Collection details
  if (data.species) {
    return (
      <div style={{ display:'grid', gap: 10 }}>
        <div style={{ display:'flex', alignItems:'center', gap:10 }}>
          <Pill bg="#ecfdf5" fg="#059669">{data.species}</Pill>
          <Pill bg="#eff6ff" fg="#2563eb">{data.quantityKg} kg</Pill>
          <Pill bg="#f5f3ff" fg="#7c3aed">#{shortId(data._id)}</Pill>
        </div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10 }}>
          {data.freshness != null && <KV label="Freshness" value={`${data.freshness} / 10`} />}
          {data.sizeScore != null && <KV label="Size / Maturity" value={`${data.sizeScore} / 10`} />}
          <KV label="Created" value={new Date(data.createdAt).toLocaleString()} />
          {data.location && (
            <KV label="Location" value={`${data.location?.lat}, ${data.location?.lng}`} />
          )}
        </div>
        {data.qualityNotes && (
          <div>
            <div style={{ fontWeight: 800, color:'#111827', marginBottom: 6 }}>Quality Notes</div>
            <div style={{ color:'#374151' }}>{data.qualityNotes}</div>
          </div>
        )}
        {data.notes && (
          <div>
            <div style={{ fontWeight: 800, color:'#111827', marginBottom: 6 }}>Collection Notes</div>
            <div style={{ color:'#374151' }}>{data.notes}</div>
          </div>
        )}
        <KV label="Collection ID" value={data._id} />
      </div>
    )
  }

  // Lab record details
  if (data.batchId || data.status) {
    return (
      <div style={{ display:'grid', gap: 10 }}>
        <div style={{ display:'flex', alignItems:'center', gap:10 }}>
          <Pill bg="#eff6ff" fg="#2563eb">{data.batchId || '-'}</Pill>
          <StatusBadge status={data.status} />
          <Pill bg="#f5f3ff" fg="#7c3aed">#{shortId(data._id)}</Pill>
        </div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10 }}>
          {data.testDate && <KV label="Test Date" value={new Date(data.testDate).toLocaleString()} />}
          {data.collectionId && <KV label="Collection ID" value={data.collectionId} />}
          <KV label="Moisture" value={data.moisture} />
          <KV label="Ash Content" value={data.ashContent} />
          <KV label="Pesticide Level" value={data.pesticideLevel} />
          <KV label="Microbial Load" value={data.microbialLoad} />
          <KV label="Active Compounds" value={data.activeCompounds} />
        </div>
        {data.notes && (
          <div>
            <div style={{ fontWeight: 800, color:'#111827', marginBottom: 6 }}>Lab Notes</div>
            <div style={{ color:'#374151' }}>{data.notes}</div>
          </div>
        )}
        {data.report && (
          <div>
            <div style={{ fontWeight: 800, color:'#111827', marginBottom: 6 }}>Consolidated Report</div>
            <div style={{ color:'#374151', whiteSpace:'pre-wrap' }}>{data.report}</div>
          </div>
        )}
        <KV label="Record ID" value={data._id} />
      </div>
    )
  }

  // Default to user details
  return (
    <div style={{ display:'grid', gap: 10 }}>
      <div style={{ display:'flex', alignItems:'center', gap:10 }}>
        <Pill bg="#eef2ff" fg="#4f46e5">{data.name || 'User'}</Pill>
        <Pill bg="#ecfeff" fg="#0891b2">{data.role || '-'}</Pill>
      </div>
      <KV label="Email" value={data.email} />
      {data.createdAt && <KV label="Created" value={new Date(data.createdAt).toLocaleString()} />}
      <KV label="User ID" value={data._id || data.id} />
    </div>
  )
}

function Pill({ bg, fg, children }) {
  return <span style={{ background:bg, color:fg, padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{children}</span>
}

function KV({ label, value }) {
  return (
    <div style={{ background:'#f9fafb', border:'1px solid #f3f4f6', borderRadius:10, padding:'10px 12px' }}>
      <div style={{ fontSize:12, color:'#6b7280', fontWeight:800, textTransform:'uppercase', letterSpacing:0.3 }}>{label}</div>
      <div style={{ color:'#111827', fontWeight:800 }}>{value ?? '-'}</div>
    </div>
  )
}

function shortId(id) { return String(id || '').slice(-6) }

function useDebounced(value, delay) {
  const [d, setD] = useState(value)
  useEffect(() => {
    const id = setTimeout(() => setD(value), delay)
    return () => clearTimeout(id)
  }, [value, delay])
  return d
}

function Section({ title, loading, error, children }) {
  return (
    <div>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom: 8 }}>
        <h2 style={{ margin: 0, color: '#0b6b5d' }}>{title}</h2>
      </div>
      <div style={{ display: 'grid', gap: 8 }}>
        {loading && <Card><div>Loading...</div></Card>}
        {error && <Card><div style={{ color: 'red' }}>{error}</div></Card>}
        {!loading && !error && children}
      </div>
    </div>
  )
}

function Card({ children, onClick }) {
  return (
    <div onClick={onClick} style={{ cursor:'pointer', background:'#fff', border:'1px solid #e5e7eb', borderRadius: 12, padding: 12, boxShadow: '0 1px 2px rgba(0,0,0,0.04)' }}>
      {children}
    </div>
  )
}

function Empty({ children }) {
  return (
    <div style={{ background:'#fff', border:'1px solid #f3f4f6', borderRadius: 12, padding: 16, color:'#6b7280' }}>{children}</div>
  )
}

function StatusBadge({ status }) {
  const map = {
    pending: { bg: '#fef3c7', fg: '#b45309', label: 'Pending' },
    pass: { bg: '#dcfce7', fg: '#166534', label: 'Pass' },
    fail: { bg: '#fee2e2', fg: '#991b1b', label: 'Fail' },
  }
  const s = map[status] || { bg: '#e5e7eb', fg: '#374151', label: status || 'unknown' }
  return <span style={{ background:s.bg, color:s.fg, padding:'4px 10px', borderRadius: 999, fontWeight: 800 }}>{s.label}</span>
}

function Modal({ title, children, onClose }) {
  return (
    <div style={{ position:'fixed', inset:0, background:'rgba(0,0,0,0.6)', display:'grid', placeItems:'center', zIndex:100 }}>
      <div style={{ background:'#fff', borderRadius: 12, width:'min(720px, 94vw)', maxHeight:'86vh', overflow:'auto' }}>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:12, borderBottom:'1px solid #eef2f7' }}>
          <div style={{ fontWeight: 900, color:'#0b6b5d' }}>{title}</div>
          <button onClick={onClose} style={{ border:'none', background:'transparent', fontSize: 22, cursor:'pointer' }}>✖</button>
        </div>
        <div style={{ padding: 16 }}>
          {children}
        </div>
      </div>
    </div>
  )
}
