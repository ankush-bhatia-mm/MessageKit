//
//  ChatView.swift
//  ChatExample
//
//  Created by Ankush Bhatia on 22/06/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import SwiftUI
import MessageKit

struct ChatView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = BasicExampleViewController
    
    func makeUIViewController(context: Context) -> BasicExampleViewController {
        let chatController = BasicExampleViewController()
        return chatController
    }
    
    func updateUIViewController(_ uiViewController: BasicExampleViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(with: self)
    }
}

extension ChatView {
    
    class Coordinator: NSObject {
        
        var parent: ChatView
        
        init(with parent: ChatView) {
            self.parent = parent
        }
        
        
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

