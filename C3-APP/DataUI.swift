//
//  DataUI.swift
//  C3-APP
//
//  Created by Rithik Pranao on 23/08/24.
//

import SwiftUI

public class DataUI {
    public static func presentSDK(from viewController: UIViewController) {
        let hostingController = UIHostingController(rootView: GPSAndBaroView(onClose: {
            viewController.dismiss(animated: true, completion: nil)
        }))
        viewController.present(hostingController, animated: true, completion: nil)
    }
}
