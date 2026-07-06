//
//  PlaceDetailSheetView.swift
//  MangoProject
//
//  Created by Belmiro Kayru on 04/07/26.
//

import SwiftUI

struct PlaceDetailSheetView: View {
    let state: FindingPlaceDetailState
    var onClose: () -> Void = {}
    var onShare: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                dragHandle
                header
                websiteButton
                summaryRow
                hoursSection
                detailsSection
                reportButton
                actionBar
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 34)
        }
        .scrollIndicators(.hidden)
        .background(sheetBackground)
        .preferredColorScheme(.dark)
    }
}

private extension PlaceDetailSheetView {
    var sheetBackground: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(Color(red: 0.10, green: 0.10, blue: 0.11).opacity(0.94))
    }

    var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.32))
            .frame(width: 62, height: 6)
    }

    var header: some View {
        ZStack(alignment: .top) {
            HStack {
                CircleIconButton(systemImage: "square.and.arrow.up", action: onShare)

                Spacer()

                CircleIconButton(systemImage: "xmark", action: onClose)
            }

            VStack(spacing: 4) {
                Text(state.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                HStack(spacing: 4) {
                    Text(state.category)
                    Text("·")
                    Text(state.locationName)
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.58))
                .lineLimit(1)
            }
            .padding(.horizontal, 68)
            .padding(.top, 44)
        }
        .frame(minHeight: 98)
    }

    var websiteButton: some View {
        Button {
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 22, weight: .bold))

                Text("Website")
                    .font(.system(size: 20, weight: .bold))
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(Color.blue.opacity(0.16))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(state.websiteText)
    }

    var summaryRow: some View {
        HStack(spacing: 46) {
            SummaryItem(title: "Hours", value: state.hoursStatus, valueColor: .green)
            SummaryItem(title: "Distance", value: state.distanceText, valueColor: .white, systemImage: "point.topleft.down.curvedto.point.bottomright.up")
        }
        .frame(maxWidth: .infinity)
    }

    var hoursSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Hours")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            HStack(alignment: .top) {
                Text(state.hoursStatus)
                    .foregroundStyle(.green)

                Spacer()

                Text(state.hoursText)
                    .foregroundStyle(.white)
            }
            .font(.system(size: 22, weight: .regular))

            Divider()
                .overlay(Color.white.opacity(0.12))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Normal Hours")
                        .foregroundStyle(.white.opacity(0.46))

                    Text("Every Day")
                        .foregroundStyle(.white)
                }

                Spacer()

                Text(state.hoursText)
                    .foregroundStyle(.white)

                Image(systemName: "chevron.down")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.34))
            }
            .font(.system(size: 22, weight: .regular))
        }
    }

    var detailsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Details")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            DetailRow(label: "Website", value: state.websiteText, valueColor: .blue)

            Divider()
                .overlay(Color.white.opacity(0.12))

            DetailRow(label: "Address", value: state.addressLines.joined(separator: "\n"), alignment: .trailing)
        }
    }

    var reportButton: some View {
        Button {
        } label: {
            Label("Report an Issue", systemImage: "exclamationmark.bubble.fill")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(Color.blue.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    var actionBar: some View {
        HStack(spacing: 34) {
            Image(systemName: "plus")
            Image(systemName: "star")
            Image(systemName: "hand.thumbsup")
            Image(systemName: "ellipsis")
        }
        .font(.system(size: 28, weight: .regular))
        .foregroundStyle(.white)
        .padding(.horizontal, 34)
        .frame(height: 62)
        .background(Color.black.opacity(0.36))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct CompactPlaceSheetView: View {
    let state: FindingPlaceDetailState
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: 58, height: 6)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("To \(state.name)")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text("Distance  \(state.distanceText)")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.black.opacity(0.28))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.30, green: 0.30, blue: 0.28).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .preferredColorScheme(.dark)
    }
}

private struct SummaryItem: View {
    let title: String
    let value: String
    let valueColor: Color
    var systemImage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white.opacity(0.48))

            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(value)
                    .font(.system(size: 22, weight: .regular))
            }
            .foregroundStyle(valueColor)
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white
    var alignment: TextAlignment = .leading

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            Text(label)
                .font(.system(size: 21, weight: .semibold))
                .foregroundStyle(.white.opacity(0.48))

            Spacer()

            Text(value)
                .font(.system(size: 21, weight: .regular))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(alignment)
        }
    }
}

private struct CircleIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.10))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PlaceDetailSheetView(
        state: FindingPlaceDetailState(
            name: "Tamper Coffee",
            category: "Coffee Shop",
            locationName: "The Breeze",
            websiteText: "instagram.com/tampercoffeejkt",
            hoursStatus: "Open",
            hoursText: "07.00 - 22.00",
            distanceText: "150 m",
            addressLines: ["Sampora", "Tangerang", "Banten", "Indonesia"]
        )
    )
}
