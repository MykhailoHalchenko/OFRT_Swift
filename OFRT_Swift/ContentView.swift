import SwiftUI

class ContentViewModel: ObservableObject, ScreenTimeoutDelegate {
    @Published var isTracking = false
    @Published var remainingTime: TimeInterval = 120
    
    func startTracking() {
        ScreenTimeoutManager.shared.startTracking(
            duration: remainingTime,
            delegate: self
        )
        isTracking = true
    }
    
    func stopTracking() {
        ScreenTimeoutManager.shared.stopTracking()
        isTracking = false
    }
    
    func screenTimeoutDidOccur(in language: Localization.Language) {
        DispatchQueue.main.async { [weak self] in
            self?.isTracking = false
            self?.remainingTime = 120
        }
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Screen Timeout Demo")
                .font(.title)
                .fontWeight(.bold)
            
            Text(viewModel.timeString(from: viewModel.remainingTime))
                .font(.largeTitle)
                .monospacedDigit()
            
            HStack {
                Button(action: viewModel.startTracking) {
                    Text("Start Tracking")
                        .padding()
                        .background(viewModel.isTracking ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isTracking)
                
                Button(action: viewModel.stopTracking) {
                    Text("Stop Tracking")
                        .padding()
                        .background(viewModel.isTracking ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isTracking)
            }
        }
        .onAppear {
            ScreenTimeoutManager.shared.delegate = viewModel
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
