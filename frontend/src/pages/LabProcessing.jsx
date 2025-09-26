import React, { useEffect, useMemo, useState } from 'react'
import { api } from '../api'

export default function LabProcessing() {
  const [form, setForm] = useState({
    _id: '',
    batchId: '',
    collectionId: '',
    moisture: '',
    ashContent: '',
    pesticideLevel: '',
    microbialLoad: '',
    activeCompounds: '',
    notes: '',
    report: '',
    status: 'pending',
    testDate: '',
  })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [recent, setRecent] = useState([])
  const [search, setSearch] = useState('')
  const [loadingRecent, setLoadingRecent] = useState(false)
  const [collections, setCollections] = useState([])
  const [colLoading, setColLoading] = useState(false)
  const [colSearch, setColSearch] = useState('')
  const [colModal, setColModal] = useState({ open: false, data: null })
  const [recModal, setRecModal] = useState({ open: false, data: null })

  // Debounced inputs for auto-search
  const debouncedSearch = useDebounced(search, 350)
  const debouncedColSearch = useDebounced(colSearch, 350)

  const statuses = useMemo(() => ['pending', 'pass', 'fail'], [])

  function update(key, val) {
    setForm(f => ({ ...f, [key]: val }))
  }

  async function fetchRecent(q) {
    setLoadingRecent(true)
    try {
      const qn = normalizeSearch(q)
      const res = await api.get('/lab/mine', { params: qn ? { q: qn } : {} })
      setRecent(res.data.records || [])
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e)
    } finally {
      setLoadingRecent(false)
    }
  }

  useEffect(() => { fetchRecent('') }, [])
  useEffect(() => { fetchRecent(debouncedSearch) }, [debouncedSearch])

  async function fetchCollections(q) {
    setColLoading(true)
    try {
      const qn = normalizeSearch(q)
      const res = await api.get('/collections/all', { params: qn ? { q: qn } : {} })
      setCollections(res.data.collections || [])
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error(e)
    } finally {
      setColLoading(false)
    }
  }

  useEffect(() => { fetchCollections('') }, [])
  useEffect(() => { fetchCollections(debouncedColSearch) }, [debouncedColSearch])

  async function onSubmit(e) {
    e?.preventDefault?.()
    setSaving(true)
    setError('')
    try {
      const payload = {
        batchId: form.batchId,
        collectionId: form.collectionId || undefined,
        moisture: form.moisture,
        ashContent: form.ashContent,
        pesticideLevel: form.pesticideLevel,
        microbialLoad: form.microbialLoad,
        activeCompounds: form.activeCompounds,
        notes: form.notes,
        report: form.report,
        status: form.status,
        testDate: form.testDate || undefined,
      }
      if (form._id) {
        await api.put(`/lab/${form._id}`, payload)
      } else {
        const res = await api.post('/lab', payload)
        update('_id', res.data?.record?._id || '')
      }
      await fetchRecent('')
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to save lab record')
    } finally {
      setSaving(false)
    }
  }

  function clearForm() {
    setForm({ _id: '', batchId: '', collectionId: '', moisture: '', ashContent: '', pesticideLevel: '', microbialLoad: '', activeCompounds: '', notes: '', report: '', status: 'pending', testDate: '' })
  }

  function loadForEdit(rec) {
    setForm({
      _id: rec._id,
      batchId: rec.batchId || '',
      collectionId: rec.collectionId || '',
      moisture: rec.moisture || '',
      ashContent: rec.ashContent || '',
      pesticideLevel: rec.pesticideLevel || '',
      microbialLoad: rec.microbialLoad || '',
      activeCompounds: rec.activeCompounds || '',
      notes: rec.notes || '',
      report: rec.report || '',
      status: rec.status || 'pending',
      testDate: rec.testDate ? new Date(rec.testDate).toISOString().slice(0,10) : '',
    })
  }

  return (
    <div style={{ padding: 16 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
        <div style={{ fontWeight: 900, color: '#0b6b5d', fontSize: 20 }}>Lab Processing Dashboard</div>
        <span style={{ background:'#dcfce7', color:'#166534', padding:'4px 10px', borderRadius: 999, fontWeight: 800 }}>Lab-only</span>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: 16 }}>
        {/* Form */}
        <div style={{ background:'#fff', border:'1px solid #e5e7eb', borderRadius: 12, padding: 16 }}>
          <div style={{ fontWeight: 800, color:'#0b6b5d', marginBottom: 10 }}>Quality Test Parameters</div>
          <form onSubmit={onSubmit} style={{ display: 'grid', gap: 10 }}>
            <Labeled label="Batch Number">
              <input value={form.batchId} onChange={e => update('batchId', e.target.value)} style={input} placeholder="e.g., ASH-2024-001" />
            </Labeled>
            <Labeled label="Linked Collection (optional)">
              <div style={{ display:'flex', gap: 8, alignItems:'center' }}>
                <input value={form.collectionId} onChange={e => update('collectionId', e.target.value)} style={{ ...input, flex: 1 }} placeholder="Paste collection ID or attach from list" />
                <button type="button" onClick={() => fetchCollections(colSearch)} style={secondaryBtn}>Refresh</button>
              </div>
            </Labeled>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Labeled label="Moisture Content"><input value={form.moisture} onChange={e => update('moisture', e.target.value)} style={input} placeholder="e.g., 8%" /></Labeled>
              <Labeled label="Ash Content"><input value={form.ashContent} onChange={e => update('ashContent', e.target.value)} style={input} placeholder="e.g., 1.2%" /></Labeled>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Labeled label="Pesticide Level"><input value={form.pesticideLevel} onChange={e => update('pesticideLevel', e.target.value)} style={input} placeholder="e.g., Negligible" /></Labeled>
              <Labeled label="Microbial Load"><input value={form.microbialLoad} onChange={e => update('microbialLoad', e.target.value)} style={input} placeholder="e.g., Low" /></Labeled>
            </div>

            <Labeled label="Active Compounds">
              <input value={form.activeCompounds} onChange={e => update('activeCompounds', e.target.value)} style={input} placeholder="e.g., Curcumin" />
            </Labeled>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              <Labeled label="DNA Barcode Result">
                <select value={form.status} onChange={e => update('status', e.target.value)} style={input}>
                  {statuses.map(s => <option key={s} value={s}>{s}</option>)}
                </select>
              </Labeled>
              <Labeled label="Test Date">
                <input type="date" value={form.testDate} onChange={e => update('testDate', e.target.value)} style={input} />
              </Labeled>
            </div>

            <Labeled label="Lab Notes & Observations">
              <textarea value={form.notes} onChange={e => update('notes', e.target.value)} style={{ ...input, minHeight: 90 }} placeholder="Enter observations, test conditions, etc." />
            </Labeled>

            <Labeled label="Consolidated Report">
              <textarea value={form.report} onChange={e => update('report', e.target.value)} style={{ ...input, minHeight: 120 }} placeholder="Enter consolidated findings and conclusions" />
            </Labeled>

            <div style={{ display:'flex', gap: 8 }}>
              <button type="submit" disabled={saving} style={primaryBtn}>{saving ? 'Saving...' : (form._id ? 'Update Record' : 'Submit Test Results')}</button>
              <button type="button" onClick={clearForm} style={secondaryBtn}>Clear Form</button>
            </div>
            {error && <div style={{ color: 'red' }}>{error}</div>}
          </form>
        </div>

        {/* Side panel */}
        <div style={{ display:'grid', gap: 12 }}>
          <div style={{ background:'#fff', border:'1px solid #e5e7eb', borderRadius: 12, padding: 12 }}>
            <div style={{ fontWeight: 800, color:'#0b6b5d', marginBottom: 8 }}>Selected Batch Info</div>
            <div style={{ color:'#374151', fontSize: 14 }}>
              <div><strong>Batch ID:</strong> {form.batchId || '-'}</div>
              <div><strong>Status:</strong> {form.status}</div>
              <div><strong>Record ID:</strong> {form._id || '-'}</div>
              <div><strong>Collection ID:</strong> {form.collectionId || '-'}</div>
              <div><strong>Unique Code:</strong> {form._id ? `#${shortId(form._id)}` : '-'}</div>
            </div>
          </div>

          <div style={{ background:'#fff', border:'1px solid #e5e7eb', borderRadius: 12, padding: 12 }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom: 8 }}>
              <div style={{ fontWeight: 800, color:'#0b6b5d' }}>Recent Test Results</div>
              <div style={{ display:'flex', gap: 6 }}>
                <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by code or id" style={{ ...input, padding:'6px 8px' }} />
                <button type="button" onClick={() => fetchRecent(search)} style={secondaryBtn}>Search</button>
              </div>
            </div>
            <div style={{ display: 'grid', gap: 8 }}>
              {loadingRecent && <div>Loading...</div>}
              {!loadingRecent && recent.map(r => (
                <div key={r._id} style={{ display:'flex', justifyContent:'space-between', alignItems:'center', border:'1px solid #f3f4f6', padding: 10, borderRadius: 10 }}>
                  <div>
                    <div style={{ fontWeight: 800 }}>
                      {r.batchId || '-'}
                      <span style={{ marginLeft: 8, background:'#f5f3ff', color:'#7c3aed', padding:'2px 8px', borderRadius: 999, fontWeight: 800, fontSize:12 }}>#{shortId(r._id)}</span>
                    </div>
                    <div style={{ color:'#6b7280', fontSize: 12 }}>{new Date(r.createdAt).toLocaleString()}</div>
                  </div>
                  <div style={{ display:'flex', gap: 8, alignItems:'center' }}>
                    <StatusPill status={r.status} />
                    <button type="button" onClick={() => setRecModal({ open: true, data: r })} style={secondaryBtn}>View</button>
                    <button type="button" onClick={() => loadForEdit(r)} style={primaryBtn}>Edit</button>
                  </div>
                </div>
              ))}
              {!loadingRecent && recent.length === 0 && (
                <div style={{ color:'#6b7280' }}>No records yet.</div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* All User Collections List */}
      <div style={{ marginTop: 16, background:'#fff', border:'1px solid #e5e7eb', borderRadius: 12, padding: 12 }}>
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom: 8 }}>
          <div style={{ fontWeight: 800, color:'#0b6b5d' }}>All Collections</div>
          <div style={{ display:'flex', gap: 8 }}>
            <input value={colSearch} onChange={e => setColSearch(e.target.value)} placeholder="Search by species or id" style={{ ...input, padding:'6px 8px' }} />
            <button type="button" onClick={() => fetchCollections(colSearch)} style={secondaryBtn}>Search</button>
          </div>
        </div>
        {colLoading && <div>Loading...</div>}
        {!colLoading && (
          <div style={{ display:'grid', gap: 8 }}>
            {collections.map(c => (
              <div key={c._id} style={{ border:'1px solid #f3f4f6', padding: 10, borderRadius: 10, display:'flex', justifyContent:'space-between', alignItems:'center' }}>
                <div>
                  <div style={{ fontWeight: 800 }}>
                    {c.species}
                    <span style={{ color:'#6b7280', fontWeight: 600 }}> • {c.quantityKg} kg</span>
                    <span style={{ marginLeft: 8, background:'#f5f3ff', color:'#7c3aed', padding:'2px 8px', borderRadius: 999, fontWeight: 800, fontSize:12 }}>#{shortId(c._id)}</span>
                  </div>
                  <div style={{ color:'#6b7280', fontSize: 12 }}>{new Date(c.createdAt).toLocaleString()}</div>
                </div>
                <div style={{ display:'flex', gap: 8 }}>
                  <button type="button" onClick={() => setColModal({ open: true, data: c })} style={secondaryBtn}>View Details</button>
                  <button type="button" onClick={() => { update('collectionId', c._id); if (!form.batchId) update('batchId', `COL-${String(c._id).slice(-6)}`) }} style={primaryBtn}>Attach</button>
                </div>
              </div>
            ))}
            {collections.length === 0 && <div style={{ color:'#6b7280' }}>No collections found.</div>}
          </div>
        )}
      </div>

      {recModal.open && (
        <div style={{ position:'fixed', inset:0, background:'rgba(0,0,0,0.6)', display:'grid', placeItems:'center', zIndex:100 }}>
          <div style={{ background:'#fff', borderRadius: 12, width:'min(720px, 94vw)' }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:12, borderBottom:'1px solid #eef2f7' }}>
              <div style={{ fontWeight: 900, color:'#0b6b5d' }}>Lab Record Details</div>
              <button onClick={() => setRecModal({ open:false, data:null })} style={{ border:'none', background:'transparent', fontSize: 22, cursor:'pointer' }}>✖</button>
            </div>
            <div style={{ padding: 16, display:'grid', gap: 8 }}>
              <div style={{ display:'flex', alignItems:'center', gap:10 }}>
                <span style={{ background:'#eff6ff', color:'#2563eb', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{recModal.data?.batchId || '-'}</span>
                <StatusPill status={recModal.data?.status} />
                <span style={{ background:'#f5f3ff', color:'#7c3aed', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>#{shortId(recModal.data?._id)}</span>
              </div>
              <KV label="Record ID" value={recModal.data?._id} />
              <KV label="Batch ID" value={recModal.data?.batchId} />
              {recModal.data?.collectionId && <KV label="Collection ID" value={recModal.data?.collectionId} />}
              <KV label="Status" value={recModal.data?.status} />
              {recModal.data?.testDate && <KV label="Test Date" value={new Date(recModal.data.testDate).toLocaleString()} />}
              <KV label="Moisture" value={recModal.data?.moisture} />
              <KV label="Ash Content" value={recModal.data?.ashContent} />
              <KV label="Pesticide Level" value={recModal.data?.pesticideLevel} />
              <KV label="Microbial Load" value={recModal.data?.microbialLoad} />
              <KV label="Active Compounds" value={recModal.data?.activeCompounds} />
              <KV label="Notes" value={recModal.data?.notes} />
              <KV label="Report" value={recModal.data?.report} />
            </div>
          </div>
        </div>
      )}

      {colModal.open && (
        <div style={{ position:'fixed', inset:0, background:'rgba(0,0,0,0.6)', display:'grid', placeItems:'center', zIndex:100 }}>
          <div style={{ background:'#fff', borderRadius: 12, width:'min(720px, 94vw)' }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:12, borderBottom:'1px solid #eef2f7' }}>
              <div style={{ fontWeight: 900, color:'#0b6b5d' }}>Collection Details</div>
              <button onClick={() => setColModal({ open:false, data:null })} style={{ border:'none', background:'transparent', fontSize: 22, cursor:'pointer' }}>✖</button>
            </div>
            <div style={{ padding: 16 }}>
              {/* Header chips */}
              <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom: 10 }}>
                <span style={{ background:'#ecfdf5', color:'#059669', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{colModal.data?.species}</span>
                <span style={{ background:'#eff6ff', color:'#2563eb', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{colModal.data?.quantityKg} kg</span>
                <span style={{ background:'#f5f3ff', color:'#7c3aed', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>#{shortId(colModal.data?._id)}</span>
              </div>
              <KV label="Species" value={colModal.data?.species} />
              <KV label="Quantity (kg)" value={String(colModal.data?.quantityKg)} />
              <KV label="Created" value={new Date(colModal.data?.createdAt).toLocaleString()} />
              {colModal.data?.location && (
                <KV label="Location" value={`${colModal.data.location?.lat}, ${colModal.data.location?.lng}`} />
              )}
              {colModal.data?.freshness != null && <KV label="Freshness" value={`${colModal.data.freshness}/10`} />}
              {colModal.data?.sizeScore != null && <KV label="Size/Maturity" value={`${colModal.data.sizeScore}/10`} />}
              {colModal.data?.qualityNotes && (
                <div style={{ marginTop: 8 }}>
                  <div style={{ fontWeight: 800, color:'#111827', marginBottom: 6 }}>Quality Notes</div>
                  <div style={{ color:'#374151' }}>{colModal.data.qualityNotes}</div>
                </div>
              )}
              {colModal.data?.notes && (
                <div style={{ marginTop: 8 }}>
                  <div style={{ fontWeight: 800, color:'#111827', marginBottom: 6 }}>Collection Notes</div>
                  <div style={{ color:'#374151' }}>{colModal.data.notes}</div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function Labeled({ label, children }) {
  return (
    <div>
      <div style={{ fontSize: 12, color:'#6b7280', marginBottom: 4 }}>{label}</div>
      {children}
    </div>
  )
}

function StatusPill({ status }) {
  const map = {
    pending: { bg:'#fef3c7', fg:'#b45309', text:'Pending' },
    pass: { bg:'#dcfce7', fg:'#166534', text:'Pass' },
    fail: { bg:'#fee2e2', fg:'#991b1b', text:'Fail' },
  }
  const s = map[status] || { bg:'#e5e7eb', fg:'#374151', text:String(status || 'unknown') }
  return <span style={{ background:s.bg, color:s.fg, padding:'4px 10px', borderRadius: 999, fontWeight: 800 }}>{s.text}</span>
}

// simple key/value block used in details modals
function KV({ label, value }) {
  return (
    <div style={{ background:'#f9fafb', border:'1px solid #f3f4f6', borderRadius:10, padding:'10px 12px' }}>
      <div style={{ fontSize:12, color:'#6b7280', fontWeight:800, textTransform:'uppercase', letterSpacing:0.3 }}>{label}</div>
      <div style={{ color:'#111827', fontWeight:800 }}>{value ?? '-'}</div>
    </div>
  )
}

function shortId(id) {
  const s = String(id || '')
  return s.slice(-6)
}

function normalizeSearch(q) {
  if (!q) return ''
  let s = String(q).trim()
  if (s.startsWith('#')) s = s.slice(1)
  return s
}

// simple debounce hook
function useDebounced(value, delay) {
  const [d, setD] = useState(value)
  useEffect(() => {
    const id = setTimeout(() => setD(value), delay)
    return () => clearTimeout(id)
  }, [value, delay])
  return d
}

const input = { width:'100%', border:'1px solid #e5e7eb', borderRadius: 10, padding:'10px 12px' }
const primaryBtn = { background:'#0b6b5d', color:'#fff', padding:'10px 12px', border:'none', borderRadius: 10, fontWeight: 800, cursor:'pointer' }
const secondaryBtn = { background:'#fff', color:'#0b6b5d', border:'1px solid #0b6b5d', padding:'10px 12px', borderRadius: 10, fontWeight: 800, cursor:'pointer' }
