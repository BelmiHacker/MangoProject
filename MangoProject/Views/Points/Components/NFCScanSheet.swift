//
//  NFCScanSheet.swift
//  MangoProject
//

import SwiftUI

struct NFCScanSheet: View {
    var onCancel: () -> Void = {}
    var onSuccess: () -> Void = {}

    @State private var scanState: ScanState = .scanning
    @State private var pulse1 = false
    @State private var pulse2 = false
    @State private var successPulse1 = false
    @State private var successPulse2 = false

    private enum ScanState { case scanning, success }

    var body: some View {
        ZStack {
            if scanState == .scanning {
                scanningView
                    .transition(.opacity)
            } else {
                successView
                    .transition(.opacity)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .onAppear {
            startScanAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    scanState = .success
                }
                onSuccess()
            }
        }
    }

    // MARK: - Scanning State

    private var scanningView: some View {
        VStack(spacing: 0) {
            dragHandle

            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Ready To Scan")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                Spacer()

                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 32)

            ZStack {
                Circle()
                    .stroke(Color(red: 0.11, green: 0.38, blue: 0.29).opacity(0.25), lineWidth: 2)
                    .frame(width: 180, height: 180)
                    .scaleEffect(pulse1 ? 1.12 : 1.0)
                    .opacity(pulse1 ? 0.4 : 1.0)

                Circle()
                    .stroke(Color(red: 0.11, green: 0.38, blue: 0.29).opacity(0.5), lineWidth: 2.5)
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulse2 ? 1.08 : 1.0)
                    .opacity(pulse2 ? 0.6 : 1.0)

                Circle()
                    .fill(Color(red: 0.11, green: 0.38, blue: 0.29))
                    .frame(width: 96, height: 96)

                Image(systemName: "iphone")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.bottom, 32)

            Text("Hold your device near the\nrestaurant's NFC tag to collect your\nattendance stamp.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 28)

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
    }

    // MARK: - Success State

    private var successView: some View {
        VStack(spacing: 0) {
            dragHandle

            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 32)

            ZStack {
                Circle()
                    .stroke(Color.yellow.opacity(0.4), lineWidth: 2)
                    .frame(width: 200, height: 200)
                    .scaleEffect(successPulse1 ? 1.08 : 1.0)

                Circle()
                    .stroke(Color.orange.opacity(0.6), lineWidth: 3)
                    .frame(width: 155, height: 155)
                    .scaleEffect(successPulse2 ? 1.06 : 1.0)

                Circle()
                    .stroke(Color.orange, lineWidth: 3)
                    .frame(width: 110, height: 110)

                Image(systemName: "star.circle")
                    .font(.system(size: 58, weight: .medium))
                    .foregroundStyle(Color.orange)
            }
            .padding(.bottom, 36)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    successPulse1 = true
                }
                withAnimation(.easeInOut(duration: 1.0).delay(0.2).repeatForever(autoreverses: true)) {
                    successPulse2 = true
                }
            }

            Text("+500 Points Added")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.bottom, 48)
        }
    }

    // MARK: - Shared

    private var dragHandle: some View {
        Capsule()
            .fill(Color(.systemGray4))
            .frame(width: 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 16)
    }

    private func startScanAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulse1 = true
        }
        withAnimation(.easeInOut(duration: 1.2).delay(0.3).repeatForever(autoreverses: true)) {
            pulse2 = true
        }
    }
}
