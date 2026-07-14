//
//  StoryView.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 14/07/26.
//

import SwiftUI

struct StoryView: View {
    @Environment(AppModel.self) var model
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    let storyText = """
    Mas Yanto, ini si Marbella kurang ajar. Masa iya anomali dibiarin masuk ke kampung kita? Peja sampe harus nge-hack itu hape buat diatur frekuensinya, jadi kita bisa tangkap si anomali itu.
    
    Malam ini kamu yang jaga ya, saya pusing banget. Ini Kyai Sandy agak-agak requestnya ya--saya mesti jaga peti karung yang gatau lah apa itu isinya.
    
    Salam semangat.
    Tafa Kreasi, anak pak bos Brotowali Kreasi
    
    PS: Harusnya malam ini Handaru gak pulang, kayanya dia ke club. Katanya mau live toktok nyari duit, gatau deh. Mungkin cari tante
    """
    
    var body: some View {
        ZStack {
            Image("paper_container")
                .resizable()
                .scaledToFill()
            VStack {
                Text(storyText)
                    // .font(.custom("HandwritingFont", size: 22))
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .foregroundColor(Color(red: 0.3, green: 0.15, blue: 0.05))
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
            }
            .padding(80)
        }
        .frame(width: 800, height: 600)
        .ornament(attachmentAnchor: .scene(.bottom), contentAlignment: .top) {
            FrameButton(title: "Tutup") {
                model.currentFlow = .playing
            }
            .padding(.top, 24)
        }
    }
}
