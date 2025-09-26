import React, { createContext, useContext, useEffect, useMemo, useState } from 'react'
import { setAuthToken } from './api'

const AuthCtx = createContext()

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem('token'))
  const [user, setUser] = useState(() => JSON.parse(localStorage.getItem('user') || 'null'))

  useEffect(() => {
    if (token) localStorage.setItem('token', token)
    else localStorage.removeItem('token')
    // keep axios Authorization header in sync
    setAuthToken(token)
  }, [token])

  useEffect(() => {
    if (user) localStorage.setItem('user', JSON.stringify(user))
    else localStorage.removeItem('user')
  }, [user])

  const value = useMemo(() => ({ token, setToken, user, setUser }), [token, user])

  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>
}

export function useAuth() {
  return useContext(AuthCtx)
}
