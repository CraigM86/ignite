//
//  ExistingFieldsView.swift
//  Ignite
//
//  Created by Craig Martin on 2/3/2026.
//

import SwiftUI

struct ExistingFieldsView: View {
    let header: String
    let text: String
    let height: CGFloat
    
    var body: some View {
        VStack {
            HStack {
                Text(header)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.igniteWhite)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundStyle(.igniteWhite)
                    .padding()
                    .frame(maxWidth: 400, minHeight: height, alignment: .topLeading)
                    .background(.igniteDarkGrey)
                    .cornerRadius(8)
                    .textSelection(.enabled)
                
                Spacer()
            }
        }
        .padding()
    }
}
