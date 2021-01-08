//
//  ViewController.swift
//  ToastyDemo
//
//  Created by yangjie on 2021/1/7.
//

import UIKit
import Toasty

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let button = UIButton(type: .system)
        button.setTitle("Show", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.showButtonTouchUpInside), for: .touchUpInside)
        button.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        button.center = CGPoint(x: view.center.x, y: 75)
        self.view.addSubview(button)
        
        //Toast
        ToastCenter.default.isQueueEnabled = false
    }


    @objc func showButtonTouchUpInside() {
        let text: String = "This is a pThis is a piece of toast on top for 3 家韩国开花结果客户关怀火锅和口感好还高环境共和国冠好还高好高好还高好骨灰盒好还高好高好高分同样附体地方i呀UI过一个高好恐惧规格根据客户高环境 赶紧回家过寒假工开饭还高好高好快好好看好高腰裤复古与干枯个开关就好高好结果哦呀老公iu老公不敢回家要跪榴莲干u哦提高secondsThis is a piece of toast on top for 3 家韩国开花结果客户关怀火锅和口感好还高环境共和国冠好还高好高好还高好骨灰盒好还高好高好高分同样附体地方i呀UI过一个高好恐惧规格根据客户高环境 赶紧回家过寒假工开饭还高好高好快好好看好高腰裤复古与干枯个开关就好高好结果哦呀老公iu老公不敢回家要跪榴莲干u哦提高secondsiece of toast"
        
        Toast(text: text,position: .center, superView: self.view).show()
        self.view.makeToast(text: "view extention make toast!",position: .top)
    }
}

