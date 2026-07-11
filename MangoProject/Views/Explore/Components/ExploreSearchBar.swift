//
//  ExploreSearchBar.swift
//  MangoProject
//

import SwiftUI

struct ExploreSearchBar: View {

    @Binding var text: String
    let onClear: () -> Void

    @FocusState private var isFocused: Bool
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search halal food...", text: $text)
                .focused($isFocused)
                .autocorrectionDisabled()
                .onChange(of: text) { newValue in
                    // Stop dictation if the user starts typing manually
                    if speechRecognizer.isListening && speechRecognizer.transcript != newValue {
                        speechRecognizer.stopTranscribing()
                    }
                }
                .onChange(of: speechRecognizer.transcript) { newValue in
                    if speechRecognizer.isListening {
                        text = newValue
                    }
                }

            Spacer(minLength: 0)

            if text.isEmpty {
                Button {
                    speechRecognizer.toggleListening()
                } label: {
                    Image(systemName: speechRecognizer.isListening ? "mic.fill" : "mic")
                        .foregroundStyle(speechRecognizer.isListening ? .red : .secondary)
                }
            } else {
                Button {
                    onClear()
                    isFocused = false
                    speechRecognizer.stopTranscribing()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .background {
            if #available(iOS 26, *) {
                Color.clear
                    .glassEffect(in: RoundedRectangle(cornerRadius: 14))
            } else {
                Color(.systemGray6)
            }
        }
        .onDisappear {
            speechRecognizer.stopTranscribing()
        }
    }
}
