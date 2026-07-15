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
    
    let IndostoryText = """
    Mas Yanto, ini si Marbella kurang ajar. Masa iya anomali dibiarin masuk ke kampung kita? Peja sampe harus nge-hack itu hape buat diatur frekuensinya, jadi kita bisa tangkap si anomali itu.
    
    Malam ini kamu yang jaga ya, saya pusing banget. Ini Kyai Sandy agak-agak requestnya ya--saya mesti jaga peti karung yang gatau lah apa itu isinya.
    
    Salam semangat.
    Tafa Kreasi, anak pak bos Brotowali Kreasi
    
    PS: Harusnya malam ini Handaru gak pulang, kayanya dia ke club. Katanya mau live toktok nyari duit, gatau deh. Mungkin cari tante
    """
    
    let storyText = """
    Yanto, that Marbella is out of line. Can you believe they just let an anomaly slip into our neighborhood? Peja actually had to hack that phone to tune the frequency so we can catch the thing.
    
    You're taking the night shift tonight, my head is killing me. Elder Sandy made a pretty weird request—I have to guard this weird crate and God knows what's actually inside it.
    
    Stay sharp.
    Tafa Kreasi, son of the boss at Brotowali Kreasi
    
    PS: Handaru shouldn't be coming home tonight, I think he hit the club. Said he's doing a Toktok live to make some cash, idk. Probably looking for a sugar mommy.
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
