//
//  TextCompareArrayView.swift
//  Ignite
//
//  Created by Craig Martin on 4/3/2026.
//

import SwiftUI

struct TextCompareArrayView: View {
    let header: String
    @Binding var storedGenreArray: [[String]]
    @Binding var selectedIndex: Int
    @Binding var bedrockField: [String]
    @Binding var enrichment: Enrichment?
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
            HStack(spacing: 48) {
                VStack {
                    
                    ForEach(bedrockField.indices, id: \.self) { index in
                        TextEditor(text: $bedrockField[index])
                            .font(.title2)
                            .foregroundStyle(.ignitePink)
                            .scrollContentBackground(.hidden)
                            
                    }
                }
                .padding(6)
                .padding(.trailing, 48)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .frame(minHeight: height)
                .background(.ignitePink.opacity(0.4))
                .cornerRadius(8)
                .overlay(alignment: .topTrailing) {
                    Button {
                        storedGenreArray.append(bedrockField)
                        selectedIndex = storedGenreArray.count - 1
                        bedrockField = []
                    } label: {
                        Image(systemName: "arrow.right")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(8)
                    }
                }
                
                
                Text(storedGenreArray.isEmpty ? "" : storedGenreArray[selectedIndex].joined(separator: ", "))
                    .font(.title2)
                    .foregroundStyle(.igniteWhite)
                    .padding()
                    .padding(.trailing, 48)
                    .frame(maxWidth: .infinity, minHeight: height, alignment: .topLeading)
                    .background(.igniteGreen.opacity(0.4))
                    .cornerRadius(8)
                    .textSelection(.enabled)
                    .overlay(alignment: .topTrailing) {
                        Menu {
                            ForEach(Array(storedGenreArray.enumerated()), id: \.offset) { index, text in
                                Button {
                                    selectedIndex = index
                                } label: {
                                    HStack {
                                        Text("\(index + 1)")
                                        if selectedIndex == index {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(8)
                                .padding(.top, 8)
                            
                        }
                    }
            }
            
            HStack {
//                Text("Confidence Score: \(String(format: "%.2f", enrichment?.aggregatedConfidence ?? 0))")
//                    .font(.title3)
//                    .foregroundStyle(.igniteSoftPink)
//                    .padding(.trailing, 24)
                
                Text("LLM: \(enrichment?.source ?? "")")
                    .font(.title3)
                    .foregroundStyle(.igniteWhite.opacity(0.5))
                
                Spacer()
            }
            .padding()
            
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 24)
    }
}
