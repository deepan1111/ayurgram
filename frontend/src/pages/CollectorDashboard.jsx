import React, { useEffect, useMemo, useState } from 'react'
import { api } from '../api'
import { useAuth } from '../AuthContext'
import { Scanner as QrScanner } from '@yudiel/react-qr-scanner'

export default function CollectorDashboard() {
  const { user } = useAuth()
  const [tab, setTab] = useState('home')
  const tabs = useMemo(() => ['home', 'collect', 'history', 'profile'], [])
  const [isOnline, setIsOnline] = useState(typeof navigator !== 'undefined' ? navigator.onLine : true)
  const [allCollections, setAllCollections] = useState([])
  const [showQR, setShowQR] = useState(false)
  const [qrValue, setQrValue] = useState('')
  const [qrError, setQrError] = useState('')
  const [scanDetails, setScanDetails] = useState(null)

  // online/offline badge driven by real browser connectivity
  useEffect(() => {
    function goOnline() { setIsOnline(true) }
    function goOffline() { setIsOnline(false) }
    window.addEventListener('online', goOnline)
    window.addEventListener('offline', goOffline)
    return () => {
      window.removeEventListener('online', goOnline)
      window.removeEventListener('offline', goOffline)
    }
  }, [])

  async function onUploadQrImage(e) {
    try {
      setQrError('')
      const file = e.target.files && e.target.files[0]
      if (!file) return
      if (!(window).BarcodeDetector) {
        setQrError('QR detection is not supported in this browser. Please use camera scan.')
        return
      }
      const detector = new (window).BarcodeDetector({ formats: ['qr_code'] })

      // Try createImageBitmap; fallback to HTMLImageElement
      let source
      if ((window).createImageBitmap) {
        try {
          source = await (window).createImageBitmap(file)
        } catch {}
      }
      if (!source) {
        source = await new Promise((resolve, reject) => {
          const img = new Image()
          img.onload = () => resolve(img)
          img.onerror = reject
          img.src = URL.createObjectURL(file)
        })
      }

      const barcodes = await detector.detect(source)
      if (barcodes && barcodes.length > 0) {
        const text = barcodes[0].rawValue || ''
        setQrValue(text)
        setShowQR(false)
        setTimeout(() => alert(`QR scanned: ${text}`), 10)
      } else {
        setQrError('No QR code found in the selected image')
      }
    } catch (err) {
      console.error('QR image detect error', err)
      setQrError('Failed to process image for QR')
    }
  }

  // Fetch all collections once when dashboard mounts (to drive summary and history)
  useEffect(() => {
    (async () => {
      try {
        const res = await api.get('/collections')
        setAllCollections(res.data.collections || [])
      } catch (e) {
        // ignore for initial load; UI still works offline
      }
    })()
  }, [])

  return (
    <div style={{ padding: 16, paddingBottom: 72, background: '#f6fbf7', minHeight: '100vh' }}>
      <header style={{ background: '#fff', borderRadius: 12, padding: 12, display: 'flex', justifyContent: 'space-between', alignItems: 'center', boxShadow: '0 2px 8px rgba(0,0,0,0.05)', marginBottom: 16 }}>
        <div>
          <div style={{ fontSize: 14, color: '#6b7280' }}>Welcome back,</div>
          <div style={{ fontWeight: 800, color: '#0b6b5d' }}>{user?.name || 'Collector'}</div>
        </div>
        <div style={{ background: isOnline ? '#22c55e' : '#f87171', color: '#fff', padding: '6px 10px', borderRadius: 999, display: 'flex', alignItems: 'center', gap: 6 }}>
          <span>📶</span>
          <span>{isOnline ? 'Online' : 'Offline'}</span>
        </div>
      </header>

      {tab === 'home' && (
        <HomeView
          onGoCollect={() => setTab('collect')}
          onGoHistory={() => setTab('history')}
          metrics={computeSummary(allCollections)}
          onOpenQR={() => setShowQR(true)}
        />
      )}
      {tab === 'collect' && <CollectionView onRefreshAll={setAllCollections} />}
      {tab === 'history' && <HistoryView onRefreshAll={setAllCollections} />}
      {tab === 'profile' && <ProfileView />}

      <BottomNav tab={tab} setTab={setTab} />

      {showQR && (
        <div style={{ position:'fixed', inset:0, background:'rgba(0,0,0,0.6)', display:'grid', placeItems:'center', zIndex:50 }}>
          <div style={{ background:'#fff', borderRadius:12, padding:16, width:'min(520px, 92vw)' }}>
            <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:8 }}>
              <div style={{ fontWeight:800, color:'#0b6b5d' }}>Scan QR</div>
              <button onClick={() => setShowQR(false)} style={{ border:'none', background:'transparent', fontSize:22, cursor:'pointer' }}>✖</button>
            </div>
            <div style={{ background:'#000', borderRadius:12, overflow:'hidden' }}>
              <QrScanner
                onDecode={(text) => {
                  try {
                    const data = JSON.parse(text || '{}')
                    setScanDetails(data)
                  } catch {
                    setQrValue(text || '')
                  }
                  setShowQR(false)
                }}
                onError={(err) => console.warn('QR error', err)}
                constraints={{ facingMode: 'environment' }}
                styles={{ container: { width: '100%' }, video: { width: '100%' } }}
              />
            </div>
            <div style={{ marginTop: 12, display:'grid', gap: 8 }}>
              <div style={{ fontWeight:800, color:'#0b6b5d' }}>Or Upload Image</div>
              <input type="file" accept="image/*" onChange={onUploadQrImage} />
              {qrError && <div style={{ color:'red' }}>{qrError}</div>}
            </div>
          </div>
        </div>
      )}

      {/* Decoded QR Details Modal */}
      {scanDetails && (
        <div style={{ position:'fixed', inset:0, background:'rgba(0,0,0,0.6)', display:'grid', placeItems:'center', zIndex:60 }}>
          <div style={{ background:'#fff', borderRadius:16, padding:0, width:'min(640px, 92vw)', boxShadow:'0 10px 30px rgba(0,0,0,0.2)' }}>
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'14px 18px', borderBottom:'1px solid #eef2f7' }}>
              <div style={{ fontWeight:900, color:'#0b6b5d', fontSize:18 }}>Scanned Details</div>
              <button onClick={() => setScanDetails(null)} style={{ border:'none', background:'transparent', fontSize:22, cursor:'pointer', color:'#6b7280' }}>✖</button>
            </div>
            <div style={{ padding:18, display:'grid', gap:14 }}>
              {scanDetails?.type === 'collection' ? (
                <>
                  <div style={{ display:'flex', alignItems:'center', gap:10 }}>
                    {scanDetails.species && <span style={{ background:'#ecfdf5', color:'#059669', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{scanDetails.species}</span>}
                    {scanDetails.quantityKg != null && <span style={{ background:'#eff6ff', color:'#2563eb', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{scanDetails.quantityKg} kg</span>}
                    {scanDetails.id && <span style={{ background:'#f5f3ff', color:'#7c3aed', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>#{String(scanDetails.id).slice(-6)}</span>}
                  </div>
                  <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
                    {scanDetails.freshness != null && <KV label="Freshness" value={`${scanDetails.freshness} / 10`} />}
                    {scanDetails.sizeScore != null && <KV label="Size / Maturity" value={`${scanDetails.sizeScore} / 10`} />}
                    {scanDetails.createdAt && <KV label="Created" value={new Date(scanDetails.createdAt).toLocaleString()} />}
                    {scanDetails.location && (
                      <KV label="Location" value={`${Number(scanDetails.location.lat).toFixed?.(6)}, ${Number(scanDetails.location.lng).toFixed?.(6)}`} />
                    )}
                  </div>
                  {scanDetails.qualityNotes && (
                    <div style={{ background:'#fafafa', border:'1px solid #eee', borderRadius:12, padding:12 }}>
                      <div style={{ fontWeight:800, color:'#111827', marginBottom:6 }}>Quality Notes</div>
                      <div style={{ color:'#374151' }}>{scanDetails.qualityNotes}</div>
                    </div>
                  )}
                  {scanDetails.notes && (
                    <div style={{ background:'#fafafa', border:'1px solid #eee', borderRadius:12, padding:12 }}>
                      <div style={{ fontWeight:800, color:'#111827', marginBottom:6 }}>Collection Notes</div>
                      <div style={{ color:'#374151' }}>{scanDetails.notes}</div>
                    </div>
                  )}
                </>
              ) : (
                <pre style={{ whiteSpace:'pre-wrap', wordBreak:'break-word' }}>{JSON.stringify(scanDetails, null, 2)}</pre>
              )}
            </div>
            <div style={{ padding:12, borderTop:'1px solid #eef2f7', display:'flex', justifyContent:'flex-end', gap:8 }}>
              <button onClick={() => setScanDetails(null)} style={{ padding:'10px 14px', border:'1px solid #e5e7eb', background:'#fff', borderRadius:10, fontWeight:800, color:'#374151', cursor:'pointer' }}>Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function Card({ children, style }) {
  return <div style={{ background: '#fff', border: '1px solid #eee', borderRadius: 8, padding: 16, boxShadow: '0 1px 2px rgba(0,0,0,0.04)', ...style }}>{children}</div>
}

function HomeView({ onGoCollect, onGoHistory, metrics, onOpenQR }) {
  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <h2 style={{ color: '#0b6b5d' }}>Quick Actions</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 16 }}>
        <QACard icon="➕" color="#16a34a" title="New Collection" subtitle="Record harvest" onClick={onGoCollect} />
        <QACard icon="🔳" color="#3b82f6" title="Scan QR" subtitle="Verify batch" onClick={onOpenQR} />
        <QACard icon="🕘" color="#f59e0b" title="Recent Activity" subtitle="View history" onClick={onGoHistory} />
        <QACard icon="🔄" color="#8b5cf6" title="Sync Data" subtitle="All synced" onClick={() => alert('Sync complete')} />
      </div>

      <h2 style={{ color: '#0b6b5d' }}>Today's Summary</h2>
      <div style={{ background: 'linear-gradient(90deg,#16a34a,#15803d)', color: '#fff', borderRadius: 12, padding: 16, display: 'flex', justifyContent: 'space-around' }}>
        <SummaryItem label="Collections" value={String(metrics.count)} />
        <SummaryItem label="Weight (kg)" value={String(metrics.totalWeight)} />
        <SummaryItem label="Species" value={String(metrics.uniqueSpecies)} />
      </div>

      <h2 style={{ color: '#0b6b5d' }}>Compliance Status</h2>
      <Card>
        <ComplianceItem title="Harvest Zone" status="Approved" color="#22c55e" />
        <hr style={{ borderColor: '#f3f4f6' }} />
        <ComplianceItem title="Seasonal Restrictions" status="Compliant" color="#22c55e" />
        <hr style={{ borderColor: '#f3f4f6' }} />
        <ComplianceItem title="Conservation Limits" status="60% Used" color="#f59e0b" />
      </Card>
    </div>
  )
}

function SummaryItem({ label, value }) {
  return (
    <div style={{ textAlign: 'center', color: '#fff' }}>
      <div style={{ fontSize: 20, fontWeight: 800 }}>{value}</div>
      <div style={{ opacity: 0.9 }}>{label}</div>
    </div>
  )
}

function ComplianceItem({ title, status, color }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
      <div>{title}</div>
      <div style={{ background: `${color}22`, color, padding: '4px 8px', borderRadius: 12, fontWeight: 700 }}>{status}</div>
    </div>
  )
}

function QACard({ icon, color, title, subtitle, onClick }) {
  return (
    <div onClick={onClick} style={{ cursor: 'pointer', background: '#fff', borderRadius: 12, padding: 16, boxShadow: '0 2px 6px rgba(0,0,0,0.06)' }}>
      <div style={{ width: 44, height: 44, borderRadius: 999, background: `${color}22`, display: 'grid', placeItems: 'center', marginBottom: 10 }}>
        <span style={{ color, fontSize: 22 }}>{icon}</span>
      </div>
      <div style={{ fontWeight: 800, color: '#111827' }}>{title}</div>
      <div style={{ color: '#6b7280' }}>{subtitle}</div>
    </div>
  )
}

function CollectionView({ onRefreshAll }) {
  const [species, setSpecies] = useState('')
  const [quantityKg, setQuantityKg] = useState('')
  const [notes, setNotes] = useState('')
  const [location, setLocation] = useState(null)
  const [freshness, setFreshness] = useState(5)
  const [sizeScore, setSizeScore] = useState(5)
  const [qualityNotes, setQualityNotes] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [items, setItems] = useState([])

  async function fetchCollections() {
    try {
      const res = await api.get('/collections')
      setItems(res.data.collections)
      onRefreshAll && onRefreshAll(res.data.collections)
    } catch (e) {
      console.error(e)
    }
  }

  useEffect(() => {
    fetchCollections()
  }, [])

  async function getLocation() {
    if (!navigator.geolocation) {
      setError('Geolocation is not supported by your browser')
      return
    }
    setError('')
    navigator.geolocation.getCurrentPosition(
      (pos) => setLocation({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
      (err) => setError(err.message)
    )
  }

  async function handleSubmit(e) {
    e.preventDefault()
    setSubmitting(true)
    setError('')
    try {
      const payload = { species, quantityKg: Number(quantityKg), notes, location, freshness, sizeScore, qualityNotes }
      await api.post('/collections', payload)
      setSpecies(''); setQuantityKg(''); setNotes('')
      await fetchCollections()
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to submit collection')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div style={{ display: 'grid', gap: 16 }}>
      <h2 style={{ color: '#0b6b5d' }}>New Collection</h2>
      {/* Location Card */}
      <div style={{ background: '#f1f8f3', border: '1px solid #e5e7eb', borderRadius: 12, padding: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
          <div style={{ fontWeight: 800, color: '#0b6b5d', display: 'flex', alignItems: 'center', gap: 8 }}>
            <span>📍</span> Current Location
          </div>
          <div style={{ background: '#22c55e', color: '#fff', padding: '4px 10px', borderRadius: 999 }}>Online</div>
        </div>
        {location ? (
          <div style={{ color: '#374151' }}>
            Lat: {location.lat.toFixed(6)}<br />
            Long: {location.lng.toFixed(6)}
          </div>
        ) : (
          <button onClick={getLocation} type="button" style={{ padding: '8px 10px', border: '1px solid #ddd', borderRadius: 8, background: '#fff', cursor: 'pointer' }}>Get Location</button>
        )}
      </div>

      {/* Collection Form */}
      <Card>
        <form onSubmit={handleSubmit} style={{ display: 'grid', gap: 12 }}>
          <input style={inputBox} placeholder="Plant Species *" value={species} onChange={e => setSpecies(e.target.value)} />
          <input style={inputBox} placeholder="Quantity (kg) *" value={quantityKg} onChange={e => setQuantityKg(e.target.value)} type="number" step="0.01" />
          <textarea style={{ ...inputBox, minHeight: 80 }} placeholder="Collection Notes" value={notes} onChange={e => setNotes(e.target.value)} />
        </form>
      </Card>

      {/* Quality Assessment */}
      <Card>
        <div style={{ fontWeight: 800, color: '#0b6b5d', marginBottom: 8 }}>Quality Assessment</div>
        <Slider label={`Freshness: ${freshness}/10`} value={freshness} onChange={setFreshness} />
        <Slider label={`Size/Maturity: ${sizeScore}/10`} value={sizeScore} onChange={setSizeScore} />
        <textarea style={{ ...inputBox, minHeight: 80 }} placeholder="Quality Notes (Optional)" value={qualityNotes} onChange={e => setQualityNotes(e.target.value)} />
      </Card>

      <button
        onClick={handleSubmit}
        disabled={submitting || !species || !quantityKg}
        style={{
          padding: '12px 16px',
          background: (!species || !quantityKg) ? '#d1d5db' : '#0b6b5d',
          color: '#fff', border: 'none', borderRadius: 12, fontWeight: 800, cursor: (!species || !quantityKg) ? 'not-allowed' : 'pointer'
        }}
      >
        {submitting ? 'Submitting...' : 'Submit Collection'}
      </button>
      {error && <div style={{ color: 'red' }}>{error}</div>}

      <h3 style={{ color: '#0b6b5d' }}>My Recent Collections</h3>
      <div style={{ display: 'grid', gap: 8 }}>
        {items.map(item => (
          <Card key={item._id}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <div>
                <div style={{ fontWeight: 700 }}>{item.species}</div>
                <div style={{ color: '#555' }}>{item.quantityKg} kg</div>
              </div>
              <div style={{ textAlign: 'right', color: '#666' }}>
                <div>{new Date(item.createdAt).toLocaleString()}</div>
                {item.location && ( <div>({item.location.lat?.toFixed?.(2)}, {item.location.lng?.toFixed?.(2)})</div> )}
              </div>
            </div>
            {item.notes && <div style={{ marginTop: 8 }}>{item.notes}</div>}
          </Card>
        ))}
        {items.length === 0 && <div>No collections yet.</div>}
      </div>
    </div>
  )
}

function HistoryView({ onRefreshAll }) {
  const [items, setItems] = useState([])
  const [showDetails, setShowDetails] = useState(false)
  const [selected, setSelected] = useState(null)
  const [qrUrl, setQrUrl] = useState('')
  const [qrGenErr, setQrGenErr] = useState('')
  useEffect(() => { (async () => {
    try {
      const res = await api.get('/collections');
      setItems(res.data.collections || []);
      onRefreshAll && onRefreshAll(res.data.collections || [])
    } catch {}
  })() }, [])
  useEffect(() => {
    async function gen() {
      try {
        setQrGenErr('')
        setQrUrl('')
        if (!selected?._id) return
        const payload = JSON.stringify({ type: 'collection', id: selected._id })
        // Try dynamic import of 'qrcode'. If not installed, show fallback.
        const mod = await import(/* @vite-ignore */ 'qrcode').catch(() => null)
        const QR = mod?.default || mod
        if (!QR || !QR.toDataURL) {
          setQrGenErr("QR library not installed. Run 'npm i qrcode' in frontend to enable QR images.")
          return
        }
        const dataUrl = await QR.toDataURL(payload, { width: 220, margin: 2 })
        setQrUrl(dataUrl)
      } catch (e) {
        setQrGenErr('Failed to generate QR')
      }
    }
    gen()
  }, [selected])
  return (
    <div>
      <h2 style={{ color: '#046f5c' }}>History</h2>
      <div style={{ display: 'grid', gap: 8 }}>
        {items.map(item => (
          <Card key={item._id}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <div>
                <div style={{ fontWeight: 700 }}>{item.species}</div>
                <div style={{ color: '#555' }}>{item.quantityKg} kg</div>
              </div>
              <div style={{ textAlign: 'right', color: '#666' }}>
                <div>{new Date(item.createdAt).toLocaleString()}</div>
                {item.location && ( <div>({item.location.lat?.toFixed?.(2)}, {item.location.lng?.toFixed?.(2)})</div> )}
              </div>
            </div>
            {item.notes && <div style={{ marginTop: 8 }}>{item.notes}</div>}
            <div style={{ marginTop: 8, display: 'flex', justifyContent: 'flex-end' }}>
              <button
                onClick={() => { setSelected(item); setShowDetails(true) }}
                style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #e5e7eb', background: '#fff', cursor: 'pointer', fontWeight: 700, color: '#0b6b5d' }}
              >View Details</button>
            </div>
          </Card>
        ))}
        {items.length === 0 && (
          <Card><div style={{ color: '#6b7280' }}>No history yet. Create your first collection from the Collect tab.</div></Card>
        )}
      </div>

      {showDetails && selected && (
        <div style={{ position:'fixed', inset:0, background:'rgba(0,0,0,0.6)', display:'grid', placeItems:'center', zIndex:60 }}>
          <div style={{ background:'#fff', borderRadius:16, padding:0, width:'min(640px, 92vw)', boxShadow:'0 10px 30px rgba(0,0,0,0.2)' }}>
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'14px 18px', borderBottom:'1px solid #eef2f7' }}>
              <div style={{ fontWeight:900, color:'#0b6b5d', fontSize:18 }}>Collection Details</div>
              <button onClick={() => setShowDetails(false)} style={{ border:'none', background:'transparent', fontSize:22, cursor:'pointer', color:'#6b7280' }}>✖</button>
            </div>
            <div style={{ padding:18, display:'grid', gap:14 }}>
              <div style={{ display:'flex', alignItems:'center', gap:10 }}>
                <span style={{ background:'#ecfdf5', color:'#059669', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{selected.species}</span>
                <span style={{ background:'#eff6ff', color:'#2563eb', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>{selected.quantityKg} kg</span>
                <span style={{ background:'#f5f3ff', color:'#7c3aed', padding:'4px 10px', borderRadius:999, fontWeight:800 }}>#{String(selected._id).slice(-6)}</span>
              </div>

              <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
                <KV label="Freshness" value={`${selected.freshness ?? '-'} / 10`} />
                <KV label="Size / Maturity" value={`${selected.sizeScore ?? '-'} / 10`} />
                <KV label="Created" value={new Date(selected.createdAt).toLocaleString()} />
                {selected.location && (
                  <KV label="Location" value={`${Number(selected.location.lat).toFixed?.(6)}, ${Number(selected.location.lng).toFixed?.(6)}`} />
                )}
              </div>

              {selected.qualityNotes && (
                <div style={{ background:'#fafafa', border:'1px solid #eee', borderRadius:12, padding:12 }}>
                  <div style={{ fontWeight:800, color:'#111827', marginBottom:6 }}>Quality Notes</div>
                  <div style={{ color:'#374151' }}>{selected.qualityNotes}</div>
                </div>
              )}
              {selected.notes && (
                <div style={{ background:'#fafafa', border:'1px solid #eee', borderRadius:12, padding:12 }}>
                  <div style={{ fontWeight:800, color:'#111827', marginBottom:6 }}>Collection Notes</div>
                  <div style={{ color:'#374151' }}>{selected.notes}</div>
                </div>
              )}

              {/* QR code for sharing/scanning */}
              <div style={{ display:'grid', gridTemplateColumns:'auto 1fr', gap:12, alignItems:'center' }}>
                <div>
                  {qrUrl ? (
                    <img src={qrUrl} width={132} height={132} alt="Collection QR" style={{ border:'1px solid #eee', borderRadius:8 }} />
                  ) : (
                    <div style={{ width:132, height:132, display:'grid', placeItems:'center', border:'1px dashed #e5e7eb', borderRadius:8, color:'#6b7280' }}>QR</div>
                  )}
                </div>
                <div>
                  <div style={{ fontWeight:800, color:'#0b6b5d', marginBottom:6 }}>Scan to View</div>
                  <div style={{ color:'#374151', fontSize:13 }}>This QR encodes a JSON payload with the collection id. A compatible scanner can read and deep-link to details.</div>
                  {qrGenErr && <div style={{ color:'red', marginTop:6 }}>{qrGenErr}</div>}
                  {!qrUrl && (
                    <div style={{ marginTop:8, fontSize:12, color:'#6b7280' }}>
                      Payload: <code>{JSON.stringify({ type: 'collection', id: selected._id })}</code>
                    </div>
                  )}
                </div>
              </div>
            </div>
            <div style={{ padding:12, borderTop:'1px solid #eef2f7', display:'flex', justifyContent:'flex-end', gap:8 }}>
              <button onClick={() => setShowDetails(false)} style={{ padding:'10px 14px', border:'1px solid #e5e7eb', background:'#fff', borderRadius:10, fontWeight:800, color:'#374151', cursor:'pointer' }}>Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function ProfileView() {
  const { user } = useAuth()
  return (
    <div>
      <h2 style={{ color: '#046f5c' }}>Profile</h2>
      <Card>
        <div style={{ display:'flex', alignItems:'center', gap:16 }}>
          <div style={{ width:56, height:56, borderRadius:999, background:'#ecfdf5', display:'grid', placeItems:'center', color:'#059669', fontWeight:900 }}>
            {(user?.name || 'U').slice(0,1).toUpperCase()}
          </div>
          <div style={{ flex:1 }}>
            <div style={{ fontSize:18, fontWeight:900, color:'#111827' }}>{user?.name || '-'}</div>
            <div style={{ color:'#374151' }}>
              <a href={`mailto:${user?.email || ''}`} style={{ color:'#2563eb', textDecoration:'none' }}>{user?.email || '-'}</a>
            </div>
          </div>
          {user?.role && (
            <span style={{ background:'#eff6ff', color:'#2563eb', padding:'6px 10px', borderRadius:999, fontWeight:800 }}>{user.role}</span>
          )}
        </div>
        {user?._id && (
          <div style={{ marginTop:10, fontSize:12, opacity:0.8 }}>
            <strong>ID:</strong> {user._id}
          </div>
        )}
      </Card>
    </div>
  )
}

const inputBox = {
  background: '#fff',
  border: '1px solid #e5e7eb',
  borderRadius: 12,
  padding: '12px 12px',
}

function Slider({ label, value, onChange }) {
  return (
    <div style={{ marginBottom: 12 }}>
      <div style={{ marginBottom: 6 }}>{label}</div>
      <input type="range" min={0} max={10} value={value} onChange={(e) => onChange(Number(e.target.value))} style={{ width: '100%', accentColor:'#0b6b5d' }} />
    </div>
  )
}

function BottomNav({ tab, setTab }) {
  const items = [
    { key: 'home', label: 'Home', icon: '🏠' },
    { key: 'collect', label: 'Collect', icon: '➕' },
    { key: 'history', label: 'History', icon: '🕘' },
    { key: 'profile', label: 'Profile', icon: '👤' },
  ]
  return (
    <nav style={{ position: 'fixed', left: 0, right: 0, bottom: 0, background: '#fff', borderTop: '1px solid #e5e7eb', display: 'grid', gridTemplateColumns: `repeat(${items.length}, 1fr)`, padding: '8px 0', backdropFilter:'saturate(180%) blur(8px)' }}>
      {items.map(it => (
        <button key={it.key} onClick={() => setTab(it.key)} style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: tab === it.key ? '#0b6b5d' : '#9ca3af', display: 'grid', placeItems: 'center', gap: 4, fontWeight: tab === it.key ? 800 : 600 }}>
          <div>{it.icon}</div>
          <div style={{ fontSize: 12 }}>{it.label}</div>
        </button>
      ))}
    </nav>
  )
}

// key/value helper for details modal
function KV({ label, value }) {
  return (
    <div style={{ background:'#f9fafb', border:'1px solid #f3f4f6', borderRadius:10, padding:'10px 12px' }}>
      <div style={{ fontSize:12, color:'#6b7280', fontWeight:800, textTransform:'uppercase', letterSpacing:0.3 }}>{label}</div>
      <div style={{ color:'#111827', fontWeight:800 }}>{value}</div>
    </div>
  )
}

// --- helpers ---
function computeSummary(items) {
  try {
    const count = items?.length || 0
    let totalWeight = 0
    const speciesSet = new Set()
    for (const it of items || []) {
      if (typeof it?.quantityKg === 'number') totalWeight += it.quantityKg
      if (it?.species) speciesSet.add(it.species)
    }
    return { count, totalWeight: Number(totalWeight.toFixed(1)), uniqueSpecies: speciesSet.size }
  } catch {
    return { count: 0, totalWeight: 0, uniqueSpecies: 0 }
  }
}
