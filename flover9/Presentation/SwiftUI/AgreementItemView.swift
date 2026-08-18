//
//  AgreementItemView.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//

import SwiftUI

struct AgreementView: View {

    // MARK: - 외부 상태

    /// 필수 항목에 모두 동의하면 true
    @Binding var isAllAgreed: Bool

    /// 동의를 완료하고 Apple 로그인을 계속할 때 실행
    let onContinue: () -> Void

    // MARK: - 내부 상태

    @State private var isTermsAgreed = false
    @State private var isPrivacyCollectionAgreed = false

    @State private var selectedDocument: AgreementDocument?

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                headerView

                Spacer()
                    .frame(height: 36)

                agreementSection

                Spacer()

                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 16)
        }
        .sheet(item: $selectedDocument) { document in
            documentSheet(document)
        }
    }
}

// MARK: - Header

private extension AgreementView {

    var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flover9 이용을 위해\n동의해 주세요")
                .font(
                    .system(
                        size: 26,
                        weight: .bold
                    )
                )
                .foregroundStyle(.white)

            Text(
                "필수 항목에 동의하면 Apple 로그인을 계속할 수 있어요."
            )
            .font(
                .system(
                    size: 14,
                    weight: .regular
                )
            )
            .foregroundStyle(.gray)
        }
    }
}

// MARK: - Agreement Section

private extension AgreementView {

    var agreementSection: some View {
        VStack(spacing: 4) {
            allAgreementRow

            Divider()
                .overlay(Color.gray.opacity(0.4))
                .padding(.vertical, 8)

            agreementRow(
                title: "[필수] 서비스 이용약관 동의",
                isSelected: isTermsAgreed,
                onToggle: {
                    isTermsAgreed.toggle()
                    updateAllAgreementState()
                },
                onDetail: {
                    selectedDocument = .termsOfService
                }
            )

            agreementRow(
                title: "[필수] 개인정보 수집·이용 동의",
                isSelected: isPrivacyCollectionAgreed,
                onToggle: {
                    isPrivacyCollectionAgreed.toggle()
                    updateAllAgreementState()
                },
                onDetail: {
                    selectedDocument = .personalInformationConsent
                }
            )

            privacyPolicyButton
        }
    }

    var allAgreementRow: some View {
        Button {
            toggleAllAgreements()
        } label: {
            HStack(spacing: 12) {
                checkmarkImage(
                    isSelected: isAllAgreed
                )

                Text("모두 동의")
                    .font(
                        .system(
                            size: 17,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)

                Spacer()
            }
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    func agreementRow(
        title: String,
        isSelected: Bool,
        onToggle: @escaping () -> Void,
        onDetail: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Button {
                onToggle()
            } label: {
                checkmarkImage(
                    isSelected: isSelected
                )
            }
            .buttonStyle(.plain)

            Button {
                onToggle()
            } label: {
                Text(title)
                    .font(
                        .system(
                            size: 15,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onDetail()
            } label: {
                Text("보기")
                    .font(
                        .system(
                            size: 14,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.gray)
                    .underline()
            }
            .buttonStyle(.plain)
        }
        .frame(minHeight: 48)
    }

    var privacyPolicyButton: some View {
        Button {
            selectedDocument = .privacyPolicy
        } label: {
            Text("개인정보처리방침 보기")
                .font(
                    .system(
                        size: 14,
                        weight: .regular
                    )
                )
                .foregroundStyle(.gray)
                .underline()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
    }

    func checkmarkImage(
        isSelected: Bool
    ) -> some View {
        Image(
            systemName: isSelected
                ? "checkmark.circle.fill"
                : "circle"
        )
        .font(.system(size: 24))
        .foregroundStyle(
            isSelected
                ? Color.white
                : Color.gray
        )
    }
}

// MARK: - Continue Button

private extension AgreementView {

    var continueButton: some View {
        Button {
            guard isAllAgreed else {
                return
            }

            onContinue()
            
        } label: {
            Text("동의하고 Apple로 계속하기")
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    isAllAgreed
                        ? Color.white
                        : Color.gray.opacity(0.5)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                )
        }
        .buttonStyle(.plain)
        .disabled(!isAllAgreed)
        .animation(
            .easeInOut(duration: 0.2),
            value: isAllAgreed
        )
    }
}

// MARK: - Agreement State

private extension AgreementView {

    func toggleAllAgreements() {
        let newValue = !isAllAgreed

        isTermsAgreed = newValue
        isPrivacyCollectionAgreed = newValue
        isAllAgreed = newValue
    }

    func updateAllAgreementState() {
        isAllAgreed =
            isTermsAgreed &&
            isPrivacyCollectionAgreed
    }
}

// MARK: - Document Sheet

private extension AgreementView {

    func documentSheet(
        _ document: AgreementDocument
    ) -> some View {
        NavigationStack {
            ScrollView {
                Text(document.content)
                    .font(
                        .system(
                            size: 15,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            }
            .background(Color.black)
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(
                .dark,
                for: .navigationBar
            )
            .toolbarBackground(
                Color.black,
                for: .navigationBar
            )
            .toolbarBackground(
                .visible,
                for: .navigationBar
            )
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("닫기") {
                        selectedDocument = nil
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }
}
