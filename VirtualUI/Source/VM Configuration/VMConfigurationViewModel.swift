//
//  VMConfigurationViewModel.swift
//  VirtualUI
//
//  Created by Guilherme Rambo on 18/07/22.
//

import SwiftUI
import VirtualCore

public final class VMConfigurationViewModel: ObservableObject {
    
    @Published var config: VBMacConfiguration {
        didSet {
            /// Reset display preset when changing display settings.
            /// This is so the warning goes away, if any warning is being shown.
            if config.hardware.displayDevices != oldValue.hardware.displayDevices,
               config.hardware.displayDevices.first != selectedDisplayPreset?.device
            {
                selectedDisplayPreset = nil
            }
        }
    }
    
    @Published public internal(set) var supportState: VBMacConfiguration.SupportState = .supported
    
    @Published var selectedDisplayPreset: VBDisplayPreset?
    
    @Published private(set) var vm: VBVirtualMachine
    
    public init(_ vm: VBVirtualMachine) {
        self.config = vm.configuration
        self.vm = vm
        
        Task { await updateSupportState() }
    }

    @discardableResult
    public func updateSupportState() async -> VBMacConfiguration.SupportState {
        let updatedState = await config.validate(for: vm)
        await MainActor.run {
            supportState = updatedState
        }
        return updatedState
    }
    
}