//
//  SignInView.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//


import SwiftUI

struct SignInView: View {

    @State private var isAllAgreed = false

    var body: some View {
        AgreementView(
            isAllAgreed: $isAllAgreed,
            onContinue: {
                print("모두 동의 완료")
                print(isAllAgreed) // true

                // Apple 로그인 시작 이벤트 전달
            }
        )
    }
}

#Preview {
    SignInView()
}
