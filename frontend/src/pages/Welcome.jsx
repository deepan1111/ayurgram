
import React from 'react'
import { useNavigate } from 'react-router-dom'

export default function Welcome() {
  // const navigate = (path) => {
  //   console.log(`Navigating to: ${path}`)
  //   alert(`In a real app, this would navigate to: ${path}`)
  // }
  const navigate = useNavigate();
  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-900 via-teal-800 to-cyan-900 text-white relative overflow-hidden">
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-10">
        <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="ayurvedic-pattern" x="0" y="0" width="100" height="100" patternUnits="userSpaceOnUse">
              <path d="M50,20 Q70,10 80,30 Q70,50 50,40 Q30,50 20,30 Q30,10 50,20 Z" fill="#4ade80" opacity="0.3"/>
              <circle cx="25" cy="75" r="8" fill="#22d3ee" opacity="0.4"/>
              <path d="M75,70 Q85,60 90,75 Q85,90 75,80 Q65,90 60,75 Q65,60 75,70 Z" fill="#10b981" opacity="0.3"/>
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#ayurvedic-pattern)"/>
        </svg>
      </div>

      <div className="relative z-10 flex items-center justify-center min-h-screen px-4 py-12">
        <div className="max-w-4xl w-full">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            
            {/* Left Side - Content */}
            <div className="text-center lg:text-left">
              {/* Badge */}
              <div className="inline-flex items-center px-4 py-2 bg-emerald-500/20 border border-emerald-400/30 rounded-full text-sm font-medium text-emerald-200 mb-8">
                <span className="w-2 h-2 bg-emerald-400 rounded-full mr-2"></span>
                Ancient Wisdom • Modern Care
              </div>

              {/* Main Heading */}
              <h1 className="text-5xl lg:text-6xl font-extrabold leading-tight mb-6">
                <span className="block text-white">Aayur</span>
                <span className="block bg-gradient-to-r from-emerald-300 via-cyan-300 to-teal-300 bg-clip-text text-transparent">
                  Gram
                </span>
              </h1>

              {/* Subheading */}
              <h2 className="text-2xl lg:text-3xl font-semibold text-emerald-100 mb-4">
                Welcome to Natural Healing
              </h2>

              {/* Description */}
              <p className="text-lg text-emerald-100/90 leading-relaxed mb-8 max-w-lg mx-auto lg:mx-0">
                Discover authentic Ayurvedic care that brings balance and wellness to your life. 
                Experience the harmony of traditional wisdom with modern convenience.
              </p>

              {/* CTA Buttons */}
              <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
                <button
                  onClick={() => navigate('/login')}
                  className="bg-white text-emerald-900 px-8 py-4 rounded-xl font-bold text-lg hover:bg-emerald-50 shadow-xl hover:shadow-2xl transform hover:-translate-y-1 transition-all duration-200"
                >
                  Log In
                  <span className="ml-2">→</span>
                </button>
                
                <button
                  onClick={() => navigate('/signup')}
                  className="bg-emerald-500/20 border-2 border-emerald-400/50 text-white px-8 py-4 rounded-xl font-semibold text-lg hover:bg-emerald-500/30 hover:border-emerald-300 backdrop-blur-sm transition-all duration-200"
                >
                  Create Account
                </button>
              </div>

              {/* Trust Indicators */}
              <div className="flex items-center justify-center lg:justify-start gap-8 mt-12 text-sm text-emerald-200">
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 bg-emerald-500/30 rounded-full flex items-center justify-center">
                    <span>🌿</span>
                  </div>
                  <span>100% Natural</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 bg-emerald-500/30 rounded-full flex items-center justify-center">
                    <span>⚡</span>
                  </div>
                  <span>Instant Access</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 bg-emerald-500/30 rounded-full flex items-center justify-center">
                    <span>🔒</span>
                  </div>
                  <span>Secure</span>
                </div>
              </div>
            </div>

            {/* Right Side - Enhanced Visual */}
            <div className="flex items-center justify-center">
              <div className="relative">
                {/* Main Circle */}
                <div className="w-80 h-80 lg:w-96 lg:h-96 bg-gradient-to-br from-emerald-400/20 to-cyan-400/20 rounded-full backdrop-blur-sm border border-white/20 flex items-center justify-center shadow-2xl">
                  <div className="w-72 h-72 lg:w-80 lg:h-80 bg-gradient-to-br from-white/10 to-white/5 rounded-full backdrop-blur-md border border-white/30 flex items-center justify-center">
                    
                    {/* Central Lotus Design */}
                    <div className="text-center">
                      <div className="w-32 h-32 lg:w-40 lg:h-40 mx-auto mb-6 bg-gradient-to-br from-emerald-300 to-cyan-300 rounded-full flex items-center justify-center shadow-lg">
                        <svg width="80" height="80" viewBox="0 0 80 80" fill="none">
                          <g transform="translate(40, 40)">
                            {[0, 45, 90, 135, 180, 225, 270, 315].map((angle, i) => (
                              <path 
                                key={i}
                                d="M0,0 Q-10,-20 0,-30 Q10,-20 0,0"
                                fill="rgba(255, 255, 255, 0.9)"
                                transform={`rotate(${angle})`}
                              />
                            ))}
                          </g>
                          <circle cx="40" cy="40" r="8" fill="#f59e0b"/>
                        </svg>
                      </div>
                      <h3 className="text-2xl lg:text-3xl font-bold text-white mb-2">Holistic Healing</h3>
                      <p className="text-emerald-200 text-lg">Mind • Body • Spirit</p>
                    </div>
                  </div>
                </div>

                {/* Floating Information Cards */}
                <div className="absolute -top-4 -left-4 bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4 w-44 shadow-lg">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-emerald-400/30 rounded-full flex items-center justify-center">
                      <span className="text-lg">👩‍⚕️</span>
                    </div>
                    <div>
                      <div className="text-lg font-semibold text-white">Expert Care</div>
                      <div className="text-sm text-emerald-200">Certified practitioners</div>
                    </div>
                  </div>
                </div>

                <div className="absolute -bottom-4 -right-4 bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4 w-44 shadow-lg">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-cyan-400/30 rounded-full flex items-center justify-center">
                      <span className="text-lg">📱</span>
                    </div>
                    <div>
                      <div className="text-lg font-semibold text-white">Digital Health</div>
                      <div className="text-sm text-emerald-200">Modern technology</div>
                    </div>
                  </div>
                </div>

                <div className="absolute top-1/2 -right-8 bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4 w-36 shadow-lg">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-white">5000+</div>
                    <div className="text-sm text-emerald-200">Happy clients</div>
                  </div>
                </div>

                <div className="absolute top-1/3 -left-8 bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4 w-36 shadow-lg">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-white">98%</div>
                    <div className="text-sm text-emerald-200">Success rate</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Bottom Features Section */}
          <div className="mt-20 grid grid-cols-1 md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            {[
              {
                icon: "🌱",
                title: "Natural Remedies",
                description: "Pure herbal solutions for optimal wellness and healing"
              },
              {
                icon: "🧘",
                title: "Personalized Care",
                description: "Treatments tailored to your unique constitution and needs"
              },
              {
                icon: "📈",
                title: "Proven Results",
                description: "Thousands of success stories and satisfied clients"
              }
            ].map((feature, index) => (
              <div key={index} className="text-center">
                <div className="w-16 h-16 bg-white/10 rounded-xl flex items-center justify-center mx-auto mb-4 backdrop-blur-sm border border-white/20 hover:bg-white/20 transition-colors duration-200">
                  <span className="text-3xl">{feature.icon}</span>
                </div>
                <h3 className="text-xl font-semibold text-white mb-2">{feature.title}</h3>
                <p className="text-emerald-200 leading-relaxed">{feature.description}</p>
              </div>
            ))}
          </div>

          {/* Additional Info Banner */}
          <div className="mt-16 bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-8 text-center">
            <h3 className="text-2xl font-bold text-white mb-4">Ready to Begin Your Wellness Journey?</h3>
            <p className="text-emerald-200 mb-6 max-w-2xl mx-auto">
              Join thousands of people who have discovered the power of Ayurvedic healing. 
              Start your personalized wellness journey today with our expert guidance.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <div className="flex items-center gap-2 text-emerald-300">
                <span>✓</span> Free consultation
              </div>
              <div className="flex items-center gap-2 text-emerald-300">
                <span>✓</span> Personalized treatment plan
              </div>
              <div className="flex items-center gap-2 text-emerald-300">
                <span>✓</span> Expert practitioner support
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Decorative Background Elements */}
      <div className="absolute top-20 left-10 w-20 h-20 bg-emerald-400/10 rounded-full blur-xl"></div>
      <div className="absolute bottom-32 right-16 w-32 h-32 bg-cyan-400/10 rounded-full blur-xl"></div>
      <div className="absolute top-1/2 left-1/4 w-24 h-24 bg-teal-400/10 rounded-full blur-xl"></div>
    </div>
  )
}