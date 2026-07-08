//
//  ContentView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 06/07/26.
//

import SwiftUI

struct GameDashboardView: View {
    // Simulasi data yang sudah di-decode (Ganti ini dengan logika load JSON-mu nanti)
    @State private var gameData: GameData? = nil
    
    var body: some View {
        Group {
            if let data = gameData {
                TabView {
                    // TAB 1: RESIDENTS (MANIFEST)
                    ResidentListView(residents: data.residents)
                        .tabItem {
                            Label("Warga Asli", systemImage: "person.2.fill")
                        }
                    
                    // TAB 2: ENCOUNTERS (ANOMALIES & RESIDENTS)
                    EncounterListView(encounters: data.encounters)
                        .tabItem {
                            Label("Antrean (Encounters)", systemImage: "list.bullet.rectangle.portrait")
                        }
                    
                    // TAB 3: VILLAGE MAP
                    VillageMapView(houses: Array(data.villageMap.houses.values).sorted(by: { $0.houseID < $1.houseID }))
                        .tabItem {
                            Label("Peta Desa", systemImage: "map.fill")
                        }
                }
            } else {
                ContentUnavailableView("Data Belum Dimuat", systemImage: "doc.text.magnifyingglass", description: Text("Menunggu proses decode JSON..."))
            }
        }
        .onAppear {
            loadMockData()
        }
    }
    
    // Fungsi sementara untuk mengisi data UI (Preview)
    private func loadMockData() {
        // Nanti kamu bisa isi ini dengan JSONDecoder dari file GameData.json
        // Untuk sekarang, pastikan fungsi load JSON milikmu men-set nilai ke `gameData`
    }
}

// MARK: - SubView: Resident List
struct ResidentListView: View {
    let residents: [ResidentManifest]
    
    var body: some View {
        NavigationStack {
            List(residents) { resident in
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**Pekerjaan:** \(resident.occupation)")
                        Text("**Lahir:** \(resident.dateOfBirth ?? "-")")
                        Text("**Relasi:** \(resident.relation)")
                        Text("**Kepribadian:** \(resident.personality)")
                        Text("**Secret Lore:** \(resident.secretLore)")
                            .foregroundColor(.orange)
                    }
                    .padding(.vertical, 4)
                } label: {
                    HStack {
                        Text(resident.trueAddress)
                            .font(.headline)
                            .frame(width: 80, alignment: .leading)
                        VStack(alignment: .leading) {
                            Text(resident.trueName).font(.title3).bold()
                            Text(resident.residentID).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Manifest Warga (Source of Truth)")
        }
    }
}

// MARK: - SubView: Encounter List
struct EncounterListView: View {
    let encounters: [EncounterData]
    
    var body: some View {
        NavigationStack {
            List(encounters) { encounter in
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 12) {
                        // KTP Data
                        GroupBox("Data KTP") {
                            VStack(alignment: .leading) {
                                Text("Nama: \(encounter.idCardData.printedName)")
                                Text("Alamat: \(encounter.idCardData.printedAddress)")
                                Text("Tgl Lahir: \(encounter.idCardData.dateOfBirth ?? "-")")
                                Text("Kedaluwarsa: \(encounter.idCardData.expirationDate)")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // LLM Prompt
                        GroupBox("LLM Prompt Context") {
                            VStack(alignment: .leading) {
                                Text("Role: \(encounter.llmPromptContext.roleType.rawValue.uppercased())")
                                    .bold()
                                    .foregroundColor(encounter.llmPromptContext.roleType == .anomaly ? .red : .green)
                                Text("Instruksi: \(encounter.llmPromptContext.behavioralInstruction)")
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 4)
                } label: {
                    VStack(alignment: .leading) {
                        Text(encounter.scenarioName)
                            .font(.headline)
                            .foregroundColor(encounter.llmPromptContext.roleType == .anomaly ? .red : .primary)
                        Text(encounter.encounterID)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Antrean Karakter")
        }
    }
}

// MARK: - SubView: Map View
struct VillageMapView: View {
    let houses: [HouseData]
    
    var body: some View {
        NavigationStack {
            List(houses) { house in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(house.houseID)
                            .font(.title2).bold()
                        Spacer()
                        if house.hasParkedVehicle {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                        }
                        if house.residentID == nil {
                            Text("KOSONG").font(.caption).bold().padding(4).background(Color.red.opacity(0.2)).cornerRadius(4)
                        }
                    }
                    Text(house.fullAddress).foregroundColor(.secondary)
                    Divider()
                    Text("Tetangga Kiri: \(house.leftNeighborID ?? "-")")
                    Text("Tetangga Kanan: \(house.rightNeighborID ?? "-")")
                    Text("Depan Rumah: \(house.facingNeighborID ?? "-")")
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Peta Desa")
        }
    }
}

#Preview(windowStyle: .automatic) {
    GameDashboardView()
        .environment(AppModel())
}
