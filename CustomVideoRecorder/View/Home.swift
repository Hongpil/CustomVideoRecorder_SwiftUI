//
//  Home.swift
//  CustomVideoRecorder
//
//  Created by kimhongpil on 2023/05/31.
//

import SwiftUI

struct Home: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: Camera View
            
            // MARK: Controls
            ZStack {
                
                Button {
                    
                } label: {
                    Image("Reels")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .padding(12)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle().fill(Color.black)
                        )
                        .padding(6)
                        .background(
                            Circle().fill(Color.white)
                        )
                }
                
                // Preview Button
                Button {
                    
                } label: {
                    Label {
                        Image(systemName: "chevron.right")
                            .font(.callout)
                    } icon: {
                        Text("Preview")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 10)
            .padding(.bottom, 30)
        }
        .preferredColorScheme(.dark)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
