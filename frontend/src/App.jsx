// import { Routes, Route, Link, Navigate, NavLink, useNavigate } from 'react-router-dom'
// import Login from './pages/Login'
// import Signup from './pages/Signup'
// import Dashboard from './pages/Dashboard'
// import Welcome from './pages/Welcome'
// import CollectorDashboard from './pages/CollectorDashboard'
// import AdminDashboard from './pages/AdminDashboard'
// import LabProcessing from './pages/LabProcessing'
// import { AuthProvider, useAuth } from './AuthContext'
// function Protected({ children }) {
//   const { token } = useAuth()
//   if (!token) return <Navigate to="/login" replace />
//   return children
// }

// function AdminProtected({ children }) {
//   const { token, user } = useAuth()
//   if (!token) return <Navigate to="/login" replace />
//   if (user?.role !== 'admin') return <Navigate to="/dashboard" replace />
//   return children
// }

// function LabProtected({ children }) {
//   const { token, user } = useAuth()
//   if (!token) return <Navigate to="/login" replace />
//   if (user?.role !== 'lab') return <Navigate to="/dashboard" replace />
//   return children
// }

// function CollectorProtected({ children }) {
//   const { token, user } = useAuth()
//   if (!token) return <Navigate to="/login" replace />
//   if (user?.role !== 'collector') return <Navigate to="/" replace />
//   return children
// }

// export default function App() {
//   return (
//     <AuthProvider>
//       <div className="topbar">
//         <div className="topbar-inner container">
//           <div className="brand">
//             <div className="brand-badge">🌿</div>
//             <span>Aayur Gram</span>
//           </div>
//           <TopNavLinks />
//         </div>
//       </div>

//       <main className="container" style={{ paddingTop: 16, paddingBottom: 80 }}>
//         <Routes>
//           <Route path="/" element={<Welcome />} />
//           <Route path="/login" element={<Login />} />
//           <Route path="/signup" element={<Signup />} />
//           {/* Collector-only dashboard */}
//           <Route path="/dashboard" element={<CollectorProtected><CollectorDashboard /></CollectorProtected>} />
//           {/* Admin-only route */}
//           <Route path="/admin" element={<AdminProtected><AdminDashboard /></AdminProtected>} />
//           {/* Lab-only route */}
//           <Route path="/lab" element={<LabProtected><LabProcessing /></LabProtected>} />
//         </Routes>
//       </main>
//     </AuthProvider>
//   )
// }

// function TopNavLinks() {
//   const { user, setUser, setToken } = useAuth()
//   const navigate = useNavigate()

//   function logout() {
//     setToken(null)
//     setUser(null)
//     navigate('/login')
//   }
//   return (
//     <div className="nav-links">
//       <NavLink to="/" className={({isActive}) => isActive ? 'active' : undefined}>Welcome</NavLink>
//       {!user && (
//         <>
//           <NavLink to="/login" className={({isActive}) => isActive ? 'active' : undefined}>Login</NavLink>
//           <NavLink to="/signup" className={({isActive}) => isActive ? 'active' : undefined}>Signup</NavLink>
//         </>
//       )}
//       {user && (
//         <>
//           {user?.role === 'collector' && (
//             <NavLink to="/dashboard" className={({isActive}) => isActive ? 'active' : undefined}>Dashboard</NavLink>
//           )}
//           {user?.role === 'admin' && (
//             <NavLink to="/admin" className={({isActive}) => isActive ? 'active' : undefined}>Admin</NavLink>
//           )}
//           {user?.role === 'lab' && (
//             <NavLink to="/lab" className={({isActive}) => isActive ? 'active' : undefined}>Lab</NavLink>
//           )}
//           <button onClick={logout} style={{ marginLeft: 8 }} className="linklike">Logout</button>
//           {/* Also show Login/Signup near Logout as requested */}
//           <NavLink to="/login" className={({isActive}) => isActive ? 'active' : undefined} style={{ marginLeft: 8 }}>Login</NavLink>
//           <NavLink to="/signup" className={({isActive}) => isActive ? 'active' : undefined}>Signup</NavLink>
//         </>
//       )}
//     </div>
//   )
// }


import { Routes, Route, Link, Navigate, NavLink, useNavigate } from 'react-router-dom'
import { useState } from 'react'
import Login from './pages/Login'
import Signup from './pages/Signup'
import Dashboard from './pages/Dashboard'
import Welcome from './pages/Welcome'
import CollectorDashboard from './pages/CollectorDashboard'
import AdminDashboard from './pages/AdminDashboard'
import LabProcessing from './pages/LabProcessing'
import { AuthProvider, useAuth } from './AuthContext'

function Protected({ children }) {
  const { token } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  return children
}

function AdminProtected({ children }) {
  const { token, user } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  if (user?.role !== 'admin') return <Navigate to="/dashboard" replace />
  return children
}

function LabProtected({ children }) {
  const { token, user } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  if (user?.role !== 'lab') return <Navigate to="/dashboard" replace />
  return children
}

function CollectorProtected({ children }) {
  const { token, user } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  if (user?.role !== 'collector') return <Navigate to="/" replace />
  return children
}

export default function App() {
  return (
    <AuthProvider>
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 to-teal-50">
        {/* Enhanced Navbar */}
        <nav className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-emerald-100 shadow-lg">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16">
              {/* Enhanced Brand */}
              <Link to="/" className="flex items-center space-x-3 hover:opacity-80 transition-opacity duration-200">
                <div className="w-10 h-10 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-xl flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform duration-200">
                  <span className="text-white text-lg font-bold">🌿</span>
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Aayur Gram</h1>
                  <p className="text-xs text-emerald-600 -mt-1">Natural Healing Platform</p>
                </div>
              </Link>

              {/* Desktop Navigation */}
              <div className="hidden md:flex items-center">
                <TopNavLinks />
              </div>

              {/* Mobile Menu Button */}
              <div className="md:hidden">
                <MobileMenuButton />
              </div>
            </div>
          </div>

          {/* Mobile Navigation */}
          <MobileNav />
        </nav>

        {/* Main Content */}
        <main className="min-h-screen px-4 sm:px-6 lg:px-8 py-6">
          <div className="max-w-7xl mx-auto">
            <Routes>
              <Route path="/" element={<Welcome />} />
              <Route path="/login" element={<Login />} />
              <Route path="/signup" element={<Signup />} />
              <Route path="/dashboard" element={<CollectorProtected><CollectorDashboard /></CollectorProtected>} />
              <Route path="/admin" element={<AdminProtected><AdminDashboard /></AdminProtected>} />
              <Route path="/lab" element={<LabProtected><LabProcessing /></LabProtected>} />
            </Routes>
          </div>
        </main>
      </div>
    </AuthProvider>
  )
}

function TopNavLinks() {
  const { user, setUser, setToken } = useAuth()
  const navigate = useNavigate()

  function logout() {
    setToken(null)
    setUser(null)
    navigate('/login')
  }

  const baseLinkClass = "px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200 hover:bg-emerald-50 hover:text-emerald-700"
  const activeLinkClass = "px-4 py-2 rounded-lg text-sm font-medium bg-emerald-100 text-emerald-700 border border-emerald-200 shadow-sm"

  return (
    <div className="flex items-center space-x-2">
      {/* Primary Navigation */}
      <div className="flex items-center space-x-1">
        <NavLink 
          to="/" 
          className={({isActive}) => isActive ? activeLinkClass : `${baseLinkClass} text-gray-700`}
        >
          <span className="hidden lg:inline">🏠 </span>Home
        </NavLink>
        
        {!user && (
          <>
            <NavLink 
              to="/login" 
              className={({isActive}) => isActive ? activeLinkClass : `${baseLinkClass} text-gray-700`}
            >
              <span className="hidden lg:inline">🔐 </span>Login
            </NavLink>
            <NavLink 
              to="/signup" 
              className={({isActive}) => isActive ? 
                "px-4 py-2 rounded-lg text-sm font-medium bg-emerald-600 text-white shadow-lg" : 
                "px-4 py-2 rounded-lg text-sm font-medium bg-emerald-600 text-white hover:bg-emerald-700 shadow-lg transform hover:scale-105 transition-all duration-200"
              }
            >
              <span className="hidden lg:inline">📝 </span>Sign Up
            </NavLink>
          </>
        )}
        
        {/* Role-based Navigation */}
        {user && (
          <>
            {user?.role === 'collector' && (
              <NavLink 
                to="/dashboard" 
                className={({isActive}) => isActive ? activeLinkClass : `${baseLinkClass} text-gray-700`}
              >
                <span className="hidden lg:inline">📊 </span>Dashboard
              </NavLink>
            )}
            {user?.role === 'admin' && (
              <NavLink 
                to="/admin" 
                className={({isActive}) => isActive ? activeLinkClass : `${baseLinkClass} text-gray-700`}
              >
                <span className="hidden lg:inline">👨‍💼 </span>Admin
              </NavLink>
            )}
            {user?.role === 'lab' && (
              <NavLink 
                to="/lab" 
                className={({isActive}) => isActive ? activeLinkClass : `${baseLinkClass} text-gray-700`}
              >
                <span className="hidden lg:inline">🔬 </span>Lab
              </NavLink>
            )}
          </>
        )}
      </div>

      {/* User Menu */}
      {user && (
        <div className="flex items-center space-x-3 ml-6 pl-6 border-l border-gray-200">
          {/* User Avatar & Info */}
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center shadow-md">
              <span className="text-white text-xs font-bold">
                {user.name?.charAt(0).toUpperCase() || user.email?.charAt(0).toUpperCase() || 'U'}
              </span>
            </div>
            <div className="hidden xl:block">
              <p className="text-sm font-medium text-gray-900 truncate max-w-24">
                {user.name || user.email}
              </p>
              <p className="text-xs text-gray-500 capitalize">{user.role}</p>
            </div>
          </div>
          
          {/* Action Buttons */}
          <div className="flex items-center space-x-2">
            <button 
              onClick={logout} 
              className="px-3 py-1.5 text-xs font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md transition-all duration-200 border border-red-200 hover:border-red-300"
            >
              🚪 Logout
            </button>
            
            {/* Quick Access Links */}
            <div className="hidden lg:flex items-center space-x-1 ml-2 pl-2 border-l border-gray-200">
              <NavLink 
                to="/login" 
                className="px-2 py-1 text-xs text-gray-500 hover:text-emerald-600 transition-colors duration-200"
              >
                Login
              </NavLink>
              <NavLink 
                to="/signup" 
                className="px-2 py-1 text-xs text-gray-500 hover:text-emerald-600 transition-colors duration-200"
              >
                Signup
              </NavLink>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function MobileMenuButton() {
  const [isOpen, setIsOpen] = useState(false)
  
  return (
    <button
      onClick={() => setIsOpen(!isOpen)}
      className="inline-flex items-center justify-center p-2 rounded-md text-gray-700 hover:text-emerald-600 hover:bg-emerald-50 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-emerald-500 transition-colors duration-200"
    >
      <span className="sr-only">Open main menu</span>
      <svg 
        className="w-6 h-6" 
        fill="none" 
        viewBox="0 0 24 24" 
        stroke="currentColor"
      >
        {isOpen ? (
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
        ) : (
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
        )}
      </svg>
    </button>
  )
}

function MobileNav() {
  const { user, setUser, setToken } = useAuth()
  const navigate = useNavigate()
  const [isOpen, setIsOpen] = useState(false)

  function logout() {
    setToken(null)
    setUser(null)
    navigate('/login')
    setIsOpen(false)
  }

  if (!isOpen) return null

  const mobileLinkClass = "block px-3 py-2 rounded-md text-base font-medium transition-colors duration-200"
  const activeMobileLinkClass = "block px-3 py-2 rounded-md text-base font-medium text-emerald-700 bg-emerald-50"
  const defaultMobileLinkClass = "block px-3 py-2 rounded-md text-base font-medium text-gray-700 hover:text-emerald-600 hover:bg-emerald-50"

  return (
    <div className="md:hidden border-t border-emerald-100 bg-white/95 backdrop-blur-md">
      <div className="px-4 py-3 space-y-1">
        <NavLink 
          to="/" 
          className={({isActive}) => isActive ? activeMobileLinkClass : defaultMobileLinkClass}
          onClick={() => setIsOpen(false)}
        >
          🏠 Home
        </NavLink>
        
        {!user && (
          <>
            <NavLink 
              to="/login" 
              className={({isActive}) => isActive ? activeMobileLinkClass : defaultMobileLinkClass}
              onClick={() => setIsOpen(false)}
            >
              🔐 Login
            </NavLink>
            <NavLink 
              to="/signup" 
              className={({isActive}) => isActive ? activeMobileLinkClass : defaultMobileLinkClass}
              onClick={() => setIsOpen(false)}
            >
              📝 Sign Up
            </NavLink>
          </>
        )}
        
        {user && (
          <>
            {/* User Info */}
            <div className="px-3 py-3 border-b border-gray-200 mb-2">
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center">
                  <span className="text-white text-sm font-bold">
                    {user.name?.charAt(0).toUpperCase() || user.email?.charAt(0).toUpperCase() || 'U'}
                  </span>
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">
                    {user.name || user.email}
                  </p>
                  <p className="text-xs text-gray-500 capitalize">{user.role}</p>
                </div>
              </div>
            </div>

            {/* Role-based Navigation */}
            {user?.role === 'collector' && (
              <NavLink 
                to="/dashboard" 
                className={({isActive}) => isActive ? activeMobileLinkClass : defaultMobileLinkClass}
                onClick={() => setIsOpen(false)}
              >
                📊 Dashboard
              </NavLink>
            )}
            {user?.role === 'admin' && (
              <NavLink 
                to="/admin" 
                className={({isActive}) => isActive ? activeMobileLinkClass : defaultMobileLinkClass}
                onClick={() => setIsOpen(false)}
              >
                👨‍💼 Admin Panel
              </NavLink>
            )}
            {user?.role === 'lab' && (
              <NavLink 
                to="/lab" 
                className={({isActive}) => isActive ? activeMobileLinkClass : defaultMobileLinkClass}
                onClick={() => setIsOpen(false)}
              >
                🔬 Lab Processing
              </NavLink>
            )}
            
            {/* Quick Access */}
            <div className="pt-2 border-t border-gray-200 mt-2">
              <NavLink 
                to="/login" 
                className={defaultMobileLinkClass}
                onClick={() => setIsOpen(false)}
              >
                🔐 Login Page
              </NavLink>
              <NavLink 
                to="/signup" 
                className={defaultMobileLinkClass}
                onClick={() => setIsOpen(false)}
              >
                📝 Signup Page
              </NavLink>
              
              <button 
                onClick={logout}
                className="w-full text-left px-3 py-2 text-base font-medium text-red-600 hover:text-red-700 hover:bg-red-50 rounded-md transition-colors duration-200 mt-2"
              >
                🚪 Logout
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  )
}