import SwiftUI
import UIKit
import RxSwift
import RxCocoa

struct ContentView: View {
    private let disposeBag = DisposeBag()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("PinIt")
                    .font(.largeTitle)
                    .bold()

                Text("사진 + 캡션 + 장소를 기록하는 앱")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NavigationLink("로그인 화면") {
                    LoginView()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("지도 화면") {
                    MapView()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .onAppear {
                _ = disposeBag
            }
        }
    }
}

#Preview {
    ContentView()
}
