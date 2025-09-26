import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { api } from '../api'
import { useAuth } from '../AuthContext'

export default function Signup() {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [age, setAge] = useState('22')
  const [gender, setGender] = useState('Male')
  const [role, setRole] = useState('collector')
  const [adminCode, setAdminCode] = useState('')
  const [labCode, setLabCode] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirm, setShowConfirm] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()
  const { setToken, setUser } = useAuth()

  async function handleSubmit(e) {
    e.preventDefault()
    setError('')
    try {
      if (!name || !email || !password) {
        setError('Please fill in name, email and password')
        return
      }
      if (password !== confirmPassword) {
        setError('Passwords do not match')
        return
      }
      if (role === 'admin' && !adminCode) {
        setError('Admin Access Code is required for admin signup')
        return
      }
      if (role === 'lab' && !labCode) {
        setError('Lab Access Code is required for lab signup')
        return
      }
      // NOTE: Backend currently expects { name, email, password, role }.
      // Extra fields (phone, age, gender) are collected for UI parity but not submitted yet.
      const payload = { name, email, password, role }
      if (role === 'admin') payload.adminSecret = adminCode
      if (role === 'lab') payload.labSecret = labCode
      const res = await api.post('/auth/register', payload)
      setToken(res.data.token)
      setUser(res.data.user)
      if (res.data?.user?.role === 'admin') navigate('/admin')
      else if (res.data?.user?.role === 'lab') navigate('/lab')
      else navigate('/dashboard')
    } catch (err) {
      setError(err.response?.data?.message || 'Signup failed')
    }
  }

  return (
    <div style={{ minHeight: '100vh', background: '#e8f5e9', display: 'grid', placeItems: 'center', padding: 16 }}>
      <div style={{ width: '100%', maxWidth: 520 }}>
        <div style={{ textAlign: 'center', marginBottom: 16 }}>
          <div style={{ fontSize: 40 }}>🌿</div>
          <h1 style={{ color: '#0b6b5d', margin: '8px 0' }}>Aayur Gram</h1>
        </div>

        <div style={{ background: '#fff', border: '1px solid #e5e7eb', borderRadius: 16, boxShadow: '0 10px 25px rgba(0,0,0,0.05)', padding: 24 }}>
          <h2 style={{ textAlign: 'center', color: '#0b6b5d', marginTop: 0 }}>Create Your Account</h2>

          <form onSubmit={handleSubmit} style={{ display: 'grid', gap: 12 }}>
            {/* Name */}
            <div style={fieldWrap}>
              <span style={iconStyle}>👤</span>
              <input style={inputStyle} placeholder="Name" value={name} onChange={e => setName(e.target.value)} />
            </div>
            {/* Email */}
            <div style={fieldWrap}>
              <span style={iconStyle}>✉️</span>
              <input style={inputStyle} placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} />
            </div>
            {/* Phone */}
            <div style={fieldWrap}>
              <span style={iconStyle}>📞</span>
              <input style={inputStyle} placeholder="Phone" value={phone} onChange={e => setPhone(e.target.value)} />
            </div>

            {/* Age & Gender */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div style={{ ...fieldWrap, padding: 0 }}>
                <select style={{ ...inputStyle, border: '1px solid #e5e7eb' }} value={age} onChange={e => setAge(e.target.value)}>
                  {Array.from({ length: 100 }, (_, i) => String(i + 1)).map(a => (
                    <option key={a} value={a}>{a}</option>
                  ))}
                </select>
                <div style={{ position: 'absolute', top: -8, left: 12, background: '#fff', padding: '0 4px', fontSize: 12, color: '#6b7280' }}>Age</div>
              </div>
              <div style={{ ...fieldWrap, padding: 0 }}>
                <select style={{ ...inputStyle, border: '1px solid #e5e7eb' }} value={gender} onChange={e => setGender(e.target.value)}>
                  {['Male', 'Female', 'Other'].map(g => (
                    <option key={g} value={g}>{g}</option>
                  ))}
                </select>
                <div style={{ position: 'absolute', top: -8, left: 12, background: '#fff', padding: '0 4px', fontSize: 12, color: '#6b7280' }}>Gender</div>
              </div>
            </div>

            {/* Role toggle */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: 12 }}>
              <button type="button" onClick={() => setRole('collector')} style={roleBtn(role === 'collector')}>
                <span style={{ marginRight: 8 }}>👤</span> Collector
              </button>
              <button type="button" onClick={() => setRole('user')} style={roleBtn(role === 'user')}>
                <span style={{ marginRight: 8 }}>🛒</span> Consumer
              </button>
              <button type="button" onClick={() => setRole('admin')} style={roleBtn(role === 'admin')}>
                <span style={{ marginRight: 8 }}>🛡️</span> Admin
              </button>
              <button type="button" onClick={() => setRole('lab')} style={roleBtn(role === 'lab')}>
                <span style={{ marginRight: 8 }}>🧪</span> Lab
              </button>
            </div>

            {role === 'admin' && (
              <div style={fieldWrap}>
                <span style={iconStyle}>🗝️</span>
                <input style={inputStyle} placeholder="Admin Access Code" value={adminCode} onChange={e => setAdminCode(e.target.value)} />
              </div>
            )}

            {role === 'lab' && (
              <div style={fieldWrap}>
                <span style={iconStyle}>🗝️</span>
                <input style={inputStyle} placeholder="Lab Access Code" value={labCode} onChange={e => setLabCode(e.target.value)} />
              </div>
            )}

            {/* Password */}
            <div style={fieldWrap}>
              <span style={iconStyle}>🔒</span>
              <input style={inputStyle} placeholder="Password" type={showPassword ? 'text' : 'password'} value={password} onChange={e => setPassword(e.target.value)} />
              <button type="button" onClick={() => setShowPassword(s => !s)} style={eyeBtn}>{showPassword ? '🙈' : '👁️'}</button>
            </div>
            {/* Confirm Password */}
            <div style={fieldWrap}>
              <span style={iconStyle}>🔒</span>
              <input style={inputStyle} placeholder="Confirm Password" type={showConfirm ? 'text' : 'password'} value={confirmPassword} onChange={e => setConfirmPassword(e.target.value)} />
              <button type="button" onClick={() => setShowConfirm(s => !s)} style={eyeBtn}>{showConfirm ? '🙈' : '👁️'}</button>
            </div>

            <button type="submit" style={{ background: '#0b6b5d', color: '#fff', padding: '12px 16px', border: 'none', borderRadius: 8, fontWeight: 700, cursor: 'pointer' }}>Sign Up</button>
            {error && <div style={{ color: 'red' }}>{error}</div>}
          </form>

          <div style={{ textAlign: 'center', marginTop: 12 }}>
            Already have an account?{' '}
            <button type="button" onClick={() => navigate('/login')} style={{ background: 'none', border: 'none', color: '#0b6b5d', fontWeight: 700, cursor: 'pointer' }}>Login</button>
          </div>
        </div>
      </div>
    </div>
  )
}

const fieldWrap = {
  position: 'relative',
  display: 'flex',
  alignItems: 'center',
  background: '#fff',
  border: '1px solid #e5e7eb',
  borderRadius: 12,
  padding: '4px 8px',
}

const iconStyle = {
  marginLeft: 6,
  marginRight: 6,
  color: '#0b6b5d',
}

const inputStyle = {
  flex: 1,
  border: 'none',
  outline: 'none',
  padding: '12px 8px',
  borderRadius: 10,
}

const eyeBtn = {
  background: 'none',
  border: 'none',
  cursor: 'pointer',
  padding: 6,
}

function roleBtn(active) {
  return {
    padding: '10px 12px',
    borderRadius: 12,
    border: `2px solid ${active ? '#0b6b5d' : '#e5e7eb'}`,
    background: active ? '#d1fae5' : '#f3f4f6',
    color: active ? '#0b6b5d' : '#374151',
    cursor: 'pointer',
    fontWeight: 700,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  }
}
