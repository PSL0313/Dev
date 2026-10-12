//
//  SetNickname.swift
//  flover9
//
//  Created by 박선린 on 10/5/26.
//

import SwiftUI
import ComposableArchitecture

struct SetNickname: View {
    @Bindable var store: StoreOf<NicknameFeature>
    let type: SetType

    @FocusState private var isNicknameFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

    init(_ type: SetType, store: StoreOf<NicknameFeature>) {
        self.type = type
        self.store = store
    }

    private var background: Color {
        colorScheme == .dark
            ? Color(red: 0.07, green: 0.10, blue: 0.09)
            : Color(red: 0.99, green: 0.985, blue: 0.97)
    }

    private var accent: Color {
        colorScheme == .dark
            ? Color(red: 0.62, green: 0.85, blue: 0.72)
            : Color(red: 0.13, green: 0.36, blue: 0.28)
    }

    private var availability: NicknameFeature.UnavailableType {
        store.availableCheckResult
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 44) {
                header()
                nicknameSettingView()
            }
            .padding(.horizontal, 28)
            .padding(.top, 64)
            .padding(.bottom, 32)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            completedButton()
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
                .background(background)
        }
    }

    private func header() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(type.msg)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .tracking(-1)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("다른 플로버에게 보여줄 닉네임이에요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func nicknameSettingView() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("닉네임")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    nicknameField()
                        .frame(minWidth: 150)
                    availabilityButton()
                }
                VStack(alignment: .trailing, spacing: 12) {
                    nicknameField()
                    availabilityButton()
                }
            }

            Group {
                if store.isLoading {
                    Text("닉네임을 확인하고 있어요.")
                        .foregroundStyle(.secondary)
                } else {
                    switch availability {
                    case .available:
                        Label(availability.msg, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(accent)
                    case .used, .limit:
                        Label {
                            Text(availability.msg)
                        } icon: {
                            Image(systemName: "exclamationmark.circle.fill")
                        }
                        .foregroundStyle(Color.red)
                    case .none:
                        Text(availability.msg)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .combine)
        }
    }

    private func nicknameField() -> some View {
        TextField("닉네임을 입력해주세요", text: $store.name)
            .font(.body)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .focused($isNicknameFocused)
            .onSubmit { isNicknameFocused = false }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.04 : 0.015))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isNicknameFocused ? accent : Color.primary.opacity(0.16),
                        lineWidth: isNicknameFocused ? 1.5 : 1
                    )
            }
            .accessibilityLabel("닉네임")
    }

    private func availabilityButton() -> some View {
        Button {
            isNicknameFocused = false
            store.send(.availableCheckButtonTapped)
        } label: {
            ZStack {
                Text("중복 확인")
                    .opacity(store.isLoading ? 0 : 1)
                if store.isLoading {
                    ProgressView().tint(accent)
                }
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 21)
            .foregroundStyle(accent)
            .background(accent.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(accent.opacity(0.7), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(store.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isLoading)
        .accessibilityLabel(store.isLoading ? "닉네임 중복 확인 중" : "닉네임 중복 확인")
    }

    private func completedButton() -> some View {
        Button {
            isNicknameFocused = false
            store.send(.nextButtonTapped)
        } label: {
            Text("완료")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .background(accent.opacity(availability == .available && !store.isLoading ? 1 : 0.3))
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .disabled(availability != .available || store.isLoading)
    }
}

extension SetNickname {
    enum SetType {
        case new
        case change

        var msg: String {
            switch self {
            case .new:
                return "어떤 이름으로\n불러드릴까요?"
            case .change:
                return "새로운 닉네임을\n알려주세요"
            }
        }
    }
}

#Preview {
    SetNickname(.new, store: AppDIContainer().makeStore(initialState: NicknameFeature.State(), feature: AppDIContainer().makeNicknameFeature()))
}
