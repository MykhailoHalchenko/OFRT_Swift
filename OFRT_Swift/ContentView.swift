import SwiftUI

struct ContentView: View {
    @State private var inputMode: InputMode = .slider
    @State private var timeoutDurationSlider: Double = 300
    @State private var timeoutDurationText: String = "300"
    @State private var isTrackingActive = false
    @State private var errorMessage: String = ""
    @State private var isDarkMode = false
    
    enum InputMode {
        case slider
        case textField
    }
    
    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color.white)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? .yellow : .primary)
                            .padding()
                    }
                    Spacer()
                }
                .padding()
                
                Image(isDarkMode ? "sun_image" : "moon_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Picker("Режим введення", selection: $inputMode) {
                    Text("Повзунок").tag(InputMode.slider)
                    Text("Текстове поле").tag(InputMode.textField)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Text("Час до блокування")
                    .font(.title)
                    .foregroundColor(isDarkMode ? .white : .black)
                
                if inputMode == .slider {
                    sliderInputView
                } else {
                    textFieldInputView
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Button(action: startTracking) {
                        Text("Старт")
                            .padding()
                            .background(isTrackingActive ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(isTrackingActive)
                    }
                    
                    Button(action: stopTracking) {
                        Text("Стоп")
                            .padding()
                            .background(isTrackingActive ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!isTrackingActive)
                    }
                }
                
                Text(isTrackingActive
                     ? "Відстеження активне: \(currentDurationString()) сек"
                     : "Відстеження зупинено")
                    .padding()
                    .foregroundColor(isDarkMode ? .white : .black)
            }
            .padding()
        }
    }
    
    var sliderInputView: some View {
        VStack {
            Slider(value: $timeoutDurationSlider,
                   in: 30...1800,
                   step: 30)
                .accentColor(.blue)
            
            Text("\(Int(timeoutDurationSlider)) секунд")
                .foregroundColor(isDarkMode ? .white : .blue)
        }
    }
    
    var textFieldInputView: some View {
        VStack {
            TextField("Введіть час в секундах", text: $timeoutDurationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .foregroundColor(isDarkMode ? .white : .black)
                .padding()
                .background(isDarkMode ? Color.white.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            Text("Поточне значення: \(timeoutDurationText) секунд")
                .foregroundColor(isDarkMode ? .white : .blue)
        }
    }
    
    func currentDurationString() -> String {
        return inputMode == .slider
            ? String(Int(timeoutDurationSlider))
            : timeoutDurationText
    }
    
    func startTracking() {
        let durationString = currentDurationString()
        
        guard let duration = Double(durationString), duration >= 30, duration <= 1800 else {
            errorMessage = "Час має бути від 30 до 1800 секунд"
            return
        }
        
        errorMessage = ""
        ScreenTimeoutManager.shared.startTracking(duration: duration)
        isTrackingActive = true
    }
    
    func stopTracking() {
        ScreenTimeoutManager.shared.stopTracking()
        isTrackingActive = false
        errorMessage = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
