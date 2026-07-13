import SwiftUI

struct HalalCertificateCard: View {
    let certificateNumber: String?
    let certificateIssueDate: String?
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color("Accent"))
                    Text("Certified Halal")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("Accent"))
                }
                Text("Verified by MUI")
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("Accent").opacity(0.85))
                    .padding(.bottom, 4)
                Text("ID: \(certificateNumber ?? "0123456789")")
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("Accent").opacity(0.8))
                Text("Valid: \(certificateIssueDate ?? "15 July 2025")")
                    .font(Typography.bodySecondary)
                    .foregroundStyle(Color("Accent").opacity(0.8))
            }
            Spacer()
            Image("HalalSign")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
        }
        .padding(12)
        .background(Color("HalalCertBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
