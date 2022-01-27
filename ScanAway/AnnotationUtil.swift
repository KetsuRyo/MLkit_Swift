//
//  AnnotationUtil.swift
//  ScanAway
//
//  Created by 廖峻傑 on 2022/1/26.
//

import Foundation
import MLKitEntityExtraction

class AnnotationUtil: NSObject {
    
    func stringFromAnnotation(annotation: EntityAnnotation) -> String {
        
        //["0922397477", "0928212960"]
      var outputs: [String] = []
        var output = ""
      for entity in annotation.entities {
          if entity.entityType == EntityType.phone {
            // Identifies a phone number.
            // No structured data available.
              output = "phone"

          } else if entity.entityType == EntityType.address {
              output = "address"
              print("address")
            
          }
         
          
      }
        return output

      }
    
    
    func stringFromGranularity(_ granularity: DateTimeGranularity) -> String {
      switch granularity {
      case DateTimeGranularity.year:
        return "year"
      case DateTimeGranularity.month:
        return "month"
      case DateTimeGranularity.week:
        return "week"
      case DateTimeGranularity.day:
        return "day"
      case DateTimeGranularity.hour:
        return "hour"
      case DateTimeGranularity.minute:
        return "minute"
      case DateTimeGranularity.second:
        return "second"
      case DateTimeGranularity.unknown:
        return "unknown"
      }
    }
    
    func stringFromPaymentCardNetwork(_ network: PaymentCardNetwork) -> String {
      switch network {
      case PaymentCardNetwork.unknown:
        return "unknown"
      case PaymentCardNetwork.amex:
        return "Amex"
      case PaymentCardNetwork.dinersClub:
        return "DinersClub"
      case PaymentCardNetwork.discover:
        return "Discover"
      case PaymentCardNetwork.interPayment:
        return "InterPayment"
      case PaymentCardNetwork.JCB:
        return "JCB"
      case PaymentCardNetwork.maestro:
        return "Maestro"
      case PaymentCardNetwork.mastercard:
        return "Mastercard"
      case PaymentCardNetwork.mir:
        return "Mir"
      case PaymentCardNetwork.troy:
        return "Troy"
      case PaymentCardNetwork.unionpay:
        return "Unionpay"
      case PaymentCardNetwork.visa:
        return "Visa"
      }
    }
    
    func stringFromCarrier(_ carrier: ParcelTrackingCarrier) -> String {
      switch carrier {
      case ParcelTrackingCarrier.unknown:
        return "unknown"
      case ParcelTrackingCarrier.fedEx:
        return "FedEx"
      case ParcelTrackingCarrier.UPS:
        return "UPS"
      case ParcelTrackingCarrier.DHL:
        return "DHL"
      case ParcelTrackingCarrier.USPS:
        return "USPS"
      case ParcelTrackingCarrier.ontrac:
        return "Ontrac"
      case ParcelTrackingCarrier.lasership:
        return "Lasership"
      case ParcelTrackingCarrier.israelPost:
        return "IsraelPost"
      case ParcelTrackingCarrier.swissPost:
        return "SwissPost"
      case ParcelTrackingCarrier.MSC:
        return "MSC"
      case ParcelTrackingCarrier.amazon:
        return "Amazon"
      case ParcelTrackingCarrier.iParcel:
        return "IParcel"
      }
    }
}
