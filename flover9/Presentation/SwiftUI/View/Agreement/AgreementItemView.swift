//
//  AgreementItemView.swift
//  flover9
//
//  Created by 박선린 on 7/29/26.
//

import SwiftUI
import ComposableArchitecture

struct AgreementView: View {

    // MARK: - 외부 상태
    
    private let store: StoreOf<AgreementFeature>
    
    @State private var selectedDocument: AgreementDocument? = nil
    
    init(store: StoreOf<AgreementFeature>) {
        self.store = store
    }
    
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
#Preview {
    let di = AppDIContainer()
    let feature = di.makeAgreementFeature()
    let store = di.makeStore(
        initialState: AgreementFeature.State(),
        feature: feature
    )
    AgreementView(store: store)
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
                isSelected: store.state.termsOfService,
                onToggle: {
                    store.send(.termsOfServiceTapped)
                },
                onDetail: {
                    selectedDocument = .termsOfService
                }
            )

            agreementRow(
                title: "[필수] 개인정보 수집·이용 동의",
                isSelected: store.state.privacyPolicy,
                onToggle: {
                    store.send(.privacyPolicyTapped)
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
            store.send(.allAgreeTapped)
        } label: {
            HStack(spacing: 12) {
                checkmarkImage(
                    isSelected: (store.state.privacyPolicy && store.state.termsOfService)
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
            guard (store.state.privacyPolicy && store.state.termsOfService) else {
                return
            }
            store.send(.nextTapped)
            
        } label: {
            Text("계속하기")
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
                    (store.state.privacyPolicy && store.state.termsOfService)
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
        .disabled(!(store.state.privacyPolicy && store.state.termsOfService))
        .animation(
            .easeInOut(duration: 0.2),
            value: (store.state.privacyPolicy && store.state.termsOfService)
        )
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
