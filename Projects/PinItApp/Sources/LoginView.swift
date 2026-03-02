import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("LoginView Placeholder")
                .font(.title2)
            Text("이 화면에 이메일/비밀번호 인증 UI가 구현될 예정입니다.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("로그인")
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
