import SwiftUI
import Combine
import HomeKit

class HomeStore: NSObject, ObservableObject, HMHomeManagerDelegate {
    @Published var accessories: [HMAccessory] = []
    @Published var homes: [HMHome] = []
    private let manager = HMHomeManager()
    
    override init() {
        super.init()
        manager.delegate = self  // This triggers automatic permission
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        DispatchQueue.main.async {
            self.homes = manager.homes
            self.accessories = manager.homes.first?.accessories ?? []
            print("✅ Found \(self.accessories.count) HomeKit devices")
        }
    }
}

/* struct ContentView: View {
    @StateObject private var homeStore = HomeStore()
    
    var body: some View {
        NavigationView {
            List(homeStore.accessories, id: \.uniqueIdentifier) { accessory in
                Text(accessory.name)
            }
            .navigationTitle("HomeKit Devices")
        }
    }
}
*/

struct ContentView: View {
    @StateObject private var homeStore = HomeStore()
    @State private var selectedAccessory: HMAccessory? = nil  // ← Binding pro detail
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedAccessory) {  // ← TOTO je klíč
                ForEach(homeStore.accessories, id: \.uniqueIdentifier) { accessory in
                    Label(accessory.name, systemImage: "lightbulb.fill")
                        .tag(accessory)  // ← TOTO musí být
                }
            }
            .navigationTitle("Zařízení")
        } detail: {
            if let accessory = selectedAccessory {
                DeviceDetailView(accessory: accessory)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    Text("Vyber zařízení")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}


struct DeviceDetailView: View {
    let accessory: HMAccessory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Název a ikonka
                Label(accessory.name, systemImage: "lightbulb")
                    .font(.largeTitle)
                
                // ID
                GroupBox("UUID") {
                    Text(accessory.uniqueIdentifier.uuidString)
                        .font(.monospaced(.caption)())
                        .textSelection(.enabled)
                }
                
                // Room (pokud existuje)
                if let room = accessory.room {
                    GroupBox("Místnost") {
                        Text(room.name)
                    }
                }
                
                // Services (světla, spínače...)
                GroupBox("Služby") {
                    ForEach(accessory.services, id: \.uniqueIdentifier) { service in
                        Text("• \(service.name)")
                    }
                }
            }
            .padding()
        }
        .navigationTitle(accessory.name)
    }
}
