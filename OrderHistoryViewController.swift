//
//  OrderHistoryViewController.swift
//  SilverFox
//
//  Created by Satinderjeet Kaur on 26/02/21.
//

import UIKit
import RealmSwift

class OrderHistoryViewController: UIViewController {
    
    //MARK:- OUTLETS
    @IBOutlet weak var viewTbl: UIView!
    @IBOutlet weak var cartCountLbl: UILabel!
    
    @IBOutlet weak var centerOrderHistoryLbl: UIButton!
    
    @IBOutlet weak var tbl: UITableView!
    
    var orderData = [orderHistoryModel]()
    var allProductData = [AddToDetailProductModel]()
    var mrpNewPrice = [Float]()
    var discountNewPrice = [Float]()
    var addressData = [addressModel]()
    let realm = try? Realm()
    var refreshLoader = false
    var paged = 1
    var perPaged = "20"
    var index = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .lightGray
        tbl.refreshControl = refreshControl
        
        self.tbl.layer.cornerRadius = 10.0
        self.tbl.clipsToBounds =  true
        //tbl.layer.masksToBounds = true
        viewTbl.addViewBorder(borderColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), borderWith: 0, borderCornerRadius: 8.0)
        paged = 1
        perPaged = "20"
        orderHistoryApi(paged: "\(paged)", perPaged: perPaged)
    }
    
    @objc func reloadData(sender: UIRefreshControl) {
        sender.beginRefreshing()
        refreshLoader = true
        self.orderData.removeAll()
        paged = 1
        perPaged = "20"
        orderHistoryApi(paged: "\(paged)", perPaged: perPaged)
        sender.endRefreshing()
    }
    
    //MARK: BUTTON ACTIONS
    
    @IBAction func actionBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let results = realm?.objects(AddToCartModel.self)
        if results?.count == 0 {
            cartCountLbl.isHidden = true
        } else {
            cartCountLbl.text = "\(results?.count ?? 0)"
            cartCountLbl.isHidden = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @IBAction func cartBtnAction(_ sender: Any) {
        let results = realm?.objects(AddToCartModel.self)
        if results?.count == 0 {
            Alert.showSimple("No item in your cart")
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: cartViewController) as! CartViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @objc func deleteItemBtnPressed(sender: UIButton) {
        
        orderHistoryApiByID(orderId:"\(orderData[sender.tag].id)")
    }
}


//MARK:- TABLEVIEW DELEGATES AND DATASOURCES METHODS

extension OrderHistoryViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: orderHistoryTableCell) as! OrderHistoryTableCell
        //        cell.layer.cornerRadius = 25.0
        //        cell.layer.masksToBounds = true
        cell.orderIdLbl.text = "\(orderData[indexPath.row].id)"
        cell.orderDateLbl.text = orderData[indexPath.row].createdDate
        cell.orderStatusLbl.text = orderData[indexPath.row].status
        cell.reorderBtn.tag = indexPath.row
        cell.reorderBtn.addTarget(self, action: #selector(self.deleteItemBtnPressed), for: .touchUpInside)
        if orderData[indexPath.row].status == "completed" {
            
        } else {
            cell.reorderBtnHeightConstraint.constant = 0.0
            cell.reorderBtn.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == index - 1 {
            orderHistoryApi(paged: "\(paged)", perPaged: perPaged)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
        vc.orderId = "\(orderData[indexPath.row].id)"
        self.navigationController?.pushViewController(vc,animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension OrderHistoryViewController {
    func orderHistoryApi(paged:String,perPaged:String) {
        if refreshLoader == false {
            Hud.show(message: "Please Wait", view: self.view)
        }
        DataService.sharedInstance.orderHistory(paged:paged,perPaged: perPaged) { (resultDict, errorMsg) in
            Hud.hide(view: self.view)
            print(resultDict as Any)
            
            if errorMsg == nil {
                if resultDict?.count != 0 {
                    
                    if resultDict?["status"] as? Int == 200 {
                        if let allData = resultDict?["data"] as? [NSDictionary] {
                            for orderData in allData {
                                let id = orderData["order_id"] as? Int
                                let date = orderData["created_Date"] as? String
                                let status = orderData["status"] as? String
                                let formatDate = DateFormatter()
                                formatDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                                let drawDate = formatDate.date(from: date ?? "")
                                print(drawDate)

                                // Create Date Formatter
                                let dateFormatter = DateFormatter()

                                // Set Date Format
                                dateFormatter.dateFormat = "MM/dd/yyyy"

                                // Convert Date to String
                                let newDate = dateFormatter.string(from: drawDate!)
                                print(newDate)
                                self.orderData.append(orderHistoryModel.init(id: id ?? 0, createdDate: newDate ?? "", status: status ?? ""))
                            }
                            self.index = self.index + 20
                            self.paged = self.paged + 1
                            self.tbl.reloadData()
                        }
                    }
                }
            } else {
               //self.noExerciseFoundLbl.isHidden = false
                Alert.showSimple(errorMsg ?? "")
            }
        }
    }
    
    func orderHistoryApiByID(orderId:String) {
        Hud.show(message: "Please Wait", view: self.view)
        DataService.sharedInstance.getOrderById(orderID: orderId) { (resultDict, errorMsg) in
            Hud.hide(view: self.view)
            print(resultDict as Any)
            self.allProductData.removeAll()
            self.addressData.removeAll()
            if errorMsg == nil {
                if resultDict?.count != 0 {
                    
                    if let shippingData = resultDict?["billing"] as? NSDictionary {
                        let street = shippingData["address_1"] as? String
                        let flatNumber = shippingData["address_2"] as? String
                        let landMark = shippingData["address_3"] as? String
                        let city = shippingData["city"] as? String
                        let country = shippingData["country"] as? String
                        let email = shippingData["email"] as? String
                        let first_name = shippingData["first_name"] as? String
                        let last_name = shippingData["last_name"] as? String
                        let phone = shippingData["phone"] as? String
                        let postcode = shippingData["postcode"] as? String
                        let state = shippingData["state"] as? String
                        
                        self.addressData.append(addressModel.init(street: street ?? "", flatNumber: flatNumber ?? "", landMark: landMark ?? "", city: city ?? "", country: country ?? "", email: email ?? "", firstName: first_name ?? "", lastName: last_name ?? "", phone: phone ?? "", postcode: postcode ?? "", state: state ?? ""))
                    }
                    
                    if let productData = resultDict?["line_items"] as? [NSDictionary] {
                        for productAllData in productData {
                            print(productAllData)
                            
                            let Id = productAllData["id"] as? Int
                            let productName = productAllData["name"] as? String
                            let productPrice = productAllData["price"] as? Float
                            let productId = productAllData["product_id"] as? Int
                            let quantity = productAllData["quantity"] as? Int
                            let productTotalPrice = productAllData["subtotal"] as? String
                            let productTotal = productAllData["total"] as? String
                            let totalOfRegular = productAllData["total_of_regular"] as? Float
                            let productPendingQuantity = productAllData["pending_quality"] as? String
                            let regularPrice = productAllData["regular_price"] as? String
                            let slugName = productAllData["slug"] as? String
                            if let productImageData = productAllData["image"] as? [NSDictionary] {
                                for productImageAllData in productImageData {
                                    let images = productImageAllData["Original_image_url"] as? String
                                //    print(images)
                                    self.allProductData.append(AddToDetailProductModel.init(id: "\(Id ?? 0)" , productId: "\(productId ?? 0)", productImage: images ?? "", productName: productName ?? "", productSlug: slugName ?? "", productQuantity: "\(quantity ?? 0)", productUserQuantity: productPendingQuantity ?? "", productDiscountPrice: "\(productPrice ?? 0.0)", productUpdatedDiscountPrice: productTotalPrice ?? "", productPrice: regularPrice ?? "", productUpdatedPrice: "\(totalOfRegular ?? 0)"))
                                }
                            }
                        }
                    }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: cartViewController) as! CartViewController
                    vc.allProductData = self.allProductData
                    vc.addressData = self.addressData
                    self.navigationController?.pushViewController(vc, animated: true)

                }
            } else {
               //self.noExerciseFoundLbl.isHidden = false
                Alert.showSimple(errorMsg ?? "")
            }
        }
    }
}
