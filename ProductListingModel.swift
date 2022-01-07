//
//  ProductListingModel.swift
//  SilverFox
//
//  Created by Brst-pc-53 on 07/12/21.
//

import Foundation

struct ProductListingModel{
    var id:Int
    var name:String
    var slug:String
    var price:String
    var quantity:String
    var boxQuantity:String
    var discountprice:String
    var image:String
    
    init(id:Int,name:String,slug:String,price:String,quantity:String,boxQuantity:String,discountprice:String,image:String){
        self.id = id
        self.name = name
        self.slug = slug
        self.price = price
        self.quantity = quantity
        self.boxQuantity = boxQuantity
        self.discountprice = discountprice
        self.image = image
    }
}

struct AllProductListingData{
    var status: Int
    var msg: String
    var categoryName:String
    var ProductData:[ProductListingModel]
    init(status: Int,msg: String,categoryName:String,ProductData:[ProductListingModel]){
        self.status = status
        self.msg = msg
        self.categoryName = categoryName
        self.ProductData = ProductData
    }
}
