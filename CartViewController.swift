//
//  CartViewController.swift
//  SilverFox
//
//  Created by Satinderjeet Kaur on 22/03/21.
//

import UIKit
import RealmSwift
class CartViewController: UIViewController {

    
    @IBOutlet weak var btnNext: UIButton!
    
    @IBOutlet weak var cartImg: UIImageView!

    @IBOutlet weak var paymentImg: UIImageView!
    
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var mrpPriceLbl: UILabel!
    @IBOutlet weak var deliveryChargesLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var totalAmountLbl: UILabel!
    @IBOutlet weak var addressImage: UIImageView!
    
    let realm = try? Realm()
    var allProductData = [AddToDetailProductModel]()
    var mrpNewPrice = [Float]()
    var discountNewPrice = [Float]()
    var addressData = [addressModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        radius()
        if addressData.count == 0 {
            realmData()
        } else {
            reorderProductOrder()
        }
        
    }
    
    func reorderProductOrder(){
        mrpNewPrice.removeAll()
        discountNewPrice.removeAll()
        
        if allProductData.count == 0 {
            navigationController?.popViewController(animated: true)
        }
        for allData in allProductData {
            mrpNewPrice.append(Float(allData.productUpdatedPrice ?? "") ?? 0.0)
        }
        
        let sum = mrpNewPrice.reduce(0, +)
        mrpPriceLbl.text = "$\(sum)"
        
        if allProductData.count != 0 {
            for allData in allProductData {
                discountNewPrice.append(Float(allData.productUpdatedPrice)! - Float(allData.productUpdatedDiscountPrice)!)
            }
        }
        
        
        let discountsum = discountNewPrice.reduce(0, +)
        discountLbl.text = "$\(discountsum)"
        
        totalAmountLbl.text = "$\(sum - discountsum)"
        tbl.reloadData()
    }
    
    func radius(){
        btnNext.addButtonBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 26.5)
        cartImg.addImageBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 23)
        addressImage.addImageBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 23)
        paymentImg.addImageBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 23)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mobileNumber == ""{
            
        } else {
            addressImage.backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.4274509804, blue: 0.7137254902, alpha: 1)
            paymentImg.backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.4274509804, blue: 0.7137254902, alpha: 1)
            addressImage.image = UIImage(named: "Location")
            paymentImg.image = UIImage(named: "selctedPayment")
            paymentImg.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    //MARK:- BUTTON ACTIONS
        
    @IBAction func actionBack(_ sender: Any) {
        firstName = ""
        lastName = ""
        email = ""
        mobileNumber = ""
        zipCode = ""
        streetData = ""
        cityName = ""
        flatData = ""
        stateName = ""
        countryName = ""
        landMark = ""
        mrpPrice = ""
        discountPrice = ""
        totalPrice = ""
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionNext(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: addressViewController) as! AddressViewController
        vc.mrp = mrpPriceLbl.text ?? ""
        vc.discount = discountLbl.text ?? ""
        vc.totalAmount = totalAmountLbl.text ?? ""
        vc.addressData = addressData
        self.navigationController?.pushViewController(vc,animated: true)
    }

    @objc func addItemBtnPressed(sender: UIButton) {
        
        if addressData.count == 0 {
            let atendaceResult = realm?.objects(AddToCartModel.self)
            
            if atendaceResult?[sender.tag].productQuantity != atendaceResult?[sender.tag].productUserQuantity {
                try! self.realm?.write({
                    let quantity = Int(atendaceResult?[sender.tag].productQuantity ?? "")
                    let price = Float(atendaceResult?[sender.tag].productPrice ?? "")
                    let updatedprice = Float(atendaceResult?[sender.tag].productUpdatedPrice ?? "")
                    let discountPrice = Float(atendaceResult?[sender.tag].productDiscountPrice ?? "")
                    let discountUpdatedPrice = Float(atendaceResult?[sender.tag].productDiscountUpdatedPrice ?? "")
                    atendaceResult?[sender.tag].productQuantity = "\(quantity! + 1)"
                    atendaceResult?[sender.tag].productUpdatedPrice = "\(updatedprice! + price!)"
                    atendaceResult?[sender.tag].productDiscountUpdatedPrice = "\(discountUpdatedPrice! + discountPrice!)"
                })
                realmData()
            } else {
                
            }
            
        } else {
            
            if allProductData[sender.tag].productQuantity != allProductData[sender.tag].productUpdatedDiscountPrice {
                let quantity = Int(allProductData[sender.tag].productQuantity )
                let price = Float(allProductData[sender.tag].productPrice )
                let updatedprice = Float(allProductData[sender.tag].productUpdatedPrice )
                let discountPrice = Float(allProductData[sender.tag].productDiscountPrice )
                let discountUpdatedPrice = Float(allProductData[sender.tag].productUpdatedDiscountPrice )
                allProductData[sender.tag].productQuantity = "\(quantity! + 1)"
                allProductData[sender.tag].productUpdatedPrice = "\(updatedprice! + price!)"
                allProductData[sender.tag].productUpdatedDiscountPrice = "\(discountUpdatedPrice! + discountPrice!)"
                
                reorderProductOrder()
            } else {
                
            }
            
        }
        
    }
    
    @objc func deleteItemBtnPressed(sender: UIButton) {
        if addressData.count == 0 {
            let atendaceResult = realm?.objects(AddToCartModel.self)
            
            if Int(atendaceResult?[sender.tag].productQuantity ?? "") ?? 0 > 1 {
                try! self.realm?.write({
                    let quantity = Int(atendaceResult?[sender.tag].productQuantity ?? "")
                    let price = Float(atendaceResult?[sender.tag].productPrice ?? "")
                    let updatedprice = Float(atendaceResult?[sender.tag].productUpdatedPrice ?? "")
                    let discountPrice = Float(atendaceResult?[sender.tag].productDiscountPrice ?? "")
                    let discountUpdatedPrice = Float(atendaceResult?[sender.tag].productDiscountUpdatedPrice ?? "")

                    atendaceResult?[sender.tag].productQuantity = "\(quantity! - 1)"
                    atendaceResult?[sender.tag].productUpdatedPrice = "\(updatedprice! - price!)"
                    atendaceResult?[sender.tag].productDiscountUpdatedPrice = "\(discountUpdatedPrice! - discountPrice!)"
                    
                })
                realmData()
            }
        } else {
            
            if Int(allProductData[sender.tag].productQuantity ) ?? 0 > 1 {
                let quantity = Int(allProductData[sender.tag].productQuantity )
                let price = Float(allProductData[sender.tag].productPrice )
                let updatedprice = Float(allProductData[sender.tag].productUpdatedPrice )
                let discountPrice = Float(allProductData[sender.tag].productDiscountPrice )
                let discountUpdatedPrice = Float(allProductData[sender.tag].productUpdatedDiscountPrice )
                
                allProductData[sender.tag].productQuantity = "\(quantity! - 1)"
                allProductData[sender.tag].productUpdatedPrice = "\(updatedprice! - price!)"
                allProductData[sender.tag].productUpdatedDiscountPrice = "\(discountUpdatedPrice! - discountPrice!)"
                
                reorderProductOrder()
            }
        }
        
    }
    
    
    @objc func deletedItemDataBtnPressed(sender: UIButton) {
        let alertController = UIAlertController(title: "", message: "Are you sure you want to Remove this product from cart ?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .default) { action in
            
            if self.addressData.count == 0 {
                let atendaceResult = self.realm?.objects(AddToCartModel.self)
                
                try! self.realm?.write {
                    let deleteData = atendaceResult?[sender.tag]
                    self.realm?.delete(deleteData!)
                }
                self.realmData()
            } else {
                
                self.allProductData.remove(at: sender.tag)
                self.reorderProductOrder()
            }
            
        }
        let CancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
            print("You've pressed OK Button")
        }
        alertController.addAction(CancelAction)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func realmData(){
        let results = realm?.objects(AddToCartModel.self)
        print(results)
        allProductData.removeAll()
        mrpNewPrice.removeAll()
        discountNewPrice.removeAll()
        if results != nil {
            if results?.count != 0 {
                for allItems in results! {
                    mrpNewPrice.append(Float(allItems.productUpdatedPrice ?? "") ?? 0.0)
                    allProductData.append(AddToDetailProductModel.init(id: allItems.id ?? "", productId: allItems.productId ?? "", productImage: allItems.productImage ?? "", productName: allItems.productName ?? "", productSlug: allItems.productSlug ?? "", productQuantity: allItems.productQuantity ?? "", productUserQuantity: allItems.productUserQuantity ?? "", productDiscountPrice: allItems.productDiscountPrice ?? "", productUpdatedDiscountPrice: allItems.productDiscountUpdatedPrice ?? "", productPrice: allItems.productPrice ?? "", productUpdatedPrice: allItems.productUpdatedPrice ?? ""))
                }
            }
        }
        
        if results?.count == 0 {
            self.navigationController?.popViewController(animated: true)
        }
        let sum = mrpNewPrice.reduce(0, +)
        mrpPriceLbl.text = "$\(sum)"
        
        if allProductData.count != 0 {
            for allData in allProductData {
                discountNewPrice.append(Float(allData.productUpdatedPrice)! - Float(allData.productUpdatedDiscountPrice)!)
            }
        }
        
        
        let discountsum = discountNewPrice.reduce(0, +)
        discountLbl.text = "$\(discountsum)"
        
        totalAmountLbl.text = "$\(sum - discountsum)"
        tbl.reloadData()
    }
    
    @IBAction func addressBtnAction(_ sender: Any) {
        if mobileNumber == "" {
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: addressViewController) as! AddressViewController
            vc.mrp = mrpPriceLbl.text ?? ""
            vc.discount = discountLbl.text ?? ""
            vc.totalAmount = totalAmountLbl.text ?? ""
            self.navigationController?.pushViewController(vc,animated: false)
        }
    }
    
    @IBAction func paymentBtnAction(_ sender: Any) {
        if mobileNumber == "" {
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
            self.navigationController?.pushViewController(vc,animated: false)
        }
    }
    
}


//MARK: TABLEVIEW CELL CLASS

class CartViewTableView: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var viewImageInside: UIView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var discountStrikeVw: UIView!
    
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCutPrice: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnSub: UIButton!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var outOfStockLbl: UILabel!
    
    
    override func awakeFromNib() {
        radius()
    }
    
    func radius() {
        btnAdd.addButtonBorder(borderColor: #colorLiteral(red: 0, green: 0.3992938995, blue: 0.6427186728, alpha: 1), borderWith: 1, borderCornerRadius: 11)
        btnSub.addButtonBorder(borderColor: #colorLiteral(red: 0, green: 0.3992938995, blue: 0.6427186728, alpha: 1), borderWith: 1, borderCornerRadius: 11)
        viewImageInside.addViewBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 5)
        viewImg.addViewBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 10)
        backView.addViewBorder(borderColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0), borderWith: 0, borderCornerRadius: 5)
    }
}

//MARK: TABLEVIEW DELEGATE AND DATASOURCE METHODS

extension CartViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProductData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cartViewTableView) as! CartViewTableView
        cell.lblPrice.text = "$ \(allProductData[indexPath.row].productUpdatedDiscountPrice)"
        cell.lblCount.text = allProductData[indexPath.row].productQuantity
        cell.lblDescription.text = allProductData[indexPath.row].productSlug
        cell.lblName.text = allProductData[indexPath.row].productName
        if allProductData[indexPath.row].productUserQuantity != "0"{
            cell.outOfStockLbl.isHidden = true
        }
            
        if allProductData[indexPath.row].productUpdatedDiscountPrice == allProductData[indexPath.row].productUpdatedPrice {
            cell.lblCutPrice.isHidden = true
            cell.discountStrikeVw.isHidden = true
        } else {
            cell.lblCutPrice.isHidden = false
            cell.discountStrikeVw.isHidden = false
        }
        
        cell.lblCutPrice.text = "$ \(allProductData[indexPath.row].productUpdatedPrice)"
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(self.addItemBtnPressed), for: .touchUpInside)
        cell.imgView.sd_setImage(with: URL(string: allProductData[indexPath.row].productImage), placeholderImage: UIImage(named: "logo-screen"), options: .refreshCached)
        cell.btnSub.tag = indexPath.row
        cell.btnSub.addTarget(self, action: #selector(self.deleteItemBtnPressed), for: .touchUpInside)
        
        cell.btnCross.tag = indexPath.row
        cell.btnCross.addTarget(self, action: #selector(self.deletedItemDataBtnPressed), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tbl.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                var areaOfGrowthTableViewHeight: CGFloat {
                    tbl.layoutIfNeeded()
                    return tbl.contentSize.height
                }
                self.tblHeight.constant = areaOfGrowthTableViewHeight
            }
        }
    }
}

