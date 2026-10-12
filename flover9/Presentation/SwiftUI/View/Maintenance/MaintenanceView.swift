//
//  MaintenanceView.swift
//  flover9
//
//  Created by 박선린 on 8/3/26.
//

import SwiftUI

// MARK: - 서비스 점검 상태를 안내하는 전체 화면
struct MaintenanceView: View {
    private let message: String // Remote Config에서 전달받은 점검 안내 문구
    @State private var isAnimating = false // 상태 표시 애니메이션 제어
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea() // 기기 전체를 검은 배경으로 채움

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.green.opacity(0.42),
                                    Color.green.opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 180
                            )
                        )
                        .frame(width: 360, height: 360)
                        .blur(radius: 24)
                        .scaleEffect(isAnimating ? 1.06 : 0.01)
                        .opacity(isAnimating ? 1 : 0.72)

                    Image("f9Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .scaleEffect(isAnimating ? 1.03 : 0.97)
                        .opacity(isAnimating ? 1 : 0.82)
                        .accessibilityHidden(true)
                } // 로고와 초록빛이 항상 같은 중심을 공유
                .frame(width: 170, height: 170)

                statusBadge
                    .padding(.top, 28)

                Text("잠시 쉬어가고 있어요")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)

                Text(displayMessage)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.62))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .lineLimit(nil)
                    .padding(.top, 12)
                    .padding(.horizontal, 38)

                Spacer()

                Text("더 좋은 모습으로 돌아올게요")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.bottom, 28)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.4)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true // 로고에 느린 호흡 애니메이션 적용
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Remote Config의 줄바꿈 표기를 실제 줄바꿈 문자로 변환
    private var displayMessage: String {
        message.replacingOccurrences(
            of: "\\n",
            with: "\n"
        )
    }

    // MARK: - 현재 점검 상태를 나타내는 배지
    private var statusBadge: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(Color.green.opacity(0.85))
                .frame(width: 7, height: 7)

            Text("서비스 점검 중")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.white.opacity(0.08), in: Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(0.1), lineWidth: 1)
        }
    }
}

#Preview {
    MaintenanceView(message: "점검 중입니다.")
}
