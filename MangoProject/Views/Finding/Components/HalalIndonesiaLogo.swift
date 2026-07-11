import SwiftUI

struct HalalIndonesiaLogo: View {
    var body: some View {
        VStack(spacing: 2) {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                
                // Draw outline dome / flame
                var path = Path()
                path.move(to: CGPoint(x: w * 0.5, y: 0))
                path.addCurve(
                    to: CGPoint(x: w, y: h * 0.7),
                    control1: CGPoint(x: w * 0.9, y: h * 0.25),
                    control2: CGPoint(x: w, y: h * 0.45)
                )
                path.addLine(to: CGPoint(x: w * 0.82, y: h))
                path.addLine(to: CGPoint(x: w * 0.18, y: h))
                path.addLine(to: CGPoint(x: 0, y: h * 0.7))
                path.addCurve(
                    to: CGPoint(x: w * 0.5, y: 0),
                    control1: CGPoint(x: 0, y: h * 0.45),
                    control2: CGPoint(x: w * 0.1, y: h * 0.25)
                )
                
                context.stroke(path, with: .color(.white), lineWidth: 1.8)
                
                // Internal lines (Arabic script style symbol)
                var linesPath = Path()
                
                // Left curve
                linesPath.move(to: CGPoint(x: w * 0.32, y: h * 0.28))
                linesPath.addQuadCurve(to: CGPoint(x: w * 0.32, y: h * 0.85), control: CGPoint(x: w * 0.26, y: h * 0.55))
                
                // Middle vertical line
                linesPath.move(to: CGPoint(x: w * 0.5, y: h * 0.16))
                linesPath.addLine(to: CGPoint(x: w * 0.5, y: h * 0.85))
                
                // Right curve
                linesPath.move(to: CGPoint(x: w * 0.68, y: h * 0.28))
                linesPath.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.85), control: CGPoint(x: w * 0.74, y: h * 0.55))
                
                // Horizontal connecting line
                linesPath.move(to: CGPoint(x: w * 0.25, y: h * 0.85))
                linesPath.addLine(to: CGPoint(x: w * 0.75, y: h * 0.85))
                
                context.stroke(linesPath, with: .color(.white), lineWidth: 1.5)
            }
            .frame(width: 36, height: 42)
            
            Text("HALAL")
                .font(.system(size: 9, weight: .black))
                .tracking(1.5)
                .foregroundStyle(.white)
            
            Text("INDONESIA")
                .font(.system(size: 6, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(.white)
        }
    }
}
