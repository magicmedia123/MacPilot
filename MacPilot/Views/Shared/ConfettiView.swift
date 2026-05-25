import SwiftUI

struct ConfettiView: View {
    @Binding var isActive: Bool

    @State private var particles: [ConfettiParticle] = []

    private static let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    private static let particleCount = 40

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    spawnParticles(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawnParticles(in size: CGSize) {
        particles = (0..<Self.particleCount).map { _ in
            ConfettiParticle(
                color: Self.colors.randomElement()!,
                size: CGFloat.random(in: 5...10),
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: size.height + 20
                ),
                opacity: 1
            )
        }

        for index in particles.indices {
            let delay = Double.random(in: 0...0.3)
            let targetX = CGFloat.random(in: 0...size.width)
            let targetY = CGFloat.random(in: -20...size.height * 0.4)

            withAnimation(.easeOut(duration: 1.2).delay(delay)) {
                particles[index].position = CGPoint(x: targetX, y: targetY)
            }

            withAnimation(.easeIn(duration: 0.6).delay(delay + 1.0)) {
                particles[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isActive = false
            particles = []
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}
