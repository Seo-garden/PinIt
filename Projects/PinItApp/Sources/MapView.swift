import SwiftUI

struct MapView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("MapView Placeholder")
                .font(.title2)
            Text("이 화면에 지도 기반 기록 조회 UI가 구현될 예정입니다.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("지도")
    }
}

#Preview {
    NavigationStack {
        MapView()
    }
}
