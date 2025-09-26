import React, { useEffect, useState } from 'react'
import { api } from '../api'
import { useAuth } from '../AuthContext'

export default function Dashboard() {
  const { token, user, setToken, setUser } = useAuth()
  const [me, setMe] = useState(user)

  useEffect(() => {
    async function fetchMe() {
      try {
        const res = await api.get('/auth/me', { headers: { Authorization: `Bearer ${token}` } })
        setMe(res.data.user)
      } catch (e) {
        console.error(e)
      }
    }
    if (token) fetchMe()
  }, [token])

  function logout() {
    setToken(null)
    setUser(null)
  }

  return (
    <div style={{ padding: 16 }}>
      <h2>Dashboard</h2>
      <pre>{JSON.stringify(me, null, 2)}</pre>
      <button onClick={logout}>Logout</button>
    </div>
  )
}
