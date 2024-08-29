import SwiftUI

struct ContentView: View {
    @State private var isSDKViewPresented = false
    
    func connectSdk() {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                DataUI.presentSDK(from: rootViewController)
            }
        }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {
                    connectSdk()
                }){
                    Text("OPEN APP")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 150)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Spacer()
                Text("APP Which has the AR Feature Integrated")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
        }
    }
}

#Preview {
    ContentView()
}
