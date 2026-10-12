//
//  Agreement.swift
//  flover9
//
//  Created by 박선린 on 10/1/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AgreementFeature {
    // MARK: - Route, Closure
    var onRoute: ((Route) -> Void)?
    
    enum Route {
        case agree
    }
    
    @ObservableState
    struct State: Equatable {
        var termsOfService: Bool = false
        var personalInformationConsent: Bool = false
        var privacyPolicy: Bool = false
        
        var isLoading: Bool = false
        var failed: String? = nil
    }
    
    enum Action {
        case allAgreeTapped
        case termsOfServiceTapped
        case personalInformationConsentTapped
        case privacyPolicyTapped
        case isLoadingTapped
        case nextTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .allAgreeTapped:
                if state.termsOfService == true &&
                    state.personalInformationConsent == true &&
                    state.privacyPolicy == true {
                    state.termsOfService = false
                    state.personalInformationConsent = false
                    state.privacyPolicy = false
                } else {
                    state.termsOfService = true
                    state.personalInformationConsent = true
                    state.privacyPolicy = true
                }
                return .none
                
            case .termsOfServiceTapped:
                state.termsOfService.toggle()
                return .none
                
            case .personalInformationConsentTapped:
                state.personalInformationConsent.toggle()
                return .none
                
            case .privacyPolicyTapped:
                state.privacyPolicy.toggle()
                return .none
                
            case .isLoadingTapped:
                state.isLoading.toggle()
                return .none
                
            case .nextTapped:
                if state.termsOfService == true &&
                    state.personalInformationConsent == true &&
                    state.privacyPolicy == true {
                    
                    onRoute?(.agree)
                    return .none
                } else {
                    state.failed = "모든 약관에 동의해야 합니다."
                    return .none
                }
                
            }
            
        }
    }
}
