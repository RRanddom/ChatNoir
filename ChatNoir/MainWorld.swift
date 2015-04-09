//
//  ViewController.swift
//  ChatNoir
//
//  Created by apple on 15-4-7.
//  Copyright (c) 2015年 apple.com. All rights reserved.
//

import UIKit

struct Point :Equatable,Hashable{
    var x: Int
    var y: Int
    var empty: Bool
    
    var hashValue :Int {
        get{
            
            return x << 6 + y
        }
    }
}

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}



class MainWorld: UIViewController {
    

    var worldMap = Array< Array<Bool> >()
    var views = Array< Array<UIView?> >()
    var catPosition:Point = Point(x:0,y:0,empty:true)
    
    let defaultColor = UIColor(red: 0.23, green: 0.78, blue: 0.33, alpha: 1)
    let brickColor = UIColor(red: 0.11, green: 0.32, blue: 0.79, alpha: 1)
    let catImageView = UIImageView(image: UIImage(named: "chatNoir_"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData(8, height: 12)
        drawTheWorld(8, height: 12)
        drawRandomBricks(8, height: 12)
        drawRandomCat(8, height: 12)
        
        var gestureRec = UITapGestureRecognizer(target: self, action: "handleTap:")
        view.addGestureRecognizer(gestureRec)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(width:Int,height:Int){
        assert({() -> Bool in return (2 * width >= height ?  true :  false) }(), {() -> String in return "height should be smaller or equal to 2*width"}())
        worldMap.removeAll(keepCapacity: false)
        for h in 1...height{
            worldMap.append(Array(count: width, repeatedValue: false))
        }
        
    
    }
    
    
    func drawTheWorld(width:Int,height:Int){
        
        views.removeAll(keepCapacity: false)
        var listofArray = [UIView?](count:width,repeatedValue:nil)
        views = [ Array<UIView?> ](count:height,repeatedValue:listofArray)
        
        let frameWidth:CGFloat = view.frame.size.width
        let framwHeight:CGFloat = view.frame.size.height
        
        let border:CGFloat = 4
        
        let tmpSize:CGFloat = frameWidth - CGFloat(width-1)*border - border*CGFloat(width-1)
        let size:CGFloat = tmpSize / CGFloat(width) //calc the size
        
        var startPoint:CGPoint = CGPoint(x: border, y: 20)
        
        for i in 1...height{
            //draw UIView at coordinate
            for j in 1...width{
                if(j == 1){
                    if(i % 2 == 0){
                        startPoint = CGPoint(x: border, y: startPoint.y + size )
                    }else{
                        startPoint = CGPoint(x: border + size/2, y: startPoint.y + size )
                    }
                }else{
                    startPoint = CGPoint(x: startPoint.x + size + border, y: startPoint.y)
                }
                
                var circleView:UIView = UIView(frame: CGRect(x: startPoint.x , y: startPoint.y, width: size, height: size))
                circleView.layer.cornerRadius = size/2;
                circleView.backgroundColor = defaultColor
                circleView.layer.masksToBounds = true
                views[i-1][j-1] = circleView
                view.addSubview(circleView)
            }
        }
    }
    
    func drawRandomBricks(width:Int,height:Int) {

        let numberOfBricks = Int(arc4random_uniform(6)) + 8
        
        //set the worldMap
        for i in 1...numberOfBricks {
            var randomNumber = arc4random_uniform(UInt32(width) * UInt32(height))
            worldMap[Int(randomNumber)/height ][Int(randomNumber)%width] = true
            var aView = views[Int(randomNumber)/height][Int(randomNumber)%width]
            
            aView?.backgroundColor = brickColor
        }
        
    }
    
    
    func drawRandomCat(width:Int,height:Int) { // first element is height
        var position = Point(x: height/2, y: width/2, empty: false)
        
        while(worldMap[position.x][position.y]){ // while there is bricks at the point
            //next position
            if(position.x < height/2+2){
                position.x++
            }else{
                position.y++
            } // move point
        }
        catPosition = position
        var aView = views[catPosition.x][catPosition.y]
        aView?.addSubview(catImageView)
   
    }
    
    func handleTap(rec:UIGestureRecognizer){
        //scan all point
        var point = rec.locationInView(view)
        
        var loc = rec.locationInView(rec.view)
        var subView  = rec.view?.hitTest(loc, withEvent: nil)
        
        for i in 0...views.count-1{
            for j in 0...views[i].count-1{
                if(views[i][j] == subView){
                    if(CGPointMake(CGFloat(catPosition.x),CGFloat(catPosition.y)) != CGPointMake(CGFloat(i), CGFloat(j)) && !worldMap[i][j]){
                        worldMap[i][j] = true
                        subView?.backgroundColor = brickColor
                        
                        if(!bfs(catPosition)){
                            gameWin()
                        }
                    }
                }
            }
        }
    }
    
    func gameReStart(){
        for views in view.subviews{
            views.removeFromSuperview()
        }
        
        initData(8, height: 12)
        drawTheWorld(8, height: 12)
        drawRandomBricks(8, height: 12)
        drawRandomCat(8, height: 12)
    }
    
    func gameOver() {
        insertAlertView(false)
    
    }
    
    func gameWin(){
        insertAlertView(true)
    }
    
    
    func insertAlertView(isWin:Bool) {
       
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.alpha = 1
        //view.addSubview(blurView)
        UIView.transitionWithView(view, duration: 0.8, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {()->Void in self.view.addSubview(blurView) }, completion: nil)
        
        var title:String
        //var message:String
        if(isWin){
            title = "You Win"
        }else{
            title = "Try Again?"
        }
        
        var alert = UIAlertController(title: title , message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler:{(UIAlertAction)-> Void in  self.gameReStart() }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    

    
    func bfs(startPoint:Point) -> Bool{
        
        if(reachBoundary(startPoint)){
            gameOver()
            return true
        }
        
        let height = worldMap.count
        let width  = worldMap[0].count
        
        var tmp = [Bool](count:width , repeatedValue: false)
        var visited = [Array<Bool>](count:height,repeatedValue: tmp)
        
        var parent = [Point:Point]() //
        var queue = Queue<Point>()
        
        queue.enQueue(startPoint)
        
        visited[startPoint.x][startPoint.y] = true
        
        while (!queue.isEmpty()){
            var node = queue.deQueue()
            
            if(self.reachBoundary(node!)){
                var father = parent[node!]
                
                self.backtrace(parent, start: startPoint, end: node!)
                return true
            }
        
            var adjacent = getAdjacent(node!, visited: &visited)
            
            for someNode in adjacent{
                parent[someNode] = node!
                queue.enQueue(someNode)
            }
        }
        return false
    }
    
    func backtrace(parent:[Point:Point],start:Point,end:Point) -> Point {
        var tmpPoint = end
        
        while(parent[tmpPoint] != start){
            tmpPoint = parent[tmpPoint]!
        }
        
        //cat move to tmpPoint
        catImageView.removeFromSuperview()
        catPosition = tmpPoint
        
        var aView = views[catPosition.x][catPosition.y]
        aView?.addSubview(catImageView)
        
        return tmpPoint
    }
    
    
    func reachBoundary(startPoint:Point) -> Bool {
        var height = worldMap.count
        var width  = worldMap[0].count
        
        if(startPoint.x == 0 || startPoint.y == 0 || startPoint.x == height - 1 || startPoint.y == width - 1){
            return !worldMap[startPoint.x][startPoint.y]
        }else {
            return false
        }
    }
    
    func getAdjacent(startPoint:Point,inout visited:[[Bool]]) -> [Point]{
        var points = [Point]()
        
        var y_offset = startPoint.x % 2 == 0 ? 1 : -1
        
        if(!worldMap[startPoint.x][startPoint.y + 1] && !visited[startPoint.x][startPoint.y + 1]){
            points.append(Point(x: startPoint.x,y: startPoint.y + 1,empty: false))
            visited[startPoint.x][startPoint.y + 1] = true
        }
        if(!worldMap[startPoint.x][startPoint.y - 1] && !visited[startPoint.x][startPoint.y - 1]){
            points.append(Point(x: startPoint.x,y: startPoint.y - 1,empty: false))
            visited[startPoint.x][startPoint.y - 1] = true
        }
        if(!worldMap[startPoint.x + 1][startPoint.y] && !visited[startPoint.x + 1][startPoint.y]){
            points.append(Point(x: startPoint.x + 1,y: startPoint.y,empty: false))
            visited[startPoint.x + 1][startPoint.y] = true
        }
        if(!worldMap[startPoint.x - 1][startPoint.y] && !visited[startPoint.x - 1][startPoint.y]){
            points.append(Point(x: startPoint.x - 1,y: startPoint.y,empty: false))
            visited[startPoint.x - 1][startPoint.y] = true
        }
        if(!worldMap[startPoint.x + 1][startPoint.y + y_offset] && !visited[startPoint.x + 1][startPoint.y + y_offset]){
            points.append(Point(x: startPoint.x + 1,y: startPoint.y + y_offset,empty: false))
            visited[startPoint.x + 1][startPoint.y + y_offset] = true
        }
        if(!worldMap[startPoint.x - 1][startPoint.y + y_offset] && !visited[startPoint.x - 1][startPoint.y + y_offset]){
            points.append(Point(x: startPoint.x - 1 ,y: startPoint.y + y_offset,empty: false))
            visited[startPoint.x - 1][startPoint.y + y_offset] = true
        }
        
        return points
    }
    
    override func shouldAutorotate() -> Bool {
        return false;
    }
    
}

