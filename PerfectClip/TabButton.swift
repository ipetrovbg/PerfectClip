//
//  TabButton.swift
//  PerfectClip
//
//  Created by Petar Petrov on 19.02.22.
//

import SwiftUI

struct TabButton: View {
    @Binding var selected: String
    var title: String
    var icon: String
    var id: String
    
    var body: some View {
        Button {
            withAnimation {
                selected = id
            }
        } label: {
            VStack(spacing: 7) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(title)
                    .foregroundColor(.white)
            }
            
            .frame(width: 70, height: 60)
            .aspectRatio(contentMode: .fit)
            .contentShape(Rectangle())
            
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.primary.opacity(selected == id ? 0.2 : 0))
        .cornerRadius(10)
        .padding()

    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        TabButton(selected: .constant("settings"), title: "Settings", icon: "gear", id: "settings")
    }
}
