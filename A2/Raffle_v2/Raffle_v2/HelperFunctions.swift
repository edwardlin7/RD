//
//  HelperFunctions.swift
//  Raffle_v2
//
//  Created by Chengming Liu on 24/5/20.
//  Copyright © 2020 University of Tasmania. All rights reserved.
//

import Foundation
import UIKit

public class Helper {
    
     static func getCurrentTime() -> String{
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        let now = dateFormatterGet.string(from: Date())
        return now
    }
    
    static func getTicketNum(exclude:[Int], min:Int, max:Int, type:Int, numOfTickets:Int) -> [Int] {
        var ran = [Int]()
        var num:Int
        for i in 1...numOfTickets{
            if type == 1{
                repeat {
                    num = Int.random(in: min...max)
                } while exclude.contains(num) || ran.contains(num)
            }else{
                num = (exclude.max() ?? 0) + i
            }
            ran.append(num)
        }
        return ran
    }
    
    static func decodeImage(imageBase64:String) -> UIImage {
        
        let dataDecoded:NSData = NSData(base64Encoded: imageBase64, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedImage:UIImage = UIImage(data: dataDecoded as Data)!
        
        return decodedImage
    }
    
    static func alertTextAlignment(text:String) -> NSMutableAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left

        let messageText = NSMutableAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)
            ]
        )
        return messageText
    }

    
}
